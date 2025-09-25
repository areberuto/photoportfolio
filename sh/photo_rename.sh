#!/bin/bash

# Script to rename JPG files to ph1.jpg, ph2.jpg, ph3.jpg, etc. (safer version)

# Function to display usage
usage() {
    echo "Usage: $0 [directory_path]"
    echo "If no directory is specified, uses current directory"
    exit 1
}

# Set directory (default to current if not specified)
target_dir="${1:-.}"

# Check if directory exists
if [[ ! -d "$target_dir" ]]; then
    echo "Error: Directory '$target_dir' does not exist."
    usage
fi

# Change to target directory
cd "$target_dir" || { echo "Error: Cannot access directory '$target_dir'"; exit 1; }

echo "Working directory: $(pwd)"
echo "JPG files found: $(find . -maxdepth 1 -type f -iname "*.jpg" | wc -l)"

# Safety check - look for existing ph*.jpg files
existing_ph_files=$(find . -maxdepth 1 -type f -iname "photo*.jpg" | wc -l)
if [[ $existing_ph_files -gt 0 ]]; then
    read -p "WARNING: Found $existing_ph_files existing photo*.jpg files. Continue? (y/n): " confirm
    if [[ $confirm != [yY] ]]; then
        echo "Operation cancelled."
        exit 1
    fi
fi

# Confirm with user
read -p "Proceed with renaming ALL JPG files in this directory? (y/n): " confirm

if [[ $confirm != [yY] ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Counter for numbering
counter=1

# Loop through all JPG files (case insensitive, sorted by name)
while IFS= read -r -d '' file; do
    # Generate new filename
    new_name="photo${counter}.jpg"
    
    # Check if target file already exists
    if [[ -f "$new_name" ]]; then
        echo "WARNING: $new_name already exists. Skipping $file"
        continue
    fi
    
    # Rename the file
    mv -- "$file" "$new_name"
    
    echo "Renamed: $(basename "$file") -> $new_name"
    
    # Increment counter
    ((counter++))
    
done < <(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 | sort -z)

echo "Renaming complete! Total files renamed: $((counter-1))"