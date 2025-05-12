#!/bin/bash
set -euo pipefail

WORKDIR="$(pwd)/dependencies"
STEAMCMD_DIR="$WORKDIR/steamcmd"
INSTALL_DIR="$WORKDIR/resonite"

mkdir -p "$STEAMCMD_DIR" "$INSTALL_DIR"

# Download and extract SteamCMD if not present
if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
  echo "Downloading SteamCMD..."
  curl -sL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar -xz -C "$STEAMCMD_DIR"
fi

# Run SteamCMD with login and beta credentials
echo "Running SteamCMD to download Resonite Headless..."

# check if the user provided Steam credentials
if [ -z "${STEAM_USER:-}" ] || [ -z "${STEAM_PASS:-}" ] || [ -z "${RESONITE_HEADLESS_KEY:-}" ]; then
    echo "Please set STEAM_USER, STEAM_PASS, and RESONITE_HEADLESS_KEY environment variables."
    exit 1
fi
"$STEAMCMD_DIR/steamcmd.sh" +force_install_dir "$INSTALL_DIR" \
    +login ${STEAM_USER} ${STEAM_PASS} \
    +app_license_request 2519830 +app_update 2519830 \
    -beta headless -betapassword ${RESONITE_HEADLESS_KEY} \
    validate +quit

echo "✅ Resonite Headless downloaded to: $INSTALL_DIR"
