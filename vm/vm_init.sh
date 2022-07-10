#!/bin/bash

# 关闭selinux
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# 关闭firewalld
systemctl stop firewalld
systemctl disable firewalld

# 将yum源修改为阿里云的yum源, 这样下载rpm包更快
# 参考: 
#   https://developer.aliyun.com/mirror/centos?spm=a2c6h.13651102.0.0.3e221b11qP3CaC
#   https://developer.aliyun.com/mirror/epel?spm=a2c6h.13651102.0.0.13631b11bgj6RM
rm -fv /etc/yum.repos.d/*
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm
sed -i 's|^#baseurl=https://download.example/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*

# 配置时间同步, 将时间源改为阿里云的时间服务器
# 参考: https://developer.aliyun.com/mirror/?spm=a2c6h.13651102.0.0.3e221b11qP3CaC&serviceType=ntp
yum install -y chrony
sed -i 's/2.centos.pool.ntp.org/ntp.aliyun.com/' /etc/chrony.conf
systemctl daemon-reload
systemctl enable --now chronyd

# 关闭swap
#swapoff -a
#sed -i '/\<swap\>/d' /etc/fstab

# 安装常用的rpm包
yum -y install wget net-tools vim bind-utils
