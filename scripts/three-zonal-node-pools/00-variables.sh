# Azure Kubernetes Service (AKS) cluster
prefix="Amon"
aksClusterName="${prefix}Aks"
resourceGroupName="${prefix}RG"
location="WestEurope"
osSku="AzureLinux"
osDiskSize=50
osDiskType="Ephemeral"
systemNodePoolName="system"

# Virtual Network
virtualNetworkName="${prefix}VNet"
virtualNetworkAddressPrefix="10.0.0.0/8"
systemSubnetName="SystemSubnet"
systemSubnetPrefix="10.240.0.0/16"
userSubnetName="UserSubnet"
userSubnetPrefix="10.241.0.0/16"
podSubnetName="PodSubnet"
podSubnetPrefix="10.242.0.0/16"
bastionSubnetName="AzureBastionSubnet"
bastionSubnetPrefix="10.243.2.0/24"

# AKS variables
dnsServiceIp="172.16.0.10"
serviceCidr="172.16.0.0/16"
aadProfileAdminGroupObjectIDs="4e4d0501-e693-4f3e-965b-5bec6c410c03"

# Log Analytics
logAnalyticsName="${prefix}LogAnalytics"
logAnalyticsSku="PerGB2018"

# Node count, node size, and ssh key location for AKS nodes
nodeSize="Standard_D4ds_v4"

sshKeyValue="~/.ssh/id_rsa.pub"

# Network policy
networkPolicy="azure"
networkPlugin="azure"

# Node count variables
nodeCount=1
minCount=3
maxCount=20
maxPods=100

# Node pool variables
userNodePoolPrefix="user"
evictionPolicy="Delete"
vmSize="Standard_D4ds_v4" #Standard_F8s_v2, Standard_D4ads_v5
osType="Linux"
mode="User"

# SubscriptionName and tenantId of the current subscription
subscriptionName=$(az account show --query name --output tsv)
tenantId=$(az account show --query tenantId --output tsv)

# Kubernetes sample
namespace="disk-test"