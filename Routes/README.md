## OpenSSL for encrypt route in openshift
$openssl req -x509 -newkey rsa:4096 -nodes -keyout mykey.key -out mykey.crt 

#Note , when create openssl , write URL [test.apps.ocp.coffee.me] correct for project 


# Creating an edge route:
$oc create route edge <name> --service=<service_name> --cert=<cert_name> --key=<key_file> --hostname=<URL>
$oc describe route <name>

-------------
# Creating a re-encrypt route
$oc create route reencrypt <name> --serivce=<service_name> --cert=<cert_name> --key=<key_file> \
--dest-ca-cert=<destination_ca_certifcate>
--ca-cert=<ca_certificate> --hostname=<URL>

----------------
# Creating passthrough route
$oc create secret tls <secret_name> --cert <ca_certificate_file> --key <key_file>
$ oc set volumes deploy/httpd-ex-git --add -t secret --secret-name=<secret_name> -m /usr/local/etc/ssl/certs
$oc create route passthrough <route_name> --service=httpd-ex-git 
OR
$oc create route passthrough <name>
--service=<service_name> --port <port_number>
--hostname=<hostname>
