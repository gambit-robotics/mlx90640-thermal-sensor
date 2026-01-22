#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_NAME="venv"
PYTHON="python3"

# Install system lgpio package for Pi 5 GPIO support
# This provides both the C library and Python bindings
if command -v apt-get &> /dev/null; then
    if ! python3 -c "import lgpio" 2>/dev/null; then
        echo "Installing python3-lgpio system package..."
        sudo apt-get update -qq
        sudo apt-get install -y -qq python3-lgpio
    fi
fi

# Check if existing venv has system-site-packages access
# If not, delete it so we can recreate it properly (handles upgrades)
if [ -d "$SCRIPT_DIR/$VENV_NAME" ]; then
    if ! "$SCRIPT_DIR/$VENV_NAME/bin/python3" -c "import lgpio" 2>/dev/null; then
        echo "Existing venv doesn't have system package access, recreating..."
        rm -rf "$SCRIPT_DIR/$VENV_NAME"
    fi
fi

# Create virtualenv with access to system packages (for lgpio)
if [ ! -d "$SCRIPT_DIR/$VENV_NAME" ]; then
    echo "Creating virtual environment..."
    $PYTHON -m venv --system-site-packages "$SCRIPT_DIR/$VENV_NAME"
fi

# Install dependencies using venv's pip explicitly (PEP 668 compliance)
echo "Installing dependencies..."
"$SCRIPT_DIR/$VENV_NAME/bin/pip" install --upgrade pip
"$SCRIPT_DIR/$VENV_NAME/bin/pip" install -r "$SCRIPT_DIR/requirements.txt"

echo "Setup complete."
