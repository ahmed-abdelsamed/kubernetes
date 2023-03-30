https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/

Exposing the NGINX Ingress Controller
Once the base configuration is in place, 
the next step is to expose the NGINX Ingress Controller to the outside world to allow it to start receiving connections. 
This could be through a load-balancer like on AWS, GCP, Azure, or BareOS with MetalLB. 
The other option when deploying on your own infrastructure without MetalLB, or a cloud provider with less capabilities, 
is to create a service with a NodePort to allow access to the Ingress Controller.

