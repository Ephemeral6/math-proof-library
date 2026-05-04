# Discovery Report — Agent 10 of 10

**Domain:** Multi-Agent Verification theory (5 self-referential proofs about Cumulative Reasoning / Auditor–Fixer architectures).

**Meta-observation up front.** All five theorems are *about the very framework that is producing them* (the math-proof-agent with its Auditor–Fixer loop). Problem 4.1 is the foundational reliability theorem; Problems 7.2, 7.4, 7.7, 7.9 are explicit elaborations (categorical lift, non-stationary verifier, library reuse, depth lower bound). The "discovery" pattern across the set is therefore unusually transparent: a designer (the user / prompt) observed empirical behaviour of their own multi-agent stack and asked the agent to formalize that behaviour as theorems.

---

## Proof 1: Multi-Agent Verification Error Propagation (Problem 4.1)

### 1. The Spark
**failure-of-natural-approach** — observation that a single-shot LLM verifier with per-step error rate ε ≈ 0.14 produces only ~22% chain reliability over T=10 rounds, raising the question "can we cheaply amplify this?"

### 2. The Key Insight
The non-obvious leap is exceptionally small here: replacing one Bernoulli(ε) per round with a logical-AND of k independent Bernoulli(ε) trials drives the per-round residual error to ε^k. The insight is *engineering-architectural* (an auditor–fixer loop = independent retry = exponential amplification), not mathematical. Required prior knowledge: union bound, independence of Bernoullis. A textbook student could find it in minutes.

### 3. The Technique Chain
- Bernoulli independence + product rule — standard, undergraduate probability.
- Monotonicity of probability for the inclusion {no error} ⊂ {chain correct} — standard.
- Tightness via "honest proposer + false-reject only" construction — non-standard only in that it eliminates error cancellation; cute but elementary.

### 4. The Construction
The honest-proposer / false-reject-only instance is forced by the need to *kill cancellation*: a noisy proposer occasionally proposes wrong things, which lets a false-accept on a wrong proposition partially cancel a later false-reject. Pinning the proposer to truth makes every Verifier draw a single non-redundant test, so the product (1−ε)^T is attained on the nose. Simplifying to "any proposer" loses tightness.

### 5. The Failure Modes
- Trying to bound failure by union bound Tε directly: gives the right scaling but misses the multiplicative-form tightness that powers the (1−ε^k)^T comparison.
- Trying to make the k retries dependent (sharing a hard input): the bound silently breaks; the proof's "Remark on the model assumption" is exactly this caveat.

### 6. The Discovery Path
1. Empirical: framework reports 14% first-round audit failure → users notice end-to-end drift.
2. Try: union bound 1 − Tε — too loose, doesn't motivate retries.
3. Insight: independence + product → multiplicative bound, and retries replace ε with ε^k.
4. Execute: write the two product-form bounds, add tightness construction.
5. Verify: SymPy + 5×10⁵ Monte Carlo, empirical 0.2213 vs theoretical 0.2213.

### 7. Transferable Patterns
- **Independence-then-product-then-amplify** template: any binary-judgement pipeline gets an exponential reliability lift from k independent retries iff the failure mode is statistical, not adversarial.
- The "tightness-via-honest-input" construction trick generalises to any randomised-rejection setting.

---

## Proof 2: Categorical-Functorial Error Propagation (Problem 7.2)

### 1. The Spark
**analogy-from-other-field** — recognition that "verifier as natural transformation between functors" gives Lawvere enriched categories a chance to encode error compounding as functor-category distance.

### 2. The Key Insight
The "insight" is choosing the *right* Lawvere enrichment — M = ([0,∞], ≥, +, 0) — so that ||η||_∞ = d_{[C,D]}(F,G) becomes definitional. Banach contraction in functor space then turns the auditor–fixer iterate into α^k decay automatically. Required prior knowledge: Lawvere 1973, Kelly's enriched category basics, Banach fixed-point. The "leap" is largely *vocabulary*: once the framework is fixed the proofs collapse to one-line sup-of-sums and one-line iteration.

### 3. The Technique Chain
- Lawvere [0,∞]-enrichment (Lawvere 1973) — non-standard outside categorical-logic circles, applied here to verifier metrics.
- Sup-distance on functor categories (Kelly, *Basic Concepts*, §2.1) — standard, just instantiated.
- Banach fixed-point in enriched setting — standard analysis dressed in categorical clothing.
- Kleisli over the distribution monad → reduction to TV-metric on Δ(D) → recovers Problem 4.1 verbatim.

### 4. The Construction
Choosing C discrete + D = Δ with TV-Lawvere metric is *engineered* to make the categorical theorem reduce to Problem 4.1 — i.e., the construction is not about hardness but about *demonstrating non-vacuity*. Removing TV (using e.g. KL) breaks non-expansion and the contraction story collapses.

### 5. The Failure Modes
- A textbook student would try ordinary metric spaces — but then "verifier = natural transformation" has no meaning and the unification with Problem 4.1 is lost.
- Trying functor-category sup over morphism-distance instead of object-distance gives a stronger object that doesn't match the empirical "per-state error" semantics.

