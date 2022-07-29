#!/bin/bash

echo ${TYR_SQLALCHEMY_DATABASE_URI}
# we need to wait for the database to be ready
while ! pg_isready --host=${TYR_SQLALCHEMY_DATABASE_URI}; do
    echo "waiting for postgres to be ready"
    sleep 1;
done

# export PYTHONPATH=.:../navitiacommon

#db migration
python /usr/bin/manage_tyr.py db upgrade

uwsgi --mount /=tyr:app --http 0.0.0.0:80
