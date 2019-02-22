#! /bin/sh
# Program
#      install shadowsocks and set config
# Histroy
#	2019/2/15    Declr    version 1.dev

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

###################################
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


##########################################
#	Check denpendency
##########################################
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
        curl "$pip_dir" > get-pip.py && python get-pip.py
        sudo pip install shadowsocks
fi


##########################################
#	check ssserver start?
##########################################
ps_return=`ps -ef`
echo $ps_return|grep -q ssserver
if [ "$?" == "1" ];
then
    # use function create_config() to create config
    create_config
    # start ssserver
    sudo ssserver -c "/etc/shadowsocks.json" start
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

##########################################
#		rd.rclocal
###########################################
#cat << EOF |sudo tee -a $ss_rd
#sudo nohup ssserver -c "/etc/shadowsocks.json" start &
#EOF



