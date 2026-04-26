#!/usr/bin/env bash

# Build the same static HTML artifact that GitHub Actions publishes.
#
# Run from the repository root:
#   bash scripts/publish.sh
#
# This is a local sanity-check for the CI publishing workflow. It does not
# deploy anything by itself.

set -euo pipefail

echo "Preprocessing notebooks"
python ./scripts/process_notebooks.py

echo "Refreshing packaged custom theme"
bash ./scripts/build_theme_dist.sh

echo "Building GitHub Pages HTML artifact"
myst build --html

echo "Build complete."
echo "The GitHub Pages artifact is in: ./_build/html"
echo "Deployment itself is handled by .github/workflows/deploy.yml after a push to main."
