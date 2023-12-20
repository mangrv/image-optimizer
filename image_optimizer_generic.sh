#!/bin/bash

INPUT_FOLDER="/input" #add your directory
PROCESSED_FOLDER="/processed" #add your directory
ARCHIVE_FOLDER="/archive" #add your directory
COUNTER=1
WATERMARK_ENABLED="yes" # Set to "yes" to enable watermark, "no" to disable
WATERMARK_TEXT="Your Watermark Here" # Customize your watermark text here
RESIZE_ENABLED="no" # Set to "yes" to enable resizing to 800x, "no" to keep original size
ARCHIVE_TIME_LIMIT=1440 # Age in minutes to archive the files, set to a high number to disable
FILENAME_PART="optimized" # Part of the filename
WATERMARK_POSITION="bottom_right_center" # Options: left_center, center_center, right_center, bottom_left_center, bottom_center_center, bottom_right_center

# Function to determine gravity based on position
get_gravity() {
    case "$1" in
        left_center) echo "West";;
        center_center) echo "Center";;
        right_center) echo "East";;
        bottom_left_center) echo "Southwest";;
        bottom_center_center) echo "South";;
        bottom_right_center) echo "Southeast";;
        *) echo "South" # Default to Bottom Center Center if no match
    esac
}

fswatch -o "$INPUT_FOLDER" | while read
do
  # Create processed and archive directories if they don't exist
  mkdir -p "$PROCESSED_FOLDER"
  mkdir -p "$ARCHIVE_FOLDER"

  # Move old files from input and processed folders to the archive folder
  find "$INPUT_FOLDER" -mindepth 1 -maxdepth 1 -mmin +$ARCHIVE_TIME_LIMIT -exec mv {} "$ARCHIVE_FOLDER" \;
  find "$PROCESSED_FOLDER" -mindepth 1 -maxdepth 1 -mmin +$ARCHIVE_TIME_LIMIT -exec mv {} "$ARCHIVE_FOLDER" \;

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
      # Format: mmdd+FILENAME_PART+counter
      NEW_FILENAME="$(date +%m%d)+$FILENAME_PART+$COUNTER.jpg" # Changed to .jpg

      # Apply resizing if enabled
      if [[ $RESIZE_ENABLED == "yes" ]]; then
        RESIZE_COMMAND="-resize 800x"
      else
        RESIZE_COMMAND=""
      fi

      # Apply auto-orientation, stripping, and quality reduction
      convert "$SORTED_FILEPATH" -auto-orient -strip -quality 80 $RESIZE_COMMAND "$PROCESSED_FOLDER/$NEW_FILENAME"

      # Get the image dimensions
      read IMAGE_WIDTH IMAGE_HEIGHT < <(identify -format "%w %h" "$PROCESSED_FOLDER/$NEW_FILENAME")

      # Add watermark if enabled
      if [[ $WATERMARK_ENABLED == "yes" ]]; then
        GRAVITY=$(get_gravity "$WATERMARK_POSITION")
        echo "Watermark gravity is set to: $GRAVITY"  # Debugging line

        # Create a watermark image with the same width as the original image and 40px in height
        convert -size ${IMAGE_WIDTH}x40 xc:none \
                -fill "rgba(0,0,0,0.5)" -draw "rectangle 0,0 ${IMAGE_WIDTH},40" \
                -gravity center -pointsize 24 -fill white \
                -annotate +0+0 "$WATERMARK_TEXT" \
                miff:- |\
        composite -gravity $GRAVITY -geometry +0+0 - "$PROCESSED_FOLDER/$NEW_FILENAME" "$PROCESSED_FOLDER/$NEW_FILENAME"
      fi

      jpegoptim --max=80 "$PROCESSED_FOLDER/$NEW_FILENAME" # Additional compression with jpegoptim
      let COUNTER=COUNTER+1
    fi
  done
done