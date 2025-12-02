#!/bin/bash

SUB_ID="26fe00f8-9173-4872-9134-bb1d2e00343a" # AKS INT/Staging Test Subscription
RG="paultest"
CLUSTER="enotacular2"
LOCATION="westus2" # For Staging

#Create Resource Group
az group create --subscription "${SUB_ID}" --name "${RG}" --location "${LOCATION}"

#Create AKS Cluster
az aks create --subscription "${SUB_ID}" \
  --resource-group "${RG}" \
  --name "${CLUSTER}" \
  --location "${LOCATION}" \
  --network-dataplane cilium

az aks get-credentials --subscription "${SUB_ID}" \
  --resource-group "${RG}" \
  --name "${CLUSTER}" 