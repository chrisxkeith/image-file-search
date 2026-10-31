#!/bin/bash
# set -x
machineName=$(uname -n)
rm -rf data/ck/*
time ./find_em.sh ~/Documents
mv ${machineName}-image_list.txt data/ck/image_list.txt
mv ${machineName}-image_err.txt data/ck/image_err.txt
time ./find_em.sh ~/Downloads
cat ${machineName}-image_list.txt >> data/ck/image_list.txt
cat ${machineName}-image_err.txt >> data/ck/image_err.txt
rm ${machineName}-image_list.txt
rm ${machineName}-image_err.txt
time ./find_em.sh ~/Pictures
cat ${machineName}-image_list.txt >> data/ck/image_list.txt
cat ${machineName}-image_err.txt >> data/ck/image_err.txt
rm ${machineName}-image_list.txt
rm ${machineName}-image_err.txt
python3 show_em.py data/ck/image_list.txt
python3 tree_to_html.py data/ck/directory_tree.txt
/usr/bin/google-chrome-stable --new-window data/ck/directory_tree.html