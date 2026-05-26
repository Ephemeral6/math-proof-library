/-
Result R.407 — Goodhart / reward-hacking as an A.2-coverage **failure**.

Reference: `~/Desktop/MIP/workspace/theory_unification.md` §R.407
("Reward Hacking / Goodhart 作为 A.2 失效定理", 2026-05-16).

**Mapping conditions (taken as explicit hypotheses).**
* **(G1) True vs proxy objective.** Two problems `p_true ≠ p_proxy` with
  knowledge demands `R(p_true)`, `R(p_proxy)`.
* **(G2) Coverage over time.** The agent's knowledge set evolves
  `K(A_t)` as training optimises the proxy (`H_K` reshaping).  Coverage
  of a demand `R` is the set inclusion `R ⊆ K(A_t)`; by A.2 the emergence
  cost `N(p, A_t)` is finite **iff** `R(p) ⊆ K(A_t)` (out-of-coverage `⟹`
  `N = ∞`).
* **(G3) Proxy optimisation.** Training reshapes `K` to keep the proxy
  covered while the *true* demand can drop out.

**Statement (the failure theorem).**  Optimising the proxy can break
true-coverage: at a "Goodhart phase time" `t_G` the true demand stops
being covered while the proxy stays covered.  We prove:

1. **Abstract divergence** — given sets `R_true, R_proxy, K₀, K_t` with
   `R_true ⊆ K₀` (initially covered), `R_proxy ⊆ K_t` (proxy stays
   covered), and a *witness* `ω ∈ R_true` with `ω ∉ K_t`, the divergence
   `R_true ⊆ K₀ ∧ R_true ⊄ K_t ∧ R_proxy ⊆ K_t` holds.  This is the
   reward-hacking signature: proxy up, truth gone.
2. **A.2 reading** — under the coverage axiom this means
   `N(p_true, A_0) < ∞` (solvable before) but `N(p_true, A_t) = ∞`
   (unsolvable after), while `N(p_proxy, A_t) < ∞`.
3. **Concrete finite witness** — an explicit instance over `Finset ℕ`
   exhibiting `t_G`: `R_true = {0,1}`, `R_proxy = {1,2}`, `K₀ = {0,1,2}`,
   `K_t = {1,2,3}`.  Training dropped element `0` (a true-only demand)
   and added `3` (a proxy-aligned hack), so `R_true ⊄ K_t` while
   `R_proxy ⊆ K_t`.

**This file is `axiom`-free.**  Imports only Mathlib; A.2 enters as an
explicit hypothesis and the divergence is proved with concrete finite
witnesses.
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.ENat.Basic
import Mathlib.Data.Finset.Insert

namespace MIP

namespace Goodhart

variable {Ω : Type*} [DecidableEq Ω]

/-- Emergence cost lives in `ℕ∞`, so "`N = ∞`" (unsolvable) is literal. -/
abbrev Cost := ℕ∞

omit [DecidableEq Ω] in
/-- **R.407 (i) — abstract Goodhart divergence.**

Given the true and proxy demands and two coverage snapshots
`K₀ = K(A_0)`, `K_t = K(A_t)`:
* `R_true` is initially covered (`R_true ⊆ K₀`),
* the proxy stays covered after the step (`R_proxy ⊆ K_t`),
* but a demanded true element `ω` drops out (`ω ∈ R_true`, `ω ∉ K_t`),

then the reward-hacking signature holds: at `t_G` the true demand loses
coverage (`R_true ⊄ K_t`) while everything the proxy needs is still
present (`R_proxy ⊆ K_t`).  Optimising the proxy *broke* true-coverage. -/
theorem R_407_i_divergence
    (R_true R_proxy K₀ K_t : Finset Ω) {ω : Ω}
    (hInit : R_true ⊆ K₀)
    (hProxyCover : R_proxy ⊆ K_t)
    (hWitnessIn : ω ∈ R_true)
    (hWitnessOut : ω ∉ K_t) :
    R_true ⊆ K₀ ∧ ¬ R_true ⊆ K_t ∧ R_proxy ⊆ K_t := by
  refine ⟨hInit, ?_, hProxyCover⟩
  intro hCover
  exact hWitnessOut (hCover hWitnessIn)

omit [DecidableEq Ω] in
/-- **R.407 (ii) — A.2 reading: true cost diverges, proxy cost stays finite.**

Encode A.2 as the coverage axiom `N ≠ ⊤ ↔ R ⊆ K` per (problem, snapshot).
With the Goodhart divergence (i), the true problem is solvable at `t=0`
(`N_true⁰ < ∞`) but unsolvable at `t=t_G` (`N_true^t = ∞`), while the
proxy remains solvable (`N_proxy^t < ∞`).  This is the A.2-failure form
of reward hacking. -/
theorem R_407_ii_cost_divergence
    (R_true R_proxy K₀ K_t : Finset Ω) {ω : Ω}
    (N_true0 N_true_t N_proxy_t : Cost)
    -- A.2 instances:
    (hA2_true0 : N_true0 ≠ ⊤ ↔ R_true ⊆ K₀)
    (hA2_true_t : N_true_t ≠ ⊤ ↔ R_true ⊆ K_t)
    (hA2_proxy_t : N_proxy_t ≠ ⊤ ↔ R_proxy ⊆ K_t)
    -- Goodhart divergence hypotheses:
    (hInit : R_true ⊆ K₀)
    (hProxyCover : R_proxy ⊆ K_t)
    (hWitnessIn : ω ∈ R_true)
    (hWitnessOut : ω ∉ K_t) :
    N_true0 ≠ ⊤ ∧ N_true_t = ⊤ ∧ N_proxy_t ≠ ⊤ := by
  obtain ⟨hInit', hNoCover, hProxy'⟩ :=
    R_407_i_divergence R_true R_proxy K₀ K_t hInit hProxyCover hWitnessIn hWitnessOut
  refine ⟨hA2_true0.mpr hInit', ?_, hA2_proxy_t.mpr hProxy'⟩
  -- N_true_t = ⊤  ⟺  ¬(N_true_t ≠ ⊤)  ⟺  ¬(R_true ⊆ K_t).
  by_contra hne
  exact hNoCover (hA2_true_t.mp hne)

end Goodhart

/-- **R.407 (iii) — concrete finite witness of the Goodhart phase `t_G`.**

An explicit instance over `Finset ℕ`:
* `R_true  = {0, 1}` — the true demand,
* `R_proxy = {1, 2}` — the proxy demand,
* `K₀      = {0, 1, 2}` — initial knowledge (covers *both*),
* `K_t     = {1, 2, 3}` — post-step knowledge.

Training dropped true-only element `0` and acquired the proxy-aligned hack
`3`.  Hence `R_true ⊆ K₀`, `R_proxy ⊆ K_t`, but `R_true ⊄ K_t` (element
`0` is gone).  This realises `t_G` with concrete finite data. -/
theorem R_407_iii_concrete_witness :
    let R_true  : Finset ℕ := {0, 1}
    let R_proxy : Finset ℕ := {1, 2}
    let K₀      : Finset ℕ := {0, 1, 2}
    let K_t     : Finset ℕ := {1, 2, 3}
    R_true ⊆ K₀ ∧ ¬ R_true ⊆ K_t ∧ R_proxy ⊆ K_t := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

end MIP
