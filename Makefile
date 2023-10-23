executable_name = buildconfigswift

.SILENT:

.PHONY: clean build test release lint format demo_app_init demo_test demo

default: clean build

clean:
	swift package clean
	git clean -xdf -e .build -e Demo/Tools/.build

dependencies:
	swift package update

build:
	swift build

test:
	./scripts/test.sh

release:
	scripts/release.sh $(executable_name)

lint:
	swift run swiftlint

format:
	swift run swiftlint --fix

demo_app_init:
	scripts/copy-lint-config.sh && \
	xcrun --sdk macosx swift run -c release --package-path Tools xcodegen --spec Demo/project.yml && \
	xcrun --sdk macosx swift run -c release --package-path Tools xcodegen --spec DemoWithPackage/App/project.yml

demo: demo_app_init
	xed Demo/BuildConfigSwiftDemo.xcodeproj

demo_package: demo_app_init
	xed DemoWithPackage/App/BuildConfigSwiftDemoApp.xcodeproj

demo_test:
	./scripts/test_demo.sh
