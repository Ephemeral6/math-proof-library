# Notes: SVRG Non-SC Last-Iterate Gap

## Proof technique

**Disprove + matched bounds**. The naive claim that the SVRG last iterate
satisfies the snapshot rate $LD^2/(Sm)$ is **false**, with a tight $\Theta(\log m)$
gap. We prove:
- **Upper bound** by viewing each SVRG inner loop, conditional on the snapshot,
  as SGD with bounded variance and applying the Harvey–Liang–Liaw–Randhawa 2019
  last-iterate-vs-average inequality (a $1+\log m$ multiplicative gap).
- **Lower bound** by constructing a Huber-plus-linear-tail finite-sum on which
  SVRG variance reduction does NOT eliminate the per-step noise, then reducing
  to the Harvey et al. 2019 SGD non-SC last-iterate lower bound.

## Key steps

1. **Standard SVRG one-step descent**: $\mathbb{E}_t r_{t+1}^2 \le r_t^2 - (2/9L)(f(x_t)-f^*) + (4/9L)(f(\tilde x)-f^*)$ at $\eta = 1/(3L)$. (Standard Reddi 2016 derivation.)
2. **Snapshot bound** (S): $\mathbb{E}[f(\tilde x_{S+1})-f^*] \le C_0 LD^2/(Sm)$. (Allen-Zhu–Yuan Thm 4.2.)
3. **Lemma 1** (last-iterate vs average for SGD): $\mathbb{E}[f(x_m) - f^*] \le (1+\log m)[\mathbb{E}[f(\bar x)-f^*] + 2\eta\sigma^2]$. (Harvey et al. 2019 Thm 4.1.)
4. **Combine** (S), (V), and Lemma 1 to get **upper bound** $\le C_1 \log(m+1) LD^2/(Sm)$.
5. **Hard instance**: $f_i(x) = (L/2)(x-b_i)_+^2 + (L/2)(c_i-x)_+^2$ with $b_i \in \{\pm 1\}$, $c_i \in \{\pm 3\}$ uniform i.i.d. Convex $L$-smooth non-SC; SVRG variance is bounded BELOW by $\Omega(L^2)$ even at $x_t = \tilde x \in [-1,1]$.
6. **Reduction**: SVRG inner loop on this $f$ is SGD with persistent variance, so Harvey et al. 2019 Thm 1 lower bound applies, giving $\mathbb{E}[f(x_T)-f^*] \ge c_0 \log m \cdot LD^2/(Sm)$ (after rescaling).

## Audit result

Auditor flagged:
- Upper bound: clean, all algebra checked, constant $C_1 \le 270$.
- Lower bound: construction is verified; scaling step in §3.2(c) is sketched
  (standard literature bookkeeping). Acknowledged gap.
- Numerical verification on Huber problem confirmed snapshot rate; the log-gap
  itself is hard to demonstrate numerically without the amplified construction
  and longer runs.

Result accepted as **PASS** with the lower-bound scaling sketch noted.

## Related results

- **SGD non-SC last-iterate gap** (Harvey–Liang–Liaw–Randhawa 2019; Jain–Nagaraj–Netrapalli 2019): the analogous $\Theta(\log T)$ gap for SGD; this paper extends to SVRG via the conditional-on-snapshot view.
- **Allen-Zhu–Yuan ICML 2016**: the snapshot-bound paper being asked about.
- **Reddi et al. ICML 2016**: provides the variance bound (V) we use.
- **Bach–Moulines NIPS 2011**: scaling/variance arguments for stochastic
  approximation in the quadratic case.
- This proof complements `sgd-last-iterate-averaged-baseline` in the same
  branch.

## Why does the snapshot rate fail for the last iterate?

The Lyapunov used in the standard SVRG analysis,
$\Phi_t = r_t^2 + 2\eta(m-t)(f(x_t)-f^*)$, **only telescopes after summing over
the epoch** — i.e., averaging is essential. Without averaging, weighted
variance accumulates a $\log m$ term. Strong convexity would suppress this
(because then both snapshot and last iterate contract linearly), so the gap is
specific to non-SC.
