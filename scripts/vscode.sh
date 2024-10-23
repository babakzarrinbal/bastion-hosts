#!/bin/bash
# Author: Babak Zarrinbal
# Date: 2024-09-19

apt-get update && apt-get install -y curl 
curl -fsSL https://raw.githubusercontent.com/babakzarrinbal/scripts/master/vscode-server.sh | sh
