#!/bin/bash

set -euo pipefail

ROOT_DIR="$(pwd)"
WORK_DIR="$(mktemp -d)"

echo "Root directory: ${ROOT_DIR}"
echo "Working directory: ${WORK_DIR}"

cleanup() {
  rm -rf "$WORK_DIR"
}

trap cleanup EXIT

validate_repository() {

  local allowed=(
    ".git"
    ".github"
  )

  shopt -s dotglob nullglob

  for item in "$ROOT_DIR"/*; do

    local name
    name="$(basename "$item")"

    if [[ ! " ${allowed[*]} " =~ " ${name} " ]]; then

      echo "::error::Repository is not empty. Found '${name}'."

      exit 1

    fi

  done

  shopt -u dotglob nullglob
}

move_to_root() {

  echo "Moving scaffold output to repository root..."

  shopt -s dotglob nullglob

  local entries=("$WORK_DIR"/*)

  if [[ ${#entries[@]} -eq 0 ]]; then
    echo "::error::No files were generated"

    exit 1
  fi

  if [[ ${#entries[@]} -eq 1 && -d "${entries[0]}" ]]; then

    echo "Single generated directory detected: $(basename "${entries[0]}")"

    mv "${entries[0]}"/* "$ROOT_DIR"/

  else

    echo "Generated files detected directly in working directory"

    mv "$WORK_DIR"/* "$ROOT_DIR"/

  fi

  shopt -u dotglob nullglob
}

validate_repository

case "$STACK:$PACKAGE_MANAGER" in

  "java:plugin")

    echo "Scaffolding Java project with Maven plugin"

    cd "$WORK_DIR"

    MVN_ARGS=(
      "${PLUGIN_GROUP_ID}:${PLUGIN_ARTIFACT_ID}:${PLUGIN_VERSION}:init"
      "-DgroupId=${GROUP_ID}"
      "-DartifactId=${ARTIFACT_ID}"
      "-Darchitecture=${ARCHITECTURE}"
      "-DjavaVersion=${VERSION}"
      "-DspringVersion=${SPRING_BOOT_VERSION}"
      "-Dconfiguration=${CONFIGURATION}"
      "-Dmapstruct=${MAPSTRUCT}"
      "-Dlombok=${LOMBOK}"
    )

    [[ -n "${PROJECT_NAME:-}" ]] &&
      MVN_ARGS+=("-Dname=${PROJECT_NAME}")

    [[ -n "${PACKAGE_NAME:-}" ]] &&
      MVN_ARGS+=("-DpackageName=${PACKAGE_NAME}")

    [[ -n "${INIT_VERSION:-}" ]] &&
          MVN_ARGS+=("-Dversion=${INIT_VERSION}")

    mvn "${MVN_ARGS[@]}"

    move_to_root

    ;;

  "java:maven")

    cd "$WORK_DIR"

    case "${FRAMEWORK:-none}" in

      spring-boot)

        echo "Scaffolding Spring Boot project"

        curl -fsSL -G https://start.spring.io/starter.zip \
          -d type=maven-project \
          -d language=java \
          -d bootVersion="${SPRING_BOOT_VERSION:-4.0.0}" \
          -d javaVersion="${VERSION}" \
          -d groupId="${GROUP_ID}" \
          -d artifactId="${ARTIFACT_ID}" \
          -d name="${PROJECT_NAME:-$ARTIFACT_ID}" \
          -d packageName="${PACKAGE_NAME:-$GROUP_ID}" \
          -d version="${INIT_VERSION:-0.0.0}" \
          -o project.zip

        unzip -oq project.zip

        rm project.zip

        ;;

      none|"")

        echo "Scaffolding Maven quickstart"

        mvn archetype:generate \
          -DgroupId="${GROUP_ID}" \
          -DartifactId="${ARTIFACT_ID}" \
          -DarchetypeArtifactId=maven-archetype-quickstart \
          -DarchetypeVersion=1.5 \
          -Dversion="${INIT_VERSION:-0.0.0}" \
          -Dmaven.compiler.release="${VERSION}" \
          -DinteractiveMode=false

        ;;

      *)

        echo "::error::Unsupported framework '${FRAMEWORK}'"

        exit 1

        ;;

    esac

    move_to_root

    ;;

  "node:npm"|"node:yarn"|"node:pnpm")

    cd "$WORK_DIR"

    PROJECT_NAME="${PROJECT_NAME:-${ARTIFACT_ID:-app}}"

    case "${FRAMEWORK}" in

      angular)

        echo "Scaffolding Angular project"

        npx --yes "@angular/cli@${VERSION:-latest}" \
          new "${PROJECT_NAME}" \
          --package-manager="${PACKAGE_MANAGER}" \
          --routing \
          --style=scss \
          --skip-git \
          --skip-install

        ;;

      react)

        echo "Scaffolding React project"

        case "${PACKAGE_MANAGER}" in

          npm)

            npm create vite@latest \
              "${PROJECT_NAME}" \
              -- \
              --template react

            ;;

          yarn)

            yarn create vite \
              "${PROJECT_NAME}" \
              --template react

            ;;

          pnpm)

            pnpm create vite \
              "${PROJECT_NAME}" \
              --template react

            ;;

        esac

        ;;

      *)

        echo "::error::Unsupported framework '${FRAMEWORK}'"

        exit 1

        ;;

    esac

    move_to_root

    ;;

  *)

    echo "::error::Unsupported combination"

    exit 1

    ;;

esac

echo "Scaffold completed successfully"