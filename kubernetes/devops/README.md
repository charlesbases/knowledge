------

## 1. Tekton

### 1.1. install

#### 1.1.1. pipeline

```shell
# 查看 tekton-pipeline 支持的 Kubernetes 版本
# https://github.com/tektoncd/pipeline

version=v0.46.0
wget -O - https://storage.googleapis.com/tekton-releases/pipeline/previous/$version/release.yaml >> tekton.yaml
```

#### 1.1.2. dashboard

```shell
# 查看 tekton-dashboard 支持的 tekton-pipeline 版本
# https://github.com/tektoncd/dashboard/releases

version=v0.34.0
wget -O https://github.com/tektoncd/dashboard/releases/download/$version/release.yaml >> tekton.yaml
```

```shell
# 注释掉 'kind: Namespace', 改为手动创建。防止卸载时 ns 删除失败
ls *yaml | while read file; do grep -n '^kind: Namespace' $file | awk -F ':' '{print $1}' | while read line; do echo $file:$line; done; done

# namespace
kubectl create namespace devops
```

### 1.2. documents

#### 1.2.1 api-resources

##### 1. Task

*Task 为构建任务，是 Tekton 中不可分割的最小单位，正如同 Pod 在 Kubernetes 中的概念一样。在 Task 中，可以有多个 Step，每个 Step 由一个 Container 来执行。*

```yaml
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: gopath
  namespace: tekton-pipelines
spec:
  volumeMode: Filesystem
  storageClassName: juicefs-sc
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 128Gi
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: env-golang
  namespace: tekton-pipelines
data:
  GOOS: 'linux'
  GOARCH: 'amd64'
  CGO_ENABLED: '0'
  GO111MODULE: 'on'
  GOPATH: '/gopath'
  GOPROXY: 'https://goproxy.io,direct'
---
apiVersion: tekton.dev/v1alpha1
kind: Task
metadata:
  labels:
    app: auth
  name: auth
  namespace: tekton-pipelines
spec:
  # 由于 tekton 会给每个构建的容器都挂载 '/workspace' 目录，所以每个 steps 步骤里都可以在 '/workspace' 里找到上一步执行的产物
  inputs:
    resources:
    # ${PipelineResource.metadata.name}
    # git 可以认为是一个默认的 steps，这个 steps 的逻辑里 tekton会把代码拉取至 'workspace/${resources.name}' 中
    - name: auth
      type: git
    params:
    - name: workspace
      default: '/workspace/auth'
    - name: imagetag
      default: 'auth:v1.0.0'
  steps:
  - name: builder
    image: 'golang:1.19'
    # 指定工作目录为代码存放目录
    workingDir: '${inputs.params.workspace}'
#    env:
#    - name: GOPATH
#      value: '/gopath'
    envFrom:
    - configMapRef:
        name: env-golang
#    - secretRef:
#        name: env-golang
    command:
    - /bin/bash
    args:
    - buils.sh
    volumeMounts:
    - name: localtime
      mountPath: /etc/localtime
    - name: gopath
      mountPath: /gopath
  - name: docker-build
    image: 'docker:git'
    workingDir: '${inputs.params.workspace}'
    args:
    - --tag
    - '${inputs.params.imagetag}'
    - .
    volumeMounts:
    - name: localtime
      mountPath: /etc/localtime
    - name: docker-socket
      mountPath: /var/run/docker.sock
  - name: docker-push
    image: 'docker:git'
    workingDir: '${inputs.params.workspace}'
    args:
    - push
    - '${inputs.params.imagetag}'
    volumeMounts:
    - name: localtime
      mountPath: /etc/localtime
    - name: docker-socket
      mountPath: /var/run/docker.sock
  volumes:
  - name: localtime
    hostPath:
      path: /usr/share/zoneinfo/Asia/Shanghai
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
      type: Socket
  - name: gopath
    persistentVolumeClaim:
      claimName: gopath
```

##### 2. Pipeline

*Pipeline 由一个或多个 Task 组成。在 Pipeline 中，用户可以定义这些 Task 的执行顺序以及依赖关系来组成 DAG（有向无环图）*

##### 3. PipelineRun

*PipelineRun 是 Pipeline 的实际执行产物，当用户定义好 Pipeline 后，可以通过创建 PipelineRun 的方式来执行流水线，并生成一条流水线记录。*

##### 4. TaskRun

*PipelineRun 被创建出来后，会对应 Pipeline 里面的 Task 创建各自的 TaskRun。一个 TaskRun 控制一个 Pod，Task 中的 Step 对应 Pod 中的 Container。当然，TaskRun 也可以单独被创建。*

```yaml
apiVersion: tekton.dev/v1alpha1
kind: TaskRun
metadata:
  # TaskRun 为一次性任务，不需要定义 'name' 字段，无法修改 TaskRun 中字段重新创建
  generateName: auth-
spec:
  inputs:
    resources:
    - name: git
#      resourceRef:
#        name: auth
      # PipelineResource 模板
      resourceSpec:
        type: git
        params:
        - name: url
          value: 'ssh://git@gitlab.com/cloud/kubernetes.git'
        - name: revision
          value: 'master' # branch or tag or commit hash
  serviceAccount: git-reporter
  taskRef:
    name: auth
```

