#!/bin/sh
# Author: Babak Zarrinbal
# Date: 2024-09-19
# requirments:
#  ENV variables:
#   - DB_CONNECTION_STRING  [required]
#   - CLUSTER_NAME  [required]
#   - NODE_GROUP  [required]
#   - NAME_SPACE  [required]

# Get the count of processing jobs
throughput_count=$(mongo "$DB_CONNECTION_STRING" --quiet --eval '
    var count = db.getCollection("processing_jobs").find({timestamp: {$exists: true, $gte: new Date(Date.now() - 60 * 60 * 1000)}}).count();
    print(count);
')

unprocessed_count=$(mongo "$DB_CONNECTION_STRING" --quiet --eval '
    var count = db.getCollection("processing_jobs").find({processed:false}).count();
    print(count);
')

# Determine the desired replica count
if [ "$throughput_count" -gt "$HIGH_THROUGHPUT" ] || [ "$unprocessed_count" -gt "$HIGH_UNPROCESSED" ]; then
    replica_count=3
elif [ "$throughput_count" -gt "$LOW_THROUGHPUT" ] || [ "$unprocessed_count" -gt "$LOW_UNPROCESSED" ]; then
    replica_count=2
else
    replica_count=1
fi

# Get the current number of nodes in the node group
current_nodes=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODE_GROUP --query 'nodegroup.scalingConfig.desiredSize' --output text)

# Compare and update if necessary
if [ "$current_nodes" -ne "$replica_count" ]; then
    aws eks update-nodegroup-config --cluster-name $CLUSTER_NAME --nodegroup-name $NODE_GROUP --scaling-config minSize=$replica_count,maxSize=$replica_count,desiredSize=$replica_count
    kubectl scale deployment data-processing --replicas=$replica_count -n $NAME_SPACE
    echo "Updated the number of nodes and deployment replicas to $replica_count"
else
    kubectl delete pod -n  $NAME_SPACE -l app=data-processing --field-selector=status.phase=Failed
    echo "The number of nodes is already aligned with the desired replica count ($replica_count). No updates needed."
fi
