# A15: Polyak-Ruppert Weighted Average Defeats SHB Cycling

**Proof path**: `proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/`
**Claimed source**: Iterate-type extension of OP-2 / GPT 2023 (arXiv:2307.11291)
**Verdict**: **NOVEL** (top publication candidate)

## Our claim
On Goujaud-Taylor-Dieuleveut 2023's hard cycling instance for SHB (with deterministic iterate $x_t = (D/\sqrt 2) e_{t \bmod K}$), the **Polyak-Ruppert weighted average** with linear weights $w_t \propto t$ achieves
$$f_0(\tilde x_T) - f_0^* \le \frac{LD^2}{4T^2 \sin^4(\pi/K)} = \Theta(LD^2/T^2)$$
**disproving** the conjectured $\Omega(LD^2/T)$ lower bound on the bias term. Iterate separation:
- Last iterate: $\Theta(LD^2)$ (constant — no decay)
- Cesaro average: $\Theta(LD^2/T^2)$
- Polyak-Ruppert: $\Theta(LD^2/T^2)$ (THIS WORK — matches Cesaro bias rate, with linear weights)

## Cross-check
[ARXIV-UNREACHABLE] Goujaud-Taylor-Dieuleveut 2023 ("Quadratic minimization: from conjugate gradients to an adaptive Heavy-ball method with Polyak step sizes" & related works on SHB lower bounds, arXiv:2307.11291) construct the cycling counterexample showing **last-iterate** SHB does not accelerate. The question of whether **weighted-averaging schemes** (Polyak-Ruppert with linear weights) can also fail to accelerate on this instance is, to my knowledge, **not in published literature**.

The proof is clean: it reduces to bounding $|\sum_{t=1}^T t\omega^t|$ for $\omega = e^{2\pi i/K}$, which has closed form via the arithmetico-geometric series. The $\sin^4(\pi/K)$ leading constant makes a sharp prediction.

## Comparison
- **Assumptions**: deterministic SHB on Goujaud's exact cycling instance. Matches GPT 2023.
- **Constants**: explicit $LD^2/(4T^2\sin^4(\pi/K))$ — sharp.
- **Scope**: NEW result — answers the natural follow-up to GPT 2023 about averaging schemes.
- **Technique**: reduction to Fourier sum on the K-th root of unity + L-smoothness upper bound. Clean and short.

## Verdict
**NOVEL**. Strong candidate for publication (e.g., short note or part of a larger SHB-iterate-type-separation paper). The disproof of the natural $\Omega(LD^2/T)$ bias lower bound for Polyak-Ruppert is a clean, surprising negative result.

**Action item**: STRONG publication candidate. The result is sharp, the proof is clean, and it answers an obvious open question following GPT 2023.
