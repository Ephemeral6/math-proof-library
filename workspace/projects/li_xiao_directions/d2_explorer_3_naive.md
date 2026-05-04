# Direction 2 — Explorer 3 (Route C, NAIVE frame)

**Author:** Explorer 3
**Frame:** NAIVE (take Sebbouh et al. 2020 off the shelf and read off constants)
**Route:** C — Sebbouh–Gower–Defazio de-averaging
**Target:** Establish whether Sebbouh et al. arXiv:2006.07867 yields a last-iterate UB
$\mathbb{E}[f(x_T)-f^\star]\le C(\beta)\,LD^2/T + C'(\beta)\,\sigma D/\sqrt T$ for fixed-momentum SHB on $L$-smooth convex (non-SC) functions.

---

## 1. The naive plan

The starting point is the abstract of Sebbouh, Gower, Defazio "Almost sure convergence rates for Stochastic Heavy-Ball" (NeurIPS 2021 / arXiv:2006.07867). Two claims are advertised:

1. **A.s. last-iterate rate.** For SHB iterates $(x_t)$ on $L$-smooth convex $f$ with bounded-variance oracle ($\mathbb{E}\|g_t-\nabla f(x_t)\|^2\le\sigma^2$), there is a step/momentum schedule under which
   $f(x_T) - f^\star = o(1/\sqrt T)\quad\text{almost surely.}$
2. **"Arbitrarily close" rate.** For any $\varepsilon>0$ there is a schedule with $f(x_T)-f^\star = O(T^{-1/2+\varepsilon})$ a.s.

The naive plan: import these statements into our problem (fixed $\beta$, fixed $\eta$), upgrade a.s. to expectation, and read off constants. If it works, we have a clean matching UB.

---

## 2. Step 1 — What Sebbouh et al. actually prove

A careful look at the paper (and the standard Robbins–Siegmund template behind it) shows the result is **not** for fixed $(\beta,\eta)$:

- The "arbitrarily close to $1/\sqrt T$" theorem is achieved by a **time-varying momentum** $\beta_t = (t-1)/(t+\alpha)$ (Nesterov-style, $\beta_t\uparrow 1$) combined with a **time-varying stepsize** $\eta_t = \Theta(t^{-\gamma})$ with $\gamma \in (1/2, 1)$ tuned to $\varepsilon$.
- The proof uses Robbins–Siegmund on a Lyapunov $V_t = \|x_t-x^\star\|^2 + c_t\|x_t-x_{t-1}\|^2$ where the coefficient $c_t$ is **schedule-dependent**, and the bias-vs-variance balance is paid for by tuning $\eta_t$.
- For **constant $\eta$ and constant $\beta$**, the standard Robbins–Siegmund condition $\sum_t\eta_t^2\sigma^2<\infty$ fails. The paper does **not** claim a $1/\sqrt T$ a.s. rate (or any decaying rate) for fixed $(\beta,\eta)$ with stochastic gradients on smooth convex non-SC $f$.

So the desired off-the-shelf statement — "$f(x_T)-f^\star = o(1/\sqrt T)$ a.s. for fixed $\beta$, fixed $\eta$" — is **not in the paper**. The naive import already breaks.

---

## 3. Step 2 — A.s. to expectation: the conversion gap

Even granting an a.s. rate, the conversion to $\mathbb{E}[f(x_T)-f^\star]$ is non-trivial:

- Almost-sure $o(1/\sqrt T)$ does **not** imply $\mathbb{E}[\cdot]=o(1/\sqrt T)$ without uniform integrability. Concretely, on a quadratic $f(x)=(L/2)x^2$ with fixed $\eta$, the iterate has stationary variance $\sigma^2\eta/(L(1-\beta^2))>0$, so $\sqrt T\,(f(x_T)-f^\star)$ is NOT uniformly integrable in $T$.
- Robbins–Siegmund supermartingale convergence yields a.s. convergence and an $L^1$-bound on the supermartingale, **not** a rate in $L^1$. Promoting an a.s. $o(\cdot)$ to an $L^1$ $o(\cdot)$ requires extra work (e.g. dominating envelope, second-moment control of $V_t$).
- Sebbouh et al. do prove $L^2$-bounded iterates under their schedule, which gives uniform integrability of $\|x_t-x^\star\|^2$. But $L$-smoothness then gives $f(x_t)-f^\star\le (L/2)\|x_t-x^\star\|^2$, which is bounded but does NOT give a $1/\sqrt T$ rate in expectation; the a.s. $o(1/\sqrt T)$ does not transfer.

Conclusion: even in the schedule where the a.s. rate exists, the expectation rate is not free.

---

## 4. Step 3 — Constants and form of the bound

