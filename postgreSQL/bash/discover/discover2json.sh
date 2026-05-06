#!/usr/bin/bash
#------
# Script de convertion résultat discover de .ini a .json
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
# raccourcis répertoire utilisés mode partage
#
#PATHTOOLS="/usr/local/share/scripts"
#PATHDATAS="/usr/local/share/data"
#PATHCONF="/usr/local/share/data"
#PATHSECU="$HOME/.config/toolsconf"
#
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
#
# decomposition d ela clef section
#
kpart1=
kpart2=
kpart3=
kpart4=
kpart5=
kpart6=

#
# raccourcis répertoire utilisés
#
PATHTOOLS=$HOME/scripts
PATHDATAS="$HOME/scripts/data"

infile=
json_data=
FICOUT="${PATHDATAS}/output.json"   # fichier de sortie, valeur par defaut output.json
type_conv="b"        #type de conversion ini en json , default b => brute

#FICOUT="${PATHDATAS}"

source "${PATHTOOLS}/function_central.sh"

print_help(){
  echo " Programme de test de al fonction iniget (extraction d'un fichier de type .IINI)"
  echo " usage : iniget2json -i <file> -o <file> -t [b|s|a]"
  echo "   paramètres :"
  echo "     -i <file> : nom du fichier ini à exploiter, chemin relatif à PATHDATAS"
  echo "     -o <file> : nom du fichier json a généré, chemin relatif à PATHDATAS"
  echo "     -t : type de formatage du json, valeur possibel [b|s|a]"
  echo "          b = brute (un groupe par ensemble section et clef/valeur)"
  echo "          s = simple (reproduit la structure du fichier ini)"
  echo "          a = arborescent (clef/valeur regroupées dans une arborescence des sections"
  echo "             implique que la section soit decomposable en champs séparé par des \";\")"
}

# Fonction pour ajouter récursivement une clé composée param -t valeur a
add_to_json() {
    local json="$1"
    local key_parts=($(echo "$2" | tr ';' '\n'))
    local current_key="${key_parts[0]}"
    local remaining_parts=$(IFS=';'; echo "${key_parts[*]:1}")
    local value="$3"

    # Si on est au dernier niveau, on ajoute la valeur
    if [[ -z "$remaining_parts" ]]; then
        echo "$json" | jq --arg key "$current_key" --argjson value "$value" '. + {($key): $value}'
    else
        # Sinon, on descend dans l'arborescence
        if ! echo "$json" | jq --arg key "$current_key" 'has($key)' > /dev/null; then
            # Si la clé n'existe pas, on l'ajoute avec un objet vide
            json=$(echo "$json" | jq --arg key "$current_key" '. + {($key): {}}')
        fi
        # On récupère le sous-objet
        sub_json=$(echo "$json" | jq --arg key "$current_key" '.[$key]')
        # On appelle récursivement add_to_json sur le sous-objet
        sub_json=$(add_to_json "$sub_json" "$remaining_parts" "$value")
        # On met à jour le JSON global avec le sous-objet modifié
        echo "$json" | jq --arg key "$current_key" --argjson sub_json "$sub_json" '. + {($key): $sub_json}'
    fi
}

#
# check environnement
#
do_verif_path "${PATHTOOLS}"
do_verif_path "${PATHDATAS}"

while test -n "$1"; do
  case "$1" in
    -i )
      infile="${PATHDATAS}/$2"
      shift
      ;;
    -o )
      FICOUT="${PATHDATAS}/$2"
      shift
      ;;
    -t )
      type_conv=$2
      shift
      ;;
    -h )
      print_help
      exit $ST_OK
      ;;
    * )
      echo "Unknown argument : $1"
      exit $ST_UK
  esac
  shift
done

#
# si le fichier de sortie exite, on le vire comme un mal propre
#
rm -f "${FICOUT}"

echo "Fichier source      : ${infile}"
echo "Fichier destination : ${FICOUT}"

if [[ "${type_conv}" == "b" ]] ; then
  echo "Type conversion     : Brute"
