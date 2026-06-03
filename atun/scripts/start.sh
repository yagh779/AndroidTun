#!/system/bin/sh

module_dir="/data/adb/modules/AndroidTun"

scripts=$(realpath $0)
scripts_dir=$(dirname ${scripts})

. ${scripts_dir}/config.sh

wait_until_login() {
	# we doesn't have the permission to rw "/sdcard" before the user unlocks the screen
	local test_file="/sdcard/Android/.ATUN"
	true >"$test_file"
	while [ ! -f "$test_file" ]; do
		true >"$test_file"
		sleep 1
	done
	rm "$test_file"

	while [ ! -f "/data/system/packages.xml" ]; do
		sleep 1
	done
}

wait_until_login

rm ${pid_file}
mkdir -p ${run_path}

if [ ! -f ${module_dir}/disable ]; then
	mv ${run_path}/run.log ${run_path}/run.log.bak

	${scripts_dir}/service.sh start >>/dev/null 2>>${run_path}/run.log
fi
