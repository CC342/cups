#!/bin/sh
set -e
set -x

#  
if [ $(grep -ci $CUPSADMIN /etc/shadow) -eq 0 ]; then
    useradd -r -G lpadmin -M $CUPSADMIN 
fi
echo $CUPSADMIN:$CUPSPASSWORD | chpasswd


mkdir -p /config/ppd
mkdir -p /services

# PPD 
rm -rf /etc/cups/ppd
ln -s /config/ppd /etc/cups

# printers.conf 
if [ ! -f /config/printers.conf ]; then
    touch /config/printers.conf
fi
cp /config/printers.conf /etc/cups/printers.conf

#  printer-update.sh  printers.conf
/root/printer-update.sh &

#  D-Bus
if ! pgrep -x dbus-daemon >/dev/null; then
    service dbus start
fi

#  Avahi PID  Avahi Daemon
if [ -f /var/run/avahi-daemon/pid ]; then
    rm -f /var/run/avahi-daemon/pid
fi
service avahi-daemon start
sleep 2
if ! pgrep -x avahi-daemon >/dev/null; then
    echo "Avahi daemon failed to start"
    exit 1
fi

#  CUPS
exec /usr/sbin/cupsd -f
