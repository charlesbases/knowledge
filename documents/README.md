# 技术手册

------

- ##### [git](#⭐-git)

- ##### [shell](#⭐-shell)

- ##### [linux](#⭐-linux)

- ##### [rust](#⭐-rust)

- ##### [python](#⭐-python)

- ##### [golang](#⭐-golang)

- ##### [nodejs](#⭐-nodejs)

- ##### [windows](#⭐-windows)

------

## ⭐ git

### 1. tag

- ##### 添加

  ```shell
  # new tag
  git tag -a "v1.0.0" -m "release v1.0.0"

  # push
  git push --tags

  #
  v=v1.0.0; git tag -a "$v" -m "release $v" && git push --tags
  ```

- ##### 删除

  ```shell
  # 删除本地
  git tag -d v1.0.0
  
  # 删除远程
  git push origin :refs/tags/v1.0.0
  
  #
  v=v1.0.0; git tag -d $v && git push origin :refs/tags/$v
  ```

---

### 2. pull

```shell
# git pull 下载小文件时，禁用 gzip  来提高下载速度
git clone -c core.compression=0 <repo.url>

# '-c core.compression=0' 禁用 gzip
# '-b master'
# '--single-branch' 只拉取指定分支
# '--depth 1'       只拉取最新的提交记录
```

---

### 3. push

```shell
# 推送到远程分支
git push origin <local-branch>:<remote-branch>
```

---

### 4. branch

```shell
# 分支关联
git branch --set-upstream-to=<remote-branch> <local-branch>
```

- ##### 删除

  ```shell
  # 本地分支
  git branch -d branch
  
  # 远程分支
  git push origin -d branch
  
  #
  b=branch; git push origin --delete $b && git branch -d $b
  ```

---

### 5. submodule

- ##### 添加

  ```shell
  git submodule add url [path/module]
  ```

- ##### 更新

  ```shell
  git submodule update --remote
  ```

- ##### 删除

  ```shell
  # 删除 git 缓存
  git rm --cached [module]
  
  # 删除 .gitmodules 子模块信息
  [submodule "module"]
  
  # 删除 .git/config 子模块信息
  [submodule "module"]
  
  # 删除 .git 子模块文件
  rm -rf .git/modules/[model]
  ```

---

### 6. [gitconfig](.share/gitconfig)

---

### 7. git-for-windows

- ##### vimrc

  ```shell

  ```

- ##### inputrc

  ```shell
  sed -i -s 's/set bell-style visible/set bell-style none/g' inputrc
  ```



- ##### profile.d

  - [git-prompt.sh](.share/scripts/git-prompt.sh)

---

### 99. others

```shell
# 查看当前分支名
git rev-parse --abbrev-ref HEAD

# 查看当前分支 hash
git rev-parse HEAD

# 查看当前分支 hash(short)
git rev-parse --short HEAD
```

## ————————————

## ⭐ shell

```shell
# awk
# 适合结构化数据，支持行、列处理

# sed
# 主要用于进行文本和流的编辑功能，包括替换、删除、添加、选取

# grep
# 主要提供文件搜索功能
```



### 1. if

```shell
# 判断对象是否为空
if [ ! "$a" ]; then
  echo "a is null"
else
  echo "a is not null"
fi

# -z 是否为空字符串
# -n 是否不为空
```

```shell
if [ -f "$filename" ]; then
  echo
fi

# -e 对象是否存在
# -d 对象是否存在, 并且为目录
# -f 对象是否存在, 并且为常规文件
# -L 对象是否存在, 并且为符号链接
# -h 对象是否存在, 并且为软链接
# -s 对象是否存在, 并且长度不为0
# -r 对象是否存在, 并且可读
# -w 对象是否存在, 并且可写
# -x 对象是否存在, 并且可执行
# -O 对象是否存在, 并且属于当前用户
# -G 对象是否存在, 并且属于当前用户组
```

---

### 2. args

