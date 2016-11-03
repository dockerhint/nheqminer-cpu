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

ARG NHEQMINER_GIT_URL=https://github.com/nicehash/nheqminer.git
ARG NHEQMINER_BRANCH=linux

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

  # Build NiceHash Equihash Miner
RUN mkdir -p /tmp/build \
    && git clone "$NHEQMINER_GIT_URL" /tmp/build/nheqminer \
    && cd /tmp/build/nheqminer/cpu_xenoncat/Linux/asm/ \
    && sh assemble.sh \
    && cd ../../../Linux_cmake/nheqminer_cpu \
    && cmake . \
    && make
  # Install nheqminer_cpu
RUN cp /tmp/build/nheqminer/Linux_cmake/nheqminer_cpu/nheqminer_cpu /usr/bin/nheqminer \
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

CMD ["./entrypoint.sh"]
