# Integrating MicroPython REPL as an OTA App

This guide explains how to make the MicroPython REPL available as a selectable app on the BYUI eBadge bootloader system.

## Overview

The BYUI eBadge uses an OTA (Over-The-Air) app system with:
- **Factory partition**: Permanent bootloader/app selector (never overwritten)
- **OTA partitions**: Downloadable apps (ota_0, ota_1, ota_2)
- **manifest.json**: App catalog served over HTTP/WiFi

## Integration Steps

### 1. Build MicroPython as OTA App

Build the MicroPython REPL app to generate a flashable binary:

```bash
# Standard build
idf.py build

# The app binary will be at:
# build/namebadge_micropython.bin
```

### 2. Prepare for OTA Deployment

#### Option A: Flash to Specific OTA Partition

Flash directly to an OTA partition (e.g., ota_0):

```bash
# Flash to ota_0 partition at 0x110000
esptool.py --port /dev/ttyUSB0 --chip esp32s3 \
    write_flash 0x110000 build/namebadge_micropython.bin

# Or use partition name
parttool.py --port /dev/ttyUSB0 write_partition \
    --partition-name ota_0 --input build/namebadge_micropython.bin
```

#### Option B: Deploy via OTA Server

Copy the binary to the bootloader's OTA file directory:

```bash
# Assuming bootloader repo structure:
# namebadge_bootloader/
# ├── ota_files/
# │   ├── apps/
# │   │   ├── led_app.bin
# │   │   ├── game.bin
# │   │   └── micropython_repl.bin  ← Add here
# │   └── manifest.json

# Copy built binary
cp build/namebadge_micropython.bin \
   /path/to/namebadge_bootloader/ota_files/apps/micropython_repl.bin
```

### 3. Update manifest.json

Add MicroPython REPL to the app catalog:

```json
{
  "apps": [
    {
      "name": "MicroPython REPL",
      "version": "1.0.0",
      "description": "Interactive Python environment",
      "url": "http://192.168.X.Y/apps/micropython_repl.bin",
      "size": 1234567,
      "hash": "sha256_hash_here"
    },
    {
      "name": "LED Demo",
      "version": "1.0.0",
      "description": "LED patterns",
      "url": "http://192.168.X.Y/apps/led_app.bin",
      "size": 123456,
      "hash": "sha256_hash_here"
    }
  ]
}
```

To generate the hash:

```bash
sha256sum build/namebadge_micropython.bin
```

### 4. Start OTA Server

From the bootloader repository:

```bash
cd namebadge_bootloader/ota_files
python3 -m http.server 8000

# Or use the provided OTA server script if available:
python3 simple_ota_server.py
```

### 5. Select App from Bootloader

1. **Power on badge** → Boots into factory partition (app selector)
2. **Connect to WiFi** → Badge connects or creates AP
3. **Browse app list** → Shows apps from manifest.json
4. **Select "MicroPython REPL"** → Downloads and flashes to OTA partition
5. **Reboot** → Boots into MicroPython REPL

---

## Bootloader Integration Architecture

```
┌─────────────────────────────────────────────────┐
│  Factory Partition (0x20000)                   │
│  ┌───────────────────────────────────────┐     │
│  │  Bootloader / App Selector            │     │
│  │  • Display app menu                   │     │
│  │  • WiFi connection                    │     │
│  │  • HTTP client                        │     │
│  │  • OTA download & flash               │     │
│  │  • Partition management               │     │
│  └───────────────────────────────────────┘     │
└─────────────────────────────────────────────────┘
                    ↓ Downloads
        ┌──────────────────────────┐
        │  OTA Server (HTTP)       │
        │  192.168.X.Y:8000        │
        ├──────────────────────────┤
        │  GET /manifest.json      │
        │  GET /apps/micropython_repl.bin │
        └──────────────────────────┘
                    ↓ Flashes to
┌─────────────────────────────────────────────────┐
│  OTA Partition 0 (0x110000)                    │
│  ┌───────────────────────────────────────┐     │
│  │  MicroPython REPL App                 │     │
│  │  • Python interpreter                 │     │
│  │  • REPL interface                     │     │
│  │  • Hardware drivers                   │     │
│  └───────────────────────────────────────┘     │
└─────────────────────────────────────────────────┘
```

---

## Return to Bootloader from MicroPython

To allow users to return to the app selector from MicroPython:

### Add Return Function to badge.py

```python
import esp32
from esp_partition import Partition

def return_to_bootloader():
    """Return to the factory app selector"""
    # Find factory partition
    factory = None
    for p in Partition.find(Partition.TYPE_APP, Partition.SUBTYPE_APP_FACTORY):
        factory = p
        break
    
    if factory:
        factory.set_boot()
        print("Rebooting to app selector...")
        import machine
        machine.reset()
    else:
        print("Factory partition not found")
```

### Add to main/badge.py

Update the badge.py module:

