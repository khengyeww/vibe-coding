#!/bin/bash

target_dir="."
zip_name="test.zip"
script_name=$(basename "$0")

# Delete existing zip if it exists
if [ -f "$zip_name" ]; then
  echo "Removing existing $zip_name"
  rm "$zip_name"
fi

# When zip, EXCLUDE hidden files (except for .env*) and following files/folders
find "$target_dir" \
  \( -path "*/.*" ! -name ".env*" \) -prune -o \
  -type f \
  ! -name ".DS_Store" \
  ! -path "*/__MACOSX/*" \
  ! -name "$script_name" \
  ! -name "bun.lock" \
  ! -name "jest.config.js" \
  ! -path "*/mock/*" \
  ! -path "*/node_modules/*" \
  ! -path "*/tests/*" \
  -print | zip -q "$zip_name" -@

# Simpler alternative
# zip -r "zip_name" "$target_dir" -x "*.DS_Store" -x "__MACOSX"
