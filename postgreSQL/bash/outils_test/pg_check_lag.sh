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
#données de connexions base maitre
m_db_name=""
m_db_env=""
m_db_host=""
m_db_port=""
m_pg_user=""
m_pg_pasw=""
#données de connexion base slave
s_db_name=""
s_db_env=""
s_db_host=""
s_db_port=""
s_pg_user=""
s_pg_pasw=""

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


 inifiltre="a"

# check environnement
#
do_verif_path "${PATHTOOLS}"
do_verif_path "${PATHDATAS}"
do_verif_path "${PATHSECU}"
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
  lconn=()
  for ((i = 0; i < ${#liniget[@]}; ++i)); do
  #  Extraire la section entre crochets
    output_wrk="${liniget[${i}]#*]}"
  #  echo "[${output_wrk%%=*}]=${output_wrk#*=}"
    lconn["${output_wrk%%=*}"]="${output_wrk#*=}"
  done  

  echo "Liste des paramètres d'applicaiton de la commande"
  for i in "${!lsel[@]}"; do
    m_db_name=""
    m_db_env=""
    m_db_host=""
    m_db_port=""
    m_ip_host=""
    mode="BT"
    # récuperation des info de connexion master
    echo "récuperation des valeur [${lsel[$i]}]"
    # phase 1 : on verifie que la base est bien en reprication et on part TOUJOURS de la base maitre
    liniget=()
    iniget "${BASECONF}" "[${lsel[$i]}]" "db_replication*"
    for wrk in "${liniget[@]}"; do
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      key=$(echo "$wrk" | grep -oP '^\[[^]]+\]\K[^=]+')
      if [[ "${key}" == "db_replication" ]]; then
        flag_replicat=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
        #echo "flag_replicat ${flag_replicat}"
      fi
    done 
    if [[ "${flag_replicat}" == "Y" ]]; then
      # le port de la base
      liniget=()
      iniget "${BASECONF}" "[${lsel[$i]}]" "db_port*"
      wrk="${liniget[0]}"
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      m_db_port=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
      # le nom de la base
      liniget=()
      iniget "${BASECONF}" "[${lsel[$i]}]" "db_name*"
      wrk="${liniget[0]}"
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      m_db_name=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
      liniget=()
      # l'environment de la base
      iniget "${BASECONF}" "[${lsel[$i]}]" "db_env*"
      wrk="${liniget[0]}"
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      m_db_env=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
      #echo "${m_db_env}"
      liniget=()
      # le host de la base
      iniget "${BASECONF}" "[${lsel[$i]}]" "db_host*"
      wrk="${liniget[0]}"
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      m_db_host=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
      # le host de la base
      iniget "${BASECONF}" "[${lsel[$i]}]" "db_ip_host*"
      wrk="${liniget[0]}"
      # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
      m_ip_host=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
      m_pg_user="${lconn[${m_db_env}_pg_user]}"
      m_pg_pasw="${lconn[${m_db_env}_pg_pasw]}"
      #echo "m_db_name=${m_db_name}"
      #echo "m_db_env=${m_db_env}"
      #echo "m_db_host=${m_db_host}"
      #echo "m_ip_host=${m_ip_host}"
      #echo "m_db_port=${m_db_port}"
      
      # phase 2 : recuperation des données de réaplicaitonde la master
      # on recupere la cofn active wal_buffers
      command="select round((setting::numeric / 128),0), round((setting::numeric / 128),0)*3 from pg_settings where name='wal_buffers';"
      output_command=()
      export PGPASSWORD=${m_pg_pasw}
      #  echo "${m_db_env}"
      #echo "${m_db_host} ${m_db_port} ${m_db_name} ${m_pg_user} ${mode} "[$PGPASSWORD]" ${command}"
      do_db_command "${m_db_host}" "${m_db_port}" "${m_db_name}" "${m_pg_user}" "${mode}" "${command}"
      unset PGPASSWORD
      outline_wrk=""
      wal_buffers="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 1)"
      wal_buffers_lag="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 2)"
      #echo "wal_buffers = ${wal_buffers}"
      # on recupere le parametrage de repmgr pour identifier le(s) node(s) standby
      command="SELECT regexp_replace(conninfo, '^.*host=([^ ]+).*$', '\1') AS node FROM repmgr.nodes where type != 'primary';"
      output_command1=()
      export PGPASSWORD=${m_pg_pasw}
      do_db_command "${m_db_host}" "${m_db_port}" "repmgr" "${m_pg_user}" "${mode}" "${command}"
      unset PGPASSWORD
      # ATTENTION il peut y avoir plusieur replication ex : CUICH donc on le recupere porut raitement iteratif
      output_command1=("${output_command[@]}")
      for outline_wrk in "${output_command1[@]}"; do
        # pour le noeud ou l'id reseau récupéer
        # on va recupere les entêtes de section, il y aura plusieur réponses mais il y des invariant dans la clef de section
        # partie1 cluster
        # partie3 instance
        # partie4 version de postgre (sauf execptio d'evolution de version en cours)
        # partie5 dbname
        # partie6 vide 
        # a) on récupere dans la conf de discover la cle env associe a ce node
        outline_wrk="$(echo "${outline_wrk}" | sed -e 's/ //g' )"
        #echo "node standby identifié [$outline_wrk]"
        if [[ $outline_wrk =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then # on recupere une adresse ip et aps un hostname
          liniget=()
          #echo "iniget $BASECONF --all *${outline_wrk}"
          iniget "$BASECONF" "--all" "*${outline_wrk}"
          # on ne traite que la premiere valeur retournée
          wrk="${liniget[0]}"
          #echo "wrk ${wrk}"
          # Extraire le groupe (ex: AAAAA)
          s_section=$(echo "$wrk" | grep -oP '\[\K[^\]]+')
          #echo "section trouvé ${s_section}"
          # cherche le host
          liniget=()
          #echo "iniget $BASECONF [${s_section}] db_host}*" # on cherche le host associe a l'ip
          iniget "$BASECONF" "[${s_section}]" "db_host*" # on cherche le host associe a l'ip
          wrk="${liniget[0]}"
          #echo "wrk ${wrk}"
          s_db_host=$(echo "${liniget[0]}" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
        else
          s_db_host=$outline_wrk
        fi
        #  echo "host de standby ${s_db_host}"
        # cherche l'env
        iniget=()
        iniget "$PATHDATAS/discover.ini" "--all" "*${s_db_host}"
        #echo "${liniget[0]}"
        s_db_env=$(echo "${liniget[0]}" | grep -oP '^\[[^]]+\]\K[^=]+' | cut -d';' -f1 )
        #echo "${s_db_env}"
        # le port de la base
        s_db_port="${m_db_port}"
        # le nom de la base
        s_db_name=${m_db_name}
        s_section="$(echo "${lsel[$i]}" | cut -d';' -f1 )"
        s_section="${s_section};${s_db_env}"
        s_section="${s_section};$(echo "${lsel[$i]}" | cut -d';' -f3 )"
        s_section="${s_section};$(echo "${lsel[$i]}" | cut -d';' -f4 )"
        s_section="${s_section};$(echo "${lsel[$i]}" | cut -d';' -f5 )"
        s_section="${s_section};$(echo "${lsel[$i]}" | cut -d';' -f6 )"
        #echo "s_section ${s_section}"
        s_pg_user="${lconn[${s_db_env}_pg_user]}"
        s_pg_pasw="${lconn[${s_db_env}_pg_pasw]}"
        iniget=()
        iniget "$BASECONF" "--all" "${s_section}"
        wrk="${liniget[0]:-vide}"
        corr_db_ver=true
        if [[ "$wrk" == "vide" ]];then
          corr_db_ver=false
        fi
        # on récupere le parametrage actif des destination de la replication (   pg_size_pretty(sent_lsn - write_lsn) AS lag_bytes,(sent_lsn - write_lsn) as rl_lag )
        command="SELECT  client_addr
,client_hostname
,state
,sent_lsn
,write_lsn
,flush_lsn
,replay_lsn
,(sent_lsn - write_lsn) as w_lag
,(sent_lsn - flush_lsn) as f_lag
,(sent_lsn - replay_lsn) as r_lag
,write_lag
,flush_lag
,replay_lag
,sync_state FROM pg_stat_replication;"
        output_command1=()
        export PGPASSWORD=${m_pg_pasw}
        #echo "${m_db_host} ${m_db_port} ${m_db_name} ${m_pg_user} [${m_pg_pasw}] ${mode} ${command}"
        do_db_command "${m_db_host}" "${m_db_port}" "${m_db_name}" "${m_pg_user}" "${mode}" "${command}"
        unset PGPASSWORD

        m_client_addr="$(echo "${output_command[0]}}" | sed -e 's/ //g' | cut -d "|" -f 1)"
        m_client_hostname="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 2)"
        m_state="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 3)"
        m_sent_lsn="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 4)"
        m_write_lsn="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 5)"
        m_flush_lsn="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 6)"
        m_replay_lsn="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 7)"
        m_w_lsn="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 8)"
        m_f_lsn="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 9)"
        m_r_lsn="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 10)"
        m_write_lag="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 11)"
        m_flush_lag="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 12)"
        m_replay_lag="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 13)"
        m_sync_state="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 14)"
        # phase 3 : recuperation des donne du slave
        command="SELECT  status,written_lsn,flushed_lsn,sender_host FROM pg_stat_wal_receiver;"
        output_command=()
        export PGPASSWORD=${s_pg_pasw}
        #echo "${s_db_host} ${s_db_port} ${s_db_name} ${s_pg_user} [${s_pg_pasw}] ${mode} ${command}"
        do_db_command "${s_db_host}" "${s_db_port}" "${s_db_name}" "${s_pg_user}"  "${mode}" "${command}"
        unset PGPASSWORD
        s_status="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 1)"
        s_writen_lsn="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 2)"
        s_flushed_lsn="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 3)"
        s_sender_host="$(echo "${output_command[0]}" | sed -e 's/ //g' | cut -d "|" -f 4)"

        #echo "Master"
        #echo "${m_client_addr} ${m_client_hostname} ${m_state} ${m_sent_lsn} ${m_write_lsn} ${m_flush_lsn} ${m_replay_lsn} ${m_write_lag} ${m_flush_lag} ${m_replay_lag} ${m_sync_state}"
        #echo "Slave"
        #echo "${s_status} ${s_writen_lsn} ${s_flushed_lsn} ${s_sender_host}"
        ini_mess="Replication de ${m_ip_host} ${m_db_host} vers ${m_client_addr} ${m_client_hostname} -- mode : ${m_sync_state} "
        ini_mess=${ini_mess}"\nEtat process :  ${m_state} "
        case ${m_state} in
          startup )  ini_mess=${ini_mess}" WARNING : Initialisation de la réplication"
                     ;;
          catchup)   ini_mess=${ini_mess}" WARNING : Initialisatin communication avec slave"
                     ;;
          streaming) ini_mess=${ini_mess}" => OK working"
                     ;;
          backup)    ini_mess=${ini_mess}" WARNING : Rattrapage en cous par le slave"
                     ;;
          stopping)  ini_mess=${ini_mess}" WARNING : Arret en cours de la replication"
                     ;;
          *)         ini_mess=${ini_mess}" CRITICAL : Etat inconnu"
                     ;;
        esac
        ini_mess=${ini_mess}"\nLimite max lag : ${wal_buffers_lag}"
        if [[ "${m_write_lsn}:-vide" == "vide" || "${m_fluch_lsn}:-vide" == "vide" || "${m_replay_lsn}:-vide" == "vide" ]]; then
          ini_mess=${ini_mess}"\nCommunication perdue avec ${s_db_host}" 
          ini_mess=${ini_mess}"\nStatus de la replication sur ${s_db_host} => ${s_status}"
        else
          if  awk -v def="$m_w_lsn" -v ins="$wal_buffers_lag" 'BEGIN { exit (def <= ins) ? 0 : 1 }' ; then
            ini_mess=${ini_mess}"\nlag écriture slave dans la norme"
          else
            ini_mess=${ini_mess}"\nlag écriture slave en hausse ${m_write_lag}"
          fi
          if  awk -v def="$m_f_lsn" -v ins="$wal_buffers_lag" 'BEGIN { exit (def <= ins) ? 0 : 1 }' ; then
            ini_mess=${ini_mess}"\nlag intégration slave dans la norem"
          else
            ini_mess=${ini_mess}"\nlag integration slave en hausse ${m_write_lag} => check lag database"
          fi
          if  awk -v def="$m_r_lsn" -v ins="$wal_buffers_lag" 'BEGIN { exit (def <= ins) ? 0 : 1 }' ; then
            ini_mess=${ini_mess}"\nretard reception slave dans la norem"
          else
            ini_mess=${ini_mess}"\nretard reception slave en hausse ${m_write_lag}"
          fi
        fi

      done
    else
        ini_mess="pas de replication trouvée"
    fi
    #generation fichier rapport
    if [[ "${set_out}" == "f" || "${set_out}" == "F" ]];then
      fic_out="${PATHOUTPUT}/pg_check_lag_${m_db_name}_${m_db_env}.log"
      if [ -f "${fic_out}" ];then
        rm "${fic_out}" 2>"${PATHDATAS}/error.log"
      fi
      echo -e "$ini_mess" | tee "${fic_out}" > /dev/null
    else
      echo -e "$ini_mess"
    fi
    ini_mess=""
    echo "---"
  done
fi
