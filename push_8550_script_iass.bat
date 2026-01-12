set /p ip_port=<ip_port.txt

set HX=8550_iass
adb -s %ip_port% shell "mkdir -p /data/local/"
adb -s %ip_port% push .\%HX%\update_image.sh  /data/local/
adb -s %ip_port% push .\%HX%\load_8550_image.sh /data/local/
adb -s %ip_port% push .\%HX%\b1_build_8550_con1.sh /data/local/
adb -s %ip_port% push .\%HX%\b2_build_8550_con2.sh /data/local/
adb -s %ip_port% push .\%HX%\b3_build_8550_con3.sh /data/local/
adb -s %ip_port% push .\%HX%\b4_build_8550_con4.sh /data/local/
adb -s %ip_port% push .\%HX%\b5_build_8550_con5.sh /data/local/
adb -s %ip_port% shell "chmod 777 /data/local/*.sh"