```python
# ... existing pin definitions ...

def return_to_menu():
    """Return to the bootloader app menu"""
    try:
        from esp32 import Partition
        
        # Find factory partition
        for p in Partition.find(Partition.TYPE_APP):
            if p.info()[0] == Partition.TYPE_APP and \
               p.info()[1] == Partition.SUBTYPE_APP_FACTORY:
                p.set_boot()
                print("Returning to app menu...")
                import machine
                machine.reset()
                return
        
        print("Factory partition not found")
    except Exception as e:
        print(f"Error: {e}")

print("\nCommands:")
print("  return_to_menu() - Return to bootloader app selector")
```

### Usage in REPL

```python
>>> from badge import return_to_menu
>>> return_to_menu()
Returning to app menu...
[Badge reboots to app selector]
```

---

## Alternative: Direct Flash to Factory

If you want MicroPython REPL as the **main** factory app:

```bash
# Flash as factory partition
esptool.py --port /dev/ttyUSB0 --chip esp32s3 write_flash \
    0x1000 build/bootloader/bootloader.bin \
    0x8000 build/partition_table/partition-table.bin \
    0x20000 build/namebadge_micropython.bin
```

This replaces the bootloader app selector with MicroPython REPL.

---

## Complete Workflow Example

### Step 1: Build MicroPython App

```bash
cd namebadge_micropython
idf.py build
ls -lh build/namebadge_micropython.bin
```

### Step 2: Copy to Bootloader OTA Directory

```bash
# Clone/locate bootloader repo
cd ../namebadge_bootloader

# Create OTA directory structure if needed
mkdir -p ota_files/apps

# Copy binary
cp ../namebadge_micropython/build/namebadge_micropython.bin \
   ota_files/apps/micropython_repl.bin

# Generate hash
sha256sum ota_files/apps/micropython_repl.bin
```

### Step 3: Update Manifest

Edit `ota_files/manifest.json`:

```json
{
  "version": "1.0",
  "apps": [
    {
      "name": "MicroPython REPL",
      "version": "1.0.0",
      "description": "Interactive Python programming environment",
      "author": "BYUI",
      "url": "http://192.168.60.8/apps/micropython_repl.bin",
      "size": 1048576,
      "hash": "abc123...",
      "category": "Development"
    }
  ]
}
```

### Step 4: Flash Bootloader (First Time)

```bash
# Flash the factory bootloader/app selector
cd namebadge_bootloader
idf.py -p /dev/ttyUSB0 flash
```

### Step 5: Start OTA Server

```bash
cd ota_files
python3 -m http.server 8000
```

### Step 6: Use Badge

1. Power on → Shows app menu
2. Connect to WiFi (badge AP or home network)
3. Browse apps → See "MicroPython REPL"
4. Download → Flashes to OTA partition
5. Boot → Enters Python REPL
6. Use `return_to_menu()` → Back to app selector

---

## Partition Management

### Check Current Boot Partition

Add to MicroPython:

```python
from esp32 import Partition

def show_partitions():
    """Display partition information"""
    print("\nPartition Table:")
    print("-" * 50)
    
    for p in Partition.find():
        type_name = {0: "APP", 1: "DATA"}.get(p.info()[0], "UNKNOWN")
        boot_marker = " [BOOT]" if p.get_next_update() else ""
        print(f"{p.info()[2]:12s} {type_name:6s} {p.info()[3]:8d} bytes{boot_marker}")
```

### Set Boot Partition from REPL

```python
>>> from esp32 import Partition
>>> 
>>> # Boot from ota_1 next time
>>> for p in Partition.find(Partition.TYPE_APP, label="ota_1"):
...     p.set_boot()
...     break
>>> 
>>> import machine
>>> machine.reset()
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| App not in menu | Check manifest.json URL and OTA server running |
| Download fails | Verify badge IP matches manifest URL |
| Boot loop | Factory partition corrupted, reflash bootloader |
| Can't return to menu | Ensure factory partition exists and is valid |
| Wrong partition boots | Check otadata, may need `esp_ota_set_boot_partition()` |

---

## Advanced: Custom Bootloader Integration

If you have access to the bootloader source code, you can add a dedicated "Python" button:

```c
// In bootloader app selector menu
if (button_python_pressed) {
    const esp_partition_t *ota_partition = 
        esp_partition_find_first(ESP_PARTITION_TYPE_APP,
                                 ESP_PARTITION_SUBTYPE_APP_OTA_0, 
                                 "micropython");
    esp_ota_set_boot_partition(ota_partition);
    esp_restart();
}
```

---

## Summary

To integrate MicroPython REPL as a selectable app:

1. ✅ Build the app binary
2. ✅ Copy to bootloader's OTA directory
3. ✅ Update manifest.json
4. ✅ Start OTA HTTP server
5. ✅ Select from badge menu
6. ✅ Add return_to_menu() function

Your MicroPython REPL is now a fully-integrated badge app!
