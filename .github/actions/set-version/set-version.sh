#!/bin/bash
set -euo pipefail

case $STACK in
  "java")
    mvn versions:set -DnewVersion="$NEW_VERSION" -DgenerateBackupPoms=false
    ;;
  "node")
    case $PACKAGE_MANAGER in
      "npm")
        npm version "$NEW_VERSION" --no-git-tag-version
        ;;
      "yarn")
        yarn version --new-version "$NEW_VERSION" --no-git-tag-version
        ;;
      "pnpm")
        pnpm version "$NEW_VERSION" --no-git-tag-version
        ;;
      *)
        echo "Unsupported package manager: $PACKAGE_MANAGER"
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Unsupported stack: $STACK"
    exit 1
    ;;
esac