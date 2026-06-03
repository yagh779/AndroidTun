#!/system/bin/sh

export PATH="/data/adb/magisk:/data/adb/ksu/bin:/data/adb/ap/bin:$PATH:/data/data/com.termux/files/usr/bin"

scripts=$(realpath $0)
scripts_dir=$(dirname ${scripts})

. ${scripts_dir}/config.sh

mkdir -p ${run_path}
mkdir -p ${box_path}/${bin_name}

find ${box_path} -mtime +3 -type f -name "*.log" | xargs rm -f

log() {
	local level="$1"
	local message="$2"
	local timestamp
	local color_code

	export TZ=Asia/Shanghai
	timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

	case "$level" in
	Debug) color_code="\033[0;36m" ;;
	Info) color_code="\033[1;32m" ;;
	Warn) color_code="\033[1;33m" ;;
	Error) color_code="\033[1;31m" ;;
	*)
		level="Unknown"
		color_code="\033[0m"
		;;
	esac

	if [ -t 2 ]; then
		printf "%b\n" "${color_code}${timestamp} [${level}]: ${message}\033[0m" >&2
	else
		printf "%s\n" "${timestamp} [${level}]: ${message}" >&2
	fi
}

private_dns_state_file="${run_path}/.private_dns_mode"

save_private_dns() {
	local current_mode=$(/system/bin/settings get global private_dns_mode 2>/dev/null)
	if [ -z "${current_mode}" ] || [ "${current_mode}" = "null" ] || [ "${current_mode}" = "off" ]; then
		log Info "private_dns_mode is already off or not set, no need to save."
		return 0
	fi
	echo "${current_mode}" >${private_dns_state_file}
	nohup /system/bin/sh -c '/system/bin/settings put global private_dns_mode off' >/dev/null 2>&1 &
	log Info "private_dns_mode saved (${current_mode}), setting to off in background."
}

restore_private_dns() {
	if [ -f "${private_dns_state_file}" ]; then
		local saved_mode=$(cat ${private_dns_state_file})
		nohup /system/bin/sh -c "/system/bin/settings put global private_dns_mode ${saved_mode}" >/dev/null 2>&1 &
		rm -f ${private_dns_state_file}
		log Info "private_dns_mode restoring to ${saved_mode} in background."
	else
		log Info "no saved private_dns_mode, skip restore."
	fi
}

ping_fix() {
	case "$1" in
	enable)
		iptables -t nat -A OUTPUT -d "$fake_ip_range_v4" -p icmp -j DNAT --to-destination 127.0.0.1
		iptables -t nat -A PREROUTING -d "$fake_ip_range_v4" -p icmp -j DNAT --to-destination 127.0.0.1
		ip6tables -t nat -A OUTPUT -d "$fake_ip_range_v6" -p icmp -j DNAT --to-destination ::1
		ip6tables -t nat -A PREROUTING -d "$fake_ip_range_v6" -p icmp -j DNAT --to-destination ::1
		log Info "ICMP redirection enabled for fake IP ranges (ping returns response, not necessarily valid)"
		;;
	disable)
		iptables -t nat -D OUTPUT -d "$fake_ip_range_v4" -p icmp -j DNAT --to-destination 127.0.0.1
		iptables -t nat -D PREROUTING -d "$fake_ip_range_v4" -p icmp -j DNAT --to-destination 127.0.0.1
		ip6tables -t nat -D OUTPUT -d "$fake_ip_range_v6" -p icmp -j DNAT --to-destination ::1
		ip6tables -t nat -D PREROUTING -d "$fake_ip_range_v6" -p icmp -j DNAT --to-destination ::1
		log Info "ICMP redirection disabled for fake IP ranges"
		;;
	esac
}

