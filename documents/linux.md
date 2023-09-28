## ——————

## hostname

```shell
sudo hostnamectl set-hostname athena
```

------

## user

```shell
# 所有用户
cat /etc/passwd
# getent passwd

# 添加用户
sudo useradd -G root,docker -s /bin/zsh -d /home/user -m user

# 删除用户
sudo userdel -r user
```

### group

```shell
# 当前用户所属组
groups

# 添加用户组
sudo groupadd usergroup

# 删除用户组
sudo groupdel usergroup

# 添加用户至 root 组
sudo gpasswd -a $USER root

# 从 root 组删除用户
sudo gpasswd -d $USER root

# 更新 root 用户组
newgrp usergroup
```

### sudoers

```shell
sudo vim /etc/sudoers

# 添加 sudo 权限
username ALL=(ALL:ALL) ALL

# 普通用户 sudo 免密
username ALL=(ALL) NOPASSWD:ALL
```

### password

```shell
# 修改当前用户密码
sudo passwd

# 修改其他用户密码
sudo passwd sun
```

------

## root

```shell
vim /etc/ssh/sshd_config

···
PermitRootLogin yes
···

# 
sh -c 'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config'

# 取消倒计时
sed -i -s "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/g" /etc/default/grub

update-grub2 && reboot
```

------

## timezone

- ##### debain

  ```shell
  sudo sh -c "apt install ntp -y && ntpd time.windows.com && timedatectl set-timezone 'Asia/Shanghai'"
  ```

- ##### contos

  ```shell
  sudo sh -c "yum install ntp -y && ntpdate time.windows.com && timedatectl set-timezone 'Asia/Shanghai'"
  ```

```shell
# 方案一
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 方案二
export TZ="Asia/Shanghai"
```

### ntpdate

```shell
# install
sudo apt install ntp -y
```

```shell
# /etc/ntp.conf
#  restrict [ip] [mask] [args]
#  restrict default notrap nomodify nopeer noquery
#    ip: 默认 'default', 指所有 IP
#    mask: 网关掩码
#    args:
#      ignore: 关闭所有的 NTP 联机服务
#      nomodify: 客户端不可更新服务端时间参数，但是客户端可通过服务端进行网络校时
#      notrust: 客户端除非通过认证，否则该客户端来源被视为不信任子网
#      noquery: 不提供客户端的时间查询
#  server 时间服务器
#  server time.windows.com # windows 时间服务器
#  server 127.127.1.0      # 本地时间服务器。当上面配置的 server 不可用时，使用本地时间服务器

sudo vim /etc/ntp.conf
...
restrict default notrap nomodify nopeer noquery

server 127.127.1.0
fudge  127.127.1.0 stratum 10
...
```

```shell
# 节点时间同步
sudo ntpd 192.168.1.1

# 同步硬件时间

# debain
sudo hwclock -w

# centos
sudo vim /etc/sysconfig/ntpd
...
SYNC_HWCLOCK=YES
OPTIONS="-u ntp:ntp -p /var/run/ntpd.pid -g"
...
```

- ##### error

  - ###### the NTP socket is in use, exiting

    ```shell
    sudo sh -c "kill -9 $(sudo lsof -i :123 | awk '{if (NR == 2){print $2}}')"
    ```

------

## firewalld

```shell
# 查看防火墙状态
sudo systemctl status firewalld

# 安装服务
apt install firewalld -y

# 开启服务
systemctl start firewalld

# 关闭服务
systemctl stop firewalld

# 查看状态
systemctl status firewalld

# 开机启动
systemctl enable firewalld

# 开机禁用
systemctl disable firewalld

# 开放端口
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=8080-9090/tcp --permanent

# 关闭端口
firewall-cmd --zone=public --remove-port=8080/tcp --permanent

# 查看端口列表
firewall-cmd --zone=public --list-ports
```

------

## openssl

![ssl](.share/openssl.png)

