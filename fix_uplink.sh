#!/bin/bash
# --- EMERGENCY UPLINK RECOVERY ---
set -eu

GATEWAY="10.0.0.55"
PORT="2222"

echo "[DEBUG] 1. Testing Local Network Stack..."
ping -c 2 8.8.8.8 > /dev/null && echo "[PASS] Internet OK" || echo "[FAIL] No Network"

echo "[DEBUG] 2. Checking Gateway Visibility..."
if nc -zv -w 3 $GATEWAY $PORT 2>&1; then
    echo "[PASS] Gateway found on port $PORT"
else
    echo "[FAIL] Gateway unreachable. Check if $GATEWAY is on the same Wi-Fi."
fi

echo "[DEBUG] 3. Verifying SSH Keys..."
[ -f ~/.ssh/id_rsa ] && echo "[PASS] Keys exist" || echo "[WARN] No SSH keys found. Run 'ssh-keygen' first."

echo "[DEBUG] 4. Resetting Termux Network (Safe)"
termux-fix-shebang satellite_uplink.sh
chmod +x satellite_uplink.sh

echo -e "\n[ACTION] Try running ./satellite_uplink.sh again."
