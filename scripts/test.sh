#!/bin/sh

set -o pipefail

XCRESULT_PATH='test_output/BuildConfig.swift.xcresult'

if [[ -e "$XCRESULT_PATH" ]]; then
    rm -rf "$XCRESULT_PATH"
fi

SCHEME="$(xcrun --sdk macosx xcodebuild -list -json | jq -rc '.workspace.schemes[] | select(. | startswith("BuildConfig"))')"

echo "Scheme: $SCHEME"

xcrun --sdk macosx xcodebuild \
    -enableCodeCoverage YES \
    -scheme "${SCHEME}" \
    -destination "platform=macOS" \
    -derivedDataPath 'DerivedData' \
    -clonedSourcePackagesDirPath '.build/SourcePackages' \
    -resultBundlePath "$XCRESULT_PATH" \
    clean test | xcpretty
