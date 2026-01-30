set /p ip_port=<ip_port.txt
::adb connect %ip_port%
::adb -s %ip_port% root
set HX=rk10
adb -s %ip_port% shell "mkdir -p /data/local/"
adb -s %ip_port% push .\%HX%\update_image.sh  /data/local/
adb -s %ip_port% push .\%HX%\load_rk10_image.sh /data/local/
adb -s %ip_port% push .\%HX%\b3_build_rk10_con3.sh /data/local/
adb -s %ip_port% push .\%HX%\b4_build_rk10_con4.sh /data/local/
adb -s %ip_port% push .\%HX%\b5_build_rk10_con5.sh /data/local/
adb -s %ip_port% push .\%HX%\b10_build_rk10_con1-con5.sh /data/local/
adb -s %ip_port% push .\%HX%\b11_build_rk_conX.sh /data/local/
adb -s %ip_port% push .\%HX%\ddr_img_30G.sh /data/local/
adb -s %ip_port% shell "chmod 777 /data/local/*.sh"

