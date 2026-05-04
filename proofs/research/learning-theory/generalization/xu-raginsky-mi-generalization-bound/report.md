# Final Report: Xu–Raginsky MI Generalization Bound

**Problem:** Information-Theoretic Generalization Bound via Mutual Information (Xu & Raginsky 2017, NeurIPS)
**Date:** 2026-04-18

---

## 1. Problem Statement

**Setup.** Let $Z$ be a data space with distribution $\mathcal{D}$. A learning algorithm $A$ maps $Z^n \to \mathcal{W}$, yielding $W := A(S)$ where $S = (Z_1, \dots, Z_n) \stackrel{\text{iid}}{\sim} \mathcal{D}^n$.

**Sub-Gaussian assumption (A1).** Under the product measure $\mathbb{P}_W \otimes \mathcal{D}$, the loss $\ell(W, Z)$ is $\sigma$-sub-Gaussian:
$$\log \mathbb{E}_{\mathbb{P}_W \otimes \mathcal{D}}\!\left[e^{\lambda(\ell(W,Z) - \mathbb{E}[\ell(W,Z)])}\right] \le \frac{\lambda^2 \sigma^2}{2}, \quad \forall \lambda \in \mathbb{R}.$$

**Claim (Xu–Raginsky 2017):**
$$\big|\mathbb{E}[R_{\mathcal{D}}(W) - R_S(W)]\big| \;\le\; \sqrt{\frac{2\sigma^2 \cdot I(W; S)}{n}},$$
where $I(W; S) = D_{\mathrm{KL}}(\mathbb{P}_{W,S} \| \mathbb{P}_W \otimes \mathbb{P}_S)$.

The proof strategy (Route D) also establishes the stronger Bu–Zou–Veeravalli (BZV 2020) per-sample bound as an intermediate result:
$$\big|\mathbb{E}[R_{\mathcal{D}}(W) - R_S(W)]\big| \;\le\; \frac{1}{n} \sum_{i=1}^n \sqrt{2\sigma^2 \cdot I(W; Z_i)}.$$

---

## 2. Phase Summary

| Phase | Agent | Outcome |
|-------|-------|---------|
| Scout | 1 scout agent | 4 routes identified (A, C, D, E; Route B dropped as near-duplicate) |
| Explorer | 4 parallel explorers | Routes A, D, E fully succeeded; Route C honest collapse (reduces to Route A/D arithmetic) |
| Judge | Claude Sonnet 4.6 | Winner: Route D (39/40); Runner-up: Route E (38/40); Route A (36/40); Route C (29/40) |
| Audit | Claude Opus 4.7 (RIGOROUS) | PASS, Round 1; 20/20 claims VALID; 3/3 numerical examples verified; 4 LOW-severity exposition notes |
| Fix | — | Not needed; audit passed on Round 1 |

---

## 3. Proof Routes Explored

**Route A (DV + Sub-Gaussian Transport + KL Chain Rule) — 36/40 ELIGIBLE**
The canonical Xu–Raginsky 2017 argument. Proves DV variational formula (both directions), sub-Gaussian transport lemma, chain rule $\sum I(W;Z_i) \le I(W;S)$, and assembles via Jensen/Cauchy-Schwarz. All steps correct; slightly heavyweight (both DV directions proved, two proofs of Lemma 3, appendix on edge cases). Minor notational friction with auxiliary product measure $\tilde{\nu}$ in Lemma 3.

**Route C (PAC-Bayes Reduction) — 29/40 ELIGIBLE_WITH_GAP (honest collapse)**
Attempted to reduce Xu–Raginsky to McAllester/Catoni PAC-Bayes via $I(W;S) = \mathbb{E}_S[D_{\mathrm{KL}}(\mathbb{P}_{W|S} \| \mathbb{P}_W)]$. Obstruction at the joint MGF step (★): assumption (A1) is sub-Gaussianity under the *joint product* $\mathbb{P}_W \otimes \mathcal{D}$, not the per-hypothesis conditional; the PAC-Bayes MGF requires the latter. Route C honestly acknowledges this collapse and falls back to the Route A/D argument for the final proof. The failure is informative (see §F, failure_patterns.md).

