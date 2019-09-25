#! /bin/bash

cfg_file=$1
if [ "${cfg_file}" = "" ]; then echo -e "Usage:\n\t3_run.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

# output_dir will be used in fio.sh, so make it global
if [ "${output_dir}" == "" ];
then
        export output_dir=${result_dir}/${logfolder}-`date +%Y%m%d_%H%M%S`${case_id}
fi

echo "test output will be saved in ${output_dir}"
if [ ! -e ${output_dir} ]; then mkdir -p ${output_dir}; fi

# collect MySQL startup options / configuration / test script
cp $0 ${output_dir}
cp ${cfg_file} ${output_dir}
cp ${cfg_file%/*}/postgresql.conf ${output_dir}

source ../lib/common-lib
source ../lib/bench-lib

collect_sys_info ${output_dir} ${css_status}

echo "export output_dir=${output_dir}" > ./output.dir
#collect some extra information
pginfo=${output_dir}/postgresql.opts
psql -c 'show shared_buffers' postgres > ${pginfo} 
psql -c 'show wal_compression' postgres >> ${pginfo} 
psql -c 'show max_wal_size' postgres >> ${pginfo} 

echo "will run workload(s) ${workload_set}"
for workload in ${workload_set};
    do
        echo "run workload ${workload}"
	cmd="run"
        # workload friendly name. it will be used in fio.sh, so make it global
        export workload_fname=${workload}
        echo ${workload} | grep load
	if [ $? -eq 0 ]; then cmd="load"; fi
        echo -e "sfx_message starts at: " `date +%Y-%m-%d\ %H:%M:%S` "\n"  > ${output_dir}/${workload_fname}.sfx_message
        sudo chmod 666 /var/log/sfx_messages;
	tail -f -n 0 /var/log/sfx_messages >> ${output_dir}/${workload_fname}.sfx_message &
        echo $! > ${output_dir}/tail.${workload_fname}.pid
        echo "iostat start at: " `date +%Y-%m-%d\ %H:%M:%S` > ${output_dir}/${workload_fname}.iostat
        tail -f -n 0 ${app_dbglog} > ${output_dir}/${workload_fname}.${app}.log &
        echo $! > ${output_dir}/tail.${workload_fname}.${app}.log.pid
        # try to keep existing result file
        if [ -e ${output_dir}/${workload_fname}.result ];
        then
                mv ${output_dir}/${workload_fname}.result ${output_dir}/${workload_fname}-`date +%Y%m%d_%H%M%S`.result
        fi
        echo "${workload_fname} starts at: " `date +%Y-%m-%d\ %H:%M:%S` > ${output_dir}/${workload_fname}.result

        iostat -txdmc ${rpt_interval} ${disk} >> ${output_dir}/${workload_fname}.iostat &
        echo $! > ${output_dir}/${workload_fname}.iostat.pid

	#cp ./workload/${workload} ${output_dir}
	# run postgreSQL workload, all parameters are from case-cfg/cfg_file
        if [ "${cmd}" == "load" ]; then
            cmdline="time ${app_basedir}/bin/pgbench -i --unlogged-tables -s ${scale} -U ${user} -h ${host} -n -q -d ${dbname}"
        else
            cmdline="time ${app_basedir}/bin/pgbench -r -j ${jobs} -c ${threads} -P ${rpt_interval} -T ${run_time} -U ${user} -h ${host} -d ${dbname}"
        fi
        echo ${cmdline} >> ${pginfo}
        if [ "${cmd}" == "load" ]; then
            time ${cmdline} >> ${output_dir}/${workload_fname}.result 2>&1  
        else
            time ${cmdline} >> ${output_dir}/${workload_fname}.result   
        fi
        du --block-size=1G ${app_datadir} > ${output_dir}/${workload_fname}.dbsize
        cat /sys/block/${dev_id}/sfx_smart_features/sfx_capacity_stat >> ${output_dir}/${workload_fname}.dbsize

        echo -e "\nsfx_messages ends at: `date +%Y-%m-%d_%H:%M:%S`\n"  >> ${output_dir}/${workload_fname}.sfx_message
        echo ${output_dir}/tail.${workload_fname}.pid
        kill `cat ${output_dir}/tail.${workload_fname}.pid`
        rm -f ${output_dir}/tail.${workload_fname}.pid
        echo -e "\niostat ends at: " `date +%Y-%m-%d_%H:%M:%S` >> ${output_dir}/${workload_fname}.iostat
        echo -e "\n${workload_fname}" "\nends at: " "`date +%Y-%m-%d_%H:%M:%S`" >> ${output_dir}/${workload_fname}.result
        echo ${output_dir}/${workload_fname}.iostat.pid
        kill `cat ${output_dir}/${workload_fname}.iostat.pid`
        rm -f ${output_dir}/${workload_fname}.iostat.pid
        kill `cat ${output_dir}/tail.${workload_fname}.${app}.log.pid`
        rm -f ${output_dir}/tail.${workload_fname}.${app}.log.pid
        # sleep ${sleep_after_case}
        sleep 60
        echo -e "select pg_database_size('${dbname}')/1024/1024/1024||'G'
" | psql postgres > ${output_dir}/${workload_fname}.pgdbsize
        #du --block-size=1G ${app_datadir} > ${output_dir}/${workload_fname}.2dbsize
        #cat /sys/block/${dev_id}/sfx_smart_features/sfx_capacity_stat >> ${output_dir}/${workload_fname}.2dbsize
    done

generate_csv ${output_dir}
get_dbsize_csv ${output_dir}

ssd_name=$(basename "$PWD")
gen_benchinfo_postgres ${ssd_name} ${scale} ${output_dir}

