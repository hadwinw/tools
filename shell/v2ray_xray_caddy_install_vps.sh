#!/usr/bin/bash
#[ -f init.sh ] && source init.sh || { echo "init.sh不存在，程序退出" ; exit 1; }
[ -z $1 ] &&  echo "$(_red "The script need a domain for caddy, eg: "$0 DOMAIN"")" && exit 1;
domain=$1

function deps_install(){
	if [ $os_like = 'rhel' ];then
		$pkg_install curl emacs-nox  yum-plugin-copr tree
	elif [ $os_like = 'debian' ];then
		apt update
		$pkg_install curl emacs-nox debian-keyring debian-archive-keyring apt-transport-https tree
	fi	
}

function v2ray_install(){
	useradd -r -M -s `which nologin` v2ray
	bash <(curl -L https://raw.githubusercontents.com/v2fly/fhs-install-v2ray/master/install-release.sh)
    bash <(curl -L https://raw.githubusercontents.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)
	sed -i 's@User=nobody@User=v2ray@g' /etc/systemd/system/v2ray.service
	sed -i 's@User=nobody@User=v2ray@g' /etc/systemd/system/v2ray@.service
	systemctl daemon-reload
}


v2ray_config(){
	domain="$1"
	cat > /usr/local/etc/v2ray/config.json <<EOF
{
    "log": {
		"loglevel": "none",
		"access": "none",
		"error": "none"
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
		},
		{
			"protocol": "blackhole",
			"settings": {},
			"tag": "blocked"
		}
    ],
    "routing": {
		"domainStrategy": "AsIs",
		"rules": [
	    	{
				"type": "field",
				"outboundTag": "blocked",
				"protocol": [
		    		"bittorrent"
				]
			},
			{
				"type": "field",
				"outboundTag": "blocked",
				"ip": [
					"geoip:private"
				]
			}
		]
	}
}
EOF
	
	systemctl restart v2ray
	systemctl enable v2ray
}


xray_install(){
	useradd -r -M -s `which nologin` xray
	bash -c "$(curl -L  https://raw.githubusercontents.com/XTLS/Xray-install/main/install-release.sh)" @ install
	sed -i 's@User=nobody@User=xray@g' /etc/systemd/system/xray.service
	sed -i 's@User=nobody@User=xray@g' /etc/systemd/system/xray@.service
	systemctl daemon-reload
}

xray_config(){
	domain=$1
	cat > /usr/local/etc/xray/config.json << EOF
{
	"log": {
		"loglevel": "none",
		"access": "none",
		"error": "none"
	},
	"inbounds": [
		{
			"port": 10000,
			"listen": "127.0.0.1",
			"protocol": "vless",
			"settings": {
				"clients": [
					{
						"id": "0fd36365-2d5d-45c9-a5dc-6bba190cd536"
					}
				],
				"decryption": "none"
			},
			"streamSettings": {
				"security": "none",
				"network": "h2",
				"httpSettings": {
					"path": "/h2",
	    			"host":
					[
						"$domain"
					]

				}
			}
		}
	],
	"outbounds": [
		{
			"tag": "direct",
			"protocol": "freedom",
			"settings": {}
		},
		{
			"tag": "blocked",
			"protocol": "blackhole",
			"settings": {}
		}
	],
	"routing": {
		"domainStrategy": "AsIs",
		"rules": [
			{
				"type": "field",
				"outboundTag": "blocked",
				"protocol": [
		    		"bittorrent"
				]
			},
			{
				"type": "field",
				"outboundTag": "blocked",
				"ip": [
					"geoip:private"
				]
			}
		]
	}
}

EOF
	
	systemctl restart xray
	systemctl enable xray
}


caddy_install(){
	if [ $os_like = 'rhel' ];then
		yum copr -y enable @caddy/caddy
		$pkg_install caddy
	elif [ $os_like = 'debian' ];then
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

	reverse_proxy /h2 localhost:10000 {
		transport http {
			versions h2c
		}
	}

}
EOF

    systemctl restart caddy
	systemctl enable caddy
}


deps_install
v2ray_install
v2ray_config $domain
xray_install
xray_config $domain
caddy_install
caddy_config $domain