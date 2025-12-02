#!/bin/sh
set -eu

find . -name go.mod | while IFS= read -r modfile; do
    moddir=$(dirname "$modfile")
    echo "==> Testing module: $moddir"
    (cd "$moddir" && go test ./...)
done