#!/bin/bash

# Variables
source ./00-variables.sh

# Check if the resource group already exists
echo "Checking if ["$resourceGroupName"] resource group actually exists in the [$subscriptionName] subscription..."

az group show --name $resourceGroupName --only-show-errors &>/dev/null

if [[ $? != 0 ]]; then
  echo "No ["$resourceGroupName"] resource group actually exists in the [$subscriptionName] subscription"
  echo "Creating ["$resourceGroupName"] resource group in the [$subscriptionName] subscription..."

  # create the resource group
  az group create \
    --name $resourceGroupName \
    --location $location \
    --only-show-errors 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "["$resourceGroupName"] resource group successfully created in the [$subscriptionName] subscription"
  else
    echo "Failed to create ["$resourceGroupName"] resource group in the [$subscriptionName] subscription"
    exit -1
  fi
else
  echo "["$resourceGroupName"] resource group already exists in the [$subscriptionName] subscription"
fi

# Check if log analytics workspace exists and retrieve its resource id
echo "Retrieving ["$logAnalyticsName"] Log Analytics resource id..."
az monitor log-analytics workspace show \
  --name $logAnalyticsName \
  --resource-group $resourceGroupName \
  --query id \
  --output tsv \
  --only-show-errors &>/dev/null

if [[ $? != 0 ]]; then
  echo "No ["$logAnalyticsName"] log analytics workspace actually exists in the ["$resourceGroupName"] resource group"
  echo "Creating ["$logAnalyticsName"] log analytics workspace in the ["$resourceGroupName"] resource group..."

  # Create the log analytics workspace
  az monitor log-analytics workspace create \
    --name $logAnalyticsName \
    --resource-group $resourceGroupName \
    --identity-type SystemAssigned \
    --sku $logAnalyticsSku \
    --location $location \
    --only-show-errors

  if [[ $? == 0 ]]; then
    echo "["$logAnalyticsName"] log analytics workspace successfully created in the ["$resourceGroupName"] resource group"
  else
    echo "Failed to create ["$logAnalyticsName"] log analytics workspace in the ["$resourceGroupName"] resource group"
    exit -1
  fi
else
  echo "["$logAnalyticsName"] log analytics workspace already exists in the ["$resourceGroupName"] resource group"
fi

# Retrieve the log analytics workspace id
workspaceResourceId=$(az monitor log-analytics workspace show \
  --name $logAnalyticsName \
  --resource-group $resourceGroupName \
  --query id \
  --output tsv \
  --only-show-errors 2>/dev/null)

if [[ -n $workspaceResourceId ]]; then
  echo "Successfully retrieved the resource id for the ["$logAnalyticsName"] log analytics workspace"
else
  echo "Failed to retrieve the resource id for the ["$logAnalyticsName"] log analytics workspace"
  exit -1
fi

# Check if the client virtual network already exists
echo "Checking if [$virtualNetworkName] virtual network actually exists in the [$resourceGroupName] resource group..."
az network vnet show \
  --name $virtualNetworkName \
  --resource-group $resourceGroupName \
  --only-show-errors &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$virtualNetworkName] virtual network actually exists in the [$resourceGroupName] resource group"
  echo "Creating [$virtualNetworkName] virtual network in the [$resourceGroupName] resource group..."

  # Create the client virtual network
  az network vnet create \
    --name $virtualNetworkName \
    --resource-group $resourceGroupName \
    --location $location \
    --address-prefixes $virtualNetworkAddressPrefix \
    --subnet-name $systemSubnetName \
    --subnet-prefix $systemSubnetPrefix \
    --only-show-errors 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$virtualNetworkName] virtual network successfully created in the [$resourceGroupName] resource group"
  else
    echo "Failed to create [$virtualNetworkName] virtual network in the [$resourceGroupName] resource group"
    exit -1
  fi
else
  echo "[$virtualNetworkName] virtual network already exists in the [$resourceGroupName] resource group"
fi

# Check if the user subnet already exists
echo "Checking if [$userSubnetName] user subnet actually exists in the [$virtualNetworkName] virtual network..."
az network vnet subnet show \
  --name $userSubnetName \
  --vnet-name $virtualNetworkName \
  --resource-group $resourceGroupName \
  --only-show-errors &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$userSubnetName] user subnet actually exists in the [$virtualNetworkName] virtual network"
  echo "Creating [$userSubnetName] user subnet in the [$virtualNetworkName] virtual network..."

  # Create the user subnet
  az network vnet subnet create \
    --name $userSubnetName \
    --vnet-name $virtualNetworkName \
    --resource-group $resourceGroupName \
    --address-prefix $userSubnetPrefix \
    --only-show-errors 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$userSubnetName] user subnet successfully created in the [$virtualNetworkName] virtual network"
  else
    echo "Failed to create [$userSubnetName] user subnet in the [$virtualNetworkName] virtual network"
    exit -1
  fi
