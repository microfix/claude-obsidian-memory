#!/usr/bin/env bash
# Fetch latest consolidated GDPR text from EUR-Lex and save to references/.
# EUR-Lex er AWS WAF-beskyttet, så vi bruger Playwright (headless browser).
# Kør hver 3-6 måned for at sikre opdateret retsgrundlag.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REF_DIR="$SKILL_DIR/references"
OUT_MD="$REF_DIR/gdpr-fulltext.md"
OUT_META="$REF_DIR/gdpr-fulltext.meta"
TMP_HTML="/tmp/gdpr-fetch-$$.html"

# Consolidated GDPR — CELEX med konsolideringsdato
URL_EN="https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:02016R0679-20160504"
URL_DA="https://eur-lex.europa.eu/legal-content/DA/TXT/HTML/?uri=CELEX:02016R0679-20160504"

echo "Henter konsolideret GDPR-tekst fra EUR-Lex (Playwright)..."

if ! command -v playwright >/dev/null 2>&1; then
    echo "FEJL: Playwright mangler. Installer med:"
    echo "  pip3 install playwright && playwright install chromium"
    exit 1
fi

if ! command -v pandoc >/dev/null 2>&1; then
    echo "FEJL: pandoc mangler. Installer med: brew install pandoc"
    exit 1
fi

# Find Python med playwright installeret
PY=""
for cand in \
    /Library/Frameworks/Python.framework/Versions/3.12/bin/python3 \
    python3.12 \
    python3; do
    if "$cand" -c "import playwright" 2>/dev/null; then
        PY="$cand"
        break
    fi
done
if [ -z "$PY" ]; then
    echo "FEJL: Ingen Python fundet med playwright-modulet."
    exit 1
fi

# Hent HTML via headless browser (omgår WAF)
"$PY" - <<PYEOF
from playwright.sync_api import sync_playwright
import sys

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    ctx = browser.new_context(
        user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        locale="en-US",
    )
    page = ctx.new_page()
    page.goto("$URL_EN", wait_until="networkidle", timeout=60000)
    html = page.content()
    with open("$TMP_HTML", "w") as f:
        f.write(html)
    browser.close()
PYEOF

if [ ! -s "$TMP_HTML" ]; then
    echo "FEJL: Kunne ikke hente indhold"
    exit 1
fi

# Konvertér til markdown
pandoc -f html -t gfm --wrap=preserve "$TMP_HTML" -o "$OUT_MD.tmp"

# Prepend metadata
{
    echo "---"
    echo "source: $URL_EN"
    echo "source_da: $URL_DA"
    echo "fetched: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "celex: 02016R0679-20160504"
    echo "tags: [gdpr, reference, fulltext]"
    echo "---"
    echo ""
    echo "# GDPR — Konsolideret fuldtekst (engelsk)"
    echo ""
    echo "Hentet fra: $URL_EN"
    echo "Dansk version: $URL_DA"
    echo ""
    echo "---"
    echo ""
    cat "$OUT_MD.tmp"
} > "$OUT_MD"

rm -f "$OUT_MD.tmp" "$TMP_HTML"

# Metadata fil til freshness-check
{
    echo "last_fetched=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "source=$URL_EN"
    echo "size_bytes=$(wc -c < "$OUT_MD")"
} > "$OUT_META"

echo ""
echo "Gemt til: $OUT_MD"
echo "Størrelse: $(wc -c < "$OUT_MD") bytes"
echo "Dato: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
