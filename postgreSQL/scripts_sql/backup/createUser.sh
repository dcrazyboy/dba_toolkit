#!/bin/bash
#
# createUser.sh: Usage: createUser.sh -u <utilisateur> -d <nom de la base> -r <nom du role> [-n] (utulisateur LDAP)

usage() { echo -e "\nUsage: $(basename $0) -u <user> -d <database name> -r <role name> [-n]\n " && grep " .)\ #" $0; exit 0; }
[ $# -lt 3 ] && usage

# Recuperation des options
ldap_user=0
while getopts u:d:r:n arg
do
   case $arg in
     d) DBNAME=${OPTARG} ;;
     u) DBUSER=${OPTARG} ;;
     r) DBROLE=${OPTARG} ;;
     n) ldap_user=1 ;;
     h | *)
       usage
       exit 0
   esac
done

if [ -z ${DBNAME} ]; then usage && exit; fi
if [ -z ${DBUSER} ]; then usage && exit; fi
if [ -z ${DBROLE} ]; then usage && exit; fi

if [ -z ${PGPORT} ]; then echo -e "\nIl manque le port ! Execute pgenv pour cela ;-)\n " && exit; fi

#echo  ${DBNAME} " " ${DBUSER} " " ${DBROLE} " " $ldap_user

# Verifications d'existences
if [[ $(psql -p ${PGPORT} -XAt -c "SELECT count(*) FROM pg_database WHERE datname='${DBNAME}';") == 0 ]]; then echo -e "\nBase ${DBNAME} inexistante.\n" && exit; fi
if [[ $(psql -p ${PGPORT} -XAt -c "SELECT count(*) FROM pg_roles WHERE rolname='${DBROLE}';") == 0 ]]; then echo -e "\nRole ${DBROLE} inexistant.\n" && exit; fi
if [[ $(psql -p ${PGPORT} -XAt -c "SELECT count(*) FROM pg_user WHERE usename='${DBUSER}';") == 1 ]]; then echo -e "\nUser ${DBUSER} dèjà existant.\n" && exit; fi

# Creation de l'utilsateur
createuser -p ${PGPORT} -l -P -e ${DBUSER}

if [ "${DBROLE}" = "pg_write_all_data" ]; then
   ADDON=", pg_read_all_data "
fi

GRANT_CMD="GRANT ${DBROLE}${ADDON} to \"${DBUSER}\";"

psql -Eqp ${PGPORT} <<EOS

  GRANT CONNECT ON DATABASE ${DBNAME} TO "${DBUSER}";
  $GRANT_CMD

EOS

# Ajout de l'utilisateur dans PgBouncer
if [ "$ldap_user" != 1 ]
then
  echo $(psql -XAt -c "SELECT '\"${DBUSER}\" \"'||rolpassword||'\"'  FROM pg_authid where rolname='${DBUSER}';" ) >> /etc/pgbouncer/userlist.txt
  echo ${DBNAME} = host = localhost port=${PGPORT} pool_mode=session >> /etc/pgbouncer/pgbouncer.ini
  sudo service pgbouncer reload
fi

exit 0
