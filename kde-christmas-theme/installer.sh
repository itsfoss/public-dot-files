#!/bin/bash

# This script downloads and installs the Christmas theme files for Konsole and KDE color schemes.

# Create target directories if they don't already exist
mkdir -p ~/.local/share/konsole
mkdir -p ~/.local/share/color-schemes

# Define the base URL for the raw files on GitHub
BASE_URL="https://raw.githubusercontent.com/itsfoss/public-dot-files/main/kde-christmas-theme"

# Download the files using curl
echo "Downloading Christmas theme files..."
curl -L -o ~/.local/share/konsole/Christmas.profile "$BASE_URL/Christmas.profile"
curl -L -o ~/.local/share/konsole/ChristmasColorScheme.colorscheme "$BASE_URL/ChristmasColorScheme.colorscheme"
curl -L -o ~/.local/share/color-schemes/ChristmasColors.colors "$BASE_URL/ChristmasColors.colors"

echo "Installation complete!"
echo "Please restart Konsole and your applications to see the new theme and colors."