else
  echo "[$userSubnetName] user subnet already exists in the [$virtualNetworkName] virtual network"
fi

# Check if the pod subnet already exists
echo "Checking if [$podSubnetName] pod subnet actually exists in the [$virtualNetworkName] virtual network..."
az network vnet subnet show \
  --name $podSubnetName \
  --vnet-name $virtualNetworkName \
  --resource-group $resourceGroupName \
  --only-show-errors &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$podSubnetName] pod subnet actually exists in the [$virtualNetworkName] virtual network"
  echo "Creating [$podSubnetName] pod subnet in the [$virtualNetworkName] virtual network..."

  # Create the pod subnet
  az network vnet subnet create \
    --name $podSubnetName \
    --vnet-name $virtualNetworkName \
    --resource-group $resourceGroupName \
    --address-prefix $podSubnetPrefix \
    --only-show-errors 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$podSubnetName] pod subnet successfully created in the [$virtualNetworkName] virtual network"
  else
    echo "Failed to create [$podSubnetName] pod subnet in the [$virtualNetworkName] virtual network"
    exit -1
  fi
else
  echo "[$podSubnetName] pod subnet already exists in the [$virtualNetworkName] virtual network"
fi

# Check if the bastion subnet already exists
echo "Checking if [$bastionSubnetName] bastion subnet actually exists in the [$virtualNetworkName] virtual network..."
az network vnet subnet show \
  --name $bastionSubnetName \
  --vnet-name $virtualNetworkName \
  --resource-group $resourceGroupName \
  --only-show-errors &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$bastionSubnetName] bastion subnet actually exists in the [$virtualNetworkName] virtual network"
  echo "Creating [$bastionSubnetName] bastion subnet in the [$virtualNetworkName] virtual network..."

  # Create the bastion subnet
  az network vnet subnet create \
    --name $bastionSubnetName \
    --vnet-name $virtualNetworkName \
    --resource-group $resourceGroupName \
    --address-prefix $bastionSubnetPrefix \
    --only-show-errors 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$bastionSubnetName] bastion subnet successfully created in the [$virtualNetworkName] virtual network"
  else
    echo "Failed to create [$bastionSubnetName] bastion subnet in the [$virtualNetworkName] virtual network"
    exit -1
  fi
else
  echo "[$bastionSubnetName] bastion subnet already exists in the [$virtualNetworkName] virtual network"
fi

# Retrieve the system subnet id
systemSubnetId=$(az network vnet subnet show \
  --name $systemSubnetName \
  --vnet-name $virtualNetworkName \
  --resource-group $resourceGroupName \
  --query id \
  --output tsv \
  --only-show-errors 2>/dev/null)

if [[ -n $systemSubnetId ]]; then
  echo "Successfully retrieved the resource id for the [$systemSubnetName] subnet"
else
  echo "Failed to retrieve the resource id for the [$systemSubnetName] subnet"
  exit -1
fi

# Retrieve the user subnet id
userSubnetId=$(az network vnet subnet show \
  --name $userSubnetName \
  --vnet-name $virtualNetworkName \
  --resource-group $resourceGroupName \
  --query id \
  --output tsv \
  --only-show-errors 2>/dev/null)

if [[ -n $userSubnetId ]]; then
  echo "Successfully retrieved the resource id for the [$userSubnetName] subnet"
else
  echo "Failed to retrieve the resource id for the [$userSubnetName] subnet"
  exit -1
fi

# Retrieve the pod subnet id
podSubnetId=$(az network vnet subnet show \
  --name $podSubnetName \
  --vnet-name $virtualNetworkName \
  --resource-group $resourceGroupName \
  --query id \
  --output tsv \
  --only-show-errors 2>/dev/null)

if [[ -n $podSubnetId ]]; then
  echo "Successfully retrieved the resource id for the [$podSubnetName] subnet"
else
  echo "Failed to retrieve the resource id for the [$podSubnetName] subnet"
  exit -1
fi

# Get the last Kubernetes version available in the region
kubernetesVersion=$(az aks get-versions \
  --location $location \
  --query "values[?isPreview==null].version | sort(@) | [-1]" \
  --output tsv \
  --only-show-errors 2>/dev/null)

# Create AKS cluster
echo "Checking if ["$aksClusterName"] aks cluster actually exists in the ["$resourceGroupName"] resource group..."

