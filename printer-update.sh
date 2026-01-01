#!/bin/sh
set -e
set -x

# 生成 AirPrint avahi service 文件
python /root/airprint-generate.py \
  --directory /services \
  --prefix AirPrint-

# 通知 avahi 重新加载（如果已运行）
if pgrep -x avahi-daemon >/dev/null; then
    avahi-daemon --reload || true
fi

