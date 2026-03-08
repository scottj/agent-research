#!/bin/sh

sudo mkdir "${GITHUB_WORKSPACE}/_site/assets/js"
sudo cp .scripts/footer.js "${GITHUB_WORKSPACE}/_site/assets/js"

FOOTER_HASH=$(git log -1 --format="%H" -- .scripts/footer.js)
FOOTER_SHORT_HASH=$(echo "$FOOTER_HASH" | cut -c1-8)

sudo sed -i "s|</body>|<script type=\"module\" src=\"assets/js/footer.js?${FOOTER_SHORT_HASH}\"></script>\n</body>|" "${GITHUB_WORKSPACE}/_site/index.html"