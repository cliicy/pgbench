#!/bin/bash

#compression_list="none snappy zlib"
#for cmp in ${compression_list};
#do
#export app_cfg=`pwd`/cfg/${cmp}.cnf

sh stop.sh
#make modification for postgresql.conf
sh onlyrunstart.sh cfg/run_case.cfg
./3_run.sh      ./cfg/run_case.cfg
#done
