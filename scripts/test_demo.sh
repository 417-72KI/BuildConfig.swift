#!/bin/sh

set -o pipefail

XCRESULT_PATH='test_output/BuildConfigDemo.xcresult'

if [[ -e "$XCRESULT_PATH" ]]; then
    rm -rf "$XCRESULT_PATH"
fi

if [[ "$(find Demo -depth 1 -name '*.xcodeproj')" == '' ]]; then
    echo '\e[33m`xcodeproj` in `Demo` not found, generating...\e[0m'
    $(dirname $0)/copy-lint-config.sh
    xcrun --sdk macosx swift run --package-path Tools xcodegen --spec Demo/project.yml 
fi

PROJECT_PATH=$(find Demo -depth 1 -name '*.xcodeproj' | head -n 1)
echo "\e[32mProject path: $PROJECT_PATH\e[0m"
SCHEME="$(xcrun --sdk macosx xcodebuild -project "${PROJECT_PATH}" -list -json | jq -rc '.project.schemes[] | select(. | contains("Demo"))')"

echo "\e[32mScheme: $SCHEME\e[0m"

xcrun --sdk macosx xcodebuild \
    -skipPackagePluginValidation \
    -enableCodeCoverage YES \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME}" \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -derivedDataPath 'Demo/DerivedData' \
    -clonedSourcePackagesDirPath 'Demo/.build/SourcePackages' \
    -resultBundlePath "$XCRESULT_PATH" \
    clean test | xcpretty
