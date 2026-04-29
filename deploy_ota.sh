#!/bin/bash
#
# deploy_ota.sh - Deploy MicroPython REPL app to bootloader OTA system
#
# Usage:
#   ./deploy_ota.sh [bootloader_repo_path]
#
# If bootloader_repo_path is not provided, it will look in common locations.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="micropython_repl"
APP_BINARY="$SCRIPT_DIR/build/namebadge_micropython.bin"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     MicroPython REPL - OTA Deployment Script             ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if binary exists
if [ ! -f "$APP_BINARY" ]; then
    echo "❌ ERROR: Binary not found at $APP_BINARY"
    echo ""
    echo "Please build the app first:"
    echo "  idf.py build"
    echo ""
    exit 1
fi

echo "✓ Found app binary: $APP_BINARY"
APP_SIZE=$(stat -f%z "$APP_BINARY" 2>/dev/null || stat -c%s "$APP_BINARY")
echo "  Size: $APP_SIZE bytes ($(($APP_SIZE / 1024)) KB)"

# Generate SHA256 hash
APP_HASH=$(sha256sum "$APP_BINARY" | cut -d' ' -f1)
echo "  SHA256: $APP_HASH"
echo ""

# Find bootloader repository
BOOTLOADER_PATH="$1"

if [ -z "$BOOTLOADER_PATH" ]; then
    echo "🔍 Searching for bootloader repository..."
    
    # Common locations to check
    SEARCH_PATHS=(
        "$SCRIPT_DIR/../namebadge_bootloader"
        "$SCRIPT_DIR/../namebadge"
        "$HOME/Documents/Repositories/namebadge_bootloader"
        "/mnt/c/users/lynn/Documents/Repositories/namebadge_bootloader"
    )
    
    for path in "${SEARCH_PATHS[@]}"; do
        if [ -d "$path" ]; then
            BOOTLOADER_PATH="$path"
            echo "  Found: $BOOTLOADER_PATH"
            break
        fi
    done
    
    if [ -z "$BOOTLOADER_PATH" ]; then
        echo ""
        echo "❌ ERROR: Bootloader repository not found"
        echo ""
        echo "Please specify the path:"
        echo "  ./deploy_ota.sh /path/to/namebadge_bootloader"
        echo ""
        exit 1
    fi
fi

# Check if bootloader path exists
if [ ! -d "$BOOTLOADER_PATH" ]; then
    echo "❌ ERROR: Bootloader path not found: $BOOTLOADER_PATH"
    exit 1
fi

echo "✓ Bootloader repository: $BOOTLOADER_PATH"
echo ""

# Create OTA directory structure
OTA_DIR="$BOOTLOADER_PATH/ota_files"
APPS_DIR="$OTA_DIR/apps"

echo "📁 Setting up OTA directory structure..."
mkdir -p "$APPS_DIR"
echo "  $APPS_DIR"
echo ""

# Copy binary
DEST_BINARY="$APPS_DIR/${APP_NAME}.bin"
echo "📦 Copying binary..."
cp "$APP_BINARY" "$DEST_BINARY"
echo "  → $DEST_BINARY"
echo ""

# Update or create manifest.json
MANIFEST="$OTA_DIR/manifest.json"

echo "📝 Updating manifest.json..."

# Check if manifest exists
if [ -f "$MANIFEST" ]; then
    echo "  Found existing manifest"
    # TODO: Update existing manifest (requires jq or manual JSON editing)
    echo "  Please manually update $MANIFEST with:"
else
    echo "  Creating new manifest"
    cat > "$MANIFEST" << EOF
{
  "version": "1.0",
  "description": "BYUI eBadge V3.0 App Catalog",
  "apps": [
    {
      "name": "MicroPython REPL",
      "version": "1.0.0",
      "description": "Interactive Python programming environment",
      "author": "BYUI",
      "category": "Development",
      "url": "http://192.168.60.8/apps/${APP_NAME}.bin",
      "size": $APP_SIZE,
      "hash": "sha256:$APP_HASH",
      "features": [
        "Python REPL",
        "WiFi Support",
        "Hardware Control"
      ]
    }
  ],
  "metadata": {
    "generated": "$(date -u +%Y-%m-%d)",
    "protocol": "http"
  }
}
EOF
fi

echo ""
echo "App Entry:"
echo "─────────────────────────────────────────────────────────────"
cat << EOF
{
  "name": "MicroPython REPL",
  "version": "1.0.0",
  "description": "Interactive Python programming environment",
  "url": "http://192.168.60.8/apps/${APP_NAME}.bin",
  "size": $APP_SIZE,
  "hash": "sha256:$APP_HASH"
}
EOF
echo "─────────────────────────────────────────────────────────────"
echo ""

# Instructions
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo ""
echo "1. Start OTA server:"
echo "   cd $OTA_DIR"
echo "   python3 -m http.server 8000"
echo ""
echo "2. Update the URL in manifest.json to match your badge IP"
echo "   (Check badge AP IP from bootloader, typically 192.168.X.Y)"
echo ""
echo "3. On the badge:"
echo "   • Boot to app selector (factory partition)"
echo "   • Connect to WiFi"
echo "   • Browse apps → Select 'MicroPython REPL'"
echo "   • Download and install"
echo "   • Reboot into Python REPL"
echo ""
echo "4. To return to menu from MicroPython:"
echo "   >>> from badge import return_to_menu"
echo "   >>> return_to_menu()"
echo ""
