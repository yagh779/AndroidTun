#!/sbin/sh

module_dir="/data/adb/modules/AndroidTun"

scripts_dir="/data/adb/atun/scripts"

(
	until [ $(getprop sys.boot_completed) -eq 1 ]; do
		sleep 3
	done
	${scripts_dir}/start.sh
) &

inotifyd ${scripts_dir}/inotify.sh ${module_dir} >/dev/null 2>&1 &
