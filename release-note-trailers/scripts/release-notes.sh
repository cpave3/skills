#!/bin/sh
# Collect Release-Note trailers from a commit range and print them as a Markdown list.
#
# Usage: release-notes.sh [--missing] [--match <glob>] [<range>] [-- <path>...]
#
#   <range>         any git revision range, e.g. v1.2.0..v1.3.0
#                   default: <latest tag reachable from HEAD>..HEAD
#                            when HEAD itself is tagged: <the tag before it>..HEAD
#                            when there is no tag: all of HEAD
#   --match <glob>  only consider tags matching the glob when choosing the default
#                   range, e.g. --match 'api@*' in a monorepo
#   -- <path>...    only commits that touch these paths
#   --missing       list the commits that carry no note, for review, in place of the notes
#
# stdout: one "- <note> (<short sha>)" line per trailer, oldest commit first.
#         A note repeated word for word is printed once.
#         A note on a commit that is reverted within the range is left out.
#         With --missing: one "- <subject> (<short sha>)" line per commit with no
#         note, leaving out merges, reverts, and reverted commits.
# stderr: the range used, and a "warning:" line for anything that needs a look:
#         an empty range, a note left out because of a revert, or a Release-Note
#         line that git did not read as a trailer.
# exit:   0 on success, including when there are no notes; non-zero when git fails or the
#         clone is shallow; 2 on a usage error.
set -eu

usage() {
  echo "usage: release-notes.sh [--missing] [--match <glob>] [<range>] [-- <path>...]" >&2
  exit 2
}

missing=0
match=
range=
while [ "$#" -gt 0 ]; do
  case $1 in
    --missing) missing=1; shift ;;
    --match) [ "$#" -ge 2 ] || usage; match=$2; shift 2 ;;
    --) shift; break ;;
    -*) usage ;;
    *) [ -z "$range" ] || usage; range=$1; shift ;;
  esac
done
# What remains in "$@" is the path list.

git rev-parse --git-dir >/dev/null

if [ "$(git rev-parse --is-shallow-repository)" = true ]; then
  echo "error: this is a shallow clone, so commits and tags are missing." >&2
  echo "Fetch full history and tags first (git fetch --unshallow --tags; in GitHub Actions, fetch-depth: 0)." >&2
  exit 1
fi

latest_tag() {
  if [ -n "$match" ]; then
    git describe --tags --abbrev=0 --match "$match" "$1" 2>/dev/null
  else
    git describe --tags --abbrev=0 "$1" 2>/dev/null
  fi
}

if [ -z "$range" ]; then
  if tag=$(latest_tag HEAD); then
    if [ "$(git rev-parse "$tag^{commit}")" = "$(git rev-parse HEAD)" ]; then
      # HEAD is the tagged release: collect what that tag released.
      if prev=$(latest_tag "HEAD^"); then
        range="$prev..HEAD"
      else
        range=HEAD
      fi
      echo "note: HEAD is tagged $tag; collecting the notes for that release" >&2
    else
      range="$tag..HEAD"
    fi
  else
    range=HEAD
  fi
fi

echo "range: $range" >&2

# One record per commit: full sha, short sha, parents, subject, body, then one
# field per Release-Note trailer. \037 separates fields, \036 ends the record.
log=$(git log --reverse \
  --format='%H%x1f%h%x1f%P%x1f%s%x1f%b%x1f%(trailers:key=Release-Note,valueonly=true,unfold=true,separator=%x1f)%x1e' \
  "$range" -- "$@")

printf '%s' "$log" | awk -v missing="$missing" '
  function warn(msg) { print "warning: " msg | "cat 1>&2" }
  function trim(s) { gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", s); return s }
  BEGIN { RS = "\036"; FS = "\037" }
  {
    full = trim($1)
    if (full == "") next
    n++
    sha[n] = full; short[n] = $2; parents[n] = trim($3); subject[n] = $4; body[n] = $5
    index_of[full] = n
    count[n] = 0
    for (i = 6; i <= NF; i++) {
      note = trim($i)
      if (note != "") notes[n, ++count[n]] = note
    }
  }
  END {
    if (n == 0) { warn("no commits in this range; check that it is the range you meant"); exit }

    # Newest first: a commit that is still live cancels the commits it reverts.
    # A revert that was itself reverted is dead, so it cancels nothing.
    for (c = n; c >= 1; c--) {
      rest = body[c]
      while (match(rest, /This reverts commit [0-9a-f]+/)) {
        is_revert[c] = 1
        target = substr(rest, RSTART + 20, RLENGTH - 20)
        rest = substr(rest, RSTART + RLENGTH)
        if (dead[c]) continue
        for (t = 1; t < c; t++)
          if (index(sha[t], target) == 1) dead[t] = 1
      }
    }

    for (c = 1; c <= n; c++) {
      # Release-Note lines in the message that git did not read as trailers.
      written = 0
      lines = split(body[c], line, "\n")
      for (l = 1; l <= lines; l++)
        if (tolower(line[l]) ~ /^release-note:/) written++
      if (written > count[c])
        warn(short[c] " has a Release-Note line that is not a trailer (not in the final paragraph, or the paragraph has a line git cannot read); read the commit message for the note")

      if (missing) {
        if (count[c] == 0 && written == 0 && !dead[c] && !is_revert[c] && parents[c] !~ / /)
          printf "- %s (%s)\n", subject[c], short[c]
        continue
      }

      for (k = 1; k <= count[c]; k++) {
        note = notes[c, k]
        if (dead[c]) { warn("left out, " short[c] " is reverted in this range: " note); continue }
        if (!seen[note]++) printf "- %s (%s)\n", note, short[c]
      }
    }
    close("cat 1>&2")
  }'
