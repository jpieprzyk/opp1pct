#!/bin/bash

DIR=`cd \`dirname ${BASH_SOURCE[0]}\`; pwd`

docker run \
  --name postgres_opp \
  -v "${DIR}/data:/data" \
  -v "${DIR}/postgres_init:/docker-entrypoint-initdb.d" \
  -d postgres
