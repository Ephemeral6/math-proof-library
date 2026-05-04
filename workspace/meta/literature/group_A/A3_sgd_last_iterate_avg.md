# A3: SGD Last-Iterate — Averaged-Iterate Baseline (Koren-Segal context)

**Proof path**: `proofs/research/optimization/convergence/sgd-last-iterate-averaged-baseline/`
**Claimed source**: Koren & Segal COLT 2020 open problem (this is the AVERAGED baseline, NOT the open-problem last iterate)
**Verdict**: **CONFIRMED** (textbook averaged-iterate; not addressing the open problem)

## Our claim
SGD on convex $G$-Lipschitz $f$ over interval $W=[a,b]$, $\eta = D/(G\sqrt T)$:
$$\mathbb{E}[f(\bar x_T) - f^*] \le \frac{DG}{\sqrt T}.$$

## Cross-check
This is the **Nemirovski–Yudin / Zinkevich** averaged-iterate $O(1/\sqrt T)$ rate for stochastic projected subgradient descent — proven in every textbook (Bubeck "Convex Opt: Algorithms and Complexity" Theorem 6.1; Hazan "OCO" Theorem 3.1). The constant $DG/\sqrt T$ (no log factor) is achieved exactly with constant step $\eta = D/(G\sqrt T)$.

The **Koren-Segal 2020 open problem** asked about the *literal* last iterate $x_T$ — whether the standard analysis's $\log T$ gap (best upper bound $O(\log T/\sqrt T)$, lower bound $\Omega(1/\sqrt T)$) can be closed. **Our proof does not address this open problem** — the document is clear about this. (The open problem was effectively resolved by Jain–Nagaraj–Netrapalli 2019 and refined by Harvey-Liang-Liaw-Randhawa 2019 / Liu-Zhou 2024.)

## Comparison
- **Assumptions**: match (1D, convex, $G$-Lipschitz, bounded domain).
- **Constants**: match the standard $DG/\sqrt T$ exactly.
- **Scope**: averaged iterate — explicitly NOT the open problem. Honest restatement is correct.
- **Technique**: standard projection-non-expansion + martingale + Jensen.

## Verdict
**CONFIRMED**. C-class textbook baseline. The honesty about not solving the open problem is appropriate. No novelty.
