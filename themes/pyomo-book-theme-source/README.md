# Source-Derived Theme Placeholder

This directory is reserved for a future source-derived custom theme workflow.

It is intentionally empty for now. When we revisit the Colab button customization, the plan is:

1. Start from the upstream `jupyter-book/myst-theme` source repository layout.
2. Create a stock-equivalent repo-hosted theme first.
3. Verify GitHub Pages deployment with no functional changes.
4. Add a minimal source-level Colab action next to the existing GitHub/Edit/Download header actions.

Why this exists:

- `../pyomo-book-theme/` is a preserved prototype built from compiled artifacts.
- That prototype is useful for reference, but it is not the recommended maintenance base.
- This directory marks the clean path we want to use next time.
