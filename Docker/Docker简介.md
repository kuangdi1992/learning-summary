# Docker概述
## Docker为什么会出现？
发布一个项目，例如(jar + （ jdk、MySql）)，能不能带上环境安装打包，而且在配置的时候回很复杂。
之前是开发出应用，运维来做部署，但是有docker之后，开发人员直接完成开发打包部署上线，一套流程完成。
以java为例：
    java --- jar(环境) --- 打包项目带上环境（镜像【重要】） ---  Docker仓库（商店） --- 下载我们发布的镜像 --- 直接运行
# Docker安装
# Docker命令
# Docker镜像
# 容器数据卷
# DockerFile
# Docker网络原理