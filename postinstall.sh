#!/bin/bash
CLUSTER_NAME=$1
AS_ARN=$2
aws eks --region us-east-1 update-kubeconfig --name $CLUSTER_NAME
template=`cat "./k8s/cluster-autoscaler.yaml" | sed "s/{{clustername}}/$CLUSTER_NAME/g"`
# apply the yml with the substituted value
echo "$template" | kubectl apply -f -
