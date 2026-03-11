set /p ip_port=<ip_port.txt
::adb connect %ip_port%
::adb -s %ip_port% root
set HX=myt-cx10
adb -s %ip_port% shell "mkdir -p /data/local/"
adb -s %ip_port% push .\%HX%\update_image.sh  /data/local/
@REM adb -s %ip_port% push .\%HX%\update_image_from_build.sh  /data/local/
adb -s %ip_port% push .\%HX%\load_cx10_image.sh /data/local/
@REM adb -s %ip_port% push .\%HX%\load_cx10_image_userdebug.sh /data/local/
adb -s %ip_port% push .\%HX%\mb1_build_cx10_con1.sh /data/local/
adb -s %ip_port% push .\%HX%\mb2_build_cx10_con2.sh /data/local/
adb -s %ip_port% push .\%HX%\mb3_build_cx10_con3.sh /data/local/
adb -s %ip_port% push .\%HX%\mb4_build_cx10_con4.sh /data/local/
adb -s %ip_port% push .\%HX%\mb5_build_cx10_con5.sh /data/local/
adb -s %ip_port% push .\%HX%\mb6_build_cx10_con6.sh /data/local/
adb -s %ip_port% push .\%HX%\mb7_build_cx10_con7.sh /data/local/
adb -s %ip_port% push .\%HX%\mb8_build_cx10_con8.sh /data/local/
adb -s %ip_port% push .\%HX%\mb9_build_cx10_con9.sh /data/local/
adb -s %ip_port% push .\%HX%\mb10_build_cx10_con10.sh /data/local/
adb -s %ip_port% push .\%HX%\mb11_build_cx10_con11.sh /data/local/
adb -s %ip_port% push .\%HX%\mb12_build_cx10_con12.sh /data/local/
adb -s %ip_port% push .\%HX%\mb13_build_cx10_con13.sh /data/local/
adb -s %ip_port% push .\%HX%\mb14_build_cx10_con14.sh /data/local/
adb -s %ip_port% push .\%HX%\mb15_build_cx10_con15.sh /data/local/
adb -s %ip_port% push .\%HX%\mbx_build_cx10_conX.sh /data/local/

adb -s %ip_port% shell "chmod 777 /data/local/*.sh"

