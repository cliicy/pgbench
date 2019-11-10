#!/bin/bash

usage="Usage:\n\t1_prep_dev cfg_file\n\tExample: ./1_prep_dev.sh sysbench.cfg"
if [ "$1" == "" ]; then echo -e ${usage}; exit 1; fi
if [ ! -e $1 ]; then echo "can't find configuration file [$1]", exit 2; fi

# read in configurations
source $1

if [ "${output_dir}" == "" ];
then
        export output_dir=${result_dir}/${logfolder}-`date +%Y%m%d_%H%M%S`${case_id}
fi

echo "test output will be saved in ${output_dir}"
if [ ! -e ${output_dir} ]; then mkdir -p ${output_dir}; fi

lsblk ${disk}
if [ "$?" -ne 0 ]; then echo "cannot find disk [${disk}]"; exit 3; fi

for index in {1..32};
do
# stop mysql service first, since it my occupy the disk
./stop.sh

bsz=`expr ${index} \* 8`
fioname=${mnt_point_data##*/}
outfile=${output_dir}/${fioname}_${bsz}k.out
sudo time fio -filename=${disk} -direct=1 -iodepth 1 -thread -rw=randwrite -size=120G -ioengine=psync -bs=${bsz}k -numjobs=1 -runtime=60 -group_reporting -name=${fioname} > ${outfile}
sleep 5

done
