#!/usr/bin/env bash

root="yaml"
if [[ ! -d $root ]]; then
  echo "$root: No such file or directory"
  exit
fi
cd $root

help() {
  echo """
Usage:
  ./$(basename $0) command [option]

Commands:
  apply       exec 'kubectl apply ...'
  delete      exec 'kubectl delete ...'

Options
  -f          delete pvc & pv"""
  exit
}

namespace() {
  case $1 in
    create|delete)
    ;;
    *)
    echo "Error: unknown command \"$1\" for \"kubectl\""
    exit
    ;;
  esac

  # namespace in yaml files
  ls *.yaml | while read file; do grep 'namespace: ' $file | sed 's/.*namespace: //' | uniq; done | sort | uniq | while read ns; do
    if [[ -z $(kubectl get namespace | grep "$ns") ]]; then
      kubectl $1 namespace $ns
    fi
  done
}

apply() {
  namespace create

  ls *.yaml | while read file; do
    kubectl apply -f $file
  done
}

delete() {
  ls *.yaml | while read file; do
    kubectl delete -f $file
  done

  case $1 in
    -f)
    for ns in "${namespaces[@]}"; do
      # pv & pvc
      kubectl get pvc -n $ns | awk 'NR>1 {print $1}' | while read item; do
        kubectl delete pvc -n $ns $item && kubectl delete pv $(kubectl get pv | grep "$item" | awk '{print $1}')
      done
    done

    # secret
    kubectl -n argocd get secret | grep -v 'default\|NAME' | while read line; do
      kubectl delete -n argocd secret $line
    done
    ;;
  esac

#  namespace delete
}

argocdNamespace="argocd"

context() {
  # default namespace
  defaultNamespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')

  # set default namespace to ${srgocdNamespace}
  kubectl config set-context --current --namespace=$argocdNamespace > /dev/null

  # do something
  $@

  # recover namespace to ${defaultNamespace}
  kubectl config set-context --current --namespace=$defaultNamespace > /dev/null
}

ls *.yaml | while read file; do
  grep -n '^kind: Namespace' $file | awk -F ':' '{print $1}' | while read line; do
    echo "find 'kind: Namespace' in $file:$line"
  done
done

case $1 in
  apply)
  context apply
  ;;
  delete)
  context delete $2
  ;;
  *)
  help
  ;;
esac
