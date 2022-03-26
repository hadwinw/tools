#!/usr/bin/bash



[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

backup_date=`date '+%Y%m%d'`

# 修改为需要备份的目录路径和文件路径
backup_paths=('/etc/caddy' '/usr/share/caddy' '/etc/php' '/etc/mysql' \
						   '/etc/mopidy/mopidy.conf' '/etc/icecast2' '/etc/default/icecast2' \
						   '/etc/systemd/system/v2ray.service' '/usr/local/etc/v2ray' \
						   '/etc/systemd/system/xray.service' '/usr/local/etc/xray' \
						   '/etc/systemd/system/trojan-go.service' '/usr/loca/etc/trojan' \
						   '/etc/systemd/system/subconverter.service' '/usr/local/subconverter' \
						   '/etc/sergate' '/etc/systemd/system/sergateClient.service' '/etc/systemd/system/sergate.service' \
						   '/etc/ssh/sshd_config' '/etc/ssh/ssh_config' \
						   '/etc/jellyfin' '/var/lib/jellyfin' \
						   '/etc/sysctl.conf' \
						   '/etc/ipsec.conf' '/etc/ipsec.secrets'
			 )

file_dir_exits(){
	arr_len=${#backup_paths[@]}
	for((i=1;i<=$arr_len;i++))
	do
		if [[ ! -e ${backup_paths[$i]} ]]
		then
			unset backup_paths[$i]
		fi
	done
}

function dir_backup(){
	tar cPpJf backup_$backup_date.tar.xz `echo ${backup_paths[@]}`
}

function mysql_backup(){
	if dpkg -l mariadb-server >/dev/null 2>&1  ;then
		mysqldump -uroot --all-databases > mariadb_$backup_date.sql
	fi
}

function iptables_backup(){
	
}


work_path=/tmp/backup
mkdir -p $work_path
cd $work_path
mysql_backup
file_dir_exits
dir_backup
iptables_backup
