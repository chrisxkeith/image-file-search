#!/bin/bash

time ./find_em.sh /media/ck/PHOTOSTICK/
time ./find_non_image_files.sh /media/ck/PHOTOSTICK/
# time ./find_em.sh "/media/ck/G-DRIVE ArmourATD/"
# time ./find_non_image_files.sh "/media/ck/G-DRIVE ArmourATD/"
mv *.txt data/cs/
rm -f data/cs/combined_directory_tree.txt
rm -f data/cs/directory_tree.html
for file in data/cs/*-image_list.txt; do
    # Check if it is a regular file (skips directories)
    if [ -f "$file" ]; then
        sed -i 's|/media/ck|/Volumes|g' $file
        python3 show_em.py "$file"
        machine=${file##*/}
        machine=${machine%-image_list.txt}
        mv data/cs/directory_tree.txt data/cs/${machine}_directory_tree.txt
        python3 tree_to_html.py data/cs/${machine}_directory_tree.txt
        mv data/cs/directory_tree.html data/cs/${machine}_directory_tree.html
        /usr/bin/google-chrome-stable --new-window data/cs/${machine}_directory_tree.html
    fi
done
