# BuildConfig.swift
[![Build Status](https://travis-ci.org/417-72KI/BuildConfig.swift.svg?branch=master)](https://travis-ci.org/417-72KI/BuildConfig.swift)
[![Version](http://img.shields.io/cocoapods/v/BuildConfig.swift.svg?style=flat)](http://cocoadocs.org/pods/BuildConfig.swift)
[![Platform](http://img.shields.io/cocoapods/p/BuildConfig.swift.svg?style=flat)](http://cocoadocs.org/pods/BuildConfig.swift)
[![GitHub release](https://img.shields.io/github/release/417-72KI/BuildConfig.swift/all.svg)](https://github.com/417-72KI/BuildConfig.swift/releases)
![Swift](https://img.shields.io/badge/Swift-4.2.svg)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-4.2.0-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/417-72KI/BuildConfig.swift/master/LICENSE.md)

BuildConfig.swift is a tool to generate configuration files by merging _yamls_ or _jsons_.

By splitting the file for each type of setting, it is possible to prevent conflicts of configuration files.

Also, by splitting the file for environment configurations, it will be easier to overwrite configurations for each environment.

## Example
### Base JSON file
```json
{
    "API": {
        "domain": "http://localhost",
        "path": {
            "login": {
                "method": "POST",
                "path": "/login"
            },
            "getList": {
                "method": "GET",
                "path": "/list"
            }
        }
    }
}
```

### Call above configuration
#### _Vanilla_
```Swift
let file = Bundle.main.path(forResource: "Base", ofType: "json")!
let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
let config = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
let api = config["API"] as! [String: Any]
let domain = api.domain as! String // "http://localhost"
let loginPath = (api.path as! [String: Any])["login"] as! [String: Any]
let path = loginPath.path // "/login"
let method = loginPath.method // "POST"
```
#### _Using BuildConfig.swift_
```Swift
let config = BuildConfig.default
let domain = config.API.domain // "http://localhost"
let path = config.API.path.login.path // "/login"
let method = config.API.path.login.method // "POST"
```

## Installation
### Common
- Create directory for splitted configuration files, e.g. `$PROJECT/Resources/Config`.
- If you use different settings for each environment, create `.env` into above directory.
- You don't have to add above directory into project.

### CocoaPods
- Add the following line to your test target in your Podfile:

```Ruby
pod 'BuildConfig.swift'
```

- Add the following `Run script` build phase to your test target's `Build Phases`:

```Bash
if [ "${CONFIGURATION}" = 'Release' ]; then
  ENVIRONMENT='production'
else
  ENVIRONMENT='staging'
fi

"${PODS_ROOT}/BuildConfig.swift/buildconfig_swift" -e $ENVIRONMENT "$SRCROOT/$PROJECT/Resources/Config"
```

You can replace `"$SRCROOT/$PROJECT/Resources/Config"` to the relative path from project to the directory you created.

Also, you can add `-o` option with output path to specify where `BuildConfig.plist` and `BuildConfig.generated.swift` will be created.

- Add `$(TEMP_DIR)/buildconfigswift-lastrun` into `Input Files` in above `Run script` build phase.
- Add `$(SRCROOT)/BuildConfig.plist` and `$(SRCROOT)/BuildConfig.generated.swift` into `Output Files` in above `Run script` build phase.
    - If you set a path to output generated files by `-o` option, you have to change `Output Files` to those paths.

- Drag the new `Run Script` phase **above** the `Compile Sources` phase and **below** `Check Pods Manifest.lock`  
  If you are using [_R.swift_](https://github.com/mac-cain13/R.swift), drag the new `Run Script` **above** the `Run Script` phase for _R.swift_ and you can load with `R.file.configPlist`.
- Build your project, in Finder you will now see a `BuildConfig.plist` and `BuildConfig.generated.swift` in `$SRCROOT` or a path you set with `-o` option in above `Run script` build phase.
- Drag them into your project.

_Tip:_ Add the `BuildConfig.plist` pattern and the `*.generated.swift` pattern to your `.gitignore` file to prevent unnecessary conflicts.

### Manually
TODO: Future support.

## What is `BuildConfig.swift` doing?
- Detect all yml/json files in `$SRCROOT/$PROJECT/Resources/Config`, exclude `.env`.
- If the `-e` option is set and a file with the same name as that option exists in `$SRCROOT/$PROJECT/Resources/Config/.env`, only that file is read.  
  For example, `-e staging` option means to read `$SRCROOT/$PROJECT/Resources/Config/.env/staging.{yml/yaml/json}`.
- Parse above files as `Swift.Dictionary`.
- Deep merge the above dictionaries.
- Output merged dictionary as a plist file.

## Libraries
* [YamlSwift](https://github.com/behrang/YamlSwift.git)
* [SourceKitten](https://github.com/jpsim/SourceKitten)
* [Commander](https://github.com/kylef/Commander)
* [PathKit](https://github.com/kylef/PathKit)
* [Nimble](https://github.com/Quick/Nimble.git)
* [Quick](https://github.com/Quick/Quick.git)

## License
Available under the [MIT License](LICENSE).
