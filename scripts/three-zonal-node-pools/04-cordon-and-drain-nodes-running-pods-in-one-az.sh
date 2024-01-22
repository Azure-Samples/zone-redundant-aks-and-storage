#!/bin/bash

# Retrieve the nodes in the user01 agent pool
echo "Retrieving the ones in the user01 node pool..."
result=$(kubectl get nodes -l kubernetes.azure.com/agentpool=user01 -o jsonpath='{.items[*].metadata.name}')

# Convert the string of node names into an array
nodeNames=($result)

for nodeName in ${nodeNames[@]}; do
  # Cordon the node running the pod
  echo "Cordoning the [$nodeName] node..."
  kubectl cordon $nodeName

  # Drain the node running the pod
  echo "Draining the [$nodeName] node..."
  kubectl drain $nodeName --ignore-daemonsets --delete-emptydir-data --force
done