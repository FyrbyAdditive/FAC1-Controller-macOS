#!/bin/bash

# Build the Swift executable
echo "Building Swift project..."
swift build -c release

# Create app bundle structure
APP_NAME="FAC1 Controller.app"
BUNDLE_DIR="$APP_NAME/Contents"
MACOS_DIR="$BUNDLE_DIR/MacOS"
RESOURCES_DIR="$BUNDLE_DIR/Resources"

echo "Creating app bundle..."
rm -rf "$APP_NAME"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp .build/release/FAC1-Controller "$MACOS_DIR/"

# Copy Info.plist
cp Info.plist "$BUNDLE_DIR/"

# Copy icon if it exists
if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns "$RESOURCES_DIR/"
fi

echo "App bundle created: $APP_NAME"

# Check if signing identity is provided
if [ ! -z "$1" ]; then
    echo "Signing app with identity: $1"
    codesign --deep --force --options runtime --sign "$1" "$APP_NAME"
    
    if [ $? -eq 0 ]; then
        echo "✓ App signed successfully"
        
        # Create DMG for notarization
        echo "Creating DMG..."
        hdiutil create -volname "FAC1 Controller" -srcfolder "$APP_NAME" -ov -format UDZO "FAC1-Controller.dmg"
        
        echo ""
        echo "To notarize, run:"
        echo "  xcrun notarytool submit FAC1-Controller.dmg --apple-id YOUR_EMAIL --team-id YOUR_TEAM_ID --password YOUR_APP_SPECIFIC_PASSWORD --wait"
        echo ""
        echo "After notarization completes, staple it:"
        echo "  xcrun stapler staple \"$APP_NAME\""
    else
        echo "✗ Signing failed"
    fi
else
    echo ""
    echo "App created but not signed."
    echo "To sign and notarize, run:"
    echo "  ./build-app.sh \"Developer ID Application: Your Name (TEAM_ID)\""
fi
