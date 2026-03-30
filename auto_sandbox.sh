#!/data/data/com.termux/files/usr/bin/bash

# 1. Setup & Tools
pkg install proot findutils gh git -y > /dev/null 2>&1

# 2. Auto-Detect newest project (excluding sandboxes)
PROJ_DIR=$(ls -td */ 2>/dev/null | grep -v "sandbox" | head -n 1 | cut -d'/' -f1)

if [ -z "$PROJ_DIR" ]; then
    echo "❌ Error: No project folder found. Please 'gh repo clone' first."
    exit 1
fi

# 3. Create Numbered Sandbox
ID=$(date +%s)
SB_DIR="sandbox_$ID"
echo "🛠️ Creating Sandbox: $SB_DIR from $PROJ_DIR"
cp -r "$PROJ_DIR/." "$SB_DIR/"
cd "$SB_DIR"

# 4. Deep Search & Execute All
echo "🔍 Searching for runnable files..."
RUNNABLES=$(find . -maxdepth 2 -type f \( -name "*.sh" -o -name "*.py" -o -executable \) | sed 's|^\./||')

for SCRIPT in $RUNNABLES; do
    echo "------------------------------------------"
    echo "🚀 RUNNING: $SCRIPT"
    chmod +x "$SCRIPT"
    # Execute in Deep Restore (Fake Root) environment
    proot -0 -r . -b /dev -b /proc -b /sys /usr/bin/env -i \
        HOME=/root PATH=$PATH:/usr/bin:/bin TERM=$TERM bash -c "./$SCRIPT"
done

echo "------------------------------------------"
echo "✅ All tasks finished in $SB_DIR"
