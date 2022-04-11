executable_name = buildconfigswift

.PHONY: clean build test

default: clean build

clean:
	swift package clean
	git clean -xdf -e .build

dependencies:
	swift package update

build:
	swift build

test:
	swift test

release:
	@scripts/release.sh $(executable_name)

lint:
	bundle exec pod spec lint --no-clean --allow-warnings

demo_app_init:
	@export POD_VERSION="$$(swift run $(executable_name) --version 2>/dev/null)" && \
	cd Demo && \
	bundle install --quiet 2>/dev/null && \
	xcrun --sdk macosx swift run -c release --package-path Tools xcodegen && \
	bundle exec pod install

demo_app_update:
	@export POD_VERSION="$$(swift run $(executable_name) --version 2>/dev/null)" && \
	cd Demo && \
	bundle exec pod update

.PHONY: demo
demo: demo_app_init
	@xed Demo/BuildConfigSwiftDemo.xcworkspace
