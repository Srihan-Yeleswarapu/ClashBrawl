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

### Option 1: Generate the Xcode project with XcodeGen (recommended)

1. Open a terminal on macOS.
2. Install XcodeGen if you haven't already:
   ```bash
   brew install xcodegen
   ```
3. Navigate to the `ClashBrawl` folder and generate the project:
   ```bash
   cd ClashBrawl
   xcodegen generate
   ```
4. Open the generated `ClashBrawl.xcodeproj` in Xcode 15+.
5. Update `ClashBrawl/Config/OracleConfig.swift` with your Oracle Cloud details (or leave mock mode on).
6. Build and run on a simulator or device.

### Option 2: Manual Xcode project

1. Open Xcode 15+ on macOS.
2. Create a new iOS App project named `ClashBrawl`.
3. Copy all files from `ClashBrawl/ClashBrawl` into the project, preserving the folder structure.
4. Update `ClashBrawl/Config/OracleConfig.swift` with your Oracle Cloud details.
5. Build and run on a simulator or device.

## Oracle Placeholders

Edit `ClashBrawl/Config/OracleConfig.swift`:
- `serverBaseURL`
- `apiKey`
- `region`
- `restEndpointPrefix`
- `socketEndpointPrefix`

## Continuous Integration

The repository includes GitHub Actions workflows that run on macOS:

- **iOS Build**: Installs XcodeGen, generates `ClashBrawl.xcodeproj`, and builds it for the iOS Simulator.
- **SwiftLint**: Lints the Swift sources on every push and pull request.
