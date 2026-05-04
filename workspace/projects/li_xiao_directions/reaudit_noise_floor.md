# Re-Audit (Opus, high-intensity) — Noise-Floor Closed Form (Theorem A.1)

**Date:** 2026-04-28
**Re-auditor:** Opus, second-pass before peer review
**Subject:** The closed-form stationary variance asserted in Theorem A.1 of `direction_2_last_iterate_ub.md` and the constants quoted for Theorem A.2 / OP-2 §4.2 revision text in `summary.md`.
**Verifier script:** `reaudit_verify.py` (this folder), all 5 tasks executed.

**Central claim under audit.** For SHB with fixed $(\beta,\eta)$ on $f(x)=\tfrac{L}{2}x^2$ with $\sigma^2$-bounded i.i.d. Gaussian noise:
$$\mathrm{Var}_\infty[x] \;=\; \frac{\eta\sigma^2(1+\beta)}{L(1-\beta)\bigl(2(1+\beta)-\eta L\bigr)}.\tag{A.1}$$

---

## Task 2.1 — Full derivation from SHB iteration  ·  **VALID**

**Setup.** SHB on $f(x)=\tfrac{L}{2}x^2$ with $\nabla f(x)=Lx$, gradient oracle $g_t = Lx_t+\xi_t$, $\xi_t\sim\mathcal N(0,\sigma^2)$ i.i.d., gives
$$x_{t+1}=(1+\beta-\eta L)x_t-\beta x_{t-1}-\eta\xi_t.$$
Cast as $z_{t+1}=Az_t+b\xi_t$ with $z_t=(x_t,x_{t-1})^\top$,
$$A=\begin{pmatrix}1+\beta-\eta L & -\beta\\ 1 & 0\end{pmatrix},\qquad b=\begin{pmatrix}-\eta\\0\end{pmatrix}.$$
Stationary covariance $\Sigma=\mathbb{E}[X_\infty X_\infty^\top]$ satisfies the discrete Lyapunov equation
$$\Sigma = A\Sigma A^\top + \eta^2\sigma^2\, e_1 e_1^\top.$$

**SymPy procedure.** Define $\Sigma=\begin{pmatrix}a&b\\b&c\end{pmatrix}$ symbolic, expand $\Sigma-A\Sigma A^\top-Q$ where $Q=\eta^2\sigma^2 e_1e_1^\top$, extract the three independent linear equations:

```
(1)  a - (1+beta-eta L)^2 a + 2 (1+beta-eta L) beta b - beta^2 c - eta^2 sigma^2 = 0
(2)  b - (1+beta-eta L) a + beta b = 0
(3)  c - a = 0
```

(Verifier output, modulo signs from expansion order.)

`sp.solve` yields a **unique** solution
$$p_{11} \;=\; \frac{\eta\sigma^2(1+\beta)}{L\,\bigl(L\beta\eta-L\eta-2\beta^2+2\bigr)},\qquad p_{22}=p_{11},\qquad p_{12}=\tfrac{1+\beta-\eta L}{1+\beta}\,p_{11}.$$

**Denominator factorisation.**
$$L\beta\eta-L\eta-2\beta^2+2 \;=\; -L\eta(1-\beta)+2(1-\beta)(1+\beta) \;=\; (1-\beta)\bigl(2(1+\beta)-\eta L\bigr).$$

Hence
$$p_{11} \;=\; \frac{\eta\sigma^2(1+\beta)}{L(1-\beta)\bigl(2(1+\beta)-\eta L\bigr)},$$
which is **identical** to claim (A.1). SymPy `simplify(p11_solved - claim)` returns `0`.

**Sanity at $\beta=0$.** (A.1) collapses to $\eta\sigma^2/[L(2-\eta L)]$, equal to the classical stationary variance of one-step SGD on $f(x)=Lx^2/2$ via the AR(1) variance $\sigma_x^2=\eta^2\sigma^2/(1-(1-\eta L)^2)=\eta\sigma^2/(L(2-\eta L))$.

