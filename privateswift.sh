#az extension add --name aks-preview
#az extension update --name aks-preview
#az feature register --namespace "Microsoft.ContainerService" --name "PodSubnetPreview"
#az feature register --name EnablePodIdentityPreview --namespace Microsoft.ContainerService
#az feature register --name EncryptionAtHost --namespace Microsoft.Compute
#az provider register --namespace Microsoft.ContainerService
#az provider register -n Microsoft.Compute

AZ_NETWORK_RG=paultest
AZ_NETWORK_NAME=paulswiftnet
AZ_Node_SUBNET_NAME=subnet-nodes
AZ_POD_SUBNET_NAME=subnet-pods
AZ_RESOURCE_GROUP=paultest
AZ_Node_RESOURCE_GROUP=paultest
#AZ_LOCATION=westus
AZ_CLUSTER_NAME=privateswiftsimple


az network vnet create -g $AZ_NETWORK_RG --name $AZ_NETWORK_NAME --address-prefixes 10.0.0.0/8 -o none
az network vnet subnet create -g $AZ_NETWORK_RG --vnet-name $AZ_NETWORK_NAME --name $AZ_Node_SUBNET_NAME --address-prefixes 10.240.0.0/16 -o none
az network vnet subnet create -g $AZ_NETWORK_RG --vnet-name $AZ_NETWORK_NAME --name $AZ_POD_SUBNET_NAME --address-prefixes 10.241.0.0/16 -o none


AZ_VNET_ID=$(az network vnet show --name $AZ_NETWORK_NAME --resource-group $AZ_NETWORK_RG --query id -o tsv)
echo vnetid $AZ_VNET_ID
AZ_SUBNETWORK_K8S_Nodes_ID=$(az network vnet subnet show --name $AZ_Node_SUBNET_NAME --vnet-name $AZ_NETWORK_NAME --resource-group $AZ_NETWORK_RG --query id -o tsv)
echo nodeid  $AZ_SUBNETWORK_K8S_Nodes_ID
AZ_SUBNET_PODs_ID=$(az network vnet subnet show --name $AZ_POD_SUBNET_NAME --vnet-name $AZ_NETWORK_NAME --resource-group $AZ_NETWORK_RG --query id -o tsv)
echo podid  $AZ_SUBNET_PODs_ID
AZ_Docker_Bridge_Range=10.180.0.0/21
AZ_AKS_Service_Range=10.170.0.0/21
DNS_IP=10.170.0.10
K8S_NODE_SIZE=Standard_DS2_v2
#AADGRP_AKS_PROD_SYSADMIN=$(az ad group show --group AADGRP_AKS_PROD_SYSADMIN --query objectId -o tsv)
#AZ_Private_DNS_Zone_Name=privatelink.germanywestcentral.azmk8s.io
#AZ_PrivateDNS_RG=rg-aks01-prod-privatedns
#AZ_PRIVATE_DNS_ZONE_ID=$(az network private-dns zone show --resource-group $AZ_PrivateDNS_RG --name $AZ_Private_DNS_Zone_Name --query id -o tsv)
AZ_Node_RESOURCE_GROUP=rg-aks01-prod-k8s-services
#AZ_LAW_ID=$(az monitor log-analytics workspace show --workspace-name law-eu2-centrallogging-sharedservices-prod-001 --subscription sub-sharedservices-prod --resource-group rg-sharedservices-prod-centrallogging --query id -o tsv)
AZ_SERVICE_TENANT_ID=a6238551-92a6-4d9a-90fa-3f16b12dc7c3
AZ_TENANT_ID=$(az account show --query tenantId --output tsv)
#AZ_IDENTITY_ID=$(az identity show --name msiusr-ge2-lbge2aksprod001-prod-001 --resource-group rg-aks01-prod-identities --query id -o tsv)
#AZ_ACR_ID=$(az acr show --name lbge2azcrprod001 --resource-group rg-aks01-prod-containerregistry --query id -o tsv)
#AppGW_ID=$(az network application-gateway show --name appgw-ge2-prod-001 --resource-group rg-aks01-prod-appgw --query id -o tsv)
SYSTEM_NODE_NAME=lbakssnpp001
USER_NODE_NAME=lbaksunpp001
 
az aks create --resource-group $AZ_RESOURCE_GROUP \
                --name $AZ_CLUSTER_NAME \
                --network-plugin azure \
                --max-pods 250 \
                --enable-cluster-autoscaler \
                --min-count 2 \
                --max-count 6 \
                --node-count 2 \
                --zones 1 2 3 \
                --generate-ssh-keys \
                --vnet-subnet-id $AZ_SUBNETWORK_K8S_Nodes_ID \
                --pod-subnet-id $AZ_SUBNET_PODs_ID \
                --docker-bridge-address $AZ_Docker_Bridge_Range \
                --service-cidr $AZ_AKS_Service_Range \
                --dns-service-ip $DNS_IP \
                --node-vm-size $K8S_NODE_SIZE \
                --dns-name-prefix K8S \
                --enable-aad  \
                --enable-azure-rbac \
                --disable-local-accounts \
                --enable-managed-identity \
                --enable-pod-identity \
                --kubernetes-version 1.22.4 \
                --generate-ssh-keys \
                --enable-private-cluster \
                --enable-encryption-at-host \
                --network-policy calico \
                --nodepool-name systemtemp 
                
                #--uptime-sla 

                #--node-resource-group $AZ_Node_RESOURCE_GROUP \
                #--appgw-id $AppGW_ID \
                #--disable-public-fqdn \
                #--private-dns-zone $AZ_PRIVATE_DNS_ZONE_ID
                #--assign-identity $AZ_IDENTITY_ID \
                #--attach-acr $AZ_ACR_ID \
                #--enable-addons monitoring,azure-policy,azure-keyvault-secrets-provider \
                #--workspace-resource-id $AZ_LAW_ID \
                