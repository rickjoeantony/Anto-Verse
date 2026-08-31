#!/bin/bash
set -e

echo "=== Building LeukQuant iOS Release (.ipa) ==="

# 1. Fetch Flutter dependencies
echo "[1/4] Resolving Flutter dependencies..."
flutter pub get

# 2. Build iOS release bundle without codesign
echo "[2/4] Compiling iOS Release app..."
flutter build ios --release --no-codesign

# 3. Package Runner.app into an IPA (Payload format)
echo "[3/4] Packaging .ipa..."
cd build/ios/iphoneos
rm -rf Payload LeukQuant.ipa
mkdir Payload
cp -r Runner.app Payload/
zip -r -y LeukQuant.ipa Payload
rm -rf Payload

echo "[4/4] Done! IPA created at:"
echo "$(pwd)/LeukQuant.ipa"
