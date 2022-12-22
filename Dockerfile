FROM webdevops/php:8.1-alpine

ENV APPLICATION_PATH=/app \
    APPLICATION_UID=1000 \
    APPLICATION_GID=1000

ENV WEB_DOCUMENT_ROOT=$APPLICATION_PATH \
    WEB_DOCUMENT_INDEX=index.php \
    WEB_ALIAS_DOMAIN=*.vm \
    WEB_PHP_TIMEOUT=600 \
    WEB_PHP_SOCKET=""
ENV WEB_PHP_SOCKET=127.0.0.1:9000
ENV SERVICE_NGINX_CLIENT_MAX_BODY_SIZE="50m"
ENV TIMEZONE=Asia/Jakarta
ENV PHP_DATE_TIMEZONE=$TIMEZONE
ENV APP_ENV=production
ENV SKIP_COMPOSER=""

COPY ./.docker/config/ /opt/docker/
COPY ./.docker/errors/ /var/www/errors/
# COPY ./src $WEB_DOCUMENT_ROOT

RUN set -x \
    # Install nginx
    && apk-install \
    nginx \
    tzdata \
    && docker-run-bootstrap \
    && docker-image-cleanup

# set timezone
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

WORKDIR $APPLICATION_PATH

EXPOSE 80 443
