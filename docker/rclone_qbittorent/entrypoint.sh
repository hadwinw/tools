#!/bin/bash

# entrypoint.sh
qbittorrent-nox --daemon --save-path=/down --add-paused=true --webui-port=9000
rclone rcd --rc-web-gui-no-open-browser --rc-addr=:9001 --rc-user=hadwin --rc-pass=Zrf@Wenyuehua.rc
while true
do
sleep 100
done
