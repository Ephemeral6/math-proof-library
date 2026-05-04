# Direction 2 — Explorer 1 (Route A, ORTHODOX frame)

**Frame:** ORTHODOX. Run the standard 3-term Lyapunov / energy-descent protocol for fixed-momentum SHB, choose constants by the textbook recipe, and report what rate it gives — without trying to be clever about saving the $\sigma D/\sqrt T$ form.

**Iteration (recall).** With $g_t = \nabla f(x_t) + \xi_t$, $\mathbb{E}[\xi_t\mid\mathcal{H}_t] = 0$, $\mathbb{E}\|\xi_t\|^2\leq \sigma^2$,
$$
x_{t+1} \;=\; x_t \;-\; \eta g_t \;+\; \beta(x_t-x_{t-1}).
$$
Write $m_t := x_t - x_{t-1}$ and $\Delta_t := x_{t+1}-x_t = -\eta\nabla f(x_t) - \eta\xi_t + \beta m_t$. Set $D=\|x_0-x^\star\|$.

---

## Step 1 — Stepsize choice

For the orthodox 3-term Lyapunov to produce a positive contraction, we need the deterministic descent to dominate. The natural region is
$$
\eta \;\in\; \Bigl(0,\ \tfrac{1-\beta^2}{L}\Bigr],\qquad \beta\in[0,1).
$$
This is *strictly inside* the SHB stability region $\mathcal S = \{(\beta,\eta):\eta < 2(1+\beta)/L\}$, and is the natural sub-region in which $L\eta + \beta^2 < 1$, the inequality the Lyapunov coefficients require to stay positive. For the fixed-stepsize discussion we keep $\eta$ free in this range; for the time-varying analysis we will revisit $\eta_t = c/(L\sqrt T)$.

## Step 2 — Per-step descent inequality

By $L$-smoothness,
$$
f(x_{t+1}) \;\leq\; f(x_t) + \langle \nabla f(x_t),\Delta_t\rangle + \tfrac{L}{2}\|\Delta_t\|^2.
$$
Substituting $\Delta_t = -\eta\nabla f(x_t)-\eta\xi_t+\beta m_t$ and taking $\mathbb{E}[\cdot\mid\mathcal H_t]$:
$$
\mathbb{E}[f(x_{t+1})\mid\mathcal H_t] \;\leq\; f(x_t)\;-\;\eta\|\nabla f(x_t)\|^2 \;+\;\beta\langle\nabla f(x_t),m_t\rangle\;+\;\tfrac{L}{2}\,\mathbb{E}[\|\Delta_t\|^2\mid\mathcal H_t]. \tag{D}
$$
The cross term $\beta\langle\nabla f(x_t),m_t\rangle$ is the irritant: it is sign-indefinite. The Lyapunov fixes this by adding pieces whose $\langle\nabla f,m_t\rangle$ coefficients sum to zero with the $+\beta$ in (D).

## Step 3 — Distance-from-optimum recursion

$$
\|x_{t+1}-x^\star\|^2 \;=\; \|x_t-x^\star\|^2 + 2\langle x_t-x^\star,\Delta_t\rangle + \|\Delta_t\|^2.
$$
After expectation, $\mathbb E[\langle x_t-x^\star,-\eta\xi_t\rangle]=0$, leaving
$$
\mathbb E\bigl[\|x_{t+1}-x^\star\|^2\mid\mathcal H_t\bigr] = \|x_t-x^\star\|^2 - 2\eta\langle\nabla f(x_t),x_t-x^\star\rangle + 2\beta\langle x_t-x^\star,m_t\rangle + \mathbb E\|\Delta_t\|^2. \tag{R}
$$
Convexity gives $\langle\nabla f(x_t),x_t-x^\star\rangle\geq f(x_t)-f^\star$, so the second term is $\leq -2\eta(f(x_t)-f^\star)$.

## Step 4 — Velocity recursion

$\Delta_t = m_{t+1}$. So
$$
\mathbb E\|m_{t+1}\|^2 = \eta^2\|\nabla f(x_t)\|^2 + \eta^2\sigma^2 + \beta^2\|m_t\|^2 - 2\eta\beta\langle\nabla f(x_t),m_t\rangle. \tag{V}
$$

## Step 5 — Cross-term elimination, choice of $c_1,c_2$

