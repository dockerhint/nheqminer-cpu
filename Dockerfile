#
# Dockerized zcash cpuminer
# usage: docker run baseboxorg/nheqminer:supernova -l zec.suprnova.cc:2142 -u bitbuyio.donate -p x
#
# BTC tips welcome 1PboFDkBsW2i968UnehWwcSrM9Djq5LcLB
#
#▒███████▒ ▄████▄   ▄▄▄        ██████  ██░ ██
#▒ ▒ ▒ ▄▀░▒██▀ ▀█  ▒████▄    ▒██    ▒ ▓██░ ██▒
#░ ▒ ▄▀▒░ ▒▓█    ▄ ▒██  ▀█▄  ░ ▓██▄   ▒██▀▀██░
#  ▄▀▒   ░▒▓▓▄ ▄██▒░██▄▄▄▄██   ▒   ██▒░▓█ ░██
#▒███████▒▒ ▓███▀ ░ ▓█   ▓██▒▒██████▒▒░▓█▒░██▓
#░▒▒ ▓░▒░▒░ ░▒ ▒  ░ ▒▒   ▓▒█░▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒
#░░▒ ▒ ░ ▒  ░  ▒     ▒   ▒▒ ░░ ░▒  ░ ░ ▒ ░▒░ ░
#░ ░ ░ ░ ░░          ░   ▒   ░  ░  ░   ░  ░░ ░
#  ░ ░    ░ ░            ░  ░      ░   ░  ░  ░
#░        ░
#
# If you want to mine within an interactive shell:
# 1) start the container
# docker run --interactive --tty --entrypoint=/bin/bash baseboxorg/nheqminer:supernova
#
# 2) run the cpuminer manually daemon
# nheqminer -l zec.suprnova.cc:2142 -u bitbuyio.donate -p x -t 4
#
# 3) happyness
#
# Last change:
# * Allow any Stratum based pool, add suprnova default (6086f95) 


FROM ubuntu:16.04
MAINTAINER BitBuyIO <developer@bitbuy.io>

RUN groupadd -r nicehash \
  && useradd -r -g nicehash -m -d /home/nicehash/ -G sudo nicehash

ARG NHEQMINER_GIT_URL=https://github.com/ocminer/nheqminer.git
ARG NHEQMINER_BRANCH=linux

ENV GOSU_VERSION 1.10

RUN DEBIAN_FRONTEND=noninteractive; \
  apt-get autoclean && apt-get autoremove && apt-get update \
  && apt-get -qqy install --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    git \
    libboost-all-dev \
    wget \
  && rm -rf /var/lib/apt/lists/*
  # Get gosu
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true
  # Build NiceHash Equihash Miner
RUN gosu nicehash mkdir -p /tmp/build && chown nicehash:nicehash /tmp/build \
    && gosu nicehash git clone -b "$NHEQMINER_BRANCH" "$NHEQMINER_GIT_URL" /tmp/build/nheqminer \
    && cd /tmp/build/nheqminer/cpu_xenoncat/Linux/asm/ \
    && gosu nicehash sh assemble.sh \
    && cd ../../../Linux_cmake/nheqminer_cpu \
    && gosu nicehash cmake .. \
    && gosu nicehash make
  # Install nheqminer_cpu
RUN /usr/bin/install -g nicehash -o nicehash -s -c nheqminer -t /usr/local/bin/ \
  # Cleanup
    && rm -rf /tmp/build/ \
    && apt-get purge -y --auto-remove \
      build-essential \
      ca-certificates \
      cmake \
      git \
      wget

WORKDIR /home/nicehash

COPY entrypoint.sh /home/nicehash/entrypoint.sh
RUN chmod +x /home/nicehash/entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["-h"]
