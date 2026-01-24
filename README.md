# boneIO Black Pins Overlay

Device tree overlays for boneIO Black boards.

## Overlays

| Overlay | Description | Board Version |
|---------|-------------|---------------|
| `BONEIO-BLACK-PINS.dtbo` | Default overlay with **CAN bus** on P9.24/P9.26 | v0.4+ |
| `BONEIO-BLACK-PINS-UART1.dtbo` | UART1 (Modbus) on P9.24/P9.26 | v0.3 |

## Build

```bash
make
```

## Install

```bash
sudo make install
```

## Usage

### Default (CAN bus, v0.4+)

The main overlay `BONEIO-BLACK-PINS.dtbo` is loaded automatically if configured in `/boot/uEnv.txt`.

After boot, configure CAN interface:
```bash
sudo ip link set can0 type can bitrate 125000
sudo ip link set up can0
```

### UART1 variant (Modbus, v0.3)

For v0.3 boards with Modbus on UART1, add to `/boot/uEnv.txt`:
```
uboot_overlay_addr5=/boot/dtbs/<kernel>/overlays/BONEIO-BLACK-PINS-UART1.dtbo
```

This will override DCAN1 and enable UART1 on P9.24/P9.26.