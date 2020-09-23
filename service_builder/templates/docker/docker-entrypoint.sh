#!/bin/bash
set -e

bash scripts/wait-for-it.sh $DATABASE_HOST $DATABASE_PORT

echo $(date -u) "- Migrating"
python manage.py migrate

echo $(date -u) "- Running the server"
gunicorn {{ name_project }}.wsgi --config {{ name_project }}/gunicorn_conf.py
