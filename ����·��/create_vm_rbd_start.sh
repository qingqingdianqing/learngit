#!bin.bash
choose_image() {
    glance image-list
    read -p "未选择镜像，请选择：" IMG_ID;
    while [ -z $IMG_ID ];do
        read -p "未选择镜像，请选择：" IMG_ID;
    done
    glance image-show $IMG_ID 1>/dev/null 2>/dev/null
   
    if [ $? -ne 0 ]
    then
        echo "镜像 $IMG_ID 不存在，是否重新选择？(y/n)；输入\"q\"退出。"
        retry choose_image
    fi
}
choose_flavor() {
    nova flavor-list
    read -p "未选择规格，请选择：" FLV_ID;
    while [ -z $FLV_ID ];do
        read -p "未选择规格，请选择：" FLV_ID;
    done
    nova flavor-show $FLV_ID 1>/dev/null 2>/dev/null
   
    if [ $? -ne 0 ]
    then
        echo "规格 $FLV_ID 不存在，是否重新选择？(y/n)；输入\"q\"退出。"
        retry choose_flavor
    fi
}
choose_network() {
    neutron net-list
    read -p "未选择网络，请选择：" NET_ID;
    while [ -z $NET_ID ];do
        read -p "未选择网络，请选择：" NET_ID;
    done
    neutron net-show $NET_ID 1>/dev/null 2>/dev/null
   
    if [ $? -ne 0 ]
    then
        echo "网络 $NET_ID 不存在，是否重新选择？(y/n)；输入\"q\"退出。"
        retry choose_network
    fi
}
choose_host() {
    nova-manage service list|grep nova-compute
    read -p "未选择可用域，请选择：" DEST_HOST;
    while [ -z $DEST_HOST ];do
        read -p "未选择可用域，请选择：" DEST_HOST;
    done
    nova-manage service list|grep $DEST_HOST|grep nova-compute|grep enabled|grep ":-)" 1>/dev/null 2>/dev/null
   
    if [ $? -ne 0 ]
    then
        echo "可用域 $DEST_HOST 不存在或不可用，是否重新选择？(y/n)；输入\"q\"退出。"
        retry choose_host
    fi
}
retry() {
    read CHOICE;
    if [ -z $CHOICE ];then
    echo "请输入选择..."
    retry
    elif [ $CHOICE == "q" -o $CHOICE == "n" ];then
        echo "退出"
        exit 0
    elif [ ${CHOICE} == "y" ];then
        echo "进入重新选择..."
        $1
    else
        echo "未知选项，请重新选择(y/n)；输入\"q\"退出。"
        retry
    fi
}
create_vm() {
    read -p "请输入虚拟机名称(默认为：INSTANCE)：" NAME;
    if [ -z $NAME ];then
        NAME="INSTANCE"
    fi
    echo "镜像：$IMG_ID"
    echo "规格：$FLV_ID"
    echo "网络：$NET_ID"
    echo "主机：$DEST_HOST"
    echo "名称：$NAME"
	echo "nova boot --flavor $FLV_ID --block-device source=image,dest=volume,size=200,id=$IMG_ID,bootindex=0 --nic net-id=$NET_ID --availability-zone nova:${DEST_HOST} $NAME"
    nova boot --flavor $FLV_ID --block-device source=image,dest=volume,size=20,id=$IMG_ID,bootindex=0 --nic net-id=$NET_ID --availability-zone nova:${DEST_HOST} $NAME
}
choose_image
choose_flavor
choose_network
choose_host
create_vm

