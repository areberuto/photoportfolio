#!/bin/bash

# Interactive and safe JPG renamer to photo1.jpg, photo2.jpg, etc.
# Ensures proper overwriting even if photo*.jpg already exists in the directory.

# Function to show usage
usage() {
    echo "Usage: $0 [directory_path]"
    echo "If no directory is specified, uses the current directory."
    exit 1
}

# Set target directory
target_dir="${1:-.}"

# Validate directory
if [[ ! -d "$target_dir" ]]; then
    echo "Error: Directory '$target_dir' does not exist."
    usage
fi

# Change to target directory
cd "$target_dir" || { echo "Error: Cannot access '$target_dir'"; exit 1; }

echo "Working in: $(pwd)"

# Gather all JPG/JPEG files (case-insensitive), sorted
mapfile -d '' files < <(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 | sort -z)

total_files=${#files[@]}

if [[ $total_files -eq 0 ]]; then
    echo "No JPG or JPEG files found."
    exit 0
fi

# Show rename plan
echo
echo "Found $total_files JPG/JPEG files. Preview of renaming:"
counter=1
for file in "${files[@]}"; do
    base="$(basename "$file")"
    echo "  $base -> photo${counter}.jpg"
    ((counter++))
done

echo
read -p "Proceed with renaming and overwriting existing photo*.jpg files if needed? (y/n): " confirm
if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Create temp staging directory
tmp_dir=$(mktemp -d)

# First, move all files to the staging dir and rename
counter=1
for file in "${files[@]}"; do
    new_name="photo${counter}.jpg"
    cp -- "$file" "$tmp_dir/$new_name"
    ((counter++))
done

# Remove original files (ONLY the ones we are renaming!)
for file in "${files[@]}"; do
    rm -f -- "$file"
done

# Move renamed files back from temp (overwrite allowed)
mv -f "$tmp_dir"/* ./
rmdir "$tmp_dir"

echo
echo "Renaming complete. Total files renamed: $((counter - 1))"
