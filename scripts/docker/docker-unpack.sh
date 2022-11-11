#!/bin/bash
echo "Unpacking droidbuild to buildroot..."
cp -r /opt/droid/droidpak/* /opt/droid/buildroot/
# By default hidden files are not globbed with asteris
# so copy .repo manually
cp -r /opt/droid/droidpak/.repo /opt/droid/buildroot/
echo "Done"
