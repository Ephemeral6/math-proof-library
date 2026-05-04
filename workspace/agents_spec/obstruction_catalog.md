# Obstruction Catalog — Seed v1

**Status**: hand-curated seed (Phase-1). Eight rows; one row per controlled-vocab `obstruction_class`.
**Owners**: this file is read by `workspace/agents_spec/tool_discoverer.md` (§D.2 catalog fallback) and consulted by `workspace/agents_spec/explain_why_prompt.md` (§A.4 obstacle field validation). Updates require operator approval until Phase-3 promotes this to a registry channel.
**Format**: a single mapping table from `obstruction_class` → `(meaning, search_keywords, typical_discovery_category)`. Each row carries a short rationale and one historical example so future readers can ground the abstract category in a concrete failure.

---

## A. The eight `obstruction_class` values

This is the controlled vocabulary referenced by `discoveries/SCHEMA.md §A.defuses_obstruction[]`, by `hypothesis_tracker.md §A.WH.obstacle.obstruction_class`, by `explain_why_prompt.md §A.4`, and by `tool_discoverer.md §C.obstruction_class`.

| `obstruction_class` | Meaning | Search keywords | Typical discovery category |
|---|---|---|---|
| `combinatorial_blowup` | Search space grows exponentially; exhaustive enumeration is infeasible. | probabilistic method, expectation bound, LP relaxation, generating function, Lovász local lemma, random sampling | `proof_technique` |
| `loose_inequality` | Inequality has slack; the bound is not tight enough to close the goal. | polarisation, AM-GM tightening, Schur complement, interpolation, refined Cauchy-Schwarz, Jensen-with-tangent | `proof_technique` |
| `wrong_direction` | The inequality direction is reversed for what the goal needs (e.g. need a lower bound but only have an upper bound on a related quantity). | duality, conjugate / Fenchel, complementary slackness, minimax, KKT, reverse triangle | `proof_technique` |
| `missing_lower_bound` | A lower bound is needed but only upper-bound techniques are available. | Le Cam two-point, Fano inequality, Markov chain mixing time, information-theoretic lower bound, Yao's principle, communication complexity | `proof_technique` |
| `non_constructive_witness` | Existence is established but the proof needs an explicit construction or algorithm. | algorithmic constructivisation, derandomisation, conditional expectations, explicit construction, expander, code | `strategic_pattern` |
| `coupling_breaks` | Dependency / adaptivity / sequential conditioning destroys an independence assumption the technique relies on. | KL chain rule, sequential conditioning, Doob martingale, filtration, exchangeable sequences, coupling argument | `proof_technique` |
| `regularity_loss` | Smoothness / convexity / Lipschitz hypothesis fails; standard analysis machinery does not apply. | mollification, Yosida-Moreau envelope, inf-convolution, smoothed dual, proximal regularisation, weak convergence | `proof_technique` |
| `intractable_certificate` | The certificate-search space (Lyapunov coefficients, polynomial sum-of-squares decomposition, …) is too large for direct construction. | SDP / LMI, Positivstellensatz, sum-of-squares, PEP framework, semidefinite programming, certificate via convex relaxation | `rigor_pattern` |

---

## B. Per-row rationale and historical example

Each row of §A is paired with a one-paragraph rationale and one historical example drawn from the existing run record (OP-1, OP-2, Theorem 3, Erdős-Selfridge, OptLib2). When no concrete example yet exists in the registry, the row carries `(no concrete instance yet)` to flag where Phase-2 / Phase-3 should look first.

### B.1 `combinatorial_blowup`

The technique reduces to enumerating an object class whose size is exponential (or worse) in a parameter that is not under the agent's control. Rescue moves are *probabilistic / averaging* arguments that bound the quantity of interest without enumerating; LP / SDP relaxations that drop integrality; or generating-function identities that collapse a sum.

**Historical example**: Erdős-Selfridge iterative inclusion-exclusion at ≥ 4 distinct primes. `max_union_size(A_1, ..., A_k)` requires enumerating up to `∏ p_i / lcm(...)` residue tuples; combinatorially intractable for the smallest 4-prime instance. The probabilistic-method analog (E[X] bound on the union) is the canonical rescue.

### B.2 `loose_inequality`

The bound the technique produces is correct but slack — typically a factor of 2 or a polynomial in problem size that should not appear. Rescue moves restructure the inequality (polarisation, Schur complement) so the slack is absorbed into a tighter intermediate quantity, or interpolate between two too-loose endpoints.

**Historical example**: `disc_009_lookahead_augmentation` (OP-2 round 2) — single-step Lyapunov produces a loose `α^2 k` factor in the variance-reduction analysis; lookahead augmentation absorbs the cross-time noise correlation that breaks the single-step bound, recovering the tight rate.