check_permission() {
	if which ${bin_name} | grep -q "/system/bin/"; then
		box_user=$(echo ${box_user_group} | awk -F ':' '{print $1}')
		box_group=$(echo ${box_user_group} | awk -F ':' '{print $2}')
		box_user_id=$(id -u ${box_user})
		box_group_id=$(id -g ${box_group})
		[ ${box_user_id} ] && [ ${box_group_id} ] ||
			(box_user_group="root:net_admin" && log Error "${box_user_group} error, use root:net_admin instead.")
		bin_path=$(which ${bin_name})
		chown ${box_user_group} ${bin_path}
		chmod 0755 ${bin_path}
		if [ "${box_user_id}" != "0" ] || [ "${box_group_id}" != "3005" ]; then
			# setcap has been deprecated as it does not support binary outside of the /system/bin directory
			setcap 'cap_net_admin,cap_net_raw,cap_net_bind_service,cap_sys_ptrace,cap_dac_read_search+ep' ${bin_path} ||
				(box_user_group="root:net_admin" && log Error "setcap authorization failed, you may need libcap package.")
		fi
		chown -R ${box_user_group} ${box_path}
		return 0
	elif [ -f ${bin_path} ]; then
		box_user_group="root:net_admin"
		chown ${box_user_group} ${bin_path}
		chmod 0700 ${bin_path}
		chown -R ${box_user_group} ${box_path}
		return 0
	else
		return 1
	fi
}

start_bin() {
	ulimit -SHn 1000000
	case "${bin_name}" in
	sing-box)
		if ${bin_path} check -D ${box_path}/${bin_name} >${run_path}/check.log 2>&1; then
			log Info "starting ${bin_name} service."
			[ -f "${box_path}/${bin_name}/src/log.txt" ] && mv ${box_path}/${bin_name}/src/log.txt ${box_path}/${bin_name}/src/log.txt.bak
			nohup busybox setuidgid ${box_user_group} ${bin_path} run -D ${box_path}/${bin_name} >/dev/null 2>${run_path}/error_${bin_name}.log &
			echo -n $! >${pid_file}
			return 0
		else
			log Error "configuration check failed, please check the ${run_path}/check.log file."
			return 1
		fi
		;;
	mihomo)
		if ${bin_path} -t -d ${box_path}/${bin_name} >${run_path}/check.log 2>&1; then
			log Info "starting ${bin_name} service."
			nohup busybox setuidgid ${box_user_group} ${bin_path} -d ${box_path}/${bin_name} >${box_path}/${bin_name}/src/${bin_name}_$(date +%Y%m%d%H%M).log 2>${run_path}/error_${bin_name}.log &
			echo -n $! >${pid_file}
			return 0
		else
			log Error "configuration check failed, please check the ${run_path}/check.log file."
			return 1
		fi
		;;
	*)
		log Error "$1 core error, it must be one of ${bin_name_list}"
		return 2
		;;
	esac
}

find_netstat_path() {
	[ -f /system/bin/netstat ] && alias netstat="/system/bin/netstat" && return 0
	[ -f /system/xbin/netstat ] && alias netstat="/system/xbin/netstat" && return 0
	return 1
}

wait_bin_listen() {
	wait_count=0
	bin_pid=$(busybox pidof ${bin_name})
	find_netstat_path &&
		check_bin_cmd="netstat -tnulp | grep -q ${bin_name}" ||
		check_bin_cmd="ls -lh /proc/${bin_pid}/fd | grep -q socket"
	while [ ${bin_pid} ] && ! eval "${check_bin_cmd}" && [ ${wait_count} -lt 100 ]; do
		sleep 1
		wait_count=$((${wait_count} + 1))
	done
	if [ ${bin_pid} ] && eval "${check_bin_cmd}"; then
		return 0
	else
		return 1
	fi
}

