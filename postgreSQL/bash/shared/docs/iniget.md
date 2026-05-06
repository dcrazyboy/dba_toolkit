# INFORMATIONS GENERALES

## But
Tester les retours de la fonction iniget de la bibliothèque function_central.

Ce script fonctionne avec n'importequelle fichier de type **INI**

Le retour affiche au maximum pour chaque section du fichier INI 
```
Section: [<section>>]
----
  <clef> = <valeur>
  /.../
  <clef> = <valeur>
----

```
Il ya plusieur mode d'appels utilisable en paramètre
- Une liste des sections avec possibilite de filtre
- La liste des clef/valeur d'une section avec possibilite de filtre
- La totalité du fichier INI avec possibilite de filtre qui s'applique sur les ensembles de clef/valeur

le filtre acceprte le métacaractère * qui peut être présent plusieurs fois dans le filtre : exemple : db*=*xx

### Chemins relatif utilisées
- PATHTOOLS => Chemin relatif au répertoire d'installation des scripts et leur dépedance
- PATHDATAS => Chemin relatif au répertoire d'installation contenant les fichiers de données

## Installaiton

cf : README.md

### règles de constitution du filtre
- abcdefg => filtre strict sur la valeur
- abc* => tout ce qui commence par abd
- *efg = tout ce qui finit par efg
- `*adc*efg*` => tout ce qui contient abc puis efg

### Paramètres en entrée
L'ordre des param_tres est **strict**

1. `<fichier source>` : Mandatory :fichier de type INI avec le chemin relatif depuis **PATHDATAS**
2. Le mode de recherche au choix : Mandatory:
   1. --list : recherche des noms de section
   2. `<section>` : nom de la section ou l'on cherche l'info
   3.  --all : recherche globale dans toutes les section
3. Le filtre : Facultatif : si vide renvoi tout en fonction des limites impose par le mode de recherche

### dépendences
- function_central.sh : bibliothèque de fonctions bash

## Quelques exemples

1. recherche dans les section de toutes les entrée concernant la prodA
```bash
./iniget.sh db.ini --list *prA*
```
Résultat
```
source fichier : /home/CDWEB/jnicolle/scripts/data/db.ini
type recherche : --list
        filtre : *prA*
récuperation des valeur
# Affichage pour vérification
Section: [ZABIX;prA;main;15;zabbix;]
----
Section: [PG-CIUCH;prA;main;14;ciuchhermesdb;]
----
Section: [PG-CIUCH;prA;main;14;edb;]
----

```
2. recherche des clef/valeur de la section : [PG-CIUCH;prA;main;14;ciuchhermesdb;]

Subtilité les nom de section contiennent des caractères d'echapement [] que le bash ne prend pas en compte si le paramètre n'est pas mis entre ""

```bash
./iniget.sh db.ini "[PG-CIUCH;prA;main;14;ciuchhermesdb;]"
```
Résultat
```
source fichier : /home/CDWEB/jnicolle/scripts/data/db.ini
type recherche : [PG-CIUCH;prA;main;14;ciuchhermesdb;]
        filtre :
récuperation des valeur
# Affichage pour vérification
Section: [PG-CIUCH;prA;main;14;ciuchhermesdb;]
----
  db_replication_type = primary
  db_replication = Y
  db_instance = main
  db_version = 14
  db_ip_host = 10.10.133.139
  db_port = 5432
  db_cluster = PG-CIUCH
  db_host = cd01srvhcpga001.cdweb.biz
  db_env = prA
  db_name = ciuchhermesdb
----
```
3. recherche dans le fichier des clef commencant par db_i
```bash
./iniget.sh db.ini --all db_i*
```
Résultat
```
source fichier : /home/CDWEB/jnicolle/scripts/data/db.ini
type recherche : --all
        filtre : db_i*
récuperation des valeur
# Affichage pour vérification
Section: [PG-CIUCH;prC;main;14;edb;]
----
  db_instance = main
  db_ip_host = 10.11.133.215
----
Section: [ZABIX;prB;main;15;zabbix;]
----
  db_ip_host = 10.11.163.3
  db_instance = main

/.../

----
Section: [PG-CIUCH;prB;main;14;edb;]
----
  db_instance = main
  db_ip_host = 10.10.133.140
----
```

4. Recherche de de clef dans une section identifiée

```bash
 ./iniget.sh db.ini "[PG-DC2-CLUSTER1;pprodA;pgargoworkflowsarchive;14;argoworkflowsarchivedb;]" *rep*
```
Résultat
```
source fichier : /home/CDWEB/jnicolle/scripts/data/db.ini
type recherche : [PG-DC2-CLUSTER1;pprodA;pgargoworkflowsarchive;14;argoworkflowsarchivedb;]
        filtre : *rep*
récuperation des valeur
# Affichage pour vérification
Section: [PG-DC2-CLUSTER1;pprodA;pgargoworkflowsarchive;14;argoworkflowsarchivedb;]
----
  db_replication_type = primary
  db_replication = Y
----
