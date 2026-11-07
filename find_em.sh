#!/bin/bash

directory=${1:-.}

if [[ ! -d "$directory" ]]; then
  printf 'Error: not a directory: %s\n' "$directory" >&2
  exit 1
fi

if [[ "$directory" == *"PHOTOSTICK"* ]]; then
  machineName="PHOTOSTICK"
elif [[ "$directory" == *"G-DRIVE ArmorATD"* ]]; then # handle this first to avoid matching the generic G-DRIVE case
  machineName="Sandisk-G"
elif [[ "$directory" == *"G-DRIVE"* ]]; then
  machineName="g-tech"
else
  machineName=$(uname -n)
fi

find_options=(-type f)
if [[ "$(uname -s)" == "Darwin" ]]; then
  find_options=(-type d \( -name Library -o -name Applications \) -prune -o -type f)
fi

find "$directory" "${find_options[@]}" -exec sh -c '
  for path do
    description=$(file -- "$path") || exit
    size=$(wc -c < "$path" | tr -d "[:space:]") || exit
    printf "%s|%s\n" "$description" "$size"
  done
' sh {} + | \
        grep -E 'PC bitmap|JPEG|PNG|TIFF' > ${machineName}-image_list.txt 2> ${machineName}-image_err.txt
nb1=`grep bitmap ${machineName}-image_list.txt | wc -l`
printf 'Found %d bitmap files.\n' "$nb1"
nb2=`grep JPEG ${machineName}-image_list.txt | wc -l`
printf 'Found %d JPEG files.\n' "$nb2"
nb3=`grep PNG ${machineName}-image_list.txt | wc -l`
printf 'Found %d PNG files.\n' "$nb3"
nb4=`grep TIFF ${machineName}-image_list.txt | wc -l`
printf 'Found %d TIFF files.\n' "$nb4"
sum=$((nb1 + nb2 + nb3 + nb4))
printf 'Total: %d image files.\n' "$sum"
