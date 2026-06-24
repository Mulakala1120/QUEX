#!/bin/bash
# Fix failed iOS Simulator downloads and reinstall
# Run: bash scripts/fix_simulator_disk.sh

set -e
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "========================================"
echo "  QueX — Fix iOS Simulator Install"
echo "========================================"

echo "Step 1: Quit Xcode and Simulator..."
osascript -e 'quit app "Xcode"' 2>/dev/null || true
osascript -e 'quit app "Simulator"' 2>/dev/null || true
sleep 2

echo "Step 2: Stop simulator background services (needs password)..."
sudo killall -9 simdiskimaged 2>/dev/null || true
sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null || true
sudo killall -9 SimulatorTrampoline 2>/dev/null || true
sleep 2

INBOX="/Library/Developer/CoreSimulator/Cryptex/Images/Inbox"
if [ -d "$INBOX" ]; then
  COUNT=$(ls -1 "$INBOX"/*.dmg 2>/dev/null | wc -l | tr -d ' ')
  if [ "$COUNT" -gt 0 ]; then
  echo "Step 3: Removing $COUNT failed partial downloads (~$(( COUNT * 7 ))GB)..."
  sudo rm -f "$INBOX"/*.dmg
  fi
fi

echo "Step 4: Cleaning caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm 2>/dev/null || true

FREE_GB=$(df -g /System/Volumes/Data | awk 'NR==2 {print $4}')
FREE_H=$(df -h /System/Volumes/Data | awk 'NR==2 {print $4}')
echo ""
echo "Free space now: $FREE_H ($FREE_GB GB)"

if [ "$FREE_GB" -lt 12 ]; then
  echo ""
  echo "ERROR: Need at least 12GB free. Delete files in Downloads and Empty Trash."
  open ~/Downloads
  exit 1
fi

echo ""
echo "Step 5: Downloading iOS Simulator (15-30 min, needs password)..."
sudo xcodebuild -downloadPlatform iOS

echo ""
echo "Step 6: Verifying..."
xcrun simctl list runtimes
xcrun simctl list devices available | head -10

open -a Simulator

echo ""
echo "========================================"
echo "Done! Run QueX:"
echo "  cd $(dirname "$0")/.."
echo "  flutter run"
echo "========================================"
