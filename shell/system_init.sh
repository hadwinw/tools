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
	if [ $os_like = 'rhel' -a $os_version = '7' ];then
		$pkg_install wget
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
	if [ $os_like = 'rhel' ] ;then
		$pkg_remove rsyslog* logrotate
		sed -i 's@#Storage=auto@Storage=none@g' /etc/systemd/journald.conf
		systemctl restart systemd-journald.service
		### 暂时缺少centos版本噶journald关闭
	elif [ $os_like = 'debian' ] ;then
		$pkg_remove rsyslog* logrotate
		sed -i 's@#Storage=auto@Storage=none@g' /etc/systemd/journald.conf
		systemctl restart systemd-journald.service
	fi
	rm -rf /var/log/*
}


function remove_pkg(){
	if [ $os_like = 'rhel' ];then
		$pkg_remove man-db exim4* vim vim-common vim-minimal postfix
	elif [ $os_like = 'debian' ]; then
		$pkg_remove man-db exim4* vim vim-common vim-tiny postfix
		apt autopurge -y
	fi
}

if [ -f $tempdir/system_info.sh ] ;then
	source $tempdir/system_info.sh
	pkg_method
else
	curl -sL https://gitlab.com/hadwinw/tools/-/raw/main/shell/system_info.sh  -o $tempdir/system_info.sh && source $tempdir/system_info.sh
	pkg_method
fi


sshd_reset
bbr_start
emacs_init
disable_log
remove_pkg
