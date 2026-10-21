#!/bin/bash

# Windows laptop git bash usb drive: cd /d
# chris@2022-inspiron MINGW64 /d
# $ time ./find_em.sh ~
# lhs/off overflow 4294967295 0
# real    11m44.788s

# Linux Mint desktop:
# ck@2018-ck-nuc:~/Documents/github/image-file-search$ time ./find_em.sh ~
# Found 47 bitmap files.
# Found 5200 JPEG files.
# Found 11408 PNG files.
# Found 1834 TIFF files.
# Total: 18489 image files.
# real    12m28.738s

directory=${1:-.}

if [[ ! -d "$directory" ]]; then
  printf 'Error: not a directory: %s\n' "$directory" >&2
  exit 1
fi

find "$directory" -type f -exec file -- {} + | grep -E 'PC bitmap|JPEG|PNG|TIFF' | tee image_list.txt
nb=`grep bitmap image_list.txt | wc -l`
printf 'Found %d bitmap files.\n' "$nb"
nb2=`grep JPEG image_list.txt | wc -l`
printf 'Found %d JPEG files.\n' "$nb2"
nb3=`grep PNG image_list.txt | wc -l`
printf 'Found %d PNG files.\n' "$nb3"
nb4=`grep TIFF image_list.txt | wc -l`
printf 'Found %d TIFF files.\n' "$nb4"
sum=$((nb + nb2 + nb3 + nb4))
printf 'Total: %d image files.\n' "$sum"
