Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  3m19s  default-scheduler  0/4 nodes are available: 4 node(s) had untolerated taint {node.cloudprovider.kubernetes.io/uninitialized: true}. preemption: 0/4 nodes are available: 4 Preemption is not helpful for scheduling.

# this issue because of all VMs (masters & worker) had taint
1- add in each pods the same taint 
2- delete taint on nodes < recommende on workers nodes only


k describe node rke2-master2 | grep Taints
k taint node rke2-master1 node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule-
k taint node rke2-master2 node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule-
k taint node rke2-master3 node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule-
k taint node rke2-worker1 node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule-

