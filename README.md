 Image Optimizer README

Image Optimizer
===============

Introduction
------------

This script is designed to monitor an input directory for new images and optimize them for use on the web.

Features
--------

*   Watches for new images in the input folder.
*   Resizes and compresses images.
*   Archives original images.

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

Modify the script to point to your specific directories:

    INPUT_FOLDER="/path/to/input"
    PROCESSED_FOLDER="/path/to/processed"
    ARCHIVE_FOLDER="/path/to/archive"
        

Run the script with:

    ./image_optimizer.sh

Add images to the input folder and the script will automatically process them.

Configuration
-------------

The script can be configured to handle different image types and optimization levels. Below are the configurable options:

### File Types

The script is set up to process the following image file extensions:

*   jpg
*   jpeg
*   png
*   tiff
*   webm
*   heic

You can modify the list of supported file types by editing the regular expression in the following line:

    if [[ $EXTENSION =~ ^(jpg|jpeg|png|tiff|webm|heic)$ ]]; then

### File Naming

The script generates new filenames based on the current date and a counter. The format is `mmdd+pcpart+counter.jpg`. You can change the prefix or structure by modifying:

    NEW_FILENAME="$(date +%m%d)+pcpart+$COUNTER.jpg"

### Image Conversion and Optimization

By default, images are converted to JPEG format with a quality setting of 75 and resized to a maximum width of 600 pixels. These settings can be adjusted in the `convert` command:

    convert "$SORTED_FILEPATH" -auto-orient -strip -quality 75 -resize 600x "$PROCESSED_FOLDER/$NEW_FILENAME"

*   `-auto-orient`: Corrects the orientation based on EXIF data.
*   `-strip`: Removes any profiles or comments to reduce size.
*   `-quality 75`: Sets the compression level (0 to 100; higher means better quality and larger file size).
*   `-resize 600x`: Resizes the image to a maximum width of 600 pixels while maintaining aspect ratio.

### Further Compression with jpegoptim

For additional optimization of JPEG files, the `jpegoptim` command is used:

    jpegoptim --max=80 "$PROCESSED_FOLDER/$NEW_FILENAME"

`--max=80`: Sets the maximum quality to 80%. You can adjust the quality percentage as needed.

### Incrementing Counter

The counter variable ensures that each processed file has a unique name:

    let COUNTER=COUNTER+1

You can reset or modify the counter's behavior as per your requirements.

Remember to review and test the script after making any changes to ensure it functions as expected.

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