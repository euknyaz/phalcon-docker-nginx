FROM phusion/baseimage

RUN curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | bash

RUN echo deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx >>/etc/apt/sources.list
RUN echo deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx >>/etc/apt/sources.list
RUN curl -s http://nginx.org/keys/nginx_signing.key >/tmp/nginx_signing.key
RUN apt-key add /tmp/nginx_signing.key

RUN apt-get install -y python-software-properties
RUN add-apt-repository -y ppa:ondrej/php

RUN	\
	apt-get update \
	&&	apt-get -y upgrade \
	&&	apt-get update --fix-missing

RUN \
  	apt-get install -y \
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
	    php7.1-phalcon

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN service php7.1-fpm start

RUN \
  	apt-get install -y \
	    nodejs \
	    npm \
	    git

RUN \
  	apt-get install -y \
	    nginx-full \
	    supervisor

RUN apt-get clean
RUN apt-get autoclean

COPY build/.bashrc /root/.bashrc
COPY build/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY build/nginx.conf /etc/nginx/sites-enabled/default
COPY build/php.ini /etc/php/7.1/fpm/php.ini

ADD src /var/www/html

EXPOSE 80 443
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
