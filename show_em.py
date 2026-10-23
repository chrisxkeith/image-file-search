from pathlib import Path

with open("image_list.txt", encoding="utf-8") as image_list:
    dirs = {}
    for line in image_list:
        strs = line.split(":")
        file_path = Path(strs[0])
        if (not dirs.get(file_path.parent)):
            dirs[file_path.parent] = []
        dirs[file_path.parent].append(file_path.name)

for dir_path, files in dirs.items():
    print(f"{dir_path}/: {len(files)} files \
({', '.join(files[0:5])}{'...' if len(files) > 5 else ''})")

nFiles = sum([len(files) for files in dirs.values()])
print(f"Total files: {nFiles}")
