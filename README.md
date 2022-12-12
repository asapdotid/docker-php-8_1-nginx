# Docker image PHP-FPM 8.1 & Nginx 1.22 (Alpine Linux)

![Docker Automated build](https://img.shields.io/docker/automated/asapdotid/php-nginx?style=flat-square)
![docker hub](https://img.shields.io/docker/pulls/asapdotid/php-nginx.svg?style=flat-square)
![docker hub](https://img.shields.io/docker/stars/asapdotid/php-nginx.svg?style=flat-square)
![Github](https://img.shields.io/github/stars/asapdotid/docker-php-nginx.svg?style=flat-square)

## Overview

This is a Dockerfile/image to build a container for PHP-FPM and NGINX. The container also has the ability to update templated files with variables passed to docker in order to update your code and settings. There is support for custom nginx configs, core nginx/PHP variable overrides for running preferences for local volume support.

Custom from original `asapdotid/php-nginx`:

-   Timezone (default: Asia/Jakarta)
-   PHP-FPM 8.1.x
-   nginx 1.22.x (Stable version)
    -   Snippets for handling errors
    -   Custom errors template: `404`, `403` & `502`
-   Supervisor

PHP Extentions:

-   composer
-   apcu
-   gd
-   mysqli
-   pdo_mysql
-   intl
-   exif
-   zip
-   imagick
-   redis
-   opcache
-   igbinary
-   msgpack

## Environment Variables

| Environment     | Default      | Description                             |
| --------------- | ------------ | --------------------------------------- |
| TIMEZONE        | Asia/Jakarta | Timezone for OS and PHP                 |
| APPLICATION_ENV | develpment   | For build `development` or `production` |

## Versioning

| Docker Tag | Git Release | Nginx Version | PHP Version | Alpine Version |
| ---------- | ----------- | ------------- | ----------- | -------------- |
| latest     | Main Branch | 1.22.1        | 8.1.13      | 3.17           |
| 1.0.0      | Main Branch | 1.22.1        | 8.1.13      | 3.17           |

### Links

-   [https://github.com/asapdotid/docker-php-nginx](https://github.com/asapdotid/docker-php-nginx)
-   [https://registry.hub.docker.com/u/asapdotid/docker-php-nginx/](https://registry.hub.docker.com/u/asapdotid/docker-php-nginx/)

## Quick Start

To pull from docker hub:

```
docker pull asapdotid/docker-php-nginx:${IMAGE_VERSION}
```

### Running

To simply run the container:

```
docker run -d asapdotid/docker-php-nginx:latest
```

You can then browse to `http://<DOCKER_HOST>` to view the default install files. To find your `DOCKER_HOST` use the `docker inspect` to get the IP address (normally 172.17.0.2)

## Docker Compose setup

```yaml
version: "3"

services:
    laravel:
        image: asapdotid/docker-php-nginx:latest
        environment:
            TZ: "Asia/Jakarta"
            WEBROOT: "/app/public"
            # SKIP_COMPOSER: 1 # skip install composer
            APPLICATION_ENV: "production" # development|production
        ports:
            - "${APP_PORT:-8080}:8080"
        extra_hosts:
            - "host.docker.internal:host-gateway"
        volumes:
            - ".:/app"
            - "./config/nginx/nginx-site.conf:/etc/nginx/conf.d/default.conf" # Nginx proxy config
            - "./config/supervisor/laravel-supervisor.conf:/etc/supervisor/conf.d/laravel-supervisor.conf" # Supervisor config
        network:
            - app-tire

networks:
    app-tire:
        driver: bridge
```

### Nginx Config (`nginx-site.conf`)

```ini
# Default server definition
server {
    listen 8080 default_server;
    server_name _;

    sendfile off;

    # Increase proxy buffers for large requests
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;

    # Upload limit
    client_max_body_size 2M;
    client_body_buffer_size 128k;

    root /app;
    index index.php index.html;

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to index.php
        try_files $uri $uri/ /index.php?q=$uri&$args;
    }

    # Redirect server error pages to the static page /50x.html
  	include /etc/nginx/snippets/error.conf;

    # Pass the PHP scripts to PHP-FPM listening on 127.0.0.1:9000
    location ~ [^/]\.php(/|$) {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param SCRIPT_NAME $fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_index index.php;
        include fastcgi_params;
    }

    location ~* \.(jpg|jpeg|gif|png|css|js|ico|webp|tiff|ttf|svg)$ {
        expires 5d;
    }

    # deny access to . files, for security
	location ~ /\. {
        log_not_found off;
        deny all;
	}

	location ^~ /.well-known {
        allow all;
        auth_basic off;
    }

    # block access to sensitive information about git
	location /.git {
        deny all;
        return 403;
    }
}
```

### Supervisor Config for Laravel (`laravel.conf`)

Place config to `/etc/supervisor/conf.d/laravel.conf`

```ini
[group:laravel-worker]
priority=999
programs=laravel-schedule,laravel-notification,laravel-queue

[program:laravel-schedule]
numprocs=1
autostart=true
autorestart=true
redirect_stderr=true
process_name=%(program_name)s_%(process_num)02d
command=/usr/local/bin/php /var/www/html/artisan schedule:run
stdout_logfile=/var/log/nginx/schedule.log

[program:laravel-notification]
numprocs=1
autostart=true
autorestart=true
redirect_stderr=true
process_name=%(program_name)s_%(process_num)02d
command=/usr/local/bin/php /var/www/html/artisan notification:worker
stdout_logfile=/var/log/nginx/notification.log

[program:laravel-queue]
numprocs=5
autostart=true
autorestart=true
redirect_stderr=true
process_name=%(program_name)s_%(process_num)02d
command=/usr/local/bin/php /var/www/html/artisan queue:work sqs --sleep=3 --tries=3
stdout_logfile=/var/log/nginx/worker.log
```

## License

MIT / BSD

## Author Information

This Code was created in 2022 by [Asapdotid](https://github.com/asapdotid).