### 6. The Discovery Path
1. Notice the slogan "verifier ≈ natural transformation" floating around 2-categorical ML papers.
2. Attempt with ordinary metric spaces — non-expansion is not free.
3. Switch to Lawvere [0,∞]-enrichment, where non-expansion *is* M-functoriality.
4. Write Lemma 1, Theorem (a) (one line), Theorem (b) (Banach), Theorem (c) (Kleisli).
5. SymPy + 100,000-sample Monte Carlo across 5 (N, ε, T, k) cases; verify reduction to 4.1.

### 7. Transferable Patterns
- **Decorative-vs-load-bearing test for category theory**: here the Lawvere enrichment is genuinely load-bearing for the *unification* (4.1 falls out as a special case) but is *decorative* for the bound itself — the contraction would work in any complete metric space. Honest assessment: **mostly decorative formalism wrapped around a one-line Banach iteration**, but with a real payoff in conceptual cleanliness.

---

## Proof 3: Cumulative Reasoning Compositional Reuse (Problem 7.7)

### 1. The Spark
**gap-in-literature** — observation that current CR analyses either (i) treat all m lemmas as a flat union bound or (ii) re-prove every lemma from scratch; nobody had quantified the reuse advantage of a verified library.

### 2. The Key Insight
The leap is a *DAG-vs-tree comparison*: the number of independent failure events in a tree-unfolded DAG is N(d,Δ) = (Δ^{d+1}−1)/(Δ−1), strictly larger than the Δ^d term naively claimed in the problem statement. Per-lemma retries shrink δ to δ^k *before* composition, beating brute-force composition by ~700× at typical parameters. Required: Weierstrass product inequality, induction on tree depth.

### 3. The Technique Chain
- Weierstrass product inequality ∏(1−x_i) ≥ 1−∑x_i — classical, undergraduate.
- Induction on DAG depth with worst-case in-degree Δ — standard combinatorics.
- Per-lemma retry as δ → δ^k — direct reuse of the Problem 4.1 amplification trick.

### 4. The Construction
No adversarial construction — the proof is a clean upper-bound chain. The honest correction of the problem's stated exponent Δ^d → N(d,Δ) is the only "constructive" act.

### 5. The Failure Modes
- Naive union bound mδ: ignores composition structure, gives the same bound for chain and balanced tree.
- "Just multiply (1−δ)^m": correct answer for independent lemmas but ignores the depth-Δ blow-up when each lemma has multiple consumers in the DAG.

### 6. The Discovery Path
1. Empirical: library construction in the math agent reuses lemmas across many proofs.
2. First attempt: write (1−δ)^{Δ^d} as the user did — but induction won't close.
3. Insight: the actual count is geometric-series N(d,Δ); state the corrected bound and flag the discrepancy.
4. Execute Theorems 1–3, add the (b)-vs-(c) numeric comparison showing 700×.
5. Verify Weierstrass numerically + DAG instances (chain, balanced tree, bipartite layers).

### 7. Transferable Patterns
- **Library-first amortisation principle**: in any verified-pipeline analysis, paying the verification cost once at the lemma level beats deferring it to the end-to-end theorem level — the gap is always exponential in the depth/fan-out.
- The "tree-unfolding count N(d,Δ)" is the right quantitative substitute whenever someone wants to write "Δ^d" loosely.

---

## Proof 4: Cumulative Reasoning Depth Lower Bound (Problem 7.9)

### 1. The Spark
**question-asked** — "if (1−ε^k)^T is the upper bound, what's the matching lower bound on the number of verifier calls?"

### 2. The Key Insight
The leap is twofold: (i) reduce per-level error analysis to *Bernoulli hypothesis testing* between two indistinguishable candidates (Hypothesis 1 — the adversarial-alternative), then (ii) apply Yao's minimax to convert a deterministic-algorithm Bayes-error bound into a randomized-algorithm lower bound. Required prior: Yao's principle, Bayes-optimal binary tests, and the all-tail argument that gives ½·ε^{T_ℓ}.

### 3. The Technique Chain
- Yao's minimax principle — standard complexity-theory tool, used canonically.
- Bayes-optimal binary hypothesis test, all-tail probability ½·min(ε,1−ε)^{T_ℓ} — folklore Le Cam-style argument.
- Worst-level vs union bound choice — gives log(1/δ) instead of log(d/δ); subtle but standard.
- Brent-style critical-path argument for part (b) — invoked under transcript-dependency assumption (Hypothesis 2).

### 4. The Construction
Hypothesis 1 (adversarial-alternative) is the load-bearing construction: at each level, embed two propositions that the verifier confuses with probability ε. *Without* this construction, trivial level-tasks have O(1) complexity and there is no lower bound. Simplifying it kills the theorem.

### 5. The Failure Modes
- Try direct counting argument: "each verifier call reveals one bit, so need log(1/δ) bits per level" — gives the right order but is informal and doesn't survive Yao reduction.
- Try without Hypothesis 1: theorem is *false* — easy levels admit O(1) algorithms.
- Try parallel speedup attack against (b): valid under permissive verifier — flagged in the proof as honest "PARTIAL" verdict.

