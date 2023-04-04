1- Image Scan (codes scanner)
   Scan image before Pushing to repository
   - snyk solution
   - Sysdig solution

2- Run container as non-root
3- RBAC user/group persmission on resources
4- Network Policy  --- Services Mesh
 EX:
    [Frontend] ------------------->[backend]
                                       |
                                    [database]
 deny communication between frontend & DB
 
 5- Encrypt Communication
     - Communication Rules
     - mTLS between pods
6- Secure secret data
   - Encryptconfigurate
   - Valt
 
7- Secure etcd
8- Backup & Restore
  Kaston k10
  secure backup & restore

9- Configure secure policy
    - Open Policy Agent
    - kyverno

10- Disaster Recovery
   Kaston 10
   Automate Disaster recovery
==============================================================
