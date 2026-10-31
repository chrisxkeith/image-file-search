import argparse
import socket
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Directory:
    file_count: int = 0
    files: list[str] = field(default_factory=list)
    children: dict[str, "Directory"] = field(default_factory=dict)


def build_tree(image_list_path: Path) -> dict[str, Directory]:
    roots: dict[str, Directory] = {}

    with image_list_path.open(encoding="utf-8") as image_list:
        for line in image_list:
            entry = line.strip()
            if not entry:
                continue
            if "TAXES".casefold() in entry.casefold() or \
                "/Library/" in entry or \
                "/System/" in entry or \
                "/Applications/" in entry or \
                ".dropbox" in entry:
                continue
            # `find_em.sh` appends file metadata after a colon.
            file_path = Path(entry.partition(":")[0].strip())
            root_name = file_path.anchor or "."
            directory_parts = file_path.parent.parts
            if file_path.anchor:
                directory_parts = directory_parts[1:]

            directory = roots.setdefault(root_name, Directory())
            for part in directory_parts:
                directory = directory.children.setdefault(part, Directory())
            directory.file_count += 1
            directory.files.append(file_path.name.lstrip())

    return roots


def format_tree(roots: dict[str, Directory]) -> str:
    lines: list[str] = []

    def count_files(directory: Directory) -> int:
        return directory.file_count + sum(
            count_files(child) for child in directory.children.values()
        )

    def add_directory(name: str, directory: Directory, depth: int) -> None:
        indent = " " * (4 * depth)
        suffix = "" if name == "." or name.endswith(("/", "\\")) else "/"
        total_files = count_files(directory)
        file_label = "file" if total_files == 1 else "files"
        lines.append(f"{indent}{name}{suffix} ({total_files} {file_label})")
        for file_name in directory.files[:5]:
            lines.append(f"{indent}    {file_name}")
        if len(directory.files) > 5:
            lines.append(f"{indent}    ... and {len(directory.files) - 5} more files")
        for child_name, child in sorted(directory.children.items()):
            add_directory(child_name, child, depth + 1)

    for root_name, root in sorted(roots.items()):
        add_directory(root_name, root, 0)

    if lines:
        lines[0] = f"/{socket.gethostname()}/{lines[0].lstrip('/')}"

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
    output_path.write_text(format_tree(tree), encoding="utf-8")


if __name__ == "__main__":
    main()
