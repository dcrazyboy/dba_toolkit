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
mode="I"
res_req=""
ini_mess=""

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
    local tableau_name="$*"
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

while true; do
    read -p "Sortie :(E)cran ou (F)ichier : " set_out
    case "$set_out" in
        E|e|F|f) break;;
        *) echo "Option invalide." ; sleep 1 ;;
    esac
done
if [[ ${lsel[*]:-vide} == "vide" ]];then
  echo "Les paramètre conduisent à une seleciotn vide"
else
  #
  # recup des info de connexion serveur
  #
  liniget=()
  iniget "${PATHSECU}/connexion.ini"  "[CONNEXION]"
  #
  # Conversion du tableau retourne en tableau de clef/valeur 
  #
  for ((i = 0; i < ${#liniget[@]}; ++i)); do
  #  Extraire la section entre crochets
    output_wrk="${liniget[${i}]#*]}"
    lconn["${output_wrk%%=*}"]="${output_wrk#*=}"
  done  

  echo "Liste des paramètres d'applicaiton de la commande"
  for i in "${!lsel[@]}"; do
    db_name=""
    db_env=""
    db_host=""
    db_port=""

    # récuperation des info de connexion
    echo "récuperation des valeur [${lsel[$i]}]"
    # le port de la base
    liniget=()
    iniget "${PATHDATAS}/db.ini" "[${lsel[$i]}]" "db_port*"
    for wrk in "${liniget[@]}"; do
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      key=$(echo "$wrk" | grep -oP '^\[[^]]+\]\K[^=]+')
      db_port=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
    done 
    # le nom de la base
    liniget=()
    iniget "${PATHDATAS}/db.ini" "[${lsel[$i]}]" "db_name*"
    for wrk in "${liniget[@]}"; do
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      key=$(echo "$wrk" | grep -oP '^\[[^]]+\]\K[^=]+')
      db_name=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
    done
    liniget=()
    # l'environment de la base
    iniget "${PATHDATAS}/db.ini" "[${lsel[$i]}]" "db_env*"
    for wrk in "${liniget[@]}"; do
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      key=$(echo "$wrk" | grep -oP '^\[[^]]+\]\K[^=]+')
      db_env=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
    done
    liniget=()
    # le host de la base
    iniget "${PATHDATAS}/db.ini" "[${lsel[$i]}]" "db_host*"
    for wrk in "${liniget[@]}"; do
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      key=$(echo "$wrk" | grep -oP '^\[[^]]+\]\K[^=]+')
      db_host=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
    done
    pg_user="${lconn[${db_env}_pg_user]}"
    pg_pasw="${lconn[${db_env}_pg_pasw]}"
    vers_ins=""
    vers_def=""
    preload_lib=""
    mode="BT"
    #echo "chaine de connexion host = ${db_host}, port = ${db_port}, name = ${db_name}, user = ${pg_user}, pasw = ${pg_pasw}"
    # check install globale de l'extension
    command="SELECT default_version,installed_version FROM pg_available_extensions where installed_version is not null and name = 'pg_stat_statements'"
    output_command=()
    export PGPASSWORD=${pg_pasw}
    do_db_command "${db_host}" "${db_port}" "${db_name}" "${pg_user}" "${mode}" "${command}"
    unset PGPASSWORD
    for outline_wrk in "${output_command[@]}"; do
      # echo "${outline_wrk}"
      vers_def="$(echo "${outline_wrk}" | sed -e 's/ //g' | cut -d "|" -f 1)"
      vers_ins="$(echo "${outline_wrk}" | sed -e 's/ //g' | cut -d "|" -f 2)"
    done

    #check preload
    command="select setting from pg_settings where name='shared_preload_libraries'"
    output_command=()
    export PGPASSWORD=${pg_pasw}
    do_db_command "${db_host}" "${db_port}" "${db_name}" "${pg_user}" "${mode}" "${command}"
    unset PGPASSWORD
    for outline_wrk in "${output_command[@]}"; do
      preload_lib="$(echo "${outline_wrk}" | sed -e 's/ //g' )"
    done

    # dossier install
    command="SELECT nspname
FROM pg_namespace
WHERE oid = (SELECT extnamespace FROM pg_extension WHERE extname = 'pg_stat_statements')"
    output_command=()
    export PGPASSWORD=${pg_pasw}
    do_db_command "${db_host}" "${db_port}" "${db_name}" "${pg_user}" "${mode}" "${command}"
    unset PGPASSWORD
    for outline_wrk in "${output_command[@]}"; do
      schema_name="$(echo "${outline_wrk}" | sed -e 's/ //g' )"
    done

    # Vérification
    #version a jour ou superieur
    if  awk -v def="$vers_def" -v ins="$vers_ins" 'BEGIN { exit (def > ins) ? 0 : 1 }'; then 
      if [[ "${set_out}" == "E" || "${set_out}" == "e" ]];then
        echo "probleme version installée [${vers_ins}] en retard [${vers_def}] ou non installée"
      else
        ini_mess="probleme version installée [${vers_ins}] en retard [${vers_def}] ou non installée"
      fi
    else
      if [[ "[${vers_ins}]" == "[]" ]]; then
        if [[ "${set_out}" == "E" || "${set_out}" == "e" ]];then
          echo "WARNING : pg_stat_statemetn non installé"
        else
          ini_mess=${ini_mess}"\nWARNING : pg_stat_statemetn non installé"
        fi
      else
        if [[ "${set_out}" == "E" || "${set_out}" == "e" ]];then
          echo " pg_stat_statemetn installé version [${vers_ins}]"
        else
          ini_mess=${ini_mess}"\npg_stat_statemetn installé version [${vers_ins}]"
        fi
      fi
      #pg_stat_statement present dans la liste de preload
      if [[ "${preload_lib}" =~ "pg_stat_statement" ]]; then 
        if [[ "${set_out}" == "E" || "${set_out}" == "e" ]];then
          echo "pg_stat_statement chargé en memoire"
        else
          ini_mess=${ini_mess}"\npg_stat_statement chargé en memoire"
        fi
        # pg_stat_statement installe dans le bon répertoire
        if [[ "${schema_name}" == "public" ]]; then
          if [[ "${set_out}" == "E" || "${set_out}" == "e" ]];then
            echo "OK : pg_stat_statment installé sur public et disponible "
          else
            ini_mess=${ini_mess}"\nOK : pg_stat_statment installé sur public et disponible "
          fi
        else
          if [[ "${set_out}" == "E" || "${set_out}" == "e" ]];then
            echo "WARNING : pg_stat_statment installé sur [${schema_name}] et non sur public"
            echo "REMEDIATION : drop extension puis create extension puis reload database settings"
          else
            ini_mess=${ini_mess}"\nWARNING : pg_stat_statment installé sur [${schema_name}] et non sur public"
            ini_mess=${ini_mess}"\nREMEDIATION : drop extension puis create extension puis reload database settings"
          fi
        fi
      else
        if [[ "${set_out}" == "E" || "${set_out}" == "e" ]];then
          echo "CRITICAL : REMEDIATION => restart instance : pg_stat_statment installé non précharge"
        else
          ini_mess=${ini_mess}"\nCRITICAL : REMEDIATION => restart instance : pg_stat_statment installé non précharge"
        fi
      fi
    fi

    #generation fichier rapport
    if [[ "${set_out}" == "f" || "${set_out}" == "F" ]];then
      fic_out="${PATHOUTPUT}/check_stat_statment_${db_name}_${db_env}.log"
      if [ -f "${fic_out}" ];then
        rm "${fic_out}" 2>"${PATHDATAS}/error.log"
      fi
      echo -e "$ini_mess" | tee "${fic_out}" > /dev/null
      echo "résultat dans : ${fic_out}"
      ini_mess=""
    fi
    echo "---"
  done
fi
