project_name = BuildConfig.swift
executable_name = buildconfigswift

.PHONY : clean build test

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
	rm -f .build/$(executable_name).zip
	swift build -c release -Xswiftc -static-stdlib -Xswiftc -suppress-warnings
	.build/release/$(executable_name) --version
	zip -j .build/$(executable_name).zip .build/release/$(executable_name) LICENSE

lint:
	bundle exec pod spec lint --no-clean --allow-warnings

deploy:
	bundle exec pod trunk push $(project_name).podspec