display_bin_status() {
	if bin_pid=$(busybox pidof ${bin_name}); then
		log Info "${bin_name} has started with the $(stat -c %U:%G /proc/${bin_pid}) user group."
		log Info "${bin_name} service is running. ( PID: ${bin_pid} )"
		log Info "${bin_name} memory usage: $(cat /proc/${bin_pid}/status | grep -w VmRSS | awk '{print $2$3}')"
		log Info "${bin_name} cpu usage: $(/system/bin/ps -eo %CPU,NAME 2>/dev/null | grep ${bin_name} | awk '{print $1"%"}' || dumpsys cpuinfo | grep ${bin_name} | awk '{print $1}')"
		log Info "${bin_name} running time: $(busybox ps -o comm,etime | grep ${bin_name} | awk '{print $2}')"
		echo -n ${bin_pid} >${pid_file}
		return 0
	else
		log Warn "${bin_name} service is stopped."
		return 1
	fi
}

start_service() {
	if check_permission; then
		log Info "${bin_name} will be started with the ${box_user_group} user group."
		if start_bin && wait_bin_listen; then
			log Info "${bin_name} service is running. ( PID: $(cat ${pid_file}) )"
			return 0
		else
			if bin_pid=$(pidof ${bin_name}); then
				log Warn "${bin_name} service is running but may not listening. ( PID: ${bin_pid} )"
				return 0
			else
				log Error "start ${bin_name} service failed, please check the ${run_path}/error_${bin_name}.log file."
				rm -f ${pid_file} >>/dev/null 2>&1
				return 1
			fi
		fi
	else
		log Error "missing ${bin_name} core, please download and place it in the ${box_path}/bin/ directory"
		return 2
	fi
}

stop_service() {
	if display_bin_status; then
		log Warn "stopping ${bin_name} service."
		kill $(cat ${pid_file}) || killall ${bin_name}
		sleep 1
		display_bin_status
	fi
	rm -f ${pid_file} >>/dev/null 2>&1
}

probe_tun_device() {
	ifconfig | grep -q ${tun_device} || return 1
}

sing_tun_ip_rules() {
	ip rule $1 iif lo lookup local_network pref 7000
	ip rule $1 from all iif ${tun_device} goto 7010 pref 7001
	ip rule $1 from all lookup 2022 pref 7002
	ip rule $1 from all nop pref 7010
	ip -6 rule $1 from all iif ${tun_device} goto 7010 pref 7001
	ip -6 rule $1 from all lookup 2022 pref 7002
	ip -6 rule $1 from all nop pref 7010
}

tun_forward_iptables_rules() {
	iptables -w 100 $1 FORWARD -o ${tun_device} -j ACCEPT
	iptables -w 100 $1 FORWARD -i ${tun_device} -j ACCEPT
	ip6tables -w 100 $1 FORWARD -o ${tun_device} -j ACCEPT
	ip6tables -w 100 $1 FORWARD -i ${tun_device} -j ACCEPT
}

tun_forward_enable() {
	tun_forward_disable
	sleep 1
	echo 1 >/proc/sys/net/ipv4/ip_forward
	echo 2 >/proc/sys/net/ipv4/conf/default/rp_filter
	echo 2 >/proc/sys/net/ipv4/conf/all/rp_filter

	# create_tun_link
	probe_tun_device && tun_forward_iptables_rules "-I" && sing_tun_ip_rules "add" && log Info "tun hotspot support is enabled."
	return 0
}

tun_forward_disable() {
	sing_tun_ip_rules "del" >>/dev/null 2>&1
	tun_forward_iptables_rules "-D" >>/dev/null 2>&1
	log Warn "tun hotspot support is disabled."
}

case "$1" in
start)
	save_private_dns
	display_bin_status || start_service
	[ $? = "0" ] && tun_forward_enable
	ping_fix enable >>/dev/null 2>&1
	;;
stop)
	stop_service
	tun_forward_disable
	restore_private_dns
	ping_fix disable >>/dev/null 2>&1
	;;
restart)
	stop_service
	tun_forward_disable
	restore_private_dns
	ping_fix disable >>/dev/null 2>&1
	sleep 2
	save_private_dns
	start_service
	[ $? = "0" ] && tun_forward_enable
	ping_fix enable >>/dev/null 2>&1
	;;
status)
	display_bin_status
	;;
*)
	log Error "$0 $1 usage: $0 {start|stop|restart|status}"
	;;
esac
