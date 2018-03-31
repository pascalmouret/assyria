#!/bin/sh
set -e
. ./config.sh

for PROJECT in $PROJECTS; do
  (cd src/$PROJECT && make install-lib)
done
