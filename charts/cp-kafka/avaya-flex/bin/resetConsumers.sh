#!/bin/bash

# This script needs to be updated to get kafka pod and bootstrap server names dynamically, instead of hardcoding the product name.

if [[ ! -z $1 && ! -z $2 && $3 != "--execute" ]];then
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --bootstrap-server eventing-kafka-cp-kafka-headless:9092 --group $1 --topic $2 --reset-offsets --to-earliest
else
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --bootstrap-server eventing-kafka-cp-kafka-headless:9092 --group $1 --topic $2 --reset-offsets --to-earliest $3
fi

