# Run this script from the root directory of this project

set -euo pipefail

python ./scripts/process_notebooks.py
jupyter book build --all

echo "Jupyter Book 2 no longer uses the legacy 'jb build' / 'ghp-import' publish flow."
echo "To configure GitHub Pages deployment, run: jupyter book init --gh-pages"
