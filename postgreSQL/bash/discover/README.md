# INFO GENERALES

## Introduction 
Ensembles de scripts (bash ou autre) pour gérer une base postgreSQL ou extraire des informations
Le repo s'organise en 3 parties :
1. Discover
2. Requete SQL
3. Script PGBOUNCER

### Discover
Ensemble de scripts bash :
- **discoverpg.sh** : script d'exploration des serveur et découverte des instances et bases PostgreSQL présente, Le résultat est stocker dans un fichier **db.ini** exploitable
- **function_central.sh** bibliothéque bash d'instructions utilisées par l'ensemble des scripts présent dans le dossier, mais pas que si besoin
- **outils**
  - **initget.sh** script permettant d'interroger tout fichier de type **ini** (organise en section / clef-valeurs) passé en paramètre
  - **discover2json.sh** script de conversion du **db.ini** en format **json**
  - **pg_filter.sh** script d'affichage des section de **db.ini** sur critères de sélection
  - **pg_check_account** script d'affichage de la hiérarchie des roles sur critères de sélectiondans **db.ini**
  - **pg_check_stat_statment** script de vérification d'installation d epg_stat_statement sur critères de sélectiondans **db.ini**
  - **pg_do_sql** script d'execution d'un fichier de commande SQL après selection par critère dans **db.ini**
  - **pg_check_lag** Script de vérification du lag master/slace après selection par critère dans **db.ini**
- **Modèle fichier de configuraiton**
  - **connexion.ini** fichier de paramètre de connexion
  - **discover.ini** fichierde paramètrage pour **discoverpg**
- **Modèle developpement script utilisant db.ini de discover**
  - **trame_commune.md**

Tous ses scripts sont valides pour PostgreSQL 14+
Voir les différents fichier **MD** passociés pour plus de détails techniques
Voir plus loin les considération de sécurité le fichier de connexion

### Requêtes SQL
Ensemble de fichier **.sql** contenant des requête utiles ammasées ou partagées

Ces requettes sont utilisable directement sur une base par PSQL ou peuvent être utilisées par **pg_do_sql.sh** de **discover** pour un lancement en masse si elles sont dépose dans le répertoire **PATHTOOLS**, dans ce dernier cas vous dispose d'un affichage a l'écran des résultats ou la génération d'un fichier pour chaque base traite dans **PATHOUTPUT**

Se référer au README dans **Requete PSQL** pour des détail complémentaire sur la règle de nomage, ce qu'elles font, etc

### Script PGBONCER

To be donne

## Getting Started

###	Installation de discover
Discover peut être installé de deux manières :
1. Standalone
2. Partagé

Dans les deux modes les scripts utilise des variable pour trouver ou déposer des fichiers
- PATHTOOLS => répeetoire de dépots des scripts
- PATHDATAS => répertoire contenant **db.ini** et **db.histo**
- PATHCONF => répertoire contenant le fichier de configuration **discover.ini** peut-être le même que PATHDATAS
- PATHSECU => répertoire contenant le fichier de configuraiton des acces
- PATHOUTPUT => répertoire de dépot des fichiers trace des outils

Si ces chemin sont ''fixés'' pour le mode partagés, vous êtes librs de choisir leur emplacement pour le mode standalone

Considération de sécurité pour PATHSECU **(mode standalone et partagé)**
Le fichier déposé dans ce chemin va contenir des mots de passe, en attendant qu'une version utilisant vault ou autre soit mise en place. Que l'on soit en mode standalone ou partage, il doit **IMPERATIVEMENT** être créé dans le répertoire $HOME et respecter les standard XDG de linux. Le chemin proposé par defaut est : $HOME/.config/toolsconf

#### préparation

1. Standalone

Créer les répertoires
```bash
mkdir -p <chemin de PATHTOOLS>
mkdir -p <chemin de PATHDATAS>
mkdir -p <chemin de PATHCONF>
mkdir -p <chemin de PATHSECU>
mkdir -p <chemin de PATHOUTPUT>
chmod 700 <chemin de PATHSECU>
```
A partir de son compte linux sur la machine cible, vous devez avoir acces aux serveurs visées en SSH pour **discoverpg** ou a tout le moins au bases distantes par PSQL  pour les outils **pg_XXX**

2. Partagé

Afin que cette installatin ''survive'' à une mise à jour de Debian, vérifier que els répertoires ''fixés' existent et son atteignables
au besoin les créée :

- PATHTOOLS  => /usr/local/share/scripts
- PATHDATAS  => /usr/local/share/data
- PATHCONF   => /usr/local/share/data
- PATHSECU   => $HOME/.config/toolsconf
- PATHOUTPUT => $HOME/output

#### Installation

Cloner http://tfs.cdbdx.biz:8080/tfs/DefaultCollection/DbToolsPostgresql/_git/DbToolsPostgresql dans un répertoire temporaire et se positionner dessus

```bash
# copier les scripts
cp discover/*.sh <chemin de PATHTOOLS>
cp discover/discover.ini <chemin de PATHDATAS>
cp discover/connexion.ini <chemin de PATHSECU>

#eventuellement  récupere les script sql 
cp requête\ PSQL/*.sql <chemin de PATHTOOLS>

#mise a jour des droit
chmod +x <chemin de PATHTOOLS>/*.sh
```

#### post-installation

Editer et mettre a jour le fichier qui vous est propres **connexion.ini** dans PATHSECU et faire 
```bash
chmod 600 <chemin de PATHSECU>/connexion.ini
```

Completer si besoin ou modifier le fichier **dn.ini** dans PATHTOOLS

Nettoyer le dossier temporaire de clonage

##### Mettre a jours les fichier scripts pour indique les chemin

Pour tous les script, la définition des répertoires se trouve entre les lignes 10 et 30
Les deux modes son prévue et seul le mode standalone est actif
```
#
# raccourcis répertoire utilisés mode standalone
#
PATHTOOLS="$HOME/scripts"
PATHDATAS="$HOME/scripts/data"
PATHOUTPUT="$HOME/scripts/data"
PATHSECU="$HOME/.config/toolsconf"
#
# raccourcis répertoire utilisés mode partagé
#
#PATHTOOLS="/usr/local/share/scripts"
#PATHDATAS="/usr/local/share/data"
#PATHOUTPUT="/usr/local/share/data"
#PATHSECU="$HOME/.config/toolsconf"
#
#
```
Corriger les chemins actif si le mode standalone est choisi
Si le mode partage est choisi, active les lignes sous :
```
#
# raccourcis répertoire utilisés mode partagé
#
``` 
et corrige le cas écheant les valeurs, l'activation ecrasera les valeur du mode standalone automatiquement

### Caveat et sécurité

Dans l'état actuel les scripts du dossiers discover sont ammene a faire des connexion distanes sur les serveur ou les base. Dans certains cas, le mot de passe associé au compte est demandé. Il est trannsmis depuis les information contenues dans le fichier **connexion.ini**

Le temps d'exposition est minimal. Le temps de l'execution des commandes sur le serverur distant.

Pour le cas des commandes SSH un échange de clef semble le meilleur moyen d'eviter l'utilisation des mot de passe quand c'est possibe et mis en place.

Pour els connexion PSQL, le mot de passe est requis par pgbouncer pour validation. Il est donc necessaire et est expose le temps de l'excution de la requete

Il faudrait voir si ces données ne peuvent pas etre stocke dans un système plus protege et recupérable a la volée genre vault ou autre. 

# TODO
- Voir solution type vault et intégration

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)

