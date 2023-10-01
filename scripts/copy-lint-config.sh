#!/bin/zsh
# Copy .swiftlint.yml from root because `parent_config` not working.
# https://github.com/realm/SwiftLint/issues/3645

SRCROOT=$(cd $(dirname $0) && git rev-parse --show-toplevel)

if ! type brew > /dev/null; then
  echo '\e[33mHomebrew not found. Installing...\e[m'
  # Copied install script from https://brew.sh/
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ "$(/usr/bin/uname -m)" = 'arm64' ]; then
    if [ "$(cat ~/.zprofile | grep 'eval "$(/opt/homebrew/bin/brew shellenv)"')" != '' ]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi
fi

if ! type yq > /dev/null; then
    brew install yq
fi

cat "${SRCROOT}/.swiftlint.yml" \
    | yq '. | .included = ["BuildConfigSwiftDemo"] 
            | .excluded = ["Libs", "Pods", "Carthage", "Tools", "Package.swift"]' \
    > "${SRCROOT}/Demo/.swiftlint.yml"
