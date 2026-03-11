#!/bin/bash
# Create binder device nodes from /proc/misc entries
for i in $(seq 1 72); do
    minor=$(grep " binder${i}$" /proc/misc | awk '{print $1}')
    if [ -n "$minor" ]; then
        mknod /dev/binder${i} c 10 $minor 2>/dev/null
        chmod 666 /dev/binder${i}
    fi
done
echo "Created binder device nodes:"
ls /dev/binder* 2>/dev/null | head -20
