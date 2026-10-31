import argparse
import re
from collections import Counter
from pathlib import Path


def main() -> None:
    default_input = Path(__file__).parent / "data/ck/2018-ck-nuc-non_image_list.txt"
    parser = argparse.ArgumentParser(
        description="Count the first word after multiple spaces on each line."
    )
    parser.add_argument(
        "input",
        nargs="?",
        type=Path,
        default=default_input,
        help=f"input file (default: {default_input})",
    )
    args = parser.parse_args()

    word_counts: Counter[str] = Counter()
    with args.input.open(encoding="utf-8") as input_file:
        for line in input_file:
            match = re.search(r" {2,}(\S+)", line)
            if match:
                word_counts[match.group(1)] += 1

    for word in sorted(word_counts):
        print(f"{word}\t{word_counts[word]}")


if __name__ == "__main__":
    main()
