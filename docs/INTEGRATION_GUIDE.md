# MicroPython Integration Guide

## Overview

There are two approaches to integrate MicroPython with the BYUI eBadge:

### Approach 1: Use MicroPython's Official ESP32 Port (Recommended)

This is the simpler approach and uses MicroPython's official ESP32-S3 port with custom board definitions.

### Approach 2: ESP-IDF Component Integration (Advanced)

Integrate MicroPython as an ESP-IDF component within this project (more complex, better for deep integration).

---

## Approach 1: Official ESP32 Port (RECOMMENDED)

This approach uses MicroPython's built-in ESP32 port with a custom board definition for the BYUI eBadge.

### Step 1: Clone MicroPython

```bash
cd ~
git clone https://github.com/micropython/micropython.git
cd micropython
git submodule update --init
```

### Step 2: Create Custom Board Definition

Create a board definition for the BYUI eBadge:

```bash
cd ports/esp32/boards
mkdir BYUI_EBADGE_V3
```

Create `BYUI_EBADGE_V3/mpconfigboard.cmake`:

```cmake
set(IDF_TARGET esp32s3)

set(SDKCONFIG_DEFAULTS
    boards/sdkconfig.base
    ${SDKCONFIG_IDF_VERSION_SPECIFIC}
    boards/sdkconfig.ble
    boards/sdkconfig.spiram_sx
    boards/BYUI_EBADGE_V3/sdkconfig.board
)
```

Create `BYUI_EBADGE_V3/mpconfigboard.h`:

```c
// BYUI eBadge V3.0 MicroPython Board Configuration

#define MICROPY_HW_BOARD_NAME               "BYUI eBadge V3.0"
#define MICROPY_HW_MCU_NAME                 "ESP32-S3"

// Enable SPIRAM
#define CONFIG_SPIRAM_USE_MALLOC            1

// I2C
#define MICROPY_HW_I2C0_SCL                 (21)
#define MICROPY_HW_I2C0_SDA                 (47)

// SPI (for display and SD card)
#define MICROPY_HW_SPI1_SCK                 (12)
#define MICROPY_HW_SPI1_MOSI                (11)
#define MICROPY_HW_SPI1_MISO                (10)
```

Create `BYUI_EBADGE_V3/sdkconfig.board`:

```
CONFIG_ESPTOOLPY_FLASHMODE_QIO=y
CONFIG_ESPTOOLPY_FLASHFREQ_80M=y
CONFIG_ESPTOOLPY_AFTER_NORESET=y

CONFIG_ESPTOOLPY_FLASHSIZE_4MB=y
CONFIG_PARTITION_TABLE_CUSTOM=y
CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions-4MiB.csv"

CONFIG_LWIP_LOCAL_HOSTNAME="byui-ebadge"

# SPIRAM config
CONFIG_SPIRAM=y
CONFIG_SPIRAM_MODE_OCT=y
CONFIG_SPIRAM_SPEED_80M=y
```

### Step 3: Build MicroPython for BYUI eBadge

```bash
cd ~/micropython/ports/esp32

# Build mpy-cross (needed for freezing Python modules)
make -C ../../mpy-cross

# Build for BYUI eBadge
make BOARD=BYUI_EBADGE_V3 submodules
make BOARD=BYUI_EBADGE_V3
```

### Step 4: Flash to Badge

```bash
make BOARD=BYUI_EBADGE_V3 PORT=/dev/ttyUSB0 erase
make BOARD=BYUI_EBADGE_V3 PORT=/dev/ttyUSB0 deploy
```

### Step 5: Access REPL

```bash
# Using screen
screen /dev/ttyUSB0 115200

# Or using ESP-IDF monitor
idf.py -p /dev/ttyUSB0 monitor

# Or using picocom
picocom /dev/ttyUSB0 -b 115200
```

---

## Approach 2: ESP-IDF Component Integration

This approach integrates MicroPython directly into an ESP-IDF project as a component.

### Prerequisites

This requires modifying MicroPython's build system to work as an ESP-IDF component. The current project structure (`main/main.c`, `main/micropython_task.c`) is set up for this approach.

### Integration Steps

1. **Add MicroPython as ESP-IDF Component**

Create `components/micropython/CMakeLists.txt`:

```cmake
# This would require significant MicroPython build system modifications
# See micropython/ports/esp32 for reference
```

2. **Note**: This approach is complex and requires:
   - Modifying MicroPython's build files
   - Handling library dependencies manually
   - Managing Python module compilation
   - Ensuring compatibility with ESP-IDF build system

**Recommendation**: Use Approach 1 (official ESP32 port) unless you need deep ESP-IDF integration.

---

## Adding Custom Modules

### Freezing Python Modules

To include Python modules in the firmware (so they're always available):

1. Create `BYUI_EBADGE_V3/modules/` directory
2. Add your Python files (e.g., `badge.py`)
3. Rebuild - they'll be frozen into the firmware

Example `BYUI_EBADGE_V3/modules/badge.py`:

```python
# Badge hardware definitions
LED_RED = 6
LED_GREEN = 5
LED_BLUE = 4
# ... etc
```

### Adding C Modules

For hardware-specific drivers (display, etc.):

1. Create module in `BYUI_EBADGE_V3/modules/`
2. Write C code using MicroPython C API
3. Register module in `mpconfigboard.h`

Example structure:

```
BYUI_EBADGE_V3/
├── mpconfigboard.h
├── mpconfigboard.cmake
├── sdkconfig.board
├── modules/
│   ├── badge.py          # Frozen Python module
│   └── ili9341/          # C extension module
│       ├── ili9341.c
│       └── ili9341.h
└── partitions.csv
```

---

## Current Project Status

This repository (`namebadge_micropython`) is structured for **Approach 2** (ESP-IDF integration), but **Approach 1** is simpler and recommended for most users.

### Quick Start (Recommended Path)

1. Use official MicroPython ESP32 port
2. Create custom board definition (as shown above)
3. Build and flash
4. Upload badge-specific Python modules via `ampy` or freeze them

### If You Want Deep Integration

The current project structure in this repo provides a framework for Approach 2, but you'll need to:

1. Properly integrate MicroPython's build system as an ESP-IDF component
2. Handle all dependencies and library linkage
3. Configure Python module compilation

This is significantly more complex and is recommended only if you need features like:
- Custom OTA update system
- Deep integration with other ESP-IDF components
- Extensive C-level hardware driver development

---

## Recommended Next Steps

1. **Try Approach 1 first** - It's battle-tested and supported
2. **Create board definition** for BYUI eBadge with pin mappings
3. **Freeze badge.py** module with hardware definitions
4. **Build display driver** as C extension if needed
5. **Test all peripherals** through MicroPython REPL

## Resources

- [MicroPython ESP32 Port](https://github.com/micropython/micropython/tree/master/ports/esp32)
- [Custom Board Guide](https://github.com/micropython/micropython/blob/master/ports/esp32/boards/GENERIC/README.md)
- [MicroPython C Modules](https://docs.micropython.org/en/latest/develop/cmodules.html)
- [ESP-IDF Integration](https://docs.espressif.com/projects/esp-idf/en/latest/)
