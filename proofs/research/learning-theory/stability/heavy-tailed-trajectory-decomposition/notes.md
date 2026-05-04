# Notes: Heavy-Tailed Trajectory Decomposition

## Proof technique
Combined three ingredients:
1. **Heavy-tailed leave-one-out stability** (Route 1): E ||Delta_T||^p recursion with swap probability 1/m, using convexity-based non-expansive lemma; gives the 1/m factor and the signal accumulation T^{p-1}.
2. **One-sided Marcinkiewicz–Zygmund / Burkholder for p in (1,2)** (Route 2): E ||sum martingale-diffs||^p <= C_p sum E ||diff||^p, the sub-additivity of x -> x^{p/2} that replaces the variance-based BDG when only p-th moments exist.
3. **Truncation bias-variance balance** (Route 3): standard L^p tail-truncation with bias = G^p/tau^{p-1} and truncated variance = G^p tau^{2-p}, optimized via calculus-1.

## Key steps
- The signal/noise split is at the level of the gradient difference (g_t - g_t') = (signal: grad L_S diff) + (noise: empirical residuals); the signal is non-expansive under convexity (Hardt–Recht–Singer 2016 Lemma 3.7), so the only signal contribution is at the swap event.
- The Burkholder constant for p in (1,2) is finite and depends only on p — this is the technical heart of why the proof works for sub-Gaussian-free heavy tails.
- The clipping calculation gives **un-averaged tau = G T^{1/p}**; averaging contracts the noise by 1/sqrt(T), shifting to **averaged tau = G T^{1/p - 1/2}**.
- Resulting rate G T^{1-1/p}/sqrt(m) requires the consistent step-size schedule eta = c_p T^{(p-2)/(2p)} m^{(2-p)/(2p)}.

## Audit result
- 1 round, no fixer needed.
- SymPy verified the rate algebra (audit_sympy.py and v2).
- NumPy simulation: m-slope = -0.472 (predicted -0.5), upper bound holds with empirical/predicted ratios in [0.06, 0.29].

## Honest limitations
1. The clipping threshold tau = G T^{1/p - 1/2} is for the **averaged** (Polyak-Ruppert) iterate; un-averaged last iterate has tau = G T^{1/p}.
2. Constants C_p, C_p' depend on p and blow up as p -> 1 (consistent with Burkholder constant divergence).
3. Matching minimax lower bound (asserting tau is "optimal") is cited (Wang–Mao 2021, Vural et al. 2022) — not proved here.
4. Convexity is used essentially; non-convex case requires different (PAC-Bayes / expansive) tools.

## Related results
- **Standard signal-noise decomposition** (proofs/research/learning-theory/stability/sgd-signal-noise-generalization-decomposition): the p=2 limiting case.
- **Uniform stability (Hardt–Recht–Singer 2016)** (proofs/research/learning-theory/stability/sgd-uniform-stability-generalization): the convexity-based skeleton used here.
- **Adversarial trajectory tradeoff** (proofs/research/learning-theory/stability/adversarial-trajectory-tradeoff): related but different perturbation analysis.
- **Heavy-tailed minimax SGD** (Wang–Mao 2021, Vural et al. 2022): the matching minimax lower bound.

## Connections
- The exponent T^{(p-2)/2} < 0 in G_N^{(p)} reflects the same phenomenon as in heavy-tailed mean estimation (median-of-means bound: O(sigma_p (log(1/delta)/n)^{1-1/p}) vs sub-Gaussian O(sigma sqrt(log(1/delta)/n))).
- The clipping threshold tau = G T^{1/p - 1/2} is the heavy-tail analogue of the standard SGD step size sqrt(1/T): both are designed to balance the deterministic optimization rate against the stochastic noise.
- Marcinkiewicz–Zygmund for p in (1,2) is a key technical tool also appearing in heavy-tailed concentration (Brownlees–Joly–Lugosi 2015) and trimmed-mean estimators.