### 6. The Discovery Path
1. Notice symmetry: upper bound is dT/log(1/ε), so lower bound should match.
2. First attempt: counting bits — informal and not adversarial-robust.
3. Insight: cast as binary hypothesis test, deploy Yao's principle.
4. Execute (a) cleanly; (b) needs a transcript-dependency assumption (called out explicitly as gap); (c) numerical evaluation.
5. **Audit caught a numerical error**: the original problem stated "≈18" for the depth bound; correct value is 3.90. Proof was filed as PARTIAL, with the discrepancy flagged honestly rather than papered over.

### 7. Transferable Patterns
- **Yao + Bayes-error per level + sum across levels** is a reusable template for any "compositional task lower bound" question.
- The honest "PARTIAL with explicit gap" disposition is itself a pattern: when the user's stated bound is numerically wrong, *flag it* rather than retro-fit a derivation. This is meta-architecturally important for an automated proof agent.

---

## Proof 5: Cumulative Reasoning under Non-Stationary Verifier (Problem 7.4)

### 1. The Spark
**gap-in-literature** — Problem 4.1 assumes ε constant across rounds, but in practice verifier accuracy *degrades* as the chain gets longer (context dilution, error accumulation in the prompt). What does (1−ε)^T become when ε_t = ε_0(1+t/T_0)^α?

### 2. The Key Insight
Convert the discrete product log P_T = Σ log(1−ε_t) into a continuous integral via the integral test, then split into three regimes by the integrability of t^α: α<1 sub-linear (still survivable), α=1 linear (critical step T**), α>1 super-linear (super-polynomial collapse). Required prior: integral test, log(1−x) ≥ −x−x² Taylor bound, optimal-stopping FOC. The leap is *modeling*: choosing the polynomial decay family (1+t/T_0)^α as the right one-parameter family that exposes a phase transition at α=1.

### 3. The Technique Chain
- Integral test for monotone summands — standard analysis.
- log(1−x) ≥ −x−x² for x≤½ — standard Taylor bound.
- Bernoulli-style closed-form integral ∫(1+s/T_0)^α ds — calculus.
- Optimal-stopping via FOC on Φ(T) = β log T − ∫ε_s ds — standard concavity argument.
- Phase transition at α=1 read off integrability — standard "borderline-divergent" analysis.

### 4. The Construction
The polynomial decay family ε_t = ε_0(1+t/T_0)^α is *the* construction — chosen because (i) it interpolates between constant (α=0) and run-away (α→∞), (ii) it exhibits a clean integrability phase transition at α=1, (iii) it admits closed-form integrals. Replacing with exponential or sub-exponential decay loses the clean phase boundary.

### 5. The Failure Modes
- Try direct termwise bound 1−ε_t ≥ 1−ε_T (worst): gives (1−ε_T)^T which is way too loose, missing the integrability story.
- Try Stirling / large-T asymptotics first: misses the regime structure and the critical T** = T_0(1−1/e)/ε_0.
- Try optimal-stopping without the concavity proof: the FOC has multiple solutions in higher α, easy to grab wrong root.

### 6. The Discovery Path
1. Empirical: longer chains drift in actual LLM agents; constant-ε model is unrealistic.
2. Try: replace ε with ε_t directly — but the product becomes intractable.
3. Insight: log-product ↔ integral, exposing the α=1 phase transition.
4. Execute four parts: (a) sub-linear Taylor bound, (b) linear critical step, (c) super-linear divergence, (d) optimal stopping.
5. SymPy verifies (INT); numerics across α∈{0.5, 1, 2}, T∈[10, 2000].

### 7. Transferable Patterns
- **Log-product → integral → integrability phase transition** is a universal recipe for any "noisy-pipeline asymptotic" question.
- The optimal-stopping framing (Proposer benefit β log T vs accumulated risk ∫ε_s ds) is a reusable scaffold for any "when to halt a degrading process" decision.

---

## Cross-cutting summary

These five proofs are the agent reflecting on its own architecture. The core mathematical content of the *foundational* result (4.1) is undergraduate probability dressed in product form. The four elaborations differ sharply in honesty:

- 7.7 (compositional reuse) and 7.4 (non-stationary) are clean, novel-combination work that fixes user-stated formula errors transparently.
- 7.2 (categorical) is mostly *decorative formalism* — Lawvere/Banach machinery wrapped around a one-line iteration — with genuine but modest payoff in conceptual unification.
- 7.9 (depth lower bound) is the most substantive (Yao + hypothesis-testing template) but was the most flawed at submission: a 4.6× numerical error in part (c) and a model-dependency gap in (b), both flagged honestly rather than buried.

The most interesting **cross-cutting observation**: *self-referential proofs are an unusually clear discovery substrate* — because the "spark" is always traceable to an empirical observation of the agent's own behavior (audit failure rate 0.14, library reuse, context drift), there is no archaeological guesswork about motivation. The mathematics is simple; the design choices about *which formalism to wrap it in* are where the real intellectual variation lives, and the categorical proof (7.2) is a near-perfect case study of formalism-as-aesthetic-preference rather than formalism-as-necessity.
