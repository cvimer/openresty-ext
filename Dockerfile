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

RUN ./configure \
    --add-module=../ngx_http_proxy_connect_module \
    --add-module=../nginx-upsync-module \
    --add-module=../nginx-stream-upsync-module
    
RUN make && make install

WORKDIR /usr/local/openresty/nginx

ADD ./nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

ENTRYPOINT ["/usr/local/openresty/nginx/sbin/nginx"]

CMD ["-g", "daemon off;"]