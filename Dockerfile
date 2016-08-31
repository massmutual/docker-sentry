FROM sentry:8.7-onbuild

COPY wait-for-config-docker-entrypoint.sh /entrypoint.sh
