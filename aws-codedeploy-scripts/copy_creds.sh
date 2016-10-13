#!/bin/bash
S3_PATH="s3://${ENV_CONFIG_FILE_PATH}"
aws s3 cp $S3_PATH /var/sentry/.env
