#!/bin/bash
sudo aws s3 cp s3://$ENV_CONFIG_FILE_PATH /var/sentry/.env
pip install docker-compose
