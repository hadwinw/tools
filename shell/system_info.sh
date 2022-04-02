#!/usr/bin/bash
[ $(id -u) != "0" ] && { echo "你当前不是以root权限执行,请以root权限执行脚本"; exit 1; }

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


function baisc_system_info(){
	cpu_name=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	cpu_count=$( awk -F: '/processor/ {core++} END {print core}' /proc/cpuinfo )
	#freq=$( awk -F'[ :]' '/cpu MHz/ {print $4;exit}' /proc/cpuinfo )
	#ccache=$( awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	py_mem=$( LANG=C; free -m | awk '/Mem/ {print $2}' )
	py_use_mem=$( LANG=C; free -m | awk '/Mem/ {print $3}' )
	sw_mem=$( LANG=C; free -m | awk '/Swap/ {print $2}' )
	sw_use_mem=$( LANG=C; free -m | awk '/Swap/ {print $3}' )
	#up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
	#disk
	local_ip=`ip a | awk '/inet/' | awk '/global/ {printf $2"   " }'`	
}

<<<<<<< HEAD
external_system_info(){
=======
function external_system_info(){
>>>>>>> dev
	external_ip=`curl -sL ipinfo.io/ip`
	location=`curl -sL ipinfo.io/city`	
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
		echo "$_red 目前暂不支持你所使用的系统，sorry"
	fi
}

function dependence(){
	pkg_method
	$pkg_install $1
}


function system_info_print(){
	baisc_system_info
	os_info
	external_system_info
	echo "cpu               :  $(_green "$cpu_name")"
	echo "cpu核心           :  $(_green "$cpu_count")"
	echo "物理内存          :  $(_green "$py_mem")"
	echo "虚拟内存          :  $(_green "$sw_mem")"
	echo "磁盘容量          :  $(_green "$disk")"
	echo "系统              :  $(_green "$os")"
	echo "系统版本          :  $(_green "$os_version")"
	echo "系统基于          :  $(_green "$os_like")"
	echo "系统架构          :  $(_green "$os_arch")"
	echo "系统内核          :  $(_green "$os_kernel")"
	echo "本机ip信息        :  $(_green "$local_ip")"
	echo "外部显示ip        :  $(_green "$external_ip")"
	echo "机器位置          :  $(_green "$location")"
}

#system_info_print
