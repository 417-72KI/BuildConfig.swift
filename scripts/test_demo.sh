#!/bin/sh

set -o pipefail

XCRESULT_PATH='test_output/BuildConfigDemo.xcresult'

if [[ -e "$XCRESULT_PATH" ]]; then
    rm -rf "$XCRESULT_PATH"
fi

if [[ "$(find Demo -depth 1 -name '*.xcodeproj')" == '' ]]; then
    $(dirname $0)/copy-lint-config.sh
    xcrun --sdk macosx swift run --package-path Demo/Tools xcodegen --spec Demo/project.yml 
fi

PROJECT_PATH=$(find Demo -depth 1 -name '*.xcodeproj' | head -n 1)
SCHEME="$(xcrun --sdk macosx xcodebuild -project "${PROJECT_PATH}" -list -json | jq -rc '.project.schemes[] | select(. | contains("Demo"))')"

echo "Scheme: $SCHEME"

xcrun --sdk macosx xcodebuild \
    -skipPackagePluginValidation \
    -enableCodeCoverage YES \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME}" \
    -destination 'platform=iOS Simulator,name=iPhone 14 Pro' \
    -derivedDataPath 'Demo/DerivedData' \
    -clonedSourcePackagesDirPath 'Demo/.build/SourcePackages' \
    -resultBundlePath "$XCRESULT_PATH" \
    clean test | xcpretty
