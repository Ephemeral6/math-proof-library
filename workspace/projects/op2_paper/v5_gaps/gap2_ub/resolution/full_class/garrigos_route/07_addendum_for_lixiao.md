# Addendum to "Progress Report on Two OP-2 v5 Gaps" — Garrigos 2025 Route

**Date:** 2026-04-29
**Scope:** Updates §2.4 ("Full-class last-iterate — honest scope") of `report_for_lixiao.md` with the Garrigos route attempt.

---

## Updated status table

| Item | v5 / earlier | After Garrigos route |
|---|---|---|
| **Cesàro UB, full class** | Rate $T^{-1/2}$, abs constant $1$ | Same |
| **Last-iterate UB, quadratic class** | Rate $T^{-1/2}$, $(1+\beta)/[4(1-\beta)]\sigma D/\sqrt T$ | Same |
| **Ergodic last-iterate (min over $t$), full class, NOISE MODEL = finite-sum + variance-at-minimum** | not previously stated | **NEW: rigorous $O(LD^2 + \sigma^2)/((1-\beta)\sqrt{LT})$** via Garrigos variance transfer; modestly extends v5 to Garrigos's weaker noise assumption |
| **Pure last-iterate UB, full class, $T^{-1/2}$** | conjecture (9-case empirical) | **STILL conjecture** — Garrigos route identifies but does not close the gap |

---

## What Garrigos 2025 (arXiv:2507.14122, July 2025) gave us

Garrigos-Cortild-Ketels-Peypouquet 2025 prove **plain SGD** last-iterate
$\tilde O(T^{-1/2})$ for L-smooth convex finite-sum without bounded-variance assumption,
using a "variance transfer inequality" (their Lemma 4.1) combined with Zamani-Glineur weights.

I adapted this to SHB via the standard Iouditski-Polyak change-of-variables
$w_t = y_t + a(y_t - y_{t-1})$, $a = \beta/(1-\beta)$, $\eta' = \eta/(1-\beta)$, giving the descent
$$
A\,r_t - B\,r_{t-1} - C\,(f(z_t) - \inf f) \leq \|w_t - z_t\|^2 - \mathbb E\|w_{t+1} - z_t\|^2 + V'
\tag{★}
$$
with $A = 2\eta'[(1+a) - \eta'L(1+\varepsilon)]$, $B = 2\eta'a$, $C = 2\eta'$,
$V' = \eta'^2(1+\varepsilon^{-1})\sigma^2$, and $\sigma^2 = \mathbb E\|\nabla f_i(x^*)\|^2$.

(★) is verified at 12 000 MC samples × 5 parameter combinations with z-score $-83$
on the mean of LHS−RHS. Solid.

---

## What works rigorously (ergodic only)

Sum (★) over $t = 0, \dots, T-1$ with $z_t = x^*$ and $\varepsilon$ chosen so $\eta'L(1+\varepsilon) \leq 1/2$:
$$
(A-B)\sum_{t=0}^{T-2}\mathbb E[r_t] \leq \|y_0 - x^*\|^2 + B r_0 + T V'.
$$

With horizon-tuned $\eta = (1-\beta)/(C_0\sqrt{LT})$, $C_0 \geq 2$:
$$
\boxed{\min_{0 \leq t \leq T-2}\mathbb E[r_t] \leq O\!\left(\frac{LD^2 + \sigma^2}{(1-\beta)\sqrt{LT}}\right)}
$$

This is at the **same rate** as the existing v5 Cesàro UB (Theorem 1), but under the
**weaker noise assumption** of Garrigos (variance-at-minimum, not uniform bounded variance).
For OP-2's standard noise model the gain is moot; for the finite-sum model where individual
$f_i$ are L-smooth but not uniformly bounded-gradient, this is a legitimate strengthening.

Verified at `06_verify_ergodic_ub.py` — all `min_t E[r_t]` ≤ predicted UB across $(\beta, T) \in \{0,0.5,0.9\} \times \{100, 400, 1600\}$.

---

## What does NOT work (and why) — the structural barrier

I tried four sub-routes; all four fail at an identifiable step:

