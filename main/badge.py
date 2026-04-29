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

def return_to_menu():
    """Return to the bootloader app menu (factory partition)"""
    try:
        from esp32 import Partition
        
        # Find factory partition
        factory = None
        for p in Partition.find(Partition.TYPE_APP):
            info = p.info()
            if info[0] == Partition.TYPE_APP and \
               info[1] == Partition.SUBTYPE_APP_FACTORY:
                factory = p
                break
        
        if factory:
            factory.set_boot()
            print("Returning to app menu...")
            import machine
            machine.reset()
        else:
            print("ERROR: Factory partition not found")
            print("Cannot return to menu")
    except Exception as e:
        print(f"Error returning to menu: {e}")

def show_partitions():
    """Display partition table and boot information"""
    try:
        from esp32 import Partition
        
        print("\nPartition Table:")
        print("-" * 60)
        print(f"{'Label':<15} {'Type':<8} {'SubType':<12} {'Size':>10}")
        print("-" * 60)
        
        for p in Partition.find():
            info = p.info()
            type_map = {0: "APP", 1: "DATA"}
            subtype_map = {
                0x00: "FACTORY",
                0x10: "OTA_0", 0x11: "OTA_1", 0x12: "OTA_2",
                0x01: "NVS", 0x02: "PHY"
            }
            
            type_name = type_map.get(info[0], "UNKNOWN")
            subtype_name = subtype_map.get(info[1], f"0x{info[1]:02X}")
            label = info[2] if info[2] else "(no label)"
            size = info[3]
            
            # Check if this is the boot partition
            boot_marker = ""
            try:
                if hasattr(p, 'get_boot_partition'):
                    boot_part = Partition.get_boot_partition()
                    if boot_part and boot_part.info()[2] == label:
                        boot_marker = " [BOOT]"
            except:
                pass
            
            print(f"{label:<15} {type_name:<8} {subtype_name:<12} {size:>10}{boot_marker}")
        
        print("-" * 60)
    except Exception as e:
        print(f"Error reading partitions: {e}")

print("BYUI eBadge V3.0 hardware definitions loaded")
print("Import with: from badge import *")
print("\nUtility functions:")
print("  return_to_menu()    - Return to bootloader app selector")
print("  show_partitions()   - Display partition table")
