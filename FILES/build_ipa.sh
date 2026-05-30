#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$SCRIPT_DIR"

echo "Starting build_ipa.sh in $(pwd)"
echo "Repo root is $REPO_ROOT"

APP_NAME="rahhhhhh"
IPA_NAME="rahhhhhh_Nightly.ipa"

mkdir -p output/Payload/${APP_NAME}.app

SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path 2>/dev/null || true)
if [ -z "$SDK_PATH" ]; then
  echo "xcrun not available or Xcode not installed. Exiting." >&2
  exit 1
fi

FRAMEWORKS_PATH="$SDK_PATH/System/Library/Frameworks"
echo "SDK_PATH=$SDK_PATH"

SOURCE_FILE="rahhh.swift"
if [ ! -f "$SOURCE_FILE" ]; then
  echo "Source file $SOURCE_FILE not found in working directory $(pwd)" >&2
  ls -la
  exit 1
fi

# Compile binary named rahhhhhh
swiftc -sdk "$SDK_PATH" \
       -target arm64-apple-ios15.0 \
       -F "$FRAMEWORKS_PATH" \
       -parse-as-library \
       -O -o output/Payload/${APP_NAME}.app/${APP_NAME} \
       "$SOURCE_FILE"

# Copy Info.plist
if [ -f Info.plist ]; then
  cp Info.plist output/Payload/${APP_NAME}.app/Info.plist
else
  echo "Info.plist not found in working directory" >&2
  exit 1
fi

# Package IPA
cd output
zip -qy1r "$IPA_NAME" Payload
cd ..

# Move IPA to script directory
if [ -f output/"$IPA_NAME" ]; then
  mv output/"$IPA_NAME" "$IPA_NAME"
  echo "Created $SCRIPT_DIR/$IPA_NAME"
else
  echo "IPA not found after zipping" >&2
  exit 1
fi

# Create checksum
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$IPA_NAME" > "$IPA_NAME".sha256
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$IPA_NAME" > "$IPA_NAME".sha256
elif command -v openssl >/dev/null 2>&1; then
  openssl dgst -sha256 "$IPA_NAME" | awk '{print $2 "  '"$IPA_NAME"'"}' > "$IPA_NAME".sha256
else
  echo "No checksum tool available" >&2
  exit 1
fi

echo "Created checksum file: $IPA_NAME.sha256"

# Copy to repo root
cp "$IPA_NAME" "$REPO_ROOT/$IPA_NAME" || true
cp "$IPA_NAME.sha256" "$REPO_ROOT/$IPA_NAME.sha256" || true

# Validate IPA
if command -v unzip >/dev/null 2>&1; then
  unzip -t "$IPA_NAME"
else
  echo "unzip not installed; skipping IPA validation" >&2
fi

echo "Build finished. Files in script dir:"
ls -la

echo "Repo root listing:"
ls -la "$REPO_ROOT" || true

exit 0