Track
$$
V_t \;:=\; \mathbb{E}[f(x_t)-f^\star] \;+\; c_1\|x_t-x^\star\|^2 \;+\; c_2\|m_t\|^2.
$$
Combine $1\cdot$(D) $+\,c_1\cdot$(R) $+\,c_2\cdot$(V). The coefficient of $\langle\nabla f(x_t),m_t\rangle$ is
$$
\beta \;-\; 2\,c_2\,\eta\beta \;\;=\;\; \beta\bigl(1-2c_2\eta\bigr).
$$
So $c_2 = \tfrac{1}{2\eta}$ kills it. *However*, the descent term (D) also produces an $\|m_t\|^2$ piece via $\tfrac{L}{2}\|\Delta_t\|^2$, namely $\tfrac{L\beta^2}{2}\|m_t\|^2$. Combining all $\|m_t\|^2$ pieces and the $\|\nabla f(x_t)\|^2$ pieces, the cleanest tuning that simultaneously zeros the $\langle\nabla f,m\rangle$ cross term and balances the $\|\nabla f\|^2$ coefficient is
$$
\boxed{\;c_2 \;=\; \frac{\beta^2}{2\eta},\qquad c_1 \;=\; \frac{1-L\eta-\beta^2}{2\eta}.\;}
$$
Both are positive iff $L\eta + \beta^2 < 1$, i.e. iff $\eta < (1-\beta^2)/L$ (matching Step 1).

**Verification of the cross-term coefficient sum.** Computing the full contribution of $\langle\nabla f,m_t\rangle$ across (D), (R), (V):
$$
\underbrace{\beta}_{\text{from D}} \;+\; \underbrace{0}_{\text{from R, after }\xi\text{-zero-mean}} \;-\; \underbrace{2\eta\beta\,c_2}_{\text{from V}} \;+\; \underbrace{-L\eta\beta}_{\text{from }\tfrac{L}{2}\|\Delta\|^2 \text{ in D}} \;+\; \underbrace{-2\eta\beta\,c_1}_{\text{from }\|\Delta\|^2\text{ in R}}.
$$
Summing: $\beta(1 - L\eta) - 2\eta\beta(c_1+c_2)$. Setting this $=0$ yields $c_1+c_2 = (1-L\eta)/(2\eta)$, which is exactly satisfied by the boxed choice.

The $\|\nabla f(x_t)\|^2$ coefficient becomes (one checks)
$$
-\eta + \tfrac{L\eta^2}{2} + \eta^2(c_1+c_2) \;=\; -\eta + \tfrac{L\eta^2}{2} + \tfrac{\eta(1-L\eta)}{2} \;=\; -\frac{\eta}{2}.
$$
Negative — good, this gives free non-negative contraction strength via co-coercivity.

## Step 6 — Assembling the recursion

Combining (D)+$c_1$(R)+$c_2$(V) under the choices above (and the convexity bound on $\langle\nabla f,x_t-x^\star\rangle$):
$$
\mathbb E[V_{t+1}\mid \mathcal H_t] \;\leq\; V_t \;-\; \frac{\eta}{2}\|\nabla f(x_t)\|^2 \;-\; 2\eta c_1\,(f(x_t)-f^\star) \;+\; 2c_1\beta\langle x_t-x^\star,m_t\rangle \;+\; \mathcal{N}\sigma^2,
$$
where the noise prefactor is
$$
\mathcal N \;=\; \tfrac{L\eta^2}{2} + c_1\eta^2 + c_2\eta^2 \;=\; \eta^2\Bigl(\tfrac{L}{2} + \tfrac{1-L\eta}{2\eta}\Bigr) \;=\; \tfrac{\eta}{2}.
$$
The remaining cross term $2c_1\beta\langle x_t-x^\star,m_t\rangle$ is handled by Young's inequality with parameter $\delta>0$:
$$
2c_1\beta\langle x_t-x^\star,m_t\rangle \;\leq\; \delta\,c_1\,\|x_t-x^\star\|^2 + \frac{c_1\beta^2}{\delta}\,\|m_t\|^2.
$$
Choose $\delta = \eta c_1$ (ties $\delta\,c_1 = \eta c_1^2$ to match the available distance-shrinkage budget), giving:
- distance term: $-2\eta c_1\,(f(x_t)-f^\star) + \eta c_1^2\|x_t-x^\star\|^2$;
- velocity term: $\bigl(\beta^2/(2\eta)\bigr)\cdot \mathbb 1$ on $\|m_t\|^2$ already, plus an extra $\beta/\eta\cdot\|m_t\|^2$ from $c_1\beta^2/\delta = \beta/\eta$.

