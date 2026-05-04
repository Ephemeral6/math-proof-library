# Direction 2 — Rate-optimal step-size schedule

**Verdict: FEASIBLE — moderately well-precedented in the literature; would require ~2 weeks of focused work.**

**Effort:** Medium (2–3 weeks; would need adapting Liu–Zhou 2024 SGD analysis to SHB via the change-of-variables trick).

## Question

If we relax the "fixed $\eta$" assumption to allow **decaying $\eta_t$** (with fixed $\beta$), can SHB achieve last-iterate rate $O(LD^2/T + \sigma D/\sqrt T)$ matching OP-2's LB?

## Literature scan (verified via `WebSearch`/`WebFetch`)

| Paper | Setting | Algorithm | Rate |
|---|---|---|---|
| Liu, Zhou 2024 (ICLR) [arXiv:2312.08531](https://arxiv.org/abs/2312.08531) | smooth convex non-SC | **SGD** (no momentum), decaying $\eta_t$ | $O(L/T + \sigma/\sqrt T)$ last iterate; explicitly **excludes** momentum |
| Sebbouh, Gower, Defazio 2021 (COLT) [arXiv:2006.07867](https://arxiv.org/abs/2006.07867) | smooth convex non-SC | SHB with **time-varying** $\eta_t$ AND $\beta_t$ | $o(1/\sqrt k)$ almost surely; specific decay rates required |
| Li, Liu, Orabona 2022 (ALT) [arXiv:2102.07002](https://arxiv.org/abs/2102.07002) | Lipschitz convex (NOT smooth) | SGDM with constant $\beta$ + decaying $\eta_t$ | $\Omega(\log T/\sqrt T)$ — provably **suboptimal** |
| arXiv:2507.07281 (2025) | smooth convex / Hölder | SHB | "first high-prob result for SHB"; details unclear |

**Critical literature gap:** No paper explicitly proves a fixed-$\beta$, decaying-$\eta_t$, last-iterate UB for SHB on $L$-smooth convex non-SC matching $O(LD^2/T + \sigma D/\sqrt T)$. The closest are:
- Liu–Zhou 2024: handles SGD (no momentum); explicitly disclaims momentum.
- Sebbouh et al. 2021: handles SHB but requires *both* $\eta_t$ AND $\beta_t$ to be time-varying; not fixed momentum.
- Li-Liu-Orabona 2022: shows constant-momentum SGDM is *suboptimal* by $\log T$ on Lipschitz convex.

## Heuristic derivation

The most promising approach uses the **change-of-variables identity** $z_t = x_t + a(x_t - x_{t-1})$ with $a = \beta/(1-\beta)$, which gives EXACTLY (verified by SymPy in `gap2_verify.py` S4):
$$z_{t+1} - z_t \;=\; -\frac{\eta_t}{1-\beta}\, g_t \;=\; -\eta_{\text{eff}, t}\, g_t.$$
This is OGD on $z_t$ with effective stepsize $\eta_{\text{eff}, t} = \eta_t/(1-\beta)$. Apply Liu–Zhou's last-iterate analysis to $z_t$:
$$\mathbb E[f(z_T) - f^\star] \;\le\; O\!\left(\frac{LD_z^2}{T} + \frac{\sigma D_z}{\sqrt T}\right).$$

Then bridge from $z_T$ back to $x_T$. The bridge involves controlling $\|x_T - z_T\|^2 = a^2 \eta_T^2 \|m_T\|^2$. With $\eta_T \to 0$ (e.g., $\eta_T = c/\sqrt T$), the velocity $\|m_T\|^2$ stays bounded (via the Abel-summation argument in `gap2_proof.md` Lemma 2), so $\|x_T - z_T\|^2 \to 0$ and $f(x_T) \to f(z_T)$. Combining, last-iterate rate of $x_T$ matches that of $z_T$ up to vanishing terms.

**Caveat on the bridge:** the noise term in $z_T$ uses $\eta_{\text{eff}, t}$, but the bias term uses $\eta_t$ — there's a $1/(1-\beta)$ amplification in the variance. So the rate is
$$\mathbb E[f(x_T) - f^\star] \;\le\; O\!\left(\frac{LD^2}{T(1-\beta)} + \frac{\sigma D}{(1-\beta)\sqrt T}\right),$$
matching OP-2's LB **in rate** but with a $1/(1-\beta)$ blow-up at high momentum.

## Open issues for a peer-review-quality proof

1. **Liu–Zhou explicitly excludes momentum** (per their Section 1: "we only focus on algorithms without momentum or averaging"). Adapting their Lyapunov requires re-doing the suffix-averaging argument with the velocity recursion's $\beta$-weighted accumulation; non-trivial but not insurmountable.
2. **Constants** in the bridge are loose: $a^2 = \beta^2/(1-\beta)^2$ blows up as $\beta \to 1$. Achieving a constants-tight rate may require a different analysis (e.g., direct Lyapunov on $(x_t, m_t)$).
3. **Order of quantifiers**: the rate holds **per fixed $\beta$**, with $\eta_t$ decaying in $t$. This is *not* the strict $\sup_f \inf_\eta$ tightness Li Xiao initially asked about — but it's **closer to practice** (real implementations decay $\eta$).

## Recommendation

**MEDIUM PRIORITY.** Worth pursuing if the goal is "publication in MP/SIOPT". The proof is feasible, the result is interpretable ("for fixed $\beta$, decaying $\eta_t$ matches OP-2's rate"), and it would close the gap Li Xiao identified IN THE PRACTICAL SETTING.

The existing `direction_2 §5` Theorem D (projected SHB with horizon-tuned $\eta$, up to $\sqrt{\log T}$) is already a partial version of this result; extending to unprojected with decaying $\eta_t$ is the natural next step.
