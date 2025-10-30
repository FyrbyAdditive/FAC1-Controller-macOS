# FAC1 - Pan & Tilt Controller

A minimal macOS application for controlling pan and tilt servos for the [FAC1 Camera](https://www.printables.com/model/1463101-fac1-fyrby-additive-camera-1/).

![alt text](https://github.com/FyrbyAdditive/FAC1-Controller-macOS/raw/refs/heads/main/Media/FAC1-Camera.png "FAC1 Camera")

## Features

This controller is built using a native, no-nonsense, minimal Swift application, for which you can find the source code in this repository.

- **Automatic USB-Serial Detection**: Automatically finds and connects to USB-serial devices
- **Dual Servo Control**: Controls pan and tilt servos (hardcoded IDs: pan=6, tilt=4)
- **Connection Status**: Detailed status reporting for USB and individual servo connections
- **Calibration**: Calibrate the center point of the servos and toggle axis inversion to your liking
- **Always on Top**: Optional window mode to keep the controller always visible
- **Minimal Interface**: Simple arrow button controls (↑ ↓ o ← →)

![alt text](https://github.com/FyrbyAdditive/FAC1-Controller-macOS/raw/refs/heads/main/Media/FAC1-Controller-Banner.png "FAC1 Camera Controller")

## Requirements

- macOS 14.0 or later in theory
- [FAC1 Camera](https://www.printables.com/model/1463101-fac1-fyrby-additive-camera-1/)

## Building

1. Clone or download this project
2. Open Terminal and navigate to the project directory
3. Build the application:

```bash
swift build -c release
```

4. Run the application:

```bash
swift run
```

Or build and run in development mode:

```bash
swift run FAC1-Controller
```

## Usage

### First Launch

1. Connect your USB-to-serial adapter
2. Power on your servos
3. Launch the application
4. The app will automatically search for and connect to available USB-serial ports

### Controls

- **↑** (Up Arrow): Tilt up
- **↓** (Down Arrow): Tilt down
- **O** (Circular Button): Center Camera
- **←** (Left Arrow): Pan left
- **→** (Right Arrow): Pan right

### Configuration

- **Pan Servo ID**: Hardcoded to ID 6
- **Tilt Servo ID**: Hardcoded to ID 4
- **Always on Top**: Check to keep the window always visible above other applications
- **Reconnect**: Manually reconnect to the USB-serial port

## Servo Configuration

The application uses the following servo settings:

- **Pan Servo ID**: 6 (hardcoded)
- **Tilt Servo ID**: 4 (hardcoded)
- **Baud Rate**: 1,000,000
- **Protocol**: STS series (STS3250)
- **Movement Step**: 100 units per button press
- **Speed**: 200
- **Acceleration**: 50
- **Position Range**: 0 - 4095 (full 360°)

Servo IDs can be changed in `ServoController.swift` if needed.

## Troubleshooting

### Application doesn't connect

1. Check that servos are powered on
2. Verify USB-serial adapter is connected
3. Make sure servo IDs match the configured values
4. Click "Reconnect" to retry connection

### Servos don't respond

1. Verify servo IDs are correct
2. Check power supply to servos
3. Ensure baud rate matches your servo configuration (default: 1,000,000)
4. Try running the Feetech SDK ping example to test basic connectivity
5. Note that the servos will ship with the same ID. You will need to program the IDs.

### Permission denied errors

On macOS, you may need to grant permission to access the serial port:

```bash
# List available ports
ls /dev/cu.*

# The app will try to use cu.usbserial* or cu.usbmodem* devices
```

## Credits
This project uses the [Feetech Servo SDK](https://github.com/FyrbyAdditive/feetech-servo-sdk-swift) for Swift.

_Copyright 2025, Timothy Ellis, Fyrby Additive Manufacturing & Engineering_ 