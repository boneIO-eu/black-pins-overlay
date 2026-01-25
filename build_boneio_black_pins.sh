#!/bin/bash

# Script to build and install boneIO Black overlays for BeagleBone Black
# 
# Overlays:
#   - BONEIO-BLACK-PINS.dtbo      (default, CAN bus on P9.24/P9.26 for v0.4+)
#   - BONEIO-BLACK-PINS-UART1.dtbo (UART1/Modbus on P9.24/P9.26 for v0.3)

OVERLAYS=(
    "BONEIO-BLACK-PINS"
    "BONEIO-BLACK-PINS-UART1"
)

echo "Building boneIO Black overlays for BeagleBone Black..."

# Check if overlay files exist
for overlay in "${OVERLAYS[@]}"; do
    if [ ! -f "${overlay}.dtso" ]; then
        echo "Error: Overlay file ${overlay}.dtso not found!"
        exit 1
    fi
done

# Clean any existing build artifacts
for overlay in "${OVERLAYS[@]}"; do
    if [ -f "${overlay}.dtbo" ]; then
        rm -f "${overlay}.dtbo"
    fi
done
echo "Cleaned existing overlay binaries"

# Build all overlays
make all

if [ $? -eq 0 ]; then
    echo "All overlays: Built successfully"
else
    echo "Error: Failed to build overlays"
    exit 1
fi

# Install overlays for BeagleBone Black (ARM)
echo "Installing boneIO Black overlays..."
KERNEL_VERSION=$(uname -r)

install_overlays() {
    local dest="/boot/dtbs/$KERNEL_VERSION/overlays/"
    mkdir -p "$dest"
    for overlay in "${OVERLAYS[@]}"; do
        cp "${overlay}.dtbo" "$dest"
    done
}

if ! id | grep -q root; then
    echo "Install: Password required for sudo..."
    sudo bash -c "$(declare -f install_overlays); $(declare -p OVERLAYS); KERNEL_VERSION=$KERNEL_VERSION install_overlays"
else
    install_overlays
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "Installed overlays:"
    echo "  - BONEIO-BLACK-PINS.dtbo      (default, CAN bus on P9.24/P9.26)"
    echo "  - BONEIO-BLACK-PINS-UART1.dtbo (for v0.3 boards with Modbus on UART1)"
    echo ""
    echo "For v0.3 boards, add to /boot/uEnv.txt:"
    echo "  uboot_overlay_addr5=/boot/dtbs/$KERNEL_VERSION/overlays/BONEIO-BLACK-PINS-UART1.dtbo"
else
    echo "Error: Failed to install overlays"
    exit 1
fi

echo ""
echo "boneIO Black overlay build and install completed!"
