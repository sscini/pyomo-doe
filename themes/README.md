# Themes

This directory is for maintainer-only theme work.

Current state:

- The live site currently uses the stock MyST theme from the CLI.
- `pyomo-book-theme/` is a preserved compiled-theme prototype that previously added a Colab header button.
- We are intentionally not editing `pyomo-book-theme/` further by hand, because it contains build artifacts rather than source files intended for maintenance.

Recommended future path:

1. Keep the stock theme active while the site is stable on GitHub Pages.
2. Build a new source-derived custom theme from the upstream `jupyter-book/myst-theme` repository.
3. Verify that a repo-hosted stock-equivalent custom theme deploys correctly.
4. Add the smallest possible Colab header action as a source-level customization.

Useful maintainer helpers:

- `bash scripts/set_theme.sh stock`
- `bash scripts/set_theme.sh prototype`

Additional notes live in:

- `docs/theme-customization-notes.md`
