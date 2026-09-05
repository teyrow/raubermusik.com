#!/usr/bin/env bash
# Genererar webboptimerade bilder i assets/img/ från originalen i _originals/.
# Kör om efter att du lagt till eller bytt ut en originalbild:
#   ./tools/optimize-images.sh
#
# För varje original skapas <namn>-<bredd>.jpg och <namn>-<bredd>.webp.
# Bredder större än originalet hoppas över (ingen uppskalning).
# Kräver ImageMagick (`brew install imagemagick`).

set -euo pipefail
cd "$(dirname "$0")/.."

SRC=_originals
OUT=assets/img
MANIFEST=_data/bilder.yml
JPG_QUALITY=82
WEBP_QUALITY=78

command -v magick >/dev/null || { echo "Saknar ImageMagick (brew install imagemagick)" >&2; exit 1; }

# render <infil> <utnamn> <bredd...>
# Skriver samtidigt en rad per bild till _data/bilder.yml med bredder och
# bildförhållande, så att mallen kan sätta width/height och slippa layouthopp.
render() {
  local in=$1 name=$2; shift 2
  local ow oh made=()
  ow=$(magick identify -format '%w' "$in[0]")
  oh=$(magick identify -format '%h' "$in[0]")
  case "$(magick identify -format '%[EXIF:Orientation]' "$in[0]" 2>/dev/null || true)" in
    5|6|7|8) local t=$ow; ow=$oh; oh=$t ;;
  esac
  mkdir -p "$(dirname "$OUT/$name")"
  for w in "$@"; do
    if [ "$w" -gt "$ow" ]; then
      echo "  hoppar över ${name}-${w} (originalet är bara ${ow}px brett)"
      continue
    fi
    magick "$in" -auto-orient -strip -resize "${w}x" -interlace Plane \
      -sampling-factor 4:2:0 -quality "$JPG_QUALITY" "$OUT/${name}-${w}.jpg"
    magick "$in" -auto-orient -strip -resize "${w}x" \
      -define webp:method=6 -quality "$WEBP_QUALITY" "$OUT/${name}-${w}.webp"
    made+=("$w")
    echo "  ${name}-${w}  jpg $(du -h "$OUT/${name}-${w}.jpg" | cut -f1)  webp $(du -h "$OUT/${name}-${w}.webp" | cut -f1)"
  done

  local key=${name//\//_}
  {
    printf '%s:\n' "$key"
    printf '  fil: %s\n' "$name"
    printf '  bredder: [%s]\n' "$(IFS=,; echo "${made[*]}")"
    printf '  bredd: %s\n' "$ow"
    printf '  hojd: %s\n' "$oh"
  } >> "$MANIFEST"
}

echo "Genererar bilder…"
mkdir -p _data
printf '# Genererad av tools/optimize-images.sh – redigera inte för hand.\n' > "$MANIFEST"
render "$SRC/hero.jpg"         hero          1200 2000
render "$SRC/atelje.jpg"       atelje         600 900 1200
render "$SRC/reparationer.jpg" reparationer   600 900 1200
render "$SRC/butiken.jpg"      butiken        600 900 1200
render "$SRC/fragor.jpg"       fragor         600 900 1200
render "$SRC/kontakt.jpg"      kontakt        600 900 1200
render "$SRC/strakbygge.jpg"   strakbygge     600 900 1200
for i in 1 2 3 4 5 6; do
  render "$SRC/strakar/strake-$i.jpg" "strakar/strake-$i" 600 1000
done

# Favicon-varianter
magick "$SRC/icon-512.png" -strip -resize 180x180 "$OUT/icon-180.png"
magick "$SRC/icon-512.png" -strip -resize 512x512 "$OUT/icon-512.png"
magick "$SRC/icon-512.png" -strip -resize 32x32   "$OUT/favicon-32.png"
echo "  favicons"

echo "Skrev $MANIFEST"
echo "Klart. Total storlek på $OUT: $(du -sh "$OUT" | cut -f1)"