```shell
# $0 # 命令本身
# $1 # 第一个参数
# $# # 参数个数。不包括 "$0"
# $@ # 参数列表。不包括 "$0"
# $* # 不加引号是与 $@ 相同。"$*" 将所有的参数解释成一个字符串，"$@" 是一个参数数组

# ${variable:? msg}  # 如果 variable 为空，则返回 msg 错误输出。eg: arg=${1:? arg cannot be empty}
# ${variable:-value} # 如果 variable 为空，则返回 value。eg: arg=${1:-$(pwd)}
```

---

### 3. opts

- ##### getopts

  ```shell
  while getopts ":a:bc" opt; do
    case $opt in
      a)
      echo $OPTARG
      ;;
      b)
      echo "b"
      ;;
      c)
      echo "c"
      ;;
      ?) # 其他参数
      echo "invalid input"
      ;;
    esac
  done

  # 该命令可以识别 '-a -b -c' 选项。其中 '-a' 需要设置 value，'-b -c' 不需要 value
  # getopts 每次调用时，会将下一个 'opt' 放置在变量中，$OPTARG 可以从 '$*' 中拿到参数值。$OPTARG 是内置变量
  # 第一个 ':' 表示忽略错误
  # a: 表示该 'opt' 需要 value
  # b  表示该 'opt' 不需要 value

  # 去除 options 之后的参数, 可以在后面的 shell 中进行参数处理
  shift $(($OPTIND - 1))
  echo $1
  ```

- ##### select

  ```shell
  # 简单菜单的控制结构
  
  # select 菜单的提示语，会在展示菜单后打印
  PS3="请选择一个选项: "
  
  select opt in "a" "b" "c" "quit"; do
    case $opt in
      "a")
      echo "a"
      break
      ;;
      "b")
      echo "b"
      break
      ;;
      "c")
      echo "c"
      break
      ;;
      "quit")
      exit
      ;;
      *)
      echo "invalid input"
      exit
      ;;
    esac
  done
  ```

---

### 4. loop

- ##### for

- ##### while

  ```shell
  # shell 中管道 '|' 会创建子 shell，导致变量作用域改变
  # 若要在 `while read` 循环中，修改外部变量
  
  # 1. here-string
  index=0
  while read line; do
    index=$[index+1]
  done <<< $(cat $file)
  ```

---

### 5. sed

- ##### options

  ```shell
  # -n:  不输出默认内容。在没有这个选项时，sed 会默认输出每一行内容到终端
  ```

#### 5.1. trim

```shell
# str='   fmt.Println("Hello Word")    '

# 移除开头空格
echo $str | sed 's/^ *//'

# 移除结尾空格
echo $str | sed 's/ *$//'

# 移除头尾空格
# echo $str | sed 's/^ *//; s/ *$//'
echo $str | sed 's/\(^ *\)\(.*[^ ]\)\( *$\)/\2/'
# `\(^ *\)`:    第一个子表达式, 匹配从其实位置开始的 0+ 个空格字符
# `\(.*[^ ]\)`: 第二个子表达式, 匹配任意字符, 并且确保末尾不是空格字符. `[^ ]` 匹配一个非空字符, `[^abc]` 匹配一个不为 a、b、c 的字符
# `\( *$\)`:    第三个子表达式, 匹配字符串末尾的 0+ 个空格字符
# `\2`:         替换部分只引用第二个子表达式捕获的子串

# Hello Word
echo $str | sed 's@.*"\(.*\)".*@\1@'
# `\(.*\)` 表示一个子表达式, `\` 为转义, `\1` 表示表一个子表达式所捕获的字符串

# 知识点
# ^ 表示从字符串起始位置开始, $ 表示至字符串结尾
# * 表示前一个字符匹配 0+ 次, '[0-9]*' 表示 0-9 匹配 0+ 次
# . 表示匹配任意字符, .* 表示匹配任务字符 0+ 次
```

#### 5.2. append