### B.3 `wrong_direction`

The technique gives an upper bound on a quantity Q whose *lower bound* is what the proof step needs — or vice versa. Rescue moves swap to the dual quantity (Q's Fenchel conjugate, the LP dual, the adjoint operator) where the desired direction emerges naturally.

**Historical example**: (no concrete instance yet in registry; canonical instance is duality-based proofs of Sion's minimax / Slater's condition where a primal upper bound is converted into a dual lower bound).

### B.4 `missing_lower_bound`

The technique produces only upper bounds (concentration, smoothness, fixed-point estimates) when a matching lower bound (rate-optimality, communication complexity, sample-complexity tightness) is needed. Rescue moves are the *information-theoretic* lower-bound family — Le Cam two-point, Fano, Yao's principle.

**Historical example**: OP-2 SHB lower bound — a variance lower bound for SHB-style algorithms with adaptive queries. Naïve iid tensorisation fails because adaptivity breaks independence; the rescue is Le Cam two-point + KL chain rule for sequential conditioning.

### B.5 `non_constructive_witness`

The proof shows existence (e.g. by Lovász local lemma, by compactness, by counting) but the goal demands a constructive witness — an explicit algorithm, an explicit code, an explicit graph. Rescue moves are *constructivisation* meta-patterns: derandomise via conditional expectations, replace random sampling with explicit expanders, replace compactness with iterative refinement.

**Historical example**: (no concrete instance yet in registry; canonical instance is the algorithmic LLL of Moser–Tardos derandomising the original Lovász local lemma proof).

### B.6 `coupling_breaks`

Adaptive queries, time-correlated noise, sequential conditioning — any of these can break an independence assumption that the technique requires. Rescue moves are martingale / chain-rule devices that handle the dependent case explicitly.

**Historical example**: `disc_007_inline_polarisation_bypass` (OP-2) — the polarisation identity proof needs a symmetric-bilinear API that survives the move from ℝ to `RCLike`; an inline rewrite replaces the missing API with a 1–3 line `simp only` chain. (Strictly speaking this is more of an API gap than a coupling failure; the closer canonical instance is OP-2's KL chain rule for adaptive variance lower bounds, which was driven by sequential conditioning.)

### B.7 `regularity_loss`

The technique requires a regularity hypothesis (smoothness, strong convexity, Lipschitz gradient) that fails on the actual problem. Rescue moves are *regularisation* devices that restore the hypothesis on a smoothed proxy, then transfer the conclusion back via a regularisation parameter.

**Historical example**: (no concrete instance yet in registry; canonical instance is non-smooth optimisation analyses that introduce a Yosida-Moreau envelope to recover smoothness for the analysis, then send the regularisation parameter to zero).

### B.8 `intractable_certificate`

The technique requires a certificate (Lyapunov function, polynomial SOS decomposition, dual variable assignment) whose search space is too large or too unstructured for direct construction. Rescue moves are *automated certificate-search* via convex relaxation: SDP / LMI, sum-of-squares, Positivstellensatz, PEP.

**Historical example**: Theorem 3 — manual Lyapunov coefficient hunt is unbounded in (a_0, a_1, a_2, c_01, c_02, c_12) parameter space; SDP relaxation via CLARABEL automates the search and produces a numerical certificate that the rationalisation pipeline (`disc_008_sdp_rationalize_verify`) lifts to an exact one. `disc_005_frontier_extrapolation` and `disc_006_aux_sequence_synthesis` are sibling rescues in the same family.

---

## C. Conventions

- **One class per failure**. The `obstruction_class` field on a WH or `failed_attempts` entry takes exactly one value. When a failure has multiple causes, the Explain-Why prompt picks the *primary* one (the obstruction whose removal would most directly unblock the proof) and lists the others in `notes`.
- **Stable IDs**. The eight class values are stable across schema versions. Adding a ninth value bumps a `CATALOG_VERSION` (currently 1) and is only done with operator approval; renaming or removing a value is a hard break.
- **Cross-class promotion**. A `discoveries/` entry's `defuses_obstruction[]` may list multiple classes when the technique applies to several. The current backfill (Phase-1) lists at most one class per entry by the principle "primary obstruction first"; cross-class promotion is left for Phase-2 once instantiation evidence is denser.
- **Catalog-row uniqueness**. The eight rows in §A are unique by `obstruction_class`. Phase-3 may split or merge rows if instantiation patterns concentrate; a split is a schema bump.

---

## D. Versioning

`CATALOG_VERSION = 1` as of 2026-04-30. Schema-breaking changes (renaming a class, dropping a class, splitting a class) bump this constant and ship a migration patch on `discoveries/entries.jsonl`'s `defuses_obstruction[]` field.
