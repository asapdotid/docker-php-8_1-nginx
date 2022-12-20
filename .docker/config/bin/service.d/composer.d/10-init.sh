# Composer install
if [ -z "$SKIP_COMPOSER" ]; then
    # Try auto install for composer
    if [[ -f "$WEB_DOCUMENT_ROOT/composer.json" && -f "$WEB_DOCUMENT_ROOT/composer.lock" ]]; then
        if [ "$APP_ENV" == "development" ]; then
            composer install --working-dir=$WEB_DOCUMENT_ROOT
        else
            composer install --optimize-autoloader --no-interaction --no-progress --working-dir=$WEB_DOCUMENT_ROOT
        fi
    fi
fi
