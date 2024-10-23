#!/bin/sh
# Author: Babak Zarrinbal
# Date: 2024-09-19
# requirments:
#  ENV variables:
#   - AWS_REGION_NAME   [required]
#   - AWS_ACCESS_KEY_ID   [required]
#   - AWS_SECRET_ACCESS_KEY   [required]
#   - CLUSTER_NAME  [required]
#   - NAME_SPACE  [required]
#   - IDENTIFICATION_URL  [optional]
#   - BUILD_INDEX_URL   [optional]
#   - STATUS_URL  [optional]

original_path=$(pwd)
cd "$(dirname "$0")"

sh ./init-kubectl.sh

# Define the endpoints
IDENTIFICATION_URL=${IDENTIFICATION_URL:-"http://identification.dev-mailbox-pro"}
BUILD_INDEX_URL=${BUILD_INDEX_URL:-"build_global_index"}
STATUS_URL=${STATUS_URL:-"get_index_building_status"}

# Step 1: Call the build_global_index endpoint
echo "Initiating index build..."
curl -o /dev/null -s -w "%{http_code}" -G "$IDENTIFICATION_URL/$BUILD_INDEX_URL" || true &
echo "[$(TZ="Europe/Berlin" date "+%H:%M:%S %Z")] Build API called in the background"

# Initialize timer
POLL_INTERVAL=10

echo "[$(TZ="Europe/Berlin" date "+%H:%M:%S %Z")] Polling until build is complete"

# Step 2: Poll the status endpoint every 10 seconds
while true; do
    # Fetch the current status
    RESPONSE=$(curl -s -w "%{http_code}" -G "$IDENTIFICATION_URL/$STATUS_URL")
    last_call_time=$(TZ="Europe/Berlin" date "+%H:%M:%S %Z")
    status_code=$(echo "$RESPONSE" | tail -n 1)
    response_body=$(echo "$RESPONSE" | sed '$d')
    USER_IDS_LEFT_COUNT=$(echo "$response_body" | jq '.user_ids_left_count')
    
    # Check the status code and exit if not 200
    if [ "$status_code" -ne 200 ]; then
        echo "[$last_call_time]($status_code) $response_body"
        echo "Error: API call returned status code $status_code. Exiting..."
        exit 1
    fi

    # Check if user_ids_left_count is 0
    if [ "$USER_IDS_LEFT_COUNT" -eq 0 ]; then
        echo ""
        echo "[$(TZ="Europe/Berlin" date "+%H:%M:%S %Z")] user_ids_left_count is 0, calling reload_index on all pods..."

        # Step 3: Get the list of pod names in the deployment
        # Replace 'app=identification' with the actual label of your deployment
        POD_NAMES=$(kubectl get pods -n $NAME_SPACE -l app=identification -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
        
        # Loop over each pod and call the reload_index endpoint
        for pod_name in $POD_NAMES; do
            echo "[$(TZ="Europe/Berlin" date "+%H:%M:%S %Z")] Calling reload_index on pod $pod_name"
            reload_response=$(kubectl exec $pod_name -n $NAME_SPACE -c identification -- curl -s -w "%{http_code}" -G http://localhost:7000/reload_index)
            reload_status=$(echo "$reload_response" | tail -n 1)
            reload_response_body=$(echo "$reload_response" | sed '$d')

            # Check the reload status code and exit if not 200
            if [ "$reload_status" -ne 200 ]; then
                echo "[$(TZ="Europe/Berlin" date "+%H:%M:%S %Z")] ($reload_status) $reload_response_body"
                echo "Error: Reload API call returned status code $reload_status on pod $pod_name. Exiting..."
                exit 1
            fi
        done

        # Exit the loop
        break
    fi

    echo "[$(TZ="Europe/Berlin" date "+%H:%M:%S %Z")]  => user_ids_left_count: $USER_IDS_LEFT_COUNT "
    sleep $POLL_INTERVAL
done

echo "[$(TZ="Europe/Berlin" date "+%H:%M:%S %Z")] Process completed."

cd $original_path