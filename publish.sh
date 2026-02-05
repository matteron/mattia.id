source ./build.sh

set -euo pipefail

ORIGIN_URL="$(git remote get-url origin)"

(
    cd "$TEMP_OUT_DIR" || exit 1
    git init -b pages
    git add .
    git commit -m "Site Build $(date +%Y-%m-%d_%H-%M-%S)"

    git remote add origin "$ORIGIN_URL"
    git push origin pages --force
)

rm -rf "$TEMP_OUT_DIR"
