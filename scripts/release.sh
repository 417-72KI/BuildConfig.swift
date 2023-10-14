#!/bin/zsh

set -eu

APPLICATION_INFO_FILE='Sources/Common/ApplicationInfo.swift'
PACKAGE_FILE='Package.swift'

if [ $# -ne 1 ]; then
    echo -e "\e[31m[Error] invalid arguments \`$@\`.\e[m"
    exit 1
fi

EXECUTABLE_NAME=$1

if [ `git symbolic-ref --short HEAD` != 'main' ]; then
    echo '\e[31mRelease job is enabled only in main.\e[m'
    exit 1
fi

if [ "$(git status -s | grep "${APPLICATION_INFO_FILE}")" = '' ]; then
    CURRENT_VERSION=$(swift run "$EXECUTABLE_NAME" --version)
    read "NEXT_VERSION?Next version(current: $(echo "\e[1m${CURRENT_VERSION}\e[m")) > "
    if [ "${NEXT_VERSION}" = '' ]; then
        NEXT_VERSION="${CURRENT_VERSION}"
    fi
    if [[ ! "${NEXT_VERSION}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(-.*)?$ ]]; then
        echo "\e[31m[Error] Invalid version format.\e[m"
        exit 1
    fi

    sed -i '' -E "s/let version = \"(.*)\"/let version = \"${NEXT_VERSION}\"/" "${APPLICATION_INFO_FILE}"
fi

if [ "$(git tag | grep "$(swift run "$EXECUTABLE_NAME" --version)")" != '' ]; then
    echo "\e[31m${NEXT_VERSION} is already tagged.\e[m"
    git checkout HEAD -- "$APPLICATION_INFO_FILE"
    exit 1
fi

if [[ "$(cat "$PACKAGE_FILE" | grep "let isDevelop =" | awk '{ print $NF }')" == 'true' ]]; then
    sed -i '' -e 's/let isDevelop = true/let isDevelop = false/g' "$PACKAGE_FILE"
fi

if [ "$(git status -s | grep .swift | grep -v "$(basename "$APPLICATION_INFO_FILE")" | grep -v "$(basename "$PACKAGE_FILE")")" != '' ]; then
    echo "\e[31mUnexpected added/modified/deleted file.\e[m"
    exit 1
fi

if ! type "gh" > /dev/null; then
    echo '`gh` not found. Install'
    brew install gh
fi

cd $(git rev-parse --show-toplevel)

# Version
TAG="$(swift run $EXECUTABLE_NAME --version 2>/dev/null)"
git commit -m "Bump version to ${TAG}" "$APPLICATION_INFO_FILE" "$PACKAGE_FILE"

# Tag
git tag "$TAG"

# Revert to develop mode
if [[ "$(cat "$PACKAGE_FILE" | grep "let isDevelop =" | awk '{ print $NF }')" == 'false' ]]; then
    sed -i '' -e 's/let isDevelop = false/let isDevelop = true/g' "$PACKAGE_FILE"
    git commit -m "Revert to develop mode" "$PACKAGE_FILE"
fi

git push --atomic origin main "$TAG"

# GitHub Release
gh release create "$TAG"
