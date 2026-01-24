DTC ?= dtc
CPP ?= cpp

# DTC flags for overlay compilation
DTC_FLAGS = -@ -O dtb -b 0

# Preprocessor flags
dtc_cpp_flags = -nostdinc -I. -undef -D__DTS__

# All overlays to build
OVERLAYS = BONEIO-BLACK-PINS.dtbo BONEIO-BLACK-PINS-UART1.dtbo

# Default target
all: $(OVERLAYS)

# Build overlay from .dtso source
%.dtbo: %.dtso
	@echo "DTCO    $@"
	$(CPP) $(dtc_cpp_flags) -x assembler-with-cpp -o $@.tmp $< ; \
	$(DTC) $(DTC_FLAGS) -o $@ $@.tmp ; \
	rm -f $@.tmp

# Clean build artifacts
clean:
	rm -f *.dtbo *.tmp

# Install overlays
install: $(OVERLAYS)
	@echo "Installing boneIO Black overlays..."
	KERNEL_VERSION=$(shell uname -r); \
	if ! id | grep -q root; then \
		echo "Install: Password required for sudo..."; \
		sudo mkdir -p /boot/dtbs/$$KERNEL_VERSION/overlays/; \
		sudo cp $(OVERLAYS) /boot/dtbs/$$KERNEL_VERSION/overlays/; \
	else \
		mkdir -p /boot/dtbs/$$KERNEL_VERSION/overlays/; \
		cp $(OVERLAYS) /boot/dtbs/$$KERNEL_VERSION/overlays/; \
	fi
	@echo ""
	@echo "Installed overlays:"
	@echo "  - BONEIO-BLACK-PINS.dtbo      (default, with CAN bus on P9.24/P9.26)"
	@echo "  - BONEIO-BLACK-PINS-UART1.dtbo (for v0.3 boards with Modbus on UART1)"
	@echo ""
	@echo "To use UART1 variant, add to /boot/uEnv.txt:"
	@echo "  uboot_overlay_addr5=/boot/dtbs/$$KERNEL_VERSION/overlays/BONEIO-BLACK-PINS-UART1.dtbo"

.PHONY: all clean install
