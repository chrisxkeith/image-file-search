import argparse
import re
from collections import Counter
from pathlib import Path


def main() -> None:
    default_input = Path(__file__).parent / "data/ck/2018-ck-nuc-non_image_list.txt"
    parser = argparse.ArgumentParser(
        description="Count words and extract unique text after multiple spaces."
    )
    parser.add_argument(
        "input",
        nargs="?",
        type=Path,
        default=default_input,
        help=f"input file (default: {default_input})",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="output file for unique text (default: unique_text.txt beside the input file)",
    )
    args = parser.parse_args()

    word_counts: Counter[str] = Counter()
    unique_text: set[str] = set()
    with args.input.open(encoding="utf-8") as input_file:
        for line in input_file:
            match = re.search(r" {2,}(\S.*)", line.rstrip())
            if match:
                text = match.group(1)
                unique_text.add(text)
                word_counts[text.split(maxsplit=1)[0]] += 1

    for word in sorted(word_counts, key=lambda value: (value.casefold(), value)):
        print(f"{word_counts[word]}\t{word}")

    output_path = args.output or args.input.parent / "unique_text.txt"
    output_path.write_text(
        "".join(
            f"{text}\n"
            for text in sorted(unique_text, key=lambda value: (value.casefold(), value))
        ),
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
