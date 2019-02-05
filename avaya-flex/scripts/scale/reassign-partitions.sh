#!/bin/bash

helmName=$1
ids=$2

if [ -z $ids ];
then
  echo "Broker ids to which the paritions need to be re-assigned need to be passed in"
  exit 1
fi

#create topics-to-move.json
cat <<EOF > /tmp/re-assign-partitions-util.sh
#!/bin/bash
topics=\$(zookeeper-shell.sh $helmName-cp-zookeeper-headless:2181 ls /brokers/topics | tail -n 1 | tr -d '[] ')

echo '{"topics": [' > /tmp/topics_to_move.json
insertComma=""

for topic in \${topics//,/ }
do
  if [ -n "\$insertComma" ];
  then
    echo ',' >> /tmp/topics_to_move.json
  fi
  echo '{"topic": "'\$topic'"}' >> /tmp/topics_to_move.json
  insertComma=","
done

echo '],"version":1}' >> /tmp/topics_to_move.json

generatedResult=\$(kafka-reassign-partitions.sh --zookeeper $helmName-cp-zookeeper-headless:2181 --topics-to-move-json-file /tmp/topics_to_move.json --broker-list "$ids" --generate)

echo "\$generatedResult" | head -n 2 | tail -n 1 > /tmp/currentReplicaAssignment.json.bak
echo "\$generatedResult" | tail -n 1 > /tmp/newReplicaAssignment.json

kafka-reassign-partitions.sh --zookeeper $helmName-cp-zookeeper-headless:2181 --reassignment-json-file /tmp/newReplicaAssignment.json --execute
EOF

#kubectl cp /tmp/re-assign-partitions-util.sh default/$helmName-0:/tmp/re-assign-partitions-util.sh -c kafka-broker
cat /tmp/re-assign-partitions-util.sh | kubectl exec -i -c cp-kafka-broker $helmName-cp-kafka-0 -- /bin/bash -c "cat > /tmp/re-assign-partitions-util.sh"
kubectl exec $helmName-cp-kafka-0 -c cp-kafka-broker -- /bin/bash /tmp/re-assign-partitions-util.sh

#verify whether all the re-assignment successful
pendingCount=1
verifyCount=0
while [ $pendingCount -gt 0 ]
do
  verifyResult=$(kubectl exec -ti $helmName-cp-kafka-0 -c cp-kafka-broker -- kafka-reassign-partitions.sh --zookeeper $helmName-cp-zookeeper-headless:2181 --reassignment-json-file /tmp/newReplicaAssignment.json --verify)

  pendingCount=`echo "$verifyResult" | tail -n -1 | grep -v "successfully" | wc -l`
  echo "reAssignments pending $pendingCount"
  echo "$verifyResult" | tail -n -1 | grep -v "successfully"
  echo "waiting for 5 seconds"
  verifyCount=$((verifyCount + 1))
  if [ $verifyCount -gt 120 ]
  then
    break
  fi
  sleep 5
done

echo "re-assignment successfully done"

echo "doing leader re-balancing"
kubectl exec -ti $helmName-cp-kafka-0 -c cp-kafka-broker -- kafka-preferred-replica-election.sh --zookeeper $helmName-cp-zookeeper-headless:2181
