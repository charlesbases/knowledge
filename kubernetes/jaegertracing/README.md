# Jaegertracing

## 1、install

```shell
wget -O - https://github.com/jaegertracing/jaeger-operator/releases/download/v1.52.0/jaeger-operator.yaml > jaeger.yaml
```

```shell
# 镜像列表
awk '/image:/ {print $2}' jaeger.yaml | awk 'NF>0{print}'
```

