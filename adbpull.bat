set /p ip_port=<ip_port.txt
adb -s %ip_port% pull %1 %2