# INFORMATIONS GENERALES

## But

Ceci est une trame commune pour écrire des scripts exploitant la selection des bases sur lesquelles applique un traitement
Le code exposé a la fin de ce MD a été utilisé comme base pour :
- **pg_filter** 
- **pg_check_account**
- **pg_do_sql**

il propose un code pour effectuer la partie commune de sélection des scriptssité

1. La boucle d'extraction/selection des bases a traiter 

Elle se base sur un filtrage a partir des sous-clef de la section du fichier **db.ini** généré par **discoverpg**
Les parties de clef de section sont les suivantes :
- Nom du cluster système
- Enviroronement
- Version d ePostgres 
- Nom de la base de donnée

2. La boucle de traitement de la liste de sélection

A vous de l'écrire ...


### Appel

./xxxxxxx.sh [ |a|s]

### Paramètres en entrée

Type de filtre à appliquer pour extraire  les sections
Valeurs possibles : 
- vide => toutes les sections (hors les section sous surveillance : sous-clef-section 6 a OLD)
- a => Section concerant des bases actives (prod, preprod, rec,...) (hors les section sous surveillance : sous-clef 6 = OLD)
- s => Section concernant les standby (prod, preprod) (hors les section sous surveillance : sous-clef-section 6 = OLD)

### dépendences
- function_central.sh : bibliothèque de fonctions bash
  
### Chemins relatif utilisées
- PATHTOOLS => Chemin relatif au répertoire d'installation des scripts et leur dépedance
- PATHDATAS => Chemin relatif au répertoire d'installation contenant le fichier des bases identifiées **db.ini**
- PATHSECU => Chemin relatif au répertoire contenant les codes d'acces (doit se trouver dans le $HOME de l'utilisateur(inutile ici car on nefait aucun acces au bases)

## Fonctions internes de base commune à cette famille de scripts
### reinit_filtre
Sur la base de la liste des section existant dans **db.ini** r"cupéré par 
- Filtrage sur db_replication_type
- Filtrage sur le paramètre en entrée
- Décomposition des 6 parties de la section
- Création des tableau de selection

### afficher_menu_principal
Juste echo du menu
### configurer_critere
- Affichage des valeur du tableau concerne
- Constitution de la liste de valeurs retenues pour filtrage
### configurer
Transfere du tableau de liste pour le critères selectionne
### filtrer_liste
Filtrage en cascade par comparaison des valeurs selectionne pour chaque partie de sou-clef avec affichage du nombre d'entrée a chaque filtrage

Ordre de filtrage :
- cluster
- envirronement
- version
- nom de la BDD
  
## Principe

1. **Extraction** : On récupere els section du fichier, on els décompose et on bati avec els clef 4 listes de selection de critère
- Clusters
- Environement
- Version
- Nom de base

2. **Selection** : 
Suite de menu permettant de choisir les élément a croiser pour la seleciton des section en fonction des listes de séléection

3. **Croisement** : Filtrage de la liste intiale de section

4. **résultat** : 
Affichage de la liste de sélection, cette partie peut etre ^remplacée pour executer des commandes sur cette liste de sélection

### Boucle principale
```bash
while true; do
    afficher_menu_principal
    read -p "Choisissez une option (1-6) : " choix_menu
    case "$choix_menu" in
        1) configurer "cluster" ;;
        2) configurer "env" ;;
        3) configurer "version" ;;
        4) configurer "dbname" ;;
        5)
            ch_cluster=()
            ch_env=()
            ch_version=()
            ch_db=()
            echo "Tous les critères ont été réinitialisés."
            sleep 1
            ;;
        6)
            # Vérifier qu'au moins un critère est sélectionné
            if [[ ${#ch_cluster[@]} -eq 0 && ${#ch_env[@]} -eq 0 &&
                  ${#ch_version[@]} -eq 0 && ${#ch_db[@]} -eq 0 ]]; then
                echo "Aucun critère sélectionné !"
                sleep 1
            else
                # Appeler la fonction de filtrage final
                lwrk=()
                filtrer_liste
                break
            fi
            ;;
        7 ) exit $ST_OK 
            ;;
        *) echo "Option invalide." ; sleep 1 ;;
    esac
done
```
## La trame complette


