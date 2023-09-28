## 1. tag

- ##### 添加

  ```shell
  # new tag
  git tag -a "v1.0.0" -m "release v1.0.0"
  
  # push
  git push --tags
  
  #
  v=v1.0.0; git tag -a "$v" -m "release $v" && git push --tags
  ```

- ##### 删除

  ```shell
  # 删除本地
  git tag -d v1.0.0
  
  # 删除远程
  git push origin :refs/tags/v1.0.0
  
  #
  v=v1.0.0; git tag -d $v && git push origin :refs/tags/$v	
  ```

--------

## 2. pull

```shell
# git pull 下载小文件时，禁用 gzip  来提高下载速度
git clone -c core.compression=0 <repo.url>
```

--------

## 3. push

```shell
# 推送到远程分支
git push origin <local-branch>:<remote-branch>
```

--------

## 2. branch

```shell
# 分支关联
git branch --set-upstream-to=<remote-branch> <local-branch>
```

- ##### 删除

  ```shell
  # 本地分支
  git branch -d branch
  
  # 远程分支
  git push origin -d branch
  
  #
  b=branch; git push origin --delete $b && git branch -d $b
  ```

--------

## 3. submodule

- ##### 添加

  ```shell
  git submodule add url [path/module]
  ```

- ##### 更新

  ```shell
  git submodule update --remote
  ```

- ##### 删除

  ```shell
  # 删除 git 缓存
  git rm --cached [module]
  
  # 删除 .gitmodules 子模块信息
  [submodule "module"]
  
  # 删除 .git/config 子模块信息
  [submodule "module"]
  
  # 删除 .git 子模块文件
  rm -rf .git/modules/[model]
  ```

--------

## 4. [gitconfig](.share/gitconfig)

--------

## 5. git-for-windows

- ##### vimrc

  ```shell
  
  ```

- ##### inputrc

  ```shell
  sed -i -s 's/set bell-style visible/set bell-style none/g' inputrc
  ```

  

- ##### profile.d

  - [git-prompt.sh](.share/scripts/git-prompt.sh)

------

## 99. others

```shell
# 查看当前分支名
git rev-parse --abbrev-ref HEAD

# 查看当前分支 hash
git rev-parse HEAD

# 查看当前分支 hash(short)
git rev-parse --short HEAD
```

