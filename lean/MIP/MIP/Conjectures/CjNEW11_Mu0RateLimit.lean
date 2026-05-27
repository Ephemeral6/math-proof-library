/-
Conjecture Cj.NEW-11 — `dμ₀/dt ∝ ρ` rate-limit law (grey-band depletion).

Reference: `conjectures/index.md` Cj.NEW-11 (index lines ~672-694);
`workspace/mu0_measurement_theory.md` §12 (III-1).

**Faithful conjecture (natural language).**
During training, the instantaneous growth rate of the absolute-reliability
measure `μ₀` is rate-limited by the eigen-spectrum grey-band measure `ρ`:

    dμ₀(X(t), P)/dt  ≤  α_max(t) · ρ_{X(t)}(ε*)

where `α_max(t) ≤ α_∞ < ∞` is the training algorithm's "grey-band → absolute
domain" conversion-rate ceiling and `ε*` is a fixed precision parameter.

Main corollary (a) — **Saturation Theorem**:

    ρ_{X(t)}(ε*) → 0   ⟹   dμ₀/dt → 0

("grey band depletes ⟹ μ₀ stalls").

**Formalization choices.**
* The training-time families are real-valued functions of `t : ℕ`
  (discrete training steps): `dmu0 : ℕ → ℝ` is `dμ₀/dt`, `alphaMax : ℕ → ℝ`
  is `α_max(t)`, `rho : ℕ → ℝ` is `ρ_{X(t)}(ε*)`.
* The rate-limit inequality itself requires a formalization of the training
  update rule (SGD/Adam/RLHF) to derive `α_max` — that is **OPEN** (the
  index lists it under 前置: "需基于具体训练算法推出 α 的具体形式"). We take
  the rate-limit `dmu0 t ≤ alphaMax t · rho t` as a *hypothesis bundle*
  (`RateLimit`), together with the structural facts `0 ≤ dmu0 t` (μ₀ is
  non-decreasing under monotone training: the grey-band only flows toward the
  absolute domain, §10 (I-3) flow picture) and a uniform ceiling
  `alphaMax t ≤ α_∞` (the index's `α_max(t) ≤ α_∞ < ∞`).
* `ρ → 0` is `Filter.Tendsto rho atTop (𝓝 0)`; the conclusion `dμ₀/dt → 0`
  is `Filter.Tendsto dmu0 atTop (𝓝 0)`.

**What is PROVED here (corollary (a), conditional on the bound-as-hypothesis):**
the saturation implication via a two-sided squeeze
`0 ≤ dmu0 t ≤ α_∞ · rho t`, with `α_∞ · rho t → 0`.
This is sorry-free and uses only Mathlib `Filter.Tendsto` machinery.

**VERDICT: OPEN.**
The rate-limit inequality `dμ₀/dt ≤ α_max·ρ` itself is NOT proved (it needs
the training update-rule formalization, absent from the opaque layer); it is
bundled as a hypothesis. The substantive, clean **corollary (a) — the
saturation theorem — IS proved** as a conditional implication from that
bundle. Per the anti-strawman rule: the full conjecture (the bound) is OPEN;
the proven content is the genuine squeeze corollary, not a degenerate
weakening.

This file is axiom-free (only A.1–A.4 available; this file needs none —
pure real analysis on `Filter.Tendsto`).
-/
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real

namespace MIP

namespace CjNEW11_Mu0RateLimit

open Filter Topology

/-! ## Statement bundle

`dmu0 t  =  dμ₀(X(t), P)/dt`,  `alphaMax t  =  α_max(t)`,  `rho t  =  ρ_{X(t)}(ε*)`.
All real-valued functions of the discrete training step `t : ℕ`. -/

/-- The Cj.NEW-11 rate-limit bound, bundled as a `Prop` over the training
families: `dμ₀/dt(t) ≤ α_max(t) · ρ(t)` for every training step. -/
def RateLimit (dmu0 alphaMax rho : ℕ → ℝ) : Prop :=
  ∀ t : ℕ, dmu0 t ≤ alphaMax t * rho t

/-- **Cj.NEW-11 — Saturation Theorem (corollary (a)), conditional form.**

Hypotheses (the bundle):
* `hRate : RateLimit dmu0 alphaMax rho` — the rate-limit inequality
  `dμ₀/dt ≤ α_max·ρ` (itself OPEN; carried as a hypothesis);
* `hNonneg : ∀ t, 0 ≤ dmu0 t` — μ₀ is non-decreasing under monotone training
  (grey-band → absolute flow, §10 (I-3));
* `hRhoNonneg : ∀ t, 0 ≤ rho t` — `ρ` is a measure (`∈ [0,1]`);
* `hCeil : ∀ t, alphaMax t ≤ αInf` and `hαInf : 0 ≤ αInf` — the uniform
  conversion-rate ceiling `α_max(t) ≤ α_∞ < ∞`;
* `hRhoLim : Tendsto rho atTop (𝓝 0)` — grey-band depletion `ρ → 0`.

Conclusion: `dμ₀/dt → 0` — μ₀ saturates.

The proof is a two-sided squeeze: `0 ≤ dmu0 t ≤ α_∞ · rho t`, where the upper
bound `α_∞ · rho t → 0` because `rho t → 0` and `α_∞` is constant. -/
theorem saturation
    (dmu0 alphaMax rho : ℕ → ℝ) (αInf : ℝ)
    (hRate : RateLimit dmu0 alphaMax rho)
    (hNonneg : ∀ t, 0 ≤ dmu0 t)
    (hRhoNonneg : ∀ t, 0 ≤ rho t)
    (hCeil : ∀ t, alphaMax t ≤ αInf)
    (_hαInf : 0 ≤ αInf)
    (hRhoLim : Tendsto rho atTop (𝓝 0)) :
    Tendsto dmu0 atTop (𝓝 0) := by
  -- Upper envelope `g t := αInf * rho t → 0`.
  have hg : Tendsto (fun t => αInf * rho t) atTop (𝓝 (αInf * 0)) :=
    hRhoLim.const_mul αInf
  rw [mul_zero] at hg
  -- Lower envelope: constant `0 → 0`.
  have h0 : Tendsto (fun _ : ℕ => (0 : ℝ)) atTop (𝓝 0) := tendsto_const_nhds
  -- Pointwise sandwich `0 ≤ dmu0 t ≤ αInf * rho t`.
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le h0 hg
    (fun t => hNonneg t) (fun t => ?_)
  -- `dmu0 t ≤ alphaMax t * rho t ≤ αInf * rho t` (since `alphaMax t ≤ αInf`
  -- and `rho t ≥ 0`).
  calc dmu0 t ≤ alphaMax t * rho t := hRate t
    _ ≤ αInf * rho t := by
        apply mul_le_mul_of_nonneg_right (hCeil t) (hRhoNonneg t)

/-! ## Sharper corollary — rate also vanishes if `α_max → 0` (out-of-domain
exit closure, index corollary (b) flavour).

