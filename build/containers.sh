#!/bin/bash

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
    --query "Stacks[0].Outputs[?OutputKey==\`${CONTAINER_NAME}ContainerRepo\`].OutputValue" \
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
