# Makefile - Convenience wrapper for ESP-IDF commands

# Port configuration (override with: make PORT=/dev/ttyUSB1)
PORT ?= /dev/ttyUSB0
BAUD ?= 115200

# Default target
.PHONY: help
help:
	@echo "BYUI eBadge MicroPython - Build Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          - Initialize submodules and configure"
	@echo "  make menuconfig     - Open configuration menu"
	@echo ""
	@echo "Build:"
	@echo "  make build          - Build the firmware"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make fullclean      - Complete clean (including config)"
	@echo ""
	@echo "Flash:"
	@echo "  make erase          - Erase flash memory"
	@echo "  make flash          - Flash firmware to badge"
	@echo "  make monitor        - Open serial monitor"
	@echo "  make flash-monitor  - Flash and open monitor"
	@echo ""
	@echo "Advanced:"
	@echo "  make size           - Show binary sizes"
	@echo "  make bootloader     - Rebuild bootloader only"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-ota     - Deploy to bootloader OTA system"
	@echo ""
	@echo "Configuration:"
	@echo "  PORT=$(PORT)   - Serial port"
	@echo "  BAUD=$(BAUD)   - Monitor baud rate"
	@echo ""

.PHONY: setup
setup:
	@echo "Initializing MicroPython submodule..."
	git submodule update --init --recursive
	@echo "Setting target to ESP32-S3..."
	idf.py set-target esp32s3
	@echo "Setup complete! Run 'make build' to compile."

.PHONY: menuconfig
menuconfig:
	idf.py menuconfig

.PHONY: build
build:
	idf.py build

.PHONY: clean
clean:
	idf.py clean

.PHONY: fullclean
fullclean:
	idf.py fullclean

.PHONY: erase
erase:
	idf.py -p $(PORT) erase-flash

.PHONY: flash
flash:
	idf.py -p $(PORT) -b $(BAUD) flash

.PHONY: monitor
monitor:
	idf.py -p $(PORT) -b $(BAUD) monitor

.PHONY: flash-monitor
flash-monitor:
	idf.py -p $(PORT) -b $(BAUD) flash monitor

.PHONY: size
size:
	idf.py size
	idf.py size-components

.PHONY: bootloader
bootloader:
	idf.py bootloader

.PHONY: app
app:
	idf.py app

.PHONY: partition-table
partition-table:
	idf.py partition-table

.PHONY: deploy-ota
deploy-ota: build
	@echo "Deploying to bootloader OTA system..."
	@if [ -z "$(BOOTLOADER_PATH)" ]; then \
		./deploy_ota.sh; \
	else \
		./deploy_ota.sh $(BOOTLOADER_PATH); \
	fi
