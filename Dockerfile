FROM ubuntu:xenial
MAINTAINER Ingo Müller <ingo.mueller@inf.ethz.ch>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        gcc-5 \
        g++-5 \
        wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 1 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 1

RUN cd /tmp/ && \
    wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz -O - \
        | tar -xz && \
    cd /tmp/boost_1_67_0 && \
    ./bootstrap.sh --prefix=/opt/boost-1.67.0 && \
    ./b2 && \
    ./b2 install && \
    cd / && \
    rm -rf /tmp/boost_1_67_0
