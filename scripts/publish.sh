# Run this script from the root directory of this project

set -euo pipefail

python ./scripts/process_notebooks.py
bash ./scripts/build_theme_dist.sh
myst build --html

echo "Build complete."
echo "For GitHub Pages deployment, commit and push your changes to main."
echo "The site is published by GitHub Actions via .github/workflows/deploy.yml."
echo "Built Pages artifact directory: ./_build/html"
