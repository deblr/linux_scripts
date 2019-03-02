#! /bin/sh
# Program
#      install shadowsocks and set config
# Histroy
#	2019/2/15    Declr    version 1.dev

echo "===================================="
echo "# Install/uninstall shadowsocks    #"
echo "# By Deblr                         #"
echo "# Address <kaisen341125@gmail.com> #"
echo "===================================#"


# set variable
ss_config=/etc/shadowsocks.json
ss_rd=/etc/rc.d/rc.local
# ss_sport=20883
ss_lport=1080
ss_pocotol=aes-256-cfb
# ss_name=`hostname`
# ss_pwd=HACK_$ss_name
read -p "请输入自定义密码: " customize_pwd
read -p "请输入自定义服务器端口: " customize_port
pip_dir="https://bootstrap.pypa.io/get-pip.py"
local_ip=`hostname -I |cut -d " " -f1`

#### create shadowsocks' config file #####
function create_config(){
cat > $ss_config  << EOF
{
"server":"$local_ip",
"server_port":"$customize_port",
"local_port":"$local_ip",
"password":"$customize_pwd",
"timeout":600,
"method":"$ss_pocotol"
}
EOF
echo -e " creat \t\t\t\t\t\t\t [\033[32m ok \033[0m] "
}

#### set help message about more arguments"
function arguments_message(){
    echo -e "\033[31m 1) \033[0m 安装shadowsocks"
    echo -e "\033[31m 2) \033[0m 卸载shadowsocks"
    echo -e "\033[31m 3) \033[0m 打扫环境"
    echo -e "\033[31m 4) \033[0m 退出脚本"
}

#### Check denpendency ####################
function install_start_ss(){
    test -e '/usr/sbin/ssserver' && result=0 || result=1
    if [ $result == 0 ];
    then
        s_pid=`pgrep sss`
        sudo kill -9 $s_pid
        echo -e "\033[31m you already had ssserver \033[0m"
    else
        echo "install pip now"
	    # download pip & shadowsocks
        curl "$pip_dir" > /var/get-pip.py && python /var/get-pip.py
        sudo pip install shadowsocks
    fi
	sudo nohup /usr/sbin/ssserver -c /etc/shadowsocks.json
	sleep 5
}

#### check ssserver start? #############
function check_start(){
    pgrep sss
    if [ "$?" == "0" ];
    then
        echo -e " start shadowsocks \t\t\t\t\t\t\t [\033[32m OK \033[0m] "
    else echo -e " start shadowcosks \t\t\t\t\t\t\t [\033[32m FIELD \033[0m]"
    fi
}

#### uninstall & clear ########
function clear(){
    sudo pip uninstall shadowsocks
    rm -rf /etc/shadowsocks*
    rm -rf /usr/sbin/ssserver*
}

#####	change rd.rclocal #####################
function check_rd(){
    s=`cat /etc/rc.local |grep /etc/shadowsocks.json |cut -d " " -f3`
    if [ "$s" == "ssserver" ];
    then
        echo -e " set start with power ON \t\t\t\t\t\t\t [\033[32m 0K \033[0m] "
    else
cat >> /etc/rc.local << EOF
sudo nohup ssserver -c "/etc/shadowsocks.json" start &
EOF
    fi
}

function out_config(){
    echo -e "服务器地址为 :" $local_ip
    echo -e "服务器端口为 :" $customize_port
    echo -e "服务器密码为 :" $customize_pwd
    echo -e "客户端端口为 :" $ss_lport
    echo -e "服务器加密协议为 :" $ss_pocotol
}
##########################################
#	main
##########################################
arguments_message
read -p ":" istype
case $istype in
    "1")
        create_config
        install_start_ss
        check_start
        check_rd
        out_config
        ;;
    "2")
        clear
        ;;
    "3")
        clear
        ;;
    "4")
        exit
        ;;
    *) echo "参数错误"
esac