#!/usr/bin/bash

### 关闭ssh的密码登录功能，只允许使用密钥登录
function sshd_reset(){
	mkdir -p $HOME/.ssh
	cat > $HOME/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJ9ua/c7C/xCZz41e7mtSm9QfIgaEFm5yQS+tBFpk5cl38SY06w/ZPjHYPoR+4IWAsYItc8t8r0zr8Lifdq9706/mspM+UxA3kYDtHz2CUEjiDGwolY3cLeTRMDnLPr2OYHPpNJEsTd2Vxtn2imT1p4VnMkwOaNHoXVe2iKv63vlngsCxsDXOMWdnnGi/8weiWoKUkHUxssEINg5GeD+FY1FY8yy+QO/OB7AAY/FtW6jvRE0sutzhlIn9rph6lidH6KW+mNwt5luE8y+MtAgu7oHR7BkeC0jsJbj+D5LMwoLz9UUdM/LCJhQJpenUwsBm0h+hEDmQr+CVKOjyOlp0F+txkX9ItgRjjYpXGp9gHV98gUSVJBLJE0WkSofxUnYiIns7uxyy+cituaVi9L2Im/y94rQqqqcZ+mdgtWFmTwpcX6tUKMolPx8o4XiwY04W2uZWR4Ehdrr9qVdwQi2kce9GckJOxB9to4JA+pJGvZI2bf1sMpQ2pU/UOR4klAKc= hadwin@debian

EOF
	chmod 600 $HOME/.ssh/authorized_keys
	
	cat > /etc/ssh/sshd_config << EOF
PermitRootLogin yes
MaxAuthTries 3
MaxSessions 3
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
AllowAgentForwarding no
AllowTcpForwarding no
X11Forwarding no
PrintMotd no
PrintLastLog no
ClientAliveInterval 20
ClientAliveCountMax 3
UseDNS no
PermitTunnel no
Banner none
AcceptEnv LANG LC_*
Subsystem	sftp	/usr/lib/openssh/sftp-server

EOF
	systemctl restart sshd
}


function bbr_start(){
	if [ $OS = 'centos_like' -a $OS_VERSION = '7' ];then
		yum install -y wget
		wget --no-check-certificate https://raw.githubusercontents.com/teddysun/across/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh
	else
		cat >> /etc/sysctl.conf << EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

EOF
		sysctl -p
	fi
}


function emacs_init(){
	if [ ! -d $HOME/.emacs.d ];then
		mkdir -p $HOME/.emacs.d
	fi
	cat > $HOME/.emacs.d/init.el <<EOF
(defalias 'yes-or-no-p 'y-or-n-p)
(global-display-line-numbers-mode t)
(column-number-mode 1)
(setq make-backup-files nil)

EOF
}


###关闭rsyslog和systemd-journald.service日志功能
function disable_log(){
	systemctl stop rsyslog
	systemctl disable rsyslog
	if [ $OS = 'centos_like' ];then
		yum erase -y rsyslog* logrotate
	else
		apt purge -y rsyslog* logrotate
		sed -i 's@#Storage=auto@Storage=none@g' /etc/systemd/journald.conf
		systemctl restart systemd-journald.service
	fi
	rm -rf /var/log/*
}


function remove_pkg(){

	if [ $OS = 'centos_like' ];then
		yum earse -y man-db exim4* vim vim-common vim-tiny
	else
		apt purge -y man-db exim4* vim vim-common vim-tiny
		apt autopurge -y
	fi
}


[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: 脚本必须使用root权限${CEND}"; exit 1; }
[ $1 = "" ] && echo "请为主机设置一个主机名，用法$0 HOSTNAME" && exit 1

if [ -f /etc/redhat-release ];then
	OS='centos_like'
	if echo `uname -r` | grep 'el7' ;then
		OS_VERSION='7'
	elif echo `uname -r` | grep 'el8' ;then
		OS_VERSION='8'
	else
		echo "脚本不再支持7以下版本"
		exit 1
	fi
elif [ ! -z "`cat /etc/issue | grep -E 'bian|Ubuntu'`" ];then
	OS='debian_like'
else
	echo "Not support OS, Please reinstall OS and retry!"
	exit 1
fi


sshd_reset
bbr_start
emacs_init
#disable_log
remove_pkg
