# Docker image PHP-FPM 8.1 & Nginx 1.22 (Alpine Linux)

![Docker Automated build](https://img.shields.io/docker/automated/asapdotid/php-nginx?style=flat-square)
![docker hub](https://img.shields.io/docker/pulls/asapdotid/php-nginx.svg?style=flat-square)
![docker hub](https://img.shields.io/docker/stars/asapdotid/php-nginx.svg?style=flat-square)
![Github](https://img.shields.io/github/stars/asapdotid/docker-php-nginx.svg?style=flat-square)

## Overview

This is a Dockerfile/image to build a container for PHP-FPM and NGINX base from (`webdevops/php:8.1-alpine`) [doc](https://github.com/webdevops/Dockerfile/tree/master/docker/php). The container also has the ability to setup with composer

Custom from original `asapdotid/php-nginx`:

-   Timezone (default: Asia/Jakarta)
-   PHP-FPM 8.1.x
-   nginx 1.22.x (Stable version)
    -   Snippets for handling errors
    -   Custom errors template: `404`, `403` & `502`
-   Supervisor
-   Composer

## Environment Variables

| Environment     | Default      | Description                                       |
| --------------- | ------------ | ------------------------------------------------- |
| APPLICATION_UID | 1000         | PHP-FPM UID (Effective user ID)                   |
| APPLICATION_GID | 1000         | PHP-FPM GID (Effective group ID)                  |
| TIMEZONE        | Asia/Jakarta | Timezone for OS and PHP                           |
| APP_ENV         | develpment   | For build `development` or `production`           |
| SKIP_COMPOSER   | 0            | Support for composer install in application mount |

## Versioning

| Docker Tag | Git Release | Nginx Version | PHP Version | Alpine Version |
| ---------- | ----------- | ------------- | ----------- | -------------- |
| latest     | Main Branch | 1.22.1        | 8.1.13      | 3.17           |
| 1.0.1      | Main Branch | 1.22.1        | 8.1.13      | 3.17           |

### Links

-   [https://github.com/asapdotid/docker-php-nginx](https://github.com/asapdotid/docker-php-nginx)
-   [https://registry.hub.docker.com/u/asapdotid/php-nginx/](https://registry.hub.docker.com/u/asapdotid/php-nginx/)

## Quick Start

To pull from docker hub:

```
docker pull asapdotid/php-nginx:${IMAGE_VERSION}
```

### Running

To simply run the container:

```
docker run -d asapdotid/php-nginx:latest
```

You can then browse to `http://<DOCKER_HOST>` to view the default install files. To find your `DOCKER_HOST` use the `docker inspect` to get the IP address (normally 172.17.0.2)

## Docker Compose setup

```yaml
version: "3"

services:
    laravel:
        image: asapdotid/php-nginx:latest
        environment:
            - TIMEZONE=Asia/Jakarta
            - WEB_DOCUMENT_ROOT=/app/public
            - WEB_ALIAS_DOMAIN=app.domain.com
            - APP_ENV=production # development | production
            # - SKIP_COMPOSER=1 # skip install composer 0 | 1
        ports:
            - "${HTTP_PORT:-8080}:8080"
            - "${HTTPS_PORT:-9443}:9443"
        extra_hosts:
            - "host.docker.internal:host-gateway"
        volumes:
            - ".:/app"
            - "./config/supervisor/laravel.conf:/opt/docker/etc/supervisor.d/laravel.conf" # Supervisor sample config
        network:
            - app-tire

networks:
    app-tire:
        driver: bridge
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
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:laravel-notification]
numprocs=1
autostart=true
autorestart=true
redirect_stderr=true
process_name=%(program_name)s_%(process_num)02d
command=/usr/local/bin/php /var/www/html/artisan notification:worker
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:laravel-queue]
numprocs=5
autostart=true
autorestart=true
redirect_stderr=true
process_name=%(program_name)s_%(process_num)02d
command=/usr/local/bin/php /var/www/html/artisan queue:work sqs --sleep=3 --tries=3
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
```

## License

MIT / BSD

## Author Information

This Code was created in 2022 by [Asapdotid](https://github.com/asapdotid).
