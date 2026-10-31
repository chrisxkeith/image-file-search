#!/bin/bash

directory=${1:-.}

if [[ ! -d "$directory" ]]; then
  printf 'Error: not a directory: %s\n' "$directory" >&2
  exit 1
fi

find_options=(-type f)
if [[ "$(uname -s)" == "Darwin" ]]; then
  find_options=(-type d \( -name Library -o -name Applications \) -prune -o -type f)
  path_=./
else
  path_=data/ck/
fi

machineName=$(uname -n)
find "$directory" "${find_options[@]}" -exec file -- {} + | \
        grep -v -E 'PC bitmap|JPEG|PNG|TIFF' \
         > ${path_}/${machineName}-non_image_list.txt \
        2> ${path_}/${machineName}-non_image_err.txt
nb1=`cat ${path_}/${machineName}-non_image_list.txt | wc -l`
printf 'Found %d non-image files.\n' "$nb1"
