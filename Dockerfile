FROM ubuntu:bionic
MAINTAINER Ingo Müller <ingo.mueller@inf.ethz.ch>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        gcc-7 \
        g++-7 \
        patch \
        wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 1 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 1

RUN cd /tmp/ && \
    wget --progress=dot:giga -O - \
        https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz \
        | tar -xz && \
    cd /tmp/boost_1_72_0 && \
    { \
        echo "diff --git a/boost/fiber/numa/algo/work_stealing.hpp b/boost/fiber/numa/algo/work_stealing.hpp"; \
        echo "index c589902..ef5e964 100644"; \
        echo "--- a/boost/fiber/numa/algo/work_stealing.hpp"; \
        echo "+++ b/boost/fiber/numa/algo/work_stealing.hpp"; \
        echo "@@ -36,7 +36,7 @@ namespace fibers {"; \
        echo " namespace numa {"; \
        echo " namespace algo {"; \
        echo " "; \
        echo "-class work_stealing : public boost::fibers::algo::algorithm {"; \
        echo "+class BOOST_FIBERS_DECL work_stealing : public boost::fibers::algo::algorithm {"; \
        echo " private:"; \
        echo "     static std::vector< intrusive_ptr< work_stealing > >    schedulers_;"; \
        echo " "; \
    } | patch -p1 && \
    ./bootstrap.sh --prefix=/opt/boost-1.72.0 && \
    ./b2 numa=on define=BOOST_FIBERS_SPINLOCK_TTAS_ADAPTIVE_FUTEX -j$(nproc) && \
    ./b2 numa=on install && \
    cd / && \
    rm -rf /tmp/boost_1_72_0
