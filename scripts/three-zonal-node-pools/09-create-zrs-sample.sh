#!/bin/bash

# Variables
source ./00-variables.sh

# Check if namespace exists in the cluster
result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
  echo "$namespace namespace already exists in the cluster"
else
  echo "$namespace namespace does not exist in the cluster"
  echo "creating $namespace namespace in the cluster..."
  kubectl create namespace $namespace
fi

# Create the managed-csi-premium-zrs storage class
kubectl apply -f managed-csi-premium-zrs.yml

# Create the zrs-pvc-azure-disk persistent volume claim
kubectl apply -f zrs-pvc.yml -n $namespace

# Create the zrs-nginx deployment
kubectl apply -f zrs-deploy.yml -n $namespace