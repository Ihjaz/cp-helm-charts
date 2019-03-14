#!/bin/bash

# This script needs to be updated to get kafka pod and bootstrap server names dynamically, instead of hardcoding the product name.

if [ -z $1 ];then
kubectl get kafkatopics
else
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-topics.sh --describe --zookeeper eventing-kafka-cp-zookeeper-headless:2181
fi
