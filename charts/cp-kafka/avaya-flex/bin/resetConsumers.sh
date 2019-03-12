#!/bin/bash

if [ -z $1 ];then
kubectl exec -it -c cp-kafka-broker eventing-kafka-cp-kafka-0 -- kafka-consumer-groups.sh --bootstrap-server eventing-kafka-cp-kafka-headless:9092 --group test --topic test.mirror --reset-offsets --to-earliest
else
kubectl exec -it -c cp-kafka-broker eventing--kafka-cp-kafka-0 -- kafka-consumer-groups.sh --bootstrap-server eventing-kafka-cp-kafka-headless:9092 --group test --topic test.mirror --reset-offsets --to-earliest --execute
fi

