./tpcc.lua --pgsql-host=/tmp --pgsql-user=tcn --pgsql-db=vandat --threads=64 --tables=1 --scale=100 --trx_level=RC --db-ps-mode=auto --db-driver=pgsql prepare

./tpcc.lua --pgsql-host=/tmp --pgsql-user=tcn --pgsql-db=vandat --time=300 --threads=64 --report-interval=5 --tables=10 --scale=100 --trx_level=RC --db-ps-mode=auto --db-driver=pgsql --use_fk=0 --enable_purge=yes run > 1030_18:29.out
