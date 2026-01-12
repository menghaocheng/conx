set /p ip_port=<ip_port.txt

set image_dir=Z:\h\release\ota

::set image_dir=F:\8550_version\VC.20240321.002
::set image_dir=Y:\code\8550S\vendor\outVersion\VC.20230922.02
set image_dir=F:\svn\VC.20240321.002\VC.20240321.002
set image_dir=Y:\code\8550A\vendor\outVersion\VC.20240321.002
set image_dir=X:\code\8550A\vendor\outVersion\VC.20240412.004
set image_dir=X:\code\8550A\vendor\outVersion\VC.20240413.005-rc
set image_dir=X:\code\8550A\vendor\outVersion\VC.20240413.005-rc2
::set image_dir=F:\8550_release\VC.20240412.004\VC.20240412.004
::set image_dir=X:\code\8550Q\vendor\outVersion\VC.20240412.004
set image_dir=X:\code\8550Q\vendor\outVersion\VC.20240412.004
set image_dir=X:\code\8550H\vendor\outVersion\VC.20240418.006
set image_dir=Z:\code\8550N\vendor\outVersion\VC.20240418.006
set image_dir=F:\release\8550_release\VC.20251226.089(host)
set image_dir=F:\release\8550_release\VC.20241223.084\VC.20241223.084-teg

adb -s %ip_port% push %image_dir%\update.zip /sdcard/
adb -s %ip_port% push %image_dir%\ota_info.txt /data/
adb -s %ip_port% shell "cat /data/ota_info.txt | sh"
adb -s %ip_port% reboot
adb -s %ip_port% wait-for-device
