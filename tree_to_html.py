import argparse
from dataclasses import dataclass, field
from html import escape
from pathlib import Path


@dataclass
class TreeNode:
    label: str
    children: list["TreeNode"] = field(default_factory=list)


def parse_outline(lines: list[str]) -> list[TreeNode]:
    roots: list[TreeNode] = []
    ancestors: list[TreeNode] = []

    for line_number, line in enumerate(lines, start=1):
        if not line.strip():
            continue

        indentation = line[: len(line) - len(line.lstrip())]
        if "\t" in indentation:
            raise ValueError(f"Line {line_number}: indentation must use spaces, not tabs")
        if len(indentation) % 4:
            raise ValueError(f"Line {line_number}: indentation must be in multiples of 4 spaces")

        depth = len(indentation) // 4
        if depth > len(ancestors):
            raise ValueError(f"Line {line_number}: indentation skips a parent level")

        node = TreeNode(line[len(indentation) :].rstrip())
        if depth == 0:
            roots.append(node)
            ancestors = [node]
            continue

        ancestors = ancestors[:depth]
        ancestors[-1].children.append(node)
        ancestors.append(node)

    return roots


def render_nodes(nodes: list[TreeNode]) -> str:
    rendered: list[str] = []
    for node in nodes:
        label = escape(node.label)
        if node.children:
            rendered.append(
                f"<li><details><summary>{label}</summary>\n"
                f"<ul>\n{render_nodes(node.children)}</ul>\n"
                "</details></li>\n"
            )
        else:
            rendered.append(f"<li>{label}</li>\n")
    return "".join(rendered)


def render_html(roots: list[TreeNode]) -> str:
    return (
        "<!doctype html>\n"
        '<html lang="en">\n'
        "<head>\n"
        '  <meta charset="utf-8">\n'
        '  <meta name="viewport" content="width=device-width, initial-scale=1">\n'
        "  <title>Directory Tree</title>\n"
        "  <style>\n"
        "    body { font-family: system-ui, sans-serif; margin: 2rem; }\n"
        "    ul { list-style: none; margin: 0; padding-left: 1.5rem; }\n"
        "    li { margin: 0.2rem 0; }\n"
        "    summary { cursor: pointer; }\n"
        "  </style>\n"
        "</head>\n"
        "<body>\n"
        "  <ul>\n"
        f"{render_nodes(roots)}"
        "  </ul>\n"
        "</body>\n"
        "</html>\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Convert a four-space-indented directory outline to expandable HTML."
    )
    parser.add_argument(
        "input",
        nargs="?",
        type=Path,
        default=Path("directory_tree.txt"),
        help="input outline (default: directory_tree.txt)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=Path("directory_tree.html"),
        help="output HTML file (default: directory_tree.html)",
    )
    args = parser.parse_args()

    roots = parse_outline(args.input.read_text(encoding="utf-8").splitlines())
    args.output.write_text(render_html(roots), encoding="utf-8")


if __name__ == "__main__":
    main()
