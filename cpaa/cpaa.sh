#!/bin/bash
# 一键安装 aria ， AriaNg ， python-flask
# Powerd by Deblr
# Set time : 2019.03.01

# local ip
local_ip=`hostname -I |cut -d " " -f1`
# set help
function cpaa_help(){
    echo "-----------------------------------------"
    echo -e "\033[32m 请以管理员身份运行该脚本 \033[0m"
    echo "1. 安装cpaa"
    echo "2. 卸载cpaa"
    echo "3. 更新bt"
    echo "q. 退出"
}

# 检查环境和依赖
function check_Env(){
    # 检查unzip
    unzip > /dev/null 2>&1
    if [ $? == "0" ];then
        echo -e " check unzip      [\033[32m OK \033[0m]"
    else
        echo -e " Download unzip "
        yum install unzip
        echo -e " Download unzip        [\033[32m OK \033[0m]"
    fi
    # 检查pip
    pip > /dev/null 2>&1
    if [ $? == "0" ];then
        echo -e " check pip      [\033[32m OK \033[0m]"
    else
        echo -e " Install pip"
        wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
        python get-pip.py
        echo -e " Install pip \t\t\t\t\t\t  [\033[32m  OK  \033[0m]"
        sudo rm -rf get-pip.py
    fi
    #创建运行目录，并进入
    user_local=`users |cut -d ' ' -f1`
    sudo test -e /etc/cpaa && echo "you already have /etc/cpaa" || mkdir /etc/cpaa
    sudo test -e /web/pyweb && echo "you already have /web/pyweb" || mkdir -p /web/pyweb
    sudo chown $user_local /etc/cpaa /web/pyweb
    sudo chgrp $user_local /etc/cpaa /web/pyweb
    cp index.html /web/pyweb/index.html
    cp index.py /web/pyweb/index.py
}

# 安装 aria2
function install_aria2(){
    sudo yum install -y epel-release
    echo "--------------------------"
    echo " Install aria2"
    yum install -y aria2
    if [ ! -f "/usr/bin/aria2c" ];then
        wget -c http://soft.xiaoz.org/linux/aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2
		tar jxvf aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2
		cd aria2-1.34.0-linux-gnu-64bit-build1
		make install
		cd ..
    fi
}

# 安装 AriaNg all in one 版本
#function install_AriaNg(){
#    echo "--------------------------"
#    echo " Install AriaNg"
#    wget -O /etc/cpaa/AriaNg.zip https://github.com/mayswind/AriaNg/releases/download/1.0.1/AriaNg-1.0.1-AllInOne.zip
#    unzip /etc/cpaa/AriaNg.zip
#    rm -rf /etc/cpaa/AriaNg.zip
#}


# 安装 python-flask
function install_flask(){
    echo "--------------------------"
    echo -e " Install flask"
    sudo pip install flask
}

# 设置运行文件
function set_config(){
    # 设置 aria 相关文件
    cp aria2.conf /etc/cpaa/aria2.conf
    touch /etc/cpaa/aria2.session
    touch /etc/cpaa/aria2.log
    # 设置 py 文件
    cp index.py /web/pyweb
    # 开放防火墙
    sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
    sudo firewall-cmd --reload
}

# 定制化操作
function customize_set(){
    # 设置引导
    echo "---------------------------------------------"
    read -p "设置自定义文件的默认地址,默认地址为/data: " downpath
    read -p "设置aria secret: " secret
    if [ -z "$downpath" ];then
        downpath="/data"
    fi
    while [ -z "$secret" ];do
        read -p "请输入aria secret: " secret
    done
    # 更改文件
    mkdir -p $downpath
    sed -i "s%dir=%dir=${downpath}%g" /etc/cpaa/aria2.conf
    sed -i "s/rpc-secret=/rpc-secret=${secret}/g" /etc/cpaa/aria2.conf
}

# 设置显示
function customzie_view(){
    echo "------------------------------------------"
    echo -e " 请访问 地址 \033[32m $local_ip \033[0m"
    echo -e " 定义的下载文件默认目录为 \033[32m $downpath \033[0m "
    echo -e " aria secret 为: \033[32m $secret \033[0m"
}

# 卸载并清空程序
function uninstall_cpaa(){
        a_pid=`pgrep aria2c`
        py_pid=`ps -ef|grep index|head -n 1|cut -d " " -f7`
        sudo kill -9 $a_pid
        sudo kill -9 $py_pid
        sudo yum remove aria2
        rm -rf /etc/cpaa
        rm -rf /web
}

# main 程序
cpaa_help
read -p ":" input_para
case $input_para in
    "1")
        check_Env
        install_aria2
#        install_AriaNg
        install_flask
        set_config
        customize_set
        customzie_view
        nohup aria2c --conf-path=/etc/cpaa/aria2.conf > /etc/cpaa/aria2.log 2>&1 &
        nohup python index.py $local_ip &
        ;;
    "2")
        uninstall_cpaa
        ;;
    "3")
        echo "暂时不支持"
        ;;
    "help")
        cpaa_help
        ;;
    "q")
        exit
        ;;
    *)
        cpaa_help
        ;;

esac