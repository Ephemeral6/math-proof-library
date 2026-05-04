# Revised Variance Argument: Le Cam over Sequence Output

## The OP-2 variance bound, restated honestly

OP-2's stochastic 1-D part: $g_y(y) = \alpha_s y + (L/2)\max(|y|-D/\sqrt 2, 0)^2$.
Oracle: $\partial g_y(y) + \sigma\varepsilon_t$ where $\varepsilon_t$ Rademacher.

The bound $\mathbb{E}[g_y(y_T) - \min g_y] \ge c'\sigma D/\sqrt T$ uses Le Cam:
- KL between two trajectory distributions (under $s = +$ vs. $s = -$): $T \cdot 8\alpha^2/\sigma^2 = 1$.
- TV $\le 1/\sqrt 2$, so any test misidentifies $s$ w.p. $\ge (1-1/\sqrt 2)/2 \approx 0.146$.
- When test misidentifies, the iterate is "wrong side", giving gap $\ge \alpha_s \cdot D/\sqrt 2 = \sigma D/(4\sqrt T)$.

For BEST iterate, the algorithm output is $y_{t^*}$ where $t^* = \arg\min_t g_y(y_t)$. This is a measurable function of the trajectory, hence a valid test. Le Cam still gives $\Pr[\hat s \ne s] \ge 0.146$ where $\hat s := -\mathrm{sign}(y_{t^*})$.

**BUT** — when $\hat s \ne s$, this doesn't immediately translate to a gap lower bound on $g_y(y_{t^*})$:

If $\hat s \ne s$, then $\mathrm{sign}(y_{t^*}) = s$. WLOG $s = +$: $y_{t^*} \ge 0$ (or $y_{t^*}$ has unspecified sign if $y_{t^*} = 0$).

Gap: $g_y(y_{t^*}) - \min g_y$. Since $y^\star = -(D/\sqrt 2 + |\alpha|/L) < 0$, and $y_{t^*} \ge 0$, we have:
- If $y_{t^*} \in [0, D/\sqrt 2]$ (in-box on opposite side): $g_y(y_{t^*}) = \alpha_+ y_{t^*} \ge 0$. min $= -\alpha_+ \cdot D/\sqrt 2 - \alpha_+^2/(2L)$. Gap $\ge \alpha_+ D/\sqrt 2 + \alpha_+^2/(2L)$. ✓ This gives $\ge \alpha_+ D/\sqrt 2 = \sigma D/(4\sqrt T)$.
- If $y_{t^*} > D/\sqrt 2$ (in wall above): gap is even larger. ✓
- If $y_{t^*} \in (-(D/\sqrt 2 + |\alpha|/L), 0)$: but we said $y_{t^*} \ge 0$, contradiction with $\mathrm{sign} = s = +$. ✓

