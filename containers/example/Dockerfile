ARG PYTHON_MAJOR_VERSION=3.8
FROM python:$PYTHON_MAJOR_VERSION-slim

ARG PYTHON_MAJOR_VERSION=3.8

ENV PYTHON_PATH /opt
ENV TASK_ROOT /opt

WORKDIR /tmp

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      vim && \
    pip3 install --no-cache-dir \
      cmake && \
    pip3 install --no-cache-dir \
      awslambdaric \
      boto3 && \
    apt-get autoremove -y \
      build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

COPY ./ /opt/
