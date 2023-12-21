# gitlab

## apply

```shell
# 修改 storageClassName

```

```shell
# 镜像下载
awk '/image:/ {gsub(" ", ""); sub("image:", ""); print}' *.yaml | while read line; do docker pull $line; done
```

```shell
# 创建 namespace
kubectl create namespace gitlab
```

```shell
# kubectl apply
kubectl apply -f redis.yaml -f mysql.yaml

kubectl apply -f gitlab.yaml
```

