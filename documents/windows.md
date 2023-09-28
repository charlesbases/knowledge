## applications

- ##### chrome

  ```shell
  # --incognito
  # 隐身模式启动
  
  # --ignore-certificate-errors
  # 忽略证书错误
  
  # --disable-background-networking
  # 禁用版本检查
  ```

  

---

## networks

- 刷新 dns 缓存

  ```shell
  ipconfig /flushdns
  ```

- 禁用网卡

  ```shell
  netsh interface set interface "INTERNAL" disable
  ```

- 启用网卡

  ```shell
  netsh interface set interface "EXTERNAL" enable
  ```

------

## mkilnk

```shell
# cmd
mklink /D "[链接名称]" "目标路径"
```

------

## others

- 在文件资源管理器中打开当前路径

  ```shell
  start "" .
  ```

- 在 GoLand 中打开当前路径

  ```shell
  start "" "D:\Programs\JetBrains\GoLand 2022.2.5\bin\goland64.exe" .
  ```

- ping

  ```shell
  for ip in {1..254}; do ping -n 1 -w 30 10.112.27.$ip; done
  ```

