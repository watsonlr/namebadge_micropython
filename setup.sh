#!/bin/bash
#
# setup.sh - Quick setup script for BYUI eBadge MicroPython
#
# This script initializes the MicroPython submodule and configures
# the project for building.
#

set -e  # Exit on error

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     BYUI eBadge V3.0 - MicroPython REPL Setup            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if ESP-IDF is sourced
if [ -z "$IDF_PATH" ]; then
    echo "❌ ERROR: ESP-IDF environment not found!"
    echo ""
    echo "Please source ESP-IDF first:"
    echo "  . \$HOME/esp/esp-idf/export.sh"
    echo ""
    exit 1
fi

echo "✓ ESP-IDF found: $IDF_PATH"
echo ""

# Check ESP-IDF version
idf_version=$(idf.py --version 2>&1 | grep -oP 'v\d+\.\d+\.\d+' | head -1)
echo "ESP-IDF version: $idf_version"
echo ""

# Initialize submodules
echo "📦 Initializing MicroPython submodule..."
if [ ! -d "micropython/.git" ]; then
    git submodule update --init --recursive
    echo "✓ MicroPython submodule initialized"
else
    echo "✓ MicroPython submodule already initialized"
fi
echo ""

# Set target
echo "🎯 Setting target to ESP32-S3..."
idf.py set-target esp32s3
echo ""

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Build:   make build      (or: idf.py build)"
echo "  2. Flash:   make flash      (or: idf.py -p /dev/ttyUSB0 flash)"
echo "  3. Monitor: make monitor    (or: idf.py -p /dev/ttyUSB0 monitor)"
echo ""
echo "Or do all at once:"
echo "  make flash-monitor"
echo ""
echo "For help: make help"
echo ""
