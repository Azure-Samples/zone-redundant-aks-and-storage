#!/bin/bash

# Variables
source ./00-variables.sh
nodeCount=2

# Iterate node pools
for ((i = 1; i <= 3; i++)); do
  userNodePoolName=${userNodePoolPrefix}$(printf "%02d" "$i")

  # Retrieve the node count for the current node pool
  echo "Retrieving the node count for the [$userNodePoolName] node pool..."
  count=$(az aks nodepool show \
    --name $userNodePoolName \
    --cluster-name $aksClusterName \
    --resource-group $resourceGroupName \
    --query count \
    --output tsv \
    --only-show-errors)

  # Disable autoscaling for the current node pool
  echo "Disabling autoscaling for the [$userNodePoolName] node pool..."
  az aks nodepool update \
    --cluster-name $aksClusterName \
    --name $userNodePoolName \
    --resource-group $resourceGroupName \
    --disable-cluster-autoscaler \
    --only-show-errors 1>/dev/null

  # Run this command only if the current node count is not equal to two
  if [[ $count -ne $nodeCount ]]; then
    # Scale the current node pool to two nodes
    echo "Scaling the [$userNodePoolName] node pool to $nodeCount nodes..."
    az aks nodepool scale \
      --cluster-name $aksClusterName \
      --name $userNodePoolName \
      --resource-group $resourceGroupName \
      --node-count $nodeCount \
      --only-show-errors 1>/dev/null
  else
    echo "The [$userNodePoolName] node pool is already scaled to $nodeCount nodes"
  fi
done
