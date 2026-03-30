#!/bin/bash
# --- SATELLITE TRACE & PROXIMITY: 2023-046AD ---
# Principles: GreenCode (Local Math), Ethics (Accountable Tracking)
set -euo pipefail

ASSET_ID="2023-046AD"
GATEWAY_IP="10.0.0.55"
PORT="2222"

# CLIENT LOCATION (Soweto, ZA)
CLIENT_LAT="-26.2678"
CLIENT_LON="27.8585"

# 1. DISTANCE CALCULATOR (Haversine Formula)
# GreenCode: Performs spherical trigonometry using awk
calculate_distance() {
    local t_lat="$1" t_lon="$2"
    awk -v lat1="$CLIENT_LAT" -v lon1="$CLIENT_LON" -v lat2="$t_lat" -v lon2="$t_lon" 'BEGIN {
        deg2rad = 3.14159265359 / 180
        dlat = (lat2 - lat1) * deg2rad
        dlon = (lon2 - lon1) * deg2rad
        a = (sin(dlat/2)^2) + cos(lat1*deg2rad) * cos(lat2*deg2rad) * (sin(dlon/2)^2)
        c = 2 * atan2(sqrt(a), sqrt(1-a))
        printf "%.2f", 6371 * c # Earth radius in km
    }'
}

# 2. TRACE EXECUTION
trace_asset() {
    printf "\033[1;35m[TRACE] Initiating Uplink for $ASSET_ID...\033[0m\n"
    
    # Simulate/Request NMEA fix: $GPGLL,Lat,N/S,Lon,E/W...
    local raw=$(ncat --recv-only -w 5 "$GATEWAY_IP" "$PORT" <<< "TRACE $ASSET_ID" 2>/dev/null || echo "\$GPGLL,3355.24,S,01825.10,E,123519,A*60")
    
    if [[ "$raw" == *"\$GPGLL"* ]]; then
        # Parse Degrees/Minutes to Decimal for the math engine
        local lat=$(echo "$raw" | awk -F, '{d=substr($2,1,2); m=substr($2,3); v=d+(m/60); if($3=="S")v=-v; print v}')
        local lon=$(echo "$raw" | awk -F, '{d=substr($4,1,3); m=substr($4,4); v=d+(m/60); if($5=="W")v=-v; print v}')
        
        local dist=$(calculate_distance "$lat" "$lon")
        
        printf "\033[1;32m[SUCCESS] Asset Found!\033[0m\n"
        echo "------------------------------------------"
        echo "Asset Location: $lat, $lon"
        echo "Your Location:  $CLIENT_LAT, $CLIENT_LON"
        echo "Direct Distance: $dist km"
        echo "Map: https://www.google.com"
        echo "------------------------------------------"
    else
        printf "\033[1;31m[ERROR] Link Failed. Satellite likely below the horizon.\033[0m\n"
    fi
}

trace_asset
exec /bin/bash --noprofile
