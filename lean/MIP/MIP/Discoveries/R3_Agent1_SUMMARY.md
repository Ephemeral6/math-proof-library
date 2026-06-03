# R3 Agent 1 — Ohm-law family compositions

Round 3 brief: derive new theorems by **chaining ≥ 2 existing R-results**
rather than re-mining axioms A.1–A.4.  This agent's group was the Ohm-law
family: T.8 / R.25 / R.26 / R.194 / R.76 / R.114 / R.193 / R.190.

All six files below compile clean (`lake env lean ...` exit 0), use
zero `sorry`, zero new `axiom`, and chain ≥ 2 R-results each.  The
headline file `R3_Agent1_TripleChain.lean` chains **three** R-results
(R.25 + R.194 + R.76) in a single new differential identity.

## Files delivered

| # | File | Status | R-results chained | Theorem count |
|---|---|---|---|---|
| 1 | `R3_Agent1_TBmBracket.lean` | DISCOVERY | R.25 + R.26 | 4 |
| 2 | `R3_Agent1_MinOhmBudget.lean` | DISCOVERY | R.26 + (T.8 abstract) | 4 |
| 3 | `R3_Agent1_TBJacobian.lean` | DISCOVERY | R.25 + R.76 | 5 |
| 4 | `R3_Agent1_DecayCriticalDelta.lean` | DISCOVERY | R.193 + R.194 | 6 |
| 5 | `R3_Agent1_DecayNonMonotone.lean` | OBSERVATION | R.114 + R.194 | 6 |
| 6 | `R3_Agent1_TripleChain.lean` | DISCOVERY (headline) | R.25 + R.194 + R.76 | 6 |

## Headline statements

### (A) T·|B| – Φ₀·Z bracket  (`R3_Agent1_TBmBracket.lean`)

Real-valued bracket compositing R.25's `N = T·|B|` identity with R.26's
strict-positive impedance:

> `Φ₀ · (1/maxΔΦ) ≤ T·|B| ≤ Φ₀·Z + 1`, and the lower side is strictly
> positive when `Φ₀ > 0`.

The lower side strictness is the R.26 contribution; the algebraic
substitution is the R.25 contribution.  Neither file alone gives this
two-sided bracket on the difficulty product.

### (D) Minimum Ohm-budget strict positivity  (`R3_Agent1_MinOhmBudget.lean`)

> Under `Φ₀ > 0` and `maxΔΦ > 0`: `0 < Φ₀·(1/maxΔΦ)` and
> `1 ≤ ⌈Φ₀·(1/maxΔΦ)⌉`.

Headline composition R.26 + T.8 lower-bound ceiling: the smallest
possible Ohm budget is **≥ 1 intervention**.

### (C) (T, |B|) Jacobian identity  (`R3_Agent1_TBJacobian.lean`)

> `HasDerivAt (fun s => T s · B s) (T t · B'(t) + B(t) · T'(t)) t`.

Plus a 4D-coordinate-consistency theorem showing R.76's expanded
total-differential reduces to the (T, B) product-rule when only two
phase-space axes are active.  Closed-form composition R.25 + R.76 via
`HasDerivAt.mul`.

### (B) Decay-transition breakeven  (`R3_Agent1_DecayCriticalDelta.lean`)

> R.193 critical rate `ν_K^c = Rsize/τ̄` ↔ R.194 breakeven:
> `NDecay Phi0 Ztau 0 = ceilENat (Phi0 · Ztau)`.

Plus subcritical-shortfall and supercritical-excess positivity from
R.193, lifted into the R.194 monotonicity envelope.

### (E) Non-monotonicity preserved under decay  (`R3_Agent1_DecayNonMonotone.lean`)

> The decay-cost real surrogate `Phi0·Zinv Z` inherits R.114's
> slope-sign flip: positive slope in the balanced regime, negative in
> the overfit regime over the same `|K|`-pair `(100, 1000)`.  Hence
> **no monotone `h : |K| → N_cost` fits both regimes**.

OBSERVATION-grade because the ENNReal-real lift to the full R.194
ceiling kernel is technical; the real-kernel slope-flip is fully
discharged.

### (F) Triple-chain boundary differential identity  (`R3_Agent1_TripleChain.lean`)

> If both R.25 (`N = T·B`) and R.194 (real kernel `N = N_maint + Φ₀·Z_τ`)
> hold as functions on a neighbourhood of `t`, then by R.76:
>
>     T(t)·B'(t) + B(t)·T'(t)
>       =  N_maint'(t) + Z_τ(t)·Φ₀'(t) + Φ₀(t)·Z_τ'(t).

A single linear identity on the differential 5-tuple
`(T', B', N_maint', Φ₀', Z_τ')` at every boundary point — the joint
differentials lie in a 4-dim subspace of ℝ^5.

Also a clean static-axes corollary: when `T, Φ₀, Z_τ` are held
constant, `T(t)·B'(t) = N_maint'(t)` — the difficulty-rate equals the
maintenance-tax-rate.

## Compositions that broke down

- **T.8 direct chain.** The concrete-MIP T.8 uses `Z := 0`, `Z_min :=
  0`, `Z_max := ⊤`, so its two-sided bound degenerates to `0 ≤ N ≤
  ⊤`.  This kills any *direct* numerical composition with R.25 / R.26
  *at the concrete model level*.  All Ohm-budget compositions here
  use T.8's **abstract real algebraic form** (as expressed in R.25's
  and R.26's parametric hypotheses), not the concrete-model degenerate
  ceiling.  This is honest framing: the new theorems are real-valued
  bracket / positivity / Jacobian statements that any non-degenerate
  Ohm-model extension will satisfy.

- **Direct ENNReal ↔ ℝ chaining.** R.25 lives in `ℝ`, R.194 lives in
  `ENNReal ⊕ ℕ∞`.  Direct chaining requires a `toReal`-lift that
  introduces side conditions (finiteness, non-top); we sidestepped it
  by working at each domain's algebraic kernel and proving the
  composition twice when needed (real form in (E)'s slope-flip; ENNReal
  form in (B)'s NDecay).  This is also honest: the lift exists but is
  not as clean as the kernel-level composition.

- **R.190 sandwich did not produce a new composition** in this agent's
  search.  R.190's content is the same `N_decay ≤ N₀ + N_maint`
  inequality that R.194 already absorbs; chaining R.190 + R.194 just
  re-derives the R.190 sandwich.  Not pursued.

## Statistics

- 6 files, 31 theorems total.
- All files compile clean: `lake env lean MIP/Discoveries/R3_Agent1_*.lean`, exit 0.
- Zero `sorry`, zero new `axiom`, all imports cite ≥ 2 R-results.
- Headline file (TripleChain) chains R.25 + R.194 + R.76 — three
  R-results in one composition.
