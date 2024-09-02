#Install Rancher rke2
mkdir -p /etc/rancher/rke2/

vi /etc/rancher/rke2/config.aml
'''
write-kubeconfig-mode: "0644"
advertise-address: 10.10.10.171
tls-san:
  - 10.10.10.171
  - bastion-server.linkdev.local
cni: none
cluster-cidr: 10.100.0.0/16
service-cidr: 10.110.0.0/16
cluster-dns: 10.110.0.10
cluster-domain: arman-projects.com
etcd-arg: "--quota-backend-bytes 2048000000"
etcd-snapshot-schedule-cron: "0 3 * * *"
etcd-snapshot-retention: 10
disable:
  - rke2-ingress-nginx
disable-kube-proxy: true
kube-apiserver-arg:
  - '--default-not-ready-toleration-seconds=30'
  - '--default-unreachable-toleration-seconds=30'
kube-controller-manager-arg:
  - '--node-monitor-period=4s'
kubelet-arg:
  - '--node-status-update-frequency=4s'
  - '--max-pods=100'
egress-selector-mode: disabled
protect-kernel-defaults: true
'''

<<COMMIT
Let's explain the above options:

write-kubeconfig-mode: The permission of the generated kubeconfig file.
advertise-address: Kubernetes API server address that all nodes must connect to.
tls-san: Valid addresses for Kubernetes client certificate. kubectl trusts these addresses and any others are not trusted.
cni: The CNI plugin that must get installed. Here we put none which indicates no CNI should be installed.
cluster-cidr: The CIDR used in pods.
service-cidr: The CIDR used in services.
cluster-dns: Coredns service address.
cluster-domain: The Kubernetes cluster domain. The default value is cluster.local
etcd-arg: etcd database arguments. Here we've just increased the default etcd allowed memory usage.
etcd-snapshot-schedule-cron: Specifies when to perform an etcd snapshot.
etcd-snapshot-retention: Specifies how many snapshots will be kept.
disable: instructs rke2 to not deploy the specified add-ons. Here we've disabled the nginx ingress add-on.
disable-kube-proxy: Whether or not to use kube-proxy for pod networking. Here we have disabled the kube proxy so as to use Cilium instead.
kube-apiserver-arg: Specifies kube api server arguments. Here we've set default-not-ready-toleration-seconds and default-unreachable-toleration-seconds to 30 seconds. The default value is 300 seconds, so in order to reschedule pods faster and maintain service availability, the default values have been decreased.
kube-controller-manager-arg: Specifies the interval of kubelet health monitoring time.
kubelet-arg: Sets kubelet arguments. node-status-update-frequency specifies the time in which node status is updated and max-pods is the maximum number of pods allowed to run on that node.
egress-selector-mode: Disable rke2 egress mode. By default this value is set to agent and Rancher rke2 servers establish a tunnel to communicate with nodes. This behavior is due to prevent opening several connections over and over. In some cases, enabling this mode will cause some routing issues in your cluster, so it's been disabled in our scenario.
protect-kernel-defaults: compare kubelet default parameters and OS kernel. If they're different, the container is killed.
COMMIT

##(Optional) Taint Control Plane nodes
It's preferable to taint the Control Plane nodes so the workload pods won't get scheduled on those. To do so, edit /etc/rancher/rke2/config.yaml and add the following line inside it.
node-taint:
  - "CriticalAddonsOnly=true:NoExecute"



## Install rke2
curl -sfL https://get.rke2.io > install_rke2.sh
chmod ug+x install_rke2.sh
INSTALL_RKE2_VERSION="v1.29.4+rke2r1" INSTALL_RKE2_TYPE="server" ./install_rke2.sh

systemctl disable rke2-agent && systemctl mask rke2-agent

systemctl enable --now rke2-server.service
systemctl status rke2-server
journalctl -u rke2-server -f

echo 'PATH=$PATH:/var/lib/rancher/rke2/bin' >> ~/.bashrc
source ~/.bashrc

mkdir ~/.kube
cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
sed -i 's/127.0.0.1/192.168.100.100/g' ~/.kube/config

#NOTE: If you use kubectl, you'll see that nodes are in NotReady state and the reason for that, is due to the absence of a CNI plugin

## Install Cilium
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin

## Add the following config to a file named cilium.yaml:
# NOTE: As of this day, our Cilium stable version is 1.15.4 and the version of Cilium CLI is 0.16.6.
'''
cluster:
  name: cluster-1
  id: 10
prometheus:
  enabled: true
  serviceMonitor:
    enabled: false
dashboards:
  enabled: true
hubble:
  metrics:
    enabled:
    - dns:query;ignoreAAAA
    - drop
    - tcp
    - flow
    - icmp
    - http
    dashboards:
      enabled: true
  relay:
    enabled: true
    prometheus:
      enabled: true
  ui:
    enabled: true
    baseUrl: "/"
version: 1.15.4
operator:
  prometheus:
    enabled: true
  dashboards:
    enabled: true
'''
cilium install -f cilium.yaml
cilium status
kubectl get nodes


#By default, Cilium uses its own IP CIDR for pods and not the one configured during Cluster bootstrapping. To change this behavior, edit the Cilium config map:

kubectl -n kube-system edit cm cilium-config
#There is a line like this:
ipam: cluster
#Change the value to "kubernetes":
ipam: kubernetes


#The already running pods are still using the default Cilium ipam. To apply yours, either restart the server or restart Cilium resources.
kubectl -n kube-system rollout restart deployment cilium-operator
kubectl -n kube-system rollout restart ds cilium

#NOTE: check other pods too. If they're using the old IPs, restart them too. Our first Control plane node is ready.
