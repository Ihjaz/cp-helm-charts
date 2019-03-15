#!/bin/bash

# This script needs to be updated to get kafka pod and bootstrap server names dynamically, instead of hardcoding the product name.

if [[ ! -z $1 && ! -z $2 && "$3" != "--execute" ]]; then 
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --bootstrap-server eventing-kafka-cp-kafka-headless:9092 --group $1 --topic $2 --reset-offsets --to-earliest
elif [[ ! -z $1 && ! -z $2 && "$3" == "--execute" ]]; then
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --bootstrap-server eventing-kafka-cp-kafka-headless:9092 --group $1 --topic $2 --reset-offsets --to-earliest $3
else
echo "Error:- Incorrect Input, Please provide input as below."
echo "To Check the current configuraiton of a topic in a consumer group use ccm kafka-util resetConsumers group_name topic_name"
echo "To Reset the current configuration of a topic in a consumer group to default use ccm kafka-util resetConsumers group_name topic_name --execute"
fi
