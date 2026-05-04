# Notes: SGD Signal-Noise Generalization Decomposition

## Proof technique

**Algorithmic stability** (Hardt-Recht-Singer 2016 framework) with the per-step perturbation explicitly decomposed into a **signal-contraction step** (non-expansive under convex `L`-smooth + `η ≤ 2/L`, by Baillon-Haddad co-coercivity) and a **noise-differential step** (`η · [∇L_N(θ_t;z_i) − ∇L_N(θ_t^{(i)};z'_i)]`). The signal/noise split is at the gradient level, not the loss level: `∇ℓ(θ;z) = ∇L_S(θ) + ∇L_N(θ;z)` with the latter being mean-zero.

**Critical observation:** The leave-one-out chain `θ_T^{(i)}` is independent of `z_i`. This gives the *first-order vanishing* `E[L_N(θ_T^{(i)};z_i)] = 0`, which is the core of the gen-gap reduction.

## Key steps

1. **Gen gap reduction:** `gen(S) = −(1/m)Σ_i L_N(θ_T(S);z_i)` (exact identity using `L_S` cancellation in the empirical-population subtraction).

2. **Leave-one-out symmetrization:** subtract `L_N(θ_T^{(i)};z_i)` (mean-zero) to convert to a stability quantity `‖θ_T(S) − θ_T^{(i)}‖`.

3. **Cauchy-Schwarz at the loss level:** `|gen| ≤ σ_N · √(E‖δ_T‖^2)`. This is a `σ_N` (not `σ_N^2`) factor; the `σ_N^2` comes when `√Δ_T` itself contains a `σ_N` factor.

4. **Per-step recursion (signal/noise split):** when `i_t = i`, `δ_{t+1} = A_t − η N_t` with `A_t` non-expansive image of `δ_t` and `N_t` the noise differential. Squaring + Cauchy-Schwarz on cross-term gives `Δ_{t+1} ≤ Δ_t + (1/m)[4η σ_N √Δ_t + 4 η^2 σ_N^2]`.

5. **Induction on quadratic ansatz:** `Δ_t ≤ 16 η^2 σ_N^2 (t/m + t^2/m^2)`, verified by direct expansion.

## Audit result

3 rounds of fixing required:
- Round 1: linearization fix (squared recursion was exponentially blowing up).
- Round 2: removed the (incorrect) Taylor second-order trick that would have given `η^2` scaling (cross-term doesn't vanish).
- Round 3: hardened constants to handle small-`m` cases.

NumPy verification (600 trials × 6 regimes) confirms the bound is **valid in all tested settings**, with the empirical gap being 1.5–2.4% of the theoretical bound (i.e., bound is conservative by ~50× constant, but the **functional form** `√(T/m)` matches empirical scaling).

## Comparison with Hardt-Recht-Singer (HRS) 2016

| Regime | HRS bound | Our bound | Verdict |
|---|---|---|---|
| `T ≥ m` (multi-epoch) | `O((G_S^2+σ_N^2) ηT/m)` | `O((G_S^2+σ_N^2) ηT/m)` | Same order, ~4× worse constant |
| `T < m` (single-epoch) | `O((G_S^2+σ_N^2) ηT/m)` | `O((G_S^2+σ_N^2) η√(T/m))` | **Strictly worse** by `√(m/T)` |

**Strict tightness** (the second claim) does NOT hold via this stability proof. The Zhang et al. ICLR 2022 strict-tightness requires either:
- PAC-Bayes with prior centered on deterministic-GD trajectory `θ̃_T` (transfers `G_S` motion to the prior, pays only `σ_N^2`-driven KL), or
- Last-iterate convergence of `L_S(θ_T) → min L_S` with `O(η^2)` variance (decoupling signal contribution).

## Related results

- **HRS 2016:** uniform stability of SGD on convex `L`-smooth losses, `ε = G^2 ηT/m`. Stronger because it uses `G^2` (worst-case Lipschitz) directly; our `√Δ_T` route loses a `√(T/m)` factor.
- **Bousquet–Elisseeff 2002:** classical stability framework; we instantiate at the leave-one-out level.
- **Xu-Raginsky 2017:** information-theoretic generalization bounds in terms of `I(W;S)`; could give a sharper bound under noise structure but requires conditional MI computation.
- **PAC-Bayes (Catoni-style, McAllester):** gives data-dependent priors; the Zhang et al. paper effectively uses PAC-Bayes with prior on the signal trajectory.

## Honest scope of this proof

**What we proved:**
- A **valid** `G_S(T) + G_N(T)` decomposition of the gen gap, with explicit constants.
- Both terms have the same functional form `O(η · X · (√(T/m) + T/m))` where `X = G_S^2` or `σ_N^2`.

**What we did NOT prove:**
- The original paper's exponents `O(η^2 T/m)` for `G_S` and `O(η/m)` for `G_N` (no `T`).
- Strict tightness over HRS in any single regime.

The honest scope adjustment is documented per the problem's instruction to "state extra conditions if Claim 2 only holds conditionally."
