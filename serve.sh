source ./build.sh

bun "${TEMP_OUT_DIR}/**/*.html"

rm -rf "$TEMP_OUT_DIR"
