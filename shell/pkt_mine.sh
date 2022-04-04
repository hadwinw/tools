#!/usr/bin/bash

if [ ! -f $tempdir/system_info.sh ] ;then
	curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/system_info.sh  -o $tempdir/system_info.sh
fi
source $tempdir/system_info.sh
basic_system_info
[ $cpu_count -eq 1 ] && mine_count=$cpu_count || mine_count=$((cpu_count-1))


pkt_url=https://github.com/cjdelisle/packetcrypt_rs/releases/download/packetcrypt-v0.5.1/packetcrypt-v0.5.1-linux_amd64
pkt_path=/usr/local/bin/packetcrypt
run_user=packetcrypt

if [ ! -f $pkt_path ]; then
	echo "$(_green 正在下载packetcrypt...)"
	curl -s -o $pkt_path -L $pkt_url
	echo "$(_green packetcrypt已下载)"
	chmod a+x $pkt_path
fi

useradd -r -M -s `which nologin` $run_user

cat > /etc/systemd/system/packetcrypt.service << EOF
[Unit]
Description=Pkt Cash
After=network.target nss-lookup.target

[Service]
User=$run_user
ExecStart=$pkt_path ann -p pkt1q4vkqymrwsshlkmv8wyrexq3q7cna8zh8ld2lx9 http://pool.pktpool.io http://pool.pkt.world http://p.master.pktdigger.com -t $mine_count
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

systemctl is-enabled packetcrypt > /dev/null || systemctl enable packetcrypt
systemctl is-active packetcrypt > /dev/null && systemctl restart packetcrypt || systemctl start packetcrypt
