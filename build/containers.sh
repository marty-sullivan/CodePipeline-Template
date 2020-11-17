#!/bin/bash

ORIG_DIR="$PWD"

docker login --username=$DOCKER_HUB_USER --password=$DOCKER_HUB_PASSWORD
$(aws ecr get-login --no-include-email)
cp -LR $CODEBUILD_SRC_DIR/containers $CODEBUILD_SRC_DIR/build/

CONTAINER_REPO=$(aws cloudformation describe-stacks \
  --stack-name "$APPLICATION-$ENVIRONMENT" \
  --query 'Stacks[0].Outputs[?OutputKey==`EcsRepository`].OutputValue' \
  --output text)
  
for dir in $CODEBUILD_SRC_DIR/build/containers/*
do

  CONTAINER_NAME=$(basename $dir)
  
  if [[ $CONTAINER_NAME == _* ]]
  then
  
    continue
  
  fi
  
  echo "Building Container $CONTAINER_NAME-$(uname -m)..."
  
  cd $dir
  cp -LR $CODEBUILD_SRC_DIR/common/* ./
  docker pull "$CONTAINER_REPO:$CONTAINER_NAME-$(uname -m)"
  
  docker build \
    --cache-from "$CONTAINER_REPO:$CONTAINER_NAME-$(uname -m)" \
    --pull \
    -t "$CONTAINER_REPO:$CONTAINER_NAME-$(uname -m)" \
    .
  
  docker push "$CONTAINER_REPO:$CONTAINER_NAME-$(uname -m)"
  
  docker manifest create "$CONTAINER_REPO:$CONTAINER_NAME" "$CONTAINER_REPO:$CONTAINER_NAME-x86_64" "$CONTAINER_REPO:$CONTAINER_NAME-aarch64"
  docker manifest push "$CONTAINER_REPO:$CONTAINER_NAME"
  
  cd $ORIG_DIR

done
