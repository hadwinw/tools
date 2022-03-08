#!/usr/bin/bash

file="nautilus_script.sh"

#IFS=$'\n'
echo "NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" > $file
echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" >> $file

echo "NAUTILUS_SCRIPT_SELECTED_URIS" >> $file
echo "$NAUTILUS_SCRIPT_SELECTED_URIS" >> $file

echo "NAUTILUS_SCRIPT_CURRENT_URI" >> $file
echo "$NAUTILUS_SCRIPT_CURRENT_URI" >> $file


echo "NAUTILUS_SCRIPT_WINDOW_GEOMETRY" >> $file
echo "$NAUTILUS_SCRIPT_WINDOW_GEOMETRY" >> $file

