#!/sbin/sh

SKIPUNZIP=1
ASH_STANDALONE=1

if [ "$BOOTMODE" ! = true ] ; then
  abort "Error: Please install in Magisk Manager, KernelSU Manager or APatch"
fi

if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ] ; then
  abort "Error: Please update your KernelSU"
fi

if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10683 ] ; then
  service_dir="/data/adb/ksu/service.d"
else 
  service_dir="/data/adb/service.d"
fi

if [ ! -d "$service_dir" ] ; then
    mkdir -p $service_dir
fi

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH

if [ -d /data/adb/atun ] ; then
  cp /data/adb/atun/scripts/config.sh /data/adb/atun/scripts/config.sh.bak
  ui_print "- User configuration config.sh has been backed up to config.sh.bak"

  cat /data/adb/atun/scripts/config.sh >> $MODPATH/atun/scripts/config.sh
  cp -f $MODPATH/atun/scripts/* /data/adb/atun/scripts/
  ui_print "- User configuration config.sh has been"
  ui_print "- attached to the module config.sh,"
  ui_print "- please re-edit config.sh"
  ui_print "- after the update is complete."

  awk '!x[$0]++' $MODPATH/box/scripts/config.sh > /data/adb/atun/scripts/config.sh

  rm -rf $MODPATH/atun
else
  mv $MODPATH/atun /data/adb/
fi

mv -f $MODPATH/atun_service.sh $service_dir/

rm -f customize.sh

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive /data/adb/atun/ 0 0 0755 0644
set_perm_recursive /data/adb/atun/scripts/ 0 0 0755 0700
set_perm_recursive /data/adb/atun/bin/ 0 0 0755 0700

set_perm $service_dir/atun_service.sh 0 0 0700

# fix "set_perm_recursive /data/adb/box/scripts" not working on some phones.
chmod ugo+x /data/adb/atun/scripts/*
