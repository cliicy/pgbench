#!/bin/bash

cfg_file=$1
if [ "$1" = "" ]; then echo -e "Usage:\n\t2_initdb.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

${app_basedir}/bin/initdb -D ${app_datadir}
${app_basedir}/bin/pg_ctl -D ${app_datadir} -l ${app_dbglog} start
cp -f ${app_pgconf} ${app_datadir}
${app_basedir}/bin/pg_ctl restart -D ${app_datadir}
#${app_basedir}/bin/pg_ctl reload -D ${app_datadir}

sleep 5

#create test database for pgbench to benchmark
echo -e "create database ${dbname} 
\q" | psql postgres

