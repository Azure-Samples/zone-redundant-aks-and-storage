#!/bin/bash

# Get all persistent volumes
pvs=$(kubectl get pv -o json)

# Loop over pvs
for pv in $(echo "${pvs}" | jq -r '.items[].metadata.name'); do
  # Retrieve the resource id of the managed disk from the persistent volume
  echo "Retrieving the resource id of the managed disk from the [$pv] persistent volume..."
  diskId=$(kubectl get pv $pv -o jsonpath='{.spec.csi.volumeHandle}')

  if [ -n "$diskId" ]; then
    diskName=$(basename $diskId)
    echo "Successfully retrieved the resource id of the [$diskName] managed disk from the [$pv] persistent volume"
  else
    echo "Failed to retrieve the resource id of the managed disk from the [$pv] persistent volume"
    exit 1
  fi

  # Retrieve the managed disk from Azure
  echo "Retrieving the [$diskName] managed disk from Azure..."
  disk=$(az disk show \
    --ids $diskId \
    --output json \
    --only-show-errors)
  
  if [ -n "$disk" ]; then
    echo "Successfully retrieved the [$diskName] managed disk from Azure"
    echo "[$diskName] managed disk details:"
    echo $disk | jq -r
  else
    echo "Failed to retrieve the [$diskName] managed disk from Azure"
    exit 1
  fi
done