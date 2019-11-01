#!/bin/bash

# Start Docker

echo "Starting Docker..."

nohup /usr/local/bin/dockerd \
  --host=unix:///var/run/docker.sock \
  --host=tcp://127.0.0.1:2375 \
  --storage-driver=overlay2&

timeout 15 sh -c "until docker info; do echo .; sleep 1; done"
$(aws ecr get-login --no-include-email)

cp -LR $CODEBUILD_SRC_DIR/containers $CODEBUILD_SRC_DIR/build/

for dir in $CODEBUILD_SRC_DIR/build/containers/*
do

  if [[ $dir == _* ]]
  then
  
    continue
  
  fi
  
  CONTAINER_NAME=$(basename $dir)
  
  CONTAINER_REPO=$(aws cloudformation describe-stacks \
    --stack-name "$APPLICATION-$ENVIRONMENT" \
    --query "Stacks[0].Outputs[?OutputKey==\`${CONTAINER_NAME}ContainerRepo].OutputValue" \
    --output text)
  
  echo "Building Container $CONTAINER_NAME..."
  
  cp -R $CODEBUILD_SRC_DIR/containers/_common/* $dir
  docker pull "$WRF_CONTAINER_REPO_URI:$WRF_VERSION"
  
  docker build \
    --cache-from "$CONTAINER_REPO:latest" \
    --pull \
    -t "$CONTAINER_REPO:latest" \
    .
  
  docker push "$CONTAINER_REPO:latest"

done
