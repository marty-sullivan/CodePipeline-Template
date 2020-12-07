#!/bin/bash
set -e

STACK_NAME="$APPLICATION-$ENVIRONMENT"

echo "Packaging SAM CloudFormation Template..."

aws cloudformation package \
  --template-file $CODEBUILD_SRC_DIR/build/root.yml \
  --s3-bucket $BUILD_BUCKET \
  --output-template-file $CODEBUILD_SRC_DIR/build/packaged.yml \

echo "Done Building Template!"
