#!/bin/bash

ORIG_DIR="$PWD"

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
  
  echo "Building Container $CONTAINER_NAME..."
  
  cd $dir
  cp -LR $CODEBUILD_SRC_DIR/common/* ./
  docker pull "$CONTAINER_REPO:$CONTAINER_NAME"
  
  docker build \
    --cache-from "$CONTAINER_REPO:$CONTAINER_NAME" \
    --pull \
    -t "$CONTAINER_REPO:$CONTAINER_NAME" \
    .
  
  docker push "$CONTAINER_REPO:$CONTAINER_NAME"
  cd $ORIG_DIR

done
