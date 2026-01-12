set /p ip_port=<ip_port.txt
adb -s %ip_port% push %1 %2