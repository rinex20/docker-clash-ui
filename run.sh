#!/bin/sh


if [ -f "/root/clash/entrypoint.sh" ]; then
chmod a+x /root/clash/entrypoint.sh
/root/clash/entrypoint.sh
else 
chmod a+x ./entrypoint.sh
./entrypoint.sh
fi

exec "$@"
