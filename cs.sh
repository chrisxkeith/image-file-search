#!/bin/bash

cat data/cs/*image_list.txt > data/cs/combined_image_list.txt
python3 show_em.py data/cs/combined_image_list.txt
python3 tree_to_html.py data/cs/directory_tree.txt
/usr/bin/google-chrome-stable --new-window data/cs/directory_tree.html