#!/bin/bash
# Connect QueX to your Firebase project (run after creating Firebase project)
# Usage: bash scripts/setup_firebase.sh YOUR_FIREBASE_PROJECT_ID

set -e

PROJECT_ID="$1"
if [ -z "$PROJECT_ID" ]; then
  echo "Usage: bash scripts/setup_firebase.sh YOUR_FIREBASE_PROJECT_ID"
  echo ""
  echo "Steps:"
  echo "  1. Go to https://console.firebase.google.com"
  echo "  2. Create project named 'QueX'"
  echo "  3. Add Android app: com.quex.app"
  echo "  4. Add iOS app: com.quex.app"
  echo "  5. Run this script with your project ID"
  exit 1
fi

export PATH="$PATH:$HOME/.pub-cache/bin"
dart pub global activate flutterfire_cli

cd "$(dirname "$0")/.."
flutterfire configure \
  --project="$PROJECT_ID" \
  --platforms=android,ios,web \
  --android-package-name=com.quex.app \
  --ios-bundle-id=com.quex.app \
  --yes

echo ""
echo "Firebase configured! Next steps:"
echo "  1. Firebase Console → Authentication → Enable Phone"
echo "  2. Firebase Console → Cloud Messaging → set up APNs (iOS)"
echo "  3. Set in lib/core/config/app_config.dart:"
echo "       enableFirebase = true"
echo "       enablePushNotifications = true"
echo "  4. flutter run"
