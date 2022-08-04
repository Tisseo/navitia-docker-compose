#!/bin/bash

SECRET_LIST="NAVITIA_DB_PWD \
NAVITIA_DB_CITIES_PWD"

# Try to read secret files 
for VARNAME in $SECRET_LIST; do
  if [ -z "$(eval echo "\$${VARNAME}_FILE")" ]; then
    if [ -z "$(eval echo "\$${VARNAME}")"]; then 
      echo "ERROR: Missing environment variable $VARNAME" >&2
      exit 1
    fi
  else
    if ! [ -f "$(eval echo "\$${VARNAME}_FILE")" ]; then
      echo "Unable to locate file \$${VARNAME}_FILE" >&2
      exit 2
    fi
    export "${VARNAME}"="$(cat "$(eval echo \$${VARNAME}_FILE)")"
  fi
done

tyr_config() {
  instance_name=$1
  INSTANCE=$instance_name \
  NAVITIA_DB_HOST=$NAVITIA_DB_HOST \
  NAVITIA_DB_PORT=$NAVITIA_DB_PORT \
  NAVITIA_DB_USER=$NAVITIA_DB_USER \
  NAVITIA_DB_PWD=$NAVITIA_DB_PWD \
  envsubst < templates/tyr_instance.ini > /etc/tyr.d/$instance_name.ini

  mkdir -p /srv/ed/$instance_name
  mkdir -p /srv/ed/output
  mkdir -p /srv/ed/input/$instance_name
}

db_config() {
  instance_name=$1

  # wait for db ready
  while ! pg_isready --host=${NAVITIA_DB_HOST} -p ${NAVITIA_DB_PORT}; do
    echo "waiting for postgres ${NAVITIA_DB_HOST} to be ready"
    sleep 1;
  done

  # database creation
  PGPASSWORD="${NAVITIA_DB_PWD}" createdb --host ${NAVITIA_DB_HOST} --port ${NAVITIA_DB_PORT} -U ${NAVITIA_DB_USER} $instance_name
  PGPASSWORD="${NAVITIA_DB_PWD}" psql -c 'CREATE EXTENSION postgis;' --host ${NAVITIA_DB_HOST} --port ${NAVITIA_DB_PORT} $instance_name ${NAVITIA_DB_USER}

  # database schema migration
  alembic_file=/srv/ed/$instance_name/ed_migration.ini
  SQL_ALCHEMY_URL="postgresql://${NAVITIA_DB_USER}:${NAVITIA_DB_PWD}@${NAVITIA_DB_HOST}:${NAVITIA_DB_PORT}/$instance_name" \
  envsubst < templates/ed_migration.ini > $alembic_file
  ls /usr/share/navitia/ed/alembic/versions
  alembic -c $alembic_file upgrade head
}

add_instance() {
  instance_name=$1
  echo "adding instance $instance_name"

  # tyr configuration
  tyr_config $instance_name

  # db creation and migration
  db_config $instance_name
}


upgrade_cities_db() {
  # Prepare the upgrade file for the cities db in the docker-compose
  cd /usr/share/navitia/cities

  SQL_ALCHEMY_URL="postgresql://${NAVITIA_DB_CITIES_USER}:${NAVITIA_DB_CITIES_PWD}@${NAVITIA_DB_CITIES_HOST}:${NAVITIA_DB_CITIES_PORT}/${NAVITIA_DB_CITIES_SCHEMA}" \
  envsubst < /templates/cities_migration.ini > alembic.ini
  # Wait for cities db ready
  while ! pg_isready --host="${NAVITIA_DB_CITIES_HOST}" --port="${NAVITIA_DB_CITIES_PORT}"; do
    echo "waiting for postgres ${NAVITIA_DB_CITIES_HOST}  to be ready"
    sleep 1;
  done

  # Perform the upgrade
  PYTHONPATH=. alembic -c alembic.ini upgrade head

  echo "cities db upgraded"
}

# to add an instance add an environment variable called INSTANCE_${NAME_OF_THE_INSTANCE}
instances=$(env | grep "INSTANCE_"  | sed 's/INSTANCE_\(.*\)=.*/\1/')

for i in $instances; do
  add_instance $i
done

echo "all instances configured"

upgrade_cities_db
