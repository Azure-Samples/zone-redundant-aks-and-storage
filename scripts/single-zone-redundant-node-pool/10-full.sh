#!/bin/bash

# Variables
source ./00-variables.sh

for podName in ${podNames[@]}; do
  # Retrieve the name of the node running the pod
  nodeName=$(kubectl get pods $podName -o jsonpath='{.spec.nodeName}' -n $namespace)

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

  # Retrieve the type of the agent pool
  agentPoolType=$(kubectl get nodes $nodeName -o jsonpath='{.metadata.labels.kubernetes\.azure\.com/nodepool-type}')

  if [ -n "$agentPoolType" ]; then
    echo "The [$agentPoolName] agent pool is of type [$agentPoolType]"
  else
    echo "Failed to retrieve the type of the [$agentPoolName] agent pool"
    exit 1
  fi

  if [ $agentPoolType == "VirtualMachineScaleSets" ]; then

    if [ -z $nodeResourceGroupName ]; then
      # Retrieve the name of the AKS node resource group
      nodeResourceGroupName=$(az aks show \
        --name $aksClusterName \
        --resource-group $resourceGroupName \
        --query nodeResourceGroup \
        --output tsv \
        --only-show-errors)

      if [ -n "$nodeResourceGroupName" ]; then
        echo "[$nodeResourceGroupName] nodes resource group successfully found for the [$aksClusterName] AKS cluster"
      else
        echo "Failed to retrieve the name of the node resource group for the [$aksClusterName] AKS cluster"
        exit 1
      fi
    fi

    # Retrieve the VMSS name for the node pool
    vmssName=$(az vmss list \
      --resource-group $nodeResourceGroupName \
      --query "[?starts_with(name, 'aks-$agentPoolName-')].name" \
      --output tsv \
      --only-show-errors)

    if [ -n "$vmssName" ]; then
      echo "[$vmssName] VMSS successfully found for the [$agentPoolName] agent pool"
    else
      echo "Failed to retrieve the name of the VMSS for the [$agentPoolName] agent pool"
      exit 1
    fi

    # Find the VMSS instance name and id for the node running the pod
    vmssInstanceName=$(az vmss list-instances \
      --name $vmssName \
      --resource-group $nodeResourceGroupName \
      --query "[?osProfile.computerName=='$nodeName'].name" \
      --output tsv \
      --only-show-errors)

    if [ -n "$vmssInstanceName" ]; then
      echo "[$vmssInstanceName] VMSS instance name successfully found for the [$nodeName] node"
    else
      echo "Failed to retrieve the name of the VMSS instance for the [$nodeName] node"
      exit 1
    fi

    # Find the VMSS instance name and id for the node running the pod
    vmssInstanceId=$(az vmss list-instances \
      --name $vmssName \
      --resource-group $nodeResourceGroupName \
      --query "[?osProfile.computerName=='$nodeName'].instanceId" \
      --output tsv \
      --only-show-errors)

    if [ -n "$vmssInstanceId" ]; then
      echo "[$vmssInstanceId] VMSS instance id successfully found for the [$nodeName] node"
    else
      echo "Failed to retrieve the name of the VMSS instance for the [$nodeName] node"
      exit 1
    fi

    # Cordon the node running the pod
    echo "Cordoning the [$nodeName] node..."
    kubectl cordon $nodeName

    # Drain the node running the pod
    echo "Draining the [$nodeName] node..."
    kubectl drain $nodeName --ignore-daemonsets --delete-emptydir-data --force

    # Stop the node running the pod
    echo "Stopping the [$nodeName] node..."
    az vmss stop \
      --name $vmssName \
      --resource-group $nodeResourceGroupName \
      --instance-ids $vmssInstanceId \
      --no-wait \
      --only-show-errors
  fi
done