Hmm wait — let me recheck. $\mathrm{sign}(y_{t^*}) = s = +1$ means $y_{t^*} > 0$ strictly (sign(0) we'll convene = +1 say). Then $y_{t^*} > 0 > y^\star$, so we're in linear region or beyond. Gap = $\alpha_+(y_{t^*} - y^\star) \ge \alpha_+ \cdot |y^\star| \ge \alpha_+ D/\sqrt 2$. ✓

**Wait — the simulation shows this fails empirically. Why?**

Because the simulation is measuring `min_t g_y(y_t) - min g_y`, NOT `g_y(y_{t*}) - min g_y` where t* is from the SHB orbit. Let me check — actually they're THE SAME by definition: $\min_t g_y(y_t) = g_y(y_{t^*})$.

So the simulation measures EXACTLY what Le Cam gives a bound for. And the simulation says the bound FAILS.

**The bug must be in my Le Cam reasoning.**

Recheck: Le Cam says misidentification probability $\ge 0.146$. This is for EACH hypothesis: $\max_s \mathbb{P}_s[\hat s \ne s] \ge 0.146$. So at least ONE of $s = +, s = -$ has $\mathbb{P}_s[\hat s \ne s] \ge 0.146$.

But what's $\mathbb{P}_s[\hat s = s] + \mathbb{P}_s[\hat s \ne s]$? It's 1 only if $\hat s$ is well-defined (i.e., $y_{t^*} \ne 0$ a.s.). For continuous noise: yes. For Rademacher: $y_{t^*}$ is a continuous-valued mixture, so $\Pr[y_{t^*} = 0] = 0$ generically. ✓

So Le Cam should hold. Yet simulation FAILS.

**Resolution**: Re-read Le Cam. Tsybakov Thm 2.2: $\inf_{\hat s} \max_s \mathbb{P}_s[\hat s \ne s] \ge (1 - \mathrm{TV})/2$. The inf is over ALL tests. For the SPECIFIC test $\hat s := -\mathrm{sign}(y_{t^*})$, we have $\max_s \mathbb{P}_s[\hat s \ne s] \ge \inf_{\hat s'} \max_s \mathbb{P}_s[\hat s' \ne s] \ge 0.146$.

That's correct. So $\max_s \mathbb{E}_s[\text{gap}] \ge 0.146 \cdot \sigma D/(4\sqrt T)$ by the indicator argument.

But simulation says max-over-s of mean gap is $\sim 0.0004$ at $T = 100$, while $0.146 \cdot 1/(4\cdot 10) = 0.00365$. We're failing by factor 10.

**The Le Cam argument MUST have a hidden bug.**

Let me check the KL computation. Each oracle query at step $t$: $g_t = \alpha_s + \sigma\varepsilon_t$ when $|y_t| \le D/\sqrt 2$, else $g_t = \alpha_s + L(|y_t|-D/\sqrt 2)\mathrm{sign}(y_t) + \sigma\varepsilon_t$.

Hmm — when the iterate is OUTSIDE the box, the gradient depends on $y_t$, so the oracle distribution is different. The trajectory $\{y_t\}_{t=0}^T$ is NOT the same in the two hypotheses ($s=\pm$) because $y_t$ depends on past $\xi$'s.

Actually, the KL bound $T \cdot 8\alpha^2/\sigma^2$ is the chain-rule bound:
$$
\mathrm{KL}(P_+^{0:T} \| P_-^{0:T}) = \sum_{t=0}^{T-1} \mathbb{E}_+[\mathrm{KL}(P_+(\xi_t | y_{0:t}) \| P_-(\xi_t | y_{0:t}))]
$$

Per-step KL: oracle output is $g_t = \alpha_s + \mathrm{wall}_t + \sigma\varepsilon_t$ where $\mathrm{wall}_t$ is deterministic given $y_t$. So the oracle distributions under $s = \pm$ differ ONLY in the constant $\alpha_s$. KL of two Rademacher-shifted: $\mathrm{KL}(\mathrm{Unif}_{\pm 1} + a \| \mathrm{Unif}_{\pm 1} + b) \le 2(a-b)^2/(\text{variance})$ — for sub-Gaussian or shifted Rademacher with discrete support... wait, the Rademacher noise has discrete support, so the shifted distributions $\sigma\{\pm 1\} + \alpha_+$ vs $\sigma\{\pm 1\} + \alpha_-$ have different SUPPORT entirely (atoms at $\sigma + \alpha_\pm$ and $-\sigma + \alpha_\pm$).

Hmm — discrete distributions with disjoint supports have INFINITE KL!

So the KL chain is problematic for Rademacher.

**This is the bug.** The standard Le Cam analysis requires Gaussian (or other absolutely-continuous) noise so that $P_+$ and $P_-$ have the same support. Rademacher gives a degenerate KL.

In OP-2, the per-step "8α²/σ²" KL bound is informally citing the GAUSSIAN approximation. It's standard in the NY/ABRW literature to use Gaussian noise for these arguments.

**Let me redo the analysis with Gaussian noise.**

## With Gaussian noise

Replace $\xi_t \sim \sigma \cdot \mathrm{Rademacher}$ with $\xi_t \sim \mathcal{N}(0, \sigma^2)$. Then KL($\mathcal{N}(\alpha_+, \sigma^2)$ || $\mathcal{N}(\alpha_-, \sigma^2)$) = $(\alpha_+ - \alpha_-)^2/(2\sigma^2) = (2\alpha)^2/(2\sigma^2) = 2\alpha^2/\sigma^2$ where $|\alpha| = \sigma/(2\sqrt{2T})$.

Per-step KL: $2\alpha^2/\sigma^2 = 2 \cdot \sigma^2/(8T)/\sigma^2 = 1/(4T)$.
Over $T$ steps: $T \cdot 1/(4T) = 1/4$.
Pinsker: TV $\le \sqrt{1/8} = 1/(2\sqrt 2) \approx 0.354$.

So $\Pr[\hat s \ne s] \ge (1 - 1/(2\sqrt 2))/2 \approx 0.323$.

Gap on misidentification: $\ge \alpha \cdot D/\sqrt 2 = \sigma D/(4\sqrt T)$.

So $\max_s \mathbb{E}_s[\min_t g_y - \min g_y] \ge 0.323 \cdot \sigma D/(4\sqrt T) = \sigma D/(12.4 \sqrt T)$.

Constant $c'_\mathrm{best} \approx 0.0807$, slightly weaker than OP-2's quoted $1/(8\sqrt 2) \approx 0.0884$ but in the same ballpark.

**Need to verify with Gaussian noise simulation.**

Actually wait — even with Gaussian noise, the simulation could fail if my Le Cam reasoning has another bug. Let me think again.

Le Cam: $\Pr_+[\hat s \ne +] + \Pr_-[\hat s \ne -] \ge 1 - \mathrm{TV}(P_+^T, P_-^T)$. So sum of error probabilities is $\ge 1 - \mathrm{TV}$. So $\max_s \Pr_s[\hat s \ne s] \ge (1 - \mathrm{TV})/2$.

For the test $\hat s = -\mathrm{sign}(y_{t^*})$: when $\hat s \ne s$, we're in the misclassification event. Conditional on this: $\mathrm{sign}(y_{t^*}) = s$. Since $y^\star_s = -s \cdot (D/\sqrt 2 + |\alpha|/L)$, $y_{t^*}$ on same side as $s$ means $y_{t^*}$ is OPPOSITE side from $y^\star_s$. So $|y_{t^*} - y^\star_s| \ge D/\sqrt 2 + |\alpha|/L$ at least, AND $y_{t^*}$ is in "good" side from gradient direction perspective.

For $g_y$ gap when $y_{t^*}$ on wrong side (gradient pulls TOWARD optimum which is on OTHER side):
- If $s = +$: $\alpha_+ > 0$, $y^\star = -(D/\sqrt 2 + \alpha/L) < 0$, $y_{t^*} > 0$. Gap = $g_y(y_{t^*}) - \min g_y$.
  - If $y_{t^*} \le D/\sqrt 2$: gap = $\alpha_+ y_{t^*} - (-\alpha_+ D/\sqrt 2 - \alpha_+^2/(2L)) = \alpha_+(y_{t^*} + D/\sqrt 2) + \alpha_+^2/(2L) \ge \alpha_+ D/\sqrt 2 = \sigma D/(4\sqrt T)$. ✓
  - If $y_{t^*} > D/\sqrt 2$: gap is larger. ✓

So gap $\ge \sigma D/(4\sqrt T)$ on misidentification. By Markov-style:
$\mathbb{E}_s[\mathrm{gap}] \ge \Pr_s[\mathrm{misid}] \cdot \sigma D/(4\sqrt T) \ge ?$

Hmm, but we have $\max_s \Pr_s[\mathrm{misid}] \ge (1-\mathrm{TV})/2$, so $\max_s \mathbb{E}_s[\mathrm{gap}] \ge (1-\mathrm{TV})/2 \cdot \sigma D/(4\sqrt T)$. ✓

This is correct logic. The simulation must be running with Rademacher (which I noted is invalid). Let me re-run with Gaussian.

## Revised plan

Switch the noise to Gaussian. This is allowed by problem.md (just need $\mathbb{E}\xi = 0$, $\mathbb{E}\|\xi\|^2 \le \sigma^2$). Then re-run simulation. If Gaussian simulation passes, Le Cam argument is rescued.
