#set up some parameters/defaults
export s="8ecadfc9-d1a3-4ea4-b844-0d9f87e4d7c8"
export rg="mutiagenteast"
export l="eastus"
export vnet="multiagenteast"
export c="multiagenteast"

az group create --location $l --name $rg
az configure --defaults group=$rg 
az account set -s $s

#Create our two subnet network
az network vnet create -g $rg --name $vnet --address-prefixes 10.0.0.0/8 -o none
az network vnet subnet create -g $rg --vnet-name $vnet --name s1 --address-prefixes 10.240.0.0/16 
az network vnet subnet create -g $rg --vnet-name $vnet --name s2 --address-prefixes 10.241.0.0/16 


#create cluster
#az aks create -n $c -g $rg -l $l --max-pods 250 --node-count 2 --network-plugin kubenet --vnet-subnet-id /subscriptions/$s/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/s1
#az aks nodepool add --cluster-name $c -g $rg  -n other --max-pods 250 --node-count 2 --vnet-subnet-id /subscriptions/$s/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/s2

#Shove in goldpinger.
#az aks get-credentials -n $c -g $rg
#kubectl apply -f https://gist.githubusercontent.com/paulgmiller/084bd4605f1661a329e5ab891a826ae0/raw/94a32d259e137bb300ac8af3ef71caa471463f23/goldpinger-daemon.yaml
#kubectl apply -f https://gist.githubusercontent.com/paulgmiller/7bca68cd08cccb4e9bc72b0a08485edf/raw/d6a103fb79a65083f6555e4d822554ed64f510f8/goldpinger-deploy.yaml
