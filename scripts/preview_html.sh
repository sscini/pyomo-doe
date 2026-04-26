#!/usr/bin/env bash

# Build and serve the static HTML site locally.
#
# Run from the repository root:
#   bash scripts/preview_html.sh local
#   bash scripts/preview_html.sh pages
#
# Modes:
#   local  Build without BASE_URL and serve at /
#   pages  Build with BASE_URL=/<repo-name> and serve like GitHub Pages
#
# Environment overrides:
#   HTML_PREVIEW_PORT  HTTP server port (default: 8000)

set -euo pipefail

MODE="${1:-local}"
PORT="${HTML_PREVIEW_PORT:-8000}"
REPO_NAME="${REPO_NAME:-$(basename "$(pwd)")}"
BUILD_DIR="$(pwd)/_build/html"
TMP_ROOT=""

cleanup_port() {
    local port="$1"
    local pids
    pids="$(lsof -tiTCP:"${port}" -sTCP:LISTEN 2>/dev/null || true)"
    if [[ -n "${pids}" ]]; then
        echo "Stopping existing listener(s) on port ${port}: ${pids}"
        kill ${pids} 2>/dev/null || true
        sleep 1
    fi
}

cleanup_tmp() {
    if [[ -n "${TMP_ROOT}" && -d "${TMP_ROOT}" ]]; then
        rm -rf "${TMP_ROOT}"
    fi
}

trap cleanup_tmp EXIT

case "${MODE}" in
    local)
        unset BASE_URL
        PREVIEW_ROOT="${BUILD_DIR}"
        PREVIEW_URL="http://localhost:${PORT}/"
        echo "Building static HTML for local root preview"
        ;;
    pages)
        export BASE_URL="/${REPO_NAME}"
        TMP_ROOT="$(mktemp -d /tmp/pyomo-doe-pages-preview.XXXXXX)"
        PREVIEW_ROOT="${TMP_ROOT}"
        PREVIEW_URL="http://localhost:${PORT}/${REPO_NAME}/"
        echo "Building static HTML for GitHub Pages-style preview"
        echo "Using BASE_URL=${BASE_URL}"
        ;;
    *)
        echo "Usage: bash scripts/preview_html.sh [local|pages]"
        exit 1
        ;;
esac

echo "Preprocessing notebooks"
python ./scripts/process_notebooks.py

echo "Refreshing packaged custom theme"
bash ./scripts/build_theme_dist.sh

echo "Building static HTML"
myst build --html

if [[ "${MODE}" == "pages" ]]; then
    ln -s "${BUILD_DIR}" "${TMP_ROOT}/${REPO_NAME}"
fi

echo "Build complete."
echo "Serving static HTML preview at ${PREVIEW_URL}"

cleanup_port "${PORT}"

cd "${PREVIEW_ROOT}"
python -m http.server "${PORT}" &
SERVER_PID=$!

sleep 1

if command -v open >/dev/null 2>&1; then
    open "${PREVIEW_URL}"
elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "${PREVIEW_URL}" >/dev/null 2>&1 || true
else
    echo "Open this URL in your browser: ${PREVIEW_URL}"
fi

wait "${SERVER_PID}"
