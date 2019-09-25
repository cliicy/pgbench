#!/bin/bash

if [ "${app_datadir}" == "" ]; then
    app_datadir=/opt/data/css/postgresql-10.10/
fi

pg_ctl -D ${app_datadir} stop

kill -9 `ps aux | grep -v grep | grep -e bin/postgresql | cut -c 10-15`

for i in {1..100};
do
    ps aux | grep -v grep | grep -e bin/postgresql
    if [ $? -ne 0 ]; then echo stopped; sleep 10; break; fi
    echo "waiting for postgresql to exit"
    sleep 3
done
