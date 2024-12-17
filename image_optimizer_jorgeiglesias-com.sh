#!/bin/bash

# Configuration Variables
INPUT_FOLDER="/Users/cmdnotfound/Documents/inventoryImages/input"
PROCESSED_FOLDER="/Users/cmdnotfound/Documents/inventoryImages/processed"
ARCHIVE_FOLDER="/Users/cmdnotfound/Documents/inventoryImages/archive"
COUNTER=1
WATERMARK_ENABLED="yes" # Set to "yes" to enable watermark, "no" to disable
WATERMARK_TYPE="text" # Options: "text" or "image"
WATERMARK_TEXT="cmdnotfound.com" # Customize your watermark text here
WATERMARK_IMAGE_PATH="/Users/cmdnotfound/Documents/inventoryImages/watermarks/watermark.png" # Path to your watermark image
WATERMARK_OPACITY="50%" # Set watermark transparency (e.g., 50%)
WATERMARK_POSITION="right_center" # Options: left_center, center_center, right_center, etc.
WATERMARK_SCALE="0.75" # Scale of watermark relative to the image (0.5 for half, 0.25 for a quarter, 0.75 for three quarters)
RESIZE_ENABLED="no" # Set to "yes" to enable resizing to 800x, "no" to keep original size
ARCHIVE_TIME_LIMIT=2 # Age in minutes to archive the files
FILENAME_PART="cmdnotfound" # Part of the filename

# Function to determine gravity based on position
get_gravity() {
    case "$1" in
        left_center) echo "West";;
        center_center) echo "Center";;
        right_center) echo "East";;
        bottom_left_center) echo "Southwest";;
        bottom_center_center) echo "South";;
        bottom_right_center) echo "Southeast";;
        *) echo "Center" # Default to center if no match
    esac
}

# Start the watch loop
fswatch -o "$INPUT_FOLDER" | while read
do
  # Create processed and archive directories if they don't exist
  mkdir -p "$PROCESSED_FOLDER"
  mkdir -p "$ARCHIVE_FOLDER"

  # Move old files to the archive folder
  find "$INPUT_FOLDER" -mindepth 1 -maxdepth 1 -mmin +$ARCHIVE_TIME_LIMIT -exec mv {} "$ARCHIVE_FOLDER" \;
  find "$PROCESSED_FOLDER" -mindepth 1 -maxdepth 1 -mmin +$ARCHIVE_TIME_LIMIT -exec mv {} "$ARCHIVE_FOLDER" \;

  # Process new files
  find "$INPUT_FOLDER" -type f -maxdepth 1 | while IFS= read -r FILEPATH
  do
    MODTIME=$(stat -f "%m" "$FILEPATH")
    echo "$MODTIME $FILEPATH"
  done | sort -n | cut -d' ' -f2- | while IFS= read -r SORTED_FILEPATH
  do
    FILENAME=$(basename "$SORTED_FILEPATH")
    EXTENSION="${FILENAME##*.}"
    if [[ $EXTENSION =~ ^(jpg|jpeg|png|tiff|webm|heic)$ ]]; then
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
        
        if [[ $WATERMARK_TYPE == "image" ]]; then
          # Calculate watermark dimensions
          MAX_DIM=$(echo "$IMAGE_WIDTH * $WATERMARK_SCALE" | bc)

          # Resize the watermark image while maintaining aspect ratio
          TEMP_WATERMARK="/tmp/temp_watermark.png"
          convert "$WATERMARK_IMAGE_PATH" -resize ${MAX_DIM}x${MAX_DIM} \
                  "$TEMP_WATERMARK"

          # Apply the watermark with 50% transparency
          composite -dissolve 50% -gravity $GRAVITY -geometry +0+0 \
                    "$TEMP_WATERMARK" "$PROCESSED_FOLDER/$NEW_FILENAME" \
                    "$PROCESSED_FOLDER/$NEW_FILENAME"
          
          # Optionally remove the temporary watermark file
          rm "$TEMP_WATERMARK"
        else
          # Apply text watermark
          convert -size ${IMAGE_WIDTH}x40 xc:none \
                  -fill "rgba(0,0,0,0.5)" -draw "rectangle 0,0 ${IMAGE_WIDTH},40" \
                  -gravity Center -pointsize 24 -fill white \
                  -annotate +0+0 "$WATERMARK_TEXT" \
                  miff:- |\
          composite -gravity $GRAVITY -geometry +0+0 - "$PROCESSED_FOLDER/$NEW_FILENAME" "$PROCESSED_FOLDER/$NEW_FILENAME"
        fi
      fi
      
      # Optimize the image
      jpegoptim --max=80 "$PROCESSED_FOLDER/$NEW_FILENAME"
      let COUNTER=COUNTER+1
    fi
  done
done
