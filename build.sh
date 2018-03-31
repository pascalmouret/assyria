#!/bin/sh
set -e
. ./install-lib.sh

for PROJECT in $PROJECTS; do
  (cd src/$PROJECT && make install)
done
