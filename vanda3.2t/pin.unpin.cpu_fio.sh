#!/bin/bash

sudo /usr/sbin/tuned-adm profile balanced
#do job=1 cpu pining
sh fs_fio_dev.sh sysbench-cfg/benchmark.cfg

#do job=4 cpu pining
sed -i s/jbs=1/jbs=4/ sysbench-cfg/benchmark.cfg
sed -i s/cpucore_list=\"1\"/cpucore_list=\"1,2,3,4\"/ sysbench-cfg/benchmark.cfg
sh fs_fio_dev.sh sysbench-cfg/benchmark.cfg

#set back to job=1 cpu pining
sed -i s/jbs=4/jbs=1/ sysbench-cfg/benchmark.cfg
sed -i s/cpucore_list=\"1,2,3,4\"/cpucore_list=\"1\"/ sysbench-cfg/benchmark.cfg

sudo /usr/sbin/tuned-adm profile latency-performance
#do job=1 cpu pining
sh fs_fio_dev.sh sysbench-cfg/benchmark.cfg

#do job=4 cpu pining
sed -i s/jbs=1/jbs=4/ sysbench-cfg/benchmark.cfg
sed -i s/cpucore_list=\"1\"/cpucore_list=\"1,2,3,4\"/ sysbench-cfg/benchmark.cfg
sh fs_fio_dev.sh sysbench-cfg/benchmark.cfg

#set back to job=1 cpu pining
sed -i s/jbs=4/jbs=1/ sysbench-cfg/benchmark.cfg
sed -i s/cpucore_list=\"1,2,3,4\"/cpucore_list=\"1\"/ sysbench-cfg/benchmark.cfg




# do no-pincpu-test
sudo /usr/sbin/tuned-adm profile balanced
#do job=1 cpu pining
sh unpincpu_fs_fio.dev.sh sysbench-cfg/benchmark.cfg

#do job=4 cpu pining
sed -i s/jbs=1/jbs=4/ sysbench-cfg/benchmark.cfg
sed -i s/cpucore_list=\"1\"/cpucore_list=\"1,2,3,4\"/ sysbench-cfg/benchmark.cfg
sh unpincpu_fs_fio.dev.sh sysbench-cfg/benchmark.cfg

#set back to job=1 cpu pining
sed -i s/jbs=4/jbs=1/ sysbench-cfg/benchmark.cfg
sed -i s/cpucore_list=\"1,2,3,4\"/cpucore_list=\"1\"/ sysbench-cfg/benchmark.cfg

sudo /usr/sbin/tuned-adm profile latency-performance
#do job=1 cpu pining
sh unpincpu_fs_fio.dev.sh sysbench-cfg/benchmark.cfg

#do job=4 cpu pining
sed -i s/jbs=1/jbs=4/ sysbench-cfg/benchmark.cfg
sed -i s/cpucore_list=\"1\"/cpucore_list=\"1,2,3,4\"/ sysbench-cfg/benchmark.cfg
sh unpincpu_fs_fio.dev.sh sysbench-cfg/benchmark.cfg

#set back to job=1 cpu pining
sed -i s/jbs=4/jbs=1/ sysbench-cfg/benchmark.cfg
sed -i s/cpucore_list=\"1,2,3,4\"/cpucore_list=\"1\"/ sysbench-cfg/benchmark.cfg
