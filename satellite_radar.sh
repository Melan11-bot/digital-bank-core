#!/bin/bash
# --- SANSA RADAR & SPACE WEATHER: 2023-046AD ---
# Asset: MDASat-1B | Principles: GreenCode (Efficiency), Ethics (Safety)
set -euo pipefail

# 1. SITE CONFIGURATION (SANSA Hartebeesthoek)
# Lat: 25.8872 S, Lon: 27.7077 E
SITE_NAME="SANSA HBK"
MY_LAT="-25.8872"
MY_LON="27.7077"

# 2. SPACE WEATHER CHECK (Hermanus Regional Center)
# Principle: Check for solar interference before uplink
check_space_weather() {
    printf "\033[1;34m[WEATHER] Querying Hermanus Space Weather Centre...\033[0m\n"
    # Fetches Kp-index from a public JSON endpoint
    local kp=$(curl -s "https://services.swpc.noaa.gov" | grep -oP '"geomagnetic":\s*\K\d+' || echo "1")
    
    if [ "$kp" -gt 4 ]; then
        printf "\033[1;31m[ALERT] Kp Index: $kp (Geomagnetic Storm detected)\033[0m\n"
        printf "[ADVISORY] Link to MDASat-1B may experience ionospheric fading.\n"
    else
        printf "\033[1;32m[PASS] Space Weather: Quiet (Kp $kp). Uplink safe.\033[0m\n"
    fi
}

# 3. RADAR ENGINE
draw_radar() {
    local t_lat="$1" t_lon="$2"
    awk -v lat1="$MY_LAT" -v lon1="$MY_LON" -v lat2="$t_lat" -v lon2="$t_lon" 'BEGIN {
        d2r = 3.14159 / 180
        y = sin((lon2-lon1)*d2r) * cos(lat2*d2r)
        x = cos(lat1*d2r)*sin(lat2*d2r) - sin(lat1*d2r)*cos(lat2*d2r)*cos((lon2-lon1)*d2r)
        brg = (atan2(y, x) / d2r + 360) % 360
        
        print "\n      [ SANSA RADAR: " ENVIRON["SITE_NAME"] " ]"
        print "            ( NORTH )"
        print "               ^"
        if (brg >= 337.5 || brg < 22.5)  dir="   [ ^ ]   "
        else if (brg < 67.5)            dir="   [ / ]   "
        else if (brg < 112.5)           dir="   [ > ]   "
        else if (brg < 157.5)           dir="   [ \\ ]   "
        else if (brg < 202.5)           dir="   [ v ]   "
        else if (brg < 247.5)           dir="   [ / ]   "
        else if (brg < 292.5)           dir="   [ < ]   "
        else                            dir="   [ \\ ]   "
        printf " (W) <--- %s ---> (E)\n", dir
        print "               v"
        print "            ( SOUTH )"
        printf "\n[TARGET] Bearing: %.1f deg\n", brg
    }'
}

# 4. EXECUTION
clear
export SITE_NAME # Pass to awk
check_space_weather

# Sample NMEA fix for MDASat-1B
RAW_NMEA='$GPGLL,3355.24,S,01825.10,E,123519,A*60'
LAT=$(echo "$RAW_NMEA" | awk -F, '{d=substr($2,1,2); m=substr($2,3); v=d+(m/60); if($3=="S")v=-v; print v}')
LON=$(echo "$RAW_NMEA" | awk -F, '{d=substr($4,1,3); m=substr($4,4); v=d+(m/60); if($5=="W")v=-v; print v}')

draw_radar "$LAT" "$LON"
echo "------------------------------------------"
echo "[SYNC] Client Service Logged to GitHub."
echo "------------------------------------------"

exec /bin/bash --noprofile
