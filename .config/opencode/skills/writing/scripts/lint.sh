#!/bin/sh
# Route text to the right structural linter.
#
#   lint.sh [--lang en|pt|auto] [FILE...]
#   echo "texto" | lint.sh
#
# --lang auto (default) sniffs the input and picks pt when Portuguese markers
# outnumber English ones, else en. For linter flags (--json, --baseline,
# --disable) call ste-lint.py or pt-lint.py directly.
set -u
dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
lang=auto
files=""

while [ $# -gt 0 ]; do
  case "$1" in
    --lang) lang=$2; shift 2 ;;
    --lang=*) lang=${1#--lang=}; shift ;;
    -h|--help) echo "usage: lint.sh [--lang en|pt|auto] [FILE...]"; exit 0 ;;
    -*) echo "lint.sh: unknown flag $1" >&2; exit 2 ;;
    *) files="$files
$1"; shift ;;
  esac
done

sniff() {
  pt=$(grep -E -o -i 'ç|ã|õ|á|é|í|ó|ú|â|ê|ô|à|não|uma|para|com|você|voce|está|esta|são|sao|nós|nos' | wc -l | tr -d ' ')
  en=$(grep -E -o -i '\bthe\b|\band\b|\bwith\b|\bthat\b|\bthis\b|\bfrom\b|\byour\b|\bis\b|\bare\b' | wc -l | tr -d ' ')
  if [ "$pt" -gt "$en" ]; then echo pt; else echo en; fi
}

tmp=""
trap '[ -n "$tmp" ] && rm -f "$tmp"' EXIT

if [ "$lang" = auto ]; then
  if [ -n "$files" ]; then
    # shellcheck disable=SC2086
    lang=$(cat $files | sniff)
  else
    tmp=$(mktemp)
    cat > "$tmp"
    lang=$(sniff < "$tmp")
  fi
fi

case "$lang" in
  en) linter="$dir/ste-lint.py" ;;
  pt) linter="$dir/pt-lint.py" ;;
  *) echo "lint.sh: bad --lang '$lang' (en|pt|auto)" >&2; exit 2 ;;
esac

if [ -n "$files" ]; then
  # shellcheck disable=SC2086
  exec python3 "$linter" $files
elif [ -n "$tmp" ]; then
  exec python3 "$linter" < "$tmp"
else
  exec python3 "$linter"
fi
