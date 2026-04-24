# Physically Informed `theta` and `prior_FIM` Rationale (TCLab)

This note documents how the physically informed prior values used in
`acc_contrib_SSC/parmest_regularization.ipynb` were chosen.

## 1) Model structure used for intuition

The TCLab model equations in this repo are:

- Heater node dynamics:
  - `dTh/dt = (Ua*(Tamb-Th) + Ub*(Ts-Th) + alpha*P*u) * inv_CpH`
- Sensor node dynamics:
  - `dTs/dt = Ub*(Th-Ts) * inv_CpS`

See local source:

- `notebooks/tclab_pyomo.py` lines 426-452 (ODE definitions)
- `notebooks/tclab_pyomo.py` line 611 (unknown parameter order: `Ua, Ub, inv_CpH, inv_CpS`)

These equations are lumped-capacitance energy balances with Newton-style linear heat transfer terms.

## 2) Physical interpretation of the four parameters

- `Ua` (W/K): net heat loss from heater node to ambient.
- `Ub` (W/K): heater-to-sensor thermal coupling.
- `CpH` (J/K): effective thermal capacitance of heater node.
- `CpS` (J/K): effective thermal capacitance of sensor node.

In estimator space, the model uses `inv_CpH = 1/CpH` and `inv_CpS = 1/CpS`.

## 3) Prior mean (`theta0`) choices

Chosen nominal physical values:

- `Ua = 0.050` W/K
- `Ub = 0.015` W/K
- `CpH = 6.5` J/K
- `CpS = 0.35` J/K

Converted to estimator-space reference values:

- `theta0_phys = {Ua, Ub, inv_CpH=1/6.5, inv_CpS=1/0.35}`

These values are intentionally close to previously estimated magnitudes in this notebook workflow, while preserving physically plausible heat-transfer/capacitance scales.

## 4) Confidence assumptions (covariance model)

A prior covariance was built in physical parameter space using:

### 4.1 Standard deviations

- `sigma(Ua)=0.012`
- `sigma(Ub)=0.005`
- `sigma(CpH)=1.5`
- `sigma(CpS)=0.12`

### 4.2 Correlation assumptions

Correlation matrix in `[Ua, Ub, CpH, CpS]` order:

```text
[[ 1.00, -0.25,  0.55, 0.10],
 [-0.25,  1.00,  0.40, 0.75],
 [ 0.55,  0.40,  1.00, 0.20],
 [ 0.10,  0.75,  0.20, 1.00]]
```

Reasoning:

- `Ub` and `CpS` positively correlated: sensor-lag dynamics depend strongly on `Ub/CpS`.
- `Ua` and `CpH` positively correlated: heater time constant depends on `(Ua+Ub)/CpH`.
- `Ua` and `Ub` mildly negative: both can partially trade off in fitting heater cooling behavior.

## 5) Mapping covariance to estimator parameterization

Because parmest estimates `[Ua, Ub, inv_CpH, inv_CpS]`, covariance is transformed with a Jacobian:

- `x = g(p)` where `p=[Ua, Ub, CpH, CpS]` and `x=[Ua, Ub, 1/CpH, 1/CpS]`
- `Sigma_x = J * Sigma_p * J^T`

with diagonal Jacobian

```text
J = diag(1,
         1,
         -1/CpH^2,
         -1/CpS^2)
```

## 6) Prior Fisher Information Matrix

The prior information matrix is defined as:

- `prior_FIM_phys = inv(Sigma_x)`

An optional scale factor `prior_weight` is applied (currently `0.05`) to tune prior strength relative to data SSE in regularized estimation.

## 7) Where this is implemented in notebook

In `acc_contrib_SSC/parmest_regularization.ipynb`, see the appended physical-prior cell containing:

- `theta_phys`, `sigma_phys`, `corr_phys`
- Jacobian transform to estimator-space covariance
- `prior_FIM_phys`
- L1 call:
  - `parmest.Estimator(..., regularization='L1', prior_FIM=prior_FIM_phys, theta_ref=theta0_phys)`

## 8) Sources

### Local repo sources

- TCLab equations and unknown parameter ordering:
  - `notebooks/tclab_pyomo.py` lines 426-452 and 611
- Physical-prior implementation cell:
  - `acc_contrib_SSC/parmest_regularization.ipynb` (search for `theta_phys`, `corr_phys`, `prior_FIM_phys`, `pest_regL1_phys`)

### External references

- Newton cooling / lumped-capacitance intuition:
  - https://en.wikipedia.org/wiki/Newton%27s_law_of_cooling
- Fisher Information Matrix concept (information/covariance relationship):
  - https://en.wikipedia.org/wiki/Fisher_information
- Covariance propagation with Jacobian (`Sigma_y = J Sigma_x J^T`):
  - https://en.wikipedia.org/wiki/Propagation_of_uncertainty
