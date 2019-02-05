#!/bin/bash

#this script takes these arguments
# 1. number of brokers to delete
currentCount=$1
newCount=$2
helmName=$3
baseDir=$(dirname $0)

if [ -z $"helmName" ];
then
  echo "Eventing helm not installed nothing to scale"
  exit 0
fi

#scale the statefulset replica - statefulset name will be same as helm name
echo "Current broker count=$currentCount and new broker count=$newCount"

#if newCount is less than existing replication factor it cannot be scaled down
replicationFactor=$(kubectl exec -ti -c cp-kafka-broker $helmName-cp-kafka-0 -- kafka-topics.sh --describe --zookeeper $helmName-cp-zookeeper-headless:2181 |grep ReplicationFactor | sed 's/.*ReplicationFactor:\(.\).*/\1/' | sort -n -r | uniq | head -n 1)

if [ $replicationFactor -gt $newCount ];
then
  echo "newCount is less than the existing replicationFactor $replicationFactor of some topics"
  exit 1
fi

#get existing broker ids
brokerIds=$(kubectl exec -ti -c cp-kafka-broker $helmName-cp-kafka-0 -- zookeeper-shell.sh $helmName-cp-zookeeper-headless:2181 ls /brokers/ids | tail -n 1 | tr -d '[] ' | tr ',' '\n' | sort -n | head -n $newCount)

brokerIdsAsCommaSeperated=""
addComma=""
for brokerId in $brokerIds
do
  if [ -n "$addComma" ];
  then
    brokerIdsAsCommaSeperated=$brokerIdsAsCommaSeperated,
  fi
  brokerIdsAsCommaSeperated=$brokerIdsAsCommaSeperated$brokerId
  addComma=","
done
brokerIdsAsCommaSeperated=$(echo $brokerIdsAsCommaSeperated | tr -d '\r')
echo "brokers that will be retained and used in re-assignment $brokerIdsAsCommaSeperated"

#re-assign the paritions to the brokers which will be retained
/bin/bash $baseDir/reassign-partitions.sh $brokerIdsAsCommaSeperated

sleep 5

#kubectl scale statefulsets $helmName --replicas=$newCount

echo "Removing nodeport service for the brokers"

while [ $currentCount -gt $newCount ]
do
  currentCount=$[ $currentCount - 1 ]
  #echo $currentCount
  kubectl delete service $helmName-$currentCount-nodeport
done
