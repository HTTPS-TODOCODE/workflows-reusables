#!/bin/bash

set -euo pipefail

STACK="none"
VERSION=""
PACKAGE_MANAGER=""

if [ -f "pom.xml" ]; then
  STACK="java"
  PACKAGE_MANAGER="maven"

  VERSION=$(grep -oPm1 '(?<=<maven.compiler.release>)[^<]+' pom.xml || true)

  if [[ -z "$VERSION" ]]; then
    VERSION=$(grep -oPm1 '(?<=<maven.compiler.source>)[^<]+' pom.xml || true)
  fi

  if [[ -z "$VERSION" ]]; then
    VERSION=$(grep -oPm1 '(?<=<java.version>)[^<]+' pom.xml || true)
  fi
elif [ -f "package.json" ]; then
  STACK="node"

  if [[ -f "pnpm-lock.yaml" ]]; then
    PACKAGE_MANAGER="pnpm"
  elif [[ -f "yarn.lock" ]]; then
    PACKAGE_MANAGER="yarn"
  else
    PACKAGE_MANAGER="npm"
  fi

  if command -v jq >/dev/null 2>&1; then
    VERSION=$(jq -r '.engines.node // empty' package.json)
  fi

  if [[ -z "$VERSION" && -f ".nvmrc" ]]; then
    VERSION=$(cat .nvmrc)
  fi
fi

{
  echo "stack=$STACK"
  echo "stack_version=$VERSION"
  echo "package_manager=$PACKAGE_MANAGER"
} >> "$GITHUB_OUTPUT"