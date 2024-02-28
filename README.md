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

image.png