- ##### full

  ```shell
  # 完整版
  # 模拟 HTTPS 厂商生产 HTTPS 证书过程，HTTPS 证书厂商一般都会有一个根证书（3、4、5），实际申请中，该操作用户不可见。通常用户只需将服务器公钥与服务器证书申请文件交给 HTTPS 厂商即可，之后 HTTPS 厂商会邮件回复一个服务器公钥证书，拿到这个服务器公钥证书与自生成的服务器私钥就可搭建 HTTPS 服务
  
  # 1. 生成服务器私钥
  openssl genrsa -out server.key 2048
  
  # 2. 生成服务器证书申请文件
  openssl req -new -key server.key -out server.csr
  
  # 3. 生成 CA 机构私钥
  openssl genrsa -out ca.key 2048
  
  # 4. 生成 CA 机构证书请求文件
  openssl req -new -key ca.key -out ca.csr
  
  # 5. 生成 CA 机构根证书（自签名证书）
  openssl x509 req -signkey ca.key -in ca.csr -out ca.crt
  
  # 6. 生成服务器证书（公钥证书）
  openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in server.csr -out server.crt
  ```

- ##### simplify

  ```shell
  # 精简版
  # 本地 HTTPS 测试，既是用户角色也是 HTTPS 厂商角色
  
  # 1. 生成服务器私钥
  openssl genrsa -out server.key 2048
  
  # 2. 生成服务器证书申请文件
  openssl req -nodes -noout -new -key server.key -out server.csr
  
  # 3. 生成服务器证书
  openssl x509 -req -signkey server.key -in server.csr -out server.crt -days 3650
  ```

  ```shell
  # 生成本地服务器证书
  openssl req -nodes -new -x509 -newkey rsa:2048 -keyout server.key -out server.crt
  ```

------

## service

```shell
sudo cat > /etc/systemd/system/myservice.service << EOF
[Unit]
Description=MyService
After=network-online.target

[Service]
Type=notify

User=root
Group=root

Restart=on-failure

# exec
ExecStart=start command
ExecStop=stop command
# ExecReload=restart command

[Install]
WantedBy=multi-user.target
EOF

# daemon-reload
sudo systemctl daemon-reload

# enable
sudo systemctl enable myservice

# start
sudo systemctl start myservice

# status
sudo systemctl status myservice
```

```shell
# .service 文件说明，"*" 为必要参数

# [Uint] 启动顺序与依赖关系
[Uint]
# *Description 描述
Description=[txt]
# Documentation 文档位置
Documentation=[url|fullpath]

# 启动顺序，多个服务用空格分隔
# *After 当前服务在指定服务之后启动
After=network-online.target
# Before 当前服务在指定服务之前启动
Before=network-online.target

# 依赖关系
# Wants 弱依赖关系服务，指定服务发生异常不影响当前服务
Wants=network-online.target
# Requires 强依赖关系服务，指定服务发生异常，当前服务必须退出
Requires=network-online.target

# [Service] 启动行为
[Service]
# EnvironmentFile 环境变量文件
EnvironmentFile=[fullpath]
# *ExecStart 启动服务时执行的命令
ExecStart=[shell]
# *ExecStop 停止服务时执行的命令
ExecStop=[shell]
# ExecReload 重启服务时执行的命令
ExecReload=[shell]
# ExecStartPre 启动服务之前执行的命令
ExecStartPre=[shell]
# ExecStartPost 启动服务之后执行的命令
ExecStartPost=[shell]
# ExecStopPost 停止服务之后执行的命令
ExecStopPost=[shell]

# Type 启动类型
#   simple(default):ExecStart字段启动的进程为主进程
#   forking: ExecStart字段将以fork()方式启动，此时父进程将会退出，子进程将成为主进程
#   oneshot: 类似于simple，但只执行一次，Systemd 会等它执行完，才启动其他服务
#   dbus: 类似于simple，但会等待 D-Bus 信号后启动
#   notify: 类似于simple，启动结束后会发出通知信号，然后 Systemd 再启动其他服务
#   idle: 类似于simple，但是要等到其他任务都执行完，才会启动该服务。一种使用场合是为让该服务的输出，不与其他服务的输出相混合 
Type=simple

# KillMode 如何停止服务
#   control-group(default): 当前控制组里面的所有子进程，都会被杀掉
#   process: 只杀主进程
#   mixed: 主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号
#   none: 没有进程会被杀掉，只是执行服务的 stop 命令。
KillMode=control-group

# 重启方式
# no(default): 退出后不会重启
# on-success: 只有正常退出时（退出状态码为0），才会重启
# on-failure: 非正常退出时（退出状态码非0），包括被信号终止和超时，才会重启
# on-abnormal: 只有被信号终止和超时，才会重启
# on-abort: 只有在收到没有捕捉到的信号终止时，才会重启
# on-watchdog: 超时退出，才会重启
# always: 不管是什么退出原因，总是重启
Restart=no
# RestartSec 重启服务之前等待的秒数
RestartSec=3

# [Install]
[Install]
# Target（服务组）说明
# 例：WantedBy=multi-user.target
# 执行 sytemctl enable **.service命令时，**.service的一个符号链接，就会放在/etc/systemd/system/multi-user.target.wants子目录中
# 执行systemctl get-default命令，获取默认启动Target
# multi-user.target组中的服务都将开机启动
# 常用Target，1. multi-user.target-多用户命令行；2. graphical.target-图形界面模式
WantedBy=[表示该服务所在的Target]
```



