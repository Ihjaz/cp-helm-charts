#!/bin/bash

#this script takes these arguments
# 1. current replica count
# 2. new replica count
# 3. helm release name
# 
currentCount=$1
replicaCount=$2
helmName=$3
baseDir=$(dirname $0)


if [ -z $"helmName" ];
then
  echo "Eventing helm not installed nothing to scale"
  exit 0
fi

echo "Current broker count=$currentCount and new broker count=$replicaCount"

echo "Adding nodeport service for the new brokers"

nodeport=$(kubectl get services $helmName-0-nodeport | tail -n 1 | tr -s ' ' | cut -d ' ' -f 5 | cut -d ":" -f2 | cut -d"/" -f1)

echo "Nodeport is $nodeport"

while [ $currentCount -lt $replicaCount ]
do
  #echo $currentCount
  nodePortValue=$(( $nodeport + $currentCount ))
  echo "Nodeport for kafka pod $currentCount"
  sed -e "s/POD_NAME/$helmName-cp-kafka-$currentCount/; s/HELM_NAME/$helmName/; s/NODE_PORT_NAME/$helmName-$currentCount-nodeport/; s/NODE_PORT_VALUE/$nodePortValue/" $baseDir/nodeportTemplate.yaml > /tmp/nodeportKafka.yaml
  #cat /tmp/nodeportKafka.yaml
  kubectl apply -f /tmp/nodeportKafka.yaml
  currentCount=$[ $currentCount + 1 ]
done

echo "waiting for brokers to get registered in zookeeper"
brokerIds=""
while true
do
  #get existing broker ids
  brokerIds=$(kubectl exec -ti -c cp-kafka-broker $helmName-cp-kafka-0 -- zookeeper-shell.sh $helmName-cp-zookeeper-headless:2181 ls /brokers/ids | tail -n 1 | tr -d '[] ')
  brokerCount=$(( `echo "$brokerIds" | tr -cd ',' | wc -c` + 1 ))
  echo $brokerCount
  echo $brokerIds
  if [ $brokerCount -ge $replicaCount ]
  then
    echo "new brokers added and registered to zookeeper"
    break
  fi
  sleep 10
done

if [ -f $baseDir/reassign-partitions.sh ];
then
  brokerIds=$(echo $brokerIds | tr -d '\r')
  echo "brokers that will be used for re-assignment $brokerIds"
  /bin/bash $baseDir/reassign-partitions.sh "$helmName" "$brokerIds"
else
  echo "Error: reassign-partitions.sh file not found."
  echo "Exiting!!!"
  exit 1
fi

