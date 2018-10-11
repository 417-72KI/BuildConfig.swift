.PHONY : clean build test release xcodeproj lint deploy

default: clean build

clean:
	swift package clean
	rm -rf .build ./ConfigurationPlist.xcodeproj

xcode:
	swift package generate-xcodeproj
	ruby -e "require 'xcodeproj'" \
	-e "project_path = './ConfigurationPlist.xcodeproj'" \
	-e "project = Xcodeproj::Project.open(project_path)" \
	-e "project.targets.each do |target|" \
	-e "if target.name == 'ConfigurationPlist' then" \
	-e "phase = project.new(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)" \
	-e "phase.shell_script = 'cp -r \"\$$SRCROOT/TestResources\" \"\$$BUILT_PRODUCTS_DIR\"'" \
	-e "target.build_phases << phase" \
	-e "end" \
	-e "end" \
	-e "project.save"

dependencies:
	swift package update

build:
	swift build

test:
	swift test

release:
	rm -f .build/configurationPlist.zip
	swift build -c release -Xswiftc -static-stdlib
	zip -j .build/configurationPlist.zip .build/release/configurationPlist LICENSE

lint:
	pod spec lint --no-clean --allow-warnings

deploy:
	pod trunk push ConfigurationPlist.podspec