------

## .bashrc

- ##### bash-completion

  ```shell
  sudo apt install -y bash-completion
  
  cat >> ~/.bashrc << EOF
  source /usr/share/bash-completion/bash_completion
  source <(kubectl completion bash)
  EOF
  ```

------

## sysctl

```shell
# 内核优化
cat > /etc/sysctl.conf << EOF
# maximum number of open files/file descriptors
fs.file-max = 4194304

# use as little swap space as possible
vm.swappiness = 0

# prioritize application RAM against disk/swap cache
vm.vfs_cache_pressure = 50

# minimum free memory
vm.min_free_kbytes = 1000000

# follow mellanox best practices https://community.mellanox.com/s/article/linux-sysctl-tuning
# the following changes are recommended for improving IPv4 traffic performance by Mellanox

# disable the TCP timestamps option for better CPU utilization
net.ipv4.tcp_timestamps = 0

# enable the TCP selective acks option for better throughput
net.ipv4.tcp_sack = 1

# increase the maximum length of processor input queues
net.core.netdev_max_backlog = 250000

# increase the TCP maximum and default buffer sizes using setsockopt()
net.core.rmem_max = 4194304
net.core.wmem_max = 4194304
net.core.rmem_default = 4194304
net.core.wmem_default = 4194304
net.core.optmem_max = 4194304

# increase memory thresholds to prevent packet dropping:
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 65536 4194304

# enable low latency mode for TCP:
net.ipv4.tcp_low_latency = 1

# the following variable is used to tell the kernel how much of the socket buffer
# space should be used for TCP window size, and how much to save for an application
# buffer. A value of 1 means the socket buffer will be divided evenly between.
# TCP windows size and application.
net.ipv4.tcp_adv_win_scale = 1

# maximum number of incoming connections
net.core.somaxconn = 65535

# maximum number of packets queued
net.core.netdev_max_backlog = 10000

# queue length of completely established sockets waiting for accept
net.ipv4.tcp_max_syn_backlog = 4096

# time to wait (seconds) for FIN packet
net.ipv4.tcp_fin_timeout = 15

# disable icmp send redirects
net.ipv4.conf.all.send_redirects = 0

# disable icmp accept redirect
net.ipv4.conf.all.accept_redirects = 0

# drop packets with LSR or SSR
net.ipv4.conf.all.accept_source_route = 0

# MTU discovery, only enable when ICMP blackhole detected
net.ipv4.tcp_mtu_probing = 1

EOF

sysctl -p

# transparent_hugepage = madvise
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

```

------

## resolv

```shell
# 查看 resolv.conf 创建者

# 查看软链接
ls -l /etc/resolv.conf

# 或查看 resolv.conf 注释
cat /etc/resolv.conf
```

