#!/bin/bash

set -euo pipefail

echo "Cloning plugin from $PLUGIN_REPO_URL at tag $PLUGIN_REPO_TAG"

rm -rf "$WORK_DIR"

git clone --depth 1 --branch "$PLUGIN_REPO_TAG" "$PLUGIN_REPO_URL" "$WORK_DIR"

cd "$WORK_DIR"

echo "Repo content:"
ls -la

if [ ! -f "pom.xml" ]; then
    echo "❌ No pom.xml found in plugin repository"
    exit 1
fi

echo "Installing plugin to local Maven repository"
mvn clean install "$MAVEN_ARGS"

echo "plugin_dir=$WORK_DIR" >> "$GITHUB_OUTPUT"
echo "✅ Plugin installed from ${PLUGIN_REPO_URL} at tag ${PLUGIN_REPO_TAG}"
