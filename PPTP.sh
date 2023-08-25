#!/bin/bash

# 更新系统软件
sudo apt-get -y update
sudo apt-get -y upgrade

# 安装PPTP和IPtables
sudo apt-get install -y pptpd iptables

#配置PPTP
sudo sed -i 's/#localip.*/localip 192.168.100.1/' /etc/pptpd.conf
sudo sed -i 's/#remoteip.*/remoteip 192.168.100.100-200/' /etc/pptpd.conf

# 配置DNS
echo "ms-dns 8.8.8.8" | sudo tee -a /etc/ppp/pptpd-options
echo "ms-dns 223.5.5.5" | sudo tee -a /etc/ppp/pptpd-options

# 设置账户信息
echo "admin pptpd 1234567890 *" | sudo tee -a /etc/ppp/chap-secrets

# 开启IP转发
sudo sed -i 's/#net.ipv4.ip_forward/net.ipv4.ip_forward/' /etc/sysctl.conf
sudo sysctl -p

# 配置防火墙
sudo iptables -A INPUT -p gre -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 47 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 192.168.100.1/24 -o eth0 -j MASQUERADE
sudo iptables -I FORWARD -s 192.168.100.0/24 -p tcp --syn -i ppp+ -j TCPMSS --set-mss 1300
sudo iptables-save

# 重启PPTP
sudo /etc/init.d/pptpd restart
