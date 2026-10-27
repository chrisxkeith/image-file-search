#!/bin/bash

machineName=$(uname -n)
time ./find_em.sh ~/Documents > documents.txt
mv ${machineName}-image_list.txt ck_image_list.txt
mv ${machineName}-image_err.txt ck_image_err.txt
time ./find_em.sh ~/Downloads > downloads.txt
cat ${machineName}-image_list.txt > ck_image_list.txt
cat ${machineName}-image_err.txt > ck_image_err.txt
time ./find_em.sh ~/Pictures > pictures.txt
cat ${machineName}-image_list.txt > ck_image_list.txt
cat ${machineName}-image_err.txt > ck_image_err.txt
