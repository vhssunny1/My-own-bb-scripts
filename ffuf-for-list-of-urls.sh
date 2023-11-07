#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <target> <wordlist>"
  exit 1
fi

target="$1"
wordlist="$2"

# Function to create a safe filename from the URL
sanitize_url() {
  echo "$1" | sed -e 's|https\?://||' -e 's/[^A-Za-z0-9_.-]/_/g'
}

# Ensure the target and wordlist files exist
if [ ! -f "$target" ]; then
  echo "Target file '$target' does not exist."
  exit 1
fi

if [ ! -f "$wordlist" ]; then
  echo "Wordlist file '$wordlist' does not exist."
  exit 1
fi

# Loop through the URLs in the target file
while read -r url; do
  sanitized_url=$(sanitize_url "$url")
  output_file="dir-${sanitized_url}.txt"

  # Use ffuf with improved options
  ffuf -w "$wordlist" -u "$url/FUZZ" -c -mc 200-299 | tee "./$output_file"
done < "$target"
