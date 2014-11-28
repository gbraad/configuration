#!/bin/sh
set -e
cd /edx/app/edxapp/edx-platform && sudo -u www-data /edx/bin/python.edxapp ./manage.py lms syncdb --migrate --noinput --settings docker_multi
cd /edx/app/edxapp/edx-platform && sudo -u www-data /edx/bin/python.edxapp ./manage.py cms syncdb --migrate --noinput --settings docker_multi
source /edx/app/edxapp/edxapp_env
cd /edx/app/edxapp/edx-platform && paver update_assets cms --settings=docker_multi
cd /edx/app/edxapp/edx-platform && paver update_assets lms --settings=docker_multi
/usr/sbin/nginx &
/sbin/my_init