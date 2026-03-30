#!/data/data/com.termux/files/usr/bin/bash

# 1. Setup Environment
pkg install proot termux-services findutils -y > /dev/null 2>&1

# 2. Find the newest GitHub folder
PROJ_DIR=$(ls -td */ 2>/dev/null | grep -v "sandbox" | grep -v "workstation" | head -n 1 | cut -d'/' -f1)

# 3. Create the Workstation Folder
ID=$(date +%s)
SB_DIR="workstation_$ID"

if [ -z "$PROJ_DIR" ]; then
    echo "❌ Error: No GitHub project found in home directory."
    echo "👉 Please run 'gh repo clone <your-repo>' first."
    exit 1
fi

echo "🛠️ Creating Workstation: $SB_DIR from $PROJ_DIR"
mkdir -p "$SB_DIR"
cp -r "$PROJ_DIR/." "$SB_DIR/"

# 4. Enter the Workstation
if [ -d "$SB_DIR" ]; then
    cd "$SB_DIR"
else
    echo "❌ Critical Error: Could not create $SB_DIR"
    exit 1
fi

clear
echo "===================================================="
echo "   🇿🇦 SOUTH AFRICAN SERVICE COMMAND CENTRE 🇿🇦   "
echo "===================================================="
echo " STATUS: ACTIVE | FOLDER: $SB_DIR"
echo "----------------------------------------------------"

# 5. Search for Runnable Scripts
echo "[🔍 RUNNABLE FILES FOUND]"
RUNNABLES=$(find . -maxdepth 2 -type f \( -name "*.sh" -o -name "*.py" -o -executable \) | sed 's|^\./||')

if [ -z "$RUNNABLES" ]; then
    echo "No scripts found. Add some .sh or .py files to your repo."
else
    echo "$RUNNABLES"
fi

echo "----------------------------------------------------"
echo "1) Run All Scripts (Deep Restore)"
echo "2) Exit"
read -p "Selection: " OPT

if [ "$OPT" == "1" ]; then
    for SCRIPT in $RUNNABLES; do
        chmod +x "$SCRIPT"
        echo "🚀 Launching $SCRIPT..."
        proot -0 -r . -b /dev -b /proc -b /sys /usr/bin/env -i \
        HOME=/root PATH=$PATH:/usr/bin:/bin TERM=$TERM bash -c "./$SCRIPT"
    done
fi