```shell
# 在每一行后面追加一行 "New Line"
sed -i 'a New Line' file.txt
# 注: 追加内容时, 'a New Line' 不管 'a' 后面的 ' ' 多少, 'New Line' 都会从下一行第一个字符开始。
#     若要在行开头添加 ' ', 使用 'a\ New Line'.

# 在匹配行后面追加一行 "New Line"
sed -i '/nginx/a New Line' file.txt

# (正则)在匹配行后面追加一行 "  New Line"
sed -i "/^[[:space:]]nginx/a\  New Line" file.txt
## [[:space:]]  表示匹配空格
## [[:space:]]* 表示匹配任意空格

# 在匹配行前面追加一行 "New Line"
sed -i '/nginx/i New Line' file.txt

# 添加首行
sed -i '1i # hello word' file.txt

# 在第 10 行追加 new.txt 文件内容
sed -i '20r new.txt' file.txt

# a 在匹配行后面追加一行
# i 在匹配行前面插入一行
# r 在匹配行后面追加文件内容
```

#### 5.3. delete

```shell
# 删除包含匹配字符的行
sed -i '/pattern/d' file.txt

# 删除指定行
sed -i '5d' file.txt

# 删除指定范围的行
sed -i '10,20d' file.txt
```

#### 5.4. replace

```shell
# old 全字符匹配(首个)
sed -i -s 's/old/new/' file.text

# 正则匹配
sed -i -s 's/.*old.*/new/g' file.text

# 匹配 '/'
sed -i -s 's|/var/lib/kubelet|/munt/kubelet|g' file.text

# 匹配多条
sed -i -e 's/1/2/g' -e 's/3/4/g' file.text

# 在每一行开头添加字符 '#'
# '&' 表示匹配到的字符
sed -i 's/^/#&/g' file.text

# 在每一行末尾添加字符 '#'
sed -i 's/^/&#/g' file.text

# 在第1-9行行首添加字符 '# '
sed -i '1,9 s/^/# /' file.text

# 在第1-9行，并且不以 '#' 开头的行行首添加字符 '# '
sed -i '1,9 {/^[^#]/ s/^/# /}' file.text

# 查看第 100 行内容
sed -n '100p' file.txt
# -n   禁止输出所有内容
# 100p 打印第 100 行

# g  全局替换
# -i 用修改结果直接替换源文件内容
# -s 字符串替换 's/old/new/g' 或 's@old@new@g' 、's|old|new|g'
```

#### 5.5. matching

```shell
echo 'fmt.Println("hello word")' | sed 's/.*"\(.*\)".*/\1/' 
# hello word

# 输出 image 列表
sed -n '/image:/ s/image://p' calico.yaml
# -n:             取消默认打印行为
# '/image:/':     行筛选
# 's/image://p':  替换命令。(s=substitute) 将 'image:' 替换为 ''，'p' 为打印替换后的结果
```

---

### 6. awk

#### 6.1. variable

```shell
# $0  : 当前行内容
# $1, $2 ... $NF : 当前行的第 1, 2 ... NF 列内容
# FILENAME       : 当前处理的文件名
# NR  : 当前行号。注意，当处理多个文件时，'NR' 是累加的
# FNR : 当前文件的行号
# NF  : 当前行的列数
# RS  : 输入记录行分隔符(default: '\n')
# FS  : 输入记录列分隔符(default: ' ')
# ORS : 输出记录行分隔符(default: '\n')
# OFS : 输出记录列分隔符(default: ' ')
```

#### 6.2. examples

- 行打印

  ```shell
  # 打印第一行
  cat demo.txt | awk 'NR==1'
  
  # 打印最后一行
  cat demo.txt | awk 'END {print}'
  
  # 打印第一行第一列
  cat demo.txt | awk 'NR==1 {print $1}'
  
  # 打印第一列和第三列
  cat demo.txt | awk '{print $1,$3}'
  
  # 打印最后一列
  cat demo.txt | awk '{print $NF}'
  
  # 打印行号
  cat demo.txt | awk '{print NR}'
  
  # 打印行数
  cat demo.txt | awk 'END {print NR}'
  ```

