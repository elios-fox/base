.PHONY: setup analyze test build-apk build-ios clean run pb-serve

## Install dependencies + download PocketBase
setup:
	flutter pub get
	@echo "Setup compleet. Start PocketBase met: make pb-serve"

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

## Start PocketBase lokaal
pb-serve:
	cd pocketbase && ./pocketbase serve --migrationsDir=../pb_migrations --hooksDir=../pb_hooks
