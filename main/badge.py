"""
BYUI eBadge V3.0 - Hardware Pin Definitions

This module provides easy access to all badge hardware pins.
Import this in your MicroPython scripts to interact with badge peripherals.

Example:
    from badge import *
    from machine import Pin
    
    # Turn on red LED
    led_red = Pin(LED_RED, Pin.OUT)
    led_red.on()
    
    # Read button state
    btn_a = Pin(BUTTON_A, Pin.IN, Pin.PULL_UP)
    if not btn_a.value():  # Active LOW
        print("Button A pressed!")
"""

# Display (ILI9341 TFT LCD)
DISPLAY_CS = 9
DISPLAY_DC = 13
DISPLAY_RST = 48
DISPLAY_CLK = 12
DISPLAY_MOSI = 11
DISPLAY_MISO = 10

# SD Card
SD_CS = 3

# Buttons (all active LOW with pull-ups)
BUTTON_UP = 17
BUTTON_DOWN = 16
BUTTON_LEFT = 14
BUTTON_RIGHT = 15
BUTTON_A = 38
BUTTON_B = 18
BUTTON_BOOT = 0

# RGB LED
LED_RED = 6
LED_GREEN = 5
LED_BLUE = 4

# Addressable LEDs (WS2813B)
LED_STRIP = 7

# Buzzer (Piezo)
BUZZER = 42

# I2C (Accelerometer MMA8452Q)
I2C_SDA = 47
I2C_SCL = 21
I2C_FREQ = 400000  # 400 kHz

# Joystick (ADC)
JOYSTICK_X = 1
JOYSTICK_Y = 2

# USB
USB_DN = 19
USB_DP = 20

# SPI Bus IDs
SPI_DISPLAY = 2  # SPI2_HOST

# Display specifications
DISPLAY_WIDTH = 240
DISPLAY_HEIGHT = 320
DISPLAY_ROTATION = 1  # Landscape mode

print("BYUI eBadge V3.0 hardware definitions loaded")
print("Import with: from badge import *")
