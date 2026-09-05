#!/usr/bin/env bash
# Skär ner rubriktypsnittet till de tecken sajten faktiskt använder och låser
# det till en enda vikt. Originalet i _originals/fonts/ är den variabla
# latin-uppsättningen från Google Fonts (vikt 400–700, ~38 kB); sajten använder
# bara vikt 500, så variationstabellerna och alla oanvända tecken är dödvikt.
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

IN=_originals/fonts/playfair-display.woff2
UT=assets/fonts/playfair-display-latin.woff2
VIKT=500
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

echo "Låser vikten till $VIKT …"
"$VENV/bin/fonttools" varLib.instancer "$IN" "wght=$VIKT" -o "$tmp/instans.ttf" >/dev/null

echo "Skär bort oanvända tecken …"
"$VENV/bin/pyftsubset" "$tmp/instans.ttf" \
  --unicodes="$TECKEN" \
  --layout-features='kern,liga,clig,calt' \
  --flavor=woff2 \
  --desubroutinize \
  --output-file="$UT"

fore=$(wc -c < "$IN")
efter=$(wc -c < "$UT")
printf 'Klart: %d → %d byte (%.0f %% mindre)\n' "$fore" "$efter" \
  "$(echo "(1 - $efter/$fore) * 100" | bc -l)"