- ##### systemd-resolved

  ```
  sudo sh -c '''
  systemctl disable --now systemd-resolved.service
  rm -rf /etc/resolv.conf
  echo "nameserver 192.168.1.1" > /etc/resolv.conf
  '''
  ```

- ##### NetworkManager

  ```shell
  # 清理 NetworkManager.conf
  grep -ir "\[main\]" /etc/NetworkManager
  ...
  - [main]
  ...
  
  # 修改配置
  sudo sh -c """cat > /etc/NetworkManager/conf.d/no-dns.conf << EOF
  [main]
  dns=none
  EOF
  
  systemctl restart NetworkManager.service
  
  rm -rf /etc/resolv.conf
  echo "nameserver 192.168.1.1" > /etc/resolv.conf
  """
  ```

------

## fdisk

```shell
# 查看已有分区
sudo fdisk -l

# 操作磁盘
sudo fdisk /dev/sda

# m: command help
# d: 删除磁盘分区
# n: 添加磁盘分区
# w: 保存并退出

# 格式化分区
sudo mkfs -t ext4 /dev/sda3

# 分区挂载
cat >> /etc/fstab << EOF
/dev/sda3 /mnt/sda3 ext4 defaults 0 0
EOF

reboot
```

------

## nohup

```shell
# 后台启动
nohup ./script.sh > /opt/log/output.log 2>&1 &

# PID
ps aux | grep "./script.sh"
```

------

## [wrk](.share/wrk.mhtml)

------

## swap

```shell
# 临时禁用
sudo swapoff -a

# 临时启用
sudo swapon -a

# 永久禁用
sudo vim /etc/fstab
···
# /mnt/swap swap swap defaults 0 0
···
reboot

# 或
sed -ri 's/.*swap.*/# &/' /etc/fstab

# 查看分区状态
free -m
```

------

## vim

```shell
# 快捷键

# G:  跳至文本最后一行
# gg: 跳至文本首行
# $:  跳至当前行最后一个字符
# 0:  跳至当前行首字符
```

```shell
vim ～/.vimrc

···
syntax on
filetype on

set go=
set nocompatible
set term=builtin_ansi

set encoding=utf-8 
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,gbk,gb2312,cp936,big5,gb18030,shift-jis,euc-jp,euc-kr,latin1

set nobomb                   " 不自动设置字节序标记
set nobackup                 " 禁用备份
set noswapfile               " 禁用 swp 文件
set clipboard=unnamed        " 共享剪贴板
set fileformats=unix,dos     " 换行符
set ruler                    " 打开状态栏标尺
set cursorline               " 突出显示当前行
set syntax=on                " 语法高亮
set confirm                  " 在处理未保存或只读文件的时候，弹出确认
set ignorecase               " 搜索忽略大小写
set cmdheight=2              " 命令行高度
set background=dark          " 黑色背景
set autoread                 " 自动加载文件改动
set noautoindent             " 关闭自动缩进
set pastetoggle=<F12>        " 开关
set expandtab                " 替换 Tab
set tabstop=2                " Tab键的宽度

set showmatch                " 高亮显示匹配的括号
set matchtime=1              " 匹配括号高亮的时间

set t_Co=256                 " 颜色

colorscheme pablo

" 默认以双字节处理那些特殊字符
if v:lang =~? '^\(zh\)\|\(ja\)\|\(ko\)'
	set ambiwidth=double
endif

" 清空整页
map zz ggdG
" 开始新行
map <cr> o<esc>
" 注释该行
map / 0i# <esc>j0
" 取消注释
map \ 0xx <esc>j0
···
```

------

## ssh

