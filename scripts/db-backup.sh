#!/bin/sh
# Author: Babak Zarrinbal
# Date: 2024-09-19
# requirments:
#  ENV variables:
#   - DB_CONNECTION_STRING  [required]
#   - BUCKET_NAME   [optional]
#   - DB_NAME   [optional]

# Set defaults
BUCKET_NAME=${BUCKET_NAME:-managbl-db-backup}
DB_NAME=${DB_NAME:-managbl}

timestamp=$(TZ=Europe/Berlin date +%Y%m%d_%H%M)

mongodump --uri="$DB_CONNECTION_STRING" --db $DB_NAME --out ./ --numParallelCollections 1 --excludeCollection logs --excludeCollection email_ticket_logs

tar -czvf ./$DB_NAME.tar.gz ./$DB_NAME

aws s3 cp ./$DB_NAME.tar.gz s3://$BUCKET_NAME/prod-db-$timestamp.tar.gz

rm -R ./$DB_NAME ./$DB_NAME.tar.gz