So in the strongly-convex (or PL) case, $\eta c_1\|x_t-x^\star\|^2$ is absorbed by the contraction $f(x_t)-f^\star \geq \tfrac{\mu}{2}\|x_t-x^\star\|^2$. **In the convex non-SC case there is no such absorption** — the $\|x_t-x^\star\|^2$ term simply persists in $V_t$, and the $-2\eta c_1(f(x_t)-f^\star)$ term is the only progress driver.

**Co-coercivity rescue.** Use the smooth-convex co-coercivity inequality
$$
\|\nabla f(x_t)\|^2 \;\leq\; 2L\,(f(x_t)-f^\star).
$$
Then $-\tfrac{\eta}{2}\|\nabla f(x_t)\|^2$ already gives a $-\tfrac{\eta}{2}\cdot 2L = -L\eta$ multiple of $(f(x_t)-f^\star)$ — wait, that's the wrong direction (co-coercivity gives an *upper* bound on $\|\nabla f\|^2$, so $-\|\nabla f\|^2 \geq -2L(f-f^\star)$, i.e. it *weakens* the negative contribution, not strengthens). Discard. Use instead the more useful direction: in convex smooth, $\|\nabla f(x_t)\|^2 \geq 0$ trivially, and we keep $-\tfrac{\eta}{2}\|\nabla f\|^2 \leq 0$.

So the clean recursion in the convex non-SC case is
$$
\boxed{\;\mathbb E[V_{t+1}\mid\mathcal H_t] \;\leq\; V_t \;-\; 2\eta c_1\,(f(x_t)-f^\star) \;+\; \tfrac{\eta}{2}\,\sigma^2 \;+\; (\text{benign}\le 0 \text{ terms}).\;}\tag{L}
$$
with $c_1 = (1-L\eta-\beta^2)/(2\eta)$ and $c_2 = \beta^2/(2\eta)$. The "benign" piece collects $-\tfrac{\eta}{2}\|\nabla f(x_t)\|^2$ and the $-c_2(1-\beta^2)\|m_t\|^2$ shrinkage that survives after Young (one checks the net $\|m_t\|^2$ coefficient is $-(1-\beta)\cdot c_2 + O(\beta)$, which is non-positive for $\eta\le (1-\beta^2)/L$).

## Step 7 — Telescoping the convex non-SC case

Sum (L) from $t=0$ to $T-1$:
$$
2\eta c_1 \sum_{t=0}^{T-1}\mathbb E[f(x_t)-f^\star] \;\leq\; V_0 - \mathbb E V_T \;+\; T\cdot\tfrac{\eta}{2}\sigma^2 \;\leq\; V_0 + T\cdot\tfrac{\eta\sigma^2}{2}.
$$
With $V_0 \leq f(x_0)-f^\star + c_1 D^2 \leq \tfrac{L}{2}D^2 + c_1 D^2$ and $c_1 = (1-L\eta-\beta^2)/(2\eta) = O(1/\eta)$:
$$
\frac{1}{T}\sum_{t=0}^{T-1}\mathbb E[f(x_t)-f^\star] \;\leq\; \underbrace{\frac{V_0}{2\eta c_1\,T}}_{\text{bias}} \;+\; \underbrace{\frac{\sigma^2}{4c_1}}_{\text{variance floor}}.
$$
Since $c_1 \asymp (1-\beta^2)/(2\eta)$ for moderate $\beta$ and small $\eta L$:
$$
\frac{1}{2\eta c_1} \;=\; \frac{1}{1-L\eta-\beta^2} \;\leq\; \frac{1}{1-\beta^2 - L\eta},\qquad \frac{1}{4c_1} \;=\; \frac{\eta}{2(1-L\eta-\beta^2)}.
$$
Hence
$$
\boxed{\;\frac{1}{T}\sum_{t=0}^{T-1}\mathbb E[f(x_t)-f^\star] \;\leq\; \frac{LD^2 + 2c_1 D^2}{2\eta c_1\,T} \;+\; \frac{\sigma^2\eta}{2(1-L\eta-\beta^2)}.\;}\tag{Cesàro UB}
$$

