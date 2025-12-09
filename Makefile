DTC ?= dtc
CPP ?= cpp

# DTC flags for overlay compilation
DTC_FLAGS = -@ -O dtb -b 0

# Preprocessor flags
dtc_cpp_flags = -nostdinc -I. -undef -D__DTS__

# Default target
all: BONEIO-BLACK-PINS.dtbo

# Build the overlay
BONEIO-BLACK-PINS.dtbo: BONEIO-BLACK-PINS.dtso
	@echo "DTCO    $@"
	$(CPP) $(dtc_cpp_flags) -x assembler-with-cpp -o $@.tmp $< ; \
	$(DTC) $(DTC_FLAGS) -o $@ $@.tmp ; \
	rm -f $@.tmp

# Clean build artifacts
clean:
	rm -f *.dtbo *.tmp

# Install overlay
install: BONEIO-BLACK-PINS.dtbo
	@echo "Installing BONEIO-BLACK-PINS overlay..."
	KERNEL_VERSION=$(shell uname -r); \
	if ! id | grep -q root; then \
		echo "Install: Password required for sudo..."; \
		sudo mkdir -p /boot/dtbs/$$KERNEL_VERSION/overlays/; \
		sudo cp BONEIO-BLACK-PINS.dtbo /boot/dtbs/$$KERNEL_VERSION/overlays/; \
	else \
		mkdir -p /boot/dtbs/$$KERNEL_VERSION/overlays/; \
		cp BONEIO-BLACK-PINS.dtbo /boot/dtbs/$$KERNEL_VERSION/overlays/; \
	fi

.PHONY: all clean install
