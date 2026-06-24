#!/bin/bash
# Check disk space before installing Xcode
# Usage: bash scripts/check_xcode_space.sh

set -e

REQUIRED_GB=25
FREE_GB=$(df -g /System/Volumes/Data | awk 'NR==2 {print $4}')
FREE_H=$(df -h /System/Volumes/Data | awk 'NR==2 {print $4}')
USED_PCT=$(df -h /System/Volumes/Data | awk 'NR==2 {print $5}')

echo "========================================"
echo "  QueX — Xcode Disk Space Check"
echo "========================================"
echo "Free space:  $FREE_H ($FREE_GB GB)"
echo "Disk used:   $USED_PCT"
echo "Recommended: ${REQUIRED_GB}GB+ free for Xcode + iOS Simulator"
echo ""

if [ "$FREE_GB" -lt "$REQUIRED_GB" ]; then
  echo "⚠️  WARNING: Not enough space for Xcode!"
  echo ""
  echo "Xcode needs roughly:"
  echo "  • Xcode app:        ~12–15 GB"
  echo "  • iOS Simulator:    ~5–8 GB"
  echo "  • Build cache:      ~3–5 GB"
  echo ""
  echo "Free more space first:"
  echo "  open ~/Downloads     # delete large files"
  echo "  brew cleanup -s"
  echo "  Empty Trash"
  echo ""
  if [ "$FREE_GB" -lt 12 ]; then
    echo "❌ Cannot install Xcode safely. Need at least 12GB (25GB recommended)."
    exit 1
  fi
  echo "⚠️  You have $FREE_GB GB — install may fail mid-download."
else
  echo "✅ Enough space to install Xcode."
fi

echo ""
echo "Opening Xcode in Mac App Store..."
open "macappstore://apps.apple.com/app/id497799835"
echo ""
echo "After install, run:"
echo "  bash scripts/setup_xcode.sh"
echo "========================================"
