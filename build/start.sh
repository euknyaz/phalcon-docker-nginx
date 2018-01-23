#!/usr/bin/env bash
set -e

# Load /etc/sysctl.conf
# sysctl -p

# Apply changes required for redis
#if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
#    echo never > /sys/kernel/mm/transparent_hugepage/enabled
#fi
#if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
#    echo never > /sys/kernel/mm/transparent_hugepage/defrag
#fi

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
