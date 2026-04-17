# Notes: Catoni's PAC-Bayes Bound

## Proof technique

**Winning route**: Route 3 — Fubini-first + sub-Bernoulli MGF + Donsker-Varadhan.

The key structural insight is the **ordering of operations**:
1. Define an MGF-normalized scalar $W_S := \mathbb{E}_P[\exp(\phi_S(h))]$ *before* applying Donsker-Varadhan.
2. Bound $\mathbb{E}_S[W_S] \le 1$ via Tonelli + the MGF normalization.
3. Apply Markov to the scalar $W_S$ — the resulting good event $\{W_S \le 1/\delta\}$ is **$Q$-independent**, which is precisely what makes the final bound hold uniformly over all $Q$.
4. Apply Donsker-Varadhan on the good event with arbitrary $Q$.

This ordering cleanly separates the "sample randomness" (handled by Markov on a deterministic functional of $S$) from the "posterior choice" (handled by the variational formula afterwards). The alternative order — DV first then Markov — requires either union bounding or introducing $Q$-dependent events, which is messy.

The **critical algebraic identity** is
$$\lambda - n\psi(\lambda/n) = n(1 - e^{-\lambda/n}), \qquad \psi(u) := u - 1 + e^{-u}.$$
This is what allows solving the post-DV inequality for $R(Q)$ with a positive coefficient.

## Key steps

1. **Sub-Bernoulli MGF (Lemma 1)**: Convexity of $e^{-ux}$ on $[0,1]$ gives the chord bound $e^{-ux} \le 1 - x(1-e^{-u})$. Taking expectation: $\mathbb{E}[e^{-u\ell(h,Z)}] \le 1 - R(h)(1-e^{-u})$. The sub-lemma $\log(1-t) \le -t$ (via monotonicity) then gives
$$\mathbb{E}_S \exp(\lambda(R(h)-\hat R_S(h))) \le \exp(n R(h) \psi(\lambda/n)).$$

2. **MGF-normalized functional (Lemma 2)**: Setting $\phi_S(h) := \lambda(R(h)-\hat R_S(h)) - nR(h)\psi(\lambda/n)$ gives $\mathbb{E}_S[e^{\phi_S(h)}] \le 1$ per $h$.

3. **Fubini + Markov (Lemma 3)**: $W_S := \mathbb{E}_P[e^{\phi_S}]$ has $\mathbb{E}_S[W_S] \le 1$ by Tonelli; Markov gives $W_S \le 1/\delta$ w.p. $\ge 1-\delta$.

4. **Donsker-Varadhan (Lemma 4)**: $\mathbb{E}_Q[\phi] \le \log W_S + \mathrm{KL}(Q\|P)$ for any $Q \ll P$ on the good event.

5. **Rearrangement (Main)**: Solve for $R(Q)$ using $\lambda - n\psi(\lambda/n) = n(1-e^{-\lambda/n}) > 0$ for $\lambda > 0$.

## Audit result

**Round 1: PASS**. All algebraic identities verified:
- Chord bound $e^{-ux} \le 1-x(1-e^{-u})$ on $[0,1]$: convexity + endpoints
- Sub-lemma $\log(1-t) \le -t$ for $t \in [0,1)$
- Central identity $\lambda = n(1-e^{-\lambda/n}) + n\psi(\lambda/n)$
- Tonelli correctly invoked (non-negative integrand)
- Uniformity over $Q$ handled via $Q$-independent good event

No critical gaps. Minor stylistic notes (explicit $R(h) = 0$ case, re-emphasis of $\lambda > 0$) flagged as non-blocking.

## Related results

- **McAllester's PAC-Bayes bound** (`proofs/research/learning-theory/generalization/` — if archived): the $\sqrt{(\mathrm{KL}+\log(1/\delta))/(2n)}$ form. Route 2 of this proof produces McAllester's bound via Hoeffding instead of sub-Bernoulli MGF.
- **Donsker-Varadhan variational formula**: fundamental tool used throughout modern PAC-Bayes. The formula $\log\mathbb{E}_P[e^\phi] = \sup_Q\{\mathbb{E}_Q[\phi] - \mathrm{KL}(Q\|P)\}$ is the source of the "for all $Q$" uniformity.
- **Gibbs posterior optimality**: The Gibbs posterior $Q^* \propto e^{-\lambda\hat R_S}P$ minimizes the RHS of Catoni's bound, providing a principled posterior choice (see Alquier-Ridgway-Chopin 2016).

## Lessons learned (for future PAC-Bayes proofs)

1. **Order of operations matters for uniformity**: When proving "for all $Q$" bounds, the ordering (Fubini → Markov → DV) keeps the sample-randomness event $Q$-free. Reversing the order (DV → Markov) requires uniform control which loses the exact constant.

2. **Sub-Bernoulli MGF beats Hoeffding for interpolating rates**: The sub-Bernoulli cumulant $nR(h)\psi(\lambda/n)$ depends on $R(h)$, which gives the slow/fast rate interpolation when $R(h) \to 0$ (interpolation regime). Hoeffding's $\lambda^2/(8n)$ is the worst-case bound at $R(h) = 1/2$.

3. **The choice of $\lambda$ is free (but fixed before seeing data)**: Catoni's bound is a parametrized family; different $\lambda$ give different rates. Data-dependent $\lambda$ requires a union bound over a grid, losing a $\log\log n$ factor. The "fixed $\lambda$" restriction is not a weakness — it matches the intended use as a model selection tool.