Even without `ρ → 0`, if the conversion-rate ceiling itself collapses
(`α_max → 0`, e.g. RLHF without new-knowledge injection: `K` not expanding),
then `dμ₀/dt → 0`. Same squeeze, with the roles of the two factors swapped:
`0 ≤ dmu0 t ≤ alphaMax t · ρ_sup` once `ρ` is uniformly bounded by `ρ_sup`. -/

/-- **Cj.NEW-11 — exit-closure variant (corollary (b) flavour).**

If the grey-band measure stays uniformly bounded (`rho t ≤ rhoSup`) but the
conversion-rate ceiling collapses (`alphaMax → 0`), then `dμ₀/dt → 0`.
(`α_max → 0` is the "exit closed: `K` not expanding" mechanism of corollary
(b).) Squeeze with envelope `alphaMax t · rhoSup → 0`. -/
theorem saturation_of_alpha_to_zero
    (dmu0 alphaMax rho : ℕ → ℝ) (rhoSup : ℝ)
    (hRate : RateLimit dmu0 alphaMax rho)
    (hNonneg : ∀ t, 0 ≤ dmu0 t)
    (hAlphaNonneg : ∀ t, 0 ≤ alphaMax t)
    (hRhoBdd : ∀ t, rho t ≤ rhoSup)
    (hRhoNonneg : ∀ t, 0 ≤ rho t)
    (hAlphaLim : Tendsto alphaMax atTop (𝓝 0)) :
    Tendsto dmu0 atTop (𝓝 0) := by
  have hrhoSup_nonneg : 0 ≤ rhoSup := le_trans (hRhoNonneg 0) (hRhoBdd 0)
  -- Upper envelope `g t := alphaMax t * rhoSup → 0`.
  have hg : Tendsto (fun t => alphaMax t * rhoSup) atTop (𝓝 (0 * rhoSup)) :=
    hAlphaLim.mul_const rhoSup
  rw [zero_mul] at hg
  have h0 : Tendsto (fun _ : ℕ => (0 : ℝ)) atTop (𝓝 0) := tendsto_const_nhds
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le h0 hg
    (fun t => hNonneg t) (fun t => ?_)
  calc dmu0 t ≤ alphaMax t * rho t := hRate t
    _ ≤ alphaMax t * rhoSup := by
        apply mul_le_mul_of_nonneg_left (hRhoBdd t) (hAlphaNonneg t)

/-! ## MISSING / BLOCKED AT (the OPEN core)

The rate-limit inequality `RateLimit dmu0 alphaMax rho`, i.e.

    dμ₀/dt ≤ α_max(t) · ρ_{X(t)}(ε*),

is NOT derived here. Deriving it requires:

* a formalization of the **training update rule** (SGD / Adam / RLHF) acting on
  the agent family `X(t)` — the index's 前置 "α_max(t) 的形式化（需基于具体训练
  算法——SGD / Adam / RLHF 的 update rule 推出）";
* a continuity / differentiability layer for `t ↦ μ₀(X(t), P)` (the opaque
  layer `MIP.Axioms` carries no time-indexed agent family and no `μ₀`
  functional);
* the partition-function dynamics of §13 (IV-1) to pin the explicit form of the
  conversion rate `α_max`.

None of these is available in the current opaque signature layer, so the bound
is bundled as the hypothesis `RateLimit`. The **proven** content above is the
genuine squeeze corollary (saturation), which is the conjecture's stated
"主要推论 (a)". -/

end CjNEW11_Mu0RateLimit

end MIP
