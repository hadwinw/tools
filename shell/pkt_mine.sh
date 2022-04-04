#!/usr/bin/bash

if [ -f $tempdir/system_info.sh ] ;then
	source $tempdir/system_info.sh
else
	curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/system_info.sh  -o $tempdir/system_info.sh && source $tempdir/system_info.sh
fi


pkt_url=https://github.com/cjdelisle/packetcrypt_rs/releases/download/packetcrypt-v0.5.1/packetcrypt-v0.5.1-linux_amd64
pkt_path=/usr/local/bin/packetcrypt
run_user=packetcrypt

if [ ! -f $pkt_path ]; then
	echo "$(_blue 正在下载packetcrypt...)"
	curl -s -o $pkt_path -L $pkt_url
	echo "$(_blue packetcrypt已下载)"
	chmod a+x $pkt_path
fi

useradd -r -M -s `which nologin` $run_user

cat > /etc/systemd/system/packetcrypt.service << EOF
[Unit]
Description=Pkt Cash
After=network.target nss-lookup.target

[Service]
User=$run_user
ExecStart=$pkt_path ann -p pkt1q4vkqymrwsshlkmv8wyrexq3q7cna8zh8ld2lx9 http://pool.pktpool.io http://pool.pkt.world http://p.master.pktdigger.com
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

systemctl is-enabled packetcrypt  || systemctl enable packetcrypt
systemctl is-active packetcrypt && systemctl restart packetcrypt || systemctl start packetcrypt
