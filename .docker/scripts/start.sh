#!/bin/bash
set -e

if [[ "$APPLICATION_ENV" == "development" ]]; then
    mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
else
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
fi

# Setup php.ini
sed \
    -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" \
    -e "s/expose_php = On/expose_php = Off/g" \
    -e "s/post_max_size = 8M/post_max_size = 16M/g" \
    -e "s/upload_max_filesize = 2M/upload_max_filesize = 16M/g" \
    -e "s/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86401/g" \
    -e "s/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86401/g" \
    -e "s/max_execution_time = 30/max_execution_time = 180/g" \
    -i "$PHP_INI_DIR/php.ini"

# Setup FPM `www` (default) pool
sed \
    -e "s|pm.max_children = 5|pm.max_children = 640|g" \
    -e "s|pm.start_servers = 2|pm.start_servers = 18|g" \
    -e "s|pm.min_spare_servers = 1|pm.min_spare_servers = 12|g" \
    -e "s|pm.max_spare_servers = 3|pm.max_spare_servers = 24|g" \
    -e "s|;pm.process_idle_timeout = 10s|pm.process_idle_timeout = 10s|g" \
    -e "s|;pm.max_requests = 500|pm.max_requests = 500|g" \
    -e "s|;pm.status_path = /status|pm.status_path = /fpm-status|g" \
    -e "s|;ping.path = /ping|ping.path = /fpm-ping|g" \
    -e "s|max_execution_time = 30|max_execution_time = 180|g" \
    -i "/usr/local/etc/php-fpm.d/www.conf"

# Setup FPM global config
# Insert before [www] directive
sed \
    -e '0,/^\[www\].*/s/^\[www\].*/emergency_restart_threshold = 10\n&/' \
    -e '0,/^\[www\].*/s/^\[www\].*/emergency_restart_interval = 1m\n&/' \
    -e '0,/^\[www\].*/s/^\[www\].*/process_control_timeout = 5\n&/' \
    -i "/usr/local/etc/php-fpm.d/zz-docker.conf"

# Set the desired timezone
echo "date.timezone=$TIMEZONE" >>"$PHP_INI_DIR/conf.d/timezone.ini"

# Setup OPcache
echo "opcache.enable = 1" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" &&
    echo "opcache.enable_cli = 1" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" &&
    echo "opcache.memory_consumption = 512" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" &&
    echo "opcache.interned_strings_buffer = 8" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" &&
    echo "opcache.max_accelerated_files = 50000" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" &&
    echo "opcache.revalidate_freq = 5" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" &&
    echo "opcache.save_comments = 0" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" &&
    echo "opcache.enable_file_override = 1" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" &&
    echo "opcache.huge_code_pages = 0" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini" &&
    echo "opcache.fast_shutdown = 1" >>"$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"

# Setup Redis
echo "php_value[session.save_handler] = redis" >>"/usr/local/etc/php-fpm.d/www.conf" &&
    echo "php_value[session.save_path] = tcp://redis:6379" >>"/usr/local/etc/php-fpm.d/www.conf"

if [ -z "$SKIP_COMPOSER" ]; then
    # Try auto install for composer
    if [ -f "$APP_CODE_PATH/composer.lock" ]; then
        if [ "$APPLICATION_ENV" == "development" ]; then
            composer install --working-dir=$APP_CODE_PATH
        else
            composer install --optimize-autoloader --no-interaction --no-progress --working-dir=$APP_CODE_PATH
        fi
    fi
fi

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

# run command with exec to pass control
echo "Running CMD: $@"
exec "$@"
