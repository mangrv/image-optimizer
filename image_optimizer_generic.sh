#!/bin/bash

INPUT_FOLDER="/input" #add your directory
PROCESSED_FOLDER="/processed" #add your directory
ARCHIVE_FOLDER="/archive" #add your directory
COUNTER=1
WATERMARK_TEXT="Your Watermark Here" # Customize your watermark text here

fswatch -o "$INPUT_FOLDER" | while read
do
  # Create processed and archive directories if they don't exist
  mkdir -p "$PROCESSED_FOLDER"
  mkdir -p "$ARCHIVE_FOLDER"

  # Move old files from input and processed folders to the archive folder
  find "$INPUT_FOLDER" -mindepth 1 -maxdepth 1 -mmin +2 -exec mv {} "$ARCHIVE_FOLDER" \;
  find "$PROCESSED_FOLDER" -mindepth 1 -maxdepth 1 -mmin +2 -exec mv {} "$ARCHIVE_FOLDER" \;

  # Get all files in the input folder, sorted by modification time
  find "$INPUT_FOLDER" -type f -maxdepth 1 | while IFS= read -r FILEPATH
  do
    MODTIME=$(stat -f "%m" "$FILEPATH")
    echo "$MODTIME $FILEPATH"
  done | sort -n | cut -d' ' -f2- | while IFS= read -r SORTED_FILEPATH
  do
    FILENAME=$(basename "$SORTED_FILEPATH")
    EXTENSION="${FILENAME##*.}"
    if [[ $EXTENSION =~ ^(jpg|jpeg|png|tiff|webm|heic)$ ]]; then
      # Format: mmdd+pcpart+counter
      NEW_FILENAME="$(date +%m%d)+pcpart+$COUNTER.jpg" # Changed to .jpg
      convert "$SORTED_FILEPATH" -auto-orient -strip -quality 75 -resize 600x \
              -gravity southeast -pointsize 12 -fill white -annotate +10+10 "$WATERMARK_TEXT" \
              "$PROCESSED_FOLDER/$NEW_FILENAME"
      jpegoptim --max=80 "$PROCESSED_FOLDER/$NEW_FILENAME" # Additional compression with jpegoptim
      let COUNTER=COUNTER+1
    fi
  done
done
