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
	@scripts/release.sh $(executable_name)

lint:
	bundle exec pod spec lint --no-clean --allow-warnings
