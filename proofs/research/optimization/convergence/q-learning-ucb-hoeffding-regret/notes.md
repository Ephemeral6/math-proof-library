# Notes: UCB-Hoeffding Q-Learning Regret (Jin–Allen Zhu–Bubeck–Jordan 2018)

## Proof technique

**Winning route**: Route A — "JABJ book" backward-induction proof interleaved with Azuma-Hoeffding concentration.

The core technical device is the **visit-count exchange** in the recursion for $R_h := \sum_k \phi_h^k(s_h^k, a_h^k)$:
$$R_h \;\le\; SAH + (1 + 1/H)\, R_{h+1} + B_h,$$
where the $(1+1/H)$ coefficient (rather than $H$) comes from identity (L4): $\sum_{t\ge i}^\infty \alpha_t^i \le 1 + 1/H$ — the sum of learning-rate "weights" accumulated across ALL future visits of a fixed cell, evaluated at the $i$-th visit. Unrolled over $H$ horizon levels, this gives $R_1 \le eH\cdot(\cdot)$ instead of $H^H\cdot(\cdot)$ — a factor-of-$H$ savings that is the difference between $\sqrt{H^4 SAT}$ (JABJ) and $\sqrt{H^6 SAT}$ (Route B's strict martingale-first).

The bonus must be $b_t = cH^{3/2}\sqrt{\iota/t}$ (i.e. $c\sqrt{H^3\iota/t}$) — the original Q-learning bonus analog for bandits would be $c\sqrt{\iota/t}$ with constant $H$, but RL needs one extra $\sqrt H$ factor because the martingale noise at each horizon level sees bounded increments $|\cdot|\le H$ rather than $|\cdot|\le 1$. The weighted-Azuma variance is $\sum_i (\alpha_t^i)^2 \cdot H^2 \le 2H^3/t$ (using $\sum(\alpha_t^i)^2 \le 2H/t$, which crucially scales like $H$ not $1$), giving deviation $\sim H^{3/2}\sqrt{\iota/t}$.

## Key steps

1. **Learning-rate identities** on $\alpha_t^i = \alpha_i \prod_{j=i+1}^t(1-\alpha_j)$ with $\alpha_t = (H+1)/(H+t)$:
   - (L1) $\sum_i \alpha_t^i = 1$ for $t\ge 1$; $\alpha_t^0 = \mathbb 1[t=0]$.
   - (L2) $1/\sqrt t \le \sum_i \alpha_t^i/\sqrt i \le 2/\sqrt t$ — proved by induction on $t$.
   - (L2') $\sum_i (\alpha_t^i)^2 \le 2H/t$ — via monotonicity of $\alpha_t^i$ in $i$ plus (L1).
   - (L4) $\sum_{t\ge i}^\infty \alpha_t^i \le 1 + 1/H$ — the load-bearing identity for the visit-exchange.

2. **Recursive Q-error expansion** (Lemma A): $Q_h^{k+1}(s,a) = \alpha_t^0 H + \sum_{i=1}^t \alpha_t^i[r + V_{h+1}^{k_i}(s_{h+1}^{k_i}) + b_i]$, derived by direct unrolling.

3. **Optimism + upper bound** (Lemma B) by backward induction on $h$: on the high-probability Azuma event, $Q_h^k(s,a) \ge Q_h^*(s,a)$ and $\phi_h^k(s,a) \le \alpha_t^0 H + \sum \alpha_t^i \phi_{h+1}^{k_i}(\cdot,\cdot) + \beta_t$ where $\beta_t := 2\sum \alpha_t^i b_i = O(H^{3/2}\sqrt{\iota/t})$.

4. **Visit-count exchange**: rearrange $\sum_k \sum_{i=1}^{n_h^k-1} \alpha_{n_h^k - 1}^i X_i = \sum_j X_j \cdot (\sum_{\text{later visits } k} \alpha_{n_h^k - 1}^j) \le (1+1/H)\sum_j X_j$ by (L4). This is the key trick.

5. **Bonus sum** (Lemma D): $\sum_h B_h \le 24\sqrt{H^3 \iota SAK}$ by Cauchy-Schwarz and $\sum_{t=1}^N \beta_t \le O(H^{3/2}\sqrt{\iota N})$.

6. **Horizon unroll** (Lemma E): $R_1 \le (1+1/H)^{H-1}[SAH^2 + B_H + \dots + B_1] \le e \cdot [SAH^2 + 24\sqrt{H^3 \iota SAK}]$. Multiplying by the $\delta_{h+1}^k$ recursion factor in Lemma C adds one more $H$, giving $\mathrm{Regret}(K) \le 70\sqrt{H^4 SAT \iota^2}$.

## Audit result

PASS after 1 Fix round. Round 1: all 9 main steps + 5 sublemmas VALID, 11 numerical check families passed (all learning-rate identities at $H\in\{1,2,5,10\}$, $t\in\{1,10,100\}$; sanity simulation $S=A=2, H=3, K=100$ gave empirical regret $97.24$ vs. theoretical bound $\sim 2\times 10^5$, ratio $\sim 5\times 10^{-4}$), 1 MEDIUM issue (union-bound arithmetic needed a $K^2$ in the definition of $\iota$, does not change $C=70$) + 4 LOW. Round 2 (post-fix): all 5 issues verified fixed, no new errors, $C=70$ unchanged. Conclusion: PASS.

## Important problem-statement corrections (caught mid-workflow)

Two bugs in the originally-stated problem.md, both caught by independent convergence of multiple routes:

1. **Bonus scale**: Originally wrote $b_t = cH\sqrt{\iota/t}$; JABJ 2018 uses $b_t = c\sqrt{H^3\iota/t} = cH^{3/2}\sqrt{\iota/t}$. Routes B and C both independently derived that the weaker bonus cannot achieve the $\sqrt{H^4}$ rate. Amended.

2. **Identity (L2')**: Originally listed (L2') implicitly as $\sum(\alpha_t^i)^2 \le 2/t$; the correct statement is $\le 2H/t$ (both numerics and the Azuma calculation require the $H$ factor). This was the source of the bonus-scale bug.

Same pattern as Problem 3 (ADMM) — multiple independent routes *converging on the same flaw* is a strong detection signal for problem-statement errors that would pass a single-route sanity check.

## Related results

- **Synchronous Q-learning finite-time** (`proofs/research/optimization/convergence/synchronous-q-learning-finite-time/`): same $\alpha_t^i$ machinery but generative model (not online); no regret, gives $L_\infty$ sample complexity.
- **OFUL linear bandit regret** (`proofs/research/learning-theory/generalization/oful-linear-bandit-regret/`): tabular structural analog. Here SA cells play the role of $d$ dimensions; $1/\sqrt{n_h^k}$ plays the role of $\|\phi\|_{\Lambda^{-1}}$. The visit-exchange trick is the Q-learning analog of the elliptical potential lemma.
- **EXP3 adversarial bandit regret** (`proofs/research/learning-theory/generalization/exp3-adversarial-bandit-regret/`): $H=1$ adversarial analog.
- **TD(0) linear approximation O(1/T) rate** (`proofs/research/optimization/convergence/td0-linear-approximation-convergence/`): same Bellman-evaluation structure but linear function approximation.
- **UCB1 stochastic bandit regret** (library, if exists): $H=1$ stochastic analog.

## Route outcomes (for learning)

- Route A (JABJ book proof with interleaved Azuma + visit-exchange): **selected**, 27/40. The interleaving and visit-exchange are both load-bearing.
- Route B (martingale-first, global Azuma event before any deterministic analysis): **suboptimal**, 20/40 (ELIGIBLE_WITH_GAP). Achieves $\sqrt{H^6 SAT}$ — loses one factor of $H$ because strictly separating concentration from deterministic analysis forces a $\sum_h$ over the per-level recursion without the visit-exchange $(1+1/H)^H \le e$ savings.
- Route C (advantage decomposition): **suboptimal**, 20/40. Achieves $\sqrt{H^5 SAT}$ — reduces to Route A modulo renaming ($\delta_h^k$ vs. $\phi_h^k + A_h^{\pi_k,*}$), but the route framing does not provide a native path to the visit-exchange step. Honestly disclosed as reducing to Route A.
- Route D (online learning / expert reduction): **structural failure**, 19/40 (INELIGIBLE). Online-to-batch requires convexity; Bellman's nested $\max$ is non-convex. Partial positive result for $H=1$ (tabular bandits), fails for $H \ge 2$. Instructive — confirms the AdaGrad-Norm Route 4 failure pattern extends to RL.

## Two-parallel-routes meta-payoff

As with Problem 3 (ADMM), the 4-parallel-routes approach caught a flaw in problem.md that a single route might have missed. Routes B and C independently flagged "the bonus in problem.md is too small by a factor of $\sqrt H$", providing strong evidence to amend before the template Route A ran. Route A then completed successfully on the amended problem. Single-route runs of the original problem.md would have silently produced an incorrect bound or gotten stuck.

Similarly, the independence of Route D (structural failure) from the Route A success is a meaningful output: it documents *why* RL regret is genuinely harder than bandit regret — the nested $\max$ in Bellman is the technical reason.
