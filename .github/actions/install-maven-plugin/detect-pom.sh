#!/bin/bash

set -euo pipefail

if compgen -G "**/pom.xml" > /dev/null; then
  echo "has_pom=true" >> "$GITHUB_OUTPUT"
else
  echo "has_pom=false" >> "$GITHUB_OUTPUT"
fi
