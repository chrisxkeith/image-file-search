#!/bin/bash

directory=${1:-.}

if [[ ! -d "$directory" ]]; then
  printf 'Error: not a directory: %s\n' "$directory" >&2
  exit 1
fi

find_options=(-type f)
if [[ "$(uname -s)" == "Darwin" ]]; then
  find_options=(-type d \( -name Library -o -name Applications \) -prune -o -type f)
fi
path_=data/cs/
if [[ "$directory" == *"PHOTOSTICK"* ]]; then
  machineName="PHOTOSTICK"
elif [[ "$directory" == *"g-tech"* ]]; then
  machineName="g-tech"
elif [[ "$directory" == *"G-DRIVE"* ]]; then
  machineName="Sandisk-G"
else
  machineName=$(uname -n)
  path_=data/ck/
fi

find "$directory" "${find_options[@]}" -exec sh -c '
  for path do
    description=$(file -- "$path") || exit
    size=$(wc -c < "$path" | tr -d "[:space:]") || exit
    printf "%s|%s\n" "$description" "$size"
  done
' sh {} + | \
        grep -v -E 'PC bitmap|JPEG|PNG|TIFF' \
         > ${path_}${machineName}-non_image_list.txt \
        2> ${path_}${machineName}-non_image_err.txt
nb1=`cat ${path_}${machineName}-non_image_list.txt | wc -l`
printf 'Found %d non-image files.\n' "$nb1"
