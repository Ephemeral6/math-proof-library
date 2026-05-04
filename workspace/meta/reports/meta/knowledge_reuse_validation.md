# Knowledge Reuse System — 5-Layer Validation

**Date**: 2026-04-27
**Goal**: Pick 3 archetypal test problems and simulate the lookup steps (no proof execution) to demonstrate which of the 5 layers fire and how useful each is.

**Layers under test**:
1. L1 — Strategy index (`workspace/strategy_index.md`, 69 signatures + Vocabulary Index)
2. L2 — Failure triggers (`workspace/failure_triggers.md`, ~48 triggers)
3. L3 — Fragments (`proofs/fragments/INDEX.md`, 40 lemmas)
4. L4 — Structure map (`workspace/structure_map.md`, 28 cross-proof links, 5 clusters A–E)
5. L5 — Meta-templates (`.claude/skills/math-proof-agent/meta_templates.md`, MT1–MT8)

---

## Test Problem A: OGDA on a smooth bilinear-plus-strongly-concave saddle

### Problem statement
Let `f(x, y) = (1/2) x^T A x + x^T B y - (μ/2) ‖y‖²` with `A ⪰ 0`, `B` arbitrary, and `μ > 0`. Run Optimistic Gradient Descent-Ascent (OGDA) with constant step `η`. Prove: the last iterate `z_T = (x_T, y_T)` satisfies `‖z_T − z*‖² ≤ C · ρ^T` for some `ρ < 1` (linear last-iterate convergence) — i.e., extend the bilinear OGDA last-iterate result to the partially strongly-concave case.

### Expected layer use
- L1 strategy: STRONG hit on `ogda-bilinear-last-iterate` and adjacent saddle-point sigs
- L5 templates: MT1 (cancellation_pair) clean fit
- L4 structure map: same-template link C3↔C4 (linearize-then-couple ≈ skew-symmetric polarization) is decorative; no domain reduction needed
- L2 triggers: NONE expected — this is a "do the same thing" problem, no known wrong-route attractors
- L3 fragments: HIGH reuse — polarization identity, cocoercivity

### Simulated lookup pass

**Step A — Strategy Signature Lookup (L1)**
- Grep tokens (Vocabulary Index): `algorithm_type=OGDA`, `function_class=saddle-point`, `target_quantity=convergence_rate`, `setting=deterministic`, `iterate_type=last`.
- Hits:
  - `ogda-bilinear-last-iterate` (5/5 feature match) → meta_template = `cancellation_pair`. Tags: OGDA, bilinear, skew-symmetry, polarization, last-iterate.
  - `gda-nonconvex-strongly-concave-convergence` (3/5: GDA / non-convex-strongly-concave / averaged) → meta_template = `lyapunov_potential`. Useful as the "strongly concave on y" reference.
  - `chambolle-pock-pdhg-ergodic-convergence` (2/5: saddle-point / averaged) → meta_template = `lyapunov_potential`. Marginal.
- Verdict: **USEFUL**. The OGDA-bilinear signature names the exact template (cancellation_pair) and the technique chain `skew_symmetric_fixed_point → polarization → telescope_identity_E`. The GDA-strongly-concave hit suggests the "two-time-scale Lyapunov V = Φ + cδ" augmentation that handles the strong-concavity in y.

**Step B — Meta-Template Slot-Filling (L5)**
- Templates evaluated: MT1 (cancellation), MT4 (low-dim — N/A), MT8 (spectral — partial, since the bilinear part has skew structure). MT1 is the strong candidate.
- Best candidate: **MT1 — Cancellation Pair**
- Slots filled:
  - SLOT V_t (Lyapunov): `‖z_t − z*‖² + c·‖δ_t‖²` where `δ_t = z_t − z_{t-1}` (OGDA-bilinear shape), augmented with a y-tracking term `+ d·‖y_t − y*(x_t)‖²` per the GDA-strongly-concave proof.
  - SLOT TELESCOPE: from OGDA update `z_{t+1} = z_t − η F(z_t) + η/2 (F(z_t) − F(z_{t-1}))` with `F(z) = (Ax + By, B^T x − μy)`.
  - SLOT GOOD: `‖z_t − z*‖²` per-step decrease.
  - SLOT BAD: cross term `⟨z_t, F(δ_t)⟩` (skew-symmetric piece) PLUS a new `μ·‖y_t − y*‖²` strong-concavity gain.
  - SLOT IDENTITY/INEQ: skew-symmetry `⟨z, B-skew(z)⟩ = 0` from C4 + polarization identity (E) for the bilinear part; for the new y-strong-concavity, use `−2η·μ ‖y_t − y*‖²` directly (no cancellation needed — this is a strict gain, not a cancellable term).
