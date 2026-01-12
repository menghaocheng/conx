set /p ip_port=<ip_port.txt
::adb connect %ip_port%
::adb -s %ip_port% root
set HX=cx10
adb -s %ip_port% shell "mkdir -p /data/local/"
adb -s %ip_port% push .\%HX%\update_image.sh  /data/local/
adb -s %ip_port% push .\%HX%\load_cx10_image.sh /data/local/
adb -s %ip_port% push .\%HX%\b1_build_cx10_con1.sh /data/local/
adb -s %ip_port% push .\%HX%\b2_build_cx10_con2.sh /data/local/
adb -s %ip_port% push .\%HX%\b3_build_cx10_con3.sh /data/local/
adb -s %ip_port% push .\%HX%\b4_build_cx10_con4.sh /data/local/
adb -s %ip_port% push .\%HX%\b5_build_cx10_con5.sh /data/local/
adb -s %ip_port% push .\%HX%\bx_build_cx10_conX.sh /data/local/
adb -s %ip_port% push .\%HX%\by_build_cx10_con1-20.sh /data/local/
adb -s %ip_port% shell "chmod 777 /data/local/*.sh"