Suppose, hypothetically, we accept Sebbouh's varying-stepsize schedule and chase constants. The bias/variance decomposition with $\eta_t \sim t^{-1/2+\varepsilon/2}$ and increasing momentum gives a bound of the form
$$\mathbb{E}[f(x_T)-f^\star] \;\le\; \frac{c_1(\beta_\infty,\varepsilon)\,LD^2}{T^{1-\varepsilon}} + \frac{c_2(\beta_\infty,\varepsilon)\,\sigma D}{T^{1/2-\varepsilon}},$$
with $c_1,c_2$ blowing up as $\varepsilon\downarrow 0$. This is **almost** the OP-2 form but suboptimal in two ways:

1. **Loses an $\varepsilon$ in the rate:** $T^{-1/2+\varepsilon}$ vs $T^{-1/2}$.
2. **Loses an $\varepsilon$ in the bias:** $T^{-(1-\varepsilon)}$ vs $T^{-1}$.
3. **Does not apply to fixed $\beta$, fixed $\eta$**, which is what OP-2's lower bound is about.

So even being maximally generous, the Sebbouh route gives an *almost-tight* UB for an *almost-our-algorithm*, not an exactly-tight UB for the algorithm we care about.

---

## 5. Step 4 — Honest assessment of the gap

The precise gap between Sebbouh's setting and OP-2's setting:

| Aspect | Sebbouh et al. 2020 | OP-2 (this paper) |
|---|---|---|
| Momentum | Time-varying, $\beta_t\uparrow 1$ (Nesterov-like) | **Fixed** $\beta\in[0,1)$ |
| Stepsize | Time-varying, $\eta_t\sim t^{-\gamma}$, $\gamma\in(1/2,1)$ | **Fixed** $\eta\in\mathcal S$ |
| Convergence mode | Almost sure | Expectation |
| Rate | $o(1/\sqrt T)$ a.s. (qualitative) or $O(T^{-1/2+\varepsilon})$ a.s. (rate) | $\Omega(LD^2/T+\sigma D/\sqrt T)$ in expectation (LB) |
| Function class | $L$-smooth convex (same) | $L$-smooth convex (same) |

The mismatches (varying vs fixed schedule, a.s. vs expectation, $\varepsilon$-loss in the rate) are **all in the same direction**: Sebbouh's result is weaker than what OP-2 needs as a matching UB.

---

## 6. Step 5 — Can we sharpen Sebbouh for fixed $(\beta,\eta)$?

The honest answer is **no**, and Explorer 1 / Explorer 2's adversarial analyses make this conclusion forced rather than circumstantial:

- For fixed $\eta$ on the quadratic $f(x)=(L/2)x^2$, the SHB Markov chain $(x_t,x_{t-1})$ admits a unique Gaussian stationary distribution with $\mathrm{Var}_\infty(x_t)=\sigma^2\eta/(L(1-\beta^2))$. The contraction rate to stationarity is geometric.
- Therefore $\mathbb{E}[f(x_T)-f^\star] \to \sigma^2\eta/(2(1-\beta^2)) > 0$ as $T\to\infty$.
- Any fixed-$(\beta,\eta)$ analysis — Sebbouh's or otherwise — must respect this noise floor. **No** $\sigma D/\sqrt T$ decay is possible for a single fixed function with fixed $\eta$.
- Sebbouh's argument escapes this floor specifically by sending $\eta_t\to 0$. There is no "secret" way to recover decay with fixed $\eta$.

Hence the route C **fails** to produce $O(LD^2/T + \sigma D/\sqrt T)$. It can only confirm what Routes A and F predict: a noise-floor saturation $\Theta(\sigma^2\eta/(1-\beta^2))$.

---

## 7. Step 6 — What Sebbouh's analysis does give for fixed $(\beta,\eta)$

If we strip away the varying-schedule machinery and run Sebbouh's Lyapunov $V_t=\|x_t-x^\star\|^2+c\|x_t-x_{t-1}\|^2$ with **constant** $c$, the per-step recursion becomes
$$\mathbb{E}[V_{t+1}\mid\mathcal H_t]\;\le\;V_t \;-\; 2\eta(1-\beta)(f(x_t)-f^\star) \;+\; C(\beta,\eta,L)\,\sigma^2\eta^2.$$
Telescoping over $t=0,\ldots,T-1$ and dividing by $T$:
$$\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}[f(x_t)-f^\star] \;\le\; \frac{V_0}{2\eta(1-\beta)T} + \frac{C(\beta,\eta,L)\,\sigma^2\eta}{2(1-\beta)}.$$
This is a **Cesàro** bound with a constant noise floor $O(\sigma^2\eta/(1-\beta))$. The last-iterate version requires a Cesàro-to-last-iterate conversion, which (without strong convexity) costs a $\sqrt T$ or $\log T$ factor and makes the bound trivial. So even the rescued Sebbouh-style argument for fixed $(\beta,\eta)$ produces:

- **Cesàro:** $O(LD^2/(T(1-\beta)) + \sigma^2\eta/(1-\beta))$ — Cesàro avg of $f$-values.
- **Last iterate:** no improvement on the constant noise floor; cannot get $\sigma D/\sqrt T$.

---

## 8. Step 7 — The right interpretation of OP-2's tightness

