set /p ip_port=<ip_port.txt
::adb connect %ip_port%
::adb -s %ip_port% root
set HX=rk14_paas
adb -s %ip_port% shell "mkdir -p /data/local"
adb -s %ip_port% push .\%HX%\update_rk14_image.sh  /data/local/
adb -s %ip_port% push .\%HX%\load_rk14_image.sh /data/local/
adb -s %ip_port% push .\%HX%\b1_build_rk14_con1.sh /data/local/
adb -s %ip_port% push .\%HX%\b2_build_rk14_con2.sh /data/local/
adb -s %ip_port% push .\%HX%\b3_build_rk14_con3.sh /data/local/
adb -s %ip_port% push .\%HX%\b4_build_rk14_con4.sh /data/local/
adb -s %ip_port% push .\%HX%\b5_build_rk14_con5.sh /data/local/
adb -s %ip_port% shell "chmod 777 /data/local/*.sh"
