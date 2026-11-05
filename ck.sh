#!/bin/bash
set -x
machineName=$(uname -n)
rm -rf data/ck/*.html
if [ ! -f "data/ck/${machineName}-image_list.txt" ]; then
    time ./find_em.sh ~/Documents
    mv ${machineName}-image_list.txt data/ck/
    rm ${machineName}-image_err.txt
fi
python3 show_em.py data/ck/${machineName}-image_list.txt
mv data/ck/directory_tree.txt data/ck/${machineName}-directory_tree.txt
python3 tree_to_html.py -o data/ck/${machineName}-image_directory_tree.html data/ck/${machineName}-directory_tree.txt
/usr/bin/google-chrome-stable --new-window data/ck/${machineName}-image_directory_tree.html

if [ ! -f "data/ck/${machineName}-non_image_list.txt" ]; then
    time ./find_non_image_files.sh ~/Documents
fi
rm -f data/ck/${machineName}-non_image_err.txt
python3 show_em.py data/ck/${machineName}-non_image_list.txt
mv data/ck/directory_tree.txt data/ck/${machineName}-non_image_directory_tree.txt
python3 tree_to_html.py -o data/ck/${machineName}-non_image_directory_tree.html data/ck/${machineName}-non_image_directory_tree.txt
/usr/bin/google-chrome-stable --new-window data/ck/${machineName}-non_image_directory_tree.html
