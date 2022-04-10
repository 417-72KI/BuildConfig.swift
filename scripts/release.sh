#!/bin/zsh

set -eu

APPLICATION_INFO_FILE='Sources/Common/ApplicationInfo.swift'

if [ $# -ne 2 ]; then
    echo -e "\e[31mError\e[m"
    exit 1
fi

EXECUTABLE_NAME=$1

if [ `git symbolic-ref --short HEAD` != 'main' ]; then
    echo '\e[31mRelease job is enabled only in main.\e[m'
    exit 1
fi

if [ "$(git status -s | grep "${APPLICATION_INFO_FILE}")" = '' ]; then
    echo "\e[31m${APPLICATION_INFO_FILE} is not modified.\e[m"
    exit 1
fi

if [ "$(git status -s | grep .swift | grep -v ApplicationInfo.swift)" != '' ]; then
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
git commit -m "Bump version to ${TAG}" "${APPLICATION_INFO_FILE}"

git push origin main

# GitHub Release
gh release create "$TAG"
