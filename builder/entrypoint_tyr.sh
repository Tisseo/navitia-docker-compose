#!/usr/bin/env sh

SECRET_LIST="NAVITIA_DB_PWD \
NAVITIA_DB_CITIES_PWD \
TYR_CELERY_BROKER_PWD \
TYR_KRAKEN_BROKER_PWD"

# Try to read secret files if value is not in the environment
for VARNAME in $SECRET_LIST; do
  if [ -z "$(eval echo "\$${VARNAME}")" ] && [ -n "$(eval echo "\$${VARNAME}_FILE")" ]; then
    if ! [ -f "$(eval echo "\$${VARNAME}_FILE")" ]; then
      echo "Unable to locate file \$${VARNAME}_FILE" >&2
      exit 2
    fi  
    export "${VARNAME}"="$(cat "$(eval echo \$${VARNAME}_FILE)" | tr -d '\n')"
  fi
done


test -n "$NAVITIA_DB_PWD" && export TYR_SQLALCHEMY_DATABASE_URI="postgresql://${NAVITIA_DB_USER}:${NAVITIA_DB_PWD}@${NAVITIA_DB_HOST}:${NAVITIA_DB_PORT}/${NAVITIA_DB_SCHEMA}"
test -n "$NAVITIA_DB_CITIES_PWD" && export TYR_CITIES_DATABASE_URI="postgresql://${NAVITIA_DB_CITIES_USER}:${NAVITIA_DB_CITIES_PWD}@${NAVITIA_DB_CITIES_HOST}:${NAVITIA_DB_CITIES_PORT}/${NAVITIA_DB_CITIES_SCHEMA}"
test -n "$TYR_CELERY_BROKER_PWD" && export TYR_CELERY_BROKER_URL="amqp://${TYR_CELERY_BROKER_USER}:${TYR_CELERY_BROKER_PWD}@${TYR_CELERY_BROKER_HOST}:${TYR_CELERY_BROKER_PORT}//"
test -n "$TYR_KRAKEN_BROKER_PWD" && export TYR_KRAKEN_BROKER_URL="amqp://${TYR_KRAKEN_BROKER_USER}:${TYR_KRAKEN_BROKER_PWD}@${TYR_KRAKEN_BROKER_HOST}:${TYR_KRAKEN_BROKER_PORT}//"

exec "$@"
