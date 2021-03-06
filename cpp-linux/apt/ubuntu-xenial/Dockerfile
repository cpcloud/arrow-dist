# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

ARG DEBUG

RUN \
  quiet=$([ "${DEBUG}" = "yes" ] || echo "-qq") && \
  apt update ${quiet} && \
  apt install -y -V ${quiet} \
    autoconf-archive \
    build-essential \
    cmake \
    debhelper\
    devscripts \
    dh-autoreconf \
    git \
    gtk-doc-tools \
    libboost-filesystem-dev \
    libboost-system-dev \
    libgirepository1.0-dev \
    libglib2.0-doc \
    libjemalloc-dev \
    lsb-release \
    nvidia-cuda-toolkit \
    pkg-config \
    python3-dev \
    python3-numpy && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*
