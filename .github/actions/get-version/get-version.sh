#!/bin/bash

set -euo pipefail

case "$STACK" in
  "java-maven")
    VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
    ;;
  "node")
    VERSION=$(jq -r '.version' package.json)
    ;;
  *)
    echo "Unsupported workflow: $STACK"
    exit 1
    ;;
esac

BASE_VERSION="${VERSION%-SNAPSHOT}"

if [[ ! "$BASE_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "::error::Invalid version format: $BASE_VERSION"
  exit 1
fi

if [[ "$VERSION" == *"-SNAPSHOT" ]]; then
  IS_SNAPSHOT="true"
else
  IS_SNAPSHOT="false"
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$BASE_VERSION"

{
  echo "version=$VERSION"
  echo "base_version=$BASE_VERSION"
  echo "is_snapshot=$IS_SNAPSHOT"
  echo "major=$MAJOR"
  echo "minor=$MINOR"
  echo "patch=${PATCH:-0}"
} >> "$GITHUB_OUTPUT"