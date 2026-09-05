#!/usr/bin/env bash
# Skär ner sajtens två typsnitt till de tecken som faktiskt används och till
# de vikter CSS:en efterfrågar. Originalen i _originals/fonts/ är de fulla
# latin-uppsättningarna från Google Fonts.
#
#   ./tools/subset-font.sh
#
# Verktygen installeras i .venv-fonttools/ i projektmappen – ingenting rörs
# utanför repot. Mappen är gitignorerad.
#
# Behöver du fler tecken (nya språk, specialtecken i en rubrik): lägg till dem
# i TECKEN nedan OCH i unicode-range i assets/css/style.css. De två måste
# stämma överens – deklarerar CSS ett intervall som saknas i filen får
# besökaren tomma rutor i stället för tecken.

set -euo pipefail
cd "$(dirname "$0")/.."

SRC=_originals/fonts
UT=assets/fonts
VENV=.venv-fonttools

# Latin-1 (täcker svenska å ä ö é ü), samt de skiljetecken sajten använder.
TECKEN="U+0000-00FF,U+0131,U+0152-0153,U+2013-2014,U+2018-201A,U+201C-201E,U+2026,U+2122,U+2212"

if [ ! -x "$VENV/bin/pyftsubset" ]; then
  echo "Installerar fonttools i $VENV …"
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --quiet --upgrade pip
  "$VENV/bin/pip" install --quiet "fonttools[woff]" brotli
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# skar <infil> <utfil> <viktangivelse>
# Viktangivelsen är antingen en enda vikt (500) eller ett intervall
# (400:600) som behåller variationsaxeln inom det spannet.
skar() {
  local in=$SRC/$1 ut=$UT/$2 vikt=$3
  "$VENV/bin/fonttools" varLib.instancer "$in" "wght=$vikt" -o "$tmp/$2.ttf" >/dev/null
  "$VENV/bin/pyftsubset" "$tmp/$2.ttf" \
    --unicodes="$TECKEN" \
    --layout-features='kern,liga,clig,calt,tnum' \
    --flavor=woff2 \
    --desubroutinize \
    --output-file="$ut"
  printf '  %-34s %6d → %6d byte\n' "$2" "$(wc -c < "$in")" "$(wc -c < "$ut")"
}

echo "Skär ner typsnitten…"
# Rubriker: enbart vikt 500.
skar playfair-display.woff2  playfair-display-latin.woff2 500
# Brödtext: 400 för löptext, 600 för fetstil och etiketter.
skar source-serif-4.woff2    source-serif-latin.woff2     400:600

printf 'Totalt: %d byte\n' "$(cat "$UT"/*.woff2 | wc -c)"
