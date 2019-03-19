#!/bin/sh

if [ -z $1 ];then
echo "Error:- Topic name requied for deleting a Topic"

else
kubectl delete kafkatopic $1
fi

