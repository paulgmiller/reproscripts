az k8s-extension create \
    --cluster-name $1 \
    --cluster-type managedClusters \
    --extension-type microsoft.evictionautoscaler \
    --name beta \
    --resource-group evictions \
    --release-train dev \
    --version 0.1.2 \
    --auto-upgrade-minor-version false \
    --config Paul=Dumb