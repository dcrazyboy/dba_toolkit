#!/usr/bin/bash
#------
# Script de recherche des bases
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
PATHCONF="$HOME/scripts/data"
PATHSECU="$HOME/.config/toolsconf"
#
# raccourcis répertoire utilisés mode partage
#
#PATHTOOLS="/usr/local/share/scripts"
#PATHDATAS="/usr/local/share/data"
#PATHCONF="/usr/local/share/data"
#PATHSECU="$HOME/.config/toolsconf"
#
# variables retournée par function_central pour memoire
#
#output_command=       # retour de sonnées exécuté  sur node externe par function_central
#declare -A liniget=() # array de retour iniget qui ne retourne que des listes indexée
#
# array liste associatives
#
declare -A ldb=()       # liste des bases de l'INI à traiter par cluster
declare -A lconn=()     # listes valeur info de connexion distante
declare -A lsec_ori=()  # listes section source
declare -A lsec_new=()     # listes section destination
declare -A cle_val_ori=()     # listes section destination
declare -A cle_val_new=()     # listes section destination
#
# identifi&ant
#
os_user=          # user systeme pour connexion ssh
os_pasw=          # password user systeme pour connexion ssh
pg_user=          # user postgres
#pg_pasw=          # password user postgres
#
# données postgres
#
env=
host=
ip_host=
cluster=
pg_port=
#pg_installer=
pg_cluster=
pg_version=
pg_repmgr=
pg_repmgr_type=
#pg_service=
#
# clef de boucle tableaux
#
kcluster=
# 
# comtpeurs jetables
#
i=0   # compteur bidon
#
# travail jetable
#
command=    # commande a passer sur node externe 
output_command= # retour de sonnées exécuté  sur node externe
output_net=   # traitement boucle retour de commande extraction info network
outline_net=  # traitement boucle retour de commande extraction info network
output_net2=  # traitement boucle retour de commande extraction info network repmgr
outline_net2=   # traitement boucle retour de commande extraction info network repmgr
output_wrk=
ddj=$(date +"%Y-%m-%d") # date du jour ca peut etre utile
#liniget    # pour mémoire initialise dans fonction centrale, variable globale de retour de iniget

BASECONF="${PATHDATAS}/db.ini"
HISTCONF="${PATHDATAS}/db.histo"

source "${PATHTOOLS}/function_central.sh"

#
# check environnement
#
do_verif_path "${PATHTOOLS}"
do_verif_path "${PATHDATAS}"
do_verif_path "${PATHCONF}"
do_verif_path "${PATHSECU}"
do_verif_file "${BASECONF}"
do_verif_file "${HISTCONF}"
#
# on supprime le work s'il existe
#
if [ -f "${BASECONF}_wrk" ];then
  rm "${BASECONF}_wrk" 2>"${PATHDATAS}/error.log"
  bypass_err $?
fi
echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [INFO] Lancement discovery " | tee -a "${HISTCONF}" > /dev/null
#fmt="%-4s : %s\n"
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

# recupération de la liste des serveurs
liniget=()
iniget "$PATHCONF/discover.ini" --all

#
# convertion en tableau imbrique de clef/valeur pour chaque cluster
#
#echo "retour iniget"
#echo "${liniget[@]}"
#echo ""

