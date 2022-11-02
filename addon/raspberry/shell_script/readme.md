#script SH api
Les scripts présent dans ce dossier permettent de gérer la mise en ligne de l'API.
Notamment pour mettre en route le service, permettant de rendre l'API disponible 
dès l'allumage du Raspberry.

`reload_service.sh` permet de mettre en route le service, en prennant en compte 
les dernières modifications apporté à l'API.

Pour les phases de test, on peut stopper le service avec `stop_service.sh`.
Il faut ensuite utilisé le script `start.sh`, ce qui permettra de voir 
les différentes routes appelées, les éventuelles données `print` etc...

En principe, `stop_service.sh` est suffisant, mais il est possible que le process
ne s'arrete pas. Dans ce cas, 