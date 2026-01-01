#!/bin/sh
set -e
set -x

# 创建管理员
if [ "$(grep -ci "$CUPSADMIN" /etc/shadow)" -eq 0 ]; then
    useradd -r -G lpadmin -M "$CUPSADMIN"
fi
echo "$CUPSADMIN:$CUPSPASSWORD" | chpasswd

# 目录
mkdir -p /config/ppd /services

rm -rf /etc/cups/ppd
ln -s /config/ppd /etc/cups

[ -f /config/printers.conf ] || touch /config/printers.conf
cp /config/printers.conf /etc/cups/printers.conf

# dbus
if ! pgrep -x dbus-daemon >/dev/null; then
    service dbus start
fi

# avahi
rm -f /var/run/avahi-daemon/pid || true
service avahi-daemon start
sleep 2

# ⭐ 关键：先启动 CUPS（后台）
/usr/sbin/cupsd

# 等待 CUPS socket 就绪
for i in $(seq 1 10); do
    if lpstat -r >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

# ⭐ 现在再生成 AirPrint（此时 cups.Connection 才会成功）
/root/printer-update.sh

# 最后把 CUPS 拉到前台（容器不退出）
exec /usr/sbin/cupsd -f

