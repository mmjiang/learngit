#!/bin/bash

NUM=$(ifconfig -a | grep HWaddr | cut -c 1-10)

echo $NUM | tee -a /root/eth_log.txt 

nic_driver=mlx4_en

echo "Start to find a driver that matches the given driver..." | tee  /root/eth_log.txt 

# echo $nic_driver 

r_driver=""
for currentNum in $NUM
do
        echo $currentNum | tee -a /root/eth_log.txt 

        str=`ethtool -i $currentNum | grep driver | cut -d ":" -f 2`
        echo $str | tee -a /root/eth_log.txt 


        if [ $str == $nic_driver ];then
                echo "Find a driver $currentNum that matches $nic_driver" | tee -a /root/eth_log.txt 
                r_driver=${r_driver:-$currentNum}
                break
        fi
done

echo "r_driver = $r_driver"

if [ $r_driver ];then
        ifconfig $r_driver up && dhclient $r_driver
        inetIP=`ifconfig $r_driver | grep "inet addr" |sed 's/^.*addr://g' | sed 's/Bcast.*$//g'`

        sleep 10s
        ping 192.168.1.254 | tee -a /root/eth_log.txt 

        ifconfig $r_driver hw ether F4:52:14:10:A1:81 | tee -a /root/eth_log.txt 

        sleep 10s
        ping 192.168.1.254 | tee -a /root/eth_log.txt 



        ifconfig $r_driver down | tee -a /root/eth_log.txt 

        ifconfig $r_driver hw ether F4:52:14:10:A1:80 | tee -a /root/eth_log.txt 

        ifconfig $r_driver $inetIP | tee -a /root/eth_log.txt 

        sleep 30s
        ping 192.168.1.254 | tee -a /root/eth_log.txt 



        ifconfig $r_driver hw ether F4:52:14:10:A1:7F | tee -a /root/eth_log.txt 


        status=$?
        echo "status=$status"

        if [ 0 -eq  $status ];then
                echo "Succeed changing HW MAC..." | tee -a /root/eth_log.txt 

        else
                echo "Fail to chang HW MAC..." | tee -a /root/eth_log.txt 

        fi

        if [ 0 -eq $status ];then
                sleep 10s
                ping 192.168.1.254 | tee -a /root/eth_log.txt 


        fi

        if [ 0 -eq $? ];then
                echo "Ping success after changing HW MAC..." | tee -a /root/eth_log.txt 

                killall dhclient | tee -a /root/eth_log.txt 

        fi

        exit 0
fi

