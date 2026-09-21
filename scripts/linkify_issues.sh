#!/usr/bin/env bash
# Idempotently converts "## Issue N" headings in index.md into hyperlinked
# headings matching the style used for Issue 4, e.g.:
#   ## Issue 6
# becomes:
#   ## [Issue 6](https://www.mortiseandtenonmag.com/collections/magazine/products/issue-six)
#
# Safe to re-run: headings that are already linked (## [Issue N](...)) are left untouched.

set -euo pipefail

FILE="${1:-index.md}"
BASE_URL="https://www.mortiseandtenonmag.com/collections/magazine/products"

if [[ ! -f "$FILE" ]]; then
  echo "File not found: $FILE" >&2
  exit 1
fi

NUMBER_WORDS=(zero one two three four five six seven eight nine ten \
  eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty)

number_to_word() {
  local n="$1"
  if (( n >= 0 && n < ${#NUMBER_WORDS[@]} )); then
    echo "${NUMBER_WORDS[$n]}"
  else
    echo ""
  fi
}

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

changed=0
while IFS= read -r line; do
  if [[ "$line" =~ ^##\ Issue\ ([0-9]+)$ ]]; then
    num="${BASH_REMATCH[1]}"
    word="$(number_to_word "$num")"
    if [[ -n "$word" ]]; then
      echo "## [Issue $num]($BASE_URL/issue-$word)" >> "$TMP_FILE"
      changed=1
      continue
    fi
  fi
  echo "$line" >> "$TMP_FILE"
done < "$FILE"

if [[ "$changed" -eq 1 ]]; then
  mv "$TMP_FILE" "$FILE"
  echo "Updated unlinked issue headings in $FILE"
else
  echo "No unlinked issue headings found in $FILE; nothing to do"
fi
