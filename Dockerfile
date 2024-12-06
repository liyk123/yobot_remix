FROM python:3.8-slim-bullseye

# 设置工作目录
WORKDIR /yobot/src/client

# 设置默认的环境变量
ENV HTTP_PROXY=""
ENV HTTPS_PROXY=""
ENV UID=99
ENV GID=100
ENV PATH="/home/user/.local/bin:${PATH}"

# 复制文件
COPY ./yobot/ /yobot/
COPY ./entrypoint.sh /entrypoint.sh

# 创建用户和组
RUN groupadd -g $GID user && useradd -u $UID -g $GID -m user

# 设置系统代理
RUN if [ -n "$HTTP_PROXY" ]; then \
        echo "Acquire::http::Proxy \"$HTTP_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf; \
    fi \
    && if [ -n "$HTTPS_PROXY" ]; then \
        echo "Acquire::https::Proxy \"$HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf; \
    fi

# 安装依赖
RUN sed -i 's/http:\/\/deb.debian.org/http:\/\/ftp.cn.debian.org/g' /etc/apt/sources.list \
    && sed -i 's/http:\/\/security.debian.org/http:\/\/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt install build-essential -y \
    && apt-get install -y --no-install-recommends gosu iputils-ping git curl \
    && apt-get autoremove \
    && apt-get clean \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' >/etc/timezone \
    && chown -R user:user /yobot \
    && cd /yobot/src/client \
    && gosu user pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && gosu user pip install --upgrade pip \
    && gosu user pip install -r requirements.txt --no-cache-dir \
    && chown user:user /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

# 运行应用程序
ENTRYPOINT ["/docker-entrypoint.sh"]