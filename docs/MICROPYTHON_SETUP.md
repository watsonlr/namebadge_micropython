# MicroPython REPL Setup Guide

This guide explains how to set up and build the MicroPython REPL application for the BYUI eBadge V3.0.

## Quick Start

### 1. Clone MicroPython Submodule

```bash
# Initialize and fetch the MicroPython source code
git submodule update --init --recursive
```

### 2. Set Up ESP-IDF Environment

Make sure ESP-IDF v5.3.1 is installed and sourced:

```bash
# Linux/WSL
. $HOME/esp/esp-idf/export.sh

# Windows (PowerShell)
. $HOME\esp\esp-idf\export.ps1
```

### 3. Configure and Build

```bash
# Set the target (only needed once)
idf.py set-target esp32s3

# Build the project
idf.py build
```

### 4. Flash to Badge

```bash
# Erase flash (first time only)
idf.py -p /dev/ttyUSB0 erase-flash

# Flash firmware
idf.py -p /dev/ttyUSB0 flash

# Flash and open monitor
idf.py -p /dev/ttyUSB0 flash monitor
```

On Windows, replace `/dev/ttyUSB0` with `COM3` (or your port).

---

## Using the REPL

Once flashed, connect to the serial port at 115200 baud. You'll see:

```
╔═══════════════════════════════════════════════════════════╗
║     BYUI eBadge V3.0 - MicroPython REPL Environment      ║
╚═══════════════════════════════════════════════════════════╝

Hardware: ESP32-S3 (revision v0.2)
Cores: 2
Features: WiFi + BLE
Flash: 4 MB
Free heap: 8421376 bytes

Starting MicroPython REPL...
Type help() for more information.

>>> 
```

### Basic Commands

```python
>>> print("Hello from BYUI eBadge!")
Hello from BYUI eBadge!

>>> import sys
>>> sys.platform
'esp32'

>>> import machine
>>> machine.freq()
240000000

>>> from badge import *
BYUI eBadge V3.0 hardware definitions loaded
Import with: from badge import *
```

### Hardware Examples

#### LED Control

```python
from machine import Pin
from badge import LED_RED, LED_GREEN, LED_BLUE

# Turn on the red LED
led_red = Pin(LED_RED, Pin.OUT)
led_red.on()

# Blink green LED
import time
led_green = Pin(LED_GREEN, Pin.OUT)
while True:
    led_green.toggle()
    time.sleep(0.5)
```

#### Button Input

```python
from machine import Pin
from badge import BUTTON_A, BUTTON_B

btn_a = Pin(BUTTON_A, Pin.IN, Pin.PULL_UP)
btn_b = Pin(BUTTON_B, Pin.IN, Pin.PULL_UP)

while True:
    if not btn_a.value():  # Active LOW
        print("A pressed!")
    if not btn_b.value():
        print("B pressed!")
    time.sleep(0.1)
```

#### I2C Accelerometer

```python
from machine import I2C, Pin
from badge import I2C_SDA, I2C_SCL

# Initialize I2C
i2c = I2C(0, scl=Pin(I2C_SCL), sda=Pin(I2C_SDA), freq=400000)

# Scan for devices
devices = i2c.scan()
print("I2C devices found:", [hex(d) for d in devices])

# MMA8452Q is typically at 0x1C or 0x1D
```

#### Buzzer (PWM)

```python
from machine import Pin, PWM
from badge import BUZZER
import time

# Create PWM on buzzer pin
buzzer = PWM(Pin(BUZZER), freq=1000, duty=512)

# Play a tone for 1 second
time.sleep(1)
buzzer.deinit()
```

#### WiFi Connection

```python
import network

# Connect to WiFi
wlan = network.WLAN(network.STA_IF)
wlan.active(True)
wlan.connect('your-ssid', 'your-password')

# Wait for connection
while not wlan.isconnected():
    pass

print('Connected! IP:', wlan.ifconfig()[0])
```

---

## File System

MicroPython on ESP32 doesn't automatically mount a filesystem. To work with files:

### Option 1: Use REPL to Create Files

```python
# Create a simple script
with open('test.py', 'w') as f:
    f.write('print("Hello from file!")\n')

# Run it
exec(open('test.py').read())
```

### Option 2: Upload via ampy

Install ampy on your PC:

```bash
pip install adafruit-ampy
```

Upload files:

```bash
ampy --port /dev/ttyUSB0 put myfile.py
ampy --port /dev/ttyUSB0 ls
```

---

## Troubleshooting

### Import Errors

If you see `ImportError: no module named 'xyz'`, the module may not be compiled into this build. Check `sdkconfig` for MicroPython module options.

### Out of Memory

MicroPython allocates 1MB heap in PSRAM. If you run out:

```python
import gc
gc.collect()  # Force garbage collection
gc.mem_free()  # Check free memory
```

### Stack Overflow

Reduce recursion depth or increase stack size in `main/micropython_task.c`:

```c
mp_stack_set_limit(20 * 1024);  // Increase to 20KB
```

### No REPL Prompt

- Check baud rate (115200)
- Press Ctrl+C to interrupt running code
- Press Ctrl+D for soft reset

---

## Advanced: Building MicroPython from ESP-IDF Port

For a more integrated approach, you can use MicroPython's official ESP32 port:

```bash
cd micropython/ports/esp32
make submodules
make BOARD=GENERIC_S3
```

However, this template integrates MicroPython directly into an ESP-IDF project for easier customization and OTA support.

---

## Next Steps

- Add custom C modules for badge-specific hardware (display driver, LED strip, etc.)
- Create Python libraries for common tasks
- Set up OTA updates to switch between apps
- Build a graphical shell using the TFT display

See [docs/EXAMPLES.md](EXAMPLES.md) for more code samples.
