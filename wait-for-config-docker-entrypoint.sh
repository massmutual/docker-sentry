#!/bin/bash

set -e

CONFIG_PATH=/config/credentials.sh

FILE="$CONFIG_PATH_IN"
if [ ${#FILE} -ge 1 ]; then
    echo "Using S3 config file."
    aws s3 cp s3://$S3_CONFIG_PATH $CONFIG_PATH
else
    echo "No config file defined. Running locally"
    cp local-credentials.sh $CONFIG_PATH
    echo "Local config file copied successfully!"
fi

source $CONFIG_PATH

# first check if we're passing flags, if so
# prepend with sentry
if [ "${1:0:1}" = '-' ]; then
    set -- sentry "$@"
fi

case "$1" in
    celery|cleanup|config|createuser|devserver|django|exec|export|help|import|init|plugins|queues|repair|run|shell|start|tsdb|upgrade)
        set -- sentry "$@"
    ;;
esac

if [ "$1" = 'sentry' ]; then
    set -- tini -- "$@"
    if [ "$(id -u)" = '0' ]; then
        mkdir -p "$SENTRY_FILESTORE_DIR"
        chown -R sentry "$SENTRY_FILESTORE_DIR"
        set -- gosu sentry "$@"
    fi
fi

exec "$@"
