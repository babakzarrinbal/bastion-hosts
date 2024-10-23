#!/bin/sh
# Author: Babak Zarrinbal
# Date: 2024-09-19
# required env variables:
#   - AWS_ACCESS_KEY_ID [required]
#   - AWS_SECRET_ACCESS_KEY [required]

echo syncing \" $AWS_BUCKET_PATH to $DATA_LOCAL_PATH \" 

mkdir -p $DATA_LOCAL_PATH 

AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 sync $AWS_BUCKET_PATH $DATA_LOCAL_PATH --delete