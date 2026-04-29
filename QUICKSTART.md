# Quick Start - Get MicroPython REPL Running in 5 Minutes

This guide gets you to a working MicroPython REPL on the BYUI eBadge V3.0 as quickly as possible.

## Prerequisites

- BYUI eBadge V3.0 hardware
- USB cable (data capable, not charge-only)
- Linux/WSL or macOS (Windows instructions provided where different)

## Option A: Use Pre-built MicroPython (Recommended)

If pre-built firmware is available, simply flash it:

```bash
# Download firmware
wget https://github.com/watsonlr/namebadge_micropython/releases/download/v1.0/firmware.bin

# Install esptool
pip install esptool

# Erase flash
esptool.py --port /dev/ttyUSB0 erase_flash

# Flash firmware
esptool.py --port /dev/ttyUSB0 --chip esp32s3 write_flash 0x0 firmware.bin

# Connect to REPL
screen /dev/ttyUSB0 115200
```

Press Ctrl+A, then K to exit screen.

## Option B: Build from Source (Official MicroPython)

### 1. Install ESP-IDF

```bash
# Install prerequisites
sudo apt-get install git wget flex bison gperf python3 python3-pip \
    python3-venv cmake ninja-build ccache libffi-dev libssl-dev \
    dfu-util libusb-1.0-0

# Clone ESP-IDF v5.3.1
mkdir -p ~/esp
cd ~/esp
git clone -b v5.3.1 --recursive https://github.com/espressif/esp-idf.git

# Install ESP-IDF
cd esp-idf
./install.sh esp32s3

# Source environment (add to ~/.bashrc for persistence)
. ~/esp/esp-idf/export.sh
```

### 2. Clone and Build MicroPython

```bash
# Clone MicroPython
cd ~
git clone https://github.com/micropython/micropython.git
cd micropython

# Get submodules
make -C ports/esp32 submodules

# Build mpy-cross compiler
make -C mpy-cross

# Build for ESP32-S3 (generic board)
cd ports/esp32
make BOARD=GENERIC_S3
```

### 3. Flash

```bash
# Erase flash
make BOARD=GENERIC_S3 PORT=/dev/ttyUSB0 erase

# Deploy (flash all components)
make BOARD=GENERIC_S3 PORT=/dev/ttyUSB0 deploy
```

**Windows**: Replace `/dev/ttyUSB0` with `COM3` (or your port).

### 4. Access REPL

```bash
# Using screen (Linux/macOS)
screen /dev/ttyUSB0 115200

# Using PuTTY (Windows)
# Set Serial, COM3, 115200, 8N1

# Using ESP-IDF monitor
idf.py -p /dev/ttyUSB0 monitor
```

You should see:

```
MicroPython v1.24.0 on 2026-04-28; Generic ESP32S3 module with ESP32S3
Type "help()" for more information.
>>> 
```

## First Steps in REPL

### Hello World

```python
>>> print("Hello from BYUI eBadge!")
Hello from BYUI eBadge!
```

### Hardware Test - Blink LED

```python
>>> from machine import Pin
>>> import time
>>> led = Pin(6, Pin.OUT)  # Red LED on GPIO6
>>> for i in range(10):
...     led.toggle()
...     time.sleep(0.5)
...
```

### Read Button

```python
>>> btn = Pin(38, Pin.IN, Pin.PULL_UP)  # Button A
>>> while True:
...     if not btn.value():
...         print("Pressed!")
...     time.sleep(0.1)
...
```

Press Ctrl+C to interrupt.

### WiFi Test

```python
>>> import network
>>> wlan = network.WLAN(network.STA_IF)
>>> wlan.active(True)
>>> wlan.scan()  # Scan for networks
[(b'YourNetwork', b'\x...', 1, -50, 4, False), ...]

>>> wlan.connect('YourSSID', 'YourPassword')
>>> wlan.ifconfig()
('192.168.1.100', '255.255.255.0', '192.168.1.1', '8.8.8.8')
```

### System Info

```python
>>> import esp32
>>> esp32.raw_temperature()  # Internal temp (Fahrenheit)
>>> import machine
>>> machine.freq()  # CPU frequency
240000000

>>> import gc
>>> gc.mem_free()  # Free memory
4194304
```

## Uploading Python Files

### Using ampy

```bash
# Install ampy
pip install adafruit-ampy

# Create a test file
cat > test.py << 'EOF'
from machine import Pin
import time

led = Pin(6, Pin.OUT)
for i in range(5):
    led.toggle()
    time.sleep(0.5)
print("Done!")
EOF

# Upload file
ampy --port /dev/ttyUSB0 put test.py

# List files
ampy --port /dev/ttyUSB0 ls

# Run the file
ampy --port /dev/ttyUSB0 run test.py
```

### Using REPL paste mode

1. Enter REPL
2. Press Ctrl+E (paste mode)
3. Paste your code
4. Press Ctrl+D to execute

## Auto-run on Boot

Create `boot.py` or `main.py` that will run automatically:

```python
# Create boot.py via REPL
>>> f = open('boot.py', 'w')
>>> f.write('print("BYUI eBadge Starting...")\n')
>>> f.write('from machine import Pin\n')
>>> f.write('led = Pin(6, Pin.OUT)\n')
>>> f.write('led.on()\n')
>>> f.close()

# Soft reset to test
>>> import machine
>>> machine.soft_reset()
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No REPL prompt | Press Ctrl+C to interrupt, then Ctrl+D to reset |
| "Device not found" | Check USB cable is data-capable, try different port |
| Import errors | Module not available, check with `help('modules')` |
| Flash verification failed | Lower baud: `--baud 115200` when flashing |

## Next Steps

1. ✓ REPL working
2. Check out [EXAMPLES.md](EXAMPLES.md) for code samples
3. Upload badge-specific modules (see [badge.py](../main/badge.py))
4. Build custom display/sensor drivers
5. Create full applications

## Badge-Specific Pin Reference

Save this as `badge.py` and upload to the badge:

```python
# Hardware pins for BYUI eBadge V3.0
LED_RED, LED_GREEN, LED_BLUE = 6, 5, 4
LED_STRIP = 7
BUTTON_A, BUTTON_B = 38, 18
BUTTON_UP, BUTTON_DOWN = 17, 16
BUTTON_LEFT, BUTTON_RIGHT = 14, 15
DISPLAY_CS, DISPLAY_DC, DISPLAY_RST = 9, 13, 48
I2C_SDA, I2C_SCL = 47, 21
BUZZER = 42
```

Then in REPL:

```python
>>> from badge import *
>>> from machine import Pin
>>> led = Pin(LED_RED, Pin.OUT)
>>> led.on()
```

---

**You now have a working MicroPython REPL on your BYUI eBadge!** 🎉

For more advanced usage, see the full documentation in [MICROPYTHON_SETUP.md](MICROPYTHON_SETUP.md).
