FROM phusion/baseimage

# skip phalcon
# RUN curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | bash

RUN echo deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx >>/etc/apt/sources.list
RUN echo deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx >>/etc/apt/sources.list
RUN curl -s http://nginx.org/keys/nginx_signing.key >/tmp/nginx_signing.key
RUN apt-key add /tmp/nginx_signing.key

RUN	apt-get update

RUN apt-get install -y python-software-properties
RUN apt-get install -y language-pack-en-base
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php

RUN	\
	apt-get update \
	&&	apt-get -y upgrade \
	&&	apt-get update --fix-missing

RUN \
  	apt-get install -y --fix-missing \
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

RUN apt-get install -y \
	    git

# libnginx-mod-http-lua 
RUN apt-get install -y \
	    nginx-full \
	    redis-server \
	    supervisor

RUN apt-get install -y \
	    postgresql \
            postgresql-contrib

# Install NodeJS / Yarn / Lessc

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

COPY build/.bashrc /root/.bashrc
COPY build/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY build/nginx.conf /etc/nginx/sites-enabled/default
COPY build/php.ini /etc/php/7.1/fpm/php.ini
COPY build/redis.conf /etc/redis/redis.conf
COPY build/sysctl.conf /etc/sysctl.conf
COPY build/start.sh /bin/start.sh

ADD src /var/www/html

EXPOSE 80 81 82 83 84 85 443 6379
CMD ["start.sh"]
