# ClashBrawl

A complete iOS game foundation built with Swift and SwiftUI.
ClashBrawl is a premium hybrid of Clash Royale (card/deck strategy) and Brawl Stars (real-time action combat).

## Features
- Real-time action combat
- Card/deck strategy
- Hero and unit progression
- Oracle Cloud backend placeholders
- Mock offline mode

## Run Instructions

### Generate the Xcode project with XcodeGen (recommended)

1. Open a terminal on macOS.
2. Install XcodeGen if you haven't already:
   ```bash
   brew install xcodegen
   ```
3. From the repository root, generate the project:
   ```bash
   ./ClashBrawl/generate_project.sh
   # or simply: xcodegen generate
   ```
4. Open the generated `ClashBrawl.xcodeproj` in Xcode 26.6+.
5. Update `ClashBrawl/ClashBrawl/Config/OracleConfig.swift` with your Oracle Cloud details (or leave mock mode on).
6. Build and run on a simulator or device.

### Manual Xcode project

1. Open Xcode 26.6+ on macOS.
2. Create a new iOS App project named `ClashBrawl`.
3. Copy all files from `ClashBrawl/ClashBrawl` into the project, preserving the folder structure.
4. Update `ClashBrawl/ClashBrawl/Config/OracleConfig.swift` with your Oracle Cloud details.
5. Build and run on a simulator or device.

## Oracle Placeholders

Edit `ClashBrawl/ClashBrawl/Config/OracleConfig.swift`:
- `serverBaseURL`
- `apiKey`
- `region`
- `restEndpointPrefix`
- `socketEndpointPrefix`

## Continuous Integration

The repository includes GitHub Actions workflows that run on `macos-26`:

- **iOS Build**: Selects Xcode 26.6 (with fallback to any Xcode 26.x), downloads the iOS platform, installs XcodeGen, generates `ClashBrawl.xcodeproj` from `project.yml`, and builds it for the iPhone 15 simulator.
- **SwiftLint**: Lints the Swift sources on every push and pull request.
