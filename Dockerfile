FROM phusion/baseimage

# skip phalcon
# RUN curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | bash

RUN echo deb http://nginx.org/packages/ubuntu/ xenial nginx >>/etc/apt/sources.list
RUN echo deb-src http://nginx.org/packages/ubuntu/ xenial nginx >>/etc/apt/sources.list
RUN curl -s http://nginx.org/keys/nginx_signing.key >/tmp/nginx_signing.key
RUN apt-key add /tmp/nginx_signing.key

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DE742AFA
## RUN echo deb-src http://nginx.org/packages/mainline/debian/ xenial nginx > /etc/apt/sources.list.d/maxmind.list
## RUN echo deb http://ppa.launchpad.net/maxmind/ppa/ubuntu xenial main > /etc/apt/sources.list.d/maxmind.list

RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php

RUN	apt-get update
## RUN	apt-get -y upgrade 
RUN	apt-get update --fix-missing

RUN apt-get install -y python-software-properties
RUN apt-get install -y language-pack-en-base


RUN apt-get install -y --fix-missing libmaxminddb0 libmaxminddb-dev mmdb-bin

# Installing nginx
ENV NGINX_VERSION=1.14.2-1~xenial
ENV NGINX_DIR=1.14.2

RUN apt-get install -y --fix-missing git dpkg-dev
RUN apt-get install -y --fix-missing nginx=${NGINX_VERSION}

# Install LuaJIT/OpenResty
## RUN apt-get install -y --fix-missing luajit libluajit-5.1-common libluajit-5.1-dev
ENV LUAJIT2_VERSION 2.1-20190221
RUN set -x \
  && apt-get install -y --fix-missing build-essential \
  && cd /usr/src \
  && curl -k -s -L https://github.com/openresty/luajit2/archive/v${LUAJIT2_VERSION}.tar.gz > luajit2-${LUAJIT2_VERSION}.tar.gz \
  && tar -xzvf luajit2-${LUAJIT2_VERSION}.tar.gz \
  && cd luajit2-${LUAJIT2_VERSION} \
  && make -j2 \
  && make install

# Install nginx extension for GeoIP2. See: https://github.com/leev/ngx_http_geoip2_module
# We have to recompile nginx. To keep things simple we use the deb file + the same compile options as before.
#
# NGINX_VERSION is coming from the base container
#
# FIXME: use nginx -V to use current compile options
#        NGINX_OPTIONS=$(2>&1 nginx -V | grep 'configure arguments' | awk -F: '{print $2}') \
RUN set -x \
  && cd /usr/src \
  && git clone https://github.com/leev/ngx_http_geoip2_module \
  && git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module \
  && git clone https://github.com/openresty/lua-nginx-module \
  && DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get source nginx=${NGINX_VERSION} \
  && apt-get install -y --fix-missing libpcre3-dev zlib1g-dev libssl-dev libxml2-dev \
     libxslt-dev libgd3 libgd-dev libgeoip1 libgeoip-dev geoip-bin libxml2 libxml2-dev libxslt1.1 libxslt1-dev \
  && cd nginx-${NGINX_DIR} \
  && export LUAJIT_LIB=/usr/local/lib \
  && export LUAJIT_INC=/usr/local/include/luajit-2.1 \
  && ./configure \
    --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIE' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
    --add-module=/usr/src/ngx_http_geoip2_module \
    --add-module=/usr/src/ngx_http_substitutions_filter_module \
    --add-module=/usr/src/lua-nginx-module \
  && make \
  && make install \
  && strip /usr/sbin/nginx* \
  && rm -rf /usr/src/*

# Install NodeJS / Yarn / Lessc
RUN     apt-get install -y --fix-missing \
	    php7.1 \
	    php7.1-bcmath \
	    php7.1-cli \
	    php7.1-common \
	    php7.1-fpm \
	    php7.1-gd \
	    php7.1-gmp \
	    php7.1-intl \
	    php7.1-json \
	    php7.1-mbstring \
	    php7.1-mcrypt \
	    php7.1-mysqlnd \
	    php7.1-opcache \
	    php7.1-pdo \
	    php7.1-xml \
	    php7.1-mcrypt \
	    php7.1-curl \
	    php7.1-zip \
	    php7.1-soap \
	    php7.1-pgsql \
  	    php-igbinary \
	    php-redis

# skip-ext
#	    php7.1-phalcon \
           

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN service php7.1-fpm start

# libnginx-mod-http-lua 
RUN apt-get install -y \
	    redis-server \
	    supervisor

RUN apt-get install -y \
	    postgresql \
            postgresql-contrib

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done

ENV NODE_VERSION 8.12.0

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 1.9.4

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

RUN yarn global add less
RUN yarn global add less-plugin-clean-css

# end of Install NodeJS / Yarn / Lessc
RUN apt-get clean
RUN apt-get autoclean
RUN apt-get remove --purge -y \
    build-essential \
    dpkg-dev

COPY build/.bashrc /root/.bashrc
COPY build/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY build/nginx_main.conf /etc/nginx/nginx.conf
COPY build/nginx.conf /etc/nginx/sites-enabled/default
COPY build/php.ini /etc/php/7.1/fpm/php.ini
COPY build/redis.conf /etc/redis/redis.conf
COPY build/sysctl.conf /etc/sysctl.conf
COPY build/start.sh /bin/start.sh

ADD src /var/www/html

EXPOSE 80 81 82 83 84 85 443 6379
CMD ["start.sh"]
