#!/bin/bash
set -e

for arg in "$@" ; do
  if [[ $arg == "-p"* ]] ; then
    exec /usr/bin/nheqminer "$@"
  elif [[ $arg == "-h"* ]] ; then
    exec /usr/bin/nheqminer -h
  fi
done

exec /usr/bin/nheqminer "$@"

