## 1. gotest

### 1.2. cover

```shell
# 简略信息
go test -cover

# 详细信息
go test -coverprofile=cover.out && go tool cover -html=cover.out -o cover.html
```

------

## 2. build

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

  ```
  go build -ldflags '-X main.version=1.0.0'
  ```



------

## 3. benchmark

```shell
go test -test.bench=. -test.count=1 -test.benchmem .
```

### 3.1 pprof

```http
https://zhuanlan.zhihu.com/p/396363069
```

- ##### graphviz

  ```http
  https://graphviz.org/download
  ```

- ##### benchmark

  ```shell
  go test -test.bench=. -memprofile=mem.out .
  go tool pprof -http=:8080 mem.out
  ```



------


## * * * * * *

## notes

```shell
# 字符串拼接效率
# strings.Builder = strings.Join > "+" > fmt.Sprintf
# 1、strings.Join 底层使用 strings.Builder 实现， 字符串拼接时，调用 'Builder.Grow' 可实现只分配一次内存；
# 2、一个 "+" 分配一次内存， 在进行俩个字符串拼接时，可使用 "+"，其他情况使用 strings.Builder
```

```shell
# 使用 map 或 switch case进行情况判断时，map 性能更占优
```