- Pyomo parmest package docs:
  - https://pyomo.readthedocs.io/en/6.9.3/explanation/analysis/parmest/index.html
  - Source/API pages used for implementation context:
    - https://pyomo.readthedocs.io/en/stable/_modules/pyomo/contrib/parmest/parmest.html
    - https://pyomo.readthedocs.io/en/latest/api/pyomo.contrib.parmest.parmest.Estimator.html

## 9) Notes

- The prior is intentionally "weak-to-moderate" and not a hard constraint.
- If optimization is over-regularized, reduce `prior_weight`.
- If non-identifiability persists (flat profile likelihood), increase prior weight slightly or tighten selected prior variances.

---

## 10) Thermodynamics-first prior (independent of previous fitted guesses)

This section intentionally does **not** use previous regression estimates as input. It starts from heat-transfer and thermal-mass reasoning.

### 10.1 Thermodynamic basis

Using lumped balances,

- Heater time scale is approximately
  - `tau_H ~ CpH / (Ua + Ub)`
- Sensor lag time scale is approximately
  - `tau_S ~ CpS / Ub`

and heat transfer follows Newton-type linearized exchange (`q ~ U * DeltaT`) with effective conductances.

Plausible TCLab-scale assumptions:

- Natural convection + radiation produce heater-to-ambient conductance in the few `1e-2 W/K` range.
- Heater-to-sensor coupling (through mounting/conduction path) is typically same order, often slightly smaller.
- Effective heater thermal capacitance is order `1-10 J/K`.
- Effective sensor thermal capacitance is order `0.05-0.5 J/K`.

### 10.2 Recommended physically based prior mean

In physical space:

- `Ua = 0.030 W/K`
- `Ub = 0.018 W/K`
- `CpH = 7.5 J/K`
- `CpS = 0.22 J/K`

Mapped to estimator space (`Ua, Ub, inv_CpH, inv_CpS`):

- `Ua = 0.030`
- `Ub = 0.018`
- `inv_CpH = 1/7.5 = 0.1333`
- `inv_CpS = 1/0.22 = 4.5455`

### 10.3 Uncertainty and correlation (physical rationale)

Suggested 1-sigma uncertainty (physical space):

- `sigma(Ua) = 0.012` (40%)
- `sigma(Ub) = 0.0072` (40%)
- `sigma(CpH) = 2.25` (30%)
- `sigma(CpS) = 0.11` (50%)

Suggested correlation matrix in `[Ua, Ub, CpH, CpS]`:

```text
[[ 1.00, -0.20,  0.55, 0.05],
 [-0.20,  1.00,  0.25, 0.75],
 [ 0.55,  0.25,  1.00, 0.30],
 [ 0.05,  0.75,  0.30, 1.00]]
```

Interpretation:

- `Ub`-`CpS` strong positive: both govern sensor lag (`tau_S`).
- `Ua`-`CpH` moderate positive: both govern heater time scale (`tau_H`).
- `Ua`-`Ub` mild negative: partial competition in heater cooling pathways.

### 10.4 Resulting covariance and prior FIM in estimator space

After Jacobian transform from `[Ua, Ub, CpH, CpS]` to
`[Ua, Ub, inv_CpH, inv_CpS]`, the covariance is:

```text
               Ua        Ub   inv_CpH   inv_CpS
Ua       0.000144 -0.000017 -0.000264 -0.001364
Ub      -0.000017  0.000052 -0.000072 -0.012273
inv_CpH -0.000264 -0.000072  0.001600  0.027273
inv_CpS -0.001364 -0.012273  0.027273  5.165289
```

and the corresponding prior information matrix `prior_FIM = inv(cov)` is:

```text
                Ua         Ub   inv_CpH  inv_CpS
Ua       12923.299  12435.627  2340.824   20.599
Ub       12435.627  56127.396  2470.870  123.596
inv_CpH   2340.824   2470.870  1111.891    0.618
inv_CpS     20.599    123.596     0.618    0.489
```

If needed, apply a global scalar `prior_weight` (for example `0.05-0.2`) to tune regularization strength relative to SSE.

## 11) Additional TCLab details that would significantly improve this prior

If you can share these, I can tighten the prior with much stronger physical backing:

- Heater plate geometry and material (dimensions, thickness, alloy).
- Sensor package type/mass and exact mounting (epoxy amount, contact area).
- Surface finish / emissivity estimate for heater assembly.
- Fan/airflow condition (still air vs forced convection).
- A short clean step-response test summary:
  - approximate heater-node rise time,
  - sensor lag time,
  - steady-state `DeltaT` at known input power.
- Measurement-noise estimate for `T1/T2` in your setup.

With these, we can derive tighter ranges for `Ua, Ub, CpH, CpS`, then regenerate a more defensible covariance and prior FIM.
