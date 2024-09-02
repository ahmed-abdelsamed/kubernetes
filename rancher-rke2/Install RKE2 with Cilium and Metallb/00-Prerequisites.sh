cat /etc/hosts

'''
10.10.10.236    rke2-worker1 rke2-worker1.linkdev.local

10.10.10.243   rke2-master1  rke2-master1.linkdev.local
10.10.10.129   rke2-master2  rke2-master2.linkdev.local
10.10.10.223    rke2-master3  rke2-master3.linkdev.local

10.10.10.171    bastion-server bastion-server.linkdev.local  lb lb.linkdev.local
'''
## apply on all VMs (masters & workers)
#Operating System Pre-requisites
dnf update -y

#Networking Pre-requisites
#First of all, we must enable 2 kernel modules.
#Run the following:

modprobe br_netfilter
modprobe overlay
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
overlay
EOF

#Now configure sysctl to prepare OS for Kubernetes and of course for security purposes.

cat <<EOF | tee /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.default.log_martians=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.default.accept_ra=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
kernel.keys.root_maxbytes=25000000
kernel.keys.root_maxkeys=1000000
kernel.panic=10
kernel.panic_on_oops=1
vm.overcommit_memory=1
vm.panic_on_oom=0
net.ipv4.ip_local_reserved_ports=30000-32767
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-arptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF


## Firewall Pre-requisites

#!/usr/sbin/nft -f

flush ruleset

table inet filter {
  chain input {
    type filter hook input priority filter; policy accept;
    tcp dport 22 accept;
    ct state established,related accept;
    iifname "lo" accept;
    ip protocol icmp accept;
    ip daddr 8.8.8.8 tcp dport 53 accept;
    ip daddr 8.8.8.8 udp dport 53 accept;
    ip daddr 8.8.4.4 tcp dport 53 accept;
    ip daddr 8.8.4.4 udp dport 53 accept;
    ip daddr 1.1.1.1 tcp dport 53 accept;
    ip daddr 1.1.1.1 udp dport 53 accept;
    ip saddr 192.168.100.11 accept;
    ip saddr 192.168.100.12 accept;
    ip saddr 192.168.100.13 accept;
    ip saddr 192.168.100.14 accept;
    ip saddr 192.168.100.15 accept;
    ip saddr 192.168.100.16 accept;
    ip saddr 192.168.100.100 tcp dport {9345,6443,443,80} accept;
    ip saddr 192.168.100.100 udp dport {9345,6443,443,80} accept;
    counter packets 0 bytes 0 drop;
  }

  chain forward {
    type filter hook forward priority filter; policy accept;
  }

  chain output {
    type filter hook output priority filter; policy accept;
  }
}

systemctl enable nftables
systemctl restart nftables



