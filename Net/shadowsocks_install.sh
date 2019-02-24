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
ss_sport=20883
ss_lport=1080
ss_pocotol=aes-256-cfb
ss_name=`hostname`
ss_pwd=HACK_$ss_name
pip_dir="https://bootstrap.pypa.io/get-pip.py"
local_ip=`ip route get 1 | cut -d " " -f7`

#### create shadowsocks' config file #####
create_config(){
        echo " creat shadowsocks.json"
        cat > $ss_config  << EOF
        {
        "server":"$local_ip",
        "server_port":"$ss_sport",
        "local_port":"$ss_lport",
        "password":"$ss_pwd",
        "timeout":600,
        "method":"$ss_pocotol"
        }
EOF
        echo " creat ok"
}

#### set help message about more arguments"
arguments_message(){  
    echo -e "\033[31m help : \033[0m"
    echo "     for help"
    echo -e "\033[31m install : \033[0m"
    echo "      install shadowsocks"
    echo -e "\033[31m uninstall : \033[0m"
    echo "      uninstall shadowsocks "
}

####	unistall shadowsocks   #############
uninstall_shadowsocks(){
    sudo pip uninstall shadowsocks
}

#### Check denpendency ####################
check_denpendency(){
    file=`whereis ssserver | cut -d ":" -f2`
    test -n "$file" && result=0 || result=1
    if [ $result == 0 ];
    then
        echo "you already had ssserver $file"
        echo "jum ssserver install"
    else
        ssserver_q="Notinstall"
        echo "install pip now"
	# download pip & shadowsocks
        curl "$pip_dir" > /var/get-pip.py && python /var/get-pip.py
        sudo pip install shadowsocks
	sleep 5
     fi
}

####	check ssserver start? #############
check_start(){
    ps_return=`ps -ef`
    echo $ps_return|grep -q ssserver
    if [ "$?" == "1" ];
    then
        # use function create_config() to create config
        echo "create_config"
        create_config
        # start ssserver
        sudo nohup ssserver -c "/etc/shadowsocks.json" start >/dev/null 2>/var/sslog &
        sleep 5
        n_ps_return=`ps -ef`
        echo $n_ps_return|grep -q ssserver
        if [ "$?" == "0" ];
        then
            echo " start shadowsocks filed"
        else
            echo " ERROR"
            echo " start shadowsocks filed check it!"
        fi
    else
        echo " you already runing shadowsocks"
    fi
}

#####	change rd.rclocal #####################
check_rd(){
    s=`cat /etc/rc.local |grep ssserver|cut -d " " -f3`
    if [ "$s" == "ssserver" ];
    then
        echo "your already set up start for power on"
    else
        echo "create start with power on"
        cat > /etc/rc.local << EOF
        sudo nohup ssservice -c "/etc/shadowsocks.json" start &
EOF
    fi
}


##########################################
#	main
##########################################
if [ "$#" -gt "0" ];then
    if [ "$1" == "h" ] || [ "$1" == "--help" ] || [ "$1" == "help" ];then
         arguments_message
    elif [ "$1" == "install" ];then
         check_denpendency
         check_start
         check_rd
    elif [ "$1" == "uninstall" ];then
         uninstall_shadowsocks
    else
         arguments_message
    fi
fi

