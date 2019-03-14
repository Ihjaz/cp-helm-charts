#!/bin/bash

# This script needs to be updated to get kafka pod and bootstrap server names dynamically, instead of hardcoding the product name.

if [ -z $2 ];then
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --bootstrap-server eventing-kafka-cp-kafka-headless:9092 --group $3 --topic $4 --reset-offsets --to-earliest
else
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --bootstrap-server eventing-kafka-cp-kafka-headless:9092 --group $3 --topic $4 --reset-offsets --to-earliest $5
fi

