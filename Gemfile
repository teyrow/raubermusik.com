source "https://rubygems.org"

# Jekyll 3.10 är den version GitHub Pages bygger med, så lokal
# förhandsgranskning och publicerad sajt beter sig likadant.
gem "jekyll", "~> 3.10"

# Båda finns på GitHub Pages tillåtna plugin-lista.
group :jekyll_plugins do
  gem "jekyll-sitemap", "~> 1.4"
  gem "jekyll-redirect-from", "~> 0.16"
end

# GitHub Pages kör Markdown genom kramdown med GFM-parsern.
gem "kramdown-parser-gfm", "~> 1.1"

gem "webrick", "~> 1.9"

# Ruby 3.4 plockade ut de här ur standardbiblioteket. Jekyll 3 behöver dem
# fortfarande, så de måste anges explicit för att bygget ska gå lokalt.
# (GitHub Pages kör en äldre Ruby och påverkas inte.)
gem "base64"
gem "csv"
gem "logger"
gem "ostruct"
gem "bigdecimal"
