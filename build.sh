set -euo pipefail

SRC_DIR="./src"
OUT_DIR="./pages"
TEMPLATE="./template.html"

KEEP_PATHS=(
  "styles.css"
  "img"
  "favicon.ico"
  "resume.html"
)

mkdir -p "$OUT_DIR"

clean_pages() {
  local dir="$1"
  shift
  local keep=("$@")

  shopt -s dotglob nullglob

  for item in "$dir"/*; do
    local name
    name="$(basename "$item")"

    for k in "${keep[@]}"; do
      [[ "$name" == "$k" ]] && continue 2
    done

    rm -rf "$item"
  done

  shopt -u dotglob nullglob
}

[[ -f "$TEMPLATE" ]] || {
  echo "Missing template.html in project root"
  exit 1
}

clean_pages "$OUT_DIR" "${KEEP_PATHS[@]}"

echo "Searching ${SRC_DIR}"
find "$SRC_DIR" -type f -name "*.html" | while read -r src_file; do
  rel_path="${src_file#$SRC_DIR/}"
  out_file="$OUT_DIR/$rel_path"
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
        BREADCRUMBS+=" <div>|</div> <a href=\"$part.html\">$part</a>"
        TITLE="$part - ";
    done
  fi

  export BREADCRUMBS
  export TITLE

  envsubst < "$TEMPLATE" > "$out_file"

  echo "Rendered: $out_file"
done
