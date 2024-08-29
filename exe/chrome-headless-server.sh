#!/bin/bash

# Run the command and capture the output
echo "Installing latest stable chrome-headless-shell..."
output=$(npx @puppeteer/browsers install chrome-headless-shell@stable)

# Extract the path from the output
chrome_path=$(echo "$output" | grep "chrome-headless-shell@" | awk '{print $2}')

# Directory you want the relative path from (current working directory)
base_dir=$(pwd)

# Convert absolute path to relative path using Node.js
relative_path=$(node -e "console.log(require('path').relative('$base_dir', '$chrome_path'))")

echo "Launching chrome-headless-shell at $relative_path"
echo $("$chrome_path" --version)
# Launch chrome-headless-shell with the --remote-debugging-port parameter
"$chrome_path" --remote-debugging-port=9222