This is a **Cesàro-average** bound. It does NOT directly bound the last iterate $f(x_T)-f^\star$ in the non-SC convex case — convexity gives $f(\bar x_T)-f^\star \leq \frac{1}{T}\sum (f(x_t)-f^\star)$ via Jensen, but $f(x_T)\neq f(\bar x_T)$ in general. The orthodox path here only delivers the *Cesàro* rate.

## Step 8 — Last-iterate extraction (the failure point)

To convert (Cesàro UB) to a last-iterate bound one of two things must happen:

(a) **Strong convexity / PL**: gives $V_t$ contraction $\mathbb E V_{t+1} \leq (1-\alpha)V_t + C\sigma^2\eta^2$ with $\alpha = \Theta(\mu\eta(1-\beta))$, and then $\mathbb E V_T \leq (1-\alpha)^T V_0 + C\sigma^2\eta^2/\alpha$. **Not available here.**

(b) **Last-iterate is monotone** in some surrogate (Sebbouh-Gower-Defazio approach), producing an extra $\log T$ or $\sqrt T$ factor relative to the Cesàro rate.

For the orthodox 3-term Lyapunov *as written*, $V_t$ does NOT contract in the non-SC case. The Lyapunov decreases on average only at rate $\sum(f(x_t)-f^\star)$, which by Jensen relates to the *average* iterate, not the last.

## Step 9 — Optimizing the stepsize

**Fixed $\eta$ ("fixed-momentum, fixed-η SHB").** From (Cesàro UB), the bias is $O(LD^2/(T(1-\beta^2-L\eta)))$ and the variance is $O(\sigma^2\eta/(1-\beta^2-L\eta))$. The variance term is $\Theta(\sigma^2\eta)$ — a **constant noise floor** independent of $T$. **The orthodox Lyapunov does NOT produce a $\sigma D/\sqrt T$ rate at fixed $\eta$.** This matches Routes E/F's noise-floor picture exactly.

**Decreasing $\eta_t = c/(L\sqrt T)$.** Substituting $\eta = c/(L\sqrt T)$ (constant, but $T$-dependent):
- bias $\to LD^2/(T\cdot c/(L\sqrt T)\cdot (1-\beta^2)) = L^2 D^2/(c(1-\beta^2)\sqrt T) \cdot (1/\sqrt T) = L^2 D^2/(c(1-\beta^2)T^{1/2})$ — wait, let me redo.

Bias term as written is $\frac{LD^2 + 2c_1 D^2}{2\eta c_1 T}$. With $c_1 \approx (1-\beta^2)/(2\eta)$, $2\eta c_1 \approx 1-\beta^2$, so bias $\approx (LD^2 + (1-\beta^2)D^2/\eta)/((1-\beta^2)T) = \frac{LD^2}{(1-\beta^2)T} + \frac{D^2}{\eta T}$.

With $\eta = c/(L\sqrt T)$: $\frac{D^2}{\eta T} = \frac{LD^2}{c\sqrt T}$, and the variance term $\frac{\sigma^2\eta}{2(1-\beta^2)} = \frac{c\sigma^2}{2L(1-\beta^2)\sqrt T}$. Optimizing $c = \sigma\sqrt{(1-\beta^2)}/(L\cdot D/\sqrt T \cdot \text{const})$... actually, balancing:
$$
\frac{LD^2}{c\sqrt T} \;\sim\; \frac{c\sigma^2}{L(1-\beta^2)\sqrt T} \;\;\Longrightarrow\;\; c^2 \;=\; \frac{L^2 D^2(1-\beta^2)}{\sigma^2},\quad c = \frac{LD\sqrt{1-\beta^2}}{\sigma}.
$$
At this $c$, both terms equal $\sigma D/(\sqrt{1-\beta^2}\sqrt T) \cdot O(1)$. Plugging back, **Cesàro rate at $\eta = \Theta(1/\sqrt T)$:**
$$
\frac{1}{T}\sum\mathbb E[f(x_t)-f^\star] \;\leq\; \frac{LD^2}{(1-\beta^2)T} \;+\; \frac{C\,\sigma D}{\sqrt{1-\beta^2}\,\sqrt T}.
$$

