# MicroPython Code Examples for BYUI eBadge V3.0

## Table of Contents
- [LED Examples](#led-examples)
- [Button & Input Examples](#button--input-examples)
- [Display Examples](#display-examples)
- [Sensor Examples](#sensor-examples)
- [WiFi & Networking](#wifi--networking)
- [Sound & Buzzer](#sound--buzzer)
- [Complete Projects](#complete-projects)

---

## LED Examples

### RGB LED Color Mixer

```python
from machine import Pin, PWM
from badge import LED_RED, LED_GREEN, LED_BLUE
import time

# Create PWM objects for each LED channel
red = PWM(Pin(LED_RED), freq=1000)
green = PWM(Pin(LED_GREEN), freq=1000)
blue = PWM(Pin(LED_BLUE), freq=1000)

def set_color(r, g, b):
    """Set RGB color (0-255 for each channel)"""
    red.duty(r * 4)    # Convert 0-255 to 0-1023
    green.duty(g * 4)
    blue.duty(b * 4)

# Rainbow cycle
colors = [
    (255, 0, 0),    # Red
    (255, 127, 0),  # Orange
    (255, 255, 0),  # Yellow
    (0, 255, 0),    # Green
    (0, 0, 255),    # Blue
    (75, 0, 130),   # Indigo
    (148, 0, 211),  # Violet
]

while True:
    for r, g, b in colors:
        set_color(r, g, b)
        time.sleep(1)
```

### Breathing LED Effect

```python
from machine import Pin, PWM
from badge import LED_BLUE
import time
import math

led = PWM(Pin(LED_BLUE), freq=1000)

while True:
    for i in range(100):
        # Sine wave breathing effect
        brightness = int((math.sin(i / 15.9) + 1) * 512)
        led.duty(brightness)
        time.sleep(0.02)
```

---

## Button & Input Examples

### Button Debouncing

```python
from machine import Pin
from badge import BUTTON_A, BUTTON_B
import time

class Button:
    def __init__(self, pin):
        self.pin = Pin(pin, Pin.IN, Pin.PULL_UP)
        self.last_state = 1
        self.last_time = 0
        self.debounce_ms = 50
        
    def pressed(self):
        """Returns True on button press (with debouncing)"""
        current_state = self.pin.value()
        current_time = time.ticks_ms()
        
        if current_state == 0 and self.last_state == 1:
            if time.ticks_diff(current_time, self.last_time) > self.debounce_ms:
                self.last_time = current_time
                self.last_state = current_state
                return True
        
        self.last_state = current_state
        return False

# Usage
btn_a = Button(BUTTON_A)
btn_b = Button(BUTTON_B)

counter = 0
while True:
    if btn_a.pressed():
        counter += 1
        print(f"Count: {counter}")
    if btn_b.pressed():
        counter = 0
        print("Reset!")
    time.sleep(0.01)
```

### Joystick Reading

```python
from machine import ADC, Pin
from badge import JOYSTICK_X, JOYSTICK_Y
import time

# Initialize ADC pins
joy_x = ADC(Pin(JOYSTICK_X))
joy_y = ADC(Pin(JOYSTICK_Y))

# Configure attenuation for 0-3.3V range
joy_x.atten(ADC.ATTN_11DB)
joy_y.atten(ADC.ATTN_11DB)

def read_joystick():
    """Returns normalized values (-1 to 1) for X and Y"""
    x_raw = joy_x.read()
    y_raw = joy_y.read()
    
    # Convert 0-4095 to -1.0 to 1.0 (assuming center ~2048)
    x_norm = (x_raw - 2048) / 2048.0
    y_norm = (y_raw - 2048) / 2048.0
    
    return x_norm, y_norm

while True:
    x, y = read_joystick()
    print(f"X: {x:+.2f}  Y: {y:+.2f}")
    time.sleep(0.1)
```

---

## Sensor Examples

### Accelerometer (MMA8452Q)

```python
from machine import I2C, Pin
from badge import I2C_SDA, I2C_SCL
import time
import struct

class MMA8452Q:
    ADDRESS = 0x1C  # or 0x1D depending on SA0 pin
    
    def __init__(self, i2c):
        self.i2c = i2c
        self.init_sensor()
    
    def init_sensor(self):
        # Put in standby mode
        self.i2c.writeto_mem(self.ADDRESS, 0x2A, bytes([0x00]))
        # Set range to ±2g
        self.i2c.writeto_mem(self.ADDRESS, 0x0E, bytes([0x00]))
        # Set to active mode
        self.i2c.writeto_mem(self.ADDRESS, 0x2A, bytes([0x01]))
        time.sleep(0.1)
    
    def read_accel(self):
        """Returns (x, y, z) acceleration in g"""
        data = self.i2c.readfrom_mem(self.ADDRESS, 0x01, 6)
        
        # Convert to 12-bit signed values
        x = struct.unpack('>h', data[0:2])[0] >> 4
        y = struct.unpack('>h', data[2:4])[0] >> 4
        z = struct.unpack('>h', data[4:6])[0] >> 4
        
        # Convert to g (assuming ±2g range, 12-bit)
        scale = 2.0 / 2048.0
        return x * scale, y * scale, z * scale

# Initialize I2C
i2c = I2C(0, scl=Pin(I2C_SCL), sda=Pin(I2C_SDA), freq=400000)

# Create accelerometer object
accel = MMA8452Q(i2c)

# Read and display
while True:
    x, y, z = accel.read_accel()
    print(f"X: {x:+.2f}g  Y: {y:+.2f}g  Z: {z:+.2f}g")
    time.sleep(0.1)
```

---

## WiFi & Networking

### WiFi Connection Manager

```python
import network
import time

class WiFiManager:
    def __init__(self):
        self.wlan = network.WLAN(network.STA_IF)
        self.wlan.active(True)
    
    def connect(self, ssid, password, timeout=10):
        """Connect to WiFi with timeout"""
        if self.wlan.isconnected():
            print("Already connected")
            return True
        
        print(f"Connecting to {ssid}...")
        self.wlan.connect(ssid, password)
        
        start = time.time()
        while not self.wlan.isconnected():
            if time.time() - start > timeout:
                print("Connection timeout")
                return False
            time.sleep(0.5)
            print(".", end="")
        
        print(f"\nConnected! IP: {self.wlan.ifconfig()[0]}")
        return True
    
    def disconnect(self):
        self.wlan.disconnect()
        print("Disconnected")
    
    def scan(self):
        """Scan for available networks"""
        print("Scanning...")
        networks = self.wlan.scan()
        for ssid, bssid, channel, rssi, authmode, hidden in networks:
            print(f"  {ssid.decode()}: {rssi} dBm (ch {channel})")

# Usage
wifi = WiFiManager()
wifi.scan()
wifi.connect('YourSSID', 'YourPassword')
```

### Simple HTTP Server

```python
import socket
import network

def start_server():
    # Assume WiFi is already connected
    addr = socket.getaddrinfo('0.0.0.0', 80)[0][-1]
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(addr)
    s.listen(1)
    
    print(f'HTTP server listening on port 80')
    
    while True:
        cl, addr = s.accept()
        print(f'Client connected from {addr}')
        
        request = cl.recv(1024)
        print(request)
        
        # Simple HTML response
        response = """HTTP/1.1 200 OK
Content-Type: text/html

<html>
<body>
<h1>BYUI eBadge V3.0</h1>
<p>Hello from MicroPython!</p>
</body>
</html>
"""
        cl.send(response)
        cl.close()

# Start server (assumes WiFi connected)
start_server()
```

---

## Sound & Buzzer

### Musical Notes

```python
from machine import Pin, PWM
from badge import BUZZER
import time

# Note frequencies (Hz)
NOTES = {
    'C4': 262, 'D4': 294, 'E4': 330, 'F4': 349,
    'G4': 392, 'A4': 440, 'B4': 494, 'C5': 523,
}

buzzer = PWM(Pin(BUZZER))

def play_note(note, duration_ms):
    """Play a musical note"""
    buzzer.freq(NOTES[note])
    buzzer.duty(512)  # 50% duty cycle
    time.sleep_ms(duration_ms)
    buzzer.duty(0)  # Silence

def play_melody():
    """Play a simple melody"""
    melody = [
        ('E4', 200), ('E4', 200), ('E4', 400),
        ('E4', 200), ('E4', 200), ('E4', 400),
        ('E4', 200), ('G4', 200), ('C4', 200), ('D4', 200),
        ('E4', 800),
    ]
    
    for note, duration in melody:
        play_note(note, duration)
        time.sleep_ms(50)  # Short pause between notes

play_melody()
buzzer.deinit()
```

---

## Complete Projects

### Badge Info Display (Serial)

```python
import esp32
import machine
import network
from badge import *

def show_badge_info():
    print("\n" + "="*50)
    print("BYUI eBadge V3.0 - System Information")
    print("="*50)
    
    # CPU Info
    freq = machine.freq() / 1_000_000
    print(f"\nCPU Frequency: {freq} MHz")
    print(f"Hall Sensor: {esp32.hall_sensor()}")
    print(f"Internal Temp: {(esp32.raw_temperature() - 32) / 1.8:.1f}°C")
    
    # Memory
    import gc
    gc.collect()
    print(f"\nFree Heap: {gc.mem_free()} bytes")
    print(f"Allocated: {gc.mem_alloc()} bytes")
    
    # WiFi MAC
    wlan = network.WLAN(network.STA_IF)
    mac = wlan.config('mac')
    mac_str = ':'.join([f'{b:02x}' for b in mac])
    print(f"\nMAC Address: {mac_str}")
    
    # Pins status
    print(f"\nButton A: {'PRESSED' if not Pin(BUTTON_A, Pin.IN, Pin.PULL_UP).value() else 'Released'}")
    print(f"Button B: {'PRESSED' if not Pin(BUTTON_B, Pin.IN, Pin.PULL_UP).value() else 'Released'}")
    
    print("\n" + "="*50 + "\n")

show_badge_info()
```

Save this as `badge_info.py` and run with `import badge_info` or `exec(open('badge_info.py').read())`.

---

For more examples and updates, visit the project repository.
