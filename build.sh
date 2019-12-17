docker build --no-cache -t euknyaz/nginx-php-redis .
docker tag euknyaz/nginx-php-redis euknyaz/nginx-php-redis:1.1
docker push euknyaz/nginx-php-redis:1.1
