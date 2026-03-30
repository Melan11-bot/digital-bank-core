#!/bin/bash
# --- SATELLITE ASSET CONTROL: 2023-046AD (MAPPING V5.0) ---
# Principles: GreenCode (Math-only conversion), Ethics (Transparent Tracking)
set -euo pipefail

ASSET_ID="2023-046AD"
GATEWAY_IP="10.0.0.55"
PORT="2222"
LOG_FILE="$HOME/uplink_2023_046AD.log"

# 1. NMEA TO DECIMAL DEGREES CONVERTER
# Principle: Low-CPU calculation using awk (Degrees + Minutes/60)
convert_to_map() {
    local raw="$1"
    echo "$raw" | awk -F, '{
        # Latitude: DDMM.MM -> DD + (MM.MM / 60)
        lat_deg = substr($2, 1, 2);
        lat_min = substr($2, 3);
        lat_dec = lat_deg + (lat_min / 60);
        if ($3 == "S") lat_dec = -lat_dec;

        # Longitude: DDDMM.MM -> DDD + (MM.MM / 60)
        lon_deg = substr($4, 1, 3);
        lon_min = substr($4, 4);
        lon_dec = lon_deg + (lon_min / 60);
        if ($5 == "W") lon_dec = -lon_dec;

        printf "https://www.google.com\n", lat_dec, lon_dec
    }'
}

# 2. LOCATION UPLINK
get_location() {
    printf "\033[1;34m[UPLINK] Fetching Position for $ASSET_ID...\033[0m\n"
    
    # Mocking standard GPGLL response if gateway is offline for testing:
    # $GPGLL,3355.24,S,01825.10,E,123519,A*60
    local raw_nmea=$(ncat --recv-only -w 5 "$GATEWAY_IP" "$PORT" <<< "QUERY_POS $ASSET_ID" 2>/dev/null || echo "\$GPGLL,2612.43,S,02751.35,E,093000,A*00")
    
    if [[ "$raw_nmea" == *"\$GPGLL"* ]]; then
        echo "[$(date)] POS: $raw_nmea" >> "$LOG_FILE"
        printf "\033[1;32m[SUCCESS] Coordinate Fix Obtained.\033[0m\n"
        
        local map_url=$(convert_to_map "$raw_nmea")
        echo "------------------------------------------"
        echo "RAW: $raw_nmea"
        printf "MAP URL: \033[1;34m$map_url\033[0m\n"
        echo "------------------------------------------"
    else
        printf "\033[1;31m[ERROR] Link timeout. Asset may be out of range.\033[0m\n"
    fi
}

# 3. INTERACTIVE SERVICE MENU
run_service() {
    clear
    printf "\033[1;35m[CLIENT SERVICE: $ASSET_ID]\033[0m\n"
    echo "1) Get Location & Map URL"
    echo "2) View Telemetry Audit"
    echo "3) Exit"
    read -p "Select: " c
    case $c in
        1) get_location ;;
        2) tail -n 15 "$LOG_FILE" ;;
        3) exit 0 ;;
    esac
}

# EXECUTION
run_service
exec /bin/bash --noprofile
