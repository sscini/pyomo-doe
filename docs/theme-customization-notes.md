# Theme Customization Notes

This note is for maintainers. It documents the local Jupyter Book / MyST theme customizations in this repository without adding noise to the main user-facing README.

The main `Readme.md` in this repository should remain a landing page for workshop users. Theme experiments, deployment debugging, and maintainer-only implementation details belong here instead.

Maintainer helpers added during this cleanup:

- `bash scripts/set_theme.sh stock`
- `bash scripts/set_theme.sh prototype`

## Current Status

As of April 25, 2026, the vendored custom theme remains in this repository, but the stock MyST theme is currently enabled in `myst.yml`.

- The vendored theme is preserved so we can switch back later without reconstructing it.
- The current fallback to the stock theme is temporary and is intended to simplify GitHub Pages debugging.

## What We Changed

We moved away from patching the downloaded `_build/templates/...` theme at build time and instead vendored the MyST book theme into this repository.

The main goals were:

- make local preview and GitHub Pages deployment deterministic
- avoid fragile runtime patching of generated theme assets
- add a Colab launch button next to the GitHub / edit / download actions on notebook pages

## Where The Custom Theme Lives

The vendored theme is stored here:

- `themes/pyomo-book-theme/`

Important files include:

- `themes/pyomo-book-theme/template.yml`
- `themes/pyomo-book-theme/server.js`
- `themes/pyomo-book-theme/build/index.js`
- `themes/pyomo-book-theme/public/build/manifest-45CD0E76.js`
- `themes/pyomo-book-theme/public/build/routes/$-L6MITV77.js`
- `themes/pyomo-book-theme/public/build/routes/_index-4AIAQW4G.js`
- `themes/pyomo-book-theme/public/build/_shared/chunk-MG6QZF7H-pyomo.js`

The vendored theme is not currently enabled.

To restore it later, edit `myst.yml` and restore:

- `site.template: themes/pyomo-book-theme`

At the moment, this vendored theme should be treated as a preserved prototype rather than the recommended long-term customization path.

The `themes/` directory now also contains:

- `themes/README.md`
- `themes/pyomo-book-theme-source/README.md`

These document the intended future source-derived customization workflow.

## How The Colab Button Works

The Colab button is implemented as a theme-level header action for notebook pages.

Behavior:

- only notebook-backed pages should show the button
- the button URL is derived from the page source URL
- a GitHub notebook URL such as
  `https://github.com/dowlinglab/pyomo-doe/blob/main/notebooks/foo.ipynb`
  is converted to
  `https://colab.research.google.com/github/dowlinglab/pyomo-doe/blob/main/notebooks/foo.ipynb`

Implementation notes:

- the server-rendered theme bundle was updated so the Colab link appears in the initial HTML
- the vendored client assets were kept aligned with the same implementation so hydration does not remove or duplicate the button
- the current implementation no longer relies on a temporary DOM-injection fallback
- the shared client chunk now uses a versioned filename to reduce stale-asset behavior during local Safari refreshes
- the final HTML and hydrated page should contain exactly one Colab link per notebook page

## Verified Behavior

As of April 25, 2026, the local preview was rechecked after simplifying the implementation.

Verified on:

- `http://localhost:4300/notebooks/parmest-multistart-profilelikelihood`

Observed header actions on that notebook page:

- GitHub
- Colab
- Edit
- Downloads

The page now renders a single Colab icon in the header action row, and the duplicate-icon behavior caused by the earlier fallback injector is gone.

Safari note:

- on a local soft refresh in Safari, a transient second Colab icon may still appear briefly before the page settles
- on a hard refresh, the page consistently settles to the correct single-icon state
- this was acceptable for deployment because the final hydrated state is correct and the GitHub Pages deployment will ship the committed vendored assets directly

## Build / Preview Scripts

These scripts were updated during the custom-theme work:

- `scripts/build_local.sh`
- `scripts/publish.sh`
- `scripts/preview_html.sh`