```bash
#!/bin/bash
#------
# Trame de base créer des scripts selectionnant les bases où appliquer un traitement, source de la selection => le resultat du discoverpg
# author : JCN
#------
# Variables globales
PROGNAME=$(basename "$0")
AUTHOR="J-C Nicolle"
VERSION="1.1.0"
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
#output_command=       # retour de sonnées exécuté  sur node externe par function_central
#declare -A liniget=() # array de retour iniget qui ne retourne que des listes indexée

#tableau indexe de filtrage
declare -a lcluster=()   # Liste indexxe des clusters utilisables
declare -a lenv=()       # Liste indexxe des environnement utilisables
declare -a lversion=()   # Liste indexxe des version majeurs utilisables
declare -a ldbname=()    # Liste indexxe des dbname utilisables
declare -a lsrc=()       # liste des bases identifiées
declare -a lsel=()       # liste des sections selectionnée pour traitement
declare -a lwrk=()       # liste de travail
declare -A lconn=()      # listes valeur info de connexion distante
ch_cluster=""
ch_env=""
ch_version=""
ch_db=""
inifiltre=""

# Ecrans
declare -a choix_var=()

BASECONF="${PATHDATAS}/db.ini"

#
# variables de travail / execution
#
db_name=""
db_env=""
db_host=""
db_port=""
pg_user=""
pg_user=""
pg_pasw=""
command=""
set_out=""

source "${PATHTOOLS}/function_central.sh"

reinit_filtre() {
  local wrk      # valeur tableau imbrique liniget
  local section  # clef tableau imbrique liniget
  local key      # sous-clef de valeur tableau imbrique liniget
  local value    # sous-valeur de valeur tableau imbrique liniget
  local kpart1   # cluster partie de la section
  local kpart2   # env partie de la section
  local kpart4   # version pg partie de la section
  local kpart5   # dbname partie de la section
  local kpart6   # surv partie de la section
  local trouve   # flag existence
  local i        # index tableau

  echo "récuperation des valeur"
  # Parcourir chaque élément du tableau
  for wrk in "${liniget[@]}"; do
    # Extraire le groupe (ex: AAAAA)
    section=$(echo "$wrk" | grep -oP '\[\K[^\]]+')
    # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
    key=$(echo "$wrk" | grep -oP '^\[[^]]+\]\K[^=]+')
    value=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
    # repere les base non repmgr et les primaire repmgr
    if [[ "$inifiltre" == "a" && ( "${value}" == "" || "${value}" == "primary") ]] ||
       [[ "$inifiltre" == "s" && "${value}" != "" && "${value}" != "primary" ]] ||
       [[ "$inifiltre" == "*" ]]; then
      # on decompose l'entete de section
      # ATTENTION :
      # modificaiton fu IFS => plantage de la boucle interne => sauvegarde/restore du IFS
      old_IFS=$IFS
      IFS=$'\n'l
      IFS=';' read -ra parts <<< "$section"
      IFS=$old_IFS
      # Assigner les parties (même si certaines sont vides)
      kpart1="${parts[0]:-vide}" # cluster
      kpart2="${parts[1]:-vide}" # env
      kpart4="${parts[3]:-vide}" # version
      kpart5="${parts[4]:-vide}" # dbname
      kpart6="${parts[5]:-vide}" # OLD
      #echo "cluster   : $kpart1"
      #echo "env       : $kpart2"
      #echo "instance  : $kpart3"
      #echo "version   : $kpart4"
      #echo "dbname    : $kpart5"
      #echo "surveille : $kpart6"
      if [[ "$kpart6" == "vide" ]]; then
        lsrc+=( "$section" )
        #echo "${#lsrc[@]} : [$section]"
        trouve=false
        for i in "${lcluster[@]}";do
          if [[ "${i}" == "$kpart1" ]]; then
            trouve=true
          fi
        done
        if [[ "$trouve" == false ]]; then
          lcluster+=("$kpart1")
        fi
        trouve=false
        for i in "${lenv[@]}";do
          if [[ "${i}" == "$kpart2" ]]; then
            trouve=true
          fi
        done
        if [[ "$trouve" == false ]]; then
          lenv+=("$kpart2")
        fi
        trouve=false
        for i in "${lversion[@]}";do
          if [[ "${i}" == "$kpart4" ]]; then
            trouve=true
          fi
        done
        if [[ "$trouve" == false ]]; then
          lversion+=("$kpart4")
        fi
        trouve=false
        for i in "${ldbname[@]}";do
          if [[ "${i}" == "$kpart5" ]]; then
            trouve=true
          fi
        done
        if [[ "$trouve" == false ]]; then
          ldbname+=("$kpart5")
        fi
      fi
    fi
  done
}

# Fonction pour afficher le menu principal
afficher_menu_principal() {
    clear
    echo "===== MENU PRINCIPAL =====
1. Configurer Critère 1 (Cluster) [${ch_cluster[*]}]
2. Configurer Critère 2 (Envirronement) [${ch_env[*]}]
3. Configurer Critère 3 (Version) [${ch_version[*]}]
4. Configurer Critère 4 (dbname) [${ch_db[*]}]
5. Réinitialiser tous les critères
6. Valider et filtrer
7. Abandonner
========================="
}

# Fonction pour demander les choix multiples d'un critère
configurer_critere() {
    local titre="$1"
    shift
    local tableau_name="$@"
    local tableau=("${!tableau_name}")

    echo "=== $titre ==="
    echo "Appuyez sur ENTRÉE pour terminer la sélection."
    PS3="Sélectionnez une option (numéro) : "

    while true; do
      # Utiliser un fichier temporaire pour capturer la sélection
      local selection
      selection=$(printf "%s\n" "${tableau[@]}" | sed 's/^/)/' | cat -n | sed 's/^/ /' | sed 's/^ *//')
      echo "$selection"
      read -p "$PS3" reply

      # Si l'utilisateur appuie sur ENTRÉE
      if [[ -z "$reply" ]]; then
        return
      fi

      # Vérifier si le numéro est valide
      if [[ "$reply" =~ ^[0-9]+$ ]] && [ "$reply" -ge 1 ] && [ "$reply" -le "${#tableau[@]}" ]; then
        local opt="${tableau[$((reply-1))]}"
        # Vérifier si l'option est déjà sélectionnée
        trouve=false
        for i in "${choix_var[@]}";do
          if [[ "${i}" == "$opt" ]]; then
          trouve=true
          fi
        done
        if [[ "$trouve" == false ]]; then
          choix_var+=("$opt")
          echo "Ajouté : $opt"
        else
          echo "Déjà sélectionné : $opt"
        fi
      else
        echo "Numéro invalide."
      fi
    done
}

configurer() {
  local param=$1
  local loptions=()
  choix_var=() #on vide choix_var avant l'appel pour recupere le retour sous forme de liste
  case "$param" in
    cluster)  loptions=("${lcluster[@]}") 
              configurer_critere "Selection des cluster" "loptions[@]" 
              ch_cluster=("${choix_var[@]}") 
              ;;
    env)      loptions=("${lenv[@]}") 
              configurer_critere "Selection des envirronements" "loptions[@]" 
              ch_env=("${choix_var[@]}") 
              ;;
    version)  loptions=("${lversion[@]}") 
              configurer_critere "Selection des versions" "loptions[@]" 
              ch_version=("${choix_var[@]}") 
              ;;
    dbname)   loptions=("${ldbname[@]}") 
              configurer_critere "Selection des bases" "loptions[@]" 
              ch_db=("${choix_var[@]}") 
              ;;
  esac
}

filtrer_liste() {
  echo "=== Filtrage sur la liste de ${#lsrc[@]} bases identifiées"
  lsel=("${lsrc[@]}")
  # Critère 1 : cluster
  if [[ ${#ch_cluster[@]} -gt 0 && ${ch_cluster[*]:-vide} != "vide" ]]; then
    for i in "${ch_cluster[@]}"; do
      # echo "$i"
      for j in "${lsrc[@]}";do
        # echo "j : [$j] =~ i : [$i]" 
        if [[ "$j" == *"$i;"* ]]; then
          # echo "Conserve : $j"
          lwrk+=( "${j}" )
        fi
      done
    done
    lsel=("${lwrk[@]}")
  fi
  echo "=== Résultat du filtrage Cluster ${#lsel[@]} bases conservées ==="
  # Critère 1 : env
  lwrk=() 
  if [[ ${#ch_env[@]} -gt 0 && ${ch_env[*]:-vide} != "vide" ]]; then
    for i in "${ch_env[@]}"; do
      # echo "$i"
      for j in "${lsel[@]}";do
        # echo "j : [$j] =~ i : [$i]" 
        if [[ "$j" == *";$i;"* ]]; then
          # echo "Conserve : $j"
          lwrk+=( "${j}" )
        fi
      done
    done
    lsel=("${lwrk[@]}")
  fi
  echo "=== Résultat du filtrage Environnement ${#lsel[@]} bases conservées ==="
  # Critère 1 : version
  lwrk=() 
  if [[ ${#ch_version[@]} -gt 0 && ${ch_version[*]:-vide} != "vide" ]]; then
    for i in "${ch_version[@]}"; do
      # echo "$i"
      for j in "${lsel[@]}";do
        # echo "j : [$j] =~ i : [$i]" 
        if [[ "$j" == *";$i;"* ]]; then
          # echo "Conserve : $j"
          lwrk+=( "${j}" )
        fi
      done
    done
    lsel=("${lwrk[@]}")
  fi
  echo "=== Résultat du filtrage Version ${#lsel[@]} bases conservées ==="
  # Critère 1 : env
  lwrk=()
  if [[ ${#ch_db[@]} -gt 0 && ${ch_db[*]:-vide} != "vide" ]]; then
    for i in "${ch_db[@]}"; do
      # echo "$i"
      for j in "${lsel[@]}";do
        # echo "j : [$j] =~ i : [$i]" 
        if [[ "$j" == *";$i;"* ]]; then
          # echo "Conserve : $j"
          lwrk+=( "${j}" )
        fi
      done
    done
    lsel=("${lwrk[@]}")
  fi
  echo "=== Résultat du filtrage Base ${#lsel[@]} bases conservées ==="
}
print_help(){
  echo " Programme de selection de bases a traiter"
  echo " usage : pg_selection <base selection> "
  echo "   paramètres :"
  echo "     <base selection> : permet le filtre sur un type de base"
  echo "     Valeurs possibles :"
  echo "        a : selection els bases actives"
  echo "        s : selection les bases standby (inactive)"
  echo "        <>: prend toutes les bases actives et standby"
}

inifiltre=""
#--------
# check param
#--------

if [[ ${1:-*} != "*" && ${1:-*} != "a" && ${1:-*} != "s" ]]; then
  print_help
  exit $ST_WR
else
  inifiltre=${1:-*}
fi

# check environnement
#
do_verif_path "${PATHTOOLS}"
do_verif_path "${PATHDATAS}"
#do_verif_path "${PATHSECU}"
do_verif_file "${BASECONF}"
#
echo "recuperation des filtres"
iniget "$BASECONF" "--all" "*db_replication_type*"
lsrc=()
lcluster=()
lenv=()
lversion=()
ldbname=()

reinit_filtre

while true; do
    afficher_menu_principal
    read -p "Choisissez une option (1-6) : " choix_menu
    case "$choix_menu" in
        1) configurer "cluster" 
           afficher_menu_principal
           ;;
        2) configurer "env"
           afficher_menu_principal
           ;;
        3) configurer "version"
           afficher_menu_principal
           ;;
        4) configurer "dbname"
           afficher_menu_principal
           ;;
        5)
            ch_cluster=()
            ch_env=()
            ch_version=()
            ch_db=()
            echo "Tous les critères ont été réinitialisés."
            sleep 1
            ;;
        6)
            # Vérifier qu'au moins un critère est sélectionné
            if [[ ${#ch_cluster[@]} -eq 0 && ${#ch_env[@]} -eq 0 &&
                  ${#ch_version[@]} -eq 0 && ${#ch_db[@]} -eq 0 ]]; then
                echo "Aucun critère sélectionné !"
                sleep 1
                afficher_menu_principal 
            else
                # Appeler la fonction de filtrage final
                lwrk=()
                filtrer_liste
                break
            fi
            ;;
        7 ) exit $ST_OK 
            ;;
        *) echo "Option invalide." ; sleep 1 ;;
    esac
done

#
# a partir de la on peut ajouter le conne necessaire pour executer une action sur la seleciton
#
#exemple affichage de la selection
```