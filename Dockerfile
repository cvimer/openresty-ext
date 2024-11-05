ARG ARG_BASE_IMAGE=docker.io/library/debian:12.7

FROM ${ARG_BASE_IMAGE} AS builder

RUN sed -i 's#deb.debian.org#mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list.d/*
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    patch cmake gcc libpcre3-dev \
    libssl-dev perl build-essential curl zlib1g-dev
COPY ./openresty/ /usr/local/src/
COPY ./modules/ /usr/local/src/

ENV RESTY_VERSION=1.27.1.1
ENV NGX_VERSION=1.27.1

WORKDIR /usr/local/src/
RUN tar xf openresty-${RESTY_VERSION}.tar.gz
WORKDIR /usr/local/src/openresty-${RESTY_VERSION}


RUN patch -d bundle/nginx-${NGX_VERSION}/ -p 1 < ../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch
# RUN patch -d bundle/nginx-${NGX_VERSION}/ -p 1 < ../nginx_upstream_check_module/check_1.20.1+.patch
# RUN patch -d bundle/nginx-${NGX_VERSION}/ -p 1 < ../nginx_tcp_proxy_module/tcp.patch


RUN ./configure \
    --add-module=../ngx_http_proxy_connect_module \
    --add-module=../nginx-upsync-module \
    --add-module=../nginx-stream-upsync-module 
    # --add-module=../nginx_upstream_check_module \
    # --add-module=../nginx_tcp_proxy_module \
    

# RUN patch -d build/nginx-${NGX_VERSION}/ -p 1 < ../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch

RUN make && make install