- 分隔符相关

  ```shell
  # RS
  # awk 读取文件时的行分隔符
  echo '1,2,3' | awk '{print $1}'
  ···
  1,2,3
  ···
  echo '1,2,3' | awk -v RS="," '{print $1}'
  ···
  1
  2
  3
  ···
  
  # ORS
  # awk 输出时的行结束符
  seq 3 | awk '{print $1}'
  ···
  1
  2
  3
  ···
  seq 3 | awk -v ORS="," '{print $1}'
  ···
  1,2,3,
  ···
  
  # FS (-F)
  # awk 读取文件时的列分隔符
  echo '1,2,3' | awk -F , '{print $1}'      # 1
  echo '1,2,3' | awk -v FS="," '{print $1}' # 1
  # 注意: 使用 'FS' 时，'print $0' 本身没任何改变, 需改变 '$0'
  echo '1,2,3' | awk -v FS="," '{$1=$1; print}'
  
  # OFS
  # awk 输出时的列分隔符
  echo '1 2 3' | awk '{print $0}'                  # 1 2 3
  echo '1 2 3' | awk -v OFS="," '{print $1,$2}'    # 1,2
  # 打印 '$0' 时，为使 'OFS' 生效，需要改变 '$0'，实际上 '$0' 本身没任何改变
  echo '1 2 3' | awk -v OFS="," '{$1=$1;print $0}' # 1,2,3
  ```

  

- 字符匹配相关

  ```shell
  # 打印匹配字符行
  awk '/image: / print}' calico.yaml
  
  # 去除 'image:'
  awk '/image: / {sub(/image:/, ""); print}' calico.yaml
  ```
  
  ```shell
  # 打印匹配字符所在行号
  awk '/^kind: Namespace/ {print FILENAME":"NR} ' tekton.yaml
  # `/^kind: Namespace/ {print FILENAME":"NR}`: 当匹配到 '^kind: Namespace' 时，执行 '{print FILENAME":"NR}', 注意 ':' 需要添加引号
  
  # 打印匹配字符，并且未注释的行号
  awk '!/^#/ && /name: argocd-notifications/ {print FILENAME":"NR}' argocd.yaml
  # `/xxx/` 为一个筛选条件，`{xxx}` 为执行的语句，可类比 if 语句
  ```

  ```shell
  # 打印俩个匹配字符之间的内容。包含匹配行
  awk '/^data/,/^kind/' secret.yaml
  
  # 打印俩个匹配字符之间的内容。不包含匹配行
  awk '/^data/,/^kind/ { if (!/^data/ && !/^kind/) print }' secret.yaml
  ```
  
  ```shell
  # 在 k8s 的 多个资源类型 yaml 中，找到匹配字符所在的模块.(打印最近的 '---' 所在行)
  awk '/^---/ {if (mark) { print FILENAME":"above; print FILENAME":"NR}; above=NR; focus=""; next} /^kind: Namespace/ {mark=NR}' tekton.yaml
  # 在匹配到 '^kind: Namespace' 时，标记 'mark'，在下次匹配到 '^---' 时，打印上次匹配到的 '^---' 行，并且打印本次匹配到的行
  # 注意：print 时，'print above NR' 实际效果为 'aboveNR', 'print above" "NR' 实际效果为 'above NR', 'print above, NR' 实际效果为 'above NR'
  
  # 在 k8s 的 多个资源类型 yaml 中，找到匹配字符所在的模块, 并注释相关代码
  awk '/^---/ {if (focus) { print above","NR}; above=NR; focus=""; next} /^kind: Namespace/ {focus=NR}' tekton.yaml | while read line; do sed -i "$line {/^[^#]/ s/^/# /}" tekton.yaml; done
  ```

#### 6.3. commands

```shell
# docker images
docker images | awk -v OFS=":" '{print $1,$2}'

# docker images (一行展示)
docker images | awk 'BEGIN{ORS=" ";OFS=":"}{print $1,$2}'
```

---

### 7. grep

```shell
# -i 忽略大小写
# -v 反转匹配
# -n 显示匹配模式的行号
# -o 只显示匹配子串

# -- 停止解析选项参数。匹配 '--root-dir' 时使用。eg: grep -- --root-dir
```

```shell
# 开头匹配
cat file.txt | grep '^kind: PrometheusRule'

# 打印匹配字段所在行
grep -n 'apiVersion' tekton.yaml | awk -F ':' '{print $1}'
# 只打印第一行
grep -n -m 1 'apiVersion' tekton.yaml | awk -F ':' '{print $1}'
# 注意: `grep -m 1` 为最多匹配 1 行
# 若要显示第 3 行, 使用 `grep -m 3 xxx | tail -n 1`, 表示从前三行中选择最后一行
# 或者使用 `awk`
```

