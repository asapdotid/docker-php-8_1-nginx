# Composer install
if [ "$SKIP_COMPOSER" != true ]; then
    # Try auto install for composer
    if [[ -f "$APPLICATION_PATH/composer.json" && -f "$APPLICATION_PATH/composer.lock" ]]; then
        if [ "$APP_ENV" == "development" ]; then
            composer install --working-dir=$APPLICATION_PATH
        else
            composer install --optimize-autoloader --no-interaction --no-progress --working-dir=$APPLICATION_PATH
        fi
    fi
fi
