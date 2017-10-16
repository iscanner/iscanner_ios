all: install
install:
	carthage update --platform iOS --verbose
build: install
	xcodebuild -project ios-app-bootstrap.xcodeproj -sdk iphonesimulator
.PHONY: test
