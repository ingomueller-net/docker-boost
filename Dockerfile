FROM ubuntu:bionic
MAINTAINER Ingo Müller <ingo.mueller@inf.ethz.ch>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        gcc-7 \
        g++-7 \
        wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 1 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 1

RUN cd /tmp/ && \
    wget --progress=dot:giga -O - \
        https://dl.bintray.com/boostorg/release/1.74.0/source/boost_1_74_0.tar.gz \
        | tar -xz && \
    cd /tmp/boost_1_74_0 && \
    ./bootstrap.sh --prefix=/opt/boost-1.74.0 && \
    ./b2 numa=on define=BOOST_FIBERS_SPINLOCK_TTAS_ADAPTIVE_FUTEX -j$(nproc) && \
    ./b2 numa=on install && \
    cd / && \
    rm -rf /tmp/boost_1_74_0
