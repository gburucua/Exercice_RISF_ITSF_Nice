# Exercice_RISF_ITSF_Nice

Création d'un cluster Kubernetes en local ( avec Docker for Windows/MAC, Kind ou k3s )

Déploiement d'un micro service nginx pour afficher une page web static:

Contenu de la page web: "HELLO RISF"
Création d'une image docker se basant sur l'image nginx officiel et y ajouter le .html.
utilisation de cette image pour le déploiement.
Déploiement d'un deuxième micro service nginx pour afficher une page web static:

Contenu de la page web: "HELLO ITSF"
Utilisation de l'image docker nginx officiel
Le .html devrait être monté via un PV en local.
Bonus : ces micro-services ne devront pas tourner avec le user root.

Exposition des pages web avec Ingress :

Création d'une pki ( CA root )
générer un certificat hello-risf.local.domain signé par le CA
généré un certificat hello-itsf.local.domain signé par le CA
exposer les pages web sous les noms de domaine hello-risf.local.domain et hello-itsf.local.domain avec les certificats générés
trafic en HTTPS jusqu'à Ingress, puis en HTTP jusqu'aux micro service nginx.
Lorsque l'on visitera les deux sites web depuis le navigateur internet, le warning de sécurité ne devra pas apparaître :


----------------------------------------------------------------------------------------------------------------------------------------------

# Enviroment: 
Docker Desktop for Mac

# File structure

![structure](https://github.com/gburucua/Exercice_RISF_ITSF_Nice/assets/47932497/68d54384-7f00-40c5-82d6-799318baf7e0)




# Image created from nginx with index file RISF:
](https://hub.docker.com/repository/docker/gburucua/nginx/general)

----------------------------------------------------------------------------------------

# Before starting its needed to install ingress-ngxing controller
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Set default namespace:
$ kubectl config set-context --current --namespace=ingress-nginx

----------------------------------------------------------------------------------------
# Certificates and Secrets:

Create file openssl.cnf 
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = req_distinguished_name
req_extensions     = req_ext

[req_distinguished_name]
commonName         = hello-itsf.local.domain

[req_ext]
basicConstraints   = critical,CA:TRUE,pathlen:0
keyUsage           = critical,keyCertSign,cRLSign
subjectAltName     = @alt_names

[alt_names]
DNS.1              = hello-itsf.local.domain
DNS.2              = hello-risf.local.domain 

----------------------------------------------------------------------------------------

# Generating CA (certificate authority)
$ openssl genrsa -out ca.key 2048 
$ openssl req -new -key ca.key -out ca.csr -subj "/CN=hello-itsf.local.domain" -config openssl.cnf
$ openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt -days 365 -extensions req_ext -extfile openssl.cnf


----------------------------------------------------------------------------------------


# For ITSF 
Create key and csr:
$openssl req -new -nodes -newkey rsa:2048 -keyout hello-itsf.local.domain.key -out hello-itsf.local.domain.csr \
  -subj "/CN=hello-itsf.local.domain" \
  -config openssl.cnf

Sign:
$ openssl x509 -req -in hello-itsf.local.domain.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out hello-itsf.local.domain.crt -days 365 -sha256 \
  -extfile <(printf "subjectAltName=DNS:hello-itsf.local.domain,DNS:hello-risf.local.domain") 

----------------------------------------------------------------------------------------


# For RISF 
Create key and csr: 
$ openssl req -new -nodes -newkey rsa:2048 -keyout hello-risf.local.domain.key -out hello-risf.local.domain.csr \
  -subj "/CN=hello-risf.local.domain" \
  -config openssl.cnf

Sign:
$ openssl x509 -req -in hello-risf.local.domain.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out hello-risf.local.domain.crt -days 365 -sha256 \
  -extfile <(printf "subjectAltName=DNS:hello-itsf.local.domain,DNS:hello-risf.local.domain") 



# Import ca.crt in browser: Mozilla 

Create Secrets:
$ kubectl create secret tls hello-risf-tls-secret --cert=hello-risf.local.domain.crt --key=hello-risf.local.domain.key -n ingress-nginx
$ kubectl create secret tls hello-itsf-tls-secret --cert=hello-itsf.local.domain.crt --key=hello-itsf.local.domain.key -n ingress-nginx

TODO:
All this with secrets manifest.

----------------------------------------------------------------------------------------

# Applying files in order: 
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f deployment2.yaml
kubectl apply -f services.yaml
kubectl ingress-controller-deployment.yaml (To add secrets to the ingress controller)
kubectl apply -f ingress.yaml


# Testing in Mozilla

# Site1 RIFS

![RISF](https://github.com/gburucua/Exercice_RISF_ITSF_Nice/assets/47932497/21134486-dc86-4ee4-be6a-366142ed259b)


# Site2 ITSF

![ITSF](https://github.com/gburucua/Exercice_RISF_ITSF_Nice/assets/47932497/c24e3d4f-d056-4ffc-b16c-31435c5028cd)


# Security (To run containers as nonroot):

Added permissions to specific folders of nginx with the user nginx in dockerfile and in the deployment added a few lines to reflect it.

FROM nginx:1.20
COPY index.html /etc/nginx/html/index.html
WORKDIR /app
RUN chown -R nginx:nginx /app && chmod -R 755 /app && \
        chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/conf.d && \
        chown -R nginx:nginx /usr/share/nginx/html

RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid

Switch to the nginx user
USER nginx

#EXPOSE <PORT_NUMBER>

Specify the command to run NGINX
CMD ["nginx", "-g", "daemon off;"]


deployment.yaml
...
...
    spec:
      securityContext:
        runAsUser: 101   # UID of the nginx user
        fsGroup: 101      # GID of the nginx user
...
...
        securityContext:
          runAsNonRoot: true



Iburuc:k8s gburucua$ k exec -it hello-world-nginx-c9c9d9b8b-ww7nx /bin/bash
nginx@hello-world-nginx-c9c9d9b8b-ww7nx:/app$

# Problemes recontree 

- certs 
- ingress 
- mounts 
