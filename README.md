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

#EnviromentL: 
Minikube avec Docker Desktop Windows
$minikube start


#Estructure
C:.
│   Dockerfile
│   README.md
│   
├───k8s
│       deployment.yaml
│       deployment2.yaml
│       index.html
│       index2.html
│       ingress.yaml
│       pv.yaml
│       pvc.yaml
│       secrets.yaml
│       services.yaml
│
└───keys
        ca.crt
        ca.key
        ca.srl
        cert.pem
        hello-itsf.crt
        hello-itsf.csr
        hello-itsf.key
        hello-risf.crt
        hello-risf.csr
        hello-risf.key
        key.pem
        ssl.conf



#Image creee a partir de nginx avec l'archive index RISF:
https://hub.docker.com/r/gburucua/hello-image/tags


#Applying files in order: 
kubectl apply -f secrets.yaml
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f deployment2.yaml
kubectl apply -f services.yaml
kubectl apply -f ingress.yaml

#Site1  
Working locally
$ minikube service hello-risf-service --url -n hello-gb
http://127.0.0.1:51753

![hello risf local](https://github.com/gburucua/Exercice_RISF_ITSF_Nice/assets/47932497/fd02224c-c930-48a6-b677-ea3d4544dc2a)


#Problemes recontree 

certs: 
Unexpected error validating SSL certificate "hello-gb/hello-itsf-tls-secret" for server "hello-itsf.local.domain": x509: certificate relies on legacy Common Name field, use SANs instead

ingress:
pas possible de gerer le traffic vers l'IP du cluster du minikube
avec minikube tunnel active 


mounts:
cest pas possible de redirigir le path dans le PV directment ou minikube
essayer avec:
minikube mount C:\Users\Buruc\Desktop\Exercice_RISF_ITSF_Nice\k8s:/mnt/host
  hostPath:
    path: /mnt/host/index2.html



Pour l'instant la mayorite de problems relacione avec du Minikube
