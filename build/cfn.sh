#!/bin/bash
set -e

STACK_NAME="$APPLICATION-$ENVIRONMENT"

echo "Packaging CloudFormation Templates..."

aws cloudformation package \
  --template-file $CODEBUILD_SRC_DIR/build/cfn_main.yml \
  --s3-bucket $BUILD_BUCKET \
  --output-template-file $CODEBUILD_SRC_DIR/build/cfn_main_packaged.yml \

cat > $CODEBUILD_SRC_DIR/build/cfn_configuration.json <<- EOM
{
  "Parameters": {
    "Application": "$APPLICATION",
    "Environment": "$ENVIRONMENT",
    "DomainName": "$DOMAIN_NAME",
    "GitHubOwner": "$GITHUB_OWNER",
    "GitHubRepo": "$GITHUB_REPO",
    "GitHubSourceVersion": "$CODEBUILD_RESOLVED_SOURCE_VERSION",
    "WebDistributionCertificate": "$WEB_DISTRIBUTION_CERTIFICATE",
    "AlertEmail": "$ALERT_EMAIL",
    "AlertPhone": "$ALERT_PHONE"
  },
  "Tags": {
    "Application": "$APPLICATION",
    "Environment": "$ENVIRONMENT"
  }
}
EOM

echo "Done Building Templates!"
