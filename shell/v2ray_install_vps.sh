#!/usr/bin/bash
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }
[ -z $1 ] &&  echo "The script need a domain for caddy, eg: $0 DOMAIN" && exit 1;
domain=$1

if [ -f /etc/redhat-release ];then
    pkg_install='yum install -y'
	OS='centos_like'
elif [ ! -z "`cat /etc/issue | grep -E 'bian|Ubuntu'`" ];then
    pkg_install='apt install -y'
	OS='debian_like'
else
    echo "Not support OS, Please reinstall OS and retry!"
    exit 1
fi

function deps_install(){
	if [ $OS = 'centos_like' ];then
		$pkg_install curl emacs-nox  yum-plugin-copr
	elif [ $OS = 'debian_like' ];then
		apt update
		$pkg_install curl emacs-nox debian-keyring debian-archive-keyring apt-transport-https
	fi	
}

function v2ray_install(){
	bash <(curl -L https://raw.githubusercontents.com/v2fly/fhs-install-v2ray/master/install-release.sh)
    bash <(curl -L https://raw.githubusercontents.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)
}


v2ray_config(){
	domain="$1"
	cat > /usr/local/etc/v2ray/config.json <<EOF
{
    "log": {
	"loglevel": "none"
    },
    "inbounds": [
       {
            "port": 10808,
            "listen":"127.0.0.1",
            "protocol": "vmess",
            "settings": {
		"clients": [
		    {
			"id": "0fd36365-2d5d-45c9-a5dc-6bba190cd536",
			"alterId": 0
		    }
		]
            },
            "streamSettings": {
		"network": "ws",
		"wsSettings": {
		    "path": "/ws"
		}
            }
	   },
	{
	    "port": "10809",
	    "listen": "127.0.0.1",
	    "domainOverride": ["http", "tls"],
	    "protocol": "vmess",
	    "settings": {
		"clients": [
		    {
			"id": "0fd36365-2d5d-45c9-a5dc-6bba190cd536",
			"alterId": 0
		    }
		]
	    },
	    "streamSettings": {
		"network": "h2",
		"httpSettings": {
		    "path": "/h2c",
		    "host": [
			"$domain"
		    ]
		}
	    }
	}
    ],
    "outbounds": [
	{
	    "protocol": "freedom",
	    "settings": {}
	}
    ]
}

EOF

	systemctl restart v2ray
}


caddy_install(){
	if [ $OS = 'centos_like' ];then
		yum copr -y enable @caddy/caddy
		$pkg_install caddy
	elif [ $OS = 'debian_like' ];then
		curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | tee /etc/apt/trusted.gpg.d/caddy-stable.asc
		curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
		apt update
		$pkg_install caddy
	fi
	
}


caddy_config(){
	domain="$1"
    
    cat > /etc/caddy/Caddyfile <<EOF
{
	admin off
	log {
	    output discard
	    level ERROR
	}
}
https://$domain {
	root * /usr/share/caddy
	file_server

	@v2ray_ws {
		path /ws
		header Connection Upgrade
		header Upgrade websocket
	}
	reverse_proxy @v2ray_ws localhost:10808
	
	reverse_proxy /h2c localhost:10809 {
		transport http {
			versions h2c
		}
	}
}
EOF

    systemctl restart caddy
}





deps_install
v2ray_install
v2ray_config $domain
caddy_install
caddy_config $domain
