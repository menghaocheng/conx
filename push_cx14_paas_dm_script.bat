set /p ip_port=<ip_port.txt
::adb connect %ip_port%
::adb -s %ip_port% root
set HX=rk14_paas_dm
adb -s %ip_port% shell "mkdir -p /data"
adb -s %ip_port% push .\%HX%\update_image.sh  /data/
adb -s %ip_port% push .\%HX%\load_rk14_image.sh /data/
::adb -s %ip_port% push .\%HX%\b3_build_rk14_paas_dm_con3.sh /data/
adb -s %ip_port% push .\%HX%\b4_build_rk14_paas_dm_con4.sh /data/
adb -s %ip_port% push .\%HX%\b5_build_rk14_paas_dm_con5.sh /data/
adb -s %ip_port% shell "chmod 777 /data/*.sh"

