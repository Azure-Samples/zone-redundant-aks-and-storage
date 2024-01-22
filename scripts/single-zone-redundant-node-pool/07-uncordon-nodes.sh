#!/bin/bash

# Get all nodes
nodes=$(kubectl get nodes -o json)

# Loop over nodes
for node in $(echo "${nodes}" | jq -r '.items[].metadata.name'); do
  # Check if node is cordoned
  if kubectl get node "${node}" | grep -q "SchedulingDisabled"; then
    # Uncordon node
    echo "Uncordoning node ${node}..."
    kubectl uncordon "${node}"
  fi
done