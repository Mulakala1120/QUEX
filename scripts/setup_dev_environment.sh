#!/bin/bash
# QueX development environment setup for macOS
# Run: bash scripts/setup_dev_environment.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  QueX Dev Environment Setup"
echo "========================================"

# --- Disk space check ---
FREE_GB=$(df -g / | awk 'NR==2 {print $4}')
if [ "$FREE_GB" -lt 15 ]; then
  echo -e "${RED}ERROR: Only ${FREE_GB}GB free. Need at least 15GB (20GB+ for Xcode).${NC}"
  echo "Free space: Empty Trash, delete Downloads, run: brew cleanup -s"
  exit 1
fi
echo -e "${GREEN}Disk space OK: ${FREE_GB}GB free${NC}"

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Flutter (skip if installed) ---
if ! command -v flutter &>/dev/null; then
  echo "Installing Flutter..."
  brew install --cask flutter
fi

# --- Android SDK ---
export ANDROID_HOME="${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}"
if [ ! -d "$ANDROID_HOME/cmdline-tools" ]; then
  echo "Installing Android command-line tools..."
  brew install --cask android-commandlinetools
fi

export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
flutter config --android-sdk "$ANDROID_HOME"

echo "Installing Android SDK packages (API 36)..."
yes | sdkmanager --licenses >/dev/null 2>&1 || true
sdkmanager --install \
  "platform-tools" \
  "platforms;android-36" \
  "build-tools;36.0.0" \
  "build-tools;28.0.3"

yes | flutter doctor --android-licenses >/dev/null 2>&1 || true

# --- Android Studio (optional GUI) ---
if [ ! -d "/Applications/Android Studio.app" ]; then
  echo -e "${YELLOW}Installing Android Studio (optional, ~1GB)...${NC}"
  brew install --cask android-studio || echo "Android Studio install skipped"
fi

# --- Xcode ---
if [ ! -d "/Applications/Xcode.app" ]; then
  echo -e "${YELLOW}Xcode not found. Install from Mac App Store (~12GB):${NC}"
  echo "  https://apps.apple.com/app/xcode/id497799835"
  echo "  Then run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
  echo "            sudo xcodebuild -runFirstLaunch"
else
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch || true
fi

# --- CocoaPods ---
if ! command -v pod &>/dev/null; then
  echo "Installing CocoaPods..."
  brew install cocoapods || sudo gem install cocoapods
fi

# --- FlutterFire CLI ---
export PATH="$PATH:$HOME/.pub-cache/bin"
dart pub global activate flutterfire_cli

# --- QueX project ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

flutter pub get

# --- Firebase (interactive — requires browser login) ---
echo ""
echo -e "${YELLOW}Firebase setup (interactive):${NC}"
echo "  1. Create project at https://console.firebase.google.com"
echo "  2. Run: flutterfire configure --project=YOUR_PROJECT_ID"
echo "  3. Enable Phone Auth + Cloud Messaging in Firebase Console"
echo "  4. Set enableFirebase=true in lib/core/config/app_config.dart"
echo ""

# --- iOS pods ---
if [ -d "ios" ] && command -v pod &>/dev/null && [ -d "/Applications/Xcode.app" ]; then
  echo "Installing iOS CocoaPods dependencies..."
  cd ios && pod install && cd ..
fi

# --- Shell profile ---
PROFILE="$HOME/.zshrc"
MARKER="# QueX Flutter environment"
if ! grep -q "$MARKER" "$PROFILE" 2>/dev/null; then
  cat >> "$PROFILE" << EOF

$MARKER
export ANDROID_HOME="$ANDROID_HOME"
export PATH="\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$HOME/.pub-cache/bin"
EOF
  echo -e "${GREEN}Added ANDROID_HOME to ~/.zshrc${NC}"
fi

echo ""
echo "========================================"
flutter doctor
echo "========================================"
echo -e "${GREEN}Setup complete! Run the app:${NC}"
echo "  cd $PROJECT_DIR"
echo "  flutter run -d chrome    # Web"
echo "  flutter run -d macos     # macOS"
echo "  flutter run              # Android/iOS device"
echo "========================================"
