#!/bin/bash

# We run the /etc/profile file
# . /etc/profile
#----------
# declaration variables globales
#---------

# fixes
PROGNAME="basename $0"
AUTHOR="J-C Nicolle"
VERSION="Version 2.0.0"

# travail
declare -A liniget=() # array de retour iniget qui ne retourne que des listes indexée
output_command=       # variable global de retour de valeur d'une commande
#selection=
#sub_selection=
validate=
#stat_psql=
#ctrlM=^M
# Variable d'échange poru el convert pattern
debut=
fin=
milieu=
err_log=

#exit values
ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=4

#
#déétermine le mode d'appel pour al gestion des message d'erreur après
#
is_interactive() {
    [ -t 0 ] || [ -n "$PS1" ]
}

#my_trap(){
#  echo "ended with error " >&2
#}
bypass_err() {
  if [ "$1" != "0" ]; then
    echo "Une erreur est survenue demandant votre attention"
    cat "${2}"
    echo ""
    echo -n "Voulez-vous la forcer ? (Y/N)"
    read -r validate
    if [ "${validate}" == "Y" ] || [ "${validate}" == "y" ]; then
      return $ST_OK
    else
      echo "Consultez le ficier ${err_log}"
      exit $ST_CR
    fi
  fi
}

do_verif_path() {
  if [ ! -d "${1}" ]; then
    echo "CRITICAL - the directory ${1} doesn't exist" 
    exit $ST_CR
  fi
  return $ST_OK
}

do_verif_file() {
  if [ ! -f "${1}" ]; then
    echo "WARNING - the file ${1} doesn't exist" 
    if [[ "${2:-vide}" == "vide " ]];then
      bypass_err $? "WARNING - the file ${1} doesn't exist" 
    else
      echo "WARNING - the file ${1} doesn't exist" 
      return $ST_UK
    fi
  fi
  return $ST_OK
}

do_db_command(){
  local host=$1
  local port=$2
  local db_name=$3
  local user=$4
  local mode_exec=$5
  local pg_command=$6

  case ${mode_exec} in
    "B") 
      # mode brut batch
      output_command="$( psql -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -c "${pg_command}")"
      ;;
    "BT") 
      # mode sans entete batch 
      output_command="$( psql -t -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -c "${pg_command}")"
      ;;
    "BX") 
      # mode basculé batch 
      output_command="$( psql -x -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -c "${pg_command}")"
      ;;
    "BTX") 
      # mode bascule sans entete batch 
      output_command="$( psql -x -t -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -c "${pg_command}")"
      ;;
    "I") 
      # mode brut interactif
      psql -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -c "${pg_command}"
      ;;
    "IT") 
      # mode sans entete interactif 
      psql -t -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -c "${pg_command}"
      ;;
    "IX") 
      # mode bascule
      psql -x -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -c "${pg_command}"
      ;;
    "ITX") 
      # mode bascule sans entete interactif
      psql -x -t -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -c "${pg_command}"
      ;;
    *) 
      # keskidi ?
      echo "mode appel" 
      return $ST_WR;;
  esac
  bypass_err $?
}

