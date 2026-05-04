---
title: "Conjecture Discovery via Iterative Refinement: An AI Agent for Open Mathematical Problems"
author: "Guancheng Pan, Chu Kochen Honors College, Zhejiang University"
date: "April 2026"
---

Existing AI mathematics systems perform proof search (AlphaProof), formalization (Gauss), or algorithm search (FunSearch). The system described here performs **mathematical research**: autonomously refining the right statement to prove, deriving results not in the literature, proving publication-grade theorems, and closing the loop with Lean 4 formal verification. Four demos exhibit four capabilities — a closed negative result (OP-2), a new explicit constant (Theorem 3), 7-round conjecture refinement (OP-1), and machine-verified formalization — spanning two fields: optimization theory and low-dimensional topology.

## Demos 1+2 — A complete upper/lower bound story for Stochastic Heavy Ball

**Problem.** Can SHB (fixed momentum $\beta>0$) accelerate over SGD on $L$-smooth convex stochastic problems? I.e., can the bias term beat $O(LD^2/T)$ — like Nesterov AC-SA's $O(LD^2/T^2)$?

**OP-2 (lower bound, CLOSED, publication-grade).** *No.* For every $(\beta,\eta)$ in the Goujaud feasibility region $\mathcal F_{K=3}$, $\exists$ hard instance with SHB error $\Omega(LD^2/T+\sigma D/\sqrt T)$ — strictly worse than AC-SA, identical to SGD. Three contributions: **(a)** *rescaled GTD23 cycling* — lift the Goujaud–Taylor–Dieuleveut 2023 strongly-convex cycling construction into the non-SC class by flattening one coordinate while preserving the $K{=}3$ orbit on the SC subspace; **(b)** *Le Cam two-point variance bound* — produce $\Omega(\sigma D/\sqrt T)$ via a coordinate-separable two-point hypothesis test, correctly handling SHB's adaptive queries; **(c)** *positive-measure cycling region* — characterize the zero-momentum-init cycling sub-region $\mathcal R^* \subset \mathcal F_{K=3}$ (anchor $\beta\!\approx\!0.303$) with $\operatorname{Leb}_3(\mathcal R^*) \ge 1.20\!\times\!10^{-4}$, certified by 216 mpmath-50-digit grid points + closed-form affine analysis.

**Theorem 3 (upper bound, NEW).** For every $\beta<1$, deterministic last-iterate $f(y_T)-f^* \le C(\beta;k)\,LD^2/(T+W(\beta;k)-1)$, with $C(\beta) \approx 0.36\,(1-\beta)^{-1.22}$. **No prior work gives an explicit closed-form $C(\beta)$:** Ghadimi–Feyzmahdavian–Johansson 2015 covers only Cesàro averages; Sebbouh–Gower 2021 gives only small-$o$. Method: PEP-style SDP + 2-step Lyapunov with $k$-step lookahead anchors; $\beta^*_{\text{LMI}}(k){=}0.957\!\to\!0.978\!\to\!0.993$, geometric ratio $\approx 0.71$ extrapolating to $\beta^*_\infty=1$. **Nine exact rational certificates** ($\beta\in\{0,0.1,\ldots,0.5,0.6,0.8\}$, SymPy QQ, PSD symbolic); CLARABEL numerical up to $\beta=0.993$; blow-up exponent $p\!\in\![1.21,1.25]$ consistent across $k=0,1,2$.

**Joint significance.** Matching upper (Thm 3) and lower (OP-2) bounds pin the SHB bias at $\Theta(LD^2/T)$ — a definitive *no* to "does fixed-$\beta$ SHB accelerate?", forming a self-contained SIOPT/Math. Prog. paper.

## Demo 3 — OP-1: 7-round conjecture refinement on the curve complex $C_1(S_{g,n})$

**Open problem (Souto 2007 et al.):** is $C_1(S_{g,n})$ contractible for positive-genus surfaces? The agent ran seven autonomous refinement rounds:

