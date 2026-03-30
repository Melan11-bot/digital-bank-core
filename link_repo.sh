#!/data/data/com.termux/files/usr/bin/bash
clear
echo "🇿🇦 SA SERVICE COMMAND CENTRE: REPO LINKER 🇿🇦"
echo "----------------------------------------------------"
echo "1) CLONE (Download an existing GitHub repo)"
echo "2) CREATE (Start a brand new repo on GitHub)"
echo "3) REMOTE (Link this current folder to GitHub)"
echo "----------------------------------------------------"
read -p "Select Link Method [1-3]: " METHOD

case $METHOD in
  1)
    echo "Fetching your remote repositories..."
    gh repo list --limit 10
    read -p "Enter 'username/repo' to clone: " REPO
    gh repo clone "$REPO"
    ;;
  2)
    read -p "Enter new repository name: " NEW_NAME
    gh repo create "$NEW_NAME" --public --clone
    ;;
  3)
    read -p "Enter the GitHub URL to link to: " GIT_URL
    git init
    git remote add origin "$GIT_URL"
    echo "Linked! Use 'git push -u origin main' to sync."
    ;;
  *)
    echo "Invalid option."
    ;;
esac
