.PHONY: setup analyze test build-apk build-ios clean run

## Install dependencies
setup:
	flutter pub get

## Run Flutter analyzer
analyze:
	flutter analyze

## Run tests met coverage
test:
	flutter test --coverage

## Build Android APK
build-apk:
	flutter build apk --release

## Build iOS (zonder codesigning)
build-ios:
	flutter build ios --release --no-codesign

## Clean build artifacts
clean:
	flutter clean
	rm -rf build/

## Run app in debug mode
run:
	flutter run
