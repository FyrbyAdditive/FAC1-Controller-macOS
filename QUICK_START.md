# Quick Start Guide

## Running the Application

### Development Mode

To run the application directly:

```bash
cd "/Users/tim/VSCode/FAC1 - macOS Controller"
swift run FAC1-Controller
```

### Release Build

For better performance, build in release mode:

```bash
cd "/Users/tim/VSCode/FAC1 - macOS Controller"
swift build -c release

# Run the release build
.build/release/FAC1-Controller
```

### Creating a Standalone App

To create a proper macOS .app bundle, you can use Xcode:

1. Generate an Xcode project:
```bash
swift package generate-xcodeproj
```

2. Open the generated `FAC1-Controller.xcodeproj` in Xcode
3. Select the target and build (⌘B)
4. Archive the app (Product → Archive)

## Hardware Setup

1. **Connect Servos**:
   - Pan servo: Connect to servo controller with ID 1
   - Tilt servo: Connect to servo controller with ID 2
   - Provide appropriate power supply (typically 6-12V depending on servo model)

2. **Connect USB-Serial Adapter**:
   - Connect TX/RX lines to servo data line
   - Connect ground
   - Plug USB into your Mac

3. **Verify Connection**:
   - Check available ports: `ls /dev/cu.*`
   - You should see something like `/dev/cu.usbserial-*` or `/dev/cu.usbmodem*`

## First Run

1. Start the application
2. The app will automatically search for USB-serial devices
3. If connected successfully, the status will show "Connected to /dev/cu.xxxxx"
4. Use the arrow buttons to control the servos

## Customizing Settings

Edit `ServoController.swift` to adjust:

- **Movement step size** (line ~23): Change `positionStep` value
- **Speed** (line ~26): Change `movingSpeed` value  
- **Acceleration** (line ~27): Change `movingAcc` value
- **Position limits** (lines ~24-25): Change `minPosition` and `maxPosition`

After making changes, rebuild:
```bash
swift build
```

## Keyboard Shortcuts

While the app doesn't have built-in keyboard shortcuts, you can:
- Tab through buttons
- Press Space to activate the focused button
- Use the checkbox and text fields normally

## Troubleshooting Commands

Check for USB devices:
```bash
ls /dev/cu.usb*
```

Test servo connectivity with the SDK ping example:
```bash
# Clone the SDK separately to test
git clone https://github.com/FyrbyAdditive/feetech-servo-sdk-swift.git
cd feetech-servo-sdk-swift
swift run PingExample
```

View application logs:
```bash
# Run with output visible
swift run FAC1-Controller 2>&1 | tee app.log
```
