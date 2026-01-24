# Aktualizacja overlay dla istniejących instalacji Debian 13

Ten dokument opisuje jak zaktualizować overlay na urządzeniach, które już mają zainstalowany obraz Debian 13 z boneIO.

## Co się zmieniło?

Od wersji v0.4 płytki boneIO Black, piny **P9.24/P9.26** są używane do **CAN bus** zamiast UART1 (Modbus).

| Wersja płytki | P9.24/P9.26 | Overlay |
|---------------|-------------|---------|
| v0.3 i starsze | UART1 (Modbus) | `BONEIO-BLACK-PINS-UART1.dtbo` |
| v0.4+ | DCAN1 (CAN bus) | `BONEIO-BLACK-PINS.dtbo` (domyślny) |

## Instrukcja aktualizacji

### 1. Pobierz nowe overlay

```bash
cd /tmp
git clone https://github.com/boneIO-eu/black-pins-overlay.git
cd black-pins-overlay
```

### 2. Zbuduj i zainstaluj

```bash
./build_boneio_black_pins.sh
```

### 3. Dla płytek v0.3 (z Modbus na UART1)

Jeśli masz płytkę v0.3, musisz włączyć overlay UART1:

```bash
sudo nano /boot/uEnv.txt
```

Dodaj linię:
```
uboot_overlay_addr5=/boot/dtbs/$(uname -r)/overlays/BONEIO-BLACK-PINS-UART1.dtbo
```

### 4. Restart

```bash
sudo reboot
```

### 5. Weryfikacja

Po restarcie sprawdź czy overlay jest załadowany:

```bash
cat /proc/device-tree/chosen/overlays/
```

#### Dla v0.4+ (CAN bus)

Sprawdź czy interfejs CAN jest dostępny:
```bash
ip link show | grep can
```

Jeśli widzisz `can0`, skonfiguruj go:
```bash
sudo ip link set can0 type can bitrate 125000
sudo ip link set up can0
```

#### Dla v0.3 (UART1/Modbus)

Sprawdź czy UART1 jest dostępny:
```bash
ls -la /dev/ttyO1
```

## Rozwiązywanie problemów

### Brak interfejsu can0

1. Sprawdź czy overlay jest załadowany:
   ```bash
   dmesg | grep -i can
   ```

2. Sprawdź czy moduły CAN są załadowane:
   ```bash
   lsmod | grep can
   ```

3. Jeśli brak, załaduj ręcznie:
   ```bash
   sudo modprobe can
   sudo modprobe can-dev
   sudo modprobe can-raw
   ```

### Konflikt UART1/DCAN1

Piny P9.24/P9.26 mogą być używane tylko przez **jeden** peryferial naraz:
- DCAN1 (CAN bus) - domyślnie w nowym overlay
- UART1 (Modbus) - wymaga dodatkowego overlay `BONEIO-BLACK-PINS-UART1.dtbo`

Nie można używać obu jednocześnie!

## Pytania?

Jeśli masz problemy z aktualizacją, zgłoś issue na GitHub lub skontaktuj się z nami.
