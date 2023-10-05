# BuildConfig.swift
[![Actions Status](https://github.com/417-72KI/BuildConfig.swift/workflows/CI/badge.svg)](https://github.com/417-72KI/BuildConfig.swift/actions)
[![Version](http://img.shields.io/cocoapods/v/BuildConfig.swift.svg?style=flat)](http://cocoapods.org/pods/BuildConfig.swift)
[![Platform](http://img.shields.io/cocoapods/p/BuildConfig.swift.svg?style=flat)](http://cocoapods.org/pods/BuildConfig.swift)
[![GitHub release](https://img.shields.io/github/release/417-72KI/BuildConfig.swift/all.svg)](https://github.com/417-72KI/BuildConfig.swift/releases)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-5.7-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/417-72KI/BuildConfig.swift/master/LICENSE.md)

BuildConfig.swift is a tool to generate configuration files by merging _yamls_ or _jsons_.

By splitting the file for each type of setting, it is possible to prevent conflicts of configuration files.

Also, by splitting the file for environment configurations, it will be easier to overwrite configurations for each environment.

## Example
> [!IMPORTANT]  
> There was a problem that parsing `0` or `1` should be `Int`, but `Bool` actually.  
> Since 5.2.0, keys for `Bool` must have `is` prefix.
> 
> This restriction will be fully resolved since 6.0.0.

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
        },
        "version": 1
    },
    "is_debug": true
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
let apiVersion = api["version"] as! Int // 1
let isDebug = config["is_debug"] as! Bool // true
```
#### _Using BuildConfig.swift_
```Swift
let config = BuildConfig.default
let domain = config.API.domain // "http://localhost"
let path = config.API.path.login.path // "/login"
let method = config.API.path.login.method // "POST"
let apiVersion = api.version // 1
let isDebug = config.isDebug // true
```

## Installation
### Common
- Create directory for splitted configuration files, e.g. `$PROJECT/Resources/BuildConfig`.
- If you use different settings for each environment, create `.env` into above directory.
- You don't have to add above directory into project.

### SwiftPM(6.0.0~)
> [!IMPORTANT]
> In this case, there are some constraints.
> 1. directory name must be `BuildConfig`
> 1. filename of environment settings must be match with Configuration name with snakenized.  
> examples:
>     - "Debug" -> `debug.yml`
>     - "AdHoc" -> `ad_hoc.yml`
>     - "Release" -> `release.yml`

1. In Project Settings, on the tab "Package Dependencies", click "+" and add `github.com/417-72KI/BuildConfig.swift`
1. Select your target, on the tab "Build Phases", in the section "Run Build Tool Plug-ins", click "+" and add `BuildConfigSwiftGenerate`
1. Build your project, now the `BuildConfig` struct should be available in your code.

### CocoaPods
- Add the following line to your test target in your Podfile:

```Ruby
pod 'BuildConfig.swift'
```

- Add the following `Run script` build phase to your test target's `Build Phases`:

#### Example

```Bash
if [ "${CONFIGURATION}" = 'Release' ]; then
  ENVIRONMENT='production'
else
  ENVIRONMENT='staging'
fi

"${PODS_ROOT}/BuildConfig.swift/buildconfigswift" -e $ENVIRONMENT "$SRCROOT/$PROJECT/Resources/BuildConfig"
```

You can replace `"$SRCROOT/$PROJECT/Resources/BuildConfig"` to the relative path from project to the directory you created.

Also, you can add `-o` option with output path to specify where `BuildConfig.plist` and `BuildConfig.generated.swift` will be created.

- Add `$(SRCROOT)/BuildConfig.generated.swift` into `Output Files` in above `Run script` build phase.
    - If you set a path to output generated files by `-o` option, you have to change `Output Files` to it's path.

- Drag the new `Run Script` phase **above** the `Compile Sources` phase and **below** `Check Pods Manifest.lock`.
- Build your project, in Finder you will now see a `BuildConfig.generated.swift` in `$SRCROOT` or a path you set with `-o` option in above `Run script` build phase.
- Drag them into your project.

_Tip:_ Add the `*.generated.swift` pattern to your `.gitignore` file to prevent unnecessary conflicts.

## What is `BuildConfig.swift` doing?
- Detect all yml/json files in `$SRCROOT/$PROJECT/Resources/BuildConfig`, exclude `.env`.
- If the `-e` option is set and a file with the same name as that option exists in `$SRCROOT/$PROJECT/Resources/BuildConfig/.env`, only that file is read.  
  For example, `-e staging` option means to read `$SRCROOT/$PROJECT/Resources/BuildConfig/.env/staging.{yml/yaml/json}`.
- Parse above files as `Swift.Dictionary`.
- Deep merge the above dictionaries.
- Output merged dictionary as a plist file.

## Libraries
* [YamlSwift](https://github.com/behrang/YamlSwift.git)
* [SourceKitten](https://github.com/jpsim/SourceKitten)
* [Commander](https://github.com/kylef/Commander)
* [PathKit](https://github.com/kylef/PathKit)

## License
Available under the [MIT License](LICENSE).
