#!/bin/bash
set -x
rm -f data/cs/combined_directory_tree.txt
rm -f data/cs/directory_tree.html
for file in data/cs/*image_list.txt; do
    # Check if it is a regular file (skips directories)
    if [ -f "$file" ]; then
        python3 show_em.py "$file"
        # lookup the name of the computer from ??? and update the top line of the directory_tree.txt file accordingly
        cat data/cs/directory_tree.txt >> data/cs/combined_directory_tree.txt
    fi
done
python3 tree_to_html.py data/cs/combined_directory_tree.txt
/usr/bin/google-chrome-stable --new-window data/cs/directory_tree.html