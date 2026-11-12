#!/usr/bin/env bash
sudo apt update && sudo apt install lm-sensors -y
sudo apt install iperf3 -y
sudo apt install btop -y
# Check Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs | cut -d. -f1)
if [ "$UBUNTU_VERSION" -ge 25 ]; then
    # Ubuntu 25 or newer: fastfetch is available directly
    sudo apt install fastfetch -y
else
    # Ubuntu 24 or older: use the Fastfetch PPA
    # Install software-properties-common to enable add-apt-repository
    sudo apt install software-properties-common -y
    # Add the Fastfetch PPA
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
    # Update the package lists after adding the new PPA
    sudo apt update
    # Install fastfetch
    sudo apt install fastfetch
fi
