#!/bin/bash
set -e

ORIG_DIR="$PWD"

docker login --username=$DOCKER_HUB_USER --password=$DOCKER_HUB_PASSWORD
$(aws ecr get-login --no-include-email)
cp -LR $CODEBUILD_SRC_DIR/containers $CODEBUILD_SRC_DIR/build/

for dir in $CODEBUILD_SRC_DIR/build/containers/*
do

  CONTAINER_NAME=$(basename $dir)
  
  if [[ $CONTAINER_NAME == _* ]]
  then
  
    continue
  
  fi
  
  CONTAINER_TAG="$CONTAINER_REPO:$CONTAINER_NAME"
  CONTAINER_BUILD_TAG="$CONTAINER_TAG-$CODEBUILD_RESOLVED_SOURCE_VERSION"
  CONTAINER_ARCH_TAG="$CONTAINER_TAG-$(uname -m)"
  CONTAINER_ARCH_BUILD_TAG="$CONTAINER_BUILD_TAG-$(uname -m)"
  
  echo "Building Container $CONTAINER_ARCH_BUILD_TAG..."
  
  cd $dir
  cp -LR $CODEBUILD_SRC_DIR/common/* ./
  docker pull "$CONTAINER_ARCH_TAG" || true
  
  docker build \
    --cache-from "$CONTAINER_ARCH_TAG" \
    --pull \
    --build-arg "BUILD_BUCKET=$BUILD_BUCKET" \
    -t "$CONTAINER_ARCH_BUILD_TAG" \
    .
  
  docker push "$CONTAINER_ARCH_BUILD_TAG"
  docker tag "$CONTAINER_ARCH_BUILD_TAG" "$CONTAINER_ARCH_TAG"
  docker push "$CONTAINER_ARCH_TAG"
  
  cd $ORIG_DIR

done
