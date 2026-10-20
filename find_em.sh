directory=${1:-.}

if [[ ! -d "$directory" ]]; then
  printf 'Error: not a directory: %s\n' "$directory" >&2
  exit 1
fi

find "$directory" -type f -exec file -- {} + | grep -E 'PC bitmap|JPEG|PNG|TIFF' | tee image_list.txt
nb=`grep bitmap image_list.txt | wc -l`
printf 'Found %d bitmap files.\n' "$nb"
nb=`grep JPEG image_list.txt | wc -l`
printf 'Found %d JPEG files.\n' "$nb"
nb=`grep PNG image_list.txt | wc -l`
printf 'Found %d PNG files.\n' "$nb"
nb=`grep TIFF image_list.txt | wc -l`
printf 'Found %d TIFF files.\n' "$nb"
