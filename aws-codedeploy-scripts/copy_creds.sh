#!/bin/bash
S3_PATH="s3://${ENV_CONFIG_FILE_PATH}"
sudo aws s3 cp $S3_PATH /var/sentry/.env
