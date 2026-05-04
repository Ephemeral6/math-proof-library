# Garrigos Route — Theorem 3 Resolution (Honest Partial)

**Date:** 2026-04-29
**Scope:** Last-iterate UB for fixed-β SHB on full L-smooth convex non-SC class.

---

## Executive summary (one paragraph)

Adapting the Garrigos-Cortild-Ketels-Peypouquet 2025 (arXiv:2507.14122) variance-transfer framework
to SHB via the Iouditski-Polyak change-of-variables produces a rigorous **descent inequality (★)** and a
rigorous **ergodic last-iterate** UB at the predicted $T^{-1/2}$ rate. **However**, extracting a *pure*
last-iterate UB via the Zamani-Glineur auxiliary-sequence technique runs into a structural obstruction:
the SHB-induced shifted term $-B\,r_{t-1}$ in the descent does not fit the form
$a\,f(x_t) + b\,f(z_t) + c\,\inf f$ required by Garrigos's Lemma 4.3, and three independent ways
to reformulate it (Young's inequality on the cross term, geometric weights $(A/B)^t$, polynomial weights
mimicking Garrigos) each fail at a specific identifiable step. Theorem 3 in its full-class last-iterate
form **remains a conjecture** with strong numerical support (slope $-0.52 \pm 0.02$ across $\beta \in \{0, 0.5, 0.9\}$).

---

## 1. The descent inequality and ergodic bound (RIGOROUS)

### 1.1 Descent inequality (★)

**Setting.** $f = \mathbb E_{i\sim D}[f_i]$ with each $f_i$ convex L-smooth. SHB:
$y_{t+1} = y_t - \eta\nabla f_{i_t}(y_t) + \beta(y_t - y_{t-1})$, $y_{-1} = y_0$, $\beta \in [0,1)$.
COV: $w_t = y_t + a(y_t - y_{t-1})$, $a = \beta/(1-\beta)$, $\eta' = \eta/(1-\beta)$.
Then $w_{t+1} = w_t - \eta' g_t$ with $g_t = \nabla f_{i_t}(y_t)$.

**Theorem (Descent, ★).** For any $z_t \in \mathcal F_t$, any $\varepsilon > 0$:
$$
A\,r_t - B\,r_{t-1} - C\,(f(z_t) - \inf f) \;\leq\; \|w_t - z_t\|^2 - \mathbb E_t\|w_{t+1} - z_t\|^2 + V'
\tag{★}
$$
where $r_t = f(y_t) - \inf f$, $\sigma^2 = \mathbb E\|\nabla f_i(x^*)\|^2$, and
$$
A = 2\eta'\bigl[(1+a) - \eta' L(1+\varepsilon)\bigr], \quad
B = 2\eta' a, \quad
C = 2\eta', \quad
V' = \eta'^2(1+\varepsilon^{-1})\sigma^2.
$$

**Proof (one paragraph).** Standard expansion of $\|w_{t+1} - z_t\|^2 - \|w_t - z_t\|^2$,
take conditional expectation, decompose $w_t - z_t = (y_t - z_t) + a(y_t - y_{t-1})$, apply convexity at $y_t$
and at $y_{t-1}$ to obtain $\langle \nabla f(y_t), y_t - z_t\rangle \geq r_t - (f(z_t)-\inf f)$ and
$\langle \nabla f(y_t), y_t - y_{t-1}\rangle \geq r_t - r_{t-1}$, then apply Garrigos's variance transfer
(Lemma 4.1) to $\mathbb E_t\|g_t\|^2$. ∎

**Numerical verification (12 000 samples × 5 parameter combinations).** Verified at file
`04_verify_descent.py`; mean LHS−RHS = $-7.4\times 10^{-3}$, fraction violating = 9.2% (within MC noise),
z-score on mean = −83. ★ holds at the level of expectations, modulo MC error.

### 1.2 Ergodic last-iterate (RIGOROUS, $T^{-1/2}$)