##### 5. PipelineResource

*PipelineResource 代表着一系列的资源，主要承担作为 Task 的输入或者输出的作用*

*它有以下几种类型：*

*1. git：代表一个 git 仓库，包含了需要被构建的源代码。将 git 资源作为 Task 的 Input，会自动 clone 此 git 仓库。(使用 git 拉取代码时，存在安全和私有仓库安全的问题，需要配置相关的 'secrets/serviceaccount')*

*2. pullRequest：表示来自配置的 url（通常是一个 git 仓库）的 pull request 事件。将 pull request 资源作为 Task 的 Input，将自动下载 pull request 相关元数据的文件，如 base/head commit、comments 以及 labels。*

*3. image：代表镜像仓库中的镜像，通常作为 Task 的 Output，用于生成镜像。*

*4. cluster：表示一个除了当前集群外的 Kubernetes 集群。可以使用 Cluster 资源在不同的集群上部署应用。*

*5. storage：表示 blob 存储，它包含一个对象或目录。将 Storage 资源作为 Task 的 Input 将自动下载存储内容，并允许 Task 执行操作。目前仅支持 GCS。*

*6. cloud event：会在 TaskRun z执行完成后发送事件信息（包含整个 TaskRun） 到指定的 URI 地址，在与第三方通信的时候十分有用。*

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-gitlab
  namespace: tekton-pipelines
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: xxxxxx
  konw_hosts: xxxxxx
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-gitlab
  namespace: tekton-pipelines
secrets:
- name: argocd-gitlab
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  labels:
    app: auth
  name: auth
  namespace: tekton-pipelines
spec:
  type: git
  params:
  - name: url
    value: 'http://gitlab.com/cloud/platform/auth.git'
  - name: revision
    value: 'master' # branch or tag or commit hash
```

------

## 2. ArgoCD

### 2.1. install

#### 2.1.1. argocd

```shell
# argocd 所支持的 kubernetes 版本为 N, N-1, N-2。例如 argocd_v2.6 支持 kubernetes_v1.26、kubernetes_v1.25、kubernetes_v1.24

# github
# https://github.com/argoproj/argo-cd

# documents
# https://argo-cd.readthedocs.io/en/stable
```

- ##### helm

  ```shell
  version=argo-cd-5.29.1
  wget -O argocd.tgz https://github.com/argoproj/argo-helm/releases/download/$version/$version.tgz
  tar -zxvf argocd.tgz && rm -rf argocd.tgz
  ```

- ##### kubectl

  ```shell
  version=stable
  wget -O argocd.yaml https://raw.githubusercontent.com/argoproj/argo-cd/$version/manifests/install.yaml
  ```

### 2.2. documents

#### 2.2.1. resources

##### 1. cluster

*Kubernetes cluster*

```shell
# 查看目标集群 NAME
kubectl config get-contexts | awk 'NR>1{print $2}' # kubernetes-admin@kubernetes

# login
argocd --insecure login localhost:8080 --username=admin --password=12345678

# cluster
argocd cluster add <KUBERNETES_NAME> --name <ALIAS_NAME> --kubeconfig .kube/cluster-dev -y
```

#### 2.2.2. api-resources

##### 1. AppProject

*项目名称。这是 ArgoCD 中应用程序的一种组织方式，类似于 kubernetes.namespace*

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: app
  namespace: argocd
spec:
  sourceRepos:
  - '*'
  destinations:
  # 目标集群 namespace
  - namespace: '*'
	# 目标集群 url
    server: '*'
    # 是否禁用目标集群的 SSL/TLS 验证
    insecure: 'true'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
```

##### 2. Application

*应用程序*

```yaml
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
  name: dev-auth
  namespace: argocd
  labels:
    env: dev
    app: auth
spec:
  # 项目名称
  project: map
  source:
  	# 应用程序路径
    repoURL: 'http://10.63.1.35/cloud/platform/task_hub.git'
    # 分支
    targetRevision: 'develop'
    # 路径
    path: 'manifests/dev'
  destination:
  	# 集群 url
    server: 'https://10.63.3.11:6443'
    # 部署到集群的目标命名空间
    namespace: 'map'
  syncPolicy:
    automated:
      prune: true
```

------

## 3. Getting Started

```shell
# 注释掉 'kind: Namespace', 改为手动创建。防止卸载时 ns 删除失败
ls *.yaml | while read file; do line=$(grep -n '^kind: Namespace' $file | awk -F ':' '{print $1}');  if [[ $line ]]; then echo "$file:$line"; fi; done

# 修改镜像拉取策略
ls *.yaml | while read file; do sed -i 's/imagePullPolicy: Always/imagePullPolicy: IfNotPresent/g' $file; done

# 禁用 argocd-notifications
grep -n 'argocd-notifications' argocd.yaml | grep -v '#' | awk -F ':' '{print $1}' | while read line; do echo argocd.yaml:$line; done
```

