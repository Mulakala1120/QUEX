#!/bin/bash
# Run after Xcode installs from App Store
# Usage: bash scripts/setup_xcode.sh

set -e
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "Configuring Xcode for QueX..."

if [ ! -d "/Applications/Xcode.app" ]; then
  echo "ERROR: Xcode.app not found. Install from Mac App Store first."
  exit 1
fi

sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept 2>/dev/null || true

echo "Xcode version:"
xcodebuild -version

echo "Installing iOS CocoaPods dependencies..."
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"
flutter pub get
cd "$PROJECT_DIR/ios"
pod install

echo ""
echo "Opening iOS Simulator..."
open -a Simulator

echo ""
echo "Done! Run QueX on iOS:"
echo "  cd $(dirname "$0")/.."
echo "  flutter run"
