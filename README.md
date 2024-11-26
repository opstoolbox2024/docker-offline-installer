```markdown
工作中经常需要给客户的服务器安装Docker，由于大部分客户服务器均没有外网，操作系统版本、硬件架构也是多种多样，
于是就写了一个脚本用于下载Docker安装包、部署Docker。

1.这个项目用于从清华源下载Docker离线安装包，包括x86和aarch64两种架构。并且提供了Docker的离线安装/卸载脚本。

2.目录结构介绍
.
├── docker-binaries      #下载的二进制包存放目录
│   ├── aarch64          #aarch64包存放目录
│   │   └── docker.tgz   #aarch64安装包
│   └── x86_64           #x86包存放目录
│       └── docker.tgz   #x86安装包
├── docker.service       #Linux系统中的Docker服务文件
├── docker.socket        #Linux系统中的docker socket文件
├── download.sh          #下载二进制包脚本
├── install_docker.sh    #安装Docker脚本
├── README.md            #README
└── uninstall_docker.sh  #卸载Docker脚本

3.下载代码
git clone https://github.com/opstoolbox2024/docker-offline-installer.git

4.下载Docker离线安装包。
在有外网的服务器上下载。然后再拷贝到内网机器上安装
执行download.sh脚本根据提示输入版本号。

./download.sh 
请输入需要下载的 Docker 版本号（例如 24.0.6）： 24.0.7

5.离线安装Docker
执行install_docker.sh脚本，会提示输入Docker数据存放路径，默认Docker数据是存放在/var/lib/docker目录下。
但是实际场景服务器通常会挂载数据盘。例如:/data。那我们可以将Docker的数据路径配置为：/data/docker

./install_docker.sh
检测到系统架构为 x86_64，准备安装 Docker x86_64 版本。
正在解压 Docker 离线包...
docker/
docker/docker
docker/docker-init
docker/dockerd
docker/runc
docker/ctr
docker/containerd-shim-runc-v2
docker/containerd
docker/docker-proxy
正在安装 Docker 二进制文件...
正在配置 systemd 服务和 socket 文件...
请输入 Docker 数据存储路径（默认：/var/lib/docker）：/data/docker
Docker 数据存储路径设置为: /data/docker
正在启动 Docker 并设置自启动...
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /etc/systemd/system/docker.service.
Docker 安装完成！
清理临时目录...
安装完成，Docker 已成功安装并启动！
