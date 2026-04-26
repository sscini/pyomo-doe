#!/usr/bin/env bash

# Run this script from the root directory of this project

set -euo pipefail

BOOK_PORT="${BOOK_PORT:-4300}"
BOOK_SERVER_PORT="${BOOK_SERVER_PORT:-4301}"
BOOK_URL="http://localhost:${BOOK_PORT}"

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

python ./scripts/process_notebooks.py
bash ./scripts/build_theme_dist.sh
jupyter book build --all

echo "Build complete."
echo "Starting local preview at ${BOOK_URL}"

cleanup_port "${BOOK_PORT}"
cleanup_port "${BOOK_SERVER_PORT}"

jupyter book start --port "${BOOK_PORT}" --server-port "${BOOK_SERVER_PORT}" &
JB_PID=$!

for _ in $(seq 1 30); do
    if curl --silent --fail "${BOOK_URL}" >/dev/null 2>&1; then
        break
    fi
    if ! kill -0 "${JB_PID}" >/dev/null 2>&1; then
        wait "${JB_PID}"
    fi
    sleep 1
done

if curl --silent --fail "${BOOK_URL}" >/dev/null 2>&1; then
    if command -v open >/dev/null 2>&1; then
        open "${BOOK_URL}"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "${BOOK_URL}" >/dev/null 2>&1 || true
    else
        echo "Open this URL in your browser: ${BOOK_URL}"
    fi
else
    echo "The preview server did not become ready at ${BOOK_URL}."
fi

wait "${JB_PID}"
