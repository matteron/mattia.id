set -euo pipefail

SRC_DIR="./src"
TEMPLATE="./template.html"

STATIC_FILE_PATHS=(
  "styles.css"
  "img"
  "favicon.ico"
  "resume.html"
)

TEMP_OUT_DIR=$(mktemp -d -t gitpages-XXXXXX)

[[ -f "$TEMPLATE" ]] || {
  echo "Missing template.html in project root"
  exit 1
}

echo "Searching ${SRC_DIR}"
find "$SRC_DIR" -type f -name "*.html" | while read -r src_file; do
  rel_path="${src_file#$SRC_DIR/}"
  out_file="$TEMP_OUT_DIR/$rel_path"
  out_dir="$(dirname "$out_file")"

  mkdir -p "$out_dir"

  CONTENT="$(cat "$src_file")"
  export CONTENT

  # Strip .html
  no_ext="${rel_path%.html}"

  # Remove trailing /index
  no_index="${no_ext%/index}"

  BREADCRUMBS=""

  if [[ -n "$no_index" ]]; then
    IFS='/' read -ra parts <<< "$no_index"
    for part in "${parts[@]}"; do
        BREADCRUMBS+=" <div>|</div> <a href=\"$no_ext\">$part</a>"
        TITLE="$part - ";
    done
  fi

  export BREADCRUMBS
  export TITLE

  envsubst < "$TEMPLATE" > "$out_file"

  echo "Rendered: $src_file"
done

echo "Copying kept paths to temporary output directory..."
for item in "${STATIC_FILE_PATHS[@]}"; do
  if [[ -e "./$item" ]]; then
    cp -r "./$item" "$TEMP_OUT_DIR/"
    echo "Copied: $item"
  else
    echo "Warning: Path to keep not found: ./$item (Skipping copy)"
  fi
done

echo "Build complete in temporary directory: $TEMP_OUT_DIR"

export TEMP_OUT_DIR
