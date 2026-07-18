#!/bin/bash
# Generate the ClashBrawl Xcode project using XcodeGen.
# Run this from the ClashBrawl directory on macOS.

set -e

if ! command -v xcodegen &> /dev/null; then
    echo "xcodegen not found. Install it with: brew install xcodegen"
    exit 1
fi

echo "Generating ClashBrawl.xcodeproj..."
xcodegen generate

echo "Done. Open ClashBrawl.xcodeproj in Xcode."