### 3.1. yaml

[argocd](argocd-custom.yaml) [tekton](tekton-custom.yaml)

- ##### ingress

  ```yaml
  ---
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: tekton
    namespace: tekton-pipelines
    annotations:
      kubernetes.io/ingress.class: "nginx"
  spec:
    rules:
    - host: tekton.devops.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: tekton-dashboard
              port:
                number: 9097
  ---
  kind: Ingress
  apiVersion: networking.k8s.io/v1
  metadata:
    name: argocd
    namespace: argocd
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/backend-protocol: HTTPS
      nginx.ingress.kubernetes.io/ssl-passthrough: 'true'
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  spec:
    rules:
    - host: argocd.devops.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: argocd-server
              port:
                number: 80
  ```

- ##### PersistentVolumeClaim

  - ##### tekton

    ```shell

    ```

  - ##### argocd

    ```shell
    # 修改 Deployment 为 StatefulSet
    grep -n '^  name: argocd-server$' argocd.yaml | awk -F ':' '{print $1}' | while read line; do if [[ $(sed -n "$[line+1]p" argocd.yaml) = "spec:" ]] && [[ $(sed -n "$[line+2]p" argocd.yaml) = "  selector:" ]]
    ; then echo argocd.yaml:$line; exit; fi; done
    # yaml
    ...
    kind: StatefulSet
    ...

    # 取消 volumes 挂载
    grep -n '^      serviceAccountName: argocd-server' argocd.yaml | awk -F ':' '{print $1}' | while read line; do echo argocd.yaml:$[line+1]; done
    # yaml
    ...
          volumes:
    #      - emptyDir: { }
    #        name: plugins-home
    ...

    # 添加 serviceName、volumeClaimTemplates
    sed -i 's/^          name: plugins-home/          name: data/' argocd.yaml
    grep -n '^  name: argocd-server$' argocd.yaml | awk -F ':' '{print $1}' | while read line; do if [[ $(sed -n "$[line+1]p" argocd.yaml) = "spec:" ]] && [[ $(sed -n "$[line+2]p" argocd.yaml) = "  selector:" ]]; then grep -n '^---' argocd.yaml | awk -F ':' '{print $1}' | while read item; do if [[ $item -gt $line ]]; then echo argocd.yaml:$item; exit; fi; done; fi; done
    # yaml
    ...
      volumeClaimTemplates:
      - kind: PersistentVolumeClaim
        apiVersion: v1
        metadata:
          name: data
        spec:
          accessModes:
          - ReadWriteOnce
          resources:
            requests:
              storage: 1024Mi
          storageClassName: juicefs-sc
          volumeMode: Filesystem
      serviceName: argocd-server
    ---
    ...
    ```

- ##### volume

  ```shell
  # localtime
  ls *.yaml | while read file; do sed -i -e '/^        env:/a\        - name: TZ\n          value: "Asia/Shanghai"' -e '/^        name: redis/a\        env:\n        - name: TZ\n          value: "Asia/Shanghai"' -e '/^          env:/a\            - name: TZ\n              value: "Asia/Shanghai"' $file; done

  # argocd-cluster-cm
  sed -i -e '/^          name: plugins-home/a\        - name: argocd-cluster-cm\n          mountPath: /home/argocd/.kube' -e '/^        name: plugins-home/a\      - name: argocd-cluster-cm\n        configMap:\n          name: argocd-cluster-cm' argocd.yaml
  ```

- ##### Secret

  ```shell
  # 修改 argocd admin 默认密码为 '12345678'
  sed -i "/^  name: argocd-secret/a\stringData:\n  admin.password: \"\$2a\$10\$ZlLYZpTmSOtJEvgdQp6qsuVysPrneGq4f7P1e0C6ch51ro5lJc8NW\"\n  admin.passwordMtime: \"$(date +%FT%T)\"" argocd.yaml
  ```

------

## 4. Error

### 1. Tekton

------

### 2. ArgoCD

```shell
# argocd-ui
# username: admin


# 自动登录
kubectl -n argocd exec $(kubectl -n argocd get pod | grep argocd-server | awk '{print $1}') -- bash -c "echo 'alias l=\"ls -alh\"' > .bashrc; echo 'argocd --insecure login localhost:8080 --username=admin --password=12345678' >> .bashrc"

# 默认密码
kubectl -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo

# 修改密码
kubectl -n argocd exec -it $(kubectl -n argocd get pod | grep argocd-server | awk '{print $1}') -- bash
# user=admin; password=<currentPassword>; newPassword=12345678
# argocd --insecure login localhost:8080 --username=$user --password=$password
# argocd account update-password --current-password=$password --new-password=$newPassword

# 重置密码
# generating a bcrypt hash
kubectl -n argocd exec -it $(kubectl -n argocd get pod | grep argocd-server | awk '{print $1}') -- bash -c 'argocd account bcrypt --password <password>' && echo
# to apply the new password hash
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"admin.password": "<password-hash>", "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'
```
