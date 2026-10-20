directory=${1:-.}

if [[ ! -d "$directory" ]]; then
  printf 'Error: not a directory: %s\n' "$directory" >&2
  exit 1
fi

find "$directory" -type f -exec file -- {} + | grep -E 'PC bitmap|JPEG|PNG|TIFF' | tee image_list.txt