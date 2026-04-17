# C3.4 — Application Scoping (narrowed to non-Euclidean SGD)

**Purpose**: Determine whether the non-Euclidean-scoped C3.4 has a genuine unclaimed application, or whether existing literature already subsumes it.

---

## 1. Landscape of "SGD on non-Euclidean parameter spaces"

| Algorithm family | Parameter space | Used for |
|---|---|---|
| Riemannian SGD (Bonnabel, [1111.5280](https://arxiv.org/abs/1111.5280)) | General Riemannian manifold | PCA, Karcher mean, matrix completion |
| Stiefel / Grassmannian SGD | $St(n,p)$, $Gr(n,p)$ | Orthogonality-constrained NN, dictionary learning, Cayley-SGD ([2002.01113](https://arxiv.org/abs/2002.01113)) |
| Hyperbolic SGD | Poincaré ball, Lorentz model | Hierarchical embedding, hyperbolic NN |
| GCN / GNN training (Euclidean params, graph in loss) | $\mathbb{R}^d$ (parameters) but loss uses graph Laplacian | Node classification, link prediction |
| node2vec / DeepWalk | Euclidean embedding space | Graph embedding |
| SGD on permutations / combinatorial | Discrete metric space (Cayley graph of $S_n$, etc.) | Learning to rank, assignment, combinatorial RL |
| Mirror descent on simplex | Simplex with KL divergence | Policy gradient, portfolio optimization |

**Note the critical split**:
- Rows 1–3 and the last two: parameter space is intrinsically non-Euclidean.
- Rows 4–5 (GNN, node2vec): parameter space is Euclidean; the graph enters through the loss.

C3.4 (coarse-Ricci-based stability) targets the **first group**.

---

## 2. Existing stability / generalization results in each family

### (a) Riemannian SGD on smooth manifolds
**Kozachkov, Wensing, Slotine — arXiv:[2201.06656](https://arxiv.org/abs/2201.06656) "Generalization in Supervised Learning Through Riemannian Contraction"**

Main theorem: *"If an optimizer is contracting in some Riemannian metric with rate $\lambda > 0$, it is uniformly algorithmically stable with rate $O(1/(\lambda n))$."*

Scope:
- Applies to SGD, natural gradient, in continuous and discrete time.
- Works for convex and non-convex losses.
- Requires **strict** contraction $\lambda > 0$.
- Recovers HRS and kernel-ridge-regression bounds as special cases.

**Directly subsumes the "Riemannian SGD" corollary of C3.4-revised.** The hypothesis "contraction rate $\lambda > 0$ in Riemannian metric" is equivalent, in the smooth setting, to "Ollivier coarse Ricci $\kappa \ge \lambda \cdot \alpha$ (up to $O(\alpha^2)$)." Since they handle the strictly-positive case with a stronger $O(1/(\lambda n))$ rate, our $O(T/n)$ for the non-strict case would only add content for $\lambda = 0$ exactly — a boundary case with marginal utility.

### (b) Stiefel / Grassmannian SGD
No algorithm-specific uniform-stability paper found. Falls under the Kozachkov framework if Stiefel-contraction is verified. Stiefel has **non-negative** sectional curvature (it's a homogeneous space with a bi-invariant metric), so Riemannian contraction is natural there. A specialized Stiefel-SGD stability bound would be a concrete application but would likely be a direct instantiation of Kozachkov.

### (c) Hyperbolic / negatively curved manifolds
**Negative curvature makes Ollivier $\kappa < 0$**, so the C3.4 hypothesis fails. Not a viable target.

### (d) GCN / GNN training
**Verma & Zhang — arXiv:[1905.01004](https://arxiv.org/abs/1905.01004) (KDD 2019) "Stability and Generalization of GCNNs"**, extended by [2410.08473](https://arxiv.org/html/2410.08473) "Deeper Insights into Deep GCNs" (2024).

- Single-layer GCN trained via SGD has uniform stability bounded by the largest absolute eigenvalue of the graph convolution filter.
- Deep GCN extension: stability degrades with depth (explains over-smoothing).
- Method: standard HRS recursion with Euclidean parameters, graph structure enters via Lipschitz constant of the network.

**These treat GNNs as Euclidean SGD with graph-structured loss.** Coarse Ricci of the graph is not used as hypothesis. A coarse-Ricci-based bound **would** be novel in this literature — but the graph appears in the loss Lipschitz constant, not in the parameter-space geometry, so the natural coarse-Ricci statement would be on the **graph itself** (message-passing dynamics on the graph), not on the SGD parameters. This is a different research direction from C3.4.

### (e) node2vec / DeepWalk
[1710.02971](https://arxiv.org/abs/1710.02971): matrix-factorization equivalence. [Stochastic Blockmodel recovery theory](https://ieeexplore.ieee.org/document/10296009/): consistency, not stability.
**No HRS-style uniform stability bound found.** But the SGD is again on Euclidean embedding parameters (with a graph-walk sampling scheme), so it's not the right target for coarse Ricci.

### (f) SGD on discrete metric spaces (permutations, combinatorial)
Almost no ML stability literature. Combinatorial optimization community has coarse-Ricci work (Bauer–Jost–Liu etc.) on graphs, but none of it applied to SGD-type learning algorithms. **This is genuinely unclaimed.**

---

## 3. Gap analysis for the three C3.4 positioning options

### Option (a) — "Graph SGD uniform stability via discrete Ricci"

| Sub-target | Status |
|---|---|
| GCN / GNN training via SGD | **COVERED** by Verma–Zhang (1905.01004) and follow-ups; they use graph filter eigenvalue, not Ricci, but cover the same result space |
| node2vec / DeepWalk embedding via SGD | No stability result exists, but the SGD is Euclidean — coarse Ricci of parameter kernel is trivially HRS |
| Message-passing dynamics (treat GNN propagation as SGD on graph function space) | Genuinely open, but is a different problem from C3.4's setup |

**Verdict**: Option (a) has no clean landing.

### Option (b) — "Riemannian SGD stability via Ricci curvature on manifold"

**COVERED** by Kozachkov et al. (2201.06656). Their contraction-based statement is strictly stronger in the strict-positive regime. The only technical slice left is $\lambda = 0$ (non-strict contraction), which gives $O(T/n)$ instead of $O(1/(\lambda n))$ — a boundary case.

**Verdict**: Option (b) is essentially rediscovery.

### Option (c) — "Abstract metric-measure SGD with coarse Ricci"

Truly general. Would include discrete/combinatorial SGD as a special case. The Kozachkov framework is smooth-Riemannian and **does not cover non-smooth discrete metric spaces** in its present form.

Concrete sub-target: **SGD on permutations** (Cayley graph of $S_n$), e.g., learning-to-rank with Plackett–Luce sampling + Mallows-like loss. Parameter space is $S_n$ with transposition distance; SGD = Metropolis-like moves following a gradient estimate.

**Verdict**: Option (c) is open, but niche and speculative — unclear who would cite it.

---

## 4. Revised risk assessment

| Risk | Status after scoping |
|---|---|
| (R1) Pure SGD Ricci degenerate in convex Euclidean | Already known — C3.4-Euclidean collapses to HRS (expected) |
| (R2) Overlap with 2305.12056 for noisy non-convex Euclidean SGD | Confirmed overlap |
| (R3) Uniform $\kappa \ge 0$ fails in non-convex Euclidean | Confirmed blocker |
| **(R4) NEW: Kozachkov 2022 already proves the Riemannian version** | **Major blocker for Option (b)** |
| **(R5) NEW: Verma–Zhang 2019 covers GNN stability** | **Blocker for Option (a)'s main target** |

**Conclusion**: C3.4 in any ML-relevant concrete positioning is either **rediscovered** (Options a, b) or **too niche** (Option c) to be worth prioritizing.

---

## 5. Final recommendation

### Primary: **Abandon C3.4 in its current framing. Switch to C1.4 (STORM-style recursive momentum for MCMC ergodic averages).**

**Rationale**:
- Kozachkov et al. 2022 ([2201.06656](https://arxiv.org/abs/2201.06656)) already proves the clean Riemannian-contraction → uniform stability theorem, with strict-contraction rate $O(1/(\lambda n))$.
- Verma–Zhang ([1905.01004](https://arxiv.org/abs/1905.01004)) and 2024 follow-up ([2410.08473](https://arxiv.org/html/2410.08473)) cover the GNN uniform-stability corollary.
- The non-Euclidean metric-measure-space version (Option c) is open but niche and hard to motivate concretely; the only plausible concrete target (SGD on permutations) requires first constructing the problem setting.

### Secondary (optional salvage): **Narrow further to "coarse Ricci on non-smooth metric measure spaces" with a concrete combinatorial SGD example.**

If the user is attached to curvature-based stability, pursue a very specific target:
- **Problem**: SGD-like randomized swap algorithm for learning a ranking / permutation from pairwise preferences. Parameter space: $S_n$. Metric: Kendall $\tau$ or transposition distance.
- **Contribution**: prove uniform stability via coarse Ricci of the swap kernel (Bauer–Jost–Liu curvature of the Cayley graph of $S_n$). Would fill the gap in combinatorial learning theory.
- **Risk**: no strong community demand; problem setting needs construction from scratch; likely a narrow 20-page paper rather than a foundational result.

### Recommendation ranking (updated)

| Candidate | Old rank | New rank | Why |
|---|---|---|---|
| C3.4 (OR ⇒ stability) | 1 | **3 (demoted)** | Subsumed by Kozachkov 2022 for all ML-relevant corollaries. Only the "abstract metric-measure SGD" framing remains, and that's niche. |
| C1.4 (STORM → MCMC) | 2 | **1 (promoted)** | No direct overlap; genuine gap; proof template ports cleanly from STORM; concrete target (posterior expectation variance reduction) with clear audience (Bayesian DL, MCMC-SGLD). |
| C3.3 (potential-game perturbation generalization) | 3 | 2 | Still open, but requires model construction. Medium feasibility, medium value. |
| C3.4-salvage (SGD on permutations) | — | 4 | Niche, speculative, would need problem construction before proof. |

### Concrete next step

**Start a feasibility analysis for C1.4** analogous to the one done for C3.4, focusing on:
1. What is the STORM-analog of the "mean-squared smoothness" assumption in Markov-chain context (mixing / Poincaré)?
2. Does the polarization-identity + Lyapunov template port from optimization to MCMC?
3. Is the rate $O(\text{Var}/T^2)$ actually achievable, or does the $a = \Theta(1/\sqrt{T})$ scaling need adjustment when $(1-a)$ comes from chain contraction rather than the algorithm parameter?
4. What concrete Bayesian-inference problem would be the headline application?

If C1.4 feasibility clears (blockers manageable), proceed with the five-phase proof protocol.

---

## Sources

- [arXiv:2201.06656](https://arxiv.org/abs/2201.06656) — Kozachkov, Wensing, Slotine — "Generalization in Supervised Learning Through Riemannian Contraction." **Main subsumer of C3.4.**
- [arXiv:1905.01004](https://arxiv.org/abs/1905.01004) — Verma & Zhang (KDD 2019) — "Stability and Generalization of GCNNs." **Subsumer of GCN corollary.**
- [arXiv:2410.08473](https://arxiv.org/html/2410.08473) — "Deeper Insights into Deep GCNs: Stability and Generalization." Extends Verma–Zhang to deep GCNs.
- [arXiv:1111.5280](https://arxiv.org/abs/1111.5280) — Bonnabel — "SGD on Riemannian Manifolds." Foundational.
- [arXiv:2002.01113](https://arxiv.org/abs/2002.01113) — "Cayley Transform for Stiefel." Algorithm example, no stability.
- [arXiv:1710.02971](https://arxiv.org/abs/1710.02971) — "Network Embedding as Matrix Factorization." node2vec/DeepWalk theory.
- [arXiv:2305.12056](https://arxiv.org/abs/2305.12056) — "Uniform-in-Time Wasserstein Stability for SGD." Dissipativity-based, round-2 overlap.
