# BYUI eBadge V3.0 - OTA App Deployment

This directory contains everything needed to deploy the MicroPython REPL as a selectable app on the BYUI eBadge bootloader.

## Quick Deployment

```bash
# 1. Build the app
make build

# 2. Deploy to bootloader
make deploy-ota

# 3. Start OTA server (from bootloader repo)
cd /path/to/namebadge_bootloader/ota_files
python3 -m http.server 8000
```

## What Gets Deployed

- **Binary**: `micropython_repl.bin` → Bootloader's `ota_files/apps/`
- **Manifest**: Entry added to `manifest.json`
- **Hash**: SHA256 checksum for integrity verification

## Using on Badge

### From Bootloader App Selector

1. **Power on** → Badge boots to factory partition (app menu)
2. **Connect to WiFi** → Badge connects to network
3. **Browse Apps** → See available apps from manifest
4. **Select "MicroPython REPL"** → Download starts
5. **Install** → Flashes to OTA partition (ota_0, ota_1, or ota_2)
6. **Reboot** → Badge boots into MicroPython REPL

### Returning to Menu

From MicroPython REPL:

```python
>>> from badge import return_to_menu
>>> return_to_menu()
Returning to app menu...
[Badge reboots to app selector]
```

## Partition Layout

```
Flash Memory (8 MB)
├── 0x1000    Bootloader
├── 0x8000    Partition Table
├── 0x9000    NVS (Settings)
├── 0xF000    OTA Data (boot partition selector)
├── 0x20000   Factory (App Selector - never overwritten)
├── 0x110000  OTA_0 (Downloadable app slot)
├── 0x200000  OTA_1 (Downloadable app slot)
└── 0x2F0000  OTA_2 (Downloadable app slot)
                      ↑
              MicroPython REPL can be installed here
```

## Manual Deployment

If the automated script doesn't work:

```bash
# 1. Build
idf.py build

# 2. Copy binary
cp build/namebadge_micropython.bin \
   /path/to/bootloader/ota_files/apps/micropython_repl.bin

# 3. Generate hash
sha256sum /path/to/bootloader/ota_files/apps/micropython_repl.bin

# 4. Edit manifest.json
nano /path/to/bootloader/ota_files/manifest.json
```

Add this entry to the `apps` array:

```json
{
  "name": "MicroPython REPL",
  "version": "1.0.0",
  "description": "Interactive Python programming environment",
  "url": "http://192.168.60.8/apps/micropython_repl.bin",
  "size": 1048576,
  "hash": "sha256:YOUR_HASH_HERE"
}
```

## Network Configuration

The badge's IP address is derived from its MAC address:

```
AP IP = 192.168.(MAC_byte4 % 240).(MAC_byte5 % 240)
```

Update the URL in `manifest.json` to match your badge's IP.

To find your badge IP:
- Check bootloader serial output during WiFi setup
- Look for: `SoftAP started: IP=192.168.X.Y`

## Troubleshooting

### App Doesn't Appear in Menu

- Verify OTA server is running
- Check manifest.json syntax (valid JSON)
- Ensure URL in manifest matches badge IP
- Check badge WiFi connection

### Download Fails

- Verify binary file exists at specified path
- Check network connectivity
- Ensure file size matches manifest
- Verify SHA256 hash is correct

### Boot Loop After Install

- Binary may be corrupted
- Flash using direct partition write:
  ```bash
  parttool.py --port /dev/ttyUSB0 write_partition \
    --partition-name ota_0 --input build/namebadge_micropython.bin
  ```

### Can't Return to Menu

- Factory partition may be missing/corrupted
- Reflash bootloader:
  ```bash
  cd /path/to/namebadge_bootloader
  idf.py -p /dev/ttyUSB0 flash
  ```

## Advanced: Direct Partition Flash

Skip OTA and flash directly to a partition:

```bash
# Flash to ota_0 at 0x110000
esptool.py --port /dev/ttyUSB0 --chip esp32s3 \
  write_flash 0x110000 build/namebadge_micropython.bin

# Set ota_0 as boot partition (requires bootloader support)
parttool.py --port /dev/ttyUSB0 set_boot_partition --partition-name ota_0
```

## Files

- **[deploy_ota.sh](../deploy_ota.sh)** - Automated deployment script
- **[manifest.json.example](../manifest.json.example)** - Example manifest entry
- **[OTA_INTEGRATION.md](OTA_INTEGRATION.md)** - Complete integration guide

## See Also

- [Bootloader Repository](https://github.com/watsonlr/namebadge_bootloader) (if available)
- [ESP-IDF OTA Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/api-reference/system/ota.html)
- [Partition Tables](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/api-guides/partition-tables.html)
