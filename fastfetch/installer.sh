#!/bin/bash

# Fastfetch Theme Installer
# Fetches themes from the itsfoss/public-dot-files repository and installs them.
# Can be run directly via: curl -sSL <URL> | bash

# --- Configuration ---
REPO_OWNER="itsfoss"
REPO_NAME="public-dot-files"
REPO_BRANCH="main"
REPO_ZIP_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${REPO_BRANCH}.zip"

# --- Colors for Output ---
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Cleanup Function ---
# Ensures the temporary directory is removed on exit
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        echo "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# --- Dependency Check ---
# Checks for curl and unzip
check_deps() {
    local missing_deps=0
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: 'curl' is not installed. Please install it to continue.${NC}"
        missing_deps=1
    fi
    if ! command -v unzip &> /dev/null; then
        echo -e "${RED}Error: 'unzip' is not installed. Please install it to continue.${NC}"
        missing_deps=1
    fi
    if [ "$missing_deps" -eq 1 ]; then
        exit 1
    fi
}

# --- Terminal Check ---
# Warns users on terminals that may not render images well
perform_terminal_check() {
    local fallback_terminals=("gnome-terminal" "konsole" "xterm" "terminator")
    local current_terminal_name=""

    if [ -n "$GNOME_TERMINAL_SCREEN" ]; then
        current_terminal_name="gnome-terminal"
    elif [ -n "$KONSOLE_VERSION" ]; then
        current_terminal_name="konsole"
    fi

    if [ -n "$current_terminal_name" ]; then
        echo -e "${YELLOW}Warning:${NC} Your terminal ($current_terminal_name) might not display images from fastfetch correctly."
        echo "For the best experience with image support, consider using Kitty, Ghostty, or another compatible terminal."

        while true; do
            read -p "Do you want to continue anyway? (y/n): " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) echo "Aborting."; exit 0;;
                * ) echo "Invalid input. Please answer y or n.";;
            esac
        done
    fi
}

# --- Main Logic ---
main() {
    check_deps
    perform_terminal_check

    # Create a temporary directory for the download
    TEMP_DIR=$(mktemp -d)
    if [ -z "$TEMP_DIR" ]; then
        echo -e "${RED}Error: Could not create a temporary directory.${NC}"
        exit 1
    fi

    echo "Downloading repository information..."
    if ! curl -sL "$REPO_ZIP_URL" -o "$TEMP_DIR/repo.zip"; then
        echo -e "${RED}Error: Failed to download repository from GitHub.${NC}"
        exit 1
    fi

    echo "Extracting files..."
    if ! unzip -q "$TEMP_DIR/repo.zip" -d "$TEMP_DIR"; then
        echo -e "${RED}Error: Failed to unzip the repository archive.${NC}"
        exit 1
    fi

    local source_dir="$TEMP_DIR/${REPO_NAME}-${REPO_BRANCH}/fastfetch"
    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}Error: Could not find the 'fastfetch' directory in the downloaded archive.${NC}"
        exit 1
    fi

    # --- Theme Selection ---
    echo "Please select a fastfetch theme to install:"
        local files=("$source_dir"/*.jsonc)

        # Gracefully exit if no .jsonc files are found
        if [ ! -f "${files[0]}" ]; then
            echo -e "${RED}Error: No '.jsonc' theme files were found in the repository.${NC}"
            exit 1
        fi

        local options=()    for file in "${files[@]}"; do
        local pretty_name=$(basename "$file" .jsonc | sed -e 's/_/ /g' -e 's/\b\(.\)/\u\1/g')
        options+=("$pretty_name")
    done

    select choice in "${options[@]}"; do
        if [[ -n $choice ]]; then
            for i in "${!options[@]}"; do
                if [[ "${options[$i]}" = "$choice" ]]; then
                    selected_file="${files[$i]}"
                    break
                fi
            done
            echo "You chose: $choice"
            break
        else
            echo -e "${RED}Invalid selection. Please try again.${NC}"
        fi
    done

    # --- Backup and Installation ---
    local config_dir="$HOME/.config/fastfetch"
    echo "Ensuring config directory exists at $config_dir..."
    mkdir -p "$config_dir"

    local config_file="$config_dir/config.jsonc"
    if [ -f "$config_file" ]; then
        echo "Backing up existing config to $config_file.bak..."
        mv "$config_file" "$config_file.bak"
    fi

    echo "Installing '$choice' theme..."
    cp "$selected_file" "$config_file"

    local assets_dir="$source_dir/assets"
    if [ -d "$assets_dir" ]; then
        echo "Copying assets..."
        cp -r "$assets_dir" "$config_dir/"
    fi

    echo -e "${GREEN}Installation complete!${NC}"
    echo "Run 'fastfetch' to see your new theme."
}

# Run the main function
main
