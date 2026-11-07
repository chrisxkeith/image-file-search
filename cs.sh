#!/bin/bash
set -x
if [ ! -f "data/cs/PHOTOSTICK-image_list.txt" ]; then
    time ./find_em.sh /media/ck/PHOTOSTICK/
fi
if [ ! -f "data/cs/PHOTOSTICK-non_image_list.txt" ]; then
    time ./find_non_image_files.sh /media/ck/PHOTOSTICK/
fi
if [ ! -f "data/cs/Sandisk-G-image_list.txt" ]; then
    time ./find_em.sh "/media/ck/G-DRIVE ArmorATD/Backups.backupdb/Christopher’s iMac/2023-09-23-040202"
fi
# /media/ck/G-DRIVE ArmorATD/Backups.backupdb/Christopher’s iMac/2023-07-07-230136 # 209,048,728 bytes
# /media/ck/G-DRIVE ArmorATD/Backups.backupdb/Christopher’s iMac/2023-09-23-030925 # 1,356,775,607 bytes
# /media/ck/G-DRIVE ArmorATD/Backups.backupdb/Christopher’s iMac/2023-09-23-040202 # 1,375,737,679 bytes
if [ ! -f "data/cs/Sandisk-G-non_image_list.txt" ]; then
    time ./find_non_image_files.sh "/media/ck/G-DRIVE ArmorATD/Backups.backupdb/Christopher’s iMac/2023-09-23-040202"
fi
mv *.txt data/cs/
rm -f data/cs/combined_directory_tree.txt
rm -f data/cs/*.html
for file in data/cs/g-tech-image_list.txt; do
    sed -i 's|/media/ck|/Volumes|g' $file
    python3 show_em.py "$file"
    machine=${file##*/}
    machine=${machine%-image_list.txt}
    mv data/cs/directory_tree.txt data/cs/${machine}-directory_tree.txt
    python3 tree_to_html.py  -o data/cs/${machine}-directory_tree.html \
        data/cs/${machine}-directory_tree.txt
    /usr/bin/google-chrome-stable --new-window data/cs/${machine}-directory_tree.html
done
for file in data/cs/g-tech-non_image_list.txt; do
    sed -i 's|/media/ck|/Volumes|g' $file
    python3 show_em.py "$file"
    machine=${file##*/}
    machine=${machine%-non_image_list.txt}
    mv data/cs/directory_tree.txt data/cs/${machine}-non_directory_tree.txt
    python3 tree_to_html.py -o data/cs/${machine}-non_directory_tree.html \
        data/cs/${machine}-non_directory_tree.txt
    /usr/bin/google-chrome-stable --new-window data/cs/${machine}-non_directory_tree.html
done
