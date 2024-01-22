#!/bin/bash

# Variables
source ./00-variables.sh

# Retrieve the names of the pods with the 'app=zne-nginx' label
echo "Retrieving the names of the pods with the 'app=zne-nginx' label..."
result=$(kubectl get pods -l app=zne-nginx -n $namespace -o jsonpath='{.items[*].metadata.name}')

# Convert the string of pod names into an array
podNames=($result)

for podName in ${podNames[@]}; do

  # Retrieve the name of the node running the pod
  nodeName=$(kubectl get pods $podName -n $namespace -o jsonpath='{.spec.nodeName}')

  if [ -n "$nodeName" ]; then
    echo "The [$podName] pd runs on the [$nodeName] agent node"
  else
    echo "Failed to retrieve the name of the node running the [$podName] pod"
    exit 1
  fi
  
  # Retrieve the availability zone of the node running the pod
  agentPoolZone=$(kubectl get nodes $nodeName -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}')

  if [ -n "$agentPoolZone" ]; then
    echo "The [$nodeName] agent node is in the [$agentPoolZone] availability zone"
  else
    echo "Failed to retrieve the availability zone of the [$nodeName] agent node"
    exit 1
  fi

  # Retrieve the name of the agent pool for the node running the pod
  agentPoolName=$(kubectl get nodes $nodeName -o jsonpath='{.metadata.labels.agentpool}')

  if [ -n "$agentPoolName" ]; then
    echo "The [$nodeName] agent node belongs to the [$agentPoolName] agent pool"
  else
    echo "Failed to retrieve the name of the agent pool for the [$nodeName] agent node"
    exit 1
  fi

  # Cordon the node running the pod
  echo "Cordoning the [$nodeName] node..."
  kubectl cordon $nodeName

  # Drain the node running the pod
  echo "Draining the [$nodeName] node..."
  kubectl drain $nodeName --ignore-daemonsets --delete-emptydir-data --force
done