```shell
# 字符串搜索
grep -nr 'sync.Once' "$(dirname $(which go))/../src"
# -n 打印行
# -r 递归地搜索指定目录中的文件和子目录

# 统计行
grep -nr 'sync.Once' "$(dirname $(which go))/../src" | wc -l
```

#### 7.1. regex

```shell
# 根据正则输出匹配子串
# [{"id":1},{"id":12},{"id":123}]
echo '[{"id":1},{"id":12},{"id":123}]' | grep -o '"id":[0-9]*'
# "id":1
# "id":12
# "id":123

# 'fmt.Println("https://www.google.com")'
grep -o 'https://[^"]*'
# https://www.google.com
```

---

### 8. string

#### 8.1. trim

```shell
filename=abc.tar.gz

# 从最后一次出现 '.' 开始，截取左边所有字符
echo "${filename%.*}" # abc.tar

# 从首次出现 '.' 开始，截取左边所有字符
echo "${filename%%.*}" # abc

# 从首次出现 '.' 开始，截取右边所有字符
echo "${filename#*.}" # tar.gz

# 从最后一次出现 '.' 开始，截取右边所有字符
echo "${filename##*.}" # gz

# 以 '.' 为分隔符输出数组
echo ${filename//./ } # abc tar gz
```

#### 8.2. sort

```shell
# 按 ASCII 正序
echo "a c b" | tr ' ' '\n' | sort

# 按 ASCII 倒叙
echo "a c b" | tr ' ' '\n' | sort -r
```

#### 8.3. uniq

```shell
# uniq 只能去除相邻字符串的重复，所以需要先使用 `sort` 进行排序

demo="""
a
b
a
b
"""

cat $demo | sort | uniq
```

#### 8.5. replace

```shell
# 替换相同数量的字符
echo 'hello world' | tr ' ' '\n'

# 只替换首次
echo ${string/substring/replacement}

# 全部替换
echo ${string//substring/replacement}
```

---

### * * * * *

### string

- 显示匹配字符串

  ```shell
  # 'fmt.Println("https://www.google.com")'
  # 匹配已知的前缀和后缀使用 `grep -o 'https://[^"]*'`
  # https://www.google.com
  ```

  ```shell
  # 'fmt.Println("hello word")'
  # 匹配未知的前缀和后缀使用 `sed 's/.*"\(.*\)".*/\1/'`
  # hello word
  ```

- 去除首尾空格

  ```shell
  # '    space    '
  # 去除字符串首尾空格, 使用 `sed 's/^ *//; s/ *$//'`
  # space
  ```

- 字符串行、列处理

  ```shell
  # 'aaa,bbb,ccc'
  # 字符串行、列处理, 使用 `awk -v RS=',' 'NR==1 {print}'`
  # aaa
  ```

- 字符替换

  ```shell
  # 'a,b,c,d,e,f'
  # 只替换一个字符时, 使用 `tr ',' '.'`
  # a.b.c.d.e.f

  # 'aabbccddeedd'
  # 字符串替换时, 显示替换后的字符串, 使用 `sed 's/[^a]/a/g'`
  # aaaaaaaaaaaa
  ```

- 字符串分割

  ```shell
  # 'a,b,c,d,e,f'
  
  1. `cut -f1 -d,`
  # -f1 打印第一个字段
  # -d, 以 ',' 为分隔符
  
  2. `awk -F , '{print $1}'`
  ```

---

### url&path

```shell
# 截取最后一个 '/' 右边所有字符串, 不包含 '/' 本身
basename $(echo "https://google.com/xx/xxx") # xxx

# 截取最后一个 '/' 左边所有字符串, 不包含 '/' 本身
dirname $(echo "https://google.com/xx/xxx")
```

## ————————————

## ⭐ linux

### vim

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

### ssh

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

### tar

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

### nfs

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

### [wrk](https://www.cnblogs.com/quanxiaoha/p/10661650.html)

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

### wget

```shell
wget [optoins] [url]

# options
#
# -O  指定保存下载文件名
# -P  指定保存下载文件夹
# -c  断点续传
# -q  静默模式，减少输出信息
```

---

