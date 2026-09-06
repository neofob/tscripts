#!/usr/bin/env python3
import re
import sys

QUOTED = re.compile(r'(?<![*_])["“][^“”"\n]*["”](?![*_])')


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} input.md", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    with open(path, encoding="utf-8") as f:
        text = f.read()

    result = QUOTED.sub(lambda m: f"_{m.group(0)}_", text)

    with open(path, "w", encoding="utf-8") as f:
        f.write(result)


if __name__ == "__main__":
    main()
