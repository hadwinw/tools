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
	echo "4. 安装pagermaid"
	echo "q. 退出脚本"
}

function os_get(){
	[ -f /etc/redhat-release ] && awk '{print $0}' /etc/redhat-release && return
	[ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
	[ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
function os_like_get(){
	[ -f /etc/os-release ] && os_like=`awk -F'[= "]' '/^ID/{print $2}' /etc/os-release`
	if [ $os_like = 'debian' ] ;then
		echo $os_like
	else 
		awk -F'[= "]' '/ID_LIKE/{print $2}' /etc/os-release && return
	fi
}
function os_version_get(){
	[ -f /etc/os-release ] && awk -F'[= "]' '/VERSION_ID/{print $3}' /etc/os-release && return
}

function os_info(){
	os=`os_get`
	os_version=`os_version_get`
	os_like=`os_like_get`
	os_arch=`uname -m`
	os_kernel=`uname -r`	
}

function pkg_method(){
	os_info
	if [ $os_like = 'rhel' ];then
		pkg_install="yum install -y"
		pkg_remove="yum remove -y"
	elif [ $os_like = 'debian' ];then
		pkg_install="apt install -y"
		pkg_remove="apt purge -y"
	else
		echo "$(_red 目前暂不支持你所使用的系统，sorry)"
	fi
}

function dependence(){
	pkg_method
	$pkg_install $1
}


export tempdir="/tmp/tempinstall"
mkdir -p $tempdir
while true
do
	main
	read -p "$(_blue 你的选择: )" choice
	case $choice in
		0)
			dependence curl
			curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/system_info.sh  -o $tempdir/system_info.sh && source $tempdir/system_info.sh
			system_info_print
			;;
		1)
			dependence curl
			curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/system_init.sh | bash
			;;
		2)
			dependence curl
			curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/v2ray_xray_caddy_install_vps.sh -o $tempdir/v2ray_xray_caddy_install_vps.sh
			read -p "$(_blue 请提供一个域名: )" domain
			bash $tempdir/v2ray_xray_caddy_install_vps.sh $domain
			;;
		3)
			echo "3"
			;;
		4)
			echo "4"
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
