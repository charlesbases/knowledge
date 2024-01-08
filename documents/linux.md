## vim

- ##### ketwords

  ```shell
  # 快捷键

  # G:  跳至文本最后一行
  # gg: 跳至文本首行
  # $:  跳至当前行最后一个字符
  # 0:  跳至当前行首字符
  ```

- ##### [.vimrc](.share/.vimrc)

---

## ssh

```shell
sudo apt install openssh-server ufw -y
ufw enable
ufw allow ssh

# ssh 密钥生成
ssh-keygen -t rsa -b 2048 -C "zhiming.sun" -f id_rsa

# ssh 免密
ssh-copy-id -i $HOME/.ssh/id_rsa.pub user@ip

# 多密钥管理
cat > $HOME/.ssh/config << EOF
Host 192.168.0.1
  User root
  Hostname 192.168.0.1
  # 服务器向客户端发送空包的时间间隔，以保持连接
  ServerAliveInterval 120
  # 服务端未收到客户端相应的空包的最大次数，就会关闭连接
  # 超时时间为 ServerAliveInterval * ServerAliveCountMax
  ServerAliveCountMax 720
  IdentityFile ~/.ssh/is_rsa
  PreferredAuthentications publickey
EOF
```

- ##### config

  ```shell
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



---

## tar

```shell
# -c 建立新的备份文件(压缩)
# -x 从备份文件中还原文件(解压)
# -z 通过 gzip 命令处理文件
# -v 显示执行过程
# -f 指定文件
# -C 输出文件夹路径
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
tar -zxvf demo.tar.gz -C demo

# *.tar.bz2
tar -jxvf demo.tar.bz2

# *.tar.Z
tar -Zxvf demo.tar.Z

# *.zip
unzip -d demo demo.zip
```

---

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

---

## [wrk](https://www.cnblogs.com/quanxiaoha/p/10661650.html)

- ##### install

  - ##### mac

    ```shell
    brew install wrk
    ```

  - ##### linux

    ```shell
    # lib
    sudo apt install git libssl-dev build-essential -y
    
    # wrk
    git clone https://github.com/wg/wrk.git wrk
    cd wrk
    make
    sudo mv wrk /usr/bin/wrk
    sudo chown root:root /usr/bin/wrk
    ```

- ##### options

  ```shell
  Usage: wrk <options> <url>
    Options:
      -c, --connections <N>  # 单线程与服务器建立并保持 TCP 连接数量
      -d, --duration    <T>  # 压测时间
      -t, --threads     <N>  # 压测线程数

      -s, --script      <S>  # 指定 lua 脚本路径
      -H, --header      <H>  # Add header to request
          --latency          # 压测结束后，打印延迟统计信息
          --timeout     <T>  # 连接超时时间
      -v, --version          # wrk 版本信息

    <N> 代表数字参数，支持国际单位 (1k, 1M, 1G)
    <T> 代表时间参数，支持时间单位 (2s, 2m, 2h)
  ```

  ```shell
  # -t: 推荐设置为压测机器 CPU 核心数的 2-4 倍
  # 实际压测连接总数为：connections * threads
  ```

- ##### report

  ```shell
  # wrk -t 32 -c 100 -d 30s --latency http://10.63.3.11:30080/swagger/index.html

  Running 30s test @ http://10.63.3.11:30080/swagger/index.html
    32 threads and 100 connections

    Thread Stats   Avg      Stdev     Max    +/- Stdev
  #  	状态        平均值     标准差    最大值  正负标准差所占比例
      Latency    24.49ms   29.51ms 201.67ms   78.78%
  #   延迟
      Req/Sec    292.77    138.20    1.86k    72.88%
  #   每秒请求数

    Latency Distribution # 延迟分布
       50%    4.69ms
       75%   47.67ms
       90%   73.86ms
       99%   90.83ms
    280671 requests in 30.09s, 1.01GB read # 30.09s 内处理了 280671 次请求，耗费流量 1.01GB
  Requests/sec:   9326.66   # QPS. 每秒评价处理请求 9326.66
  Transfer/sec:     34.53MB # 平均每秒流量 34.53MB
  ```

- ##### script

  - ##### local

    ```lua
    -- 全局变量
    wrk = {
      scheme  = "http",
      host    = "localhost",
      port    = 8080,
      method  = "GET",
      path    = "/",
      headers = {},
      body    = nil,
      thread  = <userdata>,
    }

    -- 全局方法
    wrk.format(method, path, headers, body) -- 根据参数和全局变量 `wrk`， 生成 HTTP request 字符串
    wrk.lookup(host, service)               -- 返回所有可用的服务器地址信息
    wrk.connect(addr)                       -- test connect
    ```

  - ##### api

    ```lua
    -- 启动阶段
    function setup(thread)

    -- 运行阶段
    function init(args)
    function delay()    -- 每次发送请求前调用，可用来定制延迟时间
    function request()  -- 用来生成请求，每一次请求都会先调用此方法
    function response(status, headers, body) -- 在收到每一个相应后调用

    -- 结束阶段
    function done(summary, latency, request) -- 在整个测试过程中只会调用一次，可以生成定制化的测试报告
    ```

  - ##### demo

    ```lua
    -- 自定义请求参数
    wrk.headers["Content-Type"] = "application/json"
    
    request = function()
        id = math.random(1, 100000)
        path = "/api?id=" .. id
        return wrk.format("GET", path)
    end
    ```

    ```lua
    -- 每次请求前延迟 10ms
    delay = function()
        return 10
    end
    ```

    ```lua
    -- 先认证，后请求
    token = nil
    path = "/api/login"
    
    request = function()
        return wrk.format("GET", path)
    end
    
    response = function(status, headers, body)
        if not token and status == 200 then
            token = headers["Authorization"]
            path = "api/user/list"
            wrk.headers["Authorization"] = token
        end
    end
    ```

---

## wget

```shell
wget [optoins] <url>

