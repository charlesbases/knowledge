## if

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

## args

```shell
# $0 # 命令本身
# $1 # 第一个参数
# $# # 参数个数。不包括 "$0"
# $@ # 参数列表。不包括 "$0"
# $* # 不加引号是与 $@ 相同。"$*" 将所有的参数解释成一个字符串，"$@" 是一个参数数组

# ${variable:? msg}  # 如果 variable 为空，则返回 msg 错误输出。eg: arg=${1:? arg cannot be empty}
# ${variable:-value} # 如果 variable 为空，则返回 value。eg: arg=${1:-$(pwd)}
```

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

------



## loop

### for

```shell
```



### while

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

## sed

```shell
# 删除 10 行之后的所有内容
sed -i '10,$d' filename
# sed -i "$line,\$d" filename
```

### trim

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

### append

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

# 在第 10 行追加 new.txt 文件内容
sed -i '20r new.txt' file.txt

# a 在匹配行后面追加一行
# i 在匹配行前面插入一行
# r 在匹配行后面追加文件内容
```

### replace

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

# 在第1-9行行首添加字符 '#'
sed '1,9 s/^/#/' file.text

# 查看第 100 行内容
sed -n '100p' file.txt
# -n   禁止输出所有内容
# 100p 打印第 100 行

# g  全局替换
# -i 用修改结果直接替换源文件内容
# -s 字符串替换 's/old/new/g' 或 's@old@new@g' 、's|old|new|g'
```

------

## awk

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

# OFS
# awk 输出时的列分隔符
echo '1 2 3' | awk '{print $0}'                  # 1 2 3
echo '1 2 3' | awk -v OFS="," '{print $1,$2}'    # 1,2
# 打印 '$0' 时，为使 'OFS' 生效，需要改变 '$0'，实际上 '$0' 本身没任何改变
echo '1 2 3' | awk -v OFS="," '{$1=$1;print $0}' # 1,2,3
```

- ##### commands

  ```shell
  # docker images
  docker images | awk -v OFS=":" '{print $1,$2}'

  # docker images (一行展示)
  docker images | awk 'BEGIN{ORS=" ";OFS=":"}{print $1,$2}'
  ```


------

## grep

```shell
# -i 忽略大小写
# -v 反转匹配
# -n 显示匹配模式的行号
# -o 只显示匹配子串
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

### regex

```shell
# 根据正则输出匹配子串
# [{"id":1},{"id":12},{"id":123}]
echo '[{"id":1},{"id":12},{"id":123}]' | grep -o '"id":[0-9]*'
# "id":1
# "id":12
# "id":123

# 'fmt.Println("https://www.google.com")'
grep -o 'https://[^"]*'
#https://www.google.com
```

---

## string

### trim

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

### sort

```shell
# 按 ASCII 正序
echo "a c b" | tr ' ' '\n' | sort

# 按 ASCII 倒叙
echo "a c b" | tr ' ' '\n' | sort -r
```

### uniq

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

### replace

```shell
# 替换相同数量的字符
echo 'hello world' | tr ' ' '\n'

# 只替换首次
echo ${string/substring/replacement}

# 全部替换
echo ${string//substring/replacement}
```



---



## * * * * *

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



### url&path

```shell
# 截取最后一个 '/' 右边所有字符串, 不包含 '/' 本身
basename $(echo "https://google.com/xx/xxx") # xxx

# 截取最后一个 '/' 左边所有字符串, 不包含 '/' 本身
dirname $(echo "https://google.com/xx/xxx")
```
