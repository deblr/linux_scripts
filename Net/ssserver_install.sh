#! /bin/sh
# Program
#      install shadowsocks and set config
# Histroy
#	2019/2/15    Declr    version 1

echo "===================================="
echo "# Install shadowsocks              #"
echo "# By Deblr                         #"
echo "# Address <kaisen341125@gmail.com> #"
echo "===================================#"


# set variable
ss_config=/etc/shadowsocks.json
ss_rd=/etc/rc.d/rc.local
ss_sport=20883
ss_lport=1080
ss_pocotol=aes-256-cfb
ss_name=`hostname`
ss_pwd=HACK_$ss_name
pip_dir="https://bootstrap.pypa.io/get-pip.py"
local_ip=`ip route get 1 | cut -d " " -f7`


# download pip & shadowsocks
curl "$pip_dir" > get-pip.py && python get-pip.py
sudo pip install shadowsocks


#creat ss_config
cat << EOF |sudo tee $ss_config
{
"server":"$local_ip",
"server_port":"$ss_sport",
"local_port":"$ss_lport",
"password":"$ss_pwd",
"timeout":600,
"method":"$ss_pocotol"
}
EOF

# set rc.local for start
cat << EOF |sudo tee -a $ss_rd
sudo nohup ssserver -c "$ss_config" start &
EOF

# start ssserver
sudo nohup ssserver -c "$ss_config" start &