- Blocker slot (if any): **none full-blocking**, but the `y` strong-concavity introduces a new asymmetric term that must be absorbed into the existing OGDA cancellation; the constant `c` in `V_t` may need re-tuning so the y-contraction `(1 − ημ)` aligns with the polarization telescope.
- Verdict: **FULL** skeleton emerges. The proof reduces to: copy OGDA-bilinear's identity (E) and add a `(1 − ημ)`-contraction term on the y-coordinate, then re-balance the Lyapunov weighting.

**Step C — Structure Map Consultation (L4)**
- Relevant cluster: **Cluster C (Cancellation Pair Family, MT1)**.
- Links found:
  - C4 = `ogda-bilinear-last-iterate` is in the 7-way SAME_TEMPLATE link.
  - C3 ↔ C4 ANALOGY (linearize-then-couple ≈ skew-symmetric polarization): suggests Q-learning's `Δ_t = L_t + R_t` decomposition might inspire splitting our `V_t` into a "skew-symmetric clean part" and "strong-convexity correction part."
  - C2 ↔ C3 ANALOGY (approximate-gradient + Young): less directly relevant.
- Best ANALOGY: not a true reduction — the problem already lives in the saddle-point domain. The cluster simply confirms MT1 is correct and that the augmentation pattern "add a Lyapunov term for the new structural ingredient" is well-attested (B3 sharpens B1 the same way for stability).
- Verdict: **USEFUL** but mostly confirmatory. No isomorphism to copy verbatim because no domain translation is needed.

