#!/bin/bash

STACK_NAME="$APPLICATION-$ENVIRONMENT"

echo "Packaging CloudFormation Template..."

aws cloudformation package \
  --template-file $CODEBUILD_SRC_DIR/build/root.yml \
  --s3-bucket $BUILD_BUCKET \
  --output-template-file $CODEBUILD_SRC_DIR/build/packaged.yml \

if [ $? != 0 ]
then

  echo "ERROR: Unable to package template..."
  exit 1

fi

echo "Deploying CloudFormation Template..."

aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --template-file $CODEBUILD_SRC_DIR/build/packaged.yml \
  --s3-bucket $BUILD_BUCKET \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    "Application=$APPLICATION" \
    "Environment=$ENVIRONMENT" \
    "DomainName=$DOMAIN_NAME" \
    "GitHubRepo=$GITHUB_REPO" \
    "AdminEmail=$ADMIN_EMAIL" \
    "AdminPhone=$ADMIN_PHONE" \
  --tags \
    "Application=$APPLICATION" \
    "Environment=$ENVIRONMENT" \

if [ $? != 0 ]
then

  echo "ERROR: Unable to deploy stack..."
  exit 1

fi

if [ "$ENVIRONMENT" == "master" ]
then

  echo "Enabling Termination Protection for master branch stack: $STACK_NAME"
  
  aws cloudformation update-termination-protection \
    --stack-name $STACK_NAME \
    --enable-termination-protection > /dev/null

fi

BUILD_PROJECT=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query 'Stacks[0].Outputs[?OutputKey==`BuildProject`].OutputValue' \
  --output text)

echo "Setting GitHub branch filter to '$ENVIRONMENT' for CodeBuild Project: $BUILD_PROJECT..."

aws codebuild update-webhook \
  --project-name $BUILD_PROJECT \
  --branch-filter $ENVIRONMENT \
  --rotate-secret > /dev/null

echo "Done Building!"
