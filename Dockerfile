FROM ubuntu:18.04
LABEL maintainer="michael.liberman@vonage.com"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        g++ \
        make \
        automake \
        autoconf \
        bzip2 \
        unzip \
        wget \
        sox \
        libtool \
        git \
        subversion \
        python2.7 \
        python3 \
        zlib1g-dev \
        ca-certificates \
        gfortran \
        patch \
        ffmpeg \
        libatlas3-base \
        libboost-all-dev \
	    vim && \
    rm -rf /var/lib/apt/lists/*

# RUN ln -s /usr/bin/python2.7 /usr/bin/python

COPY . /opt/kaldi

RUN cd /opt/kaldi/tools && \
    ./extras/check_dependencies.sh
    # ./extras/install_mkl.sh

RUN cd /opt/kaldi/tools && \
    make -j $(nproc)

RUN cd /opt/kaldi/tools && \
    extras/install_irstlm.sh

RUN cd /opt/kaldi/src && \
    ./configure --shared && \
    make depend -j $(nproc) && \
    make -j $(nproc)
