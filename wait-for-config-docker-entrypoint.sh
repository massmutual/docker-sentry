#!/bin/bash

set -e

FILE="$CONFIG_PATH_IN"
if [ ${#FILE} -ge 1 ]; then
    echo "Using S3 config file."
    x=0
    while [ "$x" -lt 100 -a ! -e $FILE ]; do
        x=$((x+1))
        echo "Waiting for file to exist: $FILE"
        sleep .5
    done
    if [ -e ${FILE} ]
    then
        echo "Found: ${FILE}, copying to config directory: /config/credentials.sh"
        cp ${FILE} /config/credentials.sh
    else
        echo "File ${FILE} not found within time limit!"
        exit 1
    fi
else
    echo "No config file defined. Running locally"
    cp local-credentials.sh /config/credentials.sh
    echo "Local config file copied successfully!"
fi

source /config/credentials.sh

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