Given that no off-the-shelf or adapted Sebbouh argument yields $O(\sigma D/\sqrt T)$ for the fixed-$(\beta,\eta)$ last iterate, the only honest reading of OP-2's tightness is:

**"OP-2 is tight up to the last-iterate vs Cesàro distinction."** Specifically:

- **Lower bound (OP-2):** $\Omega(LD^2/T+\sigma D/\sqrt T)$ for the **last iterate** $x_T$ on the worst-case (T-dependent) instance in $\mathcal F$.
- **Upper bound (GFJ15 + standard SGD):** $O(LD^2/T)$ deterministic Cesàro (GFJ15) and $O(\sigma D/\sqrt T)$ for SGD-like methods on the **Cesàro average** (Nemirovski–Yudin / Lan).

These two together give a "matched up to last-vs-average" picture. The genuine open question is whether the last iterate of fixed-momentum SHB itself achieves the matching $\sigma D/\sqrt T$ rate — and the synthesis of all six explorer routes is that the answer is **no, for any single fixed $f$ with fixed $\eta$**, due to the $\sigma^2\eta/(L(1-\beta^2))$ noise floor.

A weaker but defensible statement is:

**"OP-2 is tight up to log factors against the Cesàro-average UB."** With a $\sqrt{\log T}$-type Cesàro-to-last-iterate conversion (à la Harvey–Liaw–Plan–Randhawa or Jain–Nagaraj–Netrapalli for SGD, projected case), one can sometimes close the gap up to $\sqrt{\log T}$. For SHB specifically, no such closing is published; the gap is genuine.

---

## 9. Step 4 (revisited) — Precise rate from Sebbouh's analysis for FIXED-stepsize fixed-momentum SHB

Combining Sections 6–7, the *actual* rate that Sebbouh's machinery can certify for fixed $(\beta,\eta)\in\mathcal S$ on $L$-smooth convex non-SC $f$, **in expectation**, is:

$$\boxed{\;\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}[f(x_t)-f^\star] \;\le\; \frac{C_1(\beta)\,LD^2}{T} + \frac{C_2(\beta)\,\sigma^2\eta}{L}\;}$$
where $C_1(\beta) = O(1/(1-\beta))$, $C_2(\beta) = O(1/(1-\beta)^2)$. This is a **Cesàro** rate with a **constant noise floor**. There is no $\sigma D/\sqrt T$ term, and there is no last-iterate version without losing a $\sqrt T$.

For the **last iterate**, the strongest defensible statement extractable from Sebbouh-style Lyapunov analysis with fixed $(\beta,\eta)$ is:

$$\mathbb{E}[f(x_T)-f^\star] \;\le\; \frac{C_1(\beta)\,LD^2}{T} + \underbrace{C_2(\beta)\,\frac{\sigma^2\eta}{L}}_{\text{noise floor}} + \underbrace{O\!\left(\frac{V_0}{T\,\alpha(\beta,\eta,L)}\right)}_{\text{contraction term}},$$
where $\alpha$ is the spectral gap of the noiseless SHB operator. The noise floor is irreducible.

---

## 10. Naive conclusion

**The naive Route C fails as stated.** Sebbouh et al. 2020 does **not** provide an off-the-shelf last-iterate UB of the form $O(LD^2/T+\sigma D/\sqrt T)$ for fixed-momentum fixed-stepsize SHB. Specifically:

1. Their a.s. $o(1/\sqrt T)$ rate requires **time-varying** $(\beta_t,\eta_t)$ (increasing momentum, decreasing stepsize). It does not apply to fixed $(\beta,\eta)$.
2. The a.s.→expectation conversion is non-trivial and fails without uniform-integrability arguments not provided in the paper.
3. The constants, when chased, give $O(T^{-1/2+\varepsilon})$ rather than the optimal $T^{-1/2}$, with $\varepsilon$-blowup constants.
4. **For our setting (fixed $(\beta,\eta)$), no adaptation of Sebbouh's argument can beat the noise floor $\sigma^2\eta/(L(1-\beta^2))$**, as forced by the quadratic stationary-distribution argument (Route F).

The right interpretation of OP-2's tightness is therefore:
- **OP-2 is tight up to the last-iterate vs Cesàro-average gap.** The matching $\sigma D/\sqrt T$ UB exists for the Cesàro average, not the last iterate. The last iterate stagnates at a noise floor $\Theta(\sigma^2\eta/(1-\beta^2))$, so OP-2's $\Omega(\sigma D/\sqrt T)$ lower bound is best understood as a $\forall$-$\exists$ minimax statement (each $T$ has its own hard instance), not an $\exists$-$\forall$ statement (a single $f$ achieving $\sigma D/\sqrt T$ rate uniformly in $T$).

This is consistent with Explorer 1's refutation, Explorer 2's Lyapunov noise floor, and the synthesis section of the scout document. Route C contributes a literature cross-check that confirms — rather than overturns — the noise-floor picture.
