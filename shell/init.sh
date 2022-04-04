#!/usr/bin/bash

#### 定义输出颜色，github上炒回来的
_red() {
    printf '\033[0;31;31m%b\033[0m' "$1"
}

_green() {
    printf '\033[0;31;32m%b\033[0m' "$1"
}

_yellow() {
    printf '\033[0;31;33m%b\033[0m' "$1"
}

_blue() {
    printf '\033[0;31;36m%b\033[0m' "$1"
}

[ $(id -u) != "0" ] && { echo "$(_red 你当前不是以root权限执行,请以root权限执行脚本)"; exit 1; }

function main(){
	echo "0. 显示系统信息"
	echo "1. 调用system_init"
	echo "2. 调用v2ray_xray_caddy_tls"
	echo "3. 调用sergateClient"
	echo "4. 调用fscarmen的warp脚本"
	echo "5. pkt.cash挖矿"
	echo "6. peer2profit流量"
	echo "q. 退出脚本"
}

export tempdir="/tmp/tempinstall"
mkdir -p $tempdir
while true
do
	main
	read -p "$(_blue 你的选择: )" choice
	case $choice in
		0)
			#dependence curl
			if [ -f $tempdir/system_info.sh ] ;then
				source $tempdir/system_info.sh
			else
				curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/system_info.sh  -o $tempdir/system_info.sh && source $tempdir/system_info.sh
			fi
			system_info_print
			;;
		1)
			#dependence curl
			curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/system_init.sh | bash
			;;
		2)
			#dependence curl
			curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/v2ray_xray_caddy_install_vps.sh -o $tempdir/v2ray_xray_caddy_install_vps.sh
			read -p "$(_blue 请提供一个域名: )" domain
			bash $tempdir/v2ray_xray_caddy_install_vps.sh $domain
			;;
		3)
			echo "3"
			;;
		4)
			curl -so $tempdir/menu.sh -L https://raw.githubusercontents.com/fscarmen/warp/main/menu.sh && bash $tempdir/menu.sh d
			;;
		5)
			curl -so $tempdir/pkt_mine.sh -L https://gitlab.com/hadwinw/tools/-/raw/main/shell/pkt_mine.sh && bash $tempdir/pkt_mine.sh
			;;
		6)
			curl -so $tempdir/peer2profit.sh -L https://gitlab.com/hadwinw/tools/-/raw/main/shell/peer2profit.sh && bash $tempdir/peer2profit.sh
			;;
		'q')
			echo "$(_blue 已清除临时文件.)" && rm -rf $tempdir
			exit 1
			;;
		*)
			echo "$(_red 输入错误,请重新输入)"
			;;
	esac
done	 