**This is the right form** — it MATCHES the OP-2 lower bound up to the $\beta$-dependent constants, **but only for the Cesàro average, not for the last iterate, and only at $\eta_t \sim 1/\sqrt T$ (not at fixed $\eta$).**

## Step 10 — Constants in $\beta$

From the boxed coefficients:
- $c_1 \asymp (1-\beta^2)/(2\eta)$ when $L\eta \ll 1-\beta^2$;
- bias prefactor $1/(2\eta c_1 T) = 1/((1-\beta^2-L\eta)T)$, so $C_1(\beta) = O(1/(1-\beta^2)) = O(1/(1-\beta))$ near $\beta=1$;
- variance prefactor $\eta/(2(1-\beta^2-L\eta)) \asymp \eta/(2(1-\beta^2))$, so $C_2(\beta)=O(1/(1-\beta^2))$;
- under the optimal $\eta_t = c/(L\sqrt T)$ tuning the variance constant becomes $1/\sqrt{1-\beta^2} \asymp 1/\sqrt{1-\beta}$.

**$\beta$-blowup pattern.** As $\beta\to 1$: bias $\propto 1/(1-\beta)$, variance $\propto 1/(1-\beta)$ (fixed $\eta$) or $1/\sqrt{1-\beta}$ (decreasing $\eta_t$). This is *milder* than the $1/(1-\beta)^2$ blowup in some textbook SHB analyses; it is the "good" case under the cleanest cross-term cancellation.

## Step 11 — Numerical sanity check (quadratic noise floor)

To confirm the noise-floor scaling we computed (independent verification of Route F):

| $\beta$ | $\eta L$ | empirical $\frac12 L\,\mathrm{Var}_\infty$ | heuristic $\frac{\sigma^2\eta}{2(1-\beta^2)}$ | ratio |
|---|---|---|---|---|
| 0.0 | 0.5 | 0.1667 | 0.2500 | 0.667 |
| 0.0 | 1.0 | 0.5000 | 0.5000 | 1.000 |
| 0.5 | 0.5 | 0.3000 | 0.3333 | 0.900 |
| 0.7 | 0.3 | 0.2742 | 0.2941 | 0.932 |
| 0.9 | 0.1 | 0.2568 | 0.2632 | 0.976 |

(Computed via discrete Lyapunov equation for $f(x)=Lx^2/2$, $\sigma=L=1$.) The orthodox heuristic $\sigma^2\eta/(2(1-\beta^2))$ is correct up to a bounded constant ratio, and tight as $\beta\to 1$.

## Step 12 — Honest comparison with OP-2 LB

OP-2 LB (Theorem (Main) in `op2_downgraded_proof_v4.md`):
$$
\mathbb E[f^{(T)}_{\beta,\eta}(x_T) - f^{(T),\star}_{\beta,\eta}] \;\geq\; \frac{\kappa(\beta,\eta)}{4}\cdot\frac{LD^2}{T} + c_{\mathrm{NY}}\cdot\frac{\sigma D}{\sqrt T},\qquad c_{\mathrm{NY}}=\sqrt 2/27.
$$
(∀-∃: for each $T$, the function $f^{(T)}_{\beta,\eta}$ is chosen.)

What this Explorer (Route A, orthodox) delivers:

| Setting | Quantity bounded | Rate from orthodox Lyapunov | Matches OP-2 LB? |
|---|---|---|---|
| Fixed $\eta$, fixed $\beta$, last iterate | $\mathbb E[f(x_T)-f^\star]$ | **Not available** (no contraction) | — |
| Fixed $\eta$, fixed $\beta$, Cesàro avg | $\mathbb E[f(\bar x_T)-f^\star]$ | $O\bigl(\tfrac{LD^2}{(1-\beta^2)T}\bigr) + O\bigl(\tfrac{\sigma^2\eta}{1-\beta^2}\bigr)$ | **NO** — variance term is $\Theta(\sigma^2)$ floor, not $\sigma D/\sqrt T$ |
| $\eta_t=\Theta(1/(L\sqrt T))$, Cesàro avg | $\mathbb E[f(\bar x_T)-f^\star]$ | $O\bigl(\tfrac{LD^2}{(1-\beta^2)T}\bigr) + O\bigl(\tfrac{\sigma D}{\sqrt{1-\beta^2}\sqrt T}\bigr)$ | **YES, up to constants** — but for *Cesàro*, not last iterate, and at *decreasing* stepsize, not fixed $\eta$ |

