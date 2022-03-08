#!/usr/bin/env python3

###########################################################
#NAUTILUS_SCRIPT_CURRENT_URI=file:///home/xxx
#NAUTILUS_SCRIPT_SELECTED_URIS=file:///home/xxx/gfw.txt
#NAUTILUS_SCRIPT_SELECTED_FILE_PATHS=/home/xxx/gfw.txt
#INSIDE_NAUTILUS_PYTHON=
#NAUTILUS_SCRIPT_WINDOW_GEOMETRY=1366x736+0+32



'''往clash的配置文件中添加被墙的域名，在倒数第三行位置上添加'''

import os

'''如果是右键使用nautilus就获取NAUTILUS_SCRIPT_SELECTED_FILE_PATHS环境变量的值，终端下使用脚本，就获取当前路径下的文件值'''
if os.getenv('NAUTILUS_SCRIPT_SELECTED_FILE_PATHS', 'null') == 'null':
    gfw_file = os.getcwd()+"/gfw.txt"
    clash_config=os.getcwd()+"/config.yaml"
else:
    gfw_file=os.environ["NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"].replace('\n','')
    clash_config = os.path.dirname(gfw_file)+"/config.yaml"

pre_content = r"- DOMAIN-SUFFIX,"
last_content = r",♻️ 国外流量"

if not os.path.getsize(gfw_file):
    print("文件内没有要添加的域名，程序退出")
    exit(255)

'''读取clash的config.yaml文件所有内容放入clash_config_lines列表中'''
clash_config_lines = []
clash_config_point = open(clash_config,'r')
for clash_config_line in clash_config_point:
    clash_config_lines.append(clash_config_line)
clash_config_point.close()


'''读取gfw.txt文件中的所有域名放入gfw_domians列表中'''
gfw_domains=[]
gfw_file_point = open(gfw_file,'r')
for gfw_domain in gfw_file_point.read().splitlines():
    final_rule=pre_content+gfw_domain+last_content+"\n"
    '''判断域名是否已存在规则列表中，存在则跳过'''
    if final_rule in clash_config_lines:
        continue
    gfw_domains.append(final_rule)
gfw_file_point.close()


for gfw_domain in gfw_domains:
    clash_config_lines.insert(-2,gfw_domain)


'''重新写入clash的config.yaml文件中'''
clash_config_line=''.join(clash_config_lines)
clash_config_point = open(clash_config,'w')
print("正在添加域名...")
clash_config_point.write(clash_config_line)
print("域名添加完毕")
clash_config_point.close()


with open(gfw_file, 'w') as file:
    file.truncate(0)
