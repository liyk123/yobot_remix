#!/bin/bash

# 设置工作目录
WORKDIR="/yobot/src/client"
cd $WORKDIR

# 设置代理环境变量
export HTTP_PROXY=${HTTP_PROXY:-""}
export HTTPS_PROXY=${HTTPS_PROXY:-""}

# 设置 UID 和 GID 环境变量
export UID=${UID:-1000}
export GID=${GID:-1000}

# 启动主程序并记录 PID
gosu $UID:$GID python3 main.py -g &
echo $! > yobotg.pid

loop=true
while $loop
do
    loop=false
    wait
    if [ -f .YOBOT_RESTART ]
    then
        loop=true
        rm .YOBOT_RESTART
    fi
done
