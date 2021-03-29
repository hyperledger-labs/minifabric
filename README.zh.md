# 迷你Fabric

如果您想学习Hyperledger Fabric或开发智能合约，或者只是想了解
Hyperledger Fabric，迷你Fabric是让您快速开始的良好工具。迷
你Fabric可以用来在配置很低的电脑像VirtualBox上的一个虚机上为
您搭建Fabric网络，但也可以在多个大型机器上部署多节点Fabric网络。


## 功能特性

迷你Fabric虽然轻量，但它可以让您体验Hyperledger Fabric的全部
功能

- 通道创建和更新
- 节点加入通道
- 链码安装，审批，提交定义，初始化
- 链码调用，查询
    - [可选项] 私有数据集
- 区块查询

## 必要的运行环境

操作系统支持 | 存储空间 |
|---- | ---- |
Linux | 5GB |
OS X |  |
Windows |   |  

- [docker](https://www.docker.com/)（18.03或更高版本）

## 入门指引

如果您想在动手之前了解更多信息, 您可以
- 观看 [系列视频](https://www.youtube.com/playlist?list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO) 
- 阅读 [Hyperledger博文](https://www.hyperledger.org/blog/2020/04/29/minifabric-a-hyperledger-fabric-quick-start-tool-with-video-guides) 


对于那些急于上手的人，请按照以下步骤开始操作

### 1. 下载工具
##### 如果你使用Linux或OS X系统
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/yxa2q6yr && chmod +x minifab
```

##### 如果你使用Windows 10系统
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/y3gupzby
```

##### 让minifab在整个系统里使用起来更容易

为了使用方便，你可以把minifab (Linux 和 OS X) 或 minifab.cmd (Windows) 脚本移到在系统路径里的一个目录， 这样在执行minifab各种操作时你就不需要指定这个脚本的路径了.

### 2. 搭建Fabric网络:

```
minifab up
```

### 3. 删除Fabric网络:
```
minifab down
```

### 4. 如果想要更多了解minifabric的强大功能:
```
minifab
```

### 注意：如果你从hub.docker.com下载docker镜像有困难
你可以从 https://share.weiyun.com/5Updupi 下载(需要登录你自己在微云上的账户)压缩的docker镜像，然后使用下列命令在本地生成docker镜像
```
docker load < fabric_2.1.tar.gz
docker load < minifab.tar.gz
```
## 文档
想进一步了解MiniFabric？请参考[文档目录](./docs/README.md)