do_db_script(){
  local host=$1
  local port=$2
  local db_name=$3
  local user=$4
  local pg_script=$5
  local out=$6
  if [[ $# -eq 5 ]];then
    # le retour de al commande s'affiche a l'ecran 
    psql -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -f "${pg_script}"
    bypass_err $?
  elif [[ $# -eq 6 ]];then
    psql -h "${host}" -p "${port}" -d "${db_name}" -U "${user}" -o "${out}" -f "${pg_script}"
    bypass_err $?
  fi
}


do_ssh_command(){
#  echo ""
#  echo "os_user $1"
#  echo "host $2"
#  echo "commande $3"
#  echo "err_log $4"
#  echo "os_pass $5"
  output_command=""
#  echo "4 param ouput_command=\$(ssh \"$1@$2\" \"$3\" 2> $4)"
  output_command=$(ssh "$1@$2" "$3" 2> "$4")  
  bypass_err $? $4
}

do_ssh_sudo_command(){
#  echo ""
#  echo "os_user $1"
#  echo "host $2"
#  echo "commande $3"
#  echo "err_log $4"
#  echo "os_pass $5"
  output_command=""
  err_log=$4
  if [[ $# -eq 4 ]];then 
#    echo "4 param ouput_command=\$(ssh \"$1@$2\" "sudo -S $3" 2> $4)"
    output_command=$(ssh "$1@$2" "sudo -S $3" 2> "${err_log}")
  elif [[ $# -eq 5 ]];then
#    echo "5 ouput_command=\$(ssh \"$1\@$2\"  \"echo \'$5\' | sudo -S $3\" 2> $4)"
    output_command=$(ssh "$1@$2" "echo '$5' | sudo -S $3" 2> "${err_log}")
  else
    echo "ssh sudo wrong number of parmeter $#"
    return $ST_WR
  fi
  bypass_err $? "${err_log}"
}
iniget() {
  #--------
  # variables externes
  #--------
  local inifile    # fichier ini = $1
  local insection  # section recherchée = $2
  local inkey      # clef recherchée = $3
  #--------
  #variables internes
  #--------
  local lines      # variable travaille concatenation inifile forme  [section-name]key=value
  #local line       #variable travail extraction resulte liste clef=valeurs
  local lsection   # liste section
  #local keyval     # resultat extraction valeur d'une clef
  #local val        # resultat extraction valeur d'une valeur
  local i          # compteur
  #--------
  # check param
  #--------
  if [[ $# -lt 2 || ! -f $1 ]]; then
    echo "usage: iniget <file> [--list|<section>|--all [pattern]]"
    return 1
  fi
  # initialisaiton
  inifile=$1
  insection=$2
  inkey=$3

  if [[ ! -z "$inkey" ]]; then
#   construction du patern général et de ses éléments
    convert_pattern "$inkey"
  fi

  #-------
  # extraction de la liste des clef traitement --list
  # -------
  if [ "$insection" == "--list" ]; then
    i=0
    if [[ -z "$inkey" ]]; then
#        echo "inkey = $inkey ------- no pattern"
        old_IFS=$IFS
        while IFS="[] " read -r lsection; do
            if [[ -n "$lsection" ]]; then
                liniget[${i}]="$lsection"
                i=$((i+1))
            fi
        done < <(grep "\[.*\]" "$inifile")
        IFS=$old_IFS
    else
      convert_pattern "$inkey"
#       correction patern final s'il contient [ ou ]
        pattern=$(echo "${pattern//[/\\[}")
        pattern=$(echo "${pattern//]/\\]}")
#        echo "$pattern"
#        echo "convert pattern : $pattern"
#        echo "inkey : $inkey ----- Pattern utilisé : $pattern"
        old_IFS=$IFS
        while IFS="[] " read -r lsection; do
            if [[ -n "$lsection" ]]; then
                liniget[${i}]="$lsection"
                i=$((i+1))
            fi
        done < <(grep "\[.*\]" "$inifile" | grep -E "$pattern")
        IFS=$old_IFS
    fi
    return $ST_OK
  fi
  #-----------
  # recherche sur clef
  #-----------
  section=$insection
  key=$inkey
#  echo "file : $infile"
#  echo "section : $section"
#  echo "patern : $key"

  if [[ "${section}" == "--all" ]]; then
    if [[ -z "$key" ]]; then
      pattern=".*"
#      echo "patern all no filtre : $pattern"
    else
      convert_pattern "$key"
#   correction pattern final s'il contient ^ a cause de la concatenation finale
      pattern=$(echo "${pattern//^/.*}")
#     correction section final s'il contient [ ou ]
      pattern=$(echo "${pattern//[/\\[}")
      pattern=$(echo "${pattern//]/\\]}")
#      echo "patern all filtre : $pattern"
    fi
  else
    convert_pattern "$section"
#   correction pattern final s'il contient $ a cause de la concatenation finale
    pattern=$(echo "${pattern//$/}")
#     correction section final s'il contient [ ou ]
    pattern=$(echo "${pattern//[/\\[}")
    pattern=$(echo "${pattern//]/\\]}")
    section=$pattern
    if [[ -z "$key" ]]; then
      pattern="${section}.*"
#      echo "patern section no filtre : $pattern"
    else
      convert_pattern "$key"
#   correction pattern final s'il contient ^ a cause de la concatenation finale
      pattern=$(echo "${pattern//^/}")
#     correction section final s'il contient [ ou ]
      pattern=$(echo "${pattern//[/\\[}")
      pattern=$(echo "${pattern//]/\\]}")
      pattern="${section}${pattern}"
#      echo "patern section filtre : $pattern"
    fi
  fi
#  echo ${pattern}

#  echo "inkey : $inkey ----- Pattern utilisé : $pattern"
  # https://stackoverflow.com/questions/49399984/parsing-ini-file-in-bash
  # This awk line turns ini sections => [section-name]key=value
  lines=$(awk '/\[/{prefix=$0; next} $1{print prefix $0}' ${inifile})
  i=0
  old_IFS=$IFS
  while IFS="[] " read -r lsection; do
#   Ignorer les lignes qui commencent par #
    if [[ ! "$lsection" =~ ^\# ]]; then
      liniget[${i}]="$lsection"
      i=$((i+1))
    fi
  done < <(grep -E "$pattern" <<< "$lines" )
  IFS=$old_IFS
}

# Fonction pour convertir le motif utilisateur en regex
convert_pattern() {
  local input="$1"
  input=$(echo "${input//|/\\|}")
#  echo "enrte :$1: :$input:"
  # Si le motif commence par *, on ne met pas ^ au début
  if [[ "$input" == \** ]]; then
    input="${input#\*}"  # Supprime le premier *
    debut=".*"
  else
    debut="^"
  fi
#    echo $debut
  # Si le motif se termine par *, on ne met pas $ à la fin
  if [[ "$input" == *\* ]]; then
    input="${input%\*}"  # Supprime le dernier *
    fin=".*"
  else
    fin="$"
  fi
  # Remplace les * restants par .*
#    echo $input
  milieu=$(echo "$input" | sed 's/\*/.*/g')
#  echo $milieu
#    echo "fin convert_pattern"
  pattern="${debut}${milieu}${fin}"
}