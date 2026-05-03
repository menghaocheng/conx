set /p ip_port=<ip_port.txt
::adb connect %ip_port%
::adb -s %ip_port% root
set HX=cx10
adb -s %ip_port% shell "mkdir -p /data/local/"
adb -s %ip_port% push .\%HX%\update_image.sh  /data/local/
@REM adb -s %ip_port% push .\%HX%\update_image_from_build.sh  /data/local/
adb -s %ip_port% push .\%HX%\load_cx10_image.sh /data/local/
@REM adb -s %ip_port% push .\%HX%\load_cx10_image_userdebug.sh /data/local/
adb -s %ip_port% push .\%HX%\b1_build_cx10_con1.sh /data/local/
adb -s %ip_port% push .\%HX%\b2_build_cx10_con2.sh /data/local/
adb -s %ip_port% push .\%HX%\b3_build_cx10_con3.sh /data/local/
adb -s %ip_port% push .\%HX%\b4_build_cx10_con4.sh /data/local/
adb -s %ip_port% push .\%HX%\b5_build_cx10_con5.sh /data/local/
adb -s %ip_port% push .\%HX%\b6_build_cx10_con6.sh /data/local/
adb -s %ip_port% push .\%HX%\b7_build_cx10_con7.sh /data/local/
adb -s %ip_port% push .\%HX%\b8_build_cx10_con8.sh /data/local/
adb -s %ip_port% push .\%HX%\b9_build_cx10_con9.sh /data/local/
adb -s %ip_port% push .\%HX%\b10_build_cx10_con10.sh /data/local/
adb -s %ip_port% push .\%HX%\b11_build_cx10_con11.sh /data/local/
adb -s %ip_port% push .\%HX%\b12_build_cx10_con12.sh /data/local/
adb -s %ip_port% push .\%HX%\b13_build_cx10_con13.sh /data/local/
adb -s %ip_port% push .\%HX%\b14_build_cx10_con14.sh /data/local/
adb -s %ip_port% push .\%HX%\b15_build_cx10_con15.sh /data/local/
adb -s %ip_port% push .\%HX%\b16_build_cx10_con16.sh /data/local/
adb -s %ip_port% push .\%HX%\b17_build_cx10_con17.sh /data/local/
adb -s %ip_port% push .\%HX%\b18_build_cx10_con18.sh /data/local/
adb -s %ip_port% push .\%HX%\b19_build_cx10_con19.sh /data/local/
adb -s %ip_port% push .\%HX%\b10_build_cx10_con20.sh /data/local/
adb -s %ip_port% push .\%HX%\bx_build_cx10_conX.sh /data/local/
adb -s %ip_port% push .\%HX%\by_build_cx10_con1-20.sh /data/local/
adb -s %ip_port% shell "chmod 777 /data/local/*.sh"