Static HTML preview modes:

- `bash scripts/preview_html.sh local`
  - builds static HTML without `BASE_URL`
  - serves the site at `http://localhost:8000/`
  - useful for checking the root static export locally
- `bash scripts/preview_html.sh pages`
  - builds static HTML with `BASE_URL=/<repo-name>`
  - serves the site at `http://localhost:8000/<repo-name>/`
  - useful for checking behavior that should match GitHub Pages project-site deployment

GitHub Pages is configured via:

- `.github/workflows/deploy.yml`

The workflow:

- installs Python and `nbformat` for notebook preprocessing
- installs MyST Markdown via npm
- runs `scripts/process_notebooks.py`
- builds the site with `myst build --html`
- publishes `./_build/html` to GitHub Pages

Why `./_build/html` is used for GitHub Pages:

- the local MyST preview flow uses `./_build/site` for the app/content server layout
- GitHub Pages needs a static site root with a top-level `index.html`
- `./_build/site/public` did not include a root `index.html`, which caused a successful deploy to still return a 404
- `./_build/html` is the correct static publish target for this repository

## Maintenance Guidance

If we revisit this later, the preferred long-term improvement is still not to patch compiled bundles by hand. The cleaner future direction would be:

- start from the actual upstream `myst-theme` source repository rather than this build-artifact snapshot
- make the Colab button a source-level theme action, similar in spirit to the built-in MyST launch button
- verify that a stock-but-source-derived vendored theme deploys cleanly from this repository
- then add the smallest possible Colab customization and rebuild the theme assets
- only after that, vendor the resulting built theme back into this repository if needed

For now, the vendored theme is preserved but disabled. That gives us a clean fallback path:

- use the stock theme while debugging GitHub Pages behavior
- switch back later by restoring `site.template: themes/pyomo-book-theme` in `myst.yml`

Current recommendation:

- keep the stock theme enabled for the live site
- avoid further hand-editing of `themes/pyomo-book-theme/`, because it contains compiled build artifacts rather than source files intended for human maintenance
- treat a future source-derived custom theme as a separate follow-on effort

Concrete next-step plan for that follow-on effort:

1. Start from the upstream `jupyter-book/myst-theme` source repository, not from compiled artifacts.
2. Reproduce a stock-equivalent repo-hosted theme first.
3. Confirm GitHub Pages deployment works with that theme and `BASE_URL=/pyomo-doe`.
4. Only then add the smallest possible Colab header action.

## Deployment Debugging Notes

As of April 25, 2026, GitHub Pages deployment debugging surfaced an important distinction between local preview modes and static deployment modes.

Observed behavior:

- the GitHub Pages workflow could succeed while the deployed site still rendered the MyST `BASE_URL` warning page
- the deployed HTML contained root-absolute links such as `/build/...` and `/tclab` rather than repository-prefixed links such as `/pyomo-doe/build/...`
- this caused assets and routes to fail when the site was hosted at `https://dowlinglab.github.io/pyomo-doe/`

Important conclusions:

- this did not initially look like a theme-only failure
- it appeared more likely to be a mismatch between the static deployment build command and the MyST deployment guidance
- the MyST deployment docs explicitly describe static deployment using `myst build --html`
- the GitHub Pages docs for MyST also show `myst init --gh-pages` paired with `myst build --html`

Planned next step:

- re-test whether the generated `_build/html/index.html` correctly prefixes links with `BASE_URL=/pyomo-doe`

Fallback chosen on April 25, 2026:

- temporarily switch `myst.yml` back to the stock theme
- keep `themes/pyomo-book-theme/` in the repo so the custom theme can be re-enabled with a one-line configuration change

Rationale for this plan:

- `jupyter book start` remains the right tool for app-style local preview
- `myst build --html` appears to be the canonical static deployment/export path in current MyST documentation
- if the `BASE_URL` issue disappears after switching to `myst build --html`, then the problem is the static export path rather than the vendored theme itself