elif [[ "${type_conv}" == "s" ]] ; then
  echo "Type conversion     : Simple"
elif [[ "${type_conv}" == "a" ]] ; then
  echo "Type conversion     : Arborescence"
else
  echo "type de conversion inconnu"
  exit $ST_OK
fi
echo "Extraction des données"

iniget "${infile}" "--all" ""

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


echo "# Génération"

# Initialisation du JSON (tableau vide)
if [[ "${type_conv}" == "b" ]]; then
  json_data=$(jq -n '[]')
else
  json_data=$(jq -n '{}')
fi
# Pour chaque section dans tableau_out
for section in "${!tableau_out[@]}"; do
  # on décompose la section en ses parties
  # ATTENTION :
  # modificaiton fu IFS => plantage de la boucle interne => sauvegarde/restore du IFS
  old_IFS=$IFS
  IFS=';' read -ra parts <<< "$section"
  IFS=$old_IFS
  # Assigner les parties (même si certaines sont vides)
  kpart1="${parts[0]}"
  kpart2="${parts[1]}"
  kpart3="${parts[2]}"
  kpart4="${parts[3]}"
  kpart5="${parts[4]}"
  kpart6="${parts[5]}"
  #echo "${tableau_out[$wrk]}"
  # on elimine le section dont le composant 6 := vide (ex OLD) 
  if [[ "${kpart6:-vide}" != "vide" ]]; then
    echo " Section : [${section}] sous surveillance non extraite"
  else
    echo "Traitement section: [${section}]"
    if [[ "${type_conv}" == "b"  ]]; then       # version brute brut
      # Initialisation de l'objet section
      section_obj=$(jq -n --arg section "$section" '{section: $section}')
      # Ajout des paires clé/valeur
      for pair in ${tableau_out[$section]}; do
        key=$(echo "$pair" | cut -d'=' -f1)
        value=$(echo "$pair" | cut -d'=' -f2-)
        # Utilisation de --arg pour les clés et valeurs
        section_obj=$(jq --arg k "$key" --arg v "$value" '. + {($k): $v}' <<< "$section_obj")
      done
      # Ajout de l'objet section au tableau JSON
      # On utilise --argjson uniquement pour l'objet final, pas pour les clés/valeurs
      json_data=$(jq --argjson new_obj "$section_obj" '. += [$new_obj]' <<< "$json_data")
    elif [[ "${type_conv}" == "s" ]]; then      # version simple
      # Initialisation du sous-objet pour cette section
      section_content=$(jq -n '{}')
      # Ajout des paires clé/valeur dans le sous-objet
      for pair in ${tableau_out[$section]}; do
        key=$(echo "$pair" | cut -d'=' -f1)
        value=$(echo "$pair" | cut -d'=' -f2-)
        section_content=$(jq --arg key "$key" --arg value "$value" '. + {($key): $value}' <<< "$section_content")
      done

      # Ajout du sous-objet à la section dans le JSON global
      json_data=$(jq --arg section "$section" --argjson content "$section_content" '. + {($section): $content}' <<< "$json_data")

    elif [[ "${type_conv}" == "a" ]]; then
      # version aorbo
      section_arbo="${kpart1};${kpart2};${kpart3};${kpart4};${kpart5}"
        # Construction de l'objet pour cette section
          section_content='{}'
          for pair in ${tableau_out[$section]}; do
            key=$(echo "$pair" | cut -d'=' -f1)
            value=$(echo "$pair" | cut -d'=' -f2-)
            section_content=$(echo "$section_content" | jq --arg key "$key" --arg value "$value" '. + {($key): $value}')
          done

        # Ajout récursif de la section dans le JSON global
        json_data=$(add_to_json "$json_data" "$section_arbo" "$section_content")
      #done
    else
      echo "type de convertion non prévue"
    fi
  fi
done

jq '.' <<< "$json_data" > "${FICOUT}"

echo "Fichier JSON généré : ${FICOUT}"

