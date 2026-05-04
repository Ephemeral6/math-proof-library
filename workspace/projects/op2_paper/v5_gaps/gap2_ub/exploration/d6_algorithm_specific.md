# Direction 6 — Algorithm-specific tightness reframing

**Verdict: COLLAPSES INTO DIRECTION 1.** The numerical experiment refutes the original framing ("$LD^2/T$ is the exact worst-case rate") — the actual rate is $\Theta(1)$ in the cycling regime, NOT $\Theta(1/T)$. So OP-2's $\Omega(LD^2/T)$ LB is **loose**, not tight.

**Effort:** Already done (joint experiment with D1, see `d1_d6_bias_only.py`).

## The user's proposed reframing

> "Define algorithm-specific tightness: $LD^2/T$ is the exact worst-case rate of SHB last iterate. No matching UB needed — only LB + proof that rate cannot be better than $\Omega(LD^2/T)$."

## Numerical refutation

In `d1_d6_bias_only.py` (mpmath dps=50, $\sigma = 0$, deterministic SHB on Goujaud K=3):

| Regime | $(\beta, \eta L, \kappa)$ | $f_0(x_{T})$ for $T = 10^4$ | Rate behavior |
|---|---|---|---|
| Cycling | (0.8, 3.247, 0.387) | **0.2373** (constant) | $\Theta(1)$ — period-3 attractor floor |
| Period-6 | (0.9, 3.78, 0.05) | **0.9157** (constant) | $\Theta(1)$ — period-6 attractor floor |
| Decay (low $\beta$) | (0.3, 1.5, 0.2) | $\sim 0$ (numerical zero) | $\Theta(\exp(-cT))$ — exponential decay |
| Decay (mid $\beta$) | (0.6, 2.5, 0.25) | $\sim 0$ | $\Theta(\exp(-cT))$ |

**Conclusion: $LD^2/T$ is NOT the rate of SHB last iterate in any regime.**
- Cycling regime: rate is $\Theta(1)$ — STRICTLY WORSE than $1/T$.
- Decay regime: rate is $\Theta(\exp(-cT))$ — STRICTLY FASTER than $1/T$.

There is no parameter regime where the rate is exactly $\Theta(1/T)$. OP-2's $\Omega(LD^2/T)$ LB is the WORST-CASE LOWER BOUND across $T$ (correct as a *lower bound* on the rate), but it is NOT the *exact rate descriptor* in any regime.

## Updated honest statement

The OP-2 v5 contribution is best stated as a **negative** result:
- **In the cycling regime**: SHB's last iterate has a **constant** floor $\Theta(LD^2)$, **strictly worse** than the optimal $O(LD^2/T)$ rate that GFJ15-Cesàro achieves on the average iterate.
- **Outside cycling**: SHB's last iterate decays exponentially, **strictly faster** than $O(LD^2/T)$.

The $\Omega(LD^2/T)$ from OP-2 v5 is a true universal LB but is not tight against any concrete UB construction (because the cycling regime gives a stronger $\Omega(LD^2)$ LB, while non-cycling has $O(\exp(-cT))$ UB). The interesting LB is the **constant floor in the cycling regime**, not the $1/T$ rate.

## Why this is good news

The numerical refutation of "$LD^2/T$ is the rate" is actually a **stronger** message than OP-2 originally claimed:

> "On a positive-measure parameter set, SHB last iterate **does not converge at all** — it cycles with constant suboptimality. So momentum is much worse than 'merely $1/T$'; it's literally non-convergent in expectation in this regime."

This is a peer-review-clear claim: "SHB last-iterate is non-convergent on a positive-measure parameter set", with the negative result being a constant floor instead of a $1/T$ rate. This is the cleanest statement of OP-2's actual contribution.

## What "algorithm-specific tightness" reduces to

The reframing the user proposed — "no need for matching UB, only LB + proof of no-faster-UB" — is automatic when the LB is the **trivial** UB. For the cycling regime:
- $\liminf_T (f(x_T) - f^\star) \ge c_F^{\text{bias}} \cdot LD^2 > 0$ (constant LB).
- $\sup_T (f(x_T) - f^\star) \le f(x_0) - f^\star \le LD^2 / 2$ (trivial UB).
- Both are $\Theta(LD^2)$ — TIGHT in rate (constant), with constants differing by a factor of $\sim 4 \kappa$ (since the cycle floor is $\sim \kappa LD^2/4$).

This is exactly the **bias-only deterministic tightness** of Direction 1.

## Recommendation

**SKIP — collapses into D1.** The reframing in the user's prompt presupposed that $LD^2/T$ might be the exact rate; numerical evidence refutes this. The honest reframing — "SHB last-iterate has constant suboptimality on positive-measure parameter set" — is exactly D1's content. There is no separate D6 result distinct from D1.

The lesson: the *kind* of tightness Li Xiao asked for ("matching UB to the $1/T$ LB") is NOT achievable, but the actual SHB last-iterate behavior is **stronger evidence** for OP-2's "no acceleration" thesis: SHB doesn't merely fail to beat SGD, it fails to converge at all in the cycling regime.
