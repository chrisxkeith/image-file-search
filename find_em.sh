#!/bin/bash

invert_match=false
while getopts ":v" option; do
  case "$option" in
    v) invert_match=true ;;
    \?)
      printf 'Usage: %s [-v] [directory]\n' "$0" >&2
      exit 2
      ;;
  esac
done
shift $((OPTIND - 1))

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

grep_options=(-E)
list_suffix="image_list"
error_suffix="image_err"
if [[ "$invert_match" == true ]]; then
  grep_options+=(-v)
  list_suffix="non_image_list"
  error_suffix="non_image_err"
fi

find_options=(-type f)
if [[ "$(uname -s)" == "Darwin" ]]; then
  find_options=(-type d \( -name Library -o -name Applications -o -name System -o -name ".*" \) -prune -o -type f)
fi

find "$directory" "${find_options[@]}" -exec sh -c '
  for path do
    description=$(file -- "$path") || exit
    size=$(wc -c < "$path" | tr -d "[:space:]") || exit
    printf "%s|%s\n" "$description" "$size"
  done
' sh {} + | \
        grep "${grep_options[@]}" 'PC bitmap|JPEG|PNG|TIFF' > "${machineName}-${list_suffix}.txt" 2> "${machineName}-${error_suffix}.txt"
if [[ "$invert_match" == true ]]; then
  count=$(wc -l < "${machineName}-${list_suffix}.txt")
  printf 'Found %d non-image files.\n' "$count"
  exit
fi
nb1=`grep bitmap "${machineName}-${list_suffix}.txt" | wc -l`
printf 'Found %d bitmap files.\n' "$nb1"
nb2=`grep JPEG "${machineName}-${list_suffix}.txt" | wc -l`
printf 'Found %d JPEG files.\n' "$nb2"
nb3=`grep PNG "${machineName}-${list_suffix}.txt" | wc -l`
printf 'Found %d PNG files.\n' "$nb3"
nb4=`grep TIFF "${machineName}-${list_suffix}.txt" | wc -l`
printf 'Found %d TIFF files.\n' "$nb4"
sum=$((nb1 + nb2 + nb3 + nb4))
printf 'Total: %d image files.\n' "$sum"
