#!/bin/bash

# This script needs to be updated to get kafka pod and bootstrap server names dynamically, instead of hardcoding the product name.

if [ -z $1 ];then
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --list --bootstrap-server eventing-kafka-cp-kafka-headless:9092
else
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --describe --group $2 --bootstrap-server eventing-kafka-cp-kafka-headless:9092
fi

