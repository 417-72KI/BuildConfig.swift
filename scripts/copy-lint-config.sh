#!/bin/zsh
# Copy .swiftlint.yml from root because `parent_config` not working.
# https://github.com/realm/SwiftLint/issues/3645

SRCROOT=$(cd $(dirname $0) && git rev-parse --show-toplevel)

cat "${SRCROOT}/.swiftlint.yml" \
    | yq '. | .included = ["BuildConfigSwiftDemo"] 
            | .excluded = ["Libs", "Pods", "Carthage", "Tools", "Package.swift"]' \
    > "${SRCROOT}/Demo/.swiftlint.yml"
