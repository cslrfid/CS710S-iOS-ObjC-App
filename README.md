# CS710S-iOS-ObjC-App

Library and demo app for Convergence Systems Limited CS710S UHF RFID handheld reader written in Objective-C.

## Current Version

**Version:** 2.0 (Build 717)
**Last Updated:** November 2025

## Overview

The CS710S RFID Demo App is a comprehensive iOS application demonstrating the capabilities of the CSL CS710S UHF RFID handheld reader. The app provides a full-featured interface for RFID tag inventory, reading, writing, and advanced tag operations through Bluetooth Low Energy (BLE) communication.

## Development Environment

- **Xcode:** 14 or later
- **iOS Target:** 13.0+
- **Language:** Objective-C
- **Architecture:** MVC with Singleton pattern
- **Device Optimization:** iPhone 8 (4.7"), functional on all screen sizes

## Dependencies

### CSL-CS710S CocoaPod (v1.11.0)

[CSL-CS710S GitHub Repository](https://github.com/cslrfid/CSL-CS710S)

**Important:** This CocoaPod is currently unpublished. To use it:

1. Clone the repository to the default location on your Mac:
   ```bash
   git clone https://github.com/cslrfid/CSL-CS710S.git ~/Documents/GitHub/CSL-CS710S/
   ```

2. Alternatively, clone to a custom location and update the `Podfile` path:
   ```ruby
   pod 'CSL-CS710S', :path => '/your/custom/path/CSL-CS710S/'
   ```

3. Install dependencies:
   ```bash
   cd CS710S-iOS-ObjC-App
   pod install
   ```

4. Open the workspace (not the project):
   ```bash
   open CS710iOSClient.xcworkspace
   ```

## Key Features

### RFID Operations
- **Inventory Management:** Real-time tag scanning with configurable parameters
- **Tag Reading:** Read EPC, TID, and user memory banks
- **Tag Writing:** Write to EPC and user memory
- **Tag Access Control:** Lock/unlock, kill tags, change access passwords
- **Tag Search:** Locate specific tags with visual and audio feedback
- **Multibank Access:** Simultaneous read from multiple memory banks

### Advanced Features
- **Impinj Authentication:** Secure tag authentication using Impinj Monza cryptographic features
- **Temperature Sensing:** Read temperature data from temperature-sensing tags
- **Filters:** Pre-filter and post-filter configuration for selective tag reading
- **Power Control:** Adjustable RF power levels (0-30 dBm)
- **Antenna Configuration:** Control individual antenna ports

### Reader Management
- **BLE Device Discovery:** Automatic scanning and connection to CS710S readers
- **Reader Configuration:** Frequency, power, session, target settings
- **Battery Monitoring:** Real-time battery level display
- **Firmware Information:** View reader model, firmware version, and serial number

## Project Structure

```
CS710S-iOS-ObjC-App/
├── CS710iOSClient/
│   ├── ViewControllers/          # All view controllers
│   │   ├── CSLHomeVC              # Main home screen
│   │   ├── CSLInventoryVC         # Tag inventory
│   │   ├── CSLSettingsVC          # Reader settings
│   │   ├── CSLTagAccessVC         # Tag read/write operations
│   │   ├── CSLMultibankAccessVC   # Multibank operations
│   │   ├── CSLImpinjAuthenticationVC  # Impinj auth
│   │   └── ...
│   ├── Assets.xcassets/           # Images and icons
│   ├── CSLRfidDemoApp.storyboard  # Main UI storyboard
│   └── Info.plist                 # App configuration
├── Pods/                          # CocoaPods dependencies
│   └── CSL-CS710S/               # RFID reader framework
├── Podfile                        # Dependency configuration
└── README.md                      # This file
```

## Core Architecture

### Singleton Pattern
The app uses `CSLRfidAppEngine` as a singleton to manage:
- Reader instance and connection state
- Settings persistence (NSUserDefaults)
- Tag data buffers and filtering
- Reader configuration and information

### Delegate Pattern
View controllers implement `CSLBleReaderDelegate` to receive:
- Tag response packets
- Trigger key state changes
- Battery level updates
- Barcode scan data

### Navigation
- Tab-based navigation for RFID operations (Inventory, Settings, Tag Access, Tag Search)
- Storyboard-based UI with programmatic navigation for complex flows

## Building the Project

### Prerequisites
1. Install CocoaPods if not already installed:
   ```bash
   sudo gem install cocoapods
   ```

2. Clone the CSL-CS710S pod repository (see Dependencies section)

### Build Steps
1. Clone this repository:
   ```bash
   git clone https://github.com/cslrfid/CS710S-iOS-ObjC-App.git
   cd CS710S-iOS-ObjC-App
   ```

2. Install dependencies:
   ```bash
   pod install
   ```

3. Open the workspace:
   ```bash
   open CS710iOSClient.xcworkspace
   ```

4. Select a target device or simulator

5. Build and run (⌘R)

### Known Build Issues

**User Script Sandboxing:**
If you encounter permission errors during build, the project has been configured with `ENABLE_USER_SCRIPT_SANDBOXING=NO` to allow CocoaPods scripts to run properly. This is required for Xcode 14+ with CocoaPods.

**Framework Header Imports:**
The CSL-CS710S framework uses angle-bracketed imports (`<CSL_CS710S/Header.h>`) to comply with framework modulemap requirements. If you modify the pod, maintain this format.

## Recent Changes (v2.0)

### Removed Features
- **MQTT Integration:** All MQTT-related functionality has been removed, including:
  - MQTT settings page
  - Temperature upload to MQTT broker
  - Tag data transmission via MQTT
  - MQTTClient dependency

### UI Improvements
- Reorganized More Functions page layout for better accessibility
- Improved button spacing and alignment in grid layouts

### Bug Fixes
- Fixed framework header import format for proper module compilation
- Resolved build issues with user script sandboxing
- Fixed CocoaPods integration for local pod dependencies

## Configuration

### Reader Settings
Configure reader parameters in the Settings page:
- **Region:** Select regulatory region (FCC, ETSI, etc.)
- **Power Level:** Adjust RF output power (0-30 dBm)
- **Session:** Select Gen2 session (S0, S1, S2, S3)
- **Target:** Choose tag population (A, B, A->B, B->A)
- **Algorithm:** Select inventory algorithm (Dynamic Q, Fixed Q, etc.)
- **Link Profile:** Configure reader-tag communication parameters

### Filters
- **Pre-filter:** Filter tags before inventory based on EPC/TID
- **Post-filter:** Client-side filtering of received tag data

### Tag Access
- **Access Password:** Set for protected tag operations
- **Retry Count:** Configure read/write retry attempts
- **Antenna Selection:** Choose specific antenna ports

## Usage Example

### Basic Inventory Operation
1. Launch the app
2. Tap "Press to Connect" to discover and connect to a CS710S reader
3. Once connected, tap "Inventory" on the home screen
4. Press the reader's trigger button or tap "Start" in the app
5. View real-time tag reads in the table view
6. Tags display: EPC, RSSI, read count, timestamp

### Tag Read/Write
1. From home screen, tap "Tag Access"
2. Enter the target EPC or scan a tag
3. Select operation (Read/Write)
4. Choose memory bank (EPC, TID, User)
5. Set offset and length
6. Execute operation

## Bluetooth Permissions

The app requires Bluetooth permissions configured in `Info.plist`:
- `NSBluetoothAlwaysUsageDescription`
- `NSBluetoothPeripheralUsageDescription`

Users must grant Bluetooth access on first launch.

## Testing

### Tested Configurations
- **Devices:** iPhone 8, iPhone 12, iPhone 14
- **iOS Versions:** iOS 13.0 - iOS 17.5
- **Readers:** CS710S (all firmware versions)

### Simulator Limitations
The iOS Simulator cannot access Bluetooth hardware. Testing requires a physical iOS device and CS710S reader.

## Troubleshooting

### Connection Issues
- Ensure Bluetooth is enabled on the iOS device
- Verify the CS710S reader is powered on
- Check that the reader is not connected to another device
- Try power cycling the reader

### Build Failures
- Clean build folder: Product → Clean Build Folder (⌘⇧K)
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Reinstall pods: `rm -rf Pods/ && pod install`
- Verify CSL-CS710S pod is correctly cloned and accessible

### Runtime Issues
- Check iOS version compatibility (requires iOS 13.0+)
- Verify Bluetooth permissions are granted
- Review Xcode console for error messages
- Ensure reader firmware is up to date

## Contributing

This is a demonstration application. For feature requests or bug reports related to:
- **App issues:** File issues in this repository
- **Reader SDK issues:** File issues in the [CSL-CS710S repository](https://github.com/cslrfid/CSL-CS710S)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Version History

- **v2.0 (Build 717)** - November 2025
  - Removed MQTT functionality
  - Updated to CSL-CS710S v1.11.0
  - UI improvements and bug fixes

- **v1.8.668** - June 2025
  - Updated to CSL-CS710S v1.10.0
  - Connection stability improvements

- **v1.6.640** - March 2025
  - Enhanced device connection handling
  - Updated to CSL-CS710S v1.9.0
