#!/bin/bash

# we need to wait for the database to be ready
while ! pg_isready "--host=${NAVITIA_DB_HOST}" -p "${NAVITIA_DB_PORT}"; do
    echo "waiting for postgres to be ready"
    sleep 1;
done

#export TYR_CONFIG_FILE=/srv/navitia/settings.py
export PYTHONPATH=.:../navitiacommon

#db migration
python /usr/bin/manage_tyr.py db upgrade

exec celery beat -A tyr.tasks
