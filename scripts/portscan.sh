#!/bin/bash
#
# portscan.sh - Scan a port range on a single host.
# Package-agnostic: uses nmap if available, otherwise falls back to
# nc (netcat/openbsd), then to pure bash /dev/tcp.
#
# Usage:
#   ./portscan.sh <host> <start_port> <end_port>
#   ./portscan.sh 192.168.1.5 2 200
#
# Works on Linux and macOS. No root required for TCP connect scans.

set -u

usage() {
    echo "Usage: $0 <host> <start_port> <end_port>" >&2
    echo "Example: $0 192.168.1.5 2 200" >&2
    exit 1
}

[ $# -ne 3 ] && usage

HOST="$1"
START="$2"
END="$3"

# Validate args
[[ "$HOST" =~ ^[a-zA-Z0-9._-]+$ ]] || { echo "Invalid host: $HOST" >&2; exit 1; }
[[ "$START" =~ ^[0-9]+$ ]] && [[ "$END" =~ ^[0-9]+$ ]] || usage
[ "$START" -ge 1 ] && [ "$START" -le 65535 ] || { echo "start_port out of range" >&2; exit 1; }
[ "$END" -ge 1 ] && [ "$END" -le 65535 ] || { echo "end_port out of range" >&2; exit 1; }
[ "$START" -le "$END" ] || { echo "start_port must be <= end_port" >&2; exit 1; }

TIMEOUT=1  # seconds per port probe

# --- Method 1: nmap --------------------------------------------------------
if command -v nmap >/dev/null 2>&1; then
    echo "[*] Scanning $HOST ports $START-$END with nmap..."
    exec nmap -p "$START-$END" --open -T4 "$HOST"
fi

# --- Method 2: nc ----------------------------------------------------------
scan_nc() {
    local port
    for ((port = START; port <= END; port++)); do
        if nc -z -w "$TIMEOUT" "$HOST" "$port" >/dev/null 2>&1; then
            echo "open  $port"
        fi
    done
}

# --- Method 3: pure bash /dev/tcp (no dependencies at all) -----------------
scan_bash() {
    local port
    for ((port = START; port <= END; port++)); do
        if (exec 3<>"/dev/tcp/$HOST/$port") 2>/dev/null; then
            echo "open  $port"
            exec 3>&- 3<&- 2>/dev/null
        fi
    done
}

# Bash /dev/tcp exists on Linux and macOS builds of bash.
if command -v nc >/dev/null 2>&1; then
    echo "[*] nmap not found, using nc..." >&2
    METHOD="nc"
    RUN=scan_nc
else
    echo "[*] Neither nmap nor nc found, using bash /dev/tcp..." >&2
    METHOD="bash"
    RUN=scan_bash
fi

echo "[*] Scanning $HOST ports $START-$END ($METHOD, timeout ${TIMEOUT}s)..."
echo "[*] Open ports:"

FOUND=0
while IFS= read -r line; do
    echo "$line"
    FOUND=1
done < <("$RUN")

if [ "$FOUND" -eq 0 ]; then
    echo "(none)"
fi
