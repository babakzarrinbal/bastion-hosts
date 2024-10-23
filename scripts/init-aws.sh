#!/bin/sh
# Author: Babak Zarrinbal
# Date: 2024-09-19
# requirments:
#  ENV variables:
#   - AWS_REGION_NAME   [required]
#   - AWS_ACCESS_KEY_ID   [required]
#   - AWS_SECRET_ACCESS_KEY   [required]

original_path=$(pwd)
cd "$(dirname "$0")"

# installing curl and unzip
apt-get update && apt-get install -y curl unzip

# installing aws cli and kubectl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

aws configure set region "$AWS_REGION_NAME"
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set output json

cd $original_path