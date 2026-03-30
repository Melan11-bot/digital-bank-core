#!/bin/bash
# --- SANSA GROUND STATION SELECTOR ---
# Principles: GreenCode (Conditional logic), Ethics (Site Transparency)
set -euo pipefail

# 1. STATION DATABASE
# Lat/Lon for SANSA facilities
HBK_LAT="-25.8872"; HBK_LON="27.7077" # Hartebeesthoek
MTJ_LAT="-33.2323"; MTJ_LON="20.5847" # Matjiesfontein
HER_LAT="-34.4233"; HER_LON="19.2342" # Hermanus

# 2. SELECTOR INTERFACE
select_station() {
    clear
    printf "\033[1;35m[SANSA SERVICE GATEWAY]\033[0m\n"
    echo "Choose an active SANSA Ground Station:"
    echo "1) Hartebeesthoek (HBK) - LEO/Satellite Ops"
    echo "2) Matjiesfontein (MTJ) - Deep Space/NASA LEGS"
    echo "3) Hermanus (HER)      - Space Weather/Magnetic"
    read -p "Select [1-3]: " choice

    case $choice in
        1) SITE="HBK"; SLAT=$HBK_LAT; SLON=$HBK_LON ;;
        2) SITE="MTJ"; SLAT=$MTJ_LAT; SLON=$MTJ_LON ;;
        3) SITE="HER"; SLAT=$HER_LAT; SLON=$HER_LON ;;
        *) echo "Invalid selection"; exit 1 ;;
    esac

    printf "\033[1;32m[LOADED] $SITE Ground Station Active.\033[0m\n"
    echo "LINKING: ./satellite_radar.sh --site $SITE --coords $SLAT,$SLON"
}

# 3. EXECUTION
select_station
echo "------------------------------------------"
echo "[ACTION] Update your satellite_radar.sh MY_LAT/MY_LON"
echo "to match the selected SANSA station coordinates."
echo "------------------------------------------"

exec /bin/bash --noprofile
