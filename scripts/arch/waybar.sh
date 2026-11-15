#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Alexays/Waybar.git"
BUILD_DIR="build"

echo "Updating package lists..."
sudo apt update

echo "Installing dependencies..."
sudo apt install -y \
  clang-tidy \
  gobject-introspection \
  libdbusmenu-gtk3-dev \
  libevdev-dev \
  libfmt-dev \
  libgirepository1.0-dev \
  libgtk-3-dev \
  libgtkmm-3.0-dev \
  libinput-dev \
  libjsoncpp-dev \
  libmpdclient-dev \
  libnl-3-dev \
  libnl-genl-3-dev \
  libpulse-dev \
  libsigc++-2.0-dev \
  libspdlog-dev \
  libwayland-dev \
  scdoc \
  upower \
  libxkbregistry-dev \
  git \
  meson \
  ninja-build \
  pkg-config

echo "Cloning Waybar repository..."
if [[ -d "Waybar/.git" ]]; then
  echo "Waybar repository already exists. Updating it..."
  git -C Waybar pull --ff-only
elif [[ -e "Waybar" ]]; then
  echo "Error: Waybar exists but is not a Git repository."
  exit 1
else
  git clone "$REPO_URL" Waybar
fi

cd Waybar

echo "Configuring build..."
meson setup "$BUILD_DIR" --prefix=/usr/local

echo "Building Waybar..."
ninja -C "$BUILD_DIR"

echo "Installing Waybar..."
sudo ninja -C "$BUILD_DIR" install

echo "Waybar installation completed successfully."
