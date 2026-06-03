#!/bin/sh

bin_name="mihomo"
box_user_group="root:net_admin"
bin_name_list="sing-box mihomo"

box_path="/data/adb/atun"
bin_path="${box_path}/bin/${bin_name}"
run_path="${box_path}/run"
pid_file="${run_path}/${bin_name}.pid"

tun_device="tun0"
fake_ip_range_v4="28.0.0.1/8"
fake_ip_range_v6="fc00::/18"
