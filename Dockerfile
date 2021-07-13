FROM ubuntu:focal AS builder
MAINTAINER Ingo Müller <ingo.mueller@inf.ethz.ch>

# Basics
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        binutils \
        libstdc++-10-dev \
        wget \
        xz-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clang+LLVM
RUN mkdir /opt/clang+llvm-11.1.0/ && \
    cd /opt/clang+llvm-11.1.0/ && \
    wget --progress=dot:giga https://github.com/llvm/llvm-project/releases/download/llvmorg-11.1.0/clang+llvm-11.1.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz -O - \
         | tar -x -I xz --strip-components=1 && \
    for file in bin/*; \
    do \
        ln -s $PWD/$file /usr/bin/$(basename $file)-11.1; \
    done && \
    ln -s libomp.so /opt/clang+llvm-11.1.0/lib/libomp.so.5 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-11.1 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-11.1 100

# Build boost
RUN cd /tmp/ && \
    wget --progress=dot:giga -O - \
        https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz \
        | tar -xz && \
    cd /tmp/boost_1_76_0 && \
    echo "using clang : 11.1 : $(which clang-11.1) ; " > tools/build/src/user-config.jam && \
    ./bootstrap.sh --prefix=/opt/boost-1.76.0 && \
    ./b2 numa=on define=BOOST_FIBERS_SPINLOCK_TTAS_ADAPTIVE_FUTEX --toolset=clang-11.1 -j$(nproc) && \
    ./b2 numa=on install && \
    cd / && \
    rm -rf /tmp/boost_1_76_0

# Main image
FROM ubuntu:focal

COPY --from=builder /opt/boost-1.76.0 /opt/boost-1.76.0
