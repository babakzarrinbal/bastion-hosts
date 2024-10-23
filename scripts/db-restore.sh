#!/bin/sh
# Author: Babak Zarrinbal
# Date: 2024-09-19
# requirments:
#   Arguments:
#     - filename  [optional in interactive mode]
#   ENV variables:
#   - DB_CONNECTION_STRING  [required]
#   - BUCKET_NAME   [optional]
#   - DB_NAME   [optional]


# Set defaults
BUCKET_NAME=${BUCKET_NAME:-managbl-db-backup}
DB_NAME=${DB_NAME:-managbl}


# Check if filename is provided as an argument
if [ -z "$1" ]; then
  echo "Please provide file name."
  aws s3 ls s3://$BUCKET_NAME
  exit 1
fi

FILENAME=$1
S3_PATH="s3://$BUCKET_NAME/$FILENAME"

# Check if the file exists in the S3 bucket
if ! aws s3 ls "$S3_PATH" >/dev/null 2>&1; then
  echo "Error: file doesn'\''t exist"
  exit 1
fi

# Copy the file from S3 to local directory
aws s3 cp "$S3_PATH" "./$FILENAME"

# Uncompress the file
tar -xzvf "$FILENAME"

# Restore the data
mongorestore --drop --uri="$DB_CONNECTION_STRING/?authSource=admin" --db $DB_NAME --dir=./managbl/

# Clean up
rm -R "$FILENAME" ./managbl


