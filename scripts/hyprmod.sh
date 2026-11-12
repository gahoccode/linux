#!/bin/bash
set -e

echo "Updating package lists..."
sudo apt update

echo "Installing dependencies..."
sudo apt install -y \
  lua5.4 \
  libcairo2-dev \
  libgirepository-2.0-dev \
  libgtk-4-dev \
  libadwaita-1-dev \
  gir1.2-gnomedesktop-4.0 \
  gobject-introspection \
  pkg-config \
  build-essential \
  python3-dev \
  python3-pip \
  python3-venv \
  meson \
  ninja-build \
  curl

# Check whether uv is installed
if command -v uv >/dev/null 2>&1; then
  echo "uv is already installed: $(command -v uv)"
else
  echo "uv is not installed. Installing uv..."

  curl -LsSf https://astral.sh/uv/install.sh | sh

  # Load uv into the current shell environment
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

  # Verify installation
  if ! command -v uv >/dev/null 2>&1; then
    echo "Error: uv installation failed or uv could not be found in PATH."
    exit 1
  fi

  echo "uv installed successfully: $(command -v uv)"
fi

# Install Hyprmod
echo "Installing Hyprmod..."
curl -LsSf https://raw.githubusercontent.com/BlueManCZ/hyprmod/main/install.sh | sh

echo "All dependencies and Hyprmod installation steps completed."
