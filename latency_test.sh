#!/bin/bash
# --- UPLINK LATENCY SIMULATOR ---
# Asset: MDASat-1B (525km Altitude)
set -eu

ALTITUDE=525 # km
SPEED_OF_LIGHT=300000 # km/s

# Calculate theoretical RTT in milliseconds
# Math: (Altitude * 2 / Speed) * 1000
THEORETICAL_RTT=$(awk -v a=$ALTITUDE -v s=$SPEED_OF_LIGHT 'BEGIN {printf "%.2f", (a*2/s)*1000}')

printf "\033[1;34m[TEST] Pinging MDASat-1B at ${ALTITUDE}km...\033[0m\n"
sleep 0.5 # Simulate local processing
echo "64 bytes from 2023-046AD: icmp_seq=1 ttl=64 time=${THEORETICAL_RTT} ms"
echo "64 bytes from 2023-046AD: icmp_seq=2 ttl=64 time=$(awk -v r=$THEORETICAL_RTT 'BEGIN {print r+1.2}') ms"

echo -e "\n[SANSA ADVISORY] Theoretical minimum reached. Hardware jitter detected."
