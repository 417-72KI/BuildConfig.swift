executable_name = buildconfigswift

.PHONY: clean build test release lint format

default: clean build

clean:
	swift package clean
	git clean -xdf -e .build -e Demo/Tools/.build

dependencies:
	swift package update

build:
	swift build

test:
	swift test

release:
	@scripts/release.sh $(executable_name)

lint:
	@swift run swiftlint

format:
	@swift run swiftlint --fix

demo_app_init:
	@scripts/copy-lint-config.sh && \
	cd Demo && \
	xcrun --sdk macosx swift run -c release --package-path Tools xcodegen

.PHONY: demo
demo: demo_app_init
	@xed Demo/BuildConfigSwiftDemo.xcodeproj
