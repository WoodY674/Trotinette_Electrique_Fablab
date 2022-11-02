#Trotinette_Electrique_Fablab
Ceci est un Projet de d'électrification d'une trottinette, 
connectée afin de récupérer des informations telles que 
le niveau de batterie, la vitesse et la vitesse enclenchée.

Réalisé en partenariat avec le fablab de Cergy, 
durant notre année de M1 M2i lead dev



#Application Flutter
L'application est constituée d'un unique écran proposant :
- Un GPS permettant de définir son itinéraire via une Google Map
- l'affichage des informations récupérées sur la trotinette
- Un mode de suivi du parcours :
  - centré sur l'utilisateur, 
  - centré sur l'ensemble du parcours, permettant une vue d'ensemble



#Api Raspberry
Afin de transmettre les informations à l'application flutter,
nous avons configuré un Raspberry en hotspot wifi.

Nous avons ensuite crée une API en flutter permettant aux appareils connecté 
au réseau wifi de récuperé les données à affiché sur l'application.



#Arduino
Pour récuperer des données sur la trotinette tel que l'autonomie restante
et la vitesse enclenchée, nous devons traité des données brutes de la 
batterie (voltage).

Nous utilisons pour cela un Arduino, qui pourra analyser le courant électrique
transmis par la batterie.
En connaissant le voltage minimum et maximum de la batterie, 
on peut en déduire son autonomie restante.

En connaissant les valeurs des voltage délivrés pour chaque vitesse enclenchée,
on peut en déduire laquelle est actuellement utilisé, et donc également en 
déduire la vitesse de la trotinette


