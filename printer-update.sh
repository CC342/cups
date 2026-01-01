#!/bin/sh
set -e
set -x

# 创建管理员
if [ $(grep -ci $CUPSADMIN /etc/shadow) -eq 0 ]; then
    useradd -r -G lpadmin -M $CUPSADMIN
fi
echo $CUPSADMIN:$CUPSPASSWORD | chpasswd

# 准备目录
mkdir -p /config/ppd
mkdir -p /services

rm -rf /etc/cups/ppd
ln -s /config/ppd /etc/cups

# 确保 printers.conf 存在
if [ ! -f /config/printers.conf ]; then
    touch /config/printers.conf
fi
cp /config/printers.conf /etc/cups/printers.conf

# 启动 printer-update 监控
/root/printer-update.sh &

# 启动 dbus
if ! pgrep -x dbus-daemon >/dev/null; then
    service dbus start
fi

# 清理 Avahi PID 文件，避免重复启动失败
if [ -f /var/run/avahi-daemon/pid ]; then
    rm -f /var/run/avahi-daemon/pid
fi

# 启动 Avahi
service avahi-daemon start

# 等待 Avahi 完全启动
sleep 2
if ! pgrep -x avahi-daemon >/dev/null; then
    echo "Avahi daemon failed to start"
    exit 1
fi

# 启动 CUPS 守护进程
exec /usr/sbin/cupsd -f

