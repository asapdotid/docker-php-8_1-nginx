# Docker image PHP-FPM 8.1 & Nginx 1.22 (Alpine Linux)

![Docker Automated build](https://img.shields.io/docker/automated/asapdotid/php-nginx?style=flat-square)
![docker hub](https://img.shields.io/docker/pulls/asapdotid/php-nginx.svg?style=flat-square)
![docker hub](https://img.shields.io/docker/stars/asapdotid/php-nginx.svg?style=flat-square)
![Github](https://img.shields.io/github/stars/asapdotid/docker-php-nginx.svg?style=flat-square)

## Overview

This is a Dockerfile/image to build a container for PHP-FPM and NGINX. The container also has the ability to update templated files with variables passed to docker in order to update your code and settings. There is support for custom nginx configs, core nginx/PHP variable overrides for running preferences for local volume support.
Base image from `Webdevops` **PHP** and **PHP-NGINX**

Custom from original `asapdotid/php-nginx`:

-   Timezone (default: Asia/Jakarta)
-   PHP-FPM 8.1.x
-   nginx 1.22.x (Stable version)
    -   Snippets for handling errors
    -   Custom errors template: `404`, `403` & `502`
-   Supervisor
-   Composer

## Versioning

| Docker Tag | Git Release | Nginx Version | PHP Version | Alpine Version |
| ---------- | ----------- | ------------- | ----------- | -------------- |
| latest     | Main Branch | 1.22.1        | 8.1.13      | 3.17           |
| 1.0.2      | Main Branch | 1.22.1        | 8.1.13      | 3.17           |
| 1.0.1      | Main Branch | 1.22.1        | 8.1.13      | 3.17           |

## Web environment variables

| Variable                             | Description                                                 | Default                            |
| ------------------------------------ | ----------------------------------------------------------- | ---------------------------------- |
| `CLI_SCRIPT`                         | Predefined CLI script for service                           | -                                  |
| `APPLICATION_UID`                    | PHP-FPM UID (Effective user ID)                             | `1000`                             |
| `APPLICATION_GID`                    | PHP-FPM GID (Effective group ID)                            | `1000`                             |
| `WEB_DOCUMENT_ROOT`                  | Document root for Nginx                                     | `/app`                             |
| `WEB_DOCUMENT_INDEX`                 | Document index (eg. `index.php`) for Nginx                  | `index.php`                        |
| `WEB_ALIAS_DOMAIN`                   | Alias domains (eg. `*.vm`) for Nginx                        | `*.vm`                             |
| `WEB_PHP_SOCKET`                     | PHP-FPM socket address                                      | 127.0.0.1:9000 (for php-\* images) |
| `SERVICE_NGINX_CLIENT_MAX_BODY_SIZE` | Nginx `client_max_body_size`                                | `50m` (when nginx is used)         |
| `TIMEZONE`                           | Set `OS` and `PHP` timezone                                 | `Asia/Jakarta`                     |
| `APP_ENV`                            | Set for `composer` install on `development` or `production` | `production`                       |
| `SKIP_COMPOSER`                      | Skip action `composer install` = `true` or `false`          | `false`                            |

## PHP.ini variables

You can specify eg. `php.memory_limit=256M` as dynamic env variable which will set `memory_limit = 256M` as php setting.

| Environment variable                  | Description                             | Default   |
| ------------------------------------- | --------------------------------------- | --------- |
| `php.{setting-key}`                   | Sets the `{setting-key}` as php setting | -         |
| `PHP_DATE_TIMEZONE`                   | `date.timezone`                         | `UTC`     |
| `PHP_DISPLAY_ERRORS`                  | `display_errors`                        | `0`       |
| `PHP_MEMORY_LIMIT`                    | `memory_limit`                          | `512M`    |
| `PHP_MAX_EXECUTION_TIME`              | `max_execution_time`                    | `300`     |
| `PHP_POST_MAX_SIZE`                   | `post_max_size`                         | `50M`     |
| `PHP_UPLOAD_MAX_FILESIZE`             | `upload_max_filesize`                   | `50M`     |
| `PHP_OPCACHE_MEMORY_CONSUMPTION`      | `opcache.memory_consumption`            | `256`     |
| `PHP_OPCACHE_MAX_ACCELERATED_FILES`   | `opcache.max_accelerated_files`         | `7963`    |
| `PHP_OPCACHE_VALIDATE_TIMESTAMPS`     | `opcache.validate_timestamps`           | `default` |
| `PHP_OPCACHE_REVALIDATE_FREQ`         | `opcache.revalidate_freq`               | `default` |
| `PHP_OPCACHE_INTERNED_STRINGS_BUFFER` | `opcache.interned_strings_buffer`       | `16`      |

## PHP FPM variables

You can specify eg. `fpm.pool.pm.max_requests=1000` as dyanmic env variable which will sets `pm.max_requests = 1000` as fpm pool setting.
The prefix `fpm.pool` is for pool settings and `fpm.global` for global master process settings.

| Environment variable            | Description                                                   |
| ------------------------------- | ------------------------------------------------------------- |
| `fpm.global.{setting-key}`      | Sets the `{setting-key}` as fpm global setting for the master |
| `fpm.pool.{setting-key}`        | Sets the `{setting-key}` as fpm pool setting                  |
| `FPM_PROCESS_MAX`               | `process.max`                                                 |
| `FPM_PM_MAX_CHILDREN`           | `pm.max_children`                                             |
| `FPM_PM_START_SERVERS`          | `pm.start_servers`                                            |
| `FPM_PM_MIN_SPARE_SERVERS`      | `pm.min_spare_servers`                                        |
| `FPM_PM_MAX_SPARE_SERVERS`      | `pm.max_spare_servers`                                        |
| `FPM_PROCESS_IDLE_TIMEOUT`      | `pm.process_idle_timeout`                                     |
| `FPM_MAX_REQUESTS`              | `pm.max_requests`                                             |
| `FPM_REQUEST_TERMINATE_TIMEOUT` | `request_terminate_timeout`                                   |
| `FPM_RLIMIT_FILES`              | `rlimit_files`                                                |
| `FPM_RLIMIT_CORE`               | `rlimit_core`                                                 |

## Composer

Due to the incompatibilities between composer v1 and v2 we introduce a simple mechanism to switch between composer versions.

| Environment variable | Description                         | Default |
| -------------------- | ----------------------------------- | ------- |
| `COMPOSER_VERSION`   | Specify the composer version to use | `2`     |

### Links

-   [Webdevops Documentation](https://dockerfile.readthedocs.io/en/latest/index.html)
-   [Webdevops GitHub](https://github.com/webdevops/Dockerfile)
-   [https://github.com/asapdotid/docker-php-nginx](https://github.com/asapdotid/docker-php-nginx)
-   [https://registry.hub.docker.com/u/asapdotid/php-nginx/](https://registry.hub.docker.com/u/asapdotid/php-nginx/)

## Docker Compose setup (Laravel)

```yaml
version: "3"

services:
    laravel:
        image: asapdotid/php-nginx:latest
        environment:
            - PHP_POST_MAX_SIZE=100M
            - PHP_UPLOAD_MAX_FILESIZE=100M
            - SERVICE_NGINX_CLIENT_MAX_BODY_SIZE=100M
            - WEB_DOCUMENT_ROOT=/app/public
            - WEB_ALIAS_DOMAIN=app.domain.com
        ports:
            - "${HTTP_PORT:-80}:80"
            - "${HTTPS_PORT:-443}:443"
        extra_hosts:
            - "host.docker.internal:host-gateway"
        volumes:
            - ".:/app"
            - "./config/supervisor/laravel-supervisor.conf:/etc/supervisor/conf.d/laravel-supervisor.conf"
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
