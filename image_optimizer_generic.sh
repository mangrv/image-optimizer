#!/bin/bash

# Configuration Variables
INPUT_FOLDER="/Users/cmdnotfound/Documents/inventoryImages/input"
PROCESSED_FOLDER="/Users/cmdnotfound/Documents/inventoryImages/processed"
ARCHIVE_FOLDER="/Users/cmdnotfound/Documents/inventoryImages/archive"
COUNTER=1
WATERMARK_ENABLED="yes"
WATERMARK_TYPE="image"
WATERMARK_TEXT="colliercomputers.com"
WATERMARK_IMAGE_PATH="/Users/cmdnotfound/Documents/inventoryImages/watermarks/watermark.png"
WATERMARK_OPACITY="50%"
WATERMARK_POSITION="center_center"
WATERMARK_SCALE="0.5"
RESIZE_ENABLED="no"
ARCHIVE_TIME_LIMIT=1440
FILENAME_PART="optimized"

# Function to determine gravity based on position
get_gravity() {
    case "$1" in
        left_center) echo "West";;
        center_center) echo "Center";;
        right_center) echo "East";;
        bottom_left_center) echo "Southwest";;
        bottom_center_center) echo "South";;
        bottom_right_center) echo "Southeast";;
        *) echo "Center" # Default to center
    esac
}

# Ensure required folders exist
mkdir -p "$INPUT_FOLDER"
mkdir -p "$PROCESSED_FOLDER"
mkdir -p "$ARCHIVE_FOLDER"

# Start the monitoring loop
echo "Starting watermark script. Monitoring folder: $INPUT_FOLDER"

while true; do
    # Move old files to archive folder
    echo "Archiving old files..."
    find "$INPUT_FOLDER" -mindepth 1 -maxdepth 1 -mmin +$ARCHIVE_TIME_LIMIT -exec mv {} "$ARCHIVE_FOLDER" \;
    find "$PROCESSED_FOLDER" -mindepth 1 -maxdepth 1 -mmin +$ARCHIVE_TIME_LIMIT -exec mv {} "$ARCHIVE_FOLDER" \;

    # Process new files
    find "$INPUT_FOLDER" -type f -maxdepth 1 | while IFS= read -r FILEPATH; do
        echo "Processing file: $FILEPATH"
        FILENAME=$(basename "$FILEPATH")
        EXTENSION="${FILENAME##*.}"
        if [[ $EXTENSION =~ ^(jpg|jpeg|png|tiff|webp|heic)$ ]]; then
            NEW_FILENAME="$(date +%m%d)+$FILENAME_PART+$COUNTER.jpg"

            # Resize image if enabled
            if [[ $RESIZE_ENABLED == "yes" ]]; then
                RESIZE_COMMAND="-resize 800x"
            else
                RESIZE_COMMAND=""
            fi

            # Optimize image
            convert "$FILEPATH" -auto-orient -strip -quality 80 $RESIZE_COMMAND "$PROCESSED_FOLDER/$NEW_FILENAME"
            echo "Image optimized: $NEW_FILENAME"

            # Add watermark if enabled
            if [[ $WATERMARK_ENABLED == "yes" ]]; then
                GRAVITY=$(get_gravity "$WATERMARK_POSITION")
                if [[ $WATERMARK_TYPE == "image" ]]; then
                    echo "Adding image watermark..."
                    TEMP_WATERMARK="/tmp/temp_watermark.png"
                    MAX_DIM=$(identify -format "%w" "$PROCESSED_FOLDER/$NEW_FILENAME" | awk -v scale="$WATERMARK_SCALE" '{print int($1 * scale)}')
                    convert "$WATERMARK_IMAGE_PATH" -resize ${MAX_DIM}x${MAX_DIM} "$TEMP_WATERMARK"
                    composite -dissolve 50% -gravity $GRAVITY "$TEMP_WATERMARK" "$PROCESSED_FOLDER/$NEW_FILENAME" "$PROCESSED_FOLDER/$NEW_FILENAME"
                    rm "$TEMP_WATERMARK"
                    echo "Watermark applied to $NEW_FILENAME"
                elif [[ $WATERMARK_TYPE == "text" ]]; then
                    echo "Adding text watermark..."
                    convert "$PROCESSED_FOLDER/$NEW_FILENAME" \
                        -gravity $GRAVITY -pointsize 24 -fill white \
                        -annotate +0+0 "$WATERMARK_TEXT" \
                        "$PROCESSED_FOLDER/$NEW_FILENAME"
                    echo "Text watermark applied to $NEW_FILENAME"
                else
                    echo "Invalid watermark type. Skipping watermark."
                fi
            fi

            # Compress image further with jpegoptim
            jpegoptim --max=80 "$PROCESSED_FOLDER/$NEW_FILENAME"
            echo "Image compressed: $NEW_FILENAME"

            # Increment counter
            COUNTER=$((COUNTER + 1))
        else
            echo "Skipping unsupported file type: $FILENAME"
        fi
    done

    # Wait before checking again
    sleep 5
done
