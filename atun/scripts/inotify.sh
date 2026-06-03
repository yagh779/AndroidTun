#!/system/bin/sh

scripts=$(realpath $0)
scripts_dir=$(dirname ${scripts})

. ${scripts_dir}/config.sh

service_path="${scripts_dir}/service.sh"

events=$1
monitor_dir=$2
monitor_file=$3

service_control() {
	if [ "${monitor_file}" = "disable" ]; then
		if [ "${events}" = "d" ]; then
			${service_path} start >>/dev/null 2>>${run_path}/run.log
		elif [ "${events}" = "n" ]; then
			${service_path} stop >>/dev/null 2>>${run_path}/run.log
		fi
	fi
}

mkdir -p ${run_path}

service_control
