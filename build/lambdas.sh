#!/bin/bash
set -e

cp -LR $CODEBUILD_SRC_DIR/lambdas $CODEBUILD_SRC_DIR/build/

for dir in $CODEBUILD_SRC_DIR/build/lambdas/*
do

  LAMBDA_NAME=$(basename $dir)

  if [[ $LAMBDA_NAME == _* ]]
  then
  
    continue
  
  fi

  echo "Building Lambda $LAMBDA_NAME..."
  cp -LR $CODEBUILD_SRC_DIR/common/* $dir
  pip3 install -r $dir/requirements.txt -t $dir

done
