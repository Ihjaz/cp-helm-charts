#!/bin/bash

if [ -z $1 ];then
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --list --bootstrap-server eventing--kafka-cp-kafka-headless:9092
else
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --describe --group $1 --bootstrap-server eventing-kafka-cp-kafka-headless:9092
fi

