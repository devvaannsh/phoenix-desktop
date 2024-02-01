#!/bin/bash
# Define common variables
APPIMAGE_DIR=$HOME/.local/bin
DESKTOP_DIR=$HOME/.local/share/applications
NEW_APPIMAGE=phcode.AppImage
ICON=phoenix_icon.png
GITHUB_REPO="charlypa/phoenix-desktop"
API_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

install() {
    # Fetch the latest release data from GitHub
    echo "Fetching latest release from $GITHUB_REPO..."
    wget -qO- $API_URL > latest_release.json

    # Extract the download URL for the AppImage
    APPIMAGE_URL=$(grep -oP '"browser_download_url": "\K(.*phoenix-desktop.*\.AppImage)(?=")' latest_release.json)

    # If no AppImage URL is found, exit the script
    if [ -z "$APPIMAGE_URL" ]; then
        echo "No AppImage URL found in the latest release."
        rm latest_release.json
        exit 1
    fi

    # Download the AppImage
    echo "Downloading AppImage from $APPIMAGE_URL..."
    wget -qO $NEW_APPIMAGE $APPIMAGE_URL

    # Remove the temporary JSON file
    rm latest_release.json

    # Proceed with installation steps as before...
    # Create necessary directories
    mkdir -p $APPIMAGE_DIR
    mkdir -p $DESKTOP_DIR

    # Copy and rename the AppImage, and copy the icon to the AppImage directory
    echo "Installing Phoenix..."
    mv $NEW_APPIMAGE $APPIMAGE_DIR/$NEW_APPIMAGE
    cp "$ICON" $APPIMAGE_DIR  # Ensure this icon file is in the current directory

    # Make the new AppImage executable
    chmod +x $APPIMAGE_DIR/$NEW_APPIMAGE
    # Define the directory to store the AppImage
    # Get the directory where the script is located
    # Find the first AppImage file in the script's directory with the 'phoenix-code' prefix
    APPIMAGE=$(find "$SCRIPT_DIR" -maxdepth 1 -name 'phoenix-code*.AppImage' -print -quit)

    # If no AppImage file is found, exit the script
    if [ -z "$APPIMAGE" ]; then
        echo "No 'phoenix-code' AppImage file found in the script directory."
        exit 1
    fi

    # Extract filename from the full path
    APPIMAGE_NAME=$(basename "$APPIMAGE")
    ICON=phoenix_icon.png # Ensure this icon file is in the script's directory

    # Create the AppImage directory if it doesn't exist
    mkdir -p $APPIMAGE_DIR

    # Create the applications directory if it doesn't exist
    mkdir -p $DESKTOP_DIR

    # Copy and rename the AppImage, and copy the icon to the AppImage directory
    echo "Installing Phoenix..."
    cp "$APPIMAGE" $APPIMAGE_DIR/$NEW_APPIMAGE
    cp "$SCRIPT_DIR/$ICON" $APPIMAGE_DIR

    # Make the new AppImage executable
    chmod +x $APPIMAGE_DIR/$NEW_APPIMAGE

    # Define MIME types for file extensions
    MIME_TYPES="text/html;application/atom+xml;application/x-coldfusion;text/x-clojure;text/coffeescript;application/json;text/css;text/html;text/x-diff;text/jsx;text/markdown;application/mathml+xml;application/rdf+xml;application/rss+xml;text/css;application/sql;image/svg+xml;text/html;text/x-python;application/xml;application/vnd.mozilla.xul+xml;application/x-yaml;text/typescript;"

    # Add directory association
    MIME_TYPES+="inode/directory;"

    # Create a desktop entry for the AppImage with MIME type associations
cat > $DESKTOP_DIR/PhoenixCode.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Phoenix Code
Exec=$APPIMAGE_DIR/$NEW_APPIMAGE %F
Icon=$APPIMAGE_DIR/$ICON
Terminal=false
MimeType=$MIME_TYPES
EOF

    # Update the desktop database for GNOME, Unity, XFCE, etc.
    if command -v update-desktop-database &> /dev/null
    then
        update-desktop-database $DESKTOP_DIR
    fi

    # Update the KDE desktop database if KDE is in use
    if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
        if command -v kbuildsycoca5 &> /dev/null
        then
            kbuildsycoca5
        fi
    fi

    echo "Phoenix Code installed successfully."
}

uninstall() {
    # Remove the AppImage and the icon
    echo "Uninstalling Phoenix..."
    rm -f $APPIMAGE_DIR/$NEW_APPIMAGE
    rm -f $APPIMAGE_DIR/$ICON

    # Remove the desktop entry
    rm -f $DESKTOP_DIR/PhoenixCode.desktop

    # Update the desktop database for GNOME, Unity, XFCE, etc. (if available)
    if command -v update-desktop-database &> /dev/null
    then
        update-desktop-database $DESKTOP_DIR
    fi

    # Update the KDE desktop database if KDE is in use
    if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
        if command -v kbuildsycoca5 &> /dev/null
        then
            kbuildsycoca5
        fi
    fi

    echo "Phoenix uninstalled successfully."
}

# Check for command-line arguments
if [[ "$1" == "--uninstall" ]]; then
    uninstall
else
    install
fi