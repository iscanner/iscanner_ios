all: install
install:
	carthage update --platform iOS --verbose
build: install
	xcodebuild -project iscanner_ios.xcodeproj -sdk iphonesimulator
.PHONY: test