### curl

```shell
curl [optins] [url]

# options
#
# -X  HTTP Method. eg: `-X POST`
# -H  HTTP Header. eg: `-H "Content-Type: application/json"`
# -d  Request Param. eg: `-d '{"username": "user", "pasword": "password"}'`
# -k, --insecure  不验证 ssl 证书
```

---

### root

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

### user

```shell
# 所有用户
cat /etc/passwd
# getent passwd

# 添加用户
sudo useradd -G root,docker -s /bin/zsh -d /home/user -m user

# 删除用户
sudo userdel -r user
```

#### groups

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

#### sudoers

```shell
sudo vim /etc/sudoers

# 添加 sudo 权限
username ALL=(ALL:ALL) ALL

# 普通用户 sudo 免密
username ALL=(ALL) NOPASSWD:ALL
```

#### password

```shell
# 修改当前用户密码
sudo passwd

# 修改其他用户密码
sudo passwd sun
```

---

### find

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

### date

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

### swap

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

### rsync

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

### nohup

```shell
# 后台启动
nohup ./script.sh > /opt/log/output.log 2>&1 &

# PID
ps aux | grep "./script.sh"
```

---

### fdisk

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

### base64

```shell
# 编码
echo -n "Hello, Word" | base64
# '-n': 防止输出包含换行符

# 解码
echo "SGVsbG8sIFdvcmQ=" | base64 --decode
```

---

### [docker](../docker/README.md)

---

### resolv

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

### sysctl

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

### .bashrc

- ##### bash-completion

  ```
  sudo apt install -y bash-completion
  
  cat >> ~/.bashrc << EOF
  source /usr/share/bash-completion/bash_completion
  source <(kubectl completion bash)
  EOF
  ```

---

### ohmyzsh

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

### corndns

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

### service

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

### mirrors

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

### openssl

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

### hostname

```shell
sudo hostnamectl set-hostname athena
```

---

### timezone

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

#### ntpdate

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

### firewalld

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

### resources

- ##### cpu

  ```shell
  # cpu 核心数
  nproc
  
  # cpu 详细信息
  lscpu
  ```

---

### + scripts

#### [remote](.share/scripts/remote.sh)

```shell
cat >> $HOME/.zshrc << EOF
alias r="$HOME/.scripts/remote.sh"
EOF

source $HOME/.zshrc
```

---

#### [watchers](.share/scripts/watchers.sh)

```shell
crontab -e

# 每分钟执行
* * * * * /root/.scripts/watchers.sh
```

---

#### [docker-cleaner](.share/scripts/docker-cleaner.sh)

```shell
cat >> $HOME/.zshrc << EOF
alias d="$HOME/.scripts/docker-cleaner.sh"
EOF

source $HOME/.zshrc
```

## ————————————

## ⭐ rust

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

---

## ⭐ python

```shell
# 依赖
sudo apt install -y wget build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev

# Python3
ver=3.12.0
wget -c https://www.python.org/ftp/python/$ver/Python-$ver.tgz && tar -xvf Python-$ver.tgz
cd Python-$ver
./configure --enable-optimizations --prefix=/usr/local/python3
sudo make -j 2
sudo make altinstall

# 软链接
# 删除旧的 python、python3 软链
for i in pip pip3 python python3; do if [[ -f "/usr/bin/$i" ]]; then sudo rm -rf /usr/bin/$i; fi; done
# pip、python
sudo ln -s /usr/local/python3/bin/python3.12 /usr/bin/python
sudo ln -s /usr/local/python3/bin/pip3.12 /usr/bin/pip

# pip 换源
# pypi.org
pip config set global.index-url https://pypi.org/simple
pip config set global.trusted-host pypi.org
# douban
pip config set global.index-url https://pypi.douban.com/simple
pip config set global.trusted-host pypi.douban.com

# 第三方依赖
black ····· 代码格式化工具
pymysql ··· 操作 MySQL
requests ·· HTTP 封装

# PYTHONPATH
cat >> ~/.zshrc << EOF
export PYTHONPATH = "$HOME/.local/lib/python3.x/site-packages"
EOF
```

---

## ⭐ golang

