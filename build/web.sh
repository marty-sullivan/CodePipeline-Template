#!/bin/bash

WEB_BUCKET=$(aws cloudformation describe-stacks \
  --stack-name "$APPLICATION-$ENVIRONMENT" \
  --query "Stacks[0].Outputs[?OutputKey==`WebBucket`].OutputValue" \
  --output text)

aws s3 sync \
  --delete \
  --acl public-read \
  $CODEBUILD_SRC_DIR/web/ s3://$WEB_BUCKET/
