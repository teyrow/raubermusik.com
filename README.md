# raubermusik.com

Statisk sajt för Rauber musik, byggd med Jekyll. Ersätter den tidigare sidan
i one.com:s webbeditor.

Inga externa beroenden i den publicerade sajten: typsnittet ligger lokalt,
det finns ingen spårning, och kartan från Google laddas först när besökaren
klickar på den.

## Kom igång lokalt

```bash
bundle install
bundle exec jekyll serve --livereload
```

Sajten ligger då på <http://localhost:4000> och byggs om när du sparar en fil.

## Var innehållet finns

| Vad | Fil |
|---|---|
| Startsidan | `index.html` |
| Reparationer | `reparationer.md` |
| I butiken | `i_butiken.md` |
| Stråkbygge | `strakbygge.html` |
| Frågor & svar | `fragorochsvar.html` (frågorna ligger i sidans front matter) |
| Kontakt | `kontakt.html` |
| Telefon, e-post, adress, öppettider | `_data/kontakt.yml` |
| Menyn | `_data/nav.yml` |

Kontaktuppgifterna står bara på ett ställe – `_data/kontakt.yml`. Ändrar du
telefonnumret där slår det igenom i sidfoten på alla sidor, på kontaktsidan
och i den strukturerade datan som Google läser.

## Bilder

Originalen ligger i `_originals/` och publiceras aldrig. Skriptet
`tools/optimize-images.sh` gör om dem till webb­storlekar i `assets/img/`
(både `.webp` och `.jpg`, i flera bredder) och skriver `_data/bilder.yml`.

```bash
./tools/optimize-images.sh    # kräver ImageMagick: brew install imagemagick
```

Lägg in en bild i mallarna med:

```liquid
{% include bild.html id="butiken" alt="Beskrivning av bilden" sizes="(min-width: 60rem) 26rem, 92vw" %}
```

`id` är nyckeln i `_data/bilder.yml`. `sizes` talar om hur bred bilden blir i
layouten, så att webbläsaren hämtar rätt storlek.

För att lägga till en helt ny bild: lägg originalet i `_originals/`, lägg till
en `render`-rad i `tools/optimize-images.sh` och kör skriptet.

## Publicering

Sajten är gjord för GitHub Pages klassiska Jekyll-bygge – du pushar, GitHub
bygger. Båda plugin-modulerna (`jekyll-sitemap`, `jekyll-redirect-from`) finns
på GitHub Pages tillåtna lista.

1. Skapa ett repo på GitHub och pusha.
2. Settings → Pages → Source: **Deploy from a branch**, branch `main`, mapp `/`.
3. Settings → Pages → Custom domain: `raubermusik.com`. Filen `CNAME` ligger
   redan i repot.
4. Kryssa i **Enforce HTTPS** när certifikatet har utfärdats (tar några minuter).

### DNS

Domänen ligger i dag hos one.com, och one.com är även namnserver
(`ns01.one.com`, `ns02.one.com`). Peka om den till GitHub i one.com:s
DNS-inställningar:

| Typ | Namn | Värde |
|---|---|---|
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |
| AAAA | `@` | `2606:50c0:8000::153` |
| AAAA | `@` | `2606:50c0:8001::153` |
| AAAA | `@` | `2606:50c0:8002::153` |
| AAAA | `@` | `2606:50c0:8003::153` |
| CNAME | `www` | `ANVÄNDARNAMN.github.io.` |

**Viktigt:** webbhotellet kan sägas upp, men *domänregistreringen* måste leva
vidare någonstans. Antingen behåller du domänen hos one.com (bara registrering
och DNS, ingen webbhotellsdel), eller så flyttar du den till en annan
registrar innan du säger upp abonnemanget. Går registreringen ut slutar sajten
fungera oavsett var den ligger.

Det finns ingen e-post på domänen att ta hänsyn till – adressen som används är
`raubermusik@telia.com`, som ligger hos Telia och inte berörs.

## Adresser som bevarats

Alla gamla adresser fungerar: `/reparationer`, `/i_butiken`, `/strakbygge`,
`/kontakt` och `/fragorochsvar`. GitHub Pages skickar dem vidare till samma
adress med avslutande snedstreck.

Gamla `/om` var en oredigerad mallsida ("Anne Smith", keramik) som aldrig låg i
menyn. Den skickas nu vidare till startsidan (se `redirect_from` i
`index.html`). Vill du i stället ha en riktig presentationssida: ta bort
`redirect_from`, skapa `om.md` och lägg till den i `_data/nav.yml`.
