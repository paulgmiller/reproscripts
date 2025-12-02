set -ex
#az extension add --name aks-preview

#set up some parameters/defaults
export s="2aadfc95-1c40-4782-9958-07c2e99fe196"
export l="$1"
export rg="podnet3$l"
export vnet="chinapaul2"
export c="funk3"


az account set -s $s
az configure --defaults group=$rg 
az group create --location $l --name $rg

#Create our two subnet network
az network vnet create -g $rg --name $vnet --address-prefixes 10.0.0.0/8 -o none
az network vnet subnet create -g $rg --vnet-name $vnet --name vms --address-prefixes 10.240.0.0/16 -o none
az network vnet subnet create -g $rg --vnet-name $vnet --name pods --address-prefixes 10.241.0.0/16 -o none


#create cluster
az aks create -n $c -g $rg -l $l --node-count 2 --yes --network-plugin azure -s Standard_A4_v2 \
 --vnet-subnet-id /subscriptions/$s/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/vms \
 --pod-subnet-id /subscriptions/$s/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/pods \
 --nodepool-labels foo=bar --node-count 1 --enable-managed-identity


#Shove in goldpinger.
az aks get-credentials -n $c -g $rg
kubectl apply -f https://gist.githubusercontent.com/paulgmiller/084bd4605f1661a329e5ab891a826ae0/raw/94a32d259e137bb300ac8af3ef71caa471463f23/goldpinger-daemon.yaml
kubectl apply -f https://gist.githubusercontent.com/paulgmiller/7bca68cd08cccb4e9bc72b0a08485edf/raw/d6a103fb79a65083f6555e4d822554ed64f510f8/goldpinger-deploy.yaml
