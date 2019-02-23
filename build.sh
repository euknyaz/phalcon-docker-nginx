docker build --no-cache -t euknyaz/nginx-geoip-php-redis-lua . \
&& docker tag euknyaz/nginx-geoip-php-redis-lua euknyaz/nginx-geoip-php-redis-lua:1.0 \
&& docker push euknyaz/nginx-geoip-php-redis-lua:1.0 \
&& docker tag euknyaz/nginx-geoip-php-redis-lua euknyaz/nginx-geoip-php-redis-lua:latest \
&& docker push euknyaz/nginx-geoip-php-redis-lua:latest
