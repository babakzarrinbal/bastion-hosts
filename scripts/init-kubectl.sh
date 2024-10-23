#!/bin/sh
# Author: Babak Zarrinbal
# Date: 2024-09-19
# requirments:
#  ENV variables:
#   - CLUSTER_NAME  [required]
#   - NAME_SPACE  [required]

original_path=$(pwd)
cd "$(dirname "$0")"

sh ./init-aws.sh

# Check if CLUSTER_NAME and NAME_SPACE are defined
if [ -z "$CLUSTER_NAME" ] || [ -z "$NAME_SPACE" ]; then
  echo "Error: CLUSTER_NAME and NAME_SPACE must be defined."
  exit 1
fi

# installing  kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Apply EKS configuration
echo "Updating kubeconfig for cluster $CLUSTER_NAME in namespace $NAME_SPACE"
aws eks update-kubeconfig --name "$CLUSTER_NAME"

cd $original_path