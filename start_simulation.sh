#!/data/data/com.termux/files/usr/bin/bash

# 1. Detect the project folder (with your 15 files)
PROJ_DIR=$(ls -td */ 2>/dev/null | grep -v "sandbox" | grep -v "workstation" | head -n 1 | cut -d'/' -f1)

if [ -z "$PROJ_DIR" ]; then
    echo "❌ No project folder found. Please clone your repo first!"
    exit 1
fi

# 2. Create the Numbered Sandbox
ID=$(date +%s)
SB_DIR="sandbox_$ID"
echo "📦 Moving 15+ files from [$PROJ_DIR] to Live Sandbox [$SB_DIR]..."
mkdir -p "$SB_DIR"
cp -r "$PROJ_DIR/." "$SB_DIR/"
cd "$SB_DIR"

# 3. SA Command Centre Dashboard
clear
echo "===================================================="
echo "   🇿🇦 LIVE SANDBOX SIMULATION: $ID   "
echo "===================================================="
echo "📂 FILES DETECTED:"
ls -F --color=auto
echo "----------------------------------------------------"

# 4. Deep Search for Runnable Scripts
RUNNABLES=$(find . -maxdepth 2 -type f \( -name "*.sh" -o -name "*.py" -o -executable \) | sed 's|^\./||')

if [ -z "$RUNNABLES" ]; then
    echo "⚠️ No runnable scripts (.sh or .py) found among the 15 files."
else
    echo "🚀 SCRIPTS READY TO RUN:"
    echo "$RUNNABLES"
    echo "----------------------------------------------------"
    read -p "Run all scripts in Deep Restore mode? (y/n): " RUN_ALL
    
    if [ "$RUN_ALL" == "y" ]; then
        for SCRIPT in $RUNNABLES; do
            echo ">>> Executing $SCRIPT..."
            chmod +x "$SCRIPT"
            # Isolated Proot Execution
            proot -0 -r . -b /dev -b /proc -b /sys /usr/bin/env -i \
            HOME=/root PATH=$PATH:/usr/bin:/bin TERM=$TERM bash -c "./$SCRIPT"
            echo ">>> $SCRIPT Finished."
            echo "----------------------------------------------------"
        done
    fi
fi

echo "✅ Simulation sequence complete."
echo "Your files are safe in: $SB_DIR"
