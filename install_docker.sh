#!/bin/bash

# 检查系统是否已经安装 Docker
if command -v docker &>/dev/null; then
    echo "检测到系统已安装 Docker，版本信息如下："
    docker --version
    echo "无需重复安装，退出脚本。"
    exit 0
fi

# 获取当前脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 自动检测系统架构
ARCH=$(uname -m)

# 根据系统架构选择安装目录和 Docker 二进制包
if [[ "$ARCH" == "x86_64" ]]; then
    INSTALL_DIR="$SCRIPT_DIR/docker-binaries/x86_64"
    echo "检测到系统架构为 x86_64，准备安装 Docker x86_64 版本。"
elif [[ "$ARCH" == "aarch64" ]]; then
    INSTALL_DIR="$SCRIPT_DIR/docker-binaries/aarch64"
    echo "检测到系统架构为 aarch64，准备安装 Docker arm64 版本。"
else
    echo "不支持的架构：$ARCH"
    exit 1
fi

# 检查 Docker 二进制包是否存在
if [ ! -f "$INSTALL_DIR/docker.tgz" ]; then
    echo "错误：找不到 Docker 二进制包 docker.tgz。请确保已先运行 download.sh 下载相应架构的 Docker 二进制包。"
    exit 1
fi

# 解压 docker.tgz 文件到临时目录
echo "正在解压 Docker 离线包..."
TEMP_DIR=$(mktemp -d)
tar xfv "$INSTALL_DIR/docker.tgz" -C "$TEMP_DIR"

# 进入解压后的目录
cd "$TEMP_DIR"

# 复制 Docker 二进制文件到 /usr/bin 目录
echo "正在安装 Docker 二进制文件..."
cp -rf docker/* /usr/bin/

# 复制 systemd 服务和 socket 文件
echo "正在配置 systemd 服务和 socket 文件..."
cp -rf "$SCRIPT_DIR/docker.service" /etc/systemd/system/
cp -rf "$SCRIPT_DIR/docker.socket" /etc/systemd/system/

# 提示用户输入 Docker 数据存储路径，默认是 /var/lib/docker
echo -n "请输入 Docker 数据存储路径（默认：/var/lib/docker）："
read DOCKER_DATA_DIR

# 如果用户没有输入路径，则使用默认路径
DOCKER_DATA_DIR=${DOCKER_DATA_DIR:-/var/lib/docker}

echo "Docker 数据存储路径设置为: $DOCKER_DATA_DIR"

# 修改 docker.service 文件，添加 --data-root 参数来指定数据目录
sed -i "s|^ExecStart=.*|ExecStart=/usr/bin/dockerd --default-ulimit nofile=1048576:1048576 --data-root=$DOCKER_DATA_DIR|g" /etc/systemd/system/docker.service

# 重新加载 systemd 配置文件，启动并设置 Docker 自启动
echo "正在启动 Docker 并设置自启动..."
systemctl daemon-reload
systemctl start docker
systemctl enable docker

echo "Docker 安装完成！"

# 清理临时目录
echo "清理临时目录..."
cd "$SCRIPT_DIR"
rm -rf "$TEMP_DIR"

echo "安装完成，Docker 已成功安装并启动！"

