#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MYST_FILE="$ROOT_DIR/myst.yml"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/set_theme.sh stock
  bash scripts/set_theme.sh prototype

Modes:
  stock
    Use the bundled MyST stock theme by commenting out site.template.

  prototype
    Re-enable the preserved compiled-theme prototype at
    themes/pyomo-book-theme.
EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

mode="$1"

case "$mode" in
  stock)
    python - "$MYST_FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = "site:\n  template: themes/pyomo-book-theme\n"
new = "site:\n  # To restore the vendored custom theme later, uncomment:\n  # template: themes/pyomo-book-theme\n"
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text)
PY
    echo "Switched myst.yml to stock theme."
    ;;
  prototype)
    python - "$MYST_FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = "site:\n  # To restore the vendored custom theme later, uncomment:\n  # template: themes/pyomo-book-theme\n"
new = "site:\n  template: themes/pyomo-book-theme\n"
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text)
PY
    echo "Re-enabled vendored theme prototype in myst.yml."
    ;;
  *)
    usage
    exit 1
    ;;
esac
