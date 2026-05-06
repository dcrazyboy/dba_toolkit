#!/bin/bash
#------
# Script de lecture / recherche d'un fichier .ini quelquonque
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
#PATHCONF="$HOME/scripts/data"
#PATHSECU="$HOME/.config/toolsconf"
#
# raccourcis répertoire utilisés mode partagé
#
#PATHTOOLS="/usr/local/share/scripts"
#PATHDATAS="/usr/local/share/data"
#PATHCONF="/usr/local/share/data"
#PATHSECU="$HOME/.config/toolsconf"

# We run the /etc/profile file
# . /etc/profile
#----------
# declaration variables globales
#---------
#declare -A liniget=() #ceci est pour memoire, cette variable est déclare gobalement dans function_central
#
# raccourcis répertoire utilisés
#
#set -e
#
#variables
#
wrk=                 # variable travail
declare -A tableau_out=()       # liste des bases de l'INI à traiter par wrk
tableau_in=          # tableau (clef/valeur) des valeur interne associées au tableau_out (section)
key=                 # clef du tableau_in
value=               # valeur associée a la clef
pair=                # couple clef/valeur dans tableau_in
infile=
insearch=
infilter=


source "${PATHTOOLS}/function_central.sh"

print_help(){
  echo " Programme de test de al fonction iniget (extraction d'un fichier de type .IINI)"
  echo " usage : iniget <file> [--list|<section>|--all] [filtre]]"
  echo "   paramètres :"
  echo "     <file> : nom du fichier ini à exploiter comprenant le chemin"
  echo "     [--list|<section>|--all] : type de reecherche"
  echo "          --list : retrouene les ent^te de section"
  echo "          --all  : retrouen la totalite des ligne du fichier ini format [<section>]<clef><valeur>"
  echo "          <section> : nom de la section dans laquelle faire la recherche"
  echo "     [filter] (facultatif) : string de valeur a rechecher dans le type de recherche format [*]<caracteres>[*]..."
  echo "         exemple : *abc*fg* : file trusr al présence des chane de caractère abc puis fg"
  echo "                   abc*fg*  : filtre sur les valeur commencant apr abc et contenant fg"
  echo "                   *abc*fg  : filte sur les valeur contenant abc et finissant apr fg"
  echo "                    abc*fg  : filtre sur les valeur commencant par abc et finissant par fg"
  echo "         pas de limite dans la limite le nombre de filtresdes filres"
}

infile="$PATHDATAS/$1"
#--------
# check param
#--------
if [[ $# -lt 2 || ! -f $infile ]]; then
  print_help
  return $ST_WR
fi
insearch=$2
infilter=$3

echo "source fichier : ${infile}"
echo "type recherche : ${insearch}"
echo "        filtre : ${infilter}"
iniget "${infile}" "${insearch}" "${infilter}"

echo "récuperation des valeur"
# Parcourir chaque élément du tableau
for wrk in "${liniget[@]}"; do
    # Extraire le groupe (ex: AAAAA)
    tableau_in=$(echo "$wrk" | grep -oP '\[\K[^\]]+')

    # Extraire la clé et la valeur (ex: prB=ad99srvzbdbb001.cdweb.biz)
    key=$(echo "$wrk" | grep -oP '^\[[^]]+\]\K[^=]+')
    value=$(echo "$wrk" | grep -oP '=(.+\Z)' | cut -d'=' -f2- )
    if [[ -z "${tableau_out[$tableau_in]}" ]]; then
        tableau_out["$tableau_in"]=""
    fi

    # Ajouter la paire clé/valeur au groupe
    tableau_out["$tableau_in"]+=" $key=$value"
done


echo "# Affichage pour vérification"
for wrk in "${!tableau_out[@]}"; do
    echo "Section: [${wrk}]"
#    echo "${tableau_out[$wrk]}"
    echo "----"
  if [[ "${insearch}" != "--list" ]]; then  
    # Parcourir chaque paire clé=valeur dans ${tableau_out[$wrk]}
    for pair in ${tableau_out[$wrk]}; do
        # Extraire la clé et la valeur
        key=$(echo "$pair" | cut -d'=' -f1)
        value=$(echo "$pair" | cut -d'=' -f2-)
        echo "  $key = $value"
    done
    echo "----"
  fi
done
