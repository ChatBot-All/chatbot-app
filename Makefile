.PHONY: apk ipa open_apk open_ipa
open_apk:
	open ./build/app/outputs/flutter-apk/
open_ipa:
	open ./build/ios/ipa/

apk:
	fvm flutter build apk --release
	$(MAKE) open_apk

ipa:
	fvm flutter build ipa --release
	$(MAKE) open_ipa

pub:
	fvm flutter pub get
	fvm flutter build ios
	fvm flutter build macos