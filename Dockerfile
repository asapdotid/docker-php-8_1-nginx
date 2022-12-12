ARG PHP_VERSION=8.1
FROM php:${PHP_VERSION}-fpm-alpine

# Metadata
LABEL maintainer="Asapdotid <asapdotid@gmail.com>"
LABEL description="Docker PHP-FPM 8.1 + Nginx 1.22 (stable)"

ARG TIMEZONE=Asia/Jakarta
ENV TIMEZONE ${TIMEZONE}
ENV APP_CODE_PATH /app
ENV APPLICATION_ENV development

ENV NGINX_VERSION 1.22.1
ENV PKG_RELEASE 1

RUN apk update && apk upgrade && \
    apk add --no-cache \
    bash \
    supervisor \
    tzdata

# custom bashrc
COPY ./.docker/scripts/.bashrc /root/.bashrc
# make bash default shell
RUN sed -e 's;/bin/sh$;/bin/bash;g' -i /etc/passwd

# set timezone
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

# Install PHP extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions @composer apcu gd mysqli pdo_mysql intl exif zip imagick redis opcache igbinary msgpack

RUN set -x \
    # create nginx user/group first, to be consistent throughout docker variants
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apkArch="$(cat /etc/apk/arch)" \
    && nginxPackages=" \
    nginx=${NGINX_VERSION}-r${PKG_RELEASE} \
    " \
    # install prerequisites for public key and pkg-oss checks
    && apk add --no-cache --virtual .checksum-deps \
    openssl \
    && case "$apkArch" in \
    x86_64|aarch64) \
    # arches officially built by upstream
    set -x \
    && KEY_SHA512="e09fa32f0a0eab2b879ccbbc4d0e4fb9751486eedda75e35fac65802cc9faa266425edf83e261137a2f4d16281ce2c1a5f4502930fe75154723da014214f0655" \
    && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && if echo "$KEY_SHA512 */tmp/nginx_signing.rsa.pub" | sha512sum -c -; then \
    echo "key verification succeeded!"; \
    mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
    else \
    echo "key verification failed!"; \
    exit 1; \
    fi \
    && apk add -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages \
    ;; \
    *) \
    # we're on an architecture upstream doesn't officially build for
    # let's build binaries from the published packaging sources
    set -x \
    && tempDir="$(mktemp -d)" \
    && chown nobody:nobody $tempDir \
    && apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre2-dev \
    zlib-dev \
    linux-headers \
    alpine-sdk \
    findutils \
    && su nobody -s /bin/sh -c " \
    export HOME=${tempDir} \
    && cd ${tempDir} \
    && curl -f -O https://hg.nginx.org/pkg-oss/archive/757.tar.gz \
    && PKGOSSCHECKSUM=\"32a039e8d3cc54404a8ad4a31981e76a49632f1ebec2f45bb309689d6ba2f82e3e8aea8abf582b49931636ea53271b48a7e2f2ef8ebe35b167b3fe18b8b99852 *757.tar.gz\" \
    && if [ \"\$(openssl sha512 -r 757.tar.gz)\" = \"\$PKGOSSCHECKSUM\" ]; then \
    echo \"pkg-oss tarball checksum verification succeeded!\"; \
    else \
    echo \"pkg-oss tarball checksum verification failed!\"; \
    exit 1; \
    fi \
    && tar xzvf 757.tar.gz \
    && cd pkg-oss-757 \
    && cd alpine \
    && make base \
    && apk index -o ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz ${tempDir}/packages/alpine/${apkArch}/*.apk \
    && abuild-sign -k ${tempDir}/.abuild/abuild-key.rsa ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz \
    " \
    && cp ${tempDir}/.abuild/abuild-key.rsa.pub /etc/apk/keys/ \
    && apk del .build-deps \
    && apk add -X ${tempDir}/packages/alpine/ --no-cache $nginxPackages \
    ;; \
    esac \
    # remove checksum deps
    && apk del .checksum-deps \
    # if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
    && if [ -n "/etc/apk/keys/abuild-key.rsa.pub" ]; then rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
    && if [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ]; then rm -f /etc/apk/keys/nginx_signing.rsa.pub; fi \
    # Bring in gettext so we can get `envsubst`, then throw
    # the rest away. To do this, we need to install `gettext`
    # then move `envsubst` out of the way so `gettext` can
    # be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
    scanelf --needed --nobanner /tmp/envsubst \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | sort -u \
    | xargs -r apk info --installed \
    | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    # create a nginx snippets directory
    && mkdir -p /etc/nginx/snippets

# tune nginx config and site config
COPY ./.docker/nginx/snippets /etc/nginx/snippets
COPY ./.docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./.docker/nginx/conf.d/site.conf /etc/nginx/conf.d/default.conf

# entrypoint for tune nginx config
COPY ./.docker/entrypoint/docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

# script for tune php-fpm config
COPY ./.docker/scripts/start.sh /
RUN chmod 755 /start.sh

# copy supervisor configuration
RUN rm -rf /etc/supervisord.conf
COPY ./.docker/supervisor/ /etc/supervisor/

WORKDIR $APP_CODE_PATH
COPY --chown=www-data ./.docker/src $APP_CODE_PATH

EXPOSE 8080

STOPSIGNAL SIGQUIT

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/start.sh"]

# Configure a healthcheck to validate that everything is up&running
# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
