#!/bin/bash

function check_installed() {
        if [ -z "$(which ${1})" ] && [ ! -f "/bin/${1}" ]; then
                echo "FATAL ERROR: ${1^} executable not found."; exit
        fi
}


echo "UK SeLinux Denial Fixer"
echo "PRESS ENTER TO CONTINUE"
check_installed su ; check_installed python3
read
su -c logcat *:E -d | grep denied > sedenials
python3 policy.py > denials
su -c mount -o rw,remount /system
su -c rm -rf /system/SeFix
su -c mkdir /system/SeFix
su -c cp helper.sh /system/SeFix/helper.sh
su -c mv denials /system/SeFix/denials
su -c chmod a+x /system/SeFix/helper.sh
rm sedenials
echo
echo "THE PROCESS SHOULD START AND MAY TAKE AS LONG AS 1-2 HOURS."
echo "PRESS ENTER TO CONTINUE"
read
cd /system/SeFix
su -c ./helper.sh
if [ ! -z "$(cat denials)" ]; then
	su -c logcat -c > /dev/null
	su -c supolicy --save /system/SAVED_POLICIES
	echo "Policies have been saved in /system/SAVED_POLICIES"
fi
