Image Optimizer README
======================

Introduction
------------

This script monitors an input directory for new images and optimizes them for web use. It includes features like resizing, compressing, adding customizable watermarks (text or image), and archiving original images.

Features
--------

* Watches for new images in the input folder.
* Resizes and compresses images for web use.
* Archives original images after a configurable time limit.
* Adds a customizable text or image watermark with configurable position, size, and opacity. This feature can be enabled or disabled.
* Allows customization of the output filename part.
* Utilizes the Helvetica Neue font for watermark text (when using text watermark).

Prerequisites
-------------

* Git
* ImageMagick
* jpegoptim (for JPEG files)
* fswatch

Installation
------------

Clone this repository to use the Image Optimizer on your local machine:

    git clone https://github.com/mangrv/image-optimizer.git
    cd image-optimizer

Usage
-----

The script file in this repository is named `image_optimizer_generic.sh`. You can rename this script according to your preference. Ensure to use the correct file name when running the script.

Modify the script to point to your specific directories:

    INPUT_FOLDER="/path/to/input"
    PROCESSED_FOLDER="/path/to/processed"
    ARCHIVE_FOLDER="/path/to/archive"

Run the script with:

    ./image_optimizer_generic.sh

Add images to the input folder, and the script will automatically process them.

Configuration
-------------

The script can be configured to handle different image types, optimization levels, and watermarking. Below are the configurable options:

### Watermark Settings

- **Enable/Disable Watermark**: Toggle the watermark feature on or off.
- **Watermark Type**: Choose between 'text' or 'image' watermark types.
- **Watermark Text**: Set the text of the watermark (for text watermark).
- **Watermark Image Path**: Specify the path to the watermark image (for image watermark).
- **Watermark Position**: Choose the position of the watermark on the image.
- **Watermark Font**: The font used for the watermark text (for text watermark).

Example configurations:

    WATERMARK_ENABLED="yes" # Enable watermark
    WATERMARK_TYPE="text" # Choose between 'text' or 'image'
    WATERMARK_TEXT="Your Watermark Here"
    WATERMARK_IMAGE_PATH="/path/to/watermark/image.png"
    WATERMARK_POSITION="bottom_right_center" # Options: left_center, center_center, right_center, bottom_left_center, bottom_center_center, bottom_right_center

### Image Resizing

Enable or disable resizing of images to a maximum width of 800 pixels while maintaining the aspect ratio.

    RESIZE_ENABLED="yes" # Enable resizing
    RESIZE_ENABLED="no" # Keep original size

### Filename Customization

Customize the filename for processed images.

    FILENAME_PART="custompart" # Customize the middle part of the filename

### Archive Time Limit

Set the time limit in minutes for how long to wait before archiving processed images.

    ARCHIVE_TIME_LIMIT=60 # Archive images older than 60 minutes

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

* ImageMagick
* jpegoptim
* fswatch
