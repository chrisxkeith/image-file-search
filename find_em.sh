#!/bin/bash

directory=${1:-.}

if [[ ! -d "$directory" ]]; then
  printf 'Error: not a directory: %s\n' "$directory" >&2
  exit 1
fi

find "$directory" -type f -exec file -- {} + | grep -E 'PC bitmap|JPEG|PNG|TIFF' > image_list.txt 2> image_err.txt
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