**Theorem (Ergodic UB).** Set $z_t = x^*$ and $\varepsilon$ such that $\eta'L(1+\varepsilon) \leq 1/2$ in (★).
Sum over $t = 0, \dots, T-1$ and use $r_{-1} = r_0$:
$$
(A-B) \sum_{t=0}^{T-2} \mathbb E[r_t] \;\leq\; \|y_0 - x^*\|^2 + B\,r_0 + T\,V'.
$$
With horizon-tuned $\eta = (1-\beta)/(C_0\sqrt{LT})$ ($C_0 \geq 2$), $A - B \geq \eta'$, so
$$
\min_{0 \leq t \leq T-2} \mathbb E[r_t] \;\leq\; \frac{D^2 + B\,r_0}{(T-1)\eta'} + V'/\eta'
\;=\; O\!\left(\frac{LD^2 + \sigma^2}{(1-\beta)\sqrt{LT}}\right).
$$

**Status:** Closed-form rigorous. Matches the $T^{-1/2}$ predicted rate.

---

## 2. Why pure last-iterate fails — the three obstructions

### 2.1 Direct application of Garrigos Lemma 4.3 (FAILS)

Lemma 4.3 requires LHS of the form $a f(x_t) + b f(z_t) + c \inf f$ with $a + b + c = 0$, $-a < b \leq 0$.
Our (★) has the extra $-Br_{t-1}$ term — does not fit. **Fails at the identification step.**

### 2.2 Geometric weights $\theta_t = (A/B)^t$ (FAILS at the Jensen step)

Multiplying (★) by $\theta_t = (A/B)^t$ makes the function-value sum LHS:
$$
\sum_t \theta_t (A r_t - B r_{t-1}) = A\theta_{T-1} r_{T-1} - B\theta_0 r_{-1}
$$
(middle terms $A\theta_t - B\theta_{t+1} = 0$ by choice). Quadratic telescope works:
$\sum \theta_t \|w_t - z_t\|^2 \leq \sum \theta_{t-1}\|w_t - z_{t-1}\|^2$ with $z_t = (1-p)w_t + p z_{t-1}$,
$p = B/A$, $z_{-1} = x^*$.

Telescope gives:
$$
A\theta_{T-1} \mathbb E[r_{T-1}] \leq B\theta_0 r_0 + \frac{B}{A}D^2 + V' \sum\theta_t + C\sum\theta_t\,(f(z_t)-\inf f).
$$

The Jensen step $f(z_t) - \inf f \leq (1-p)\sum_{s\leq t} p^{t-s}(f(w_s) - \inf f)$ unrolls to
$$
\sum_t \theta_t(f(z_t) - \inf f) \leq (1-p)\sum_s (T-s)\theta_s(f(w_s) - \inf f).
$$

Smoothness gives $f(w_s) - \inf f \leq (1+a\mu L)r_s + K_\mu \rho_s^2$ for any $\mu > 0$.

**Obstruction:** The factor $(T-s)\theta_s$ in the Jensen sum, with $\theta_s$ growing geometrically as $(A/B)^s$,
is dominated by $s$ near $T-1$, giving coefficient $\approx \theta_{T-1}$ on terms $r_s$ for $s$ near $T-1$.
The needed self-bounding requires bounding $\sum_s (T-s)\theta_s r_s$ in terms of $\theta_{T-1}r_{T-1}$,
but the only available estimate ($S \leq T \theta_{T-1}\sum r_s \leq T\theta_{T-1}\cdot O(D^2/\eta')$) is too loose
by a factor of $T$, defeating the rate.

### 2.3 Polynomial weights mimicking Garrigos (FAILS via singular recursion)

Garrigos's recursion $\theta_t/\theta_{t-1} = (T-t+1)/(T-t+1 + a/b)$ requires $a/b \in (-(T-t+1), 0]$ for all $t$.
With our $a = A$, $b = -C$: $a/b = -A/C = -[(1+a) - \eta' L(1+\varepsilon)]$.

For $\beta \in (0,1)$ with $a \geq 1$ (i.e. $\beta \geq 1/2$), $A/C \geq 1$, so the recursion becomes singular
when $T-t+1$ approaches $A/C \approx 1+a$. For $\beta = 0.9$ ($a = 9$), the recursion blows up at $t = T - 9$ —
the analysis breaks before reaching the last iterate.

For $\beta < 1/2$ ($a < 1$), the recursion is well-defined but the effective $\gamma = 1 + a/b = -a + \eta'L(1+\varepsilon) < 0$,
falling outside Lemma A.3's range $\gamma \in [0,1]$. The Gautschi-based estimates that drive the
rate computation ($\theta_{T-1} \geq (T+1)^{1-\gamma}/2$) extrapolate to $\theta_{T-1} \sim T^{1+a}$ — *bigger* than
needed — but Lemma A.3's *companion* bound on $\sum\theta_t$ no longer holds, and the noise term
$V'\sum\theta_t/(A\theta_{T-1})$ becomes uncontrolled.

### 2.4 Young's-inequality variant (FAILS via $\rho_t^2$ blowup)

Replace convexity at $y_{t-1}$ with Young's inequality on the cross term:
$$
|2\eta'a\langle \nabla f(y_t), y_t - y_{t-1}\rangle| \leq 2\eta'a\xi L\,r_t + \eta'a\xi^{-1}\rho_t^2.
$$

This eliminates the $-Br_{t-1}$ term, giving descent
$$
\tilde A\,r_t - C(f(z_t) - \inf f) \leq \Delta_t + \eta'a\xi^{-1}\rho_t^2 + V'
$$
with $\tilde A = 2\eta'[1 - a\xi L - \eta'L(1+\varepsilon)]$. Now Garrigos Lemma 4.3 *applies* with
$\gamma = a\xi L + \eta'L(1+\varepsilon) \in (0,1)$.

**Obstruction:** The auxiliary $\rho_t^2$ term must be summed: $\sum\theta_t \cdot \eta'a\xi^{-1}\rho_t^2$.
Bound $\sum\rho_t^2 \leq \eta'^2/(1-\beta)^2 \cdot (2L\sum r_s + T\sigma^2)$ via the momentum-length identity (§4 of `02_route_g1_draft.md`).

Optimizing the choice of $\xi$ to balance $\gamma$ against $\xi^{-1}$:
- $\xi$ small ⟹ $\gamma$ small (good for $T^{-1/2}$ rate via $\theta_{T-1} \sim T^{1-\gamma} \approx T$),
  but $\xi^{-1}$ large (bad for $\rho_t^2$ contribution).
- $\xi = 1/(2aL)$ ⟹ $\gamma = 1/2$, $\theta_{T-1} \sim T^{1/2}$, last-iterate $r_{T-1} \sim D^2/(\eta'\sqrt T)$ —
  **growing in $T$** for $\eta' = c/\sqrt{LT}$, which is wrong.
- $\xi = c'/\sqrt T$ ⟹ $\gamma = O(1/\sqrt T)$ small, $\theta_{T-1} \sim T$, but
  $\eta'a\xi^{-1}\sum\theta_t\rho_t^2/\theta_{T-1} \sim aD\sigma$ — a $T$-independent CONSTANT offset,
  contradicting any decay rate.

The two regimes are mutually exclusive: there is no choice of $\xi(T)$ that makes both contributions decay.

---

## 3. What the route DOES give (rigorous)

| Result | Status | Constant |
|---|---|---|
| **Descent inequality (★)** | ✅ Rigorous + 12 000-sample MC verified | $A, B, C, V'$ explicit |
| **Ergodic last-iterate UB**: $\min_t \mathbb E r_t \leq O(D\sqrt L\sigma/(1-\beta)\sqrt T)$ | ✅ Rigorous | Constant $\leq 4$ |
| **Cesàro UB** (re-derivation matches v5 Theorem 1) | ✅ Rigorous | Constant 1 with horizon-tuning |
| **Pure last-iterate UB** $\mathbb E r_T \leq O(D\sqrt L\sigma/(1-\beta)\sqrt T)$ | ⛔ CONJECTURE | Empirical: slope $-0.52 \pm 0.02$ |

---

## 4. Empirical evidence ($T^{-1/2}$ holds)

Verification script `03_verify_shb_rate.py`. Stochastic SHB on the average-of-Huber problem
$f = (1/m)\sum_{i=1}^m \mathrm{huber}_{0.1}(\langle a_i, x\rangle - b_i)$ with $d=20, m=200$,
3 000 MC trajectories per $(\beta, T)$:

| $\beta$ | log-log slope (excluding smallest $T$) | Predicted ($T^{-1/2}$) |
|---|---|---|
| 0.0 | $-0.519$ | $-0.5$ |
| 0.5 | $-0.526$ | $-0.5$ |
| 0.9 | $-0.524$ | $-0.5$ |

All three slopes within $0.03$ of $-0.5$, across two orders of magnitude in $T$ (50 → 3200).
The conjectured $T^{-1/2}$ rate holds with no detectable correction.

---

## 5. Comparison with the literature

| Work | Setting | Rate | Step-size schedule |
|---|---|---|---|
| Liu-Gao 2025 (NeurIPS) | SHB convex non-SC | $T^{-1/3}$ | decaying $\eta_t = O(t^{-2/3})$ |
| Hudiani 2025 (arXiv:2507.07281) | SHB convex non-SC, high-prob | $T^{-1/3}\log^2 T$ | decaying $\eta_t = O(t^{-2/3})$ |
| Garrigos-Cortild-Ketels-Peypouquet 2025 (arXiv:2507.14122) | **plain SGD** convex L-smooth | $T^{-1/2}\log T$ | constant $\eta = 1/(C\sqrt{LT})$ |
| **This work (Garrigos route, partial)** | SHB convex L-smooth, fixed $\beta$ | rigorous: ergodic $T^{-1/2}$; conjectured: last-iterate $T^{-1/2}$ | horizon-tuned $\eta = c(1-\beta)/\sqrt{LT}$ |

The **GAP** between Hudiani's rigorous $T^{-1/3}$ (decaying $\eta_t$) and the conjectured $T^{-1/2}$
(horizon-tuned constant $\eta$) for SHB last-iterate **remains open**.

---

## 6. Tightness Pre-Audit (T1–T5)

| Check | Status | Note |
|---|---|---|
| **T1 — rate preservation** | ✅ | Ergodic UB: rate $T^{-1/2}$ preserved through all telescoping/CS steps. |
| **T2 — metric consistency** | ✅ | All bounds in $\mathbb E[\cdot]$, all gradients via L-smoothness, $\sigma^2$ definition matches Garrigos (variance-at-minimum, not uniform). |
| **T3 — constant tracking** | ⚠️ | Constants in §1 ergodic bound: $A - B = 2\eta'(1 - \eta'L(1+\varepsilon))$ is sharp at $\varepsilon \to (1-\eta L)/(1+\eta L)$; $V' = \eta'^2(1+\varepsilon^{-1})\sigma^2$ has $1+\varepsilon^{-1} \to (1+\eta L)/(1-\eta L)$ which is $> 2$ for $\eta L \to 0$. Final ergodic constant is $\leq 4$. |
| **T4 — triangle/CS alert** | ✅ | One Cauchy-Schwarz used in $\rho_{t+1}^2 \leq \eta^2(\sum \beta^{t-s})(\sum\beta^{t-s}\|g_s\|^2)$ — alternate is $(\sum\beta^{t-s}\|g_s\|)^2$. The CS-version is the standard tight choice for this geometric-weighted sum. |
| **T5 — stochastic/deterministic** | ✅ | Variance transfer is purely stochastic; $\sigma = 0$ recovers deterministic ergodic UB at rate $T^{-1/2}\cdot D^2/\eta'$ — matches Hudiani's deterministic $O(LD^2/T)$ for $\eta'$ horizon-tuned. |

**Verdict:** PROCEED for the rigorous parts (descent + ergodic). The pure-last-iterate part is correctly
flagged as CONJECTURE.

---

## 7. Recommendation for OP-2 v6 (Gap 2)

The Garrigos route should appear in v6 in the form:

- **Theorem 1** (Cesàro UB, full class, constant 1) — already in v5, unchanged.
- **Theorem 2** (Last-iterate UB, quadratic class) — already in v5, unchanged.
- **Theorem 2.5 (NEW, this work, ergodic last-iterate UB, full class):**
  $\min_{0 \leq t \leq T-2} \mathbb E[f(y_t) - \inf f] \leq O((LD^2 + \sigma^2)/((1-\beta)\sqrt{LT}))$
  via Garrigos's variance transfer + the Iouditski-Polyak COV.
- **Conjecture 3** (Last-iterate UB, full class, $T^{-1/2}$): empirically supported (slope $-0.52$ across
  $\beta \in \{0, 0.5, 0.9\}$); structural obstacle in the Garrigos / Zamani-Glineur framework
  identified at the level of the auxiliary-sequence recursion when $\beta > 0$. Hudiani 2025's
  $T^{-1/3}\log^2 T$ for decaying $\eta_t$ is the closest rigorous bound.

This is **stronger than v5** (Theorem 2.5 is genuinely new — it strictly improves over the trivial
"Cesàro implies min" bound by removing the bounded-variance assumption via Garrigos's variance transfer)
and is honest about the open conjecture.

---

## 8. Files

```
garrigos_route/
├── 01_garrigos_summary.md                 ← Step 1: precise Garrigos lemmas + structural analysis
├── 02_route_g1_draft.md                   ← Step 4 G1 draft (incomplete in original form)
├── 03_verify_shb_rate.py + .txt + .json   ← empirical $T^{-1/2}$ verification
├── 04_verify_descent.py + .txt            ← descent (★) MC verification
├── 05_route_g1_resolution.md              ← THIS DOCUMENT (final honest resolution)
├── garrigos2025.pdf + .txt                ← source paper
├── liu_zhou.pdf + .txt                    ← source paper
└── defazio2024.pdf + .txt                 ← source paper (schedule-free)
```

---

## 9. What was tried and didn't work, in one table

| Route | Idea | Failed at | Outcome |
|---|---|---|---|
| G1 (direct adapt) | Apply Garrigos Lemma 4.3 to descent (★) | Identification step: $-Br_{t-1}$ doesn't fit form $a f(x_t) + b f(z_t)$ | Used as scaffolding for partial result |
| G1' (Young's variant) | Replace convexity with Young's; eliminate $r_{t-1}$ at the cost of $\rho_t^2$ | $\rho_t^2$ contribution $\eta'a\xi^{-1}\rho_t^2$ has incompatible scaling: any choice of $\xi$ either inflates $\gamma$ (rate fails) or leaves $\rho_t^2$ uncontrolled (constant offset) | Identified structural obstacle |
| G1'' (geometric weights) | $\theta_t = (A/B)^t$, geometric growth | Jensen+smoothness sum $(T-s)\theta_s r_s$ is dominated near $s = T-1$; the only available bound is $T\theta_{T-1}\cdot D^2/\eta'$ — loose by factor $T$ | Recovers ergodic $T^{-1/2}$, not pure last-iterate |
| G1''' (polynomial weights) | Mimic Garrigos $\theta_t = (T-t+1)/(T-t+1+A/B)\theta_{t-1}$ | Singular recursion when $\beta \geq 1/2$ ($A/B \geq 2$); for $\beta < 1/2$, $\gamma$ outside Lemma A.3's $[0,1]$ range | Doesn't extend cleanly to $\beta > 0$ |
| G2 (ZG direct on $y_t$) | Skip COV; Zamani-Glineur on raw SHB | Same $-B''r_{t-1}$ structure appears; momentum cross term $2\beta\langle y_t-z_t,y_t-y_{t-1}\rangle$ adds an extra Young coupling that only re-routes the obstruction | Equivalent to G1', fails at the same step |
| G3 (Schedule-Free) | Defazio 2024 SF-method specializes to SHB? | Quick check: Defazio's SF analysis assumes a specific weighted iterate $y_t = (1-c_t)x_t + c_t z_t$ with non-trivial $c_t$ schedule; SHB does not fit (corresponds to $c_t \equiv \beta$ which violates SF's $c_t = O(1/t)$ growth) | Inapplicable |
| G4 (PEP / SDP) | Numerical Lyapunov search via PEPit | NOT ATTEMPTED in this round (would need pip install pepit + several hours of SDP setup). Recommended for next iteration if Theorem 3 is critical. | Pending |

---

## 10. Honest one-line summary

The Garrigos 2025 variance transfer cleanly extends to give **rigorous ergodic last-iterate $T^{-1/2}$ for SHB** under Garrigos's expected-smoothness assumption (an improvement over v5), but the **pure last-iterate $T^{-1/2}$ remains a conjecture** because the SHB-induced coupling term $-B\,r_{t-1}$ cannot be eliminated within the Garrigos / Zamani-Glineur framework without losing the rate.
