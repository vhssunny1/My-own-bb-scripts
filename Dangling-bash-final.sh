#!/bin/bash

# Check if the user provided the master list filename as a command line argument
if [ $# -eq 0 ]; then
  echo "Usage: $0 <master_list_filename>"
  exit 1
fi

# Get the master list filename from the command line argument
master_list_filename="$1"

# Command to generate data.txt from the user-supplied master list filename using httpx
cat "$master_list_filename" | httpx -nf -ip -title -sc -cname -silent -tls-grab -tls-probe -csp-probe -title -td > data.txt

# Check if data.txt and excluded_domains.txt exist and are readable
if [ ! -f "data.txt" ]; then
  echo "data.txt does not exist or is not readable"
  exit 1
fi

if [ ! -f "excluded_domains.txt" ]; then
  echo "excluded_domains.txt does not exist or is not readable"
  exit 1
fi

# Read excluded domain names from excluded_domains.txt into an array
excluded_domains=($(<excluded_domains.txt))

# Process each line in data.txt
while IFS= read -r line; do
  # Split the line into two parts using space as the delimiter
  parts=($line)

  # Extract the first part
  part1=${parts[0]}

  # Extract the domain from part1
  domain=$(echo "$part1" | awk -F/ '{print $3}')

  # Extract the top-level domain (TLD) from the domain
  tld=$(echo "$domain" | awk -F. '{print $(NF-1)"."$NF}')

  # Extract the second part
  part2=${parts[@]:1}

  # Initialize flags to check if TLD, excluded domains, and "200" are found in part2
  found_tld=0
  found_excluded_domain=0
  found_200=0

  # Check if TLD is not found in part2
  if [[ ! $part2 == *"$tld"* ]]; then
    found_tld=1
  fi

  # Loop through the excluded domains
  for excluded_domain in "${excluded_domains[@]}"; do
    if [[ $part2 == *"$excluded_domain"* ]]; then
      found_excluded_domain=1
      break
    fi
  done

  # Check if "200" is found in part2
  if [[ $part2 == *"200"* ]]; then
    found_200=1
  fi

  # Check if TLD is not found in part2, no excluded domain is found, and "200" is found
  if [[ $found_tld -eq 1 && $found_excluded_domain -eq 0 && $found_200 -eq 1 ]]; then
    echo "TLD '$tld' Possible DNS - $part2"
    echo $line
  fi

done < "data.txt"
