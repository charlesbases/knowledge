#!/usr/bin/env bash

help() {
  echo """
Usage:
  ./$(basename $0) [options] command

Options
  -i         忽略的镜像

Commands:
  show       镜像列表
  pull       镜像拉取
  push       镜像推送至私有仓库"""
  exit
}

showimages() {
  ls *.yaml | while read file; do
    echo -e "\033[32msearching for images in $file\033[0m"

    cat $file | grep -e 'image: \|gcr.io/\|-image' | grep -v "$ignore" | awk -v RS=', ' '{print}' | grep -e 'image: \|/' | sed -s -e 's/.*image: //g' -e 's/^"//g' -e 's/".*//g' -e 's/,//g' | sort | uniq | while read item; do
      if [[ $(echo $item | grep '@sha256') ]] && [[ -z $(echo $item | awk -F ':' '{print $3}') ]]; then
        echo -e "$item \033[35m[no tag]\033[0m \c"
        echo "$file:$(grep -n -m 1 $item $file | awk -F ':' '{print $1}')"
      else
        echo "$item"
      fi
    done
  done
}

dockerpull() {
  # 镜像列表
  ls *.yaml | while read file; do
    cat $file | grep -e 'image: \|gcr.io/\|-image' | grep -v "$ignore" | awk -v RS=', ' '{print}' | grep -e 'image: \|/' | sed -s -e 's/.*image: //g' -e 's/^"//g' -e 's/".*//g' -e 's/,//g' | sort | uniq
  done > images.repo

  # 镜像下载
  cat images.repo | sed -s 's/@sha256.*//' | while read item; do
    docker pull $item
  done
}

dockerpush() {
  if [[ -z $1 ]]; then
    echo -e "Error: invalid repository.\nRun './$(basename $0) push [repository]'"
    exit
  fi

  # 镜像推送
  cat images.repo | sed 's/@sha256.*//' | while read item; do
    docker tag $item $1/$item && docker push $1/$item
  done

  echo && read -sp "replace the repository in the yaml file with \"$1\"? (Y/N) " input
  if [[ $input =~ ^[yY]+$ ]]; then
    echo 'y'

    # replace
    cat images.repo | sed 's/@sha256.*//' | while read item; do
      ls *.yaml | while read file; do
        if [[ -z $(grep "$1/$item" $file) ]]; then
          sed -i "s|$item|$1/&|g" $file
        fi
      done
    done

    # remove '@sha256'
    cat images.repo | grep '@sha256' | sed 's/.*@sha256/@sha256/' | while read item; do
      ls *.yaml | while read file; do
        sed -i "s/$item//g" $file
      done
    done
  else
    echo 'n'
  fi
}

ignore="# "

while getopts ":i:" opt; do
  case $opt in
    i)
    ignore="$ignore\|$OPTARG"
    ;;
    ?)
    help
    ;;
  esac
done

shift $(($OPTIND - 1))
case $1 in
  show)
  showimages
  ;;
  pull)
  dockerpull
  ;;
  push)
  dockerpush $2
  ;;
  *)
  help
  ;;
esac
