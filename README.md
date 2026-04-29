# BYUI eBadge V3.0 - MicroPython REPL

An interactive MicroPython environment for the BYUI eBadge V3.0, providing full hardware access through a Python REPL interface.

## Features

- **Interactive Python REPL** - Write and test code directly on the badge
- **Full Hardware Access** - Control LEDs, buttons, display, sensors, and more
- **WiFi & Bluetooth** - Network connectivity and wireless communication
- **1MB Python Heap** - Generous memory allocation in PSRAM
- **ESP32-S3 Performance** - Dual-core 240 MHz processor

## Hardware Supported

| Peripheral | Details | MicroPython Access |
|------------|---------|-------------------|
| Display | ILI9341 240×320 TFT | SPI2, Pin definitions in `badge.py` |
| Buttons | 6 tactile buttons (Up/Down/Left/Right/A/B) | GPIO with pull-ups |
| RGB LED | PWM-controlled LED | `machine.PWM` |
| Addressable LEDs | WS2813B strip | RMT driver |
| Accelerometer | MMA8452Q I2C | I2C bus 0 |
| Joystick | 2-axis analog | ADC channels |
| Buzzer | Piezo speaker | PWM tones |
| SD Card | MicroSD slot | SPI2 (shared) |
| WiFi | 2.4GHz 802.11n | `network` module |
| Bluetooth | BLE 5.0 | `bluetooth` module |

## Quick Start

### 1. Prerequisites

- ESP-IDF v5.3.1
- Python 3.11+
- Git

### 2. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/watsonlr/namebadge_micropython.git
cd namebadge_micropython

# Initialize MicroPython submodule
git submodule update --init --recursive

# Source ESP-IDF (adjust path as needed)
. $HOME/esp/esp-idf/export.sh
```

### 3. Build and Flash

```bash
# Configure target
idf.py set-target esp32s3

# Build firmware
idf.py build

# Flash to badge
idf.py -p /dev/ttyUSB0 flash monitor
```

On Windows, use `COM3` instead of `/dev/ttyUSB0`.

## Deploy as OTA App

To make MicroPython REPL available as a selectable app from the bootloader:

```bash
# Build the app
idf.py build

# Deploy to bootloader OTA directory
./deploy_ota.sh /path/to/namebadge_bootloader

# Start OTA server (from bootloader repo)
cd /path/to/namebadge_bootloader/ota_files
python3 -m http.server 8000
```

Then from the badge app selector:
1. Connect to WiFi
2. Browse apps → Select "MicroPython REPL"
3. Download and install
4. Boot into Python REPL

To return to the app menu from MicroPython:
```python
>>> from badge import return_to_menu
>>> return_to_menu()
```

See **[OTA_INTEGRATION.md](docs/OTA_INTEGRATION.md)** for complete details.

## Using the REPL

Connect to the serial port at 115200 baud. You'll see the MicroPython prompt:

```python
>>> print("Hello, Badge!")
Hello, Badge!

>>> from badge import *
BYUI eBadge V3.0 hardware definitions loaded

>>> from machine import Pin
>>> led = Pin(LED_RED, Pin.OUT)
>>> led.on()
```

### Example: Blink LED

```python
from machine import Pin
from badge import LED_GREEN
import time

led = Pin(LED_GREEN, Pin.OUT)
while True:
    led.toggle()
    time.sleep(0.5)
```

### Example: Read Button

```python
from machine import Pin
from badge import BUTTON_A

btn = Pin(BUTTON_A, Pin.IN, Pin.PULL_UP)
while True:
    if not btn.value():  # Active LOW
        print("Button A pressed!")
    time.sleep(0.1)
```

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[OTA_INTEGRATION.md](docs/OTA_INTEGRATION.md)** - Deploy as bootloader app
- **[MICROPYTHON_SETUP.md](docs/MICROPYTHON_SETUP.md)** - Complete setup guide
- **[EXAMPLES.md](docs/EXAMPLES.md)** - Code examples and projects
- **[HARDWARE.md](docs/HARDWARE.md)** - Hardware specifications and pinout
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System architecture
- **[BUILD_GUIDE.md](docs/BUILD_GUIDE.md)** - Build instructions

## Badge Pin Reference

Quick reference (import from `badge.py`):

```python
# LEDs
LED_RED = 6
LED_GREEN = 5
LED_BLUE = 4
LED_STRIP = 7

# Buttons (Active LOW)
BUTTON_UP = 17
BUTTON_DOWN = 16
BUTTON_LEFT = 14
BUTTON_RIGHT = 15
BUTTON_A = 38
BUTTON_B = 18

# Display (SPI2)
DISPLAY_CS = 9
DISPLAY_DC = 13
DISPLAY_RST = 48

# I2C (Accelerometer)
I2C_SDA = 47
I2C_SCL = 21

# Other
BUZZER = 42
JOYSTICK_X = 1
JOYSTICK_Y = 2
```

## Advanced Usage

### WiFi Connection

```python
import network

wlan = network.WLAN(network.STA_IF)
wlan.active(True)
wlan.connect('YourSSID', 'YourPassword')

while not wlan.isconnected():
    pass

print('IP:', wlan.ifconfig()[0])
```

### File Upload (ampy)

```bash
# Install ampy
pip install adafruit-ampy

# Upload a script
ampy --port /dev/ttyUSB0 put myapp.py

# List files
ampy --port /dev/ttyUSB0 ls

# Run a script
ampy --port /dev/ttyUSB0 run myapp.py
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No REPL prompt | Press Ctrl+C to interrupt, Ctrl+D to soft reset |
| Import errors | Module may not be compiled in (check `sdkconfig`) |
| Out of memory | Run `gc.collect()` to free memory |
| Device not detected | Use a data USB cable (not charge-only) |

## Project Structure

```
namebadge_micropython/
├── CMakeLists.txt              # Main build configuration
├── sdkconfig.defaults          # Default ESP-IDF settings
├── partitions.csv              # Flash partition table
├── main/
│   ├── main.c                  # Entry point
│   ├── micropython_task.c      # MicroPython REPL task
│   ├── mpconfigboard.h         # Board configuration
│   └── badge.py                # Hardware pin definitions
├── docs/                       # Documentation
└── micropython/                # MicroPython submodule (git)
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project follows the MicroPython license (MIT). See the MicroPython repository for details.

## Resources

- [MicroPython Documentation](https://docs.micropython.org/)
- [ESP32 MicroPython Guide](https://docs.micropython.org/en/latest/esp32/quickref.html)
- [ESP-IDF Documentation](https://docs.espressif.com/projects/esp-idf/en/v5.3.1/)
- [BYUI eBadge Hardware Specs](docs/HARDWARE.md)

---

**BYUI eBadge V3.0** | ESP32-S3 | MicroPython REPL | 2026


This is to create a micropython app to be downloaded via the namebadge bootloader