az aks show --name $aksClusterName --resource-group $resourceGroupName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No ["$aksClusterName"] aks cluster actually exists in the ["$resourceGroupName"] resource group"
  echo "Creating ["$aksClusterName"] aks cluster in the ["$resourceGroupName"] resource group..."

  # Create the aks cluster
  az aks create \
    --name $aksClusterName \
    --resource-group $resourceGroupName \
    --service-cidr $serviceCidr \
    --dns-service-ip $dnsServiceIp \
    --os-sku $osSku \
    --node-osdisk-size $osDiskSize \
    --node-osdisk-type $osDiskType \
    --vnet-subnet-id $systemSubnetId \
    --nodepool-name $systemNodePoolName \
    --pod-subnet-id $podSubnetId \
    --enable-cluster-autoscaler \
    --node-count $nodeCount \
    --min-count $minCount \
    --max-count $maxCount \
    --max-pods $maxPods \
    --location $location \
    --kubernetes-version $kubernetesVersion \
    --ssh-key-value $sshKeyValue \
    --node-vm-size $nodeSize \
    --enable-addons monitoring \
    --workspace-resource-id $workspaceResourceId \
    --network-policy $networkPolicy \
    --network-plugin $networkPlugin \
    --service-cidr $serviceCidr \
    --enable-managed-identity \
    --enable-workload-identity \
    --enable-oidc-issuer \
    --enable-aad \
    --enable-azure-rbac \
    --aad-admin-group-object-ids $aadProfileAdminGroupObjectIDs \
    --nodepool-taints CriticalAddonsOnly=true:NoSchedule \
    --nodepool-labels nodePoolMode=system created=AzureCLI osDiskType=ephemeral osType=Linux --nodepool-tags osDiskType=ephemeral osDiskType=ephemeral osType=Linux \
    --tags created=AzureCLI \
    --cluster-autoscaler-profile balance-similar-node-groups=true \
    --only-show-errors \
    --zones 1 2 3 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "["$aksClusterName"] aks cluster successfully created in the ["$resourceGroupName"] resource group"
  else
    echo "Failed to create ["$aksClusterName"] aks cluster in the ["$resourceGroupName"] resource group"
    exit -1
  fi
else
  echo "["$aksClusterName"] aks cluster already exists in the ["$resourceGroupName"] resource group"
fi

# Iterate from 1 to 3 to create a node pool in each availability zone
for ((i = 1; i <= 3; i++)); do
  userNodePoolName=${userNodePoolPrefix}$(printf "%02d" "$i")

  # Check if the user node pool exists
  echo "Checking if ["$aksClusterName"] aks cluster actually has a user node pool..."
  az aks nodepool show \
    --name $userNodePoolName \
    --cluster-name $aksClusterName \
    --resource-group $resourceGroupName &>/dev/null

  if [[ $? == 0 ]]; then
    echo "A node pool called [$userNodePoolName] already exists in the [$aksClusterName] AKS cluster"
  else
    echo "No node pool called [$userNodePoolName] actually exists in the [$aksClusterName] AKS cluster"
    echo "Creating [$userNodePoolName] node pool in the [$aksClusterName] AKS cluster..."

    az aks nodepool add \
      --name $userNodePoolName \
      --mode $mode \
      --cluster-name $aksClusterName \
      --resource-group $resourceGroupName \
      --enable-cluster-autoscaler \
      --eviction-policy $evictionPolicy \
      --os-type $osType \
      --os-sku $osSku \
      --node-vm-size $vmSize \
      --node-osdisk-size $osDiskSize \
      --node-osdisk-type $osDiskType \
      --node-count $nodeCount \
      --min-count $minCount \
      --max-count $maxCount \
      --max-pods $maxPods \
      --tags osDiskType=managed osType=Linux \
      --labels osDiskType=ephemeral osType=Linux \
      --vnet-subnet-id $userSubnetId \
      --pod-subnet-id $podSubnetId \
      --labels nodePoolMode=user created=AzureCLI osDiskType=ephemeral osType=Linux --tags osDiskType=ephemeral osDiskType=ephemeral osType=Linux \
      --zones $i 1>/dev/null

    if [[ $? == 0 ]]; then
      echo "[$userNodePoolName] node pool successfully created in the [$aksClusterName] AKS cluster"
    else
      echo "Failed to create the [$userNodePoolName] node pool in the [$aksClusterName] AKS cluster"
      exit -1
    fi
  fi
done

# Use the following command to configure kubectl to connect to the new Kubernetes cluster
echo "Getting access credentials configure kubectl to connect to the ["$aksClusterName"] AKS cluster..."
az aks get-credentials \
  --name $aksClusterName \
  --resource-group $resourceGroupName \
  --overwrite-existing

if [[ $? == 0 ]]; then
  echo "Credentials for the ["$aksClusterName"] cluster successfully retrieved"
else
  echo "Failed to retrieve the credentials for the ["$aksClusterName"] cluster"
  exit -1
fi
