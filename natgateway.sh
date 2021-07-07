set -ex
#az extension add --name aks-preview

#set up some parameters/defaults
export s="c1089427-83d3-4286-9f35-5af546a6eb67"
export rg="paulbash8"
export l="westus2"
export vnet="paulnet1"
export c="bugbash1"

az group create --location $l --name $rg
az configure --defaults group=$rg 
az account set -s $s

#Create nat gateway and put it on our subnet
az network public-ip create   --resource-group $rg --name natpublicip --sku standard 
az network nat gateway create --resource-group $rg --name natgateway --public-ip-addresses /subscriptions/$s/resourceGroups/$rg/providers/Microsoft.Network/publicIPAddresses/natpublicip
az network vnet create -g $rg --name $vnet --address-prefixes 10.0.0.0/8 -o none
az network vnet subnet create -g $rg --vnet-name $vnet --name nat --address-prefixes 10.240.0.0/16 -o none
az network vnet subnet update --resource-group $rg --vnet-name $vnet --name nat  --nat-gateway natgateway


#create cluster
az aks create -n $c -g $rg -l $l --node-count 2 --yes --vnet-subnet-id /subscriptions/$s/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/nat 

