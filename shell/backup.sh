#!/usr/bin/bash



[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

backup_date=`date '+%Y%m%d'`

# 修改为需要备份的目录路径和文件路径
backup_paths=('/etc' \
				  ''
				  ''
			 )

function dir_backup(){
	tar cpJf backup_$backup_date.tar.xz `echo ${backup_paths[@]}`
}

function mysql_backup(){
	if dpkg -l mariadb-server >/dev/null 2>&1  ;then
		mysqldump -uroot --all-databases > mariadb_$backup_date.sql
	fi
}


work_path=/tmp
cd $work_path
mysql_backup
dir_backup
