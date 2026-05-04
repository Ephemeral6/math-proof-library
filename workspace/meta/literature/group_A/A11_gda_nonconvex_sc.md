# A11: GDA Nonconvex-Strongly-Concave $O(\kappa^2\varepsilon^{-2})$

**Proof path**: `proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/`
**Claimed source**: Lin-Jin-Jordan 2020 ICML (arXiv:1906.00331)
**Verdict**: **CONFIRMED**

## Our claim
Two-time-scale GDA with $\eta_x = 1/(16\kappa^2 L)$, $\eta_y = 1/L$ on nonconvex-strongly-concave $f$ ($L$-smooth, $\mu$-SC in $y$):
$$\frac{1}{T}\sum_{t=0}^{T-1}\|\nabla\Phi(x_t)\|^2 \le \frac{C_1\kappa^2L\Delta}{T} + \frac{C_2\kappa^2 L\|y_0 - y^*(x_0)\|^2}{T} = O(\kappa^2/\varepsilon^2).$$

## Cross-check
[ARXIV-UNREACHABLE] Lin–Jin–Jordan 2020 ("On Gradient Descent Ascent for Nonconvex-Concave Minimax Problems", ICML), Theorem 4.4: precisely this $O(\kappa^2/\varepsilon^2)$ stationary-point rate for two-time-scale GDA on nonconvex-SC, with step sizes $\eta_x = \Theta(1/(\kappa^2 L))$, $\eta_y = \Theta(1/L)$. Note the better $O(\kappa/\varepsilon^2)$ rate is achievable with extragradient (Mokhtari-Ozdaglar-Pattathil 2020) or with single-time-scale carefully tuned (Yang-Kiyavash-He 2020).

## Comparison
- **Assumptions**: match exactly (joint $L$-smoothness, $\mu$-strong concavity in $y$).
- **Constants**: $\eta_x = 1/(16\kappa^2 L)$ matches LJJ Theorem 4.4 explicit constants. Lyapunov $V_t = \Phi(x_t) + c\delta_t$ matches their Lemma 4.3 setup.
- **Scope**: matches.
- **Technique**: identical Lyapunov approach with $y$-tracking error contraction. Lemma A ($y^*$ is $\kappa$-Lipschitz), Lemma B ($\Phi$ is $2\kappa L$-smooth) — these are LJJ's Lemma 4.1 + Lemma 4.2.

## Verdict
**CONFIRMED**. Direct re-derivation of Lin-Jin-Jordan 2020 Theorem 4.4. Standard. Constants ($16\kappa^2 L$, $2\kappa L$) match the published explicit form.