| Sub-route | Failure mode |
|---|---|
| **G1.** Direct Garrigos Lemma 4.3 on (★) | The $-Br_{t-1}$ term doesn't fit the lemma's form $a f(x_t) + b f(z_t) + c \inf f$ |
| **G1' (Young's variant).** Replace convexity-at-$y_{t-1}$ with Young's; eliminate $r_{t-1}$ at cost of $\rho_t^2$ | $\rho_t^2$-contribution scales as $\eta'a\xi^{-1}$; any $\xi(T)$ forces a tradeoff: small $\xi$ ⟹ uncontrolled $\rho_t^2$ noise floor ($O(1)$ constant offset); large $\xi$ ⟹ $\gamma = a\xi L$ inflates and the $T^{-1/2}$ rate degrades |
| **G1''. Geometric weights.** $\theta_t = (A/B)^t$ make $A\theta_t - B\theta_{t+1} = 0$ | Jensen step generates $\sum_s(T-s)\theta_s r_s$ ≈ $T\theta_{T-1}\sum r_s$ — only ergodic-bound $\sum r_s = O(D^2/\eta')$ available, loose by factor $T$ |
| **G1'''. Polynomial weights mimicking Garrigos.** $\theta_t/\theta_{t-1} = (T-t+1)/(T-t+1+A/B)$ | Singular for $\beta \geq 1/2$ ($A/B \geq 2$); for $\beta < 1/2$, effective $\gamma = -a$ falls outside Lemma A.3's domain $[0,1]$ |
| **G2. Direct Zamani-Glineur on $y_t$ (no COV)** | Same $-Br_{t-1}$ structure reappears via the momentum cross term $2\beta\langle y_t-z_t, y_t-y_{t-1}\rangle$; no escape |
| **G3. Schedule-Free (Defazio 2024)** | SF uses $c_t = 1/(t+1)$ polynomial schedule, NOT fixed momentum $\beta$. SHB does not specialize from SF |

The structural picture: **Zamani-Glineur weighting gives last-iterate by absorbing all $r_s$ contributions into a single $r_T$ term via a balanced recursion. The recursion balances when there's exactly one function-value gap ($r_t$ at the current iterate). SHB's momentum produces a SECOND gap ($r_{t-1}$), which the recursion cannot absorb without losing the rate.**

---

## What the literature says

| Result | Setting | Rate | Step-size |
|---|---|---|---|
| Liu-Gao 2025 | SHB convex L-smooth | $T^{-1/3}$ | decaying $\eta_t = O(t^{-2/3})$ |
| Hudiani 2025 (arXiv:2507.07281) | SHB convex L-smooth, high-prob | $T^{-1/3}\log^2 T$ | decaying $\eta_t = O(t^{-2/3})$ |
| Garrigos 2025 (arXiv:2507.14122) | **plain SGD** convex L-smooth | $T^{-1/2}\log T$ | constant horizon-tuned $\eta = 1/(C\sqrt{LT})$ |
| Conjecture (Theorem 3) | SHB convex L-smooth, fixed $\beta$ | $T^{-1/2}\log T$ | horizon-tuned $\eta_T = c(1-\beta)/\sqrt{LT}$ |

Hudiani's $T^{-1/3}$ is the closest published bound. Closing the gap from $T^{-1/3}$ (decaying schedule) to $T^{-1/2}$ (horizon-tuned constant) is **open**.

---

## Recommendation for v6

Restate §2.4 as:

> **Theorem 2.5 (NEW, Garrigos-extended ergodic UB).** Under Assumption 2.1 (each $f_i$ convex L-smooth) and Assumption 2.2 ($\sigma^2 = \mathbb E\|\nabla f_i(x^*)\|^2 < \infty$), with horizon-tuned $\eta = c(1-\beta)/\sqrt{LT}$:
> $$\min_{0 \leq t \leq T-2}\mathbb E[f(y_t) - \inf f] \leq O\!\left(\frac{LD^2 + \sigma^2}{(1-\beta)\sqrt{LT}}\right).$$
> Proof: variance transfer + Iouditski-Polyak COV (this work, derivation in App. E).
>
> **Conjecture 3** (full-class last-iterate UB): same rate $T^{-1/2}$ holds for $\mathbb E[f(y_{T-1}) - \inf f]$. Empirically verified across $\beta \in \{0, 0.5, 0.9\}$ at slope $-0.52 \pm 0.02$ over $T \in [50, 3200]$. Garrigos-Zamani-Glineur framework cannot close the conjecture due to the SHB-induced shifted term $-B r_{t-1}$ in (★) being structurally incompatible with the auxiliary-sequence recursion.

---

## What to try next (if Theorem 3 is critical)

1. **Route G4 (PEP/SDP) — NOT YET ATTEMPTED.** Numerically search for a quadratic Lyapunov function via PEPit. If feasible at $T^{-1/2}$, extract the closed form and write the proof. If infeasible, that's the strongest possible negative result — **no quadratic Lyapunov certifies $T^{-1/2}$ for SHB**, which would explain why all elementary routes (including all four G1 variants) fail.

2. **Lower bound matching Hudiani 2025?** OP-2's existing LB is $\Omega(\sigma D/\sqrt T)$ which exceeds Hudiani's $T^{-1/3}$ UB — meaning Hudiani's $T^{-1/3}$ is loose, not the LB. For horizon-tuned $\eta_T$, OP-2's LB (proved at Gap 1, this work) and the conjectured matching UB ARE both at $T^{-1/2}$. Confirming the LB extends to fixed-step-without-horizon-tuning would be a clean separation.

3. **Restrict noise model.** A clean last-iterate $T^{-1/2}$ might be provable for Lipschitz-noise (e.g. $\|\xi_t\| \leq G$ a.s.) instead of variance-bounded noise; the trajectory-control argument changes structurally and may bypass the obstruction.

---

## Files

```
op2_v5_gaps/gap2_ub/resolution/full_class/garrigos_route/
├── 01_garrigos_summary.md              ← Step 1 precise lemma statements
├── 02_route_g1_draft.md                ← Step 4 G1 draft (incomplete original)
├── 03_verify_shb_rate.py / .txt / .json ← empirical T^-1/2 confirmation
├── 04_verify_descent.py / .txt          ← descent (★) MC verification
├── 05_route_g1_resolution.md            ← detailed obstacle-by-obstacle analysis
├── 06_verify_ergodic_ub.py / .txt / .json ← NEW ergodic UB verification (this round)
├── 07_addendum_for_lixiao.md            ← THIS DOCUMENT
├── garrigos2025.pdf / .txt              ← source paper
├── liu_zhou.pdf / .txt
└── defazio2024.pdf / .txt
```

---

## Bottom line

Garrigos's variance transfer is a real, useful tool — it cleanly extends the ergodic last-iterate UB to the variance-at-minimum noise model, an addition to v5. It does **not** close Theorem 3 (full-class pure last-iterate). The structural obstruction is identified at the level of the auxiliary-sequence recursion, and PEP/SDP (G4) is the next natural attempt.
