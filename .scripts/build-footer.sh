#!/bin/sh

mkdir _site/assets/js
cp .scripts/footer.js _site/assets/js

FOOTER_HASH=$(git log -1 --format="%H" -- .scripts/footer.js)
FOOTER_SHORT_HASH=$(echo "$FOOTER_HASH" | cut -c1-8)

sed -i "s|</body>|<script type=\"module\" src=\"assets/js/footer.js?${FOOTER_SHORT_HASH}\"></script>\n</body>|" "_site/index.html"