# options
#
# -O  指定保存下载文件名
# -P  指定保存下载文件夹
# -c  断点续传
# -q  静默模式，减少输出信息

# 将文件内容下载并保存到管道
wget -O - <url>
```

---

## curl

```shell
curl [optins] <url>

# options
#
# -X  HTTP Method. eg: `-X POST`
# -H  HTTP Header. eg: `-H "Content-Type: application/json"`
# -d  Request Param. eg: `-d '{"username": "user", "password": "password"}'`
# -k, --insecure  不验证 ssl 证书
# -s, --silent    静默模式，不显示其他信息
```

---

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

---

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

### groups

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

---

## find

```shell
# 递归显示文件夹下所有子文件夹及其目录
find . -print

# 只显示文件夹
find . -type d -print

# 只显示文件
find . -type f -print

# 排除文件夹
find -name .git -prune -o -type f -print
find -name .git -prune -o -name .idea -prune -o -type f -print

# `-print`  显示匹配项到标准输出
# `-type d` 显示文件夹
# `-type f` 显示文件
# `-name .git -prune` 排除名称为 '.git' 的文件夹
# `-o` 或，用于连接多个表达式
```

---

## eval

```shell
# 将参数作为命令进行解释并执行
command="echo Hello, Word"
eval $command
```

---

## date

```shell
# %Y 年份. 2006
# %m 月份. 01-12
# %d 日期. 01-31
# %H 小时. 00-23
# %M 分钟. 00-60
# %S 秒.   00-60
# %j 一年中的第几天. (001-366)
# %U 一年中的第几周. 从周日开始计算. (00-53)
# %W 一年中的第几周. 从周一开始计算. (00-53)
# %s 从 1970-01-01 00:00:00 UTC 起的秒数
```

```shell
# date +"%Y-%m-%d %H:%M:%S"
# date +"%Y%m%d%H%M%S"
```

---

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

---

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

---

## nohup

```shell
# 后台启动
nohup ./script.sh > /opt/log/output.log 2>&1 &

# PID
ps aux | grep "./script.sh"
```

---

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

---

## base64

```shell
# 编码
echo -n "Hello, Word" | base64
# '-n': 防止输出包含换行符

# 解码
echo "SGVsbG8sIFdvcmQ=" | base64 --decode
```

---

## [docker](../docker/README.md)

---

## resolv

```shell
# 查看 resolv.conf 创建者

# 查看软链接
ls -l /etc/resolv.conf

# 或查看 resolv.conf 注释
cat /etc/resolv.conf
```

- ##### systemd-resolved

  ```shell
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

---

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

---

## ohmyzsh

```shell
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

sed -i -s "s/robbyrussell/ys/g" $HOME/.zshrc && source $HOME/.zshrc
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

- ##### .zshrc

  ```shell
  cat >> ~/.zshrc << EOF
  if [ -d $HOME/.profile.d ]; then
    for i in `ls $HOME/.profile.d | grep .sh`; do
      if [ -r $HOME/.profile.d/$i ]; then
        . $HOME/.profile.d/$i
      fi
    done
    unset i
  fi
  
  # export
  set completion-ignore-case on
  export TERM=xterm-256color
  export TIME_STYLE="+%Y-%m-%d %H:%M:%S"
  
  # alias
  alias l="ls -lh"
  alias la="ls -Alh"
  alias his="history -i"
  
  EOF
  ```

---

## corndns

```shell
# 禁用 systemd-resolve
# 解决服务器的 53 端口占用
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

---

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



---

## mirrors

- ##### apt

  ```shell
  sudo apt update
  sudo apt upgrade -y
  sudo apt install vim git zsh wget curl make htop lsof tree expect net-tools -y
  ```

  - ##### debain

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

- ##### yum


---

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

- ##### mkcert

  ```shell
  ```

---

## hostname

```shell
sudo hostnamectl set-hostname athena
```

---

## timezone

- ##### debain

  ```shell
  sudo sh -c "apt install ntp -y && ntpd time.windows.com && timedatectl set-timezone 'Asia/Shanghai'"
  ```

- ##### ubuntu

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

  - the NTP socket is in use, exiting

    ```shell
    sudo sh -c "kill -9 $(sudo lsof -i :123 | awk '{if (NR == 2){print $2}}')"
    ```

---

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

---

## resources

- ##### cpu

  ```shell
  # cpu 核心数
  nproc
  
  # cpu 详细信息
  lscpu
  ```

## bash-completion

- ##### macos

- ##### linux

  ```shell
  # 下载 completion 脚本
  sudo apt install -y bash-completion
  
  cat >> ~/.bashrc << EOF
  # completions
  source /usr/share/bash-completion/bash_completion
  source /usr/share/bash-completion/completions/git
  # 执行 `kubectl completion bash` 生成的命令补全脚本
  source <(kubectl completion bash)
  
  EOF
  ```

- ##### windows

  ```shell
  
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

---

### [watchers](.share/scripts/watchers.sh)

```shell
crontab -e

# 每分钟执行
* * * * * /root/.scripts/watchers.sh
```

---

### [docker-cleaner](.share/scripts/docker-cleaner.sh)

```shell
cat >> $HOME/.zshrc << EOF
alias d="$HOME/.scripts/docker-cleaner.sh"
EOF

source $HOME/.zshrc
```
