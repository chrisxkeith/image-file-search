import argparse
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Directory:
    file_count: int = 0
    direct_size: int = 0
    files: list[str] = field(default_factory=list)
    file_sizes: list[int] = field(default_factory=list)
    children: dict[str, "Directory"] = field(default_factory=dict)


def build_tree(image_list_path: Path) -> dict[str, Directory]:
    roots: dict[str, Directory] = {}

    with image_list_path.open(encoding="utf-8") as image_list:
        for line_number, line in enumerate(image_list, start=1):
            entry = line.strip()
            if not entry:
                continue
            if "TAXES".casefold() in entry.casefold() or \
                "/Library/" in entry or \
                "/System/" in entry or \
                "/Applications/" in entry or \
                ".dropbox" in entry:
                continue
            file_info, separator, size_text = entry.rpartition("|")
            if separator:
                try:
                    file_size = int(size_text.strip().removesuffix(" bytes"))
                except ValueError as error:
                    file_size = -1
            else:
                file_size = -1

            # `find_em.sh` outputs the filename followed by `file` metadata.
            file_path = Path(file_info.partition(":")[0].strip())
            root_name = file_path.anchor or "."
            directory_parts = file_path.parent.parts
            if file_path.anchor:
                directory_parts = directory_parts[1:]
            if any(
                part.strip().startswith(".") and part.strip() not in {".", ".."}
                for part in directory_parts
            ):
                continue

            directory = roots.setdefault(root_name, Directory())
            for part in directory_parts:
                directory = directory.children.setdefault(part, Directory())
            directory.file_count += 1
            directory.direct_size += file_size
            directory.files.append(file_path.name.lstrip())
            directory.file_sizes.append(file_size)

    return roots


def format_tree(roots: dict[str, Directory], filename: str) -> str:
    lines: list[str] = []

    def format_size(size: int) -> str:
        if size >= 1024**3:
            return f"{size / 1024**3:.1f} gigabytes"
        if size >= 1024**2:
            return f"{size / 1024**2:.1f} megabytes"
        size_label = "byte" if size == 1 else "bytes"
        return f"{size} {size_label}"

    def totals(directory: Directory) -> tuple[int, int]:
        child_totals = [totals(child) for child in directory.children.values()]
        return (
            directory.file_count + sum(files for files, _ in child_totals),
            directory.direct_size + sum(size for _, size in child_totals),
        )

    def add_directory(name: str, directory: Directory, depth: int) -> None:
        indent = " " * (4 * depth)
        name = name.strip()
        suffix = "" if name == "." or name.endswith(("/", "\\")) else "/"
        total_files, total_size = totals(directory)
        file_label = "file" if total_files == 1 else "files"
        lines.append(
            f"{indent}{name}{suffix} ({total_files} {file_label}, "
            f"{format_size(total_size)})"
        )
        for file_name, file_size in zip(directory.files[:5], directory.file_sizes[:5]):
            file_size_label = "byte" if file_size == 1 else "bytes"
            lines.append(f"{indent}    {file_name} ({file_size} {file_size_label})")
        if len(directory.files) > 5:
            lines.append(f"{indent}    ... and {len(directory.files) - 5} more files")
        for child_name, child in sorted(directory.children.items()):
            add_directory(child_name, child, depth + 1)

    for root_name, root in sorted(roots.items()):
        add_directory(root_name, root, 0)

    if lines:
        lines[0] = f"/{filename.replace('-image_list.txt', '')}/{lines[0].lstrip('/')}"

    return "\n".join(lines) + ("\n" if lines else "")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Create a directory tree with file totals including nested directories."
    )
    parser.add_argument(
        "input",
        nargs="?",
        type=Path,
        default=Path("image_list.txt"),
        help="input file list (default: image_list.txt)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="output text file (default: directory_tree.txt beside the input file)",
    )
    args = parser.parse_args()

    tree = build_tree(args.input)
    output_path = args.output or args.input.parent / "directory_tree.txt"
    output_path.write_text(format_tree(tree, args.input.name), encoding="utf-8")


if __name__ == "__main__":
    main()
