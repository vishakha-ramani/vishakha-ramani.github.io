#!/usr/bin/env bash
# Checks the built _site against docs/superpowers/specs/2026-10-02-site-redesign-design.md.
# Run from anywhere after `bundle exec jekyll build`.
set -uo pipefail
cd "$(dirname "$0")/.."
S=_site
fails=0

check() {
  if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fails=$((fails + 1)); fi
}

home_words() {
  python3 - <<'EOF'
import re
body = open("_pages/about.md").read().split("---", 2)[2]
body = re.sub(r"^## News\n.*?(?=^## |\Z)", "", body, flags=re.M | re.S)
body = re.sub(r"\]\([^)]*\)", "]", body)
body = re.sub(r"\{%.*?%\}", "", body)
print(len(re.findall(r"[A-Za-z0-9][A-Za-z0-9'’.-]*", body)))
EOF
}

# Task 2: visual system
check "fonts loaded"          'grep -q "family=Source+Serif+4" $S/index.html && grep -q "family=Inter" $S/index.html'
check "light accent token"    'grep -q "#0f6e6e" $S/assets/css/main.css'
check "dark accent token"     'grep -q "#5fb3b3" $S/assets/css/main.css'
check "760px column"          'grep -q "760px" $S/assets/css/main.css'
check "labels skip blog posts" 'grep -q "article:not(.post-content) h2" _sass/_refined.scss'

check "body weight 400 so bold renders" 'grep -A4 "^body {" _sass/_refined.scss | grep -q "font-weight: 400"'
check "strong is explicit 600"  'grep -A2 "^strong" _sass/_refined.scss | grep -q "font-weight: 600"'
check "italic links keep accent" 'grep -q "^a em" _sass/_refined.scss'
check "home hides abstracts"  'grep -q "clearfix ~ .publications div.abstract" _sass/_refined.scss'
check "dead Abs button hidden" 'grep -q "a.abstract" _sass/_refined.scss'
check "small social icons"    'grep -A1 "contact-icons" _sass/_refined.scss | grep -q "font-size: 1.75rem"'

# Task 3: research page and nav
check "research page built"   '[ -f $S/research/index.html ]'
check "nav has research"      'grep -q "href=\"/research/\"" $S/index.html'
check "nav has cv"            'grep -q "href=\"/cv/\"" $S/index.html'
check "research keeps PhD"    'grep -q "lazy reading is timely" $S/research/index.html && grep -q "Read-Copy-Update" $S/research/index.html && grep -q "Thesis_VR.pdf" $S/research/index.html'
check "research keeps IBM"    'grep -q "2609.20957" $S/research/index.html && grep -q "BLIS" $S/research/index.html'
check "no #### headings"      '! grep -q "^####" _pages/about.md _pages/research.md'

# Task 4: homepage
check "home <= 250 words"     '[ "$(home_words)" -le 250 ]'
check "home links research"   'grep -q "href=\"/research/\">More on my research" $S/index.html'
check "home news"             'grep -q "2609.20957" $S/index.html && grep -q "IEEE CLOUD 2026" $S/index.html'
check "home selected papers"  'grep -q "Lock-Based or Lock-Less" $S/index.html'

# Task 5: publications
check "no bib search box"     '! grep -q "id=\"bibsearch\"" $S/publications/index.html'
check "preprint badge"        'grep -q "Preprint" $S/publications/index.html'

# Spec-wide
check "no disaggregation"     '! grep -rqi disaggregat $S --include="*.html"'

echo "$fails failure(s)"
exit "$fails"
