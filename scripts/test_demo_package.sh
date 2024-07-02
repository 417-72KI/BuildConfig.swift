#!/bin/sh

set -o pipefail

XCRESULT_PATH="$(git rev-parse --show-toplevel)/test_output/BuildConfigDemoPackage.xcresult"

if [[ -e "$XCRESULT_PATH" ]]; then
    rm -rf "$XCRESULT_PATH"
fi

$(dirname $0)/copy-lint-config.sh

cd DemoWithPackage
SCHEME="$(xcrun --sdk macosx xcodebuild -list -json | jq -rc '.workspace.schemes[] | select(. | contains("Demo"))')"

echo "\e[32mScheme: $SCHEME\e[0m"

xcrun --sdk macosx xcodebuild \
    -skipPackagePluginValidation \
    -enableCodeCoverage YES \
    -scheme "${SCHEME}" \
    -destination 'platform=iOS Simulator,name=iPhone 14 Pro' \
    -derivedDataPath 'DerivedData' \
    -clonedSourcePackagesDirPath '.build/SourcePackages' \
    -resultBundlePath "$XCRESULT_PATH" \
    clean test | xcpretty
