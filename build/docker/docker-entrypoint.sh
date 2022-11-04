#!/bin/bash

if [ ! -f "/opt/droid/buildroot/Buildfile" ]; then
	echo "Buildfile not in buildroot"
	source /opt/droid/docker-unpack.sh
fi
echo "Starting droidbuild..."
cd /opt/droid/buildroot
build droid
