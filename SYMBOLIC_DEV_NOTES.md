# Symbolic Notebook Dev Notes

## Working Copies

- `notebooks/doe_exercise_symbolic.ipynb`
- `notebooks/doe_four_states_symbolic.ipynb`

These are editable copies of the existing workshop notebooks. The original notebooks remain unchanged.

## Current Goal

Adapt both notebooks so they explicitly show the central finite-difference DoE path and add a symbolic (`pynumero`) comparison.

## Notebook Roles

### `doe_exercise_symbolic.ipynb`

- Main TCLab-centered symbolic notebook
- Keep the workshop flow tied to ParmEst and DoE
- Make the current central finite-difference setup explicit
- Add a `pynumero` version of the same TCLab FIM calculation
- Compare runtime, Jacobian behavior, and FIM behavior

### `doe_four_states_symbolic.ipynb`

- Secondary benchmark/support notebook
- Use as a parameter-scaling benchmark extension
- Keep it clearly separated from the main TCLab teaching flow

## Key Technical Notes

- TCLab uses the native parameterization:
  - `Ua`
  - `Ub`
  - `inv_CpH`
  - `inv_CpS`
- Existing `doe_exercise.ipynb` currently uses the central finite-difference path implicitly via `compute_FIM(method='sequential')`
- The symbolic comparison should use `gradient_method="pynumero"`

## Immediate Next Edits

1. Inspect `doe_exercise_symbolic.ipynb` cell-by-cell
2. Make the central finite-difference path explicit in markdown and code
3. Add a matching `pynumero` FIM block
4. Add timing and comparison cells
5. Inspect `doe_four_states_symbolic.ipynb` for benchmark-style adaptation

## Progress Update

### `doe_exercise_symbolic.ipynb`

The notebook now includes a new end section after the D-optimality discussion:

- `## Sensitivity Computation for the Design of Experiments`
- a markdown cell introducing the sensitivity matrix `Q`
- a markdown cell introducing the FIM expression `M = Q^T \Sigma^{-1} Q`
- a markdown cell contrasting:
  - central finite differences via parameter perturbations
  - automatic differentiation via PyNumero

A new empty code cell has been added after this markdown section and is available for the first comparison block.

### `doe_four_states_symbolic.ipynb`

No reviewer-facing symbolic content has been added yet. Current changes appear limited to notebook metadata / kernel information.
