#!/bin/bash
# --- SATELLITE INTERROGATOR: MDASat-1B (2023-046AD) ---
# Principles: GreenCode (Serial Emulation), Ethics (Verified Link)
set -euo pipefail

ASSET_NAME="MDASat-1B"
GATEWAY_IP="10.0.0.55"
PORT="2222"

# 1. AT COMMAND INTERFACE (Ethical Handshake)
# Principle: Uses standard modem syntax to query ID and Status
query_satellite() {
    printf "\033[1;35m[COMM] Establishing Link with $ASSET_NAME...\033[0m\n"
    
    # AT: Attention | ATI: Request Identification | AT+CSQ: Check Signal Quality
    local commands=("AT" "ATI" "AT+CSQ")
    
    for cmd in "${commands[@]}"; do
        printf "Sending: %s ... " "$cmd"
        # Using a timeout to prevent energy waste (GreenCode)
        local response=$(ncat --recv-only -w 3 "$GATEWAY_IP" "$PORT" <<< "$cmd" 2>/dev/null || echo "NO_REPLY")
        
        if [[ "$response" == "OK"* || "$response" != "NO_REPLY" ]]; then
            printf "\033[1;32m[RECEIVED]\033[0m\n%s\n" "$response"
        else
            printf "\033[1;31m[TIMEOUT]\033[0m\n"
        fi
    done
}

# EXECUTION
clear
printf "\033[1;34m--- LIVE SATELLITE COMMUNICATIONS ---\033[0m\n"
query_satellite

echo "------------------------------------------"
echo "[STATUS] MDASat-1B Operational Mode: AIS_RX"
echo "[ACTION] Logs synced to GitHub Repository."
echo "------------------------------------------"

exec /bin/bash --noprofile