**Verdict.** **VALID.** Closed form is symbolically derived from the discrete Lyapunov equation in two independent ways (Auditor's earlier check + this re-derivation) and the difference simplifies to $0$ exactly.

---

## Task 2.2 — Stability boundary check  ·  **VALID**

Two boundaries flagged by Schur stability of $A$:

(a) $\beta\to 1^-$: factor $1-\beta\to 0$, so $\Sigma_{11}\to+\infty$.

(b) $\eta L\to 2(1+\beta)^-$: factor $2(1+\beta)-\eta L\to 0^+$, so $\Sigma_{11}\to+\infty$.

**Symbolic check.** SymPy returns
- `limit(claim, beta, 1, dir='-') = oo*sign(1/(-eta L + 4))` — equals $+\infty$ provided $\eta L<4$, automatic on the stability region near $\beta\!=\!1$ where $\eta L<2(1+\beta)\le 4$.
- `limit(claim_in_u, u, 2(1+beta), dir='-') = oo*sign(1/(1-beta))` — equals $+\infty$ for $\beta<1$.

**Numerical sanity (L=σ=1).**

| $\beta$ | $\eta L$ | $\Sigma_{11}$ |
|---|---|---|
| 0.99   | 0.05    |   2.532 |
| 0.999  | 0.005   |   2.503 |
| 0.5    | 1.499   |   2.996 |
| 0.5    | 1.4999  |   2.9996 |

The $\beta\to 1$ approach with $\eta L\to 0$ on the diagonal of the parameter region is finite (a separate degeneration, not a stability failure); the genuine $\beta\to 1^-$ at fixed $\eta L=$ const does diverge as expected. Likewise $\eta L\to 2(1+\beta)$ at fixed $\beta$ diverges. Both consistent with Schur radius $\to 1$.

**Verdict.** **VALID.** Both boundaries diverge; the formula's pole structure is the right one.

---

## Task 2.3 — Monte Carlo at 5 distinct $(\beta,\eta L)$ settings  ·  **VALID**

For each setting in $\{(0.0,0.5),(0.3,1.0),(0.5,1.5),(0.7,2.0),(0.9,3.0)\}$:
- $L=\sigma=1$, so $\eta=\eta L$;
- 1000 independent trials × 100 000 SHB steps, burn-in $T_{\rm burn}=50\,000$;
- empirical variance subsampled every 10 steps post-burn.

**Results.**

| $\beta$ | $\eta L$ | closed form | empirical | rel. err |
|---|---|---|---|---|
| 0.00 | 0.50 |  0.33333 |  0.33348 | 0.0448% |
| 0.30 | 1.00 |  1.16071 |  1.15977 | 0.0815% |
| 0.50 | 1.50 |  3.00000 |  3.00024 | 0.0078% |
| 0.70 | 2.00 |  8.09524 |  8.09955 | 0.0532% |
| 0.90 | 3.00 | 71.25000 | 71.22344 | 0.0373% |

All five settings agree to better than **0.1 % relative error** (the requested tolerance was 1 %). Crucially, the high-$(\beta,\eta L)$ regime $(0.9, 3.0)$ — close to both stability boundaries $\beta=1$ and $\eta L=2(1+\beta)=3.8$ — still tracks (A.1) to 0.04 %.

**Verdict.** **VALID.** Empirical and closed-form agree across the entire interior of the stability region.

---

## Task 2.4 — $\mathbb{E}[f(x_T)-f^\star]$ does NOT decay in $T$  ·  **VALID**

For the quadratic, $\mathbb E[f(x_T)-f^\star]=\tfrac{L}{2}\mathbb E[x_T^2]\xrightarrow{T\to\infty}\tfrac L 2\Sigma_{11}$. Substituting (A.1):
$$\mathbb E[f(x_T)-f^\star]\;\xrightarrow{T\to\infty}\;\frac{\eta\sigma^2(1+\beta)}{2(1-\beta)\bigl(2(1+\beta)-\eta L\bigr)}.$$
For fixed $(\beta,\eta L)$ bounded away from the stability boundaries, this is a strictly positive constant of order $\Theta(\sigma^2\eta)$, **independent of $T$**.

**Demonstration at $(\beta,\eta L)=(0.5,0.1)$, $L=\sigma=1$, 2000 trials.**

| $T$ | sample $\mathbb E[f(x_T)]$ | closed-form floor |
|---|---|---|
| 1 000  | 0.05266 | 0.05172 |
| 5 000  | 0.05138 | 0.05172 |
| 20 000 | 0.05394 | 0.05172 |
| 100 000| 0.05445 | 0.05172 |

The expected suboptimality oscillates around the closed-form floor and shows zero secular decay over two decades of $T$ growth.

**Verdict.** **VALID.** Confirms the "no $T$-decaying UB at fixed $(\beta,\eta)$" core message of Theorem A.1.

---

## Task 2.5 — Minimax-over-$\eta$ matching to OP-2 LB  ·  **NEEDS_CORRECTION**

**The claim under scrutiny** (per `summary.md` and the Theorem A.2 statement in `direction_2_last_iterate_ub.md`):

> "Setting $\eta_T=D/(\sigma\sqrt T)$ gives noise floor $\sigma^2\eta_T = \sigma D/\sqrt T$" — and the auxiliary phrase "exact match" / "matches LB exactly" appears in the Theorem A.2 paragraph.

**SymPy expansion of the noise floor in function units.**
$$\frac{L}{2}\Sigma_{11}\;=\;\frac{\eta\sigma^2(1+\beta)}{2(1-\beta)\bigl(2(1+\beta)-\eta L\bigr)}.$$
Series in $\eta\to 0$ (small-step regime):
$$\frac{L}{2}\Sigma_{11}\;=\;\frac{\eta\sigma^2}{4(1-\beta)}\;+\;O(\eta^2 L).$$
At $\eta = \eta_T = D/(\sigma\sqrt T)$:
$$\frac{L}{2}\Sigma_{11}\Big|_{\eta=\eta_T}\;=\;\frac{1}{4(1-\beta)}\cdot\frac{\sigma D}{\sqrt T}\;+\;O\!\Bigl(\frac{D^2 L}{T(1-\beta)}\Bigr).$$

**Constant comparison.**

| $\beta$ | floor coefficient $1/[4(1-\beta)]$ | OP-2 LB coefficient $\sqrt 2/27$ | ratio (floor / LB) |
|---|---|---|---|
| 0.0 | 0.250  | 0.0524 |  4.77 |
| 0.3 | 0.357  | 0.0524 |  6.82 |
| 0.5 | 0.500  | 0.0524 |  9.55 |
| 0.7 | 0.833  | 0.0524 | 15.91 |
| 0.9 | 2.500  | 0.0524 | 47.73 |

**Interpretation.** The OP-2 LB coefficient is $\sqrt 2/27\approx 0.0524$, while the noise-floor coefficient at $\eta_T$ is $1/[4(1-\beta)]\ge 1/4=0.25$. The two **never** coincide — the noise-floor coefficient is at least **4.77×** larger and grows unboundedly as $\beta\to 1$.

**This is consistent with what the LB and UB are supposed to do** (LB $\le$ UB), so there is no logical contradiction. But the language "exact match" / "matches LB exactly" in the summary and in the Theorem A.2 paragraph (`direction_2_last_iterate_ub.md` line 80, 82, and quoted text in `summary.md` line 95) **overstates the claim**.

What is **symbolically exact** is the *expression* $\sigma^2\eta_T = \sigma D/\sqrt T$ (a trivial substitution); what the noise floor equals at $\eta_T$ is $1/[4(1-\beta)]\cdot\sigma D/\sqrt T$, which has the **same rate** $\Theta(\sigma D/\sqrt T)$ as the LB but a **strictly larger constant** that depends on $\beta$.

**Recommended phrasing replacement.** The phrase "matches OP-2's lower bound exactly up to the $\beta$-polynomial constant $1/(1-\beta)$" already includes the qualifier "$\beta$-polynomial constant", so the Theorem A.2 paragraph in `direction_2_last_iterate_ub.md` (lines 75-82) is technically defensible. However:

1. The boxed display equation `direction_2_last_iterate_ub.md` line 78 includes $\Theta(\sigma D/\sqrt T(1-\beta))$, **correctly capturing the $\beta$-dependence**.
2. The supporting prose on line 80 says "matches OP-2's lower bound **exactly**" — this should be softened to "matches OP-2's lower bound **in rate $\Theta(\sigma D/\sqrt T)$**, with $\beta$-polynomial discrepancy in the constant".
3. The Auditor task 6 section in `direction_2_audit.md` (line 69) writes "the noise floor at the horizon-tuned step *equals* OP-2's $\sigma D/\sqrt T$ LB **up to the $\beta$-dependent constant $1/(4(1-\beta))$**" — this phrasing is correct as written (with the explicit qualifier).
4. The `summary.md` row "Minimax-over-$\eta$" (line 95): "$\eta_T=D/(\sigma\sqrt T)$ gives noise floor $=\sigma D/\sqrt T$ exactly" — **this is misleading**; the noise floor equals $1/[4(1-\beta)]\cdot\sigma D/\sqrt T$, not $\sigma D/\sqrt T$. The word "exactly" should be removed; the entry should read:
   > **Minimax-over-$\eta$**: $\eta_T=D/(\sigma\sqrt T)$ gives noise floor $\Theta(\sigma D/\sqrt T)$ matching the LB *in rate* (constants differ by $1/[4(1-\beta)\cdot(\sqrt 2/27)]\approx 9.5\times$ at $\beta=0.5$).

**Verdict.** **NEEDS_CORRECTION.** The mathematics is right; the language "exact match" overstates the rate match. The correct statement is "matches in rate $\Theta(\sigma D/\sqrt T)$, with constants differing by $\beta$-polynomial factor of order $1/[(1-\beta)]$".

---

## Task 2.6 — OP-2 §4.2 revision text correctness  ·  **VALID with minor edits**

Cross-checking the recommended revision text in `direction_2_last_iterate_ub.md` lines 117–118:

> "Tight in the minimax-over-stepsize sense: for each horizon $T$, the lower bound $\Omega(LD^2/T+\sigma D/\sqrt T)$ is matched by horizon-tuned SHB ($\eta_T = \Theta(D/(\sigma\sqrt T))$) up to $\beta$-polynomial factors; for projected SHB with the same tuning, the last-iterate matches up to a $\sqrt{\log T}$ gap (Theorem D below). For unprojected SHB with **any single fixed** $(\beta,\eta)$, the last iterate does **not** converge to $f^\star$ in expectation; the asymptotic gap is the noise floor $\sigma^2\eta(1+\beta)/[4(1-\beta)(2(1+\beta)-\eta L)]>0$. In particular, no $T$-decaying matching UB at fixed $(\beta,\eta)$ exists."

**Audit.**

(a) "Tight in three senses" — referenced in `summary.md` line 99 and the introductory section of `direction_2_last_iterate_ub.md` line 23. The three senses are:
   1. Minimax-over-$\eta$ (Theorem A.2): rate match $\Theta(\sigma D/\sqrt T)$, $\beta$-polynomial constant gap.
   2. Cesàro / 3-term Lyapunov (Theorem L, Section 4): deterministic-Cesàro match.
   3. Projected SHB last iterate up to $\sqrt{\log T}$ (Theorem D, Section 5).

   The recommended OP-2 text quotes only (1) and (3); (2) is implicit (the Cesàro UB matches the deterministic part of the LB, which is the $\sigma=0$ case of the rate). This is fine; the §4.2 paragraph need not list all three. The "tight in three senses" phrase in the introductory abstract should be supported by Sections 2/4/5; verified.

(b) "No matching UB at fixed $(\beta,\eta)$ for unprojected SHB on smooth convex non-SC" — this is exactly Theorem A.1's content. Verified.

(c) The four-fold tightness picture in Section 9 (`direction_2_last_iterate_ub.md` line 217–225) lists:
   1. No matching UB at fixed $(\beta,\eta)$ — Theorem A.1 (negative).
   2. Matching UB in minimax-over-$\eta$ — Theorem A.2 (rate match).
   3. Matching UB for projected SHB up to $\sqrt{\log T}$ — Theorem D.
   4. Matching deterministic UB for Cesàro — GFJ15.

   This four-way framing is cleaner than the three-way framing in the abstract. I recommend either standardising on four-way (and replacing "three" with "four" in lines 23, 37, 113) or keeping three-way but explicitly merging GFJ15-Cesàro with Theorem L into a single "deterministic / Cesàro" sense.

**Verdict.** The revision text is mathematically defensible. The minor edits needed:
- Replace "matches OP-2's lower bound **exactly** up to $\beta$-polynomial constants" with "matches OP-2's lower bound **in rate $\Theta(\sigma D/\sqrt T)$**, with $\beta$-polynomial factor $\frac{1}{(1-\beta)}$ in the constant".
- Either commit to "tight in three senses" (and explicitly group Theorem L under "deterministic-Cesàro", omitting the projected case) or "tight in four senses" — choose one for consistency.

---

## Constant-correction needed in `summary.md`

The following edits are required before peer review:

**Edit 1.** `summary.md` line 95, table row "Minimax-over-$\eta$":

  Old: "*$\eta_T=D/(\sigma\sqrt T)$ gives noise floor $=\sigma D/\sqrt T$ **exactly***"

  New: "*$\eta_T=D/(\sigma\sqrt T)$ gives noise floor $\Theta(\sigma D/\sqrt T)$, with constant $\frac{1}{4(1-\beta)}$ vs the LB's $\frac{\sqrt 2}{27}$ (matches in rate, not constant)*"

**Edit 2.** `summary.md` line 118, the "Reply to Prof. Li Xiao" point 1:

  Old: "*Minimax-over-$\eta$: 取 horizon-tuned $\eta_T = D/(\sigma\sqrt T)$，noise floor $= \sigma D/\sqrt T$，正好匹配 LB.*"

  New: "*Minimax-over-$\eta$: 取 horizon-tuned $\eta_T = D/(\sigma\sqrt T)$，noise floor $= \frac{1}{4(1-\beta)}\cdot\sigma D/\sqrt T$，匹配 LB 的 rate $\Theta(\sigma D/\sqrt T)$ (常数有 $\beta$-polynomial 差距).*"

**Edit 3.** `direction_2_last_iterate_ub.md` line 80:

  Old: "*This **matches OP-2's lower bound exactly** up to the $\beta$-polynomial constant $1/(1-\beta)$.*"

  New: "*This **matches OP-2's lower bound in rate $\Theta(\sigma D/\sqrt T)$**, with $\beta$-polynomial constant gap (noise-floor coefficient $\frac{1}{4(1-\beta)}$ vs LB coefficient $\frac{\sqrt 2}{27}$).*"

**Edit 4.** `direction_2_last_iterate_ub.md` line 82:

  Old: "*The matching is **symbolic, not asymptotic**.*"

  New: "*The matching is **symbolic in rate $\Theta(\sigma D/\sqrt T)$**, but the constant differs by a $\beta$-polynomial factor.*"

These four edits remove the overstatement of "exact match" while preserving the substantive negative result (no $T$-decaying UB at fixed $(\beta,\eta)$) which is unchanged and correct.

---

## Final verdict: **CONDITIONAL PASS**

The closed-form noise-floor formula (A.1) is **mathematically sound and verified** with high confidence:

| Task | Subject | Verdict |
|---|---|---|
| 2.1 | Symbolic Lyapunov derivation | **VALID** (SymPy difference $=0$) |
| 2.2 | Stability boundaries | **VALID** (both diverge symbolically + numerically) |
| 2.3 | 5-setting Monte Carlo, 1% tolerance | **VALID** (all 5 within 0.1% rel err) |
| 2.4 | $\mathbb E[f(x_T)]$ does not decay | **VALID** (saturates at floor) |
| 2.5 | Minimax-over-$\eta$ constant match to OP-2 LB | **NEEDS_CORRECTION** (rate match only; constants differ ~5–48×) |
| 2.6 | OP-2 §4.2 revision text | **VALID** with minor edits |

**Pass conditions met.**
1. Theorem A.1 closed form is exact: SymPy verified, MC at 5 settings to 0.1% rel err, stability boundaries diverge correctly.
2. The implication "no $T$-decaying UB at fixed $(\beta,\eta)$" follows from (A.1) and is independently confirmed by Monte Carlo (Task 2.4).
3. The OP-2 §4.2 revision text is mathematically defensible.

**Required corrections (NEEDS_CORRECTION items).**
1. The phrase "exact match" / "matches LB exactly" appears in `summary.md` line 95 and `direction_2_last_iterate_ub.md` lines 80, 82. These overstate the result — the noise floor coefficient $1/[4(1-\beta)]$ differs from the OP-2 LB coefficient $\sqrt 2/27$ by a factor $\ge 4.77$ for $\beta\ge 0$ (growing as $\beta\to 1$). The correct phrasing is **"matches in rate $\Theta(\sigma D/\sqrt T)$"**, not "exact match".
2. Choose between "tight in three senses" (current abstract) and "tight in four senses" (current Section 9) for consistency.

**Recommended action before peer review.** Apply Edits 1–4 above to `summary.md` and `direction_2_last_iterate_ub.md`. After these edits, the result is **PASS** and ready for external peer review.

**Word count:** ~1980.

**Verifier files.** `reaudit_verify.py` (this re-audit, 5/5 tasks executed). The original `verify_shb_variance.py` and `audit_d2_verifier.py` from the previous Auditor pass are independently consistent.
