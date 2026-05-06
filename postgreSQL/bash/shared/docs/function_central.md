# INFORMATIONS GENERALES

## But
Ce script shell est une collection de fonctins appelables
Elle s'integre à n'importe quel script shell par un include placée entre la fin des définition de variables globale et le debut du code

Le but est de centraliser et normalise les appel par les scripts maitres. Elle ne gere donc que des cas generique

Il y a 3 groupe de fonction :
- Vérification d'environement
- execution d'ordre  sur serveur distant ou base distantes
- extraction des donnée d'un fichier de type ini avec mise en forme sous forme de tableau exploitable

Cest fonction utilise les codes retours de base linux
#exit values
ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=4

## Les fonction de vérification
**do_verif_path**
paramètre : "chemin à vérifier" (obligatoire)
Si le répertoire n'existe pas la fonction arrete le scriot avec un exit $ST_CR (critique)

**do_verif_file**
paramètre : "fichier à vérifier, chemin inclu" (obligatoire)
paramètre : "force" (facultatif)

Si le fichier n'existe pas et qu'on est en mode interactif ($2 vide ou autre que "force")
debranche sur la confirmation de by_pass_err pour permettre de continuer
Si le fichier n'existe pas et qu'on est en mode force 
affiche un message et retourne un code $ST_UK (inconu) à gérer dans le shell appelant

**do_db_command**
paramètres :
  host=$1
  port=$2
  db_name=$3
  user=$4
  mode_exec=$5
  pg_command=$6

Execute un commande sur une base distante et retourne le résultat de la requette, le paramettre mode_sec permet de formater le retour pour son traitement
L'appel peut se faire en deux modes :
- Interactif => affichage sans traitement des valeur retourné aprés, le mode_exec est alors au minimum **"I"** : 
```bash
# exemple appel
do_db_command $host $port $db_name $user $mode_exec $command
```
- Batch => le shell appelant recevra les valeurs dans une variable de type tableau prédéfinie, le mode_exec est alors au minimum **"B"** : 
```bash
# exemple appel
output_command=$(do_db_command $host $port $db_name $user $mode_exec $command)
```
La valeur du mode _exec peur être la suivante :
- pour un appel en mode intéractif :
  - I => interactif, affichage classique psql
  - IT => interactif sans entete (nomage colone) ni nombre de lignes retournée
  - IX => interactif mode basculé (colone /valeur) avec entête colonne et nb ligne retournée
  - IXT = interactif mode basculé sans entete (nomage colone) ni nombre de lignes retournée
  - B => batch, affichage classique psql
  - BT => batch sans entete (nomage colone) ni nombre de lignes retournée
  - BX => batch mode basculé (colone /valeur) avec entête colonne et nb ligne retournée
  - BXT = batch mode basculé sans entete (nomage colone) ni nombre de lignes retournée

**do_db_script**
paramtres :
  host=$1
  port=$2
  db_name=$3
  user=$4
  pg_script=$5
  out=$6

Execute un script SQL -simple requete ou DML ou DDL sur une base distante par psql

exemple apel :
```bash
    PGPASSWORD=${pg_pasw}
    export PGPASSWORD
    #echo "$set_out"
    if [[ "${set_out}" == "E" || "${set_out}" == "e" ]];then
      do_db_script "${db_host}" "${db_port}" "${db_name}" "${pg_user}" "${set_script}"
    else
      fic_out="${PATHOUTPUT}/${set_script%.*}_${db_name}_${db_env}.log"
      if [ -f "${fic_out}" ];then
        rm "${fic_out}" 2>"${PATHDATAS}/error.log"
      fi
      do_db_script "${db_host}" "${db_port}" "${db_name}" "${pg_user}" "${set_script}" > "${fic_out}"
#ou      do_db_script "${db_host}" "${db_port}" "${db_name}" "${pg_user}" "${set_script}" "${fic_out}"
      echo "résultat dans : ${fic_out}"
    fi
    unset PGPASSWORD
```

**do_ssh_command**
parametres :
  os_user=$1
  host $2
  commande=$3
  err_log=$4
  os_pass=$5

execute une commande bash sur un serveur distant par connexion avec le user mentionné
ATTENTION : a utilise en mode interactif de préférence ou a tout le moin la premiere fois car le serveur distant va demande a valider l'echange de clef pour le compte

**do_ssh_sudo_command**
paramètres: 
  os_user=$1
  host $2
  commande=$3
  err_log=$4
  os_pass=$5

execute une commande bash sur un serveur distant par connexion avec le user mentionné en utilisant le sudo pour changer de compte une fois connecté, si le sudo est autorisé
ATTENTION : a utilise en mode interactif de préférence ou a tout le moin la premiere fois car le serveur distant va demande a valider l'echange de clef pour le compte

**iniget**
paramètres 
  fichier_ini = $1
  section_recherchée = $2
  clef_recherchée = $3

Fonction qui a partir d'un nom de fichier de type in (section plus suite de clef/valeur associé) retourne dans une variable de type tableau de tableau shell la listes des valeur correspondant en fonction de la section recherche et d'eventuel filtrage
Voir iniget.sh pour le fonctionnement de l'appel
pour memoire une courte aide

- usage : iniget <file> [--list|<section>|--all] [filtre]]"
  - paramètres :
    - <file> : nom du fichier ini à exploiter comprenant le chemin
    - [--list|<section>|--all] : type de reecherche
      - --list : retrouene les ent^te de section
      - --all  : retrouen la totalite des ligne du fichier ini format [<section>]<clef><valeur>
      - <section> : nom de la section dans laquelle faire la recherche
    - [filter] (facultatif) : string de valeur a rechecher dans le type de recherche format [*]<caracteres>[*]...
      - exemple : 
        - *abc*fg* : file trusr al présence des chane de caractère abc puis fg
        - abc*fg*  : filtre sur les valeur commencant apr abc et contenant fg
        - *abc*fg  : filte sur les valeur contenant abc et finissant apr fg
        - abc*fg  : filtre sur les valeur commencant par abc et finissant par fg

**convert_pattern**
paramètres:
  input=$1

Sous-fonction convertissant un forma de patterne ave c* (voir exemple de la fonction inget) en un format regex exploitable dans un grep