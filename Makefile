.PHONY : clean build test release xcodeproj lint deploy

default: clean build

clean:
	swift package clean
	rm -rf .build ./ConfigurationPlist.xcodeproj

xcodeproj:
	swift package generate-xcodeproj

dependencies:
	swift package update

build:
	swift build

test:
	swift test

release:
	swift build -c release -Xswiftc -static-stdlib
	zip -j .build/configurationPlist.zip .build/release/configurationPlist LICENSE

lint:
	pod spec lint --no-clean --allow-warnings

deploy:
	pod trunk push ConfigurationPlist.podspec
