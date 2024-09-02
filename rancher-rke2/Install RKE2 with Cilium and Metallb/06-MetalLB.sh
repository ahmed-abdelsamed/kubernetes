curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
 chmod 700 get_helm.sh
 ./get_helm.sh


helm repo add metallb https://metallb.github.io/metallb

helm install --create-namespace --namespace metallb-system metallb metallb/metallb

kubectl get pods -n metallb-system


# Configure IP Address Pool

vi main-pool.yaml
'''
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: main-pool
  namespace: metallb-system
spec:
  avoidBuggyIPs: true
  addresses:
  - 192.168.100.50-192.168.100.55
  serviceAllocation:
    serviceSelectors:
      - matchLabels:
         ip-pool: main-pool
'''
kubectl apply -f main-pool.yaml

vi L2Advertisement.yaml
'''
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: main-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
    - main-pool
'''
kubectl apply -f l2advertisement.yaml


