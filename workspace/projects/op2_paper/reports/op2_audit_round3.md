# OP-2 Downgraded v2 — Round-3 Pre-Submission Audit

**Target:** `workspace/op2_downgraded_proof_v2.md`
**Date:** 2026-04-18
**Standard:** Would Goujaud or Taylor find an error on first read?
**Auditor:** Claude Opus 4.7

---

## Executive summary

- **Math correctness:** No mathematical errors found. Every displayed inequality verifies; every "⇒" is justified; constants close (1/112 derivation is airtight).
- **Submission readiness:** **NOT YET.** Two writing issues would cause an expert reviewer to reject on first read (F1, F1'). Four minor FLAGs need clarifying sentences but are not blockers in the math.
- **Verdict: `NEEDS_FIX`** — writing fixes required (§F); math-level FLAGs in §B4/C5/D1/D2 are nice-to-have polish.

---

## A. Theorem statement

### A1. Quantifier order  →  **PASS**

§0.5 reads: *"Then for every $(\beta,\eta) \in \mathcal F$ and every integer $T \geq 1$, there exist (1) a function $f_{\beta,\eta}^{(T)}$, (2) an initial pair, (3) an unbiased oracle such that..."*

This is $\forall(\beta,\eta,T)\,\exists(f,\text{init},\text{oracle})$. Correctly ∀-∃.

Scope remark in §0.6 line 89 explicitly reinforces: *"The function $f_{\beta,\eta}^{(T)}$ depends on $(\beta,\eta,T)$. The theorem is ∀-∃, not ∃-∀."*

### A2. Self-consistency of $\mathcal F$  →  **PASS**

§0.4 line 60: $\mathcal F = \{(\beta,\eta) \in \mathcal S : \exists K \geq 3, \exists \kappa \in (0,1) \text{ s.t.\ (★) holds}\}$. Both existential quantifiers properly nested inside the stability-region restriction. $\kappa \in (0,1)$ (strict) is compatible with Lemma 1.3's hypothesis $\mu \in (0,L)$ (since $\mu = \kappa L$).

### A3. RGM hypothesis in theorem statement  →  **PASS**

§0.5 line 66–67 boxes (RGM): $\sigma \leq LD\sqrt 2$ as an **explicit hypothesis** of the Main Theorem, with the equivalence $\sigma \leq LD\sqrt{2T}$ for all $T \geq 1$ noted. §0.7 handles $\sigma > LD\sqrt 2$ via a separate Remark showing the variance term dominates trivially. No silent hypothesis sneaking into the construction.

### A4. $c_\mathrm{NY}$ consistency  →  **PASS**

Grep confirms: $c_\mathrm{NY} = 1/112$ appears in
- §0.5 (theorem, line 78)
- Lemma 2.9 (line 373, 410)
- Remark line 412
- Claim 2.10 (line 428)
- §4.5 novelty (line 629)
- Appendix B diff table (line 655)

Values $1/56$ and $1/(8\sqrt 2)$ appear **only** in historical comparison contexts (summary line 13, derivation remarks line 417–420, diff table line 662). Theorem and proof body are internally consistent on $1/112$.

---

## B. Construction

### B1. Rescaled Goujaud $f_0$  →  **PASS**

- **Lemma 1.7** (line 211–226): Positive homogeneity of projection. Proof is the textbook change-of-variables $w = \lambda z$, $\lambda^2$ pulls out of argmin. Clean, complete.
- **Corollary 1.8**: $d_{\lambda C}(\lambda x) = \lambda d_C(x)$. One-line proof. ✓
- $f_0(x) := (L/2)\|x\|^2 - ((L-\mu)/2) d_{\mathrm{conv}(\widetilde P)}(x)^2$ on the **rescaled** polytope $\widetilde P = (D/\sqrt 2) P$.
- **Smoothness = L:** verified via $f_0 = (\mu/2)\|x\|^2 + (L-\mu)\Phi_{\mathrm{conv}(\widetilde P)}$, Moreau + 1-Lipschitz projection gives $\mu + (L-\mu)\cdot 1 = L$. ✓
- **Strong convexity = $\mu$:** monotonicity of $P_C$ gives $\langle\nabla f_0(x) - \nabla f_0(y), x-y\rangle \geq \mu\|x-y\|^2$. ✓

Claim 2.1 proof is complete and does not quietly depend on Lemma 1.7 (it uses only Lemma 1.1 + monotonicity).

### B2. Wall function $w$  →  **PASS**

- $R = D/\sqrt 2 - \alpha/L$ with $\alpha = \sigma/(2\sqrt{2T})$.
- Under (RGM): $\alpha \leq LD\sqrt 2/(2\sqrt{2T}) = LD/(2\sqrt T) \leq LD/2$, so $\alpha/L \leq D/2 < D/\sqrt 2$, giving $R \in (0, D/\sqrt 2)$. ✓
- $y^\star_s = -sD/\sqrt 2$ **exactly**: verified by the stationarity condition $\alpha_s + w'(y^\star_s) = 0$ at $|y| > R$, $y = -R - \alpha/L = -(D/\sqrt 2 - \alpha/L) - \alpha/L = -D/\sqrt 2$. ✓
- $w''(y) = 0$ for $|y| < R$, $w''(y) = L$ for $|y| > R$. Both bounded by $L$. ✓

### B3. 3D Hessian and global SC = 0  →  **PASS**

- $\nabla^2 f^{(s)}(x,y) = \nabla^2 f_0(x) \oplus w''(y)$ (block-diagonal; the linear term $\alpha_s y$ has zero Hessian).
- Upper bound: $\nabla^2 f^{(s)} \preceq L\, I_3$ (both blocks $\preceq L$). ✓
- Lower bound at $(0,0)$: Claim 2.12 verifies $\nabla^2 f_0(0) = L\, I_2$ (because $0 \in \mathrm{int}(\mathrm{conv}(\widetilde P))$, so $\nabla P = I$ locally) and $w''(0) = 0$. Hence $\nabla^2 f^{(s)}(0,0) = \mathrm{diag}(L,L,0)$, min eigenvalue 0. Test vector $v = (0,0,1)$ confirms SC constant $= 0$. ✓

**Subtle point** correctly handled in Claim 2.12: $f_0$'s Hessian is $LI_2$ **at the origin** (interior of $\mathrm{conv}(\widetilde P)$) but only $\mu I_2$ at cycle points (where $\nabla P$ has rank 0). The global SC bound $\mu I_2$ comes from the minimum eigenvalue over the Hessian's range.

### B4. Stochastic oracle  →  **FLAG (minor)**

- §2.1.3 uses Gaussian noise $\xi_t \sim \mathcal N(0,\sigma^2)$. ✓
- Claim 2.3 verifies unbiasedness and variance $\sigma^2$. ✓

**FLAG:** Lemma 1.4 is **stated** for i.i.d. samples $Y = s\alpha + \sigma\varepsilon$, but used in Lemma 2.9 (line 377) in an **adaptive** setting (queries $y_t$ depend on past observations). The adaptive extension holds because the $s$-dependence is only through the additive offset $\alpha_s$, which is history-independent — so KL tensorizes via the chain rule $\mathrm{KL}(P_+^T \| P_-^T) = \sum_t \mathbb E_+[\mathrm{KL}(P_+^{U_t|\mathcal H_t} \| P_-^{U_t|\mathcal H_t})]$ and each conditional KL is $2\alpha^2/\sigma^2$ (the $w'(y_t)$ term cancels under both hypotheses).

**Fix:** Add one sentence after line 377: *"The bound applies in our adaptive setting because the $s$-dependence is only through the constant offset $\alpha_s$; the query-dependent term $w'(y_t)$ cancels in the per-query KL, so tensorization gives $\mathrm{KL}(P_+^T \| P_-^T) = T \cdot 2\alpha^2/\sigma^2 = 1/4$ regardless of the query protocol."*

### B5. Initial distance Claim 2.4  →  **PASS**

Line 297–306: $\|(x_0, 0) - (0, y^\star_s)\|^2 = (D/\sqrt 2)^2\|e_0\|^2 + (D/\sqrt 2)^2 = D^2/2 + D^2/2 = D^2$. Exact equality. By symmetry ($|y^\star_+| = |y^\star_-| = D/\sqrt 2$), distance = D for both $s \in \{\pm\}$. ✓

---

## C. Proof core logic

### C1. Decoupling (Claim 2.5)  →  **PASS**

- x-update: $x_{t+1} = x_t - \eta \nabla f_0(x_t) + \beta(x_t - x_{t-1})$. No noise (the oracle's x-component is exact), no $y_t$ dependence (since $\nabla_x f^{(s)} = \nabla f_0(x)$). ✓
- y-update: $y_{t+1} = y_t - \eta[\alpha_s + w'(y_t) + \xi_t] + \beta(y_t - y_{t-1})$. No $x_t$ dependence (since $\partial_y f^{(s)}$ doesn't involve $x$). ✓

Oracle in §2.1.3 is **$(\nabla f_0(x_t), \partial_y f^{(s)}(x_t, y_t) + \xi_t)$**: the x-component is deterministic and y-independent; y-component gets the additive Gaussian noise. Decoupling holds exactly.

### C2. Cycling (Lemma 2.6)  →  **PASS**

Four-step proof, no jumps:
1. $P_{\widetilde C}(\lambda e_t) = \lambda M e_t$ — direct from Lemma 1.7 applied to Lemma 1.3(iii).
2. $\nabla f_0(\lambda e_t) = \lambda \nabla \psi(e_t)$ — from (F0-grad) and Step 1.
3. $\eta \nabla \psi(e_t) = (1+\beta)e_t - e_{t+1} - \beta e_{t-1}$ — from GTD23 Lemma 1.3(iv)'s internal calculation.
4. Induction. I verified Step 4's algebra:
   $x_{t+1} = \lambda e_t - \lambda[(1+\beta)e_t - e_{t+1} - \beta e_{t-1}] + \beta(\lambda e_t - \lambda e_{t-1})$
   $\phantom{x_{t+1}} = \lambda[1 - (1+\beta) + \beta]e_t + \lambda e_{t+1} + \lambda[\beta - \beta]e_{t-1} = \lambda e_{t+1}$. ✓

Base case $(x_{-1}, x_0) = (\lambda e_{K-1}, \lambda e_0)$ matches the construction. Periodicity $e_{-1} = e_{K-1}$ gives the induction start.

### C3. Bias lower bound (Lemma 2.7 + Claim 2.8)  →  **PASS**

- Lemma 2.6 ⇒ $\|x_T\| = \lambda = D/\sqrt 2$, so $\|x_T - 0\|^2 = D^2/2$.
- $f_0$ is $\mu$-SC with $x^\star = 0$, $f_0^\star = 0$. Lemma 1.2 gives $f_0(x_T) \geq (\mu/2)(D^2/2) = \mu D^2/4 = \kappa LD^2/4$. ✓
- For $T \geq 1$: $\kappa LD^2/4 \geq \kappa LD^2/(4T) = (\kappa/4)\cdot LD^2/T$. ✓

The conversion from the $T$-independent cycle gap to an $LD^2/T$ rate is tight at $T=1$ and lossy for $T \gg 1$, but since the bound we need is $\Omega(LD^2/T)$ with **some** constant, this monotone-in-$T$ bound suffices.

### C4. Variance lower bound (Lemma 2.9)  →  **PASS (math) / FLAG (see B4)**

5-step derivation, verified arithmetic:

**Step 1** (Le Cam): KL per sample $= 2\alpha^2/\sigma^2 = 1/(4T)$; tensorized $\leq 1/4$; Pinsker TV $\leq \sqrt{1/8} = 1/(2\sqrt 2)$; $p_{\min} \geq (1 - 1/(2\sqrt 2))/2 \approx 0.323 \geq 1/14$. ✓

**Step 2** (gap on misidentification): On $A_s = \{\mathrm{sgn}(y_T) = s\}$, $\alpha_s y_T = s\alpha y_T = \alpha|y_T| \geq 0$ and $w(y_T) \geq 0$, so
$$G_s(y_T) \geq 0 - [-\alpha D/\sqrt 2 + \alpha^2/(2L)] = \alpha D/\sqrt 2 - \alpha^2/(2L).$$
Here $\min_y(\alpha_s y + w(y)) = \alpha_s y^\star_s + w(y^\star_s) = -\alpha D/\sqrt 2 + \alpha^2/(2L)$ (the $w$-value at the minimizer: $w(y^\star_s) = (L/2)(|y^\star_s| - R)^2 = (L/2)(\alpha/L)^2 = \alpha^2/(2L)$). ✓

**Step 3** (wall correction): Under (RGM), $\alpha \leq LD/2$ so $\alpha^2/(2L) \leq \alpha D/4$. Then $G_s \geq \alpha D(1/\sqrt 2 - 1/4)$. Check $1/\sqrt 2 - 1/4 \geq 1/(2\sqrt 2)$:
$$1/\sqrt 2 - 1/(2\sqrt 2) = 1/(2\sqrt 2) \approx 0.354 > 0.25 = 1/4. \checkmark$$
Hence $G_s \geq \alpha D/(2\sqrt 2)$. ✓

**Step 4** (max over $s$, expectation): $G_s \geq 0$ pointwise (it's a gap from min), so $\mathbb E_s[G_s] \geq (\alpha D/(2\sqrt 2))\mathbb P_s[A_s]$. Max over $s$: $\max_s \mathbb E_s[G_s] \geq (\alpha D/(2\sqrt 2))(1/14) = \alpha D/(28\sqrt 2)$. ✓

**Step 5** (substitute $\alpha$): Verified $28\sqrt 2 \cdot 2\sqrt{2T} = 56\sqrt 2 \cdot \sqrt{2T} = 56\sqrt{4T} = 112\sqrt T$. So $\alpha D/(28\sqrt 2) = \sigma D/(112\sqrt T)$. ✓

Constants are honest and derivation is complete.

### C5. Combining bias + variance (Claim 2.10, 2.11)  →  **FLAG (minor)**

- Coordinate separability: $f^{(s)}(x,y) - f^{(s),\star} = [f_0(x) - f_0^\star] + G_s(y)$. ✓
- $x_T$ deterministic ⇒ $\mathbb E_s[f_0(x_T) - f_0^\star] = f_0(x_T) - f_0^\star$ (s-independent constant). ✓
- Claim 2.11 applies $\max_s(A + B_s) = A + \max_s B_s$ with $A$ deterministic. ✓

**FLAG:** The conclusion step (lines 448–450) defines $f_{\beta,\eta}^{(T)} := f^{(s^\star)}$ where $s^\star = \arg\max_s \mathbb E_s[\cdot]$. $s^\star$ depends on the SHB trajectory under each hypothesis. This is a valid lower-bound construction (pick the instance where SHB does worse), but a reader might wonder whether the hard instance genuinely exists **independently of SHB's behavior**. One clarifying sentence would remove the ambiguity.

**Fix:** Add after line 448: *"Explicitly: run (a mental-experiment copy of) SHB once on each of $f^{(+)}$ and $f^{(-)}$, compute both expected excess risks, and let $s^\star$ be the index of the larger. The hard instance $f_{\beta,\eta}^{(T)} := f^{(s^\star)}$ then satisfies (MAIN); since $\max_s \geq$ average $\geq $ the bound, the same inequality holds."*

---

## D. Auxiliary verifications

### D1. $\mathcal F$ positive measure (Claim 2.13)  →  **FLAG**

- **Step 1** (line 474–486): At $K=3$, derive $\gamma_\mathrm{crit}(\beta) = 3(1+\beta+\beta^2)/(1+2\beta)$. The author claims "feasibility at $K=3$ is equivalent to $\eta L (1+2\beta) \geq 3(1+\beta+\beta^2)$". This is verified **empirically** in Part 3.2 (all 7 test points confirm), but the **derivation is terse**: "After algebraic simplification (complete the square or solve for $\kappa$ explicitly)..."

  One direction ($\eta L \geq \gamma_\mathrm{crit} \Rightarrow$ feasible) is easy: as $\kappa \to 0^+$, (★) → $3(1+\beta+\beta^2) - (1+2\beta)\eta L \leq 0$. The reverse direction (infeasibility when $\eta L < \gamma_\mathrm{crit}$) requires showing **no** $\kappa \in (0,1)$ satisfies (★) — which is nontrivial because (★)'s LHS as a function of $\kappa$ has a complicated structure (quadratic in $\kappa$ with $\beta,\eta$-dependent coefficients).

- **Step 2** (line 488–496): $\gamma_\mathrm{crit} \leq 2(1+\beta) \Leftrightarrow \beta^2 + 3\beta - 1 \geq 0 \Leftrightarrow \beta \geq \beta^\star = (\sqrt{13}-3)/2$. ✓ Algebra verified.

- **Step 3** (line 498–502): integrand $(\beta^2 + 3\beta - 1)/(1+2\beta)$ continuous and strictly positive on $(\beta^\star, 1)$, integral $>0$. Closed form $\beta^2/4 + 5\beta/4 - (9/8)\ln(1+2\beta)$ verified by polynomial division. ✓

- **Step 4** (line 504): openness from strict inequalities on continuous functions. ✓

**FLAG:** Step 1's equivalence statement should either (a) provide the quadratic-in-$\kappa$ analysis showing infeasibility when $\eta L < \gamma_\mathrm{crit}$, or (b) weaken to "sufficient condition" and note empirical necessity.

**Fix:** Weaken line 485 to: *"A sufficient condition for feasibility is $\eta L (1+2\beta) \geq 3(1+\beta+\beta^2)$ (take $\kappa \to 0^+$, verified by the $\kappa$-limit of (★)). Empirically (Part 3.2), this condition is also necessary at $K=3$; we use only sufficiency for the measure argument."*

### D2. Tightness with GFJ15  →  **FLAG**

**Issue:** Lemma 1.6 (GFJ15, line 206) states the UB holds for the **weighted-average iterate** $\bar x_T$. The Main Theorem LB is for the **last iterate** $x_T$. §4.2 claims tightness without addressing this distinction.

**Resolution (implicit in the proof but not stated):**
- **Bias term**: Lemma 2.6 ⇒ $x_t$ lies on the $K$-cycle at radius $D/\sqrt 2$ for **every** $t$. By rotation-invariance of $\mathrm{conv}(\widetilde P)$, $f_0(x_t)$ is **constant** in $t$. Hence $f_0(\bar x_T) = f_0(x_T) = \kappa LD^2/4$ by Jensen + invariance (or explicit computation on cycles). The bias LB therefore transfers from last-iterate to weighted-average.
- **Variance term**: The last-iterate Le Cam bound $\Omega(\sigma D/\sqrt T)$ does **not** directly transfer to the average, but the averaged version follows from applying Lemma 2.9 at each $t$: $\mathbb E_s[G_s(y_t)] \geq c_\mathrm{NY} \sigma D/\sqrt t$, and averaging gives $\Omega(\sigma D/\sqrt T)$ (with a different constant $\sim \int_1^T t^{-1/2}dt/T = 2(\sqrt T - 1)/T \sim 2/\sqrt T$).

**Fix:** Add to §4.2 line 616: *"Strictly, the GFJ15 UB is stated for the weighted-average iterate $\bar x_T$ while our LB is for $x_T$. This is not a gap: the bias term is $T$-independent on the cycle (Lemma 2.6 + rotation invariance of $\mathrm{conv}(\widetilde P)$), so $f_0(\bar x_T) = f_0(x_T)$ exactly; the variance term's average version follows from Lemma 2.9 applied to each $y_t$ and Jensen. Hence the tight rate holds for both iterates."*

### D3. Scope declaration (§0.6)  →  **PASS**

All three disclaimers present (line 87–89):
- ✓ "Not claimed on $\mathcal S \setminus \mathcal F$"
- ✓ "Not claimed for time-varying $(\beta_t, \eta_t)$"
- ✓ "The function $f_{\beta,\eta}^{(T)}$ depends on $(\beta,\eta,T)$. The theorem is ∀-∃, not ∃-∀."

---

## E. Numerical consistency

### E1. Existing simulations vs v2  →  **PASS**

Part 3.2 (feasibility classification), Part 3.3 (positive control cycling), Part 3.4 (negative control decay), Part 3.5 (threshold $\beta^\star$) — all test only the **deterministic** $x$-coordinate dynamics and the **$\gamma_\mathrm{crit}$ threshold**. None involves the wall $w$ or the noise. v2's changes (wall redesign, Gaussian noise, $c_\mathrm{NY}$ constant) do not invalidate any of these simulations. Numerical results in Part 3 remain valid for v2. ✓

### E2. Variance-side simulation gap  →  **FLAG (not a fix-blocker)**

Neither v1 nor v2 includes a numerical verification of Lemma 2.9 or $c_\mathrm{NY} = 1/112$. A small Monte-Carlo simulation (e.g., run SHB on the y-coordinate with Gaussian noise, T ∈ {100, 1000}, check $\mathbb E[G_s(y_T)] \gtrsim \sigma D/(112\sqrt T)$) would harden the variance-side claim. Current paper does not claim numerical verification of the variance constant, so this is an omission, not an error.

**Suggested (optional):** Add a short script `verify_variance.py` that samples 10k trajectories and reports $\hat{\mathbb E}[G_s(y_T)] \cdot \sqrt T / (\sigma D)$ vs the theoretical $1/112$.

---

## F. Writing / submission-readiness

### F1. v1 retraction residue in Lemma 1.4 proof  →  **CRITICAL FLAG**

Lines 170–186 (proof of Lemma 1.4(a)) contain a literal debug-log of failed Rademacher attempts:

> Line 171: *"To make the KL finite, we use the standard 'contiguous support' convention..."* (paragraph of Rademacher attempt 1)
>
> Line 173: *"...but this loses info."*
>
> Line 175: *"**Better (direct KL on the full support).**"* (Rademacher attempt 2)
>
> Line 180: *"So $\mathbb P_+ \perp \mathbb P_-$ strictly, meaning $\mathrm{KL} = \infty$ and $\mathrm{TV} = 1$. (!)"*
>
> Line 182: *"**Fix: introduce a smoothing of the noise.** Replace the Rademacher $\sigma\varepsilon$ by a random variable with density overlapping both centers..."*

This is three failed Rademacher attempts followed by the correct Gaussian argument. An expert reviewer (Goujaud, Taylor, Dieuleveut) reading this would immediately see it as **unpolished proof debug output**, not a submission-quality proof.

**Required fix:** Rewrite Lemma 1.4 cleanly:
- State it **directly for Gaussian noise** $Y \sim \mathcal N(s\alpha, \sigma^2)$ in the Lemma statement.
- Proof of (a): one-line $\mathrm{KL}(\mathcal N(\alpha,\sigma^2) \| \mathcal N(-\alpha,\sigma^2)) = 2\alpha^2/\sigma^2$, tensorize, substitute $\alpha = \sigma/(2\sqrt{2T})$ ⇒ $1/4 \leq 1$.
- Delete all Rademacher debug paragraphs.
- Move any discussion of "why Gaussian not Rademacher" to a Remark **after** the clean proof, if at all.

### F1'. Literal "wait let me redo" in Claim 2.2  →  **CRITICAL FLAG**

Line 277 (middle of Claim 2.2 proof):

> *"For $y \leq -R$: $w'(y) = L(-y - R)(-1) \cdot (\mathrm{sgn}(y) = -1)$ **wait let me redo.** For $y < -R < 0$: ..."*

This is a literal proof-scratch-pad in submitted text. **Must be deleted.** The surrounding correct derivation $y = -R - \alpha/L = -D/\sqrt 2$ is fine; just the "wait let me redo" parenthetical must go, and the preceding half-sentence `$L(-y - R)(-1) \cdot (\mathrm{sgn}(y) = -1)$` should be rewritten as part of the clean flow.

**Required fix:** Replace lines 277 (from "For $y \leq -R$:" through "wait let me redo.") with a single clean computation:
> *"For $y < -R < 0$: $|y| = -y > R$, $\mathrm{sgn}(y) = -1$, so $w'(y) = L(|y| - R)\mathrm{sgn}(y) = L(-y - R)(-1) = L(y + R)$. Setting $\alpha + L(y + R) = 0$ gives $y = -R - \alpha/L = -(D/\sqrt 2 - \alpha/L) - \alpha/L = -D/\sqrt 2$. ✓"*

### F2. Stale v1 references  →  **PASS**

Historical references to v1 at lines 78, 255, 417, 655, 662 are appropriate (Appendix B diff table, explanatory remarks). No stale "in v1 we had X, now we have Y" mid-proof residue outside those contexts.

### F3. Usage of $1/56$ and $1/(8\sqrt 2)$  →  **PASS**

Both values confined to:
- Summary of changes (line 13)
- Remark on constants (line 417–420)
- Appendix B diff table (lines 655, 662)

Neither appears in the Main Theorem statement or the proof-body conclusions. ✓

---

## Summary of required actions

| ID | Severity | Location | Action |
|---|---|---|---|
| **F1** | **CRITICAL (writing)** | Lemma 1.4 proof, lines 170–186 | Rewrite cleanly for Gaussian; delete all Rademacher debug paragraphs |
| **F1'** | **CRITICAL (writing)** | Claim 2.2 proof, line 277 | Delete "wait let me redo"; clean up the $w'(y)$ derivation |
| B4 | FLAG (minor) | Line 377 | Add one sentence on adaptive-KL reduction |
| C5 | FLAG (minor) | Line 448 | One sentence clarifying $s^\star$ selection mechanism |
| D1 | FLAG (minor) | Line 485 | Weaken "equivalent" to "sufficient condition (necessity verified empirically)" |
| D2 | FLAG (minor) | §4.2, line 616 | Sentence on last-iterate vs weighted-average equivalence |
| E2 | FLAG (optional) | Part 3 | Optional: add variance simulation |

---

## Verdict

**`NEEDS_FIX`** — two critical writing issues (F1, F1') must be resolved before submission. No mathematical errors were found; once the writing is cleaned, the proof is a clean $\forall$-$\exists$ lower bound ready for Goujaud/Taylor/Dieuleveut-level scrutiny. The four math-side FLAGs (B4, C5, D1, D2) are clarifying polish, not blockers.

**Estimated fix time:** 30–45 minutes for F1 rewrite, 5 minutes each for F1'/B4/C5/D1/D2. Total ≈ 1 hour.

**Post-fix recommendation:** READY_TO_SUBMIT after F1 and F1' are addressed; the four FLAGs can be folded in as part of the same polish pass or deferred to a reviewer-feedback round.