```shell
apt-get install openssh-server ufw -y
ufw enable
ufw allow ssh

# ssh 密钥生成
ssh-keygen -t rsa -b 2048 -C "zhiming.sun"

# ssh 免密
ssh-copy-id -i $HOME/.ssh/id_rsa.pub user@ip

# 多密钥管理
cat > $HOME/.ssh/config << EOF
Host 192.168.0.1
  User root
  Hostname 192.168.0.1
  ServerAliveInterval 120 # 服务器向客户端发送空包的时间间隔，以保持连接
  ServerAliveCountMax 720 # 服务端未收到客户端相应的空包的最大次数，就会关闭连接。超时时间为 ServerAliveInterval * ServerAliveCountMax
  IdentityFile ~/.ssh/is_rsa  
  PreferredAuthentications publickey
EOF
```

```shell
# 多用户管理

## ip 匹配
cat > $HOME/.ssh/config << EOF
Host 192.168.0.1
  # Port 22
  # User root
  # Hostname 192.168.0.1
  ServerAliveInterval 120
  ServerAliveCountMax 720
  IdentityFile ~/.ssh/is_rsa
  PreferredAuthentications publickey
EOF

## 正则匹配
cat > $HOME/.ssh/config << EOF
Host 192.168.0.*
  ServerAliveInterval 120
  ServerAliveCountMax 720
  IdentityFile ~/.ssh/is_rsa
  PreferredAuthentications publickey
EOF
```

------

## apt

```shell
sudo apt update
sudo apt upgrade -y
sudo apt install sudo vim git zsh wget curl make htop lsof tree expect net-tools -y
```

- ##### sources

  - ###### debain

    ```shell
    # 备份
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    
    ···
    # cqu
    http://mirrors.cqu.edu.cn
    
    # ustc
    http://mirrors.ustc.edu.cn
    
    # aliyun
    http://mirrors.aliyun.com
    
    # tsinghua
    http://mirrors.tuna.tsinghua.edu.cn
    ···
    
    ··· Debian 11
    deb http://mirrors.aliyun.com/debian/ bullseye main
    # deb-src http://mirrors.aliyun.com/debian/ bullseye main
    deb http://mirrors.aliyun.com/debian/ bullseye-updates main
    # deb-src http://mirrors.aliyun.com/debian/ bullseye-updates main
    deb http://mirrors.aliyun.com/debian/ bullseye-backports main 
    # deb-src http://mirrors.aliyun.com/debian/ bullseye-backports main 
    deb http://mirrors.aliyun.com/debian-security bullseye-security main
    # deb-src http://mirrors.aliyun.com/debian-security bullseye-security main
    ···
    
    apt update -y
    ```

------

## tar

```shell
# -c 建立新的备份文件(压缩) 
# -x 从备份文件中还原文件(解压)
# -z 通过 gzip 命令处理文件
# -v 显示执行过程
# -f 指定文件
```

```shell
# 压缩文件

# *.tar
tar -cvf demo.tar.gz demo

# *.tar.gz
tar -zcvf demo.tar.gz demo
```

```shell
# 解压文件

# *.tar
tar -xvf demo.tar

# *.tar.gz | *.tgz
tar -zxvf demo.tar.gz

# *.tar.bz2
tar -jxvf demo.tar.bz2

# *.tar.Z
tar -Zxvf demo.tar.Z

# *.zip
unzip -d demo demo.zip
```

------



## ——————

## nfs

- ##### master

  ```shell
  apt install nfs-kernel-server -y
  
  # 设置挂载目录
  mkdir -p /data/nfs
  chmod a+w /data/nfs
  cat >> /etc/exports << EOF
  /data/nfs 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
  EOF
  
  # ro: 以只读方式挂载
  # rw: 赋予读写权限
  # sync: 同步检查
  # async: 忽略同步检查以提高速度
  # subtree_check: 验证文件路径
  # no_subtree_check: 不验证文件路径
  # no_root_squash: (危险项) 客户端 root 拥有服务端 root 权限
  
  # 启动服务
  sudo sh -c 'systemctl enable rpcbind && systemctl start rpcbind'
  sudo sh -c 'systemctl enable nfs-kernel-server && systemctl start nfs-kernel-server'
  
  # 查看
  showmount -e
  ```

