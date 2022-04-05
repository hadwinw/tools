#!/usr/bin/bash

if [ ! -f $tempdir/system_info.sh ] ;then
	curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/system_info.sh  -o $tempdir/system_info.sh
fi
source $tempdir/system_info.sh
os_info

#[ ! $os_like = 'debian' ] && { echo "$(_red peer2profit的命令客户端目前只提供了deb包,你的系统不支持)"; exit 1; }

client_url="https://updates.peer2profit.io/p2pclient_0.56_amd64.deb"
client=${client_url##*/}
curl -so $tempdir/$client -L $client_url

pkg_method
if [ $os_like = 'rhel' ]; then
	$pkg_install alien
	cd $tempdir
	alien -r $client
	################怎么可以使用pkg_install方式呢
	rpm -ivh p2pclient*.rpm
	cd -
else
	$pkg_install $tempdir/$client
fi


run_user=p2pclient
useradd -r -M -s `which nologin` $run_user

cat > /etc/systemd/system/p2pclient.service << EOF
[Unit]
Description=Peerprofit Client
After=network.target nss-lookup.target

[Service]
User=$run_user
ExecStart=p2pclient --login overroadpass@gmail.com
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

systemctl is-enabled p2pclient > /dev/null || systemctl enable p2pclient
systemctl is-active p2pclient > /dev/null && systemctl restart p2pclient || systemctl start p2pclient