**Route D (BZV Per-Sample MI → Xu–Raginsky Corollary) — 39/40 ELIGIBLE, WINNER**
Proves the strictly stronger BZV per-sample bound first, then derives Xu–Raginsky as a corollary via Jensen + Lemma 3. Most insightful proof structure: the two lossy steps (Jensen on $\sqrt{\cdot}$ and the chain-rule inequality) are made explicit and their strictness conditions are fully analyzed in §7. Single-pass $\lambda$-optimization in Lemma 2 (more elegant than Route A's ±-cases). See §4 for the full proof.

**Route E (Gibbs-Tilting Primal Identity) — 38/40 ELIGIBLE**
Bypasses DV supremum entirely. Key identity: $\mathbb{E}_P[\phi] = \log \mathbb{E}_Q[e^\phi] + D_{\mathrm{KL}}(P \| Q^\phi) - D_{\mathrm{KL}}(P\|Q)$; discarding $D_{\mathrm{KL}}(P\|Q^\phi) \ge 0$ gives the upper bound in one line. Conceptually the most novel derivation; structurally closer to the Langevin/free-energy literature. Minor gap in integrability verification when applying the lemma in §4.

---

## 4. Final Proof

*(Full content from `final_proof.md` — Route D, clean version)*

**Strategy.** Prove the BZV per-sample bound first; derive Xu–Raginsky as a corollary.

### Lemma 1 (Donsker–Varadhan upper bound)
For $P \ll Q$ and $f$ with $\mathbb{E}_Q[e^f] < \infty$, $\mathbb{E}_P[|f|] < \infty$:
$$\mathbb{E}_P[f] \;\le\; \log \mathbb{E}_Q[e^f] + D_{\mathrm{KL}}(P\|Q). \tag{DV}$$
*Proof:* Define $dQ_f/dQ = e^f/\mathbb{E}_Q[e^f]$. Expand $D_{\mathrm{KL}}(P\|Q_f) \ge 0$ (Gibbs) to obtain (DV). Only the upper-bound direction is used in the main theorem.

### Lemma 2 (Sub-Gaussian transport)
If $f$ is $\sigma$-sub-Gaussian under $Q$ and $P \ll Q$, then
$$|\mathbb{E}_P[f] - \mathbb{E}_Q[f]| \;\le\; \sqrt{2\sigma^2 D_{\mathrm{KL}}(P\|Q)}. \tag{ST}$$
*Proof:* Apply (DV) to $\lambda(f - \mathbb{E}_Q f)$ for every $\lambda \in \mathbb{R}$. This gives $\lambda\Delta - \lambda^2\sigma^2/2 \le D_{\mathrm{KL}}(P\|Q)$. Maximize over $\lambda$ (optimizer $\lambda^* = \Delta/\sigma^2$, value $\Delta^2/(2\sigma^2)$) to obtain $|\Delta| \le \sqrt{2\sigma^2 D_{\mathrm{KL}}(P\|Q)}$.

### Theorem 1 (BZV per-sample bound)
Under (A1) and iid $S$:
$$\boxed{\big|\mathbb{E}[R_{\mathcal{D}}(W) - R_S(W)]\big| \;\le\; \frac{1}{n}\sum_{i=1}^n \sqrt{2\sigma^2\, I(W;Z_i)}.} \tag{BZV}$$
*Proof:* Per-sample ghost decomposition (§1.4):
$$\mathbb{E}[R_{\mathcal{D}}(W) - R_S(W)] = \frac{1}{n}\sum_{i=1}^n \bigl(\mathbb{E}_{\mathbb{P}_W\otimes\mathcal{D}}[\ell(W,Z_i')] - \mathbb{E}_{\mathbb{P}_{W,Z_i}}[\ell(W,Z_i)]\bigr).$$
Fix $i$; apply Lemma 2 with $P = \mathbb{P}_{W,Z_i}$, $Q = \mathbb{P}_W \otimes \mathcal{D}$, $f = \ell$. Hypothesis (b) is exactly (A1); $D_{\mathrm{KL}}(P\|Q) = I(W;Z_i)$; $P \ll Q$ holds whenever $I(W;Z_i) < \infty$ (vacuous otherwise). Triangle inequality assembles BZV.

### Lemma 3 (Chain rule inequality under iid)
$$\sum_{i=1}^n I(W;Z_i) \;\le\; I(W;S). \tag{L3}$$
*Proof:* Chain rule gives $I(W;S) = \sum_i I(W;Z_i | Z_{1:i-1})$. Since $Z_i \perp Z_{1:i-1}$ (iid), $\mathbb{P}_{Z_i|Z_{1:i-1}} = \mathcal{D}$ a.s. (Ind). By joint convexity of $(P,Q) \mapsto D_{\mathrm{KL}}(P\|Q)$ (follows from joint convexity of $(a,b)\mapsto a\log(a/b)$) and Jensen applied against $\mathbb{P}_{Z_{1:i-1}}$:
$$I(W;Z_i|Z_{1:i-1}) = \mathbb{E}_{Z_{1:i-1}}[D_{\mathrm{KL}}(\mu_y\|\nu_y)] \;\ge\; D_{\mathrm{KL}}(\mathbb{P}_{W,Z_i}\|\mathbb{P}_W\otimes\mathcal{D}) = I(W;Z_i).$$
Summing gives (L3).

### Corollary (Xu–Raginsky 2017)
$$\boxed{\big|\mathbb{E}[R_{\mathcal{D}}(W) - R_S(W)]\big| \;\le\; \sqrt{\frac{2\sigma^2\, I(W;S)}{n}}.} \tag{XR}$$
*Proof:* From BZV, apply Jensen ($\sqrt{\cdot}$ concave): $\frac{1}{n}\sum_i\sqrt{I(W;Z_i)} \le \sqrt{\frac{1}{n}\sum_i I(W;Z_i)}$. Then Lemma 3: $\frac{1}{n}\sum_i I(W;Z_i) \le \frac{I(W;S)}{n}$. Chain to obtain (XR).

---

## 5. Audit Result

**Verdict: PASS (Round 1)**

- **Atomic claims audited:** 20
- **VALID:** 20
- **INVALID:** 0
- **Numerical examples verified:** 3/3
  - Example 1: $W = Z_1$, Bernoulli(0.3), $n=10$, $\sigma=0.5$; gap $0.042 \le$ BZV $0.0553 \le$ XR $0.1748$ ✓
  - Example 2: $W = \bar{Z}$, Gaussian, $n=20$, $\sigma=1$; BZV = XR (equal per-sample MIs) ✓
  - Example 3: Parity function, Bernoulli(0.4), $n=4$; gap $0.003840 \le$ BZV $0.003919$ (ratio 1.02, very tight) $\ll$ XR $0.2944$ ✓
- **Constant propagation:** All $2\sigma^2$ constants traced without slip through every step.

**Issues found (all LOW severity, exposition only):**

| # | Location | Description |
|---|----------|-------------|
| 1 | Lemma 1, final para | DV tightness (lower bound) cites Dupuis–Ellis but is not used; remark added in final_proof.md |
| 2 | Lemma 3, Step 3 | "Joint convexity of KL" — one-line justification added in final_proof.md |
| 3 | Theorem 1, point (a) | $P \ll Q$ condition — rephrased with explicit vacuous case in final_proof.md |
| 4 | §7 Remark (iv) | Permutation-invariance clarification — one sentence added in final_proof.md |

All four issues were addressed in `final_proof.md`. No mathematical errors were found.

---

## 6. Fix History

None required. The proof passed audit on the first round. The four LOW-severity exposition notes from the Judge's pre-audit memo were incorporated directly into `final_proof.md` during artifact generation (not a substantive fix — purely documentation).

---

## 7. Final Bounds

**BZV per-sample bound (Theorem 1, Bu–Zou–Veeravalli 2020):**
$$\big|\mathbb{E}[R_{\mathcal{D}}(W) - R_S(W)]\big| \;\le\; \frac{1}{n} \sum_{i=1}^n \sqrt{2\sigma^2\, I(W;Z_i)}.$$

**Xu–Raginsky bound (Corollary, Xu & Raginsky 2017):**
$$\big|\mathbb{E}[R_{\mathcal{D}}(W) - R_S(W)]\big| \;\le\; \sqrt{\frac{2\sigma^2\, I(W;S)}{n}}.$$

The BZV bound is strictly tighter when the per-sample MIs $I(W;Z_i)$ are unequal (Jensen strictness) or when the $Z_i$ interact non-trivially in determining $W$ (Lemma 3 strictness). In the single-sample-influence example ($W = g(Z_1)$, $n$ large), BZV $= \Theta(1/n)$ while XR $= \Theta(1/\sqrt{n})$, a $\sqrt{n}$ gap.
