#!/bin/bash
# Generate the ClashBrawl Xcode project using XcodeGen.
# Run this from the repository root on macOS.

set -e

if ! command -v xcodegen &> /dev/null; then
    echo "xcodegen not found. Install it with: brew install xcodegen"
    exit 1
fi

# project.yml lives at the repository root, so run xcodegen from there.
cd "$(dirname "$0")/.."

echo "Generating ClashBrawl.xcodeproj..."
xcodegen generate

echo "Done. Open ClashBrawl.xcodeproj in Xcode."
