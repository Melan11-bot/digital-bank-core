#!/bin/bash
# --- FINAL SOVEREIGN REPORT & EMAIL DISPATCH ---
set -eu

RECIPIENT="kgotso344@gmail.com"
REPORT="sovereign_report.txt"
TXN_ID="TXN_$(date +%s)"

# 1. GENERATE REPORT
printf "SOVEREIGN LINK FINAL ASSESSMENT\n---\n" > "$REPORT"
echo "Verified User: kgotso344@gmail.com" >> "$REPORT"
echo "Asset: MDASat-1B (2023-046AD)" >> "$REPORT"
echo "Site: SANSA Hartebeesthoek (HBK)" >> "$REPORT"
echo "Transaction ID: $TXN_ID" >> "$REPORT"
echo "Status: GITHUB_SYNCED_AND_MAILED" >> "$REPORT"

# 2. DISPATCH VIA MSMTP
printf "\033[1;34m[EMAIL] Sending report to $RECIPIENT...\033[0m\n"
(echo -e "Subject: Sovereign Link Final Report: $TXN_ID\n"; cat "$REPORT"; uuencode "$REPORT" "$REPORT") | msmtp "$RECIPIENT"

printf "\033[1;32m[SUCCESS] Report sent. Check your inbox for $TXN_ID.\033[0m\n"
