1- Create a resource group
az group create -n AKSDemo -l eastus

2- Create your AKS cluster
az aks create -g AKSDemo -n myAKSCluster --node-count 1 \
   --enable-addons monitoring \
   --generates-ssh-keys 
   
3- Connect to the cluster
az aks get-credentials \
 -g AKSDemo \
 -n myAKSCluster