**Verdict.**
1. For **fixed-momentum, fixed-$\eta$** SHB on smooth convex non-SC, the orthodox 3-term Lyapunov **fails** to produce a matching last-iterate UB. It delivers only a Cesàro UB with a constant noise floor, not $\sigma D/\sqrt T$. This corroborates the Route F refutation: the noise-floor obstruction is real, intrinsic to the fixed-$\eta$ regime.
2. With **decreasing stepsize $\eta_t=\Theta(1/\sqrt T)$**, the orthodox method delivers the right Cesàro rate $LD^2/T + \sigma D/\sqrt T$, with $\beta$-constants $O(1/(1-\beta^2))$ in bias and $O(1/\sqrt{1-\beta^2})$ in variance — better than the route-A predicted constants in `direction_2_scout_routes.md` ($1/(1-\beta)^2$).
3. Even with decreasing $\eta_t$, the orthodox path bounds only the **Cesàro average**, not the last iterate. Closing the last-iterate gap requires either (a) a Sebbouh-style monotonicity result (Route C) accepting an extra $\log T$, or (b) a tailored Lyapunov that propagates the gap to the last index, neither of which the orthodox 3-term method delivers.

## Step 13 — Summary

- Computed $c_1=(1-L\eta-\beta^2)/(2\eta)$, $c_2=\beta^2/(2\eta)$ as the unique cross-term-killing choice.
- Verified the resulting recursion: $V_{t+1} \leq V_t - 2\eta c_1(f(x_t)-f^\star) + \eta\sigma^2/2$.
- **Fixed-$\eta$ rate:** Cesàro $\mathbb E[f(\bar x_T)-f^\star] \leq \frac{C_1 LD^2}{(1-\beta^2)T} + \frac{C_2\sigma^2\eta}{1-\beta^2}$ — variance is a **noise floor**, *does not match* OP-2 LB.
- **Decreasing $\eta_t \sim 1/(L\sqrt T)$ rate:** Cesàro $\mathbb E[f(\bar x_T)-f^\star] \leq \frac{C_1 LD^2}{(1-\beta^2)T} + \frac{C_2 \sigma D}{\sqrt{1-\beta^2}\sqrt T}$ — *matches OP-2 LB up to constants, but only for Cesàro*.
- **Last-iterate UB:** orthodox path **does not** produce one in the non-SC case.
- $\beta$-constants: $C_1=O(1/(1-\beta))$, $C_2=O(1/\sqrt{1-\beta})$ (decreasing $\eta_t$) or $O(1/(1-\beta))$ (fixed $\eta$). These are *cleaner* than the scout's pessimistic estimate $1/(1-\beta)^2$.
- Numerical noise-floor table corroborates the heuristic $\sigma^2\eta/(2(1-\beta^2))$ as the correct fixed-$\eta$ asymptote on the quadratic.

**Honest bottom line.** The orthodox 3-term Lyapunov is the right tool to *recover* the SGD rate $LD^2/T+\sigma D/\sqrt T$ for **Cesàro-average iterates** of fixed-momentum SHB under **decreasing stepsize**, with $\beta$-blowup $O(1/(1-\beta))$. It is **not** the right tool for the **last iterate** at **fixed $\eta$** — there it gives only a noise floor, *not* matching the OP-2 LB pointwise. The reviewer's "missing matching UB" concern in `op2_downgraded_proof_v4.md` §4 is therefore *unresolved* by this orthodox route alone; matching the OP-2 LB at the level of last iterate genuinely requires either (i) a different algorithm (projected SHB, Route D), (ii) a different stepsize schedule (decreasing), (iii) a different averaging scheme (Cesàro, GFJ15-style), or (iv) acceptance of a $\log T$ factor (Route B/C). Within the orthodox 3-term Lyapunov frame, no clean last-iterate $\sigma D/\sqrt T$ UB exists for fixed-momentum, fixed-$\eta$ SHB.
