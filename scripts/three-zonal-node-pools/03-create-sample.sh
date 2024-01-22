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

# Create the zne-pvc-azure-disk persistent volume claim
kubectl apply -f zne-pvc.yml -n $namespace

# Create the zne-nginx-01, zne-nginx-02, and zne-nginx-03 deployments
kubectl apply -f zne-deploy.yml -n $namespace