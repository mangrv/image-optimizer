Image Optimizer README
======================

Introduction
------------

This script is designed to monitor an input directory for new images and optimize them for use on the web, including resizing, compressing, and watermarking.

Features
--------

*   Watches for new images in the input folder.
*   Resizes and compresses images.
*   Archives original images.
*   Adds a customizable watermark to images.

Prerequisites
-------------

*   Git
*   ImageMagick
*   jpegoptim (for JPEG files)
*   fswatch

Installation
------------

Clone this repository to use the Image Optimizer on your local machine:

    git clone https://github.com/mangrv/image-optimizer.git
    cd image-optimizer

Usage
-----

The script file in this repository is named `image_optimizer_generic.sh`. You can rename this script according to your preference. However, ensure to use the correct file name when running the script.

Modify the script to point to your specific directories:

    INPUT_FOLDER="/path/to/input"
    PROCESSED_FOLDER="/path/to/processed"
    ARCHIVE_FOLDER="/path/to/archive"

Run the script with:

    ./image_optimizer_generic.sh

Add images to the input folder and the script will automatically process them.

Configuration
-------------

The script can be configured to handle different image types, optimization levels, and watermarking. Below are the configurable options:

### File Types

The script processes the following image file extensions:

*   jpg
*   jpeg
*   png
*   tiff
*   webm
*   heic

Modify the list of supported file types by editing the regular expression:

    if [[ $EXTENSION =~ ^(jpg|jpeg|png|tiff|webm|heic)$ ]]; then

### File Naming

The script generates new filenames based on the current date and a counter. Format: `mmdd+pcpart+counter.jpg`. Modify the prefix or structure:

    NEW_FILENAME="$(date +%m%d)+pcpart+$COUNTER.jpg"

### Image Conversion, Optimization, and Watermarking

By default, images are converted to JPEG format with a quality setting of 75 and resized to a maximum width of 600 pixels. These settings, along with watermarking, are adjustable in the `convert` command:

    convert "$SORTED_FILEPATH" -auto-orient -strip -quality 75 -resize 600x \
            -gravity southeast -pointsize 12 -fill white -annotate +10+10 "Your Watermark Here" \
            "$PROCESSED_FOLDER/$NEW_FILENAME"

*   `-auto-orient`: Corrects orientation based on EXIF data.
*   `-strip`: Removes profiles or comments to reduce size.
*   `-quality 75`: Sets compression level.
*   `-resize 600x`: Resizes image, maintaining aspect ratio.
*   Watermark Options:

*   `-gravity southeast`: Positions the watermark (change as needed).
*   `-pointsize 12`: Font size of the watermark text.
*   `-fill white`: Color of the watermark text.
*   `-annotate +10+10 "Your Watermark Here"`: The watermark text and its position.

### Further Compression with jpegoptim

For additional JPEG optimization:

    jpegoptim --max=80 "$PROCESSED_FOLDER/$NEW_FILENAME"

`--max=80`: Sets maximum quality to 80%. Adjust as needed.

### Incrementing Counter

The counter variable ensures unique filenames:

    let COUNTER=COUNTER+1

Reset or modify the counter as required.

Review and test the script after changes to ensure functionality.

Contributing
------------

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

License
-------

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).

Contact
-------

For support or contributions, please visit our [GitHub Repo](https://github.com/mangrv/image-optimizer/).

Acknowledgements
----------------

*   ImageMagick
*   jpegoptim
*   fswatch