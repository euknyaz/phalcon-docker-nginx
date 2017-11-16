# Phalcon Docker Nginx starter app
Docker image based on:
- Ubuntu 16.04 
- Phalcon 3
- PHP 7.1
- Nginx + PHP FPM
- Supervisord

## Dependencies
Docker. For installation instructions check https://docs.docker.com/engine/installation/

## Configuration
- To change the mapped port look in docker-compose.yaml
- Default mapped port is 9000. 
- Check /build directory for PHP and Nginx tweaking.

## Docker-compose

### Build Docker Image
```bash
docker-compose build
```
This will build the base image and run the container daemonized.

### Push Docker Image to Docker Hub
```bash
docker-compose push
```
This will build and push container image to docker hub repository.

### Start the container
```bash
docker-compose up -d
```
This will run container in the backgroun and build image if necessary.
Check http://localhost:9000

### Enter the container console
```bash
docker exec -it web bash
> # important commands and files inside container
> /etc/init.d/nginx reload
> /etc/init.d/php7.0-fpm restart
> ls -la /var/www/html
> ls /etc/nginx/sites-enabled/default
> ls /etc/php/7.1/fpm/php.ini
```

### Map html dir of container to your local dir
If you want map /var/www/html dir to your local dir ./html outside of container
then run edit docker-compose.yml and uncomment the following line:
```
#       - ./html:/var/www/html
```
and restart container with the following commands(it's safe and should not affect your files):
```bash
docker-compose down
docker-compose up -d
```
Create file ./html/index.php with content:
```php
<?php phpinfo(); ?>
```
Check http://localhost:9000 to see phpinfo output.

### Stop the container
```bash
docker-compose down
```

### View docker logs
```bash
docker logs web
```