```shell
# download
wget -c https://golang.google.cn/dl/go1.20.10.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local

# environment
cat >> ~/.zshrc << EOF
export GOHONE="/usr/local/go"
export GOPATH="/opt/go"
export GOPROXY="https://goproxy.io,direct"
export GO111MODULE="on"
EOF

# add to path
cat >> ~/.zshrc << EOF
export PATH="$PATH:$GOHOME/bin:$GOPATH/bin"
EOF

#
sudo mkdir -p $GOPATH/{bin,pkg,src}
```

---

#### 1. test

```shell
# 运行当前目录下所有测试函数
go test -v .

# 运行指定函数
go test -run TestName .
```

##### 1.1. cover

```shell
# 简略信息
go test -cover

# 详细信息
go test -coverprofile=cover.out && go tool cover -html=cover.out -o cover.html
```

##### 1.2. benchmark

```shell
#
go test -test.bench=. -test.count=1 -test.benchmem .

# 运行指定的基准测试函数
```

###### 1.2.1. pprof

```http
https://zhuanlan.zhihu.com/p/396363069
```

- ###### graphviz

  ```http
  https://graphviz.org/download
  ```

- ###### benchmark

  ```shell
  go test -test.bench=. -memprofile=mem.out .
  go tool pprof -http=:8080 mem.out
  ```

---

#### 2. build

```shell
# -o <output> 执行生成的可执行文件的名称和路径
# -i       显示相关的依赖包，但不构建可执行文件
# -v       显示构建过程中的详细信息，包括编译的文件和依赖的包
# -x       显示构建过程中的详细信息，包括执行的编译命令
# -race    启用数据竞争检测，用于检查并发程序中的数据竞争问题
# -ldflags 为链接器提供额外的标志参数，如设置程序的版本信息等
```

- ##### goos

  ```shell
  # windows
  CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build .

  # linux
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build .

  # max
  CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build .
  ```

- ##### -ldflags

  ```shell
  # 减小编译后体积
  go build -ldflags "-s -w" -o main main.go
  # -s 忽略符号表和调试信息
  # -w 忽略 DWARFv3 调试信息，使用该选项后将无法使用 gdb 进行调试
  
  # 使用当前时间作为版本号
  go build -ldflags "-s -w -X main.version=$(date +'%Y%m%d%H%M%S')" -o main main.go
  # 使用当前 git-hash 作为版本号
  go build -ldflags "-s -w -X main.version=$(git rev-parse --short HEAD)" -o main main.go
  ```

---

#### 3. tools

##### 3.1. goimports

```shell
go install golang.org/x/tools/cmd/goimports@latest

# use
goimports -w [filepath]
```

---

## ⭐ nodejs

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

## ————————————

## ⭐ windows

### 1. applications

- ##### chrome

  ```shell
  # --incognito
  # 隐身模式启动

  # --ignore-certificate-errors
  # 忽略证书错误

  # --disable-background-networking
  # 禁用版本检查
  ```

- ##### docker

  ```shell
  # version
  4.11.1
  ```



---

### 2. networks

- 刷新 dns 缓存

  ```shell
  ipconfig /flushdns
  ```

- 禁用网卡

  ```shell
  netsh interface set interface "INTERNAL" disable
  ```

- 启用网卡

  ```shell
  netsh interface set interface "EXTERNAL" enable
  ```

------

### 3. mkilnk

```shell
# cmd
mklink /D "[链接名称]" "[目标路径]"

# google
mklink /D "C:\Program Files\Google" "D:\Google"

# docker
mklink /D "C:\Program Files\Docker" "D:\Docker"

# CCleaner
mklink /D "C:\Program Files\CCleaner" "D:\CCleaner"
```

------

### 99. others

- 在文件资源管理器中打开当前路径

  ```shell
  start "" .

  # alias open='start ""'
  ```

- 在 GoLand 中打开当前路径

  ```shell
  start "" "D:\JetBrains\GoLand\bin\goland64.exe" .

  # alias goland='start "" "D:\JetBrains\GoLand\bin\goland64.exe"'
  ```

- ping

  ```shell
  for ip in {1..254}; do ping -n 1 -w 30 10.112.27.$ip; done
  ```

## ————————————
