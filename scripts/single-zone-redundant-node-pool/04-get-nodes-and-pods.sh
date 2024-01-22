#!/bin/bash

# Variables
source ./00-variables.sh

# Get nodes region and zone
kubectl get nodes -L topology.kubernetes.io/region,topology.kubernetes.io/zone

# Get pods
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP,HOSTIP:.status.hostIP,NODE:.spec.nodeName -n $namespace