**Step D — Failure Trigger Pre-Scan (L2)**
- Triggers checked (top 5):
  - `FT-LEGACY-STORM-YOUNG-DISCARDS-DESCENT` — "Young's on `⟨∇f, e⟩` discards the negative `‖d‖²`." Indirect relevance: same anti-pattern as MT1's "don't reach for Young's where polarization works."
  - `FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE` — N/A (we're proving an upper bound, not extending a cycling LB).
  - `FT-LEGACY-CD-EUCLIDEAN-NORM` — N/A (no coordinate weights).
  - `FT-LEGACY-FENCHEL-SURJECTIVITY` — N/A.
  - `FT-LEGACY-SAM-PERTURBATION-LYAPUNOV` — N/A (different chassis).
- Triggers that FIRE: **none**. The Storm-Young anti-pattern is informative as a general warning (don't Young the bilinear cross term) but is already encoded inside MT1's blocker checklist.
- Verdict: **NONE**. Honest assessment: this is a "well-trodden path" problem; no known wrong-route attractor exists.

**Step E — Fragment Search (L3)**
- INDEX.md tag clusters consulted: "Convex analysis & inequalities", "Optimization / Lyapunov / convergence".
- Fragments cited:
  - `polarization-identity-gradient-error` — directly powers MT1's IDENTITY slot (the negative `‖v‖²` absorber on the bilinear part).
  - `cocoercivity-of-smooth-convex` — used to certify that the y-strong-concavity step is non-expansive when `η ≤ 2/L_y`.
  - (Looked for: skew-symmetric-3-point identity — **not present as a separate fragment**; lives only inside the `ogda-bilinear-last-iterate` proof.)
- Verdict: **SAVES WORK** — polarization is the key sub-lemma and is one click away. Cocoercivity is also pre-stated.

### Synthesis: What did the system save?
A naive Explorer would have hand-derived the polarization identity and re-discovered the skew-symmetry trick from scratch (~2-3 routes of search). The 5-layer stack collapses this to: L1 names the exact signature, L5 fills 4/5 slots from MT1's template, L3 supplies the polarization fragment as a one-liner reference. Most valuable layer for Problem A: **L1+L5 jointly** — the strategy signature is granular enough that the problem reduces to a clean "augment the existing Lyapunov by the new structural term" exercise.

---

## Test Problem B: Stability bound for SHB-momentum SGD on a strongly convex objective

### Problem statement
Let each `f_i: ℝ^d → ℝ` be `μ`-strongly-convex and `β`-smooth. Run stochastic Heavy-Ball SGD `x_{t+1} = x_t − η ∇f_{i_t}(x_t) + γ (x_t − x_{t-1})` on dataset `S` of size `n`, and on a neighboring dataset `S'` differing in one sample, with the same minibatch index sequence. Prove a uniform-stability bound `E ‖x_T(S) − x_T(S')‖ ≤ ε(T, n, η, γ, μ, β)` and convert it to a generalization gap (Hardt-Recht-Singer chassis extended to momentum).

### Expected layer use
- L1 strategy: PARTIAL — multiple stability and momentum sigs, no exact `SHB+stability` match
- L5 templates: MT3 (couple-and-track) clean attempt with one BLOCKER slot (the SHB contraction factor differs from SGD's `(1 − ημ)`)
- L4 structure map: Cluster B (HRS phylogeny) provides the chassis; SAME_TEMPLATE link tells us what plugs in
- L2 triggers: INFORMATIVE — known SHB-cycling and HB-instability triggers may apply if `η > 2/β` or momentum is mis-tuned
- L3 fragments: cocoercivity is core; martingale-cancellation could appear

### Simulated lookup pass

**Step A — Strategy Signature Lookup (L1)**
- Grep tokens: `algorithm_type=SHB`, `target_quantity=generalization_bound`. Also try `algorithm_type=SGD`+`target_quantity=generalization_bound`.
- Hits:
  - `hardt-recht-singer-sgd-stability` (4/5: SGD / smooth_convex / generalization_bound / stochastic_iid / last) → meta_template = `couple_track`. Tags: HRS, stability, co-coercivity, coupling, leave-one-out.
  - `momentum-sgd-interpolation-perron-frobenius`, `momentum-sgd-interpolation-alpha-split-quarter-L`, `momentum-sgd-interpolation-alpha-split-one-over-L`, `momentum-sgd-interpolation-spectral` (all 4: algorithm_type=SHB / smooth_SC / interpolation) → meta_template ∈ {`cancellation_pair`, `lyapunov_potential`, `spectral_eigenvalue`}.
  - `dp-implies-generalization` (sibling chassis, divergence-based stability).
  - `sgd-signal-noise-generalization-decomposition` (HRS-derived, B3 in cluster).
- Verdict: **PARTIAL**. Strategy index has the chassis (HRS) and the algorithm (SHB momentum analyses) on separate sides; no signature directly says `SHB + stability`. **Vocabulary gap noted**: there is no signature with `algorithm_type=SHB` and `target_quantity=generalization_bound`. The Explorer must combine two signatures.

**Step B — Meta-Template Slot-Filling (L5)**
- Templates evaluated: MT3 (couple-and-track) — primary; MT7 (alpha-split co-coercivity) — secondary if interpolation is added.
- Best candidate: **MT3 — Couple-and-Track-Distance**.
- Slots filled:
  - SLOT COUPLING: same minibatch index sequence on `S, S'` (HRS chassis verbatim).
  - SLOT DISTANCE: `E‖(x_t(S) − x_t(S'), x_{t-1}(S) − x_{t-1}(S'))‖` — the joint state of position + previous position is needed because SHB is a 2-step recursion.
  - SLOT NON-EXPANSIVE: this is the **BLOCKER**. Vanilla HRS uses `(I − η∇f_i)` non-expansive via co-coercivity at `η ≤ 2/β`. For SHB, the per-step operator is the 2×2 block `[(1+γ)I − η H, −γ I; I, 0]` whose spectral radius is **not** ≤ 1 in the obvious norm. The new analytical work: find the right joint-Lyapunov norm under which the SHB operator is non-expansive in the strongly-convex `μ > 0` regime.
  - SLOT SHOCK BOUND: `2η L` on the `1/n` differing step, same as HRS.
  - SLOT LIPSCHITZ TRANSFER: same as HRS, loss is `L`-Lipschitz in `θ` ⇒ gen gap ≤ `L · distance`.
- Blocker slot: **SLOT NON-EXPANSIVE** — needs a new joint Lyapunov for the 2-step SHB recursion. Direct candidates from L1's momentum-SGD-interpolation signatures: (i) `momentum-sgd-interpolation-perron-frobenius` uses joint state `(‖e‖², ‖γv‖²)` with positive-eigenvector certificate; (ii) `momentum-sgd-interpolation-alpha-split` provides explicit `(γ, β)` pairs killing variance.
- Verdict: **PARTIAL** — 4/5 slots filled, blocker localized to "find the SHB-specific contraction factor in the right joint norm". The blocker is the genuine new work.

**Step C — Structure Map Consultation (L4)**
- Relevant cluster: **Cluster B (HRS phylogeny: B1–B5, 5-way SAME_TEMPLATE)**.
- Links found:
  - B1–B5 SAME_TEMPLATE: the chassis is portable. The cross-cutting observation is: "find the new ingredient that the chassis is missing, plug it into the existing per-step recursion." Here the missing ingredient is the joint-state Lyapunov for the SHB's 2-step recursion.
  - B3 DEPENDS B1 (signal-noise decomposition pushed inside) — informs the technique.
  - B5 DEPENDS B1+B3 (`L^p` lift via Marcinkiewicz-Zygmund) — orthogonal but documents how to absorb structural extensions.
- Best ANALOGY: **B1 chassis + import the SHB joint-Lyapunov from `momentum-sgd-interpolation-perron-frobenius`**. The isomorphism: HRS's per-step operator `(I − η∇f_i)` ↔ SHB's 2×2 block matrix; HRS's contraction at `η ≤ 2/β` ↔ SHB's spectral radius `< 1` certified by the Perron-Frobenius eigenvector `(1, 1/κ²)`.
- Verdict: **USEFUL** — this is exactly the "reduction-style" problem the structure map is designed for. Cluster B explicitly says "the chassis can absorb new ingredients." The mapping is not pre-baked into a single Structure Link block (no `SHB+stability` link exists yet) but the cluster's general SAME_TEMPLATE statement plus the momentum signatures together compose into the right approach.

**Step D — Failure Trigger Pre-Scan (L2)**
- Triggers checked (top 5):
  - `FT-OP2-CYCLING-INIT-BASIN-DEPENDENCE` — informative if the user's analysis assumes generic init; doesn't strictly apply since SC + small `γ` rules out cycling.
  - `FT-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING` — N/A, we're using vanilla SHB.
  - `FT-LEGACY-SHB-LB-QUADRATIC-CHEBYSHEV` — about lower bounds, N/A.
  - `FT-LEGACY-STORM-YOUNG-DISCARDS-DESCENT` — informative anti-pattern: don't Young the cross term in the joint-Lyapunov expansion.
  - **No specific HRS-momentum trigger exists**. The closest is the implicit constraint from `cocoercivity-of-smooth-convex` (η ≤ 2/β); for SHB the analogous condition (spectral radius `< 1`) is not flagged.
- Triggers that FIRE: **INFORMATIVE only**. None of the existing triggers crisply prevents a wrong attempt for this problem. **Validation gap noted**: a useful new trigger would be "FT-SHB-STABILITY-NAIVE-CONTRACTION: applying the HRS scalar contraction `(1 − ημ)` to SHB ignores the 2-step recursion's spectral radius, producing a spurious `(1 − ημ)^T` decay that doesn't match numerical experiments."
- Verdict: **INFORMATIVE** but not blocking. This is a layer where the test surfaces a real gap.

**Step E — Fragment Search (L3)**
- INDEX.md tag clusters consulted: "Optimization / Lyapunov / convergence", "Convex analysis & inequalities".
- Fragments cited:
  - `cocoercivity-of-smooth-convex` — directly used (each gradient step still co-coercive).
  - `martingale-cancellation-via-conditional-expectation` — applies inside the expectation when computing `E[shock]`.
  - **Missing fragment**: a "SHB-joint-Lyapunov via Perron-Frobenius" lemma — would be valuable to extract from `momentum-sgd-interpolation-perron-frobenius`. Currently it lives only inside that proof.
- Verdict: **MARGINAL** — cocoercivity is reusable; martingale-cancellation is helpful but not novel. The most useful would-be fragment doesn't exist yet.

### Synthesis: What did the system save?
A naive Explorer would have either (a) wrongly applied HRS as-is and gotten an unstable contraction `(1 − ημ + γ)` that fails for `γ > 0`, or (b) re-derived the Perron-Frobenius joint Lyapunov for SHB from scratch. The system surfaces the chassis (L4 cluster B) AND the SHB-momentum analyses (L1) but the Explorer must compose them — the system doesn't pre-compose. Most valuable layer for Problem B: **L4 structure map** + L1 partial hits — the structure map's "chassis is portable" message gives the right mental scaffold; without it the Explorer might never connect HRS to the momentum-SGD signatures.

---

## Test Problem C: Lower bound `Ω(LD²/T)` for AVERAGED iterates of SHB on Goujaud's hard instance

### Problem statement
Let `f_0(x) = D² ψ(x/D)` be the Goujaud-Taylor-Dieuleveut polytope-Moreau function on `ℝ²`. Run fixed-momentum SHB with parameters `(β, η L) ∈ ℱ` (the cycling feasibility region) starting from a vertex of the K-gon. Prove `f_0(x̄_T) − f₀* ≥ Ω(LD²/T)` where `x̄_T = (1/T)∑_{t=0}^{T-1} x_t` is the uniform Cesàro average.

### Expected layer use
- L1 strategy: hits `shb-no-acceleration-restricted` and other SHB lower-bound sigs — confirms MT5 is the natural template
- L5 templates: MT5 (polytope construction) clean fit — but the iterate type changed from `last` to `averaged_uniform`
- L4 structure map: Cluster A (SHB LB family) is exactly relevant; the A1↔A5 CONTRADICTS link is critical
- L2 triggers: **CRITICAL** — `FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE` should fire and save the proof attempt
- L3 fragments: NONE — the construction is bespoke and lower-bound-specific

### Simulated lookup pass

**Step A — Strategy Signature Lookup (L1)**
- Grep tokens: `algorithm_type=SHB`, `target_quantity=lower_bound`, `iterate_type=averaged_uniform` (also try `Polyak_Ruppert`, `last`).
- Hits:
  - `shb-no-acceleration-restricted` (4/5: SHB / smooth_SC / lower_bound / stochastic_iid / **last**) → meta_template = `polytope_construction`.
  - `shb-cycling-critical-momentum` → companion to OP-2.
  - `shb-no-acceleration-best-iterate` → variant for best-iterate.
  - `shb-interpolation-regime-lb` → variant for interpolation noise.
  - `polyak-ruppert-shb-defeats-cycling` (5/5 except `iterate_type=Polyak_Ruppert` instead of averaged_uniform) → meta_template = `spectral_eigenvalue`. **Critical hit**: explicitly proves an `O(LD²/T²)` upper bound for PR-weighted averaging, which is strictly **better** than the `Ω(LD²/T)` we're trying to prove for uniform averaging.
- Verdict: **USEFUL** — strategy index correctly names MT5 polytope_construction template, but the `polyak-ruppert-shb-defeats-cycling` hit is a flashing red light: averaging defeats cycling lower bounds. The vocabulary disambiguation `iterate_type=last` vs `averaged_uniform` vs `Polyak_Ruppert` is exactly what makes this hit visible.

**Step B — Meta-Template Slot-Filling (L5)**
- Templates evaluated: MT5 (polytope construction) — primary; MT6 (Le Cam) — only for the variance half (not relevant in deterministic setting).
- Best candidate: **MT5 — Adversarial Polytope / Cycling Construction**.
- Slots filled:
  - SLOT PARAMS: `(β, η) ∈ ℱ`, the same feasibility region as A1/A2.
  - SLOT P: Goujaud K-gon polytope (K=3 minimizes threshold per A2).
  - SLOT F: `f_0(x) = D² ψ(x/D)` with `ψ = (L/2)‖x‖² − ((L−μ)/2) d²_{conv(P)}(x)` (Moreau-envelope smoothing).
  - SLOT CYCLE IDENTITY: starting from a vertex, SHB visits next vertex per `(β, η)` cycling identity from A1.
  - But: the CONCLUSION step (Step 5: "cycling means `‖x_t − x*‖ = D/√2` uniformly") **does not transfer** — the AVERAGED iterate `x̄_T` collapses to `x*` because the K-gon vertex sum vanishes by Birkhoff symmetry (`∑_{t=0}^{K-1} e_t = 0`).
- Verdict: **APPARENTLY FULL** — all slots fill cleanly. This is a TRAP: the template would produce a "complete" proof skeleton that is **wrong**. Layer 5 alone produces a confident-but-false answer. This is exactly the failure mode L2 must catch.

**Step C — Structure Map Consultation (L4)**
- Relevant cluster: **Cluster A (SHB Lower Bounds Family, A1–A6)**.
- Links found:
  - A1+A2+A3+A4 SAME_TEMPLATE: 4-way Goujaud chassis.
  - **A1+A2+A3+A4 ↔ A5 CONTRADICTS** (HIGH confidence): "A5 disproves a putative `Ω(LD²/T)` Polyak-Ruppert lower bound on Goujaud's hard instance by exhibiting an `O(LD²/T²)` achievable rate." This **explicitly says** averaging defeats the bound. Quoted: "complexifies `ℝ² ≅ ℂ` via `e_t ↔ ω^t` ... `|∑t ω^t| = O(T)` against the linear-weight denominator `W_T = Θ(T²)`."
  - A4 ↔ A5 SAME_TEMPLATE: iteration-type asymmetry — different iterate types must be analyzed independently.
- Best ANALOGY: **the CONTRADICTS link from A1–A4 to A5 is the singular most important consultation**. It tells the Explorer in one sentence that the proof attempt is doomed.
- Verdict: **USEFUL** — Cluster A's CONTRADICTS link surfaces exactly the contradiction. (Note: A5 uses Polyak-Ruppert weighted averaging not uniform Cesàro, but the underlying mechanism — vertex-sum cancellation in `ω^t` — applies to uniform averaging too. The structure map identifies the right cluster but the Explorer must extrapolate from PR to uniform.)

**Step D — Failure Trigger Pre-Scan (L2)**
- Triggers checked (top 5 most relevant):
  - **`FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE`** (line 118): "WHEN problem involves: extending a cycling-style lower bound (Goujaud-Taylor-Dieuleveut rotational K-cycling) for fixed-momentum SHB from last iterate `x_T` to averaged iterate `x̄_T = (1/T)∑ x_t` ... THEN this failure is likely because: the regular K-gon vertex sum vanishes (`∑_{t=0}^{K-1} e_t = 0`), so by Birkhoff ergodic theorem `x̄_T → 0 = x*` deterministically, giving `f_0(x̄_T) ≤ LD²/T²` — exactly AC-SA's bias rate, NOT `Ω(LD²/T)`." **EXACT MATCH**.
  - **`FT-OP2-I4-SUFFIX-AVG-RESONANCE`** (line 226): "Suffix average of length ≥ K over a K-cycle annihilates by rotational symmetry." Reinforces the same conclusion for any window-length averaging.
  - `FT-OP2-CYCLING-INIT-BASIN-DEPENDENCE` — informative side concern (zero-momentum init may not even land in the cycle).
  - `FT-LEGACY-SHB-LB-QUADRATIC-CHEBYSHEV` — N/A (we're using Goujaud, not quadratic).
  - `FT-OP2-NESTEROV-LOOKAHEAD-OFF-VERTEX` — N/A (not Nesterov).
- Triggers that FIRE: **`FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE` fires loudly**, and the recommended pivot is explicitly stated: "Instead of cycling-based reuse, switch to a fundamentally non-cycling lower-bound technique (e.g., HB-vs-AC-SA information-separation construction in `d=T`). If no such technique is available in the toolbox, restate the theorem honestly as a last-iterate bound and do NOT relabel as `oracle-complexity LB`."
- Verdict: **CRITICAL — saves a wrong-route attempt**. Without this trigger, MT5 would have produced a confident-but-false proof skeleton (Step B above).

**Step E — Fragment Search (L3)**
- INDEX.md tag clusters consulted: "Optimization / Lyapunov / convergence". Lower-bound constructions are typically not fragmentized (they are bespoke instance-builds).
- Fragments cited: **none**. The Goujaud polytope-Moreau construction is not a separate fragment; it lives inside the A1 proof.
- Verdict: **NONE** — fragments are not the right layer for adversarial-construction lower bounds.

### Synthesis: What did the system save?
A naive Explorer applying MT5 in isolation would produce a confident-but-WRONG proof skeleton (Step B above). The system catches this via two complementary mechanisms: (1) L2's exact-match trigger `FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE` fires immediately, and (2) L4's Cluster A CONTRADICTS link from A1–A4 to A5 names the contradiction structurally. Either alone would suffice to redirect the proof attempt; both together produce high confidence in the negative result. Most valuable layer for Problem C: **L2 failure triggers** — this is the canonical example of a "trap" problem where the first 4 layers all green-light a wrong route and only L2 catches it.

---

## Cross-Problem Findings

### Layer hit-rate matrix
| Problem | L1 Strategy | L2 Triggers | L3 Fragments | L4 Structure | L5 Templates |
|---|---|---|---|---|---|
| A (OGDA + SC) | USEFUL | NONE | SAVES WORK | USEFUL (confirmatory) | FULL |
| B (SHB stability) | PARTIAL | INFORMATIVE | MARGINAL | USEFUL (chassis) | PARTIAL (1 blocker) |
| C (averaged-iterate LB on Goujaud) | USEFUL | **CRITICAL** | NONE | USEFUL (CONTRADICTS link) | TRAP / FULL but WRONG |

### Most valuable layer (across the 3): L5 + L2 together

- **L5 (meta-templates)** is the single highest-leverage layer in the average case (Problems A and B): it converts a free-form proof search into a slot-filling exercise with a clear blocker.
- **L2 (failure triggers)** is the single most valuable layer for trap problems: in Problem C it is the only layer that flips the verdict from "wrong skeleton" to "correct pivot." Without L2, L1+L4+L5 collectively LIE in a confident voice.
- **L4 (structure map)** is the second-most-valuable for reduction-style problems (B) and for trap problems (C, via CONTRADICTS link).

### Layers needing improvement

- **L1 vocabulary gap**: there is no signature with `algorithm_type=SHB` AND `target_quantity=generalization_bound`. Any extension of HRS to a momentum method would have to compose two signatures manually. Recommendation: add a synthetic signature `shb-stability-generalization-extension` once such a proof is produced (or proactively, sourced from Liu et al. 2018).
- **L2 missing trigger for Problem B**: no `FT-SHB-STABILITY-NAIVE-CONTRACTION` exists to warn an Explorer not to apply HRS's scalar `(1 − ημ)` contraction directly to SHB's 2-step recursion. This is exactly the kind of momentum-stability mistake that would cost an Explorer 1–2 routes.
- **L3 missing fragment**: the joint Lyapunov for SHB (Perron-Frobenius eigenvector `(1, 1/κ²)` certifying spectral radius `< 1`) is buried inside `momentum-sgd-interpolation-perron-frobenius` and would be useful as a standalone fragment for any 2-step momentum analysis.
- **L4 missing structure link**: there is no cross-cluster link "Cluster B (HRS chassis) ↔ momentum-SGD-interpolation signatures" — this would have made Problem B's answer one-click instead of three-click.
- **L5 missing template instance for Problem C**: MT5's "Anti-pattern" section explicitly warns about averaging defeating cycling LBs, but the warning is not connected to L2 or to MT5's slot-filling output. A template-level cross-reference `MT5 → see FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE if iterate_type ≠ last` would be useful.

### Estimated overall savings

For the 3 problems collectively, a naive Explorer would likely run 6–8 routes (Problem A: 2 routes for OGDA+SC blow-out; Problem B: 3 routes — wrong scalar contraction, then over-engineered estimate sequence, then correct joint Lyapunov; Problem C: 1 wrong route producing the false `Ω(LD²/T)` skeleton, then 1 dazed re-attempt). With the 5-layer stack, this collapses to: Problem A ~1 route (slot-filling executes cleanly), Problem B ~1.5 routes (chassis from L4 + blocker localized to joint Lyapunov, then composed), Problem C ~0 routes (L2 redirects before any heavy work). Total compute savings: roughly **70–80%** of Explorer effort on this 3-problem set, with the bulk concentrated in trap-avoidance for Problem C and slot localization for Problem B. Problem A's savings are real but modest (the system is "decorative" — a competent Explorer would have found the OGDA-bilinear template by hand grep too). Problem C's savings are dramatic and high-value because they prevent confident-but-false output.

### Recommended next iteration

- **Add `FT-SHB-STABILITY-NAIVE-CONTRACTION` trigger to L2**: encode the warning that the HRS scalar contraction `(1 − ημ)` does not extend to SHB's 2-step recursion; recommended pivot is the Perron-Frobenius joint Lyapunov.
- **Harvest `shb-joint-lyapunov-perron-frobenius` fragment from L3**: extract the Perron-Frobenius eigenvector `(1, 1/κ²)` certifying SHB's spectral radius `< 1` as a standalone reusable lemma.
- **Add MT5 → L2 cross-reference**: in the meta-template file, when MT5's "When to use" clause matches but `iterate_type ≠ last`, explicitly direct the Explorer to consult `FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE` and `FT-OP2-I4-SUFFIX-AVG-RESONANCE` BEFORE slot-filling.
