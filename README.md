# Trotinette_Electrique_Fablab
Ceci est un Projet de d'électrification d'une trottinette, 
connectée afin de récupérer des informations telles que 
le niveau de batterie, la vitesse et la vitesse enclenchée.

Réalisé en partenariat avec le fablab de Cergy, 
durant notre année de M1 M2i lead dev


## Sommaire
 1. [Application Flutter](#application-flutter)
 2. [Api Raspberry](#api-raspberry)
 3. [Arduino](#arduino)


# Application Flutter
L'application est constituée d'un unique écran proposant :
- Un GPS permettant de définir son itinéraire via une Google Map
- l'affichage des informations récupérées sur la trotinette
- Un mode de suivi du parcours :
  - centré sur l'utilisateur, avec orientation de la map vers le prochain point à atteindre
  - centré sur l'itinéraire, avec une vue d'ensemble du parcours à effectuer


# Api Raspberry
Afin de transmettre les informations à l'application flutter,
nous avons configuré un Raspberry en hotspot wifi.

Nous avons ensuite créé une API en flask (python) permettant aux appareils connectés
au réseau wifi de récuperer les données à afficher sur l'application.

Les scripts sont disponibles dans le dossier `addon/raspberry/`.
Les scripts shell fournis permettent de simplifier le lancement et l'arrêt de l'api,
lancé via un service (crée avec l'utilisation du script `write_service.sh`) ou 
la commande python `python3 app.py`.

# Arduino
Pour récuperer des données sur la trotinette tel que l'autonomie restante
et la vitesse enclenchée, nous devons traiter des données brutes de la 
batterie (voltage).

Nous utilisons pour cela un Arduino, qui pourra analyser le courant électrique
transmis par la batterie.
En connaissant le voltage minimum et maximum de la batterie, 
on peut en déduire son autonomie restante.

En connaissant les valeurs des voltages délivrés pour chaque vitesse enclenchée,
on peut en déduire laquelle est actuellement utilisé, et donc également en 
déduire la vitesse de la trotinette

Les scripts sont disponibles dans le dossier `addon/arduino/`