- ##### node

  ```shell
  apt install nfs-common -y
  
  # 创建 nfs 共享目录
  sudo mkdir -p /data/nfs
  
  # 连接 nfs 服务器
  cat >> /etc/fstab << EOF
  # nfs-server
  192.168.1.10:/data/nfs /data/nfs nfs4 defaults,user,exec 0 0
  EOF
  
  #
  sudo mount -a
  
  # 启动服务
  sudo sh -c 'systemctl enable rpcbind && systemctl start rpcbind'
  
  # 查看
  df -h
  ```

------

## rsync

```shell
# 本地同步
rsync -a source destination

# 远程同步
rsync -a source user@remote:destination

# -a 递归；保存文件信息，包括时间、权限等
# -r 递归
# -z 传输时使用数据传输
# --delete 从 'destination' 删除 'source' 中不存在的文件 
```

------

## nvidia

```shell
# 安装依赖
apt-get install linux-source linux-headers-$(uname -r) -y

# 卸载旧驱动
sudo apt autoremove nvidia

sudo systemctl stop lightdm gdm kdm

# 禁用 nouveau
sudo vim /etc/modprobe.d/blacklist.conf

···
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
···

echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf

sudo update-initramfs -u
reboot

# 查看禁用是否生效
lsmod | grep nouveau

# 安装 nvidia 驱动 https://www.nvidia.cn/Download/Find.aspx?lang=cn
```

```shell
# 安装 PPA 源
sudo add-apt-repository ppa:oibaf/graphics-drivers

# 更新驱动
sudo apt-get update && sudo apt-get dist-upgrade -y

sudo root
```

------

## docker

```shell
# docker
curl -sSL https://get.daocloud.io/docker | sh
# curl -fsSL https://get.docker.com | bash -s docker --mirror aliyun
sudo systemctl enable docker

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
# sudo curl -L https://get.daocloud.io/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
sudo chmod 755 /usr/bin/docker-compose

# 添加当前用户到 docker 用户组
sudo gpasswd -a $USER docker

# 更新 docker 用户组
newgrp docker

# daemon.json
cat >> /etc/docker/daemon.json << EOF
{
  "debug": true,
  "experimental": false,
  "data-root": "/opt/docker/",
  "builder": {
    "gc": {
      "defaultKeepStorage": "64GB",
      "enabled": true
    }
  },
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "repository-mirrors": [
    "http://docker.mirrors.ustc.edu.cn"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-file": "8",
    "max-size": "128m"
  }
}
EOF
```

------

## corndns

```shell
# 禁用 systemd-resolve
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# docker
docker pull coredns/coredns:1.10.0
```

```shell
# sudo mkdir /etc/coredns
cat > /etc/coredns/start.sh << EOF
docker run -d -p 53:53/udp -v /etc/coredns/Corefile:/Corefile --name coredns --restart always  coredns/coredns:1.10.0
EOF
```

- ##### Corefile

  ```
  .:53 {
    hosts {
      192.168.1.1 coredns.com
  
      ttl 5
      fallthrough
    }
  
    # 未匹配的域名转发到上游 DNS 服务器
    forward . 192.168.1.1
  
    errors
    log stdout
    
    cache 60
    reload 3s
  }
  ```

------

## ohmyzsh

```shell
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

sed -i -s "s/robbyrussell/ys/g" $HOME/.zshrc && source $HOME/.zshrc
```

- ## .zshrc

  ```shell
  if [ -d $HOME/.profile.d ]; then
    for i in `ls $HOME/.profile.d | grep .sh`; do
      if [ -r $HOME/.profile.d/$i ]; then
        . $HOME/.profile.d/$i
      fi
    done
    unset i
  fi
  
  # alias
  alias l="ls -lh"
  alias la="ls -Alh"
  alias his="history -i"
  
  alias gp="git push"
  alias gf="git pull"
  alias gr="git reset"
  
  alias cs='cd $GOPATH/src'
  
  # export
  set completion-ignore-case on
  export TERM=xterm-256color
  export TIME_STYLE="+%Y-%m-%d %H:%M:%S"
  export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:/opt/go/bin
  ```

