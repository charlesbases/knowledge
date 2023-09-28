#!/usr/bin/env bash

# 查看 kubernetes 镜像列表
# sudo kubeadm config images list > images.txt

help() {
  echo """
Usage:
  ./$(basename $0) [options] command

Options:
  -f         从指定文件夹中整理镜像列表
  -o         保存镜像至指定目录

Commands:
  pull       镜像拉取
  push       镜像推送至私有仓库
  clean      本地镜像清理"""
  exit
}

findimages() {
  ls $1 | while read item; do
    if [[ -d "$1/$item" ]]; then
      findimages $1/$item
    else
      if [[ $(echo $item | grep ".yaml") ]]; then
        cat $1/$item | grep "image: " | sed -s 's/.*image: //g' | sed -s 's/#.*//' | sed -s 's/"//g' | sed -s "s/'//g" | while read image; do
          echo "find \"$image\" in \"$1/$item\""
          echo $image >> $imagesrepo
        done
      fi
    fi
  done
}

dockerpull() {
  if [[ "$filepath" ]]; then
    findimages $filepath
  fi

  cat $imagesrepo | sort | uniq > $imagesrepo

  cat $imagesrepo | while read image; do
    echo -e "\033[32mdocker pull $image ...\033[0m"
    docker pull $image
  done
}

dockerpush() {
  if [[ -z "$1" ]]; then
    echo "Error: invalid repository."
    echo "usage: $0 push <repository>"
    exit
  fi

  cat $imagesrepo | while read image; do
    docker tag $image $1/$image

    echo -e "\033[32mdocker push $1/$image ...\033[0m"
    docker push $1/$image
  done
}

dockersave() {
  if [[ ! -d "$output" ]]; then
    mkdir -p $output
  fi

  cat $imagesrepo | while read image; do
    filename=${image##*/}
    filename=${filename//:/_}

    echo -e "\033[32mdocker save $image ...\033[0m"
    docker save -o $output/$filename.tar $image
  done
}

dockerclean() {
  cat $imagesrepo | while read image; do
    local name=${image%:*}
    local tag=${image##*:}
    docker rmi -f $(docker images | grep $name | grep $tag | awk '{if (NR==1){print $3}}')
  done
}

output="images"
filepath=

# 整理后的镜像列表
imagesrepo="images.repo"

while getopts ":f:o:h" opt; do
  case $opt in
    o)
    output=$OPTARG
    ;;
    f)
    filepath=$OPTARG
    ;;
    h)
    help
    ;;
    ?)
    echo "Error: invalid flag: '-$OPTARG'"
    echo "See '$0 -h' for usage."
    exit
    ;;
  esac
done

# 去除 options
shift $(($OPTIND - 1))

case $1 in
  pull)
  dockerpull
  ;;
  push)
  dockerpush $2
  ;;
  save)
  dockersave
  ;;
  clean)
  dockerclean
  ;;
  *)
  help
  ;;
esac