| # | Conjecture | Evidence | Key event |
|:---:|:---|:---|:---|
| 1 | Universal vertex | 132/138 sample | DISPROVED: 6 $K_4$-core counterexamples |
| 2 | Contractible | 64/64 exhaustive | Verified, no proof technique |
| 3 | Dismantlable | 378/378 exhaustive | Polat 2002 / Boulet–Fieux–Jouve 2008 connection |
| 4 | Chordal | 259/271 | 12 non-chordal exceptions at $k\!\ge\!4$ |
| 5 | (W4) wheel + (M) metric | 318/318 exhaustive | **Chepoi–Osajda 2014 cross-field connection** |
| 6 | Hatcher surgery filler | 12/12 non-chordal | level $k-2$, $i(\alpha,\sigma_\alpha)=0$, uniform |
| 7 | Chordal-or-cone dichotomy | 383/389 exhaustive | $i(\sigma_\alpha,\beta)=i(\alpha,\beta)$ exactly, 49/49 |

**OP-1 closure.** 389/389 descending links closed on the enumerated dataset ($S_{1,1}$ $k\!\le\!8$, $S_{1,2}$ $k\!\le\!8$, $S_{2,1}$ $k\!\le\!4$) via three lemmas: Lemma 2.1 (single-step bigon cancellation, Hass–Scott + homology parity), Lemma 4.1 (multi-step universal-vertex + mod-2 parity, verified 12/12 on $S_{1,2}$), and Lemma 7.1 (two-step almost-cone for 6 $S_{2,1}$ exceptions). $S_{1,1}$ closed rigorously via Stern–Brocot. During stress testing, the agent discovered that the Hatcher surgery interpretation diverges from the universal-vertex construction on $S_{2,1}$ (93 counterexamples) — a genuine structural finding about higher-genus curve complexes that does not affect the contractibility closure.

## Demo 4 — System architecture and Lean verification

`Proposer -> Rep Selector -> Verifier -> Explain-Why -> Tracker -> Prover -> Diagnoser -> Bridge -> (repeat)`. Three modules carry the load. **(i) Representation Registry** (31 validated entries) — distinct formalizations of the same object with cost-annotated transports; on stall the agent switches representation. **(ii) Explain-Why + Hypothesis Tracker** — on the smallest tractable instance the agent articulates *why* a conjecture holds; the working hypothesis is stress-tested on larger instances, turning failures into sharper successors. **(iii) Lean Backend** — **13/13 CERTIFIED** on the optlib benchmark; `OptLib2` is a self-contained 1371-LOC library, 9 theorems, all axiom-clean over `[propext, Classical.choice, Quot.sound]`. On Nesterov $O(1/T^2)$, the agent **autonomously synthesized the auxiliary sequence** `zSeq` with bridge identities (closed by `match_scalars <;> field_simp <;> ring`) — definition synthesis, not just proof search.

## What distinguishes this from existing systems

| | AlphaProof | Gauss | FunSearch | Liam Price (vibe maths) | **This system** |
|:---|:---:|:---:|:---:|:---:|:---:|
| Task | Proof search | Formalization | Algorithm search | One-shot prompting | **Math research** |
| Input | Fixed statement | Informal proof | Objective fn | Open problem | **Open problem** |
| New mathematical results | No | No | Yes (kissing #) | Yes (\#1196) | **Yes (OP-2 + Thm 3)** |
| Reproducible end-to-end | Yes | Yes | Yes | **No** | **Yes** |
| Cross-field analogy transfer | No | No | No | No | **Yes** |
| Learns from failure | No | No | Evolutionary | No | **Structured (registry+tracker)** |
| Formal verification | Lean | Lean | No | Lean (post-hoc) | **Lean (13/13, axiom-clean)** |
| Matching upper + lower bound | N/A | N/A | N/A | N/A | **Yes (OP-2 + Thm 3)** |

All code, verification scripts, Lean proofs, and SDP certificates are reproducible end-to-end.
