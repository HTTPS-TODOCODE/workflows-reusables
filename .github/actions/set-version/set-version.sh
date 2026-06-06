#!/bin/bash

set -euo pipefail

case $STACK in
  "java-maven")
    mvn versions:set -DnewVersion="$NEW_VERSION" -DgenerateBackupPoms=false
    ;;
  "node")
    npm version "$NEW_VERSION" --no-git-tag-version
    ;;
  *)
    echo "Unsupported workflow: $STACK"
    exit 1
    ;;
esac