# Parcourir chaque élément du tableau
for kcluster in "${liniget[@]}"; do
    # Extraire le groupe (ex: AAAAA)
    cluster=$(echo "$kcluster" | grep -oP '\[\K[^\]]+')

    # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
    env=$(echo "$kcluster" | grep -oP '^\[[^]]+\]\K[^=]+')
    host=$(echo "$kcluster" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
    if [[ -z "${ldb[$cluster]}" ]]; then
        ldb["$cluster"]=""
    fi

    # Ajouter la paire clé/valeur au groupe
    ldb["$cluster"]+=" $env=$host"
done

echo "Extraction"

echo "# Affichage pour vérification"
for kcluster in "${!ldb[@]}"; do
  cluster=$kcluster
  echo "Section: [${kcluster}]"
  echo "----"

  # Parcourir chaque paire clé=valeur dans ${tableau_out[$wrk]}
  for pair in ${ldb[$kcluster]}; do
    # Extraire la clé et la valeur
    env=$(echo "$pair" | cut -d'=' -f1)
    host=$(echo "$pair" | cut -d'=' -f2-)
    echo "  $env = $host"
    #
    # récuperation des données de travail
    #  
    os_user="${lconn[${env}_user]}"
    os_pasw="${lconn[${env}_pasw]}"
    pg_user="${lconn[${env}_pg_user]}"
    ip_host=$(getent hosts "${host}" | sed -r 's/\s+/ /g' | cut -d ' ' -f 1)
    #echo "Extraction de la liste des bases pour le host ${host} du cluster ${cluster} "
    #echo "cluster : ${cluster} , env : ${env} , node : ${host} , os_user : ${os_user} , Valeur : ${os_pasw} , pg_user : ${pg_user} , Valeur : ${pg_pasw}" 
    command="ss -ltp4 | grep -e 'postgres\",pid' | grep -v color | sed -e 's/=/ /g' -e 's/:/ /g' -e 's/(/ /g' -e 's/\"/ /g' -e 's/,/ /g' |sed -r 's/\s+/ /g' | cut -d ' ' -f 5,9"
    #echo $command
    do_ssh_sudo_command "${os_user}" "${host}" "${command}" "$PATHDATAS/error.log" "${os_pasw}"
        #
    # Lire la sortie dans un tableau
    #
    #echo $output_command
    # ATTENTION :
    # modificaiton fu IFS => plantage de la boucle interne => sauvegarde/restore du IFS
    old_IFS=$IFS
    IFS=$'\n'
    unset output_net
    read -rd '' -a output_net <<< "$output_command"
    IFS=$old_IFS
    for outline_net in "${output_net[@]}"; do
      #echo $output_net
      pg_port="$(echo "${outline_net}" | cut -d ' ' -f 1)"
      # pg_installer="$(echo $outline_net | cut -d ' ' -f 2)"
      # le port n'est pas forcement numerique ex edb il faut le transcrire dans ce cas
      case $pg_port in
        ''|*[!0-9]*)
          command="grep -w ${pg_port} /etc/services | cut -d '/' -f 1 | sed -r 's/\s+/ /g' | cut -d ' ' -f 2"
          #echo $command
          do_ssh_sudo_command "${os_user}" "${host}" "${command}" "$PATHDATAS/error.log" "${os_pasw}"
          pg_port="${output_command}"
          ;;
        *)
          ;;
      esac
      ini_mess="db_env=${env}\ndb_host=${host}\ndb_cluster=${cluster}\ndb_port=${pg_port}\ndb_ip_host=${ip_host}\n"
      #echo "$outline_net $pg_port"
      #echo "Ligne : port $pg_port process $pg_installer"
      #
      # recuperation des infos complementaires version et nom de l'instance
      #
      if [ "${pg_port}" == "5432" ];then
        command=" psql -h ${host} -p $pg_port -d postgres -t -U ${pg_user} -c  'show cluster_name;' "
      else
        command=" psql -p $pg_port -d postgres -t -U ${pg_user} -c  'show cluster_name;' "
      fi
      #echo $command
      do_ssh_command "${os_user}" "${host}" "${command}" "$PATHDATAS/error.log" "${os_pasw}"
      pg_version="$(echo "$output_command" | cut -d '/' -f 1 |  sed -e 's/ //g' )"
      pg_cluster="$(echo "$output_command" | cut -d '/' -f 2 |  sed -e 's/ //g')"
      #echo "cluster : $pg_cluster version : $pg_version"
      ini_mess=${ini_mess}"db_version=${pg_version}\ndb_instance=${pg_cluster}\n"
      #
      # Recherche des bases
      #
      unset output_db
      unset db_list
      if [ "${pg_port}" == "5432" ];then
        command="psql -h ${host} -p $pg_port -d postgres -t -U ${pg_user} -c \"select datname from pg_database where datname not in ('postgres','template1','template0');\""
      else
        command="psql -p $pg_port -d postgres -t -U ${pg_user} -c \"select datname from pg_database where datname not in ('postgres','template1','template0');\""
      fi
      #echo $command
      do_ssh_command "${os_user}" "${host}" "${command}" "$PATHDATAS/error.log"
      # on sauvegarde le retour qui est une liste index, 
      # il peut arriver qu'il y ai plusieur bases dans une instance
      # cas classique replicaiton par repmgr
      # si repmgr, on l'elimine de la liste et on flag la présence de réplication
      #echo $output_command
      unset output_db
      pg_repmgr="N"
      # ATTENTION :
      # modificaiton fu IFS => plantage de la boucle interne => sauvegarde/restore du IFS
      old_IFS=$IFS
      IFS=$'\n'
      unset output_wrk
      read -rd '' -a output_wrk <<< "$output_command"
      IFS=$old_IFS
      for outline_wrk in "${output_wrk[@]}"; do
        #echo "element : \"${outline_wrk}\" \"$(echo ${outline_wrk} | sed -e 's/ //g')\""
        outline_wrk="$(echo "${outline_wrk}" | sed -e 's/ //g')"
        if [[ "${outline_wrk}" == "repmgr" ]]; then
          pg_repmgr="Y"
        else
          output_db+=("${outline_wrk}")
        fi
      done
      pg_repmgr_type=
      if [ "$pg_repmgr" == "Y" ];then
        if [ "${pg_port}" == "5432" ];then
          command="psql -h ${host} -p ${pg_port} -d repmgr -t -X -U ${pg_user} \
-c \"WITH key_value_pairs AS ( SELECT type,regexp_split_to_array(conninfo, '\\s+') tableau FROM repmgr.nodes) \
SELECT type,valeur \
FROM (SELECT type, split_part(couple, '=', 1) AS clef, split_part(couple, '=', 2) AS valeur \
FROM key_value_pairs, unnest(tableau) WITH ORDINALITY AS t(couple, i)) AS extract \
WHERE clef LIKE '%host%';\""
        else
          command="psql -p ${pg_port} -d repmgr -t -X -U ${pg_user} \
-c \"WITH key_value_pairs AS ( SELECT type,regexp_split_to_array(conninfo, '\\s+') tableau FROM repmgr.nodes) \
SELECT type,valeur \
FROM (SELECT type, split_part(couple, '=', 1) AS clef, split_part(couple, '=', 2) AS valeur \
FROM key_value_pairs, unnest(tableau) WITH ORDINALITY AS t(couple, i)) AS extract \
WHERE clef LIKE '%host%';\""
        fi
        do_ssh_command "${os_user}" "${host}" "${command}" "$PATHDATAS/error.log"
        #echo $output_command
        # ATTENTION :
        # modificaiton fu IFS => plantage de la boucle interne => sauvegarde/restore du IFS
        old_IFS=$IFS
        IFS=$'\n'
        unset output_net2
        read -rd '' -a output_net2 <<< "$output_command"
        IFS=$old_IFS
        for outline_net2 in "${output_net2[@]}"; do
          #echo "outline_net2 : $outline_net2"
          if [ "$(echo  "${outline_net2}" | grep "${ip_host}")" != "" ];then 
            pg_repmgr_type="$(echo "${outline_net2}" | sed -e 's/ //g' | cut -d "|" -f 1)"
          fi
          if [ "$(echo  "${outline_net2}" | grep "${host}")" != "" ];then 
            pg_repmgr_type="$(echo "${outline_net2}" | sed -e 's/ //g' | cut -d "|" -f 1)"
          fi
        done
      fi
      ini_mess=${ini_mess}"db_replication=${pg_repmgr}\ndb_replication_type=${pg_repmgr_type}"
      #
      #sur la base des database conserve on genere les données de l'ini
      #
      #s'il s'agit d'un instance sans base a l'interieur sauf celles système qui ne sont pas prises en compte ici
      if [[ ${#output_db[@]} -eq 0 ]]; then
        ini_mess="[${cluster};${env};${pg_cluster};${pg_version};;]\ndb_name=\n"$ini_mess
        if [ ! -e "${BASECONF}_wrk" ]; then
          echo -e "$ini_mess" | tee "${BASECONF}_wrk" > /dev/null
        else
          echo -e "$ini_mess" | tee -a "${BASECONF}_wrk" > /dev/null
        fi
      else
        # sauvegarde des données commune en ca de db multiple dans une instance
        sav_ini_mess=$ini_mess
        for db_list in "${!output_db[@]}"; do
          PG_DBNAME="${output_db[${db_list}]}"
          ini_mess="[${cluster};${env};${pg_cluster};${pg_version};${PG_DBNAME};]\ndb_name=${PG_DBNAME}\n"$sav_ini_mess
          if [ ! -e "${BASECONF}_wrk" ]; then
            echo -e "$ini_mess" | tee "${BASECONF}_wrk" > /dev/null
          else
            echo -e "$ini_mess" | tee -a "${BASECONF}_wr"k > /dev/null
          fi
        done
      fi
    done
  done
  echo "----"
done
#
# reconciliation, complement
#
echo "réconciliation"
#
# si premiere initalisation, on renome seulment le fichier travail
#
if [ ! -e "${BASECONF}" ]; then
  echo "création ""${BASECONF}_wrk"" => ""${BASECONF}"
  echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [INFO] Initialisation du fichier" | tee -a "${HISTCONF}" > /dev/null
  mv "${BASECONF}_wrk" "${BASECONF}"
  exit "$ST_OK"
fi

#
# recupération de la liste des section du fichier actuel
#
liniget=()
lsec_ori=()
lsec_new=()
iniget "$BASECONF" --all
# Parcourir chaque élément du tableau
echo "Récupération source $BASECONF"
for kcluster in "${liniget[@]}"; do
    # Extraire le groupe (ex: AAAAA)
    cluster=$(echo "$kcluster" | grep -oP '\[\K[^\]]+')

    # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
    cluster_cle=$(echo "$kcluster" | grep -oP '^\[[^]]+\]\K[^=]+')
    cluster_val=$(echo "$kcluster" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
    # echo "$kluster --- $cluster --- $cluster_cle --- $cluster_val" 
    if [[ -z "${lsec_ori[$cluster]}" ]]; then
        lsec_ori["$cluster"]=""
    fi

    # Ajouter la paire clé/valeur au groupe
    lsec_ori["$cluster"]+=" $cluster_cle=$cluster_val"
done

#
# recupération de la liste des section du fichier travail
#
liniget=()
lsec_new=()
iniget "${BASECONF}_wrk" --all
# Parcourir chaque élément du tableau
echo "Récupération du fichier de travail ${BASECONF}_wrk"
for kcluster in "${liniget[@]}"; do
    # Extraire le groupe (ex: AAAAA)
    cluster=$(echo "$kcluster" | grep -oP '\[\K[^\]]+')

    # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
    cluster_cle=$(echo "$kcluster" | grep -oP '^\[[^]]+\]\K[^=]+')
    cluster_val=$(echo "$kcluster" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
    # echo "$kluster --- $cluster --- $cluster_cle --- $cluster_val" 
    if [[ -z "${lsec_new[$cluster]}" ]]; then
        lsec_new["$cluster"]=""
    fi

    # Ajouter la paire clé/valeur au groupe
    lsec_new["$cluster"]+=" $cluster_cle=$cluster_val"
done

# Boucle pour comparer chaque sous-tableau
for kcluster in "${!lsec_ori[@]}"; do
  # on decompose l'entete de section
  # ATTENTION :
  # modificaiton fu IFS => plantage de la boucle interne => sauvegarde/restore du IFS
  old_IFS=$IFS
  IFS=$'\n'l
  IFS=';' read -ra parts <<< "$kcluster"
  IFS=$old_IFS
  # Assigner les parties (même si certaines sont vides)
  kpart1="${parts[0]}"
  kpart2="${parts[1]}"
  kpart3="${parts[2]}"
  kpart4="${parts[3]}"
  kpart5="${parts[4]}"
  kpart6="${parts[5]}"

  #echo "Part 1 : '${kpart1}'"
  #echo "Part 2 : '${kpart2}'"
  #echo "Part 3 : '${kpart3}'"
  #echo "Part 4 : '${kpart4}'"
  #echo "Part 6 : '${kpart5}' -- '${kpart5:-vide}'"
  #echo "Part 6 : '${kpart6}' -- '${kpart6:-vide}'"
  if [[ -z ${lsec_new[$kcluster]} ]]; then  # la section n'existe pas dans la nouvelle version
    # Créer des tableaux associatifs pour chaque sous-tableau
    kcluster_test="${kpart1};${kpart2};${kpart3};${kpart4};${kpart5};"
    cle_test="db_date_modif"
    cle_val_ori=()
    ini_mess=
    for pair in ${lsec_ori[$kcluster]}; do
      cluster_cle=$(echo "$pair" | cut -d'=' -f1)
      cluster_val=$(echo "$pair" | cut -d'=' -f2)
#      echo "pair : ${pair} -- cluster_cle : ${cluster_cle} --- cluster_val : ${cluster_val}"
      # on prépare la structure a ajouter
      #echo "${cluster_cle}=${cluster_val}"
      ini_mess=${ini_mess}"\n${cluster_cle}=${cluster_val}"
      cle_val_ori["$cluster_cle"]="${cluster_val}"
      #echo " cle_val_ori de $kcluster : cle -- $cluster_cle --- val : $cluster_val"
    done
    #echo "$ini_mess"
    # il s'aagit d'une section sous surveillance
    if [[ "${kpart6:-vide}" != "vide" ]]; then
      # cas de la réctivation de la base
      #echo "${lsec_new[$kcluster_test]} : ${kcluster_test}"
      if [[ -z "${lsec_new[$kcluster_test]}" ]]; then
        # Doit-on purger ?
        #echo " : ${cle_val_ori[$cle_test]}"
        #echo "$(( $(( $(date --date="$(date +"%Y-%m-%d")" +%s) -$(date --date="${cle_val_ori[$cle_test]}" +%s) )) / 84700 ))"
        if [[ $(( $(( $(date --date="$(date +"%Y-%m-%d")" +%s) -$(date --date="${cle_val_ori[$cle_test]}" +%s) )) / 84700 )) -gt 3 ]]; then
          echo "${ddj} : [WARNING] Arrêt de la surveillance de '${kcluster}', purge de al liste " 
          echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Arrêt de la surveillance de '$kcluster', purge de al liste " | tee -a "${HISTCONF}" > /dev/null
        else
          # pursuite de la surveillance jusqu'a la purge
          ini_mess="[${kpart1};${kpart2};${kpart3};${kpart4};${kpart5};OLD]${ini_mess}|n"
          echo -e "$ini_mess" | tee -a "${BASECONF}_wrk" > /dev/null
          echo "${ddj} : [WARNING] Poursuite de la surveillance de '$kcluster', instance arrétée ou en cour s de décomissionnement " 
          echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Poursuite de la surveillance de '$kcluster', instance arrétée ou en cour s de décomissionnement " | tee -a "${HISTCONF}" > /dev/null
        fi
      else
        #la base est revenue, oin récupere les inforamtion de wrk avec la clef test
        cle_val_new=()
        for pair in ${lsec_new[$kcluster_test]}; do
          cluster_cle=$(echo "$pair" | cut -d'=' -f1)
          cluster_val=$(echo "$pair" | cut -d'=' -f2)
          # au ca ou la valeur de la clef peur etre nulle
          cle_val_new["$cluster_cle"]="${cluster_val:-vide}"
          #echo " cle_val_new de $kcluster : cle -- $cluster_cle --- val : $cluster_val"
        done

        # Vérifier que toutes les clés de origine existent dans fichier de travail et que les valeurs sont identiques
        search=0
        found=0
        diff_par=0
        for pair in "${!cle_val_ori[@]}"; do
          search=$(( search+=1 ))
          # echo "cluster : $kcluster --- cle : $pair --- val ori : ${cle_val_ori[$pair]} --- val new : ${cle_val_new[$pair]}"
          if [ -z "${cle_val_new[$pair]:-vide}" ]; then
            diff_par=$(( diff_par+=1 ))
            echo "${ddj} : [WARNING] Section '$kcluster', clef '$pair' manquante pour $kcluster de ${BASECONF}_wrk" 
            echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Secteur '$kcluster', clef '$pair' manquante pour $kcluster de ${BASECONF}_wrk" | tee -a "${HISTCONF}" > /dev/null
          elif [ "${cle_val_ori[$pair]:-vide}" != "${cle_val_new[$pair]:-vide}" ]; then
            found=$(( found+=1 ))
            diff_par=$(( diff_par+=1 ))
            echo "${ddj} : [WARNING] Section '$kcluster', ecart valeur de la clé '$pair' : '${cle_val_ori[$pair]}' => '${cle_val_new[$pair]}'" 
            echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Section '$kcluster', ecart valeur de la clé '$pair' : '${cle_val_ori[$pair]}' => '${cle_val_new[$pair]}'" | tee -a "${HISTCONF}" > /dev/null
          else
            found=$(( found+=1 ))
          fi
        done

        if [[ search -eq found && diff_par -eq 0 ]]; then
          echo "${ddj} : [INFO] Section '$kcluster' => instance redémarrée sans modification d'informations " 
          echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [INFO] Section '$kcluster' => redémarée sans modification d'information " | tee -a "${HISTCONF}" > /dev/null
        else
          echo "${ddj} : [WARNING] Section '$kcluster' nb clef lues : $search -- nb clef trouvée : $found -- nb differences : $diff_par " 
          echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Section '$kcluster' nb clef lues : $search -- nb clef trouvée : $found -- nb differences : $diff_par " | tee -a "${HISTCONF}" > /dev/null
          echo "${ddj} : [WARNING] Redemarrage de la l'instance '$kcluster' avec modification d'information" 
          echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Redemarrage de la l'instance '$kcluster' avec modification d'information " | tee -a "${HISTCONF}" > /dev/null
        fi
      fi
    else
      # base arrêté ou en cours de décomissionement
      # on génère un enregistrement OLD
      ini_mess="[${kpart1};${kpart2};${kpart3};${kpart4};${kpart5};OLD]${ini_mess}\ndb_date_modif=${ddj}"
      echo -e "$ini_mess" | tee -a "${BASECONF}_wrk" > /dev/null
      echo "${ddj} : [WARNING] Mise en surveillance de '$kcluster', base absente ou décommissionnée " 
      echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Mise en surveillance de '$kcluster' , base absente ou décommissionnée " | tee -a "${HISTCONF}" > /dev/null
    fi
  else
    # Créer des tableaux associatifs pour chaque sous-tableau
    cle_val_ori=()
    ini_mess=
    for pair in ${lsec_ori[$kcluster]}; do
      cluster_cle=$(echo "$pair" | cut -d'=' -f1)
      cluster_val=$(echo "$pair" | cut -d'=' -f2)
      # on prépare la structure a ajouter
      ini_mess=${ini_mess}"\n${cluster_cle}=${cluster_val}"
      # au ca ou la valeur de la clef peur etre nulle
      cle_val_ori["$cluster_cle"]="$cluster_val"
      #echo " cle_val_ori de $kcluster : cle -- $cluster_cle --- val : $cluster_val"
    done

    cle_val_new=()
    for pair in ${lsec_new[$kcluster]}; do
      cluster_cle=$(echo "$pair" | cut -d'=' -f1)
      cluster_val=$(echo "$pair" | cut -d'=' -f2)
      # au ca ou la valeur de la clef peur etre nulle
      cle_val_new["$cluster_cle"]="${cluster_val:-vide}"
      #echo " cle_val_new de $kcluster : cle -- $cluster_cle --- val : $cluster_val"
    done

    # Vérifier que toutes les clés de origine existent dans fichier de travail et que les valeurs sont identiques
    search=0
    found=0
    diff_par=0
    for pair in "${!cle_val_ori[@]}"; do
      search=$(( search+=1 ))
      # echo "cluster : $kcluster --- cle : $pair --- val ori : ${cle_val_ori[$pair]} --- val new : ${cle_val_new[$pair]}"
      if [ -z "${cle_val_new[$pair]:-vide}" ]; then
        diff_par=$(( diff_par+=1 ))
        echo "${ddj} : [WARNING] Section '$kcluster', clef '$pair' manquante pour $kcluster de ${BASECONF}_wrk" 
        echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Secteur '$kcluster', clef '$pair' manquante pour $kcluster de ${BASECONF}_wrk" | tee -a "${HISTCONF}" > /dev/null
      elif [ "${cle_val_ori[$pair]:-vide}" != "${cle_val_new[$pair]:-vide}" ]; then
        found=$(( found+=1 ))
        diff_par=$(( diff_par+=1 ))
        echo "${ddj} : [WARNING] Section '$kcluster', ecart valeur de la clé '$pair' : '${cle_val_ori[$pair]}' => '${cle_val_new[$pair]}'" 
        echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Section '$kcluster', ecart valeur de la clé '$pair' : '${cle_val_ori[$pair]}' => '${cle_val_new[$pair]}'" | tee -a "${HISTCONF}" > /dev/null
      else
        found=$(( found+=1 ))
      fi
    done

    if [[ search -eq found && diff_par -eq 0 ]]; then
      echo "${ddj} : [INFO] Section '$kcluster' => OK " 
      echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [INFO] Section '$kcluster' => OK " | tee -a "${HISTCONF}" > /dev/null
    else
      echo "${ddj} : [WARNING] Section '$kcluster' nb clef lues : $search -- nb clef trouvée : $found -- nb differences : $diff_par " 
      echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [WARNING] Section '$kcluster' nb clef lues : $search -- nb clef trouvée : $found -- nb differences : $diff_par " | tee -a "${HISTCONF}" > /dev/null
      echo "${ddj} : [WARNING] Evolution des informations de l'instance '$kcluster' " 
      echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") : [INFO] Evolution des information de l'instance '$kcluster' " | tee -a "${HISTCONF}" > /dev/null
    fi
  fi
done
mv -f "${BASECONF}_wrk" "${BASECONF}"