- ##### dircolors

  ```shell
  dircolors >> ~/.zshrc
  
  sed -s -i 's/ow=34;42/ow=34/' ~/.zshrc
  
  # 修改 ow=34;42 ==> ow=34
  # 30: 黑色前景
  # 34: 蓝色前景
  # 42: 绿色背景
  ```

------

## conrainerd

```shell
apt install -y -qq apt-transport-https ca-certificates gnupg

# 添加 GPG 密钥
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | apt-key add -

# 添加 docker 软件源
cat > /etc/apt/sources.list.d/docker.list << EOF
deb [arch=$(dpkg --print-architecture)] https://mirrors.aliyun.com/docker-ce/linux/debian $(lsb_release -cs) stable
EOF

# apt install containerd
apt update -y && apt install -y containerd.io

# 开机启动
systemctl daemon-reload
systemctl start containerd && systemctl enable containerd
```

## ——————

## rust

```shell
# 安装
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 换源
vim .cargo/config.toml

···
[net]
  git-fetch-with-cli = true

[source.crates-io]
  repository = "https://github.com/rust-lang/crates.io-index"
  replace-with = 'tuna'

[source.tuna]
  repository = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
···

# 清除缓存
rm ~/.cargo/.package-cache

# 更新
rustup update

# 卸载
rustup self uninstall
```



------

## golang

```shell
wget -c https://dl.google.com/go/go1.18.9.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local

···
export PATH="$PATH:/usr/local/bin"
export GO111MODULE="on"
export GOPATH="/opt/go"
export GOPROXY="https://goproxy.io,direct"
···

sudo mkdir -p /opt/go/bin /opt/go/pkg /opt/go/src
sudo chown $USER /opt/go/*
```



------

## python

```shell
# 依赖
sudo apt install -y wget build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev

# Python3
ver=3.10.7
wget -c https://www.python.org/ftp/python/$ver/Python-$ver.tgz && tar -xvf Python-$ver.tgz
cd Python-$ver
./configure --enable-optimizations --prefix=/usr/local/python3
sudo make -j 2
sudo make altinstall

# 软链接
sudo ln -s /usr/local/python3/bin/python3.10 /usr/local/bin/python3
sudo ln -s /usr/local/python3/bin/pip3.10 /usr/local/bin/pip3

# Pip 加速
mkdir $HOME/.pip && cat > $HOME/.pip/pip.config << EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = mirrors.aliyun.com
EOF

# 第三方依赖
black ····· 代码格式化工具
request ··· HTTP 封装
pymysql ··· 操作 MySQL

```



------

## nodejs

```shell
wget -c https://nodejs.org/dist/v16.5.0/node-v16.5.0-linux-x64.tar.xz
sudo tar -x -C /usr/local/ -f node-v16.5.0-linux-x64.tar.xz
rm -rf node-v16.5.0-linux-x64.tar.xz

mv /usr/local/node-v16.5.0-linux-x64 /usr/local/nodejs
sudo ln -s /usr/local/nodejs/bin/npm /usr/local/bin/
sudo ln -s /usr/local/nodejs/bin/node /usr/local/bin/

# 换源(taobao)
npm config set registry https://registry.npmmirror.com/

# pnpm
sudo npm install -g pnpm
sudo ln -s /usr/local/node/bin/pnpm /usr/local/bin/
```

## ——————

## scripts

### [remote](.share/scripts/remote.sh)

```shell
cat >> $HOME/.zshrc << EOF
alias r="$HOME/.scripts/remote.sh"
EOF

source $HOME/.zshrc
```

------

### [watchers](.share/scripts/watchers.sh)

```shell
crontab -e

# 每分钟执行
* * * * * /root/.scripts/watchers.sh
```

------

### [docker-cleaner](.share/scripts/docker-cleaner.sh)

```shell
cat >> $HOME/.zshrc << EOF
alias d="$HOME/.scripts/docker-cleaner.sh"
EOF

source $HOME/.zshrc
```

------