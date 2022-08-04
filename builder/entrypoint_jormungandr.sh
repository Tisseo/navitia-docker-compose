#!/usr/bin/env bash


if [ -n "$NAVITIA_DB_PWD_FILE" ]; then
  if ! [ -f "$NAVITIA_DB_PWD_FILE" ]; then
    echo "Unable to locate file $NAVITIA_DB_PWD_FILE" >&2
    exit 2
  fi  
  export NAVITIA_DB_PWD="$(cat "$NAVITIA_DB_PWD_FILE" | tr -d '\n')"
fi


export JORMUNGANDR_SQLALCHEMY_DATABASE_URI="postgresql://${NAVITIA_DB_USER}:${NAVITIA_DB_PWD}@${NAVITIA_DB_HOST}:${NAVITIA_DB_PORT}/${NAVITIA_DB_SCHEMA}"


# run apache2
service apache2 start
if [ $? == 1 ]
then
  echo "Error: failed to start apache2";
  exit 1
fi
# run UWSGI
uwsgi --http 0.0.0.0:9090 --file /usr/src/app/jormungandr.wsgi

if [ $? == 1 ]
then
  echo "Error: Jormungandr was not launched";
  exit 1
fi

exec "$@"
