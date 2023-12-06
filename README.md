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