# Literature Survey: D2 — Symbolic Regression Sample Complexity Lower Bound

**Survey date**: 2026-04-28
**Evaluator**: Claude Sonnet 4.6 (automated)

---

## Executive finding

There is **NO** paper in 2023–2026 that provides a formal minimax sample complexity lower bound for symbolic regression (SR) over a class S of bounded-depth/size expressions. The gap is genuine and structurally open. NP-hardness of SR (computational side) has been proved (2022, 2024), but the statistical side — how many i.i.d. observations (x_i, f(x_i)) are needed to identify f ∈ S — remains unaddressed in the learning-theory literature. This is the opportunity.

---

## SR methods and benchmarking (background)

### 1. La Cava et al. (2021) — Contemporary Symbolic Regression Methods and their Relative Performance (SRBench)
- **Venue**: NeurIPS 2021 (Datasets & Benchmarks Track)
- **Availability**: PMC11074949, cavalab.org/srbench
- **Content**: Open-source benchmark of 14 SR methods and 7 ML baselines on 252 diverse regression tasks. Establishes SR as a competitive ML paradigm for interpretable model discovery. No theoretical sample complexity analysis.
- **Relevance**: D2 defines the empirical setting. The Feynman physics subset (100 equations, up to 9 variables, analytic forms) is a natural motivation for choosing class S.

### 2. Cranmer / PySR (2023)
- **Paper**: "Interpretable Machine Learning for Science with PySR and SymbolicRegression.jl"
- **Availability**: arXiv 2305.01582
- **Content**: State-of-the-art multi-objective SR system using evolutionary search on expression trees; Pareto front balancing accuracy and complexity. Achieves top performance on SRBench. No theoretical guarantees.
- **Relevance**: PySR provides the computational sanity-check infrastructure for D2.

### 3. Udrescu & Tegmark (2020) — AI Feynman
- **Venue**: Science Advances 2020; AI Feynman 2.0 at NeurIPS 2020
- **Content**: Recursive neural-aided SR on 100 Feynman equations; uses symmetry detection, dimensional analysis, compositional decomposition. Raises but does not answer the question: how many data points are needed to reliably recover such equations?
- **Relevance**: Motivates the "exact recovery" framing — AI Feynman 2.0 already uses hypothesis testing language internally (statistical tests for compositional structure), but with no formal sample complexity analysis.

---

## Parametric vs. non-parametric sample complexity

### 4. Holsapple & Rakhlin (approx. 2021–2023, ongoing MIT work)
- **Content**: Rakhlin's group (MIT) has studied optimal learners for realizable regression (arXiv 2307.03848, COLT 2023). Realizable regression: given n samples of (x, y) with y = f(x) + noise and f ∈ F, estimate f. They characterize minimax rates via covering numbers for parametric and non-parametric F.
- **Relevance**: SR sits between parametric (linear model) and non-parametric (Sobolev ball): the hypothesis class S is finite for fixed depth/size bounds (enumerable, exponential in complexity parameters), but the number of distinct functions |S| grows combinatorially. Rakhlin's framework is the closest structural analogue — but it is not applied to expression classes.
- **Gap**: No paper in this line explicitly treats S = {depth-d expressions over {+, ×, sin, exp}}.

### 5. Sample Complexity Bounds for Linear System Identification from a Finite Set (2024)
- **arXiv**: 2409.11141
- **Content**: Maximum likelihood identification of LTI systems from a finite candidate set; information-theoretic lower bound via Fano's lemma applied to the finite hypothesis class.
- **Relevance**: Structural analogue to D2. If f ∈ S and |S| is enumerable, the same Fano argument applies but requires bounding the packing number of S in the appropriate metric, not just |S|.

---

## NP-hardness / computational side

### 6. Symbolic Regression is NP-hard (2022)
- **arXiv**: 2207.01018; OpenReview: LTiaPxqe2e
- **Content**: Formal proof that SR (finding the expression minimizing MSE on training data) is NP-hard via reduction. No statistical analysis.
- **Relevance**: Establishes that computational and statistical complexity can decouple for SR. A statistical lower bound is a separate (and arguably more novel) contribution.

### 7. "Prove Symbolic Regression is NP-hard by Symbol Graph" (2024)
- **arXiv**: 2404.13820
- **Content**: Alternative NP-hardness proof via symbol graph → degree-constrained Steiner arborescence reduction.
- **Relevance**: Confirms hardness persists under combinatorial formulations; motivates the choice of bounded-depth/size class S as the tractable-theory setting.

---

## SR generalization and out-of-distribution

### 8. "Analyzing Generalization in Pre-Trained Symbolic Regression" (2025)
- **arXiv**: 2509.19849
- **Content**: Empirical study showing pre-trained transformer SR models degrade out-of-distribution; identifies generalization gap. No formal sample complexity result.
- **Relevance**: Shows that "generalization for SR" is an acknowledged open problem — D2's theoretical result would directly explain empirically observed phenomena.

### 9. Recent Advances in Symbolic Regression (2025, survey)
- **Venue**: ACM Computing Surveys (accepted 2025), dl.acm.org/doi/10.1145/3735634
- **Content**: Comprehensive survey listing three future directions: enhancing generalization, improving interpretability, reducing computational complexity. Statistical learning theory for SR is listed as open.
- **Relevance**: Provides endorsement from the SR community that the theoretical gap D2 addresses is recognized.

---

## Information-theoretic LB machinery (pipeline-relevant)

### 10. Information Theoretic Lower Bounds for Information Theoretic Upper Bounds (NeurIPS 2023)
- **arXiv**: 2302.04925
- **Content**: Unified Fano/Le Cam/Assouad treatment showing when information-theoretic generalization bounds are dimension-dependent and tight. Directly applicable to the Fano-LB route for D2.

---

## State of the field

| Question | Status |
|---|---|
| SR is NP-hard (computational) | Proved (2022, 2024) |
| SR generalization empirically degrades OOD | Documented (2025) |
| SR PAC-learnability for restricted S | **Open** |
| Minimax sample complexity LB for SR with bounded-depth formulas | **Open** |
| Minimax UB (covering number bound) | Partial — analogous results for parametric function classes exist but not applied to expression trees |

**Early-exit verdict**: NOT triggered. No 2023–2026 paper provides a minimax sample complexity lower bound for SR over expression classes. D2 is open.
