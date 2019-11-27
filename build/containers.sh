#!/bin/bash

ORIG_DIR="$PWD"

$(aws ecr get-login --no-include-email)
cp -LR $CODEBUILD_SRC_DIR/containers $CODEBUILD_SRC_DIR/build/

for dir in $CODEBUILD_SRC_DIR/build/containers/*
do

  CONTAINER_NAME=$(basename $dir)
  
  if [[ $CONTAINER_NAME == _* ]]
  then
  
    continue
  
  fi
  
  echo "Building Container $CONTAINER_NAME..."
  
  CONTAINER_REPO=$(aws cloudformation describe-stacks \
    --stack-name "$APPLICATION-$ENVIRONMENT" \
    --query "Stacks[0].Outputs[?OutputKey==\`${CONTAINER_NAME}ContainerRepo\`].OutputValue" \
    --output text)
  
  cd $dir
  cp -LR $CODEBUILD_SRC_DIR/containers/_common/* ./
  docker pull "$WRF_CONTAINER_REPO_URI:$WRF_VERSION"
  
  docker build \
    --cache-from "$CONTAINER_REPO:latest" \
    --pull \
    -t "$CONTAINER_REPO:latest" \
    .
  
  docker push "$CONTAINER_REPO:latest"
  cd $ORIG_DIR

done
