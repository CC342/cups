#!/bin/bash
# /usr/local/bin/proxy.sh

USER="user"
PASS="pass"
PROXY_HTTP="http://$USER:$PASS@192.168.123.x:78"
PROXY_SOCKS="socks5://$USER:$PASS@192.168.123.x:79"

case "$1" in
  on)
    export http_proxy=$PROXY_HTTP
    export https_proxy=$PROXY_HTTP
    export all_proxy=$PROXY_SOCKS
    echo "✅ Proxy 已开启"
    echo "HTTP Proxy: $PROXY_HTTP"
    echo "SOCKS Proxy: $PROXY_SOCKS"
    ;;
  off)
    unset http_proxy
    unset https_proxy
    unset all_proxy
    echo "❌ Proxy 已关闭"
    ;;
  *)
    echo "用法: $0 {on|off}"
    exit 1
    ;;
esac
