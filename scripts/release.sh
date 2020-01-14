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

if ! type "github-release" > /dev/null; then
    echo '`github-release` not found. Install'
    go get github.com/aktau/github-release
fi

cd $(git rev-parse --show-toplevel)

# Build
rm -f .build/${EXECUTABLE_NAME}.zip
swift build -c release -Xswiftc -suppress-warnings
.build/release/${EXECUTABLE_NAME} --version
zip -j .build/${EXECUTABLE_NAME}.zip .build/release/${EXECUTABLE_NAME} LICENSE

# Version
TAG=$(cat "${APPLICATION_INFO_FILE}" | grep version | awk '{ print $NF }' | gsed -r 's/\"(.*)\"/\1/g')
gsed -i -r "s/(s\.version\s*?=\s)\"([0-9]*\.[0-9]*\.[0-9]*?)\"/\1\"${TAG}\"/g" ${PROJECT_NAME}.podspec
git commit -m "Bump version to ${TAG}" "${PROJECT_NAME}.podspec" "${APPLICATION_INFO_FILE}"

# TAG
git tag "${TAG}"
git push origin master "${TAG}"

# GitHub Release
github-release release \
    --user 417-72KI \
    --repo ${PROJECT_NAME} \
    --tag "${TAG}"

github-release upload \
    --user 417-72KI \
    --repo ${PROJECT_NAME} \
    --tag "${TAG}" \
    --name "${EXECUTABLE_NAME}.zip" \
    --file .build/${EXECUTABLE_NAME}.zip

# CocoaPods
bundle exec pod trunk push ${PROJECT_NAME}.podspec
