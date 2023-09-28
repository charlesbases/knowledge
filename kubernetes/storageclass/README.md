# JuiceFS

[GitHub](https://github.com/juicedata/juicefs) [社区版文档](https://juicefs.com/docs/zh/community/introduction/) [CSI 文档](https://juicefs.com/docs/zh/csi/introduction)

------

## 1. 部署

```shell
# Kubernetes Version >= v1.18
wget -O juicefs.latest.yaml https://raw.githubusercontent.com/juicedata/juicefs-csi-driver/master/deploy/k8s.yaml

# Kubernetes Version < v1.18
wget -O juicefs.oldest.yaml https://raw.githubusercontent.com/juicedata/juicefs-csi-driver/master/deploy/k8s_before_v1_18.yam
```

```shell
# 查看 node 节点是否定制 kubelet 根目录
ps -ef | grep kubelet | grep root-dir

# 如果 `root-dir` 不为空并且不等于 '/var/lib/kubelet'
sed -i -s 's|/var/lib/kubelet|${root-dir}|g' juicefs.yaml
```

```shell
# 修改 juicefs 路径
sed -i -s 's|/var/lib/juicefs|/u01/juicefs|g' juicefs.yaml
```

```yaml
# 添加 secret 和 StorageClass
# https://juicefs.com/docs/zh/csi/guide/pv
---
apiVersion: v1
kind: Secret
metadata:
  name: juicefs-secret
  namespace: kube-system
type: Opaque
stringData:
  name: "juicefs"
  metaurl: "redis://:password@192.168.1.1:6379/0"
  storage: "s3"
  bucket: "http://192.168.1.1:9000/juicefs" # MinIO
  access-key: "minioadmin"
  secret-key: "minioadmin"
  envs: "{TZ: Asia/Shanghai}"
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: juicefs
  annotations:
    "storageclass.kubernetes.io/is-default-class": "true"
provisioner: csi.juicefs.com
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
parameters:
  csi.storage.k8s.io/node-publish-secret-name: juicefs-secret
  csi.storage.k8s.io/node-publish-secret-namespace: kube-system
  csi.storage.k8s.io/provisioner-secret-name: juicefs-secret
  csi.storage.k8s.io/provisioner-secret-namespace: kube-system
  juicefs/mount-image: juicedata/mount:v1.0.3-4.9.0
mountOptions:
- cache-dir=/u01/juicsfs/.cache
- cache-size=102400 # MiB
```

```shell
# 镜像下载
cat juicefs.yaml | grep 'image:' | sed -s 's/.*image: //g' | sort | uniq
# juicedata/mount:v1.0.3-4.9.0

# 查看部署状态
kubectl -n kube-system get pods -l app.kubernetes.io/name=juicefs-csi-driver
```

