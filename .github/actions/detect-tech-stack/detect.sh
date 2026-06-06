#!/bin/bash

set -euo pipefail

STACK="none"

if [ -f "pom.xml" ]; then
  STACK="java-maven"
elif [ -f "package.json" ]; then
  STACK="node"
fi

echo "stack=$STACK" >> "$GITHUB_OUTPUT"