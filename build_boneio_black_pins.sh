#!/bin/bash

# Script to build and install only BONEIO-BLACK-PINS.dtso overlay for BeagleBone Black

OVERLAY_FILE="BONEIO-BLACK-PINS.dtso"
OVERLAY_TARGET="BONEIO-BLACK-PINS.dtbo"

echo "Building BONEIO-BLACK-PINS overlay for BeagleBone Black..."

# Check if the overlay file exists
if [ ! -f "$OVERLAY_FILE" ]; then
    echo "Error: Overlay file $OVERLAY_FILE not found!"
    exit 1
fi

# Clean any existing build artifacts for this overlay
if [ -f "$OVERLAY_TARGET" ]; then
    rm -f "$OVERLAY_TARGET"
    echo "Cleaned existing overlay binary"
fi

# Build the specific overlay
make BONEIO-BLACK-PINS.dtbo

if [ $? -eq 0 ]; then
    echo "BONEIO-BLACK-PINS overlay: Built successfully"
else
    echo "Error: Failed to build BONEIO-BLACK-PINS overlay"
    exit 1
fi

# Install the overlay for BeagleBone Black (ARM)
echo "Installing BONEIO-BLACK-PINS overlay for BeagleBone Black..."
KERNEL_VERSION=$(uname -r)
if ! id | grep -q root; then
    echo "Install: Password required for sudo..."
    sudo mkdir -p /boot/dtbs/$KERNEL_VERSION/overlays/
    sudo cp "$OVERLAY_TARGET" /boot/dtbs/$KERNEL_VERSION/overlays/
else
    mkdir -p /boot/dtbs/$KERNEL_VERSION/overlays/
    cp "$OVERLAY_TARGET" /boot/dtbs/$KERNEL_VERSION/overlays/
fi

if [ $? -eq 0 ]; then
    echo "BONEIO-BLACK-PINS overlay: Installed successfully"
else
    echo "Error: Failed to install BONEIO-BLACK-PINS overlay"
    exit 1
fi

echo "BONEIO-BLACK-PINS overlay build and install completed!"
