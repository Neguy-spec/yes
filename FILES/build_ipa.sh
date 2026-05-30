#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$SCRIPT_DIR"

echo "Starting build_ipa.sh in $(pwd)"

echo "Repo root is $REPO_ROOT"

mkdir -p output/Payload/rahhh.app

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

swiftc -sdk "$SDK_PATH" \
       -target arm64-apple-ios15.0 \
       -F "$FRAMEWORKS_PATH" \
       -parse-as-library \
       -O -o output/Payload/rahhh.app/rahhh \
       "$SOURCE_FILE"

if [ -f Info.plist ]; then
  cp Info.plist output/Payload/rahhh.app/Info.plist
else
  echo "Info.plist not found in working directory" >&2
  exit 1
fi

cd output
zip -qy1r rahhh_SideStore.ipa Payload
cd ..

if [ -f output/rahhh_SideStore.ipa ]; then
  mv output/rahhh_SideStore.ipa rahhh_SideStore.ipa
  echo "Created $SCRIPT_DIR/rahhh_SideStore.ipa"
else
  echo "IPA not found after zipping" >&2
  exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum rahhh_SideStore.ipa > rahhh_SideStore.ipa.sha256
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 rahhh_SideStore.ipa > rahhh_SideStore.ipa.sha256
elif command -v openssl >/dev/null 2>&1; then
  openssl dgst -sha256 rahhh_SideStore.ipa | awk '{print $2 "  rahhh_SideStore.ipa"}' > rahhh_SideStore.ipa.sha256
else
  echo "No checksum tool available to create rahhh_SideStore.ipa.sha256" >&2
  exit 1
fi

echo "Created checksum file: rahhh_SideStore.ipa.sha256"

if [ -f rahhh_SideStore.ipa ]; then
  cp rahhh_SideStore.ipa "$REPO_ROOT/rahhh_SideStore.ipa" || true
  echo "Copied IPA to repo root: $REPO_ROOT/rahhh_SideStore.ipa"
fi
if [ -f rahhh_SideStore.ipa.sha256 ]; then
  cp rahhh_SideStore.ipa.sha256 "$REPO_ROOT/rahhh_SideStore.ipa.sha256" || true
  echo "Copied checksum to repo root: $REPO_ROOT/rahhh_SideStore.ipa.sha256"
fi

if command -v unzip >/dev/null 2>&1; then
  unzip -t rahhh_SideStore.ipa
else
  echo "unzip not installed; skipping IPA archive validation" >&2
fi

echo "Build finished. Files in script dir:"
ls -la

echo "Repo root listing:"
ls -la "$REPO_ROOT" || true

exit 0
