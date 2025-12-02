set -ex
#az extension add --name aks-preview

#set up some parameters/defaults
export s="8ecadfc9-d1a3-4ea4-b844-0d9f87e4d7c8"
export l="$1"
export rg="podsubnet$l"
export vnet="paulnet"
export c="podsubnet$2"

az account set -s $s
az group create --location $l --name $rg
az configure --defaults group=$rg 

#Create our two subnet network
az network vnet create -g $rg --name $vnet --address-prefixes 10.0.0.0/8 -o none
az network nat gateway create -g $rg -n $vnet-gateway -l $l
az network vnet subnet create -g $rg --vnet-name $vnet --name vms --address-prefixes 10.240.0.0/16 -o none
az network vnet subnet create -g $rg --vnet-name $vnet --name pods --address-prefixes 10.241.0.0/16 -o none


#create cluster
az aks create -n $c -g $rg -l $l --node-count 2 --yes --network-plugin azure -s Standard_D2_v3 \
 --vnet-subnet-id /subscriptions/$s/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/vms \
 --pod-subnet-id /subscriptions/$s/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/pods \
 --nodepool-labels foo=bar --node-count 1 --outbound-type userAssignedNATGateway 

#Shove in goldpinger.
az aks get-credentials -n $c -g $rg
