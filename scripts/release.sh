#!/bin/zsh

set -eu

APPLICATION_INFO_FILE='Sources/Common/ApplicationInfo.swift'

if [ $# -ne 2 ]; then
    echo -e "\e[31mError\e[m"
    exit 1
fi

PROJECT_NAME=$1
EXECUTABLE_NAME=$2

if [ `git symbolic-ref --short HEAD` != 'master' ]; then
    echo '\e[31mRelease job is enabled only in master.\e[m'
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

if ! type "gsed" > /dev/null; then
    echo '`gsed` not found. Install'
    brew install gnu-sed
fi

if ! type "gh" > /dev/null; then
    echo '`gh` not found. Install'
    brew install gh
fi

cd $(git rev-parse --show-toplevel)

# Version
TAG="$(swift run $EXECUTABLE_NAME --version 2>/dev/null)"
gsed -i -r "s/(s\.version\s*?=\s)\"([0-9]*\.[0-9]*\.[0-9]*?)\"/\1\"${TAG}\"/g" ${PROJECT_NAME}.podspec
git commit -m "Bump version to ${TAG}" "${PROJECT_NAME}.podspec" "${APPLICATION_INFO_FILE}"

# # TAG
# git tag "${TAG}"
# git push origin master "${TAG}"

# GitHub Release
gh release create "$TAG"
