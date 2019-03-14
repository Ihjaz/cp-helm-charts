#!/bin/sh

if [ -z $2 ];then
echo "Error:- Topic name requied for deleting a Topic"

else
kubectl delete kafkatopic $2
fi

