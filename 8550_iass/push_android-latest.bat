set /p ip_port=<ip_port.txt
::adb connect %ip_port%
::adb -s %ip_port% root
adb -s %ip_port% push F:\release\8550_release\VC.20240619.034\android-latest.img  /data/local/android-latest.img
