#!/usr/bin/env bash

set -e

list=(
# IP User Passwd Remark
# kubernetes
"192.168.10.10 user password develop-10"
"192.168.10.11 user password develop-11"
"192.168.10.12 user password develop-12 user@192.168.10.10"
)

length=${#list[@]}

display() {
  local limit=0
  for (( i = 1; i <= $length; i++ )); do
    item=(${list[i-1]})
    ip=${item[0]}
    user=${item[1]}

    if [[ $limit -lt $[${#ip}+${#user}] ]]; then
      limit=$[${#ip}+${#user}+1]
    fi
  done

  for (( i = 1; i <= $length; i++ )); do
    item=(${list[i-1]})
    ip=${item[0]}
    user=${item[1]}
    remark=${item[3]}

    echo -e "$i. \033[32m$ip\033[0m\033[34m <$user>\033[0m \c "
    for (( j = 0; j < $[$limit-${#ip}-${#user}]; j++ )); do
      echo -n "·"
    done
    if [[ -z $remark ]]; then
      echo " $user@$ip"
    else
      echo " $remark"
    fi
  done
}

connect() {
  read -sp ">: " input

  if [[ ! "$input" =~ ^[0-9]+$ ]]; then
    echo -e "\033[31mexit\033[0m"
    exit
  fi
  if [[ "$input" -gt $length ]]; then
    echo -e "\033[31minvalid input. must be 1 - $length\033[0m"
    exit
  fi

  item=(${list[$input-1]})
  ip=${item[0]}
  user=${item[1]}
  passwd=${item[2]}
  remark=${item[3]}
  board=${item[4]}

  echo -e "\033[31m$user@$ip\033[0m"

  # sshpass
  # sshpass -p $passwd ssh $user@$ip

  # ssh-copy-id
  if [[ -n "$identity" ]]; then
    if [[ "${board}" ]]; then
      ssh -t ${board} "ssh-copy-id -i $identity $user@$ip"
    else
      ssh-copy-id -i $identity $user@$ip
    fi
  fi

  # 需要跳板机远程登陆
  if [[ "${board}" ]]; then
    ssh -t ${board} "ssh $user@$ip"
  else
    ssh $user@$ip
  fi
}

bubbling() {
  # 去空格，方便排序
  for (( i = 0; i < ${#list[@]}; i++ )); do
    list[i]=$(echo ${list[i]} | sed -s 's/ /|/g')
  done

  list=($(echo ${list[@]} | tr ' ' '\n' | sort))

  # 添加空格
  for (( i = 0; i < ${#list[@]}; i++ )); do
    list[i]=$(echo ${list[i]} | sed -s 's/|/ /g')
  done
}

main() {
  display
  connect
}

# ssh-copy-id
identity=""

case $1 in
  -h)
  echo "Options:"
  echo "  -v    update this script"
  echo "  -i    identity_file"
  exit
  ;;
  -v)
  vim $0
  exit
  ;;
  -i)
  if [[ -z $2 ]] || [[ ! -f "$identity" ]]; then
    echo -e "\033[31mInvalid identity_file. No such file or directory\033[0m"
    exit
  fi
  identity=$2
  ;;
esac

main
