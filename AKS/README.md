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

========================
## kubernetes

$kubectl create deployment myapp --image=manojnair/myapp:v1 --replicas=1

$kubectl expose deployment myapp --type=LoadBalancer --port=80 --target-port=80

# how max pods in cluster
$az aks nodepool show --cluster-name aksdemo1 --name agentpool --query "maxPods"
'110'

$kubectl get pods --namespace kube-system | Measure

#scale cluster
$az aks scale       ` 
--resource-group aks-rg1 `
--name aksdemo1 `
--node-count 2 `
--no-wait `

$az aks nodepool show --name agentpool --cluster-name aksdemo1 --query "[count,provisioningState]"

# Update application
$kubectl set image deploy/myapp myapp=manojnair/myapp:v2 

$kubectl rollout history deploy/myapp 

$kubectl rollout undo deploy/myapp

$kubectl rollout undo deploy/myapp --to-revision 1

