# Run this script from the root directory of this project

set -euo pipefail

python ./scripts/process_notebooks.py
jupyter book build --all

echo "Build complete."
echo "Preview locally with: jupyter book start"
