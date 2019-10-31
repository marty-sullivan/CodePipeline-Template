#!/bin/bash

cp -LR $CODEBUILD_SRC_DIR/lambdas $CODEBUILD_SRC_DIR/build/

for dir in $CODEBUILD_SRC_DIR/build/lambdas/*
do

  if [[ $dir == _* ]]
  then
  
    continue
  
  fi

  echo "Building Lambda $dir..."
  cp -R $CODEBUILD_SRC_DIR/lambdas/_common/* $dir
  pip3 install -r $dir/requirements.txt -t $dir

done
