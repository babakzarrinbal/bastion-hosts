#!/bin/sh

export MSYS_NO_PATHCONV=1;

original_path=$(pwd)

cd "$(dirname "$0")"

repo=babakzarrinbal/bastions/aws-k8-mongo
version=v1.0.0 
container_name=bastions-aws-k8-mongo

docker build -t $repo:$version -t $repo:latest .

# docker push $repo:$version
# docker push $repo:latest

docker rm -f $container_name
docker run -d \
  --name $container_name\
  $repo:$version  tail -f /dev/null


cd $original_path
  
docker exec -it $container_name /bin/bash