# Notes: SHB Polyak-Ruppert κ-Blow-Up on Strongly Convex Quadratics

## Proof technique

Compositional decomposition into three independent scalar lemmas:
- **L1 (Part A)**: Companion-matrix spectral radius $\sqrt\beta$ in the under-damped regime → $|x_T^{(\lambda)}| \le C_1\beta^{T/2}$ with explicit $C_1 = \sqrt{\eta\lambda}/|\sin\theta_\lambda|$ via fragment R5-A.
- **L2 (Part B)**: Closed-form arithmetico-geometric kernel $S_T(z) = \sum_{t=0}^{T-1}(t+1)z^t$ slot-filled from I5 (`polyak-ruppert-shb-defeats-cycling`); reverse-triangle / asymptotic-residue gives the LB $|\tilde x_{T,\lambda}| \ge 1/(8\eta\lambda T^2)$ for $T \ge T_0$, leveraging the Vieta identity $|1-z_\lambda|^2 = \eta\lambda$.
- **L3 (Part C)**: Composing on dominating coordinates ($L$ for $f(x_T)$, $\mu$ for $f(\tilde x_T)$) gives ratio LB; characterize crossover $T^\star$.

## Key steps

1. **Vieta identity**: $|1-z_\lambda|^2 = \eta\lambda$ derived directly from the SHB characteristic polynomial — this is the spectral identity that drives Part B.
2. **Direction-flip lemma** (cross-pollinated from Route 4): for $|z|<1$, $|S_T - S_\infty| \le [(T+1)+T\sqrt\beta]\beta^{T/2}/|1-z|^2$, giving a clean LB on $|S_T|$ via reverse triangle inequality (cross-pollinated from Route 2 fragment R2-A in the tightened form).
3. **Initialization constant**: $|A|^2 = \eta\lambda/(4\sin^2\theta_\lambda)$ (R5-A), strictly cleaner than the unsimplified expression and removing a spurious $1/\beta$ factor.
4. **Honest scope for the empirical κ^{2.94}**: in the machine-precision-floor regime (T ≥ 350 for β=0.9), $f(x_T) \to \varepsilon_{\rm mach}$ and the ratio's apparent exponent becomes $c \approx 2$ (because $f(\tilde x_T) \asymp \kappa^2/(η^2 L T^4)$ on the squared average). The residual ~0.94 to reach the empirical 2.94 is unmodeled round-off and explicitly NOT proven.
5. **Geometric mechanism** (R3-B): at $(\beta=0.9, \eta L=2.9, \kappa=100)$, $\theta_L \approx 121.8°$/step (rapid rotation → strong PR cancellation, small $|\tilde x_{T,L}|$) vs $\theta_\mu \approx 9.6°$/step (slow rotation → weak cancellation, large $|\tilde x_{T,\mu}|$).

## Audit result

PASS in 2 rounds. Round 1 found 6 ROUTINE issues (2 MED + 4 LOW); Fix Round 1 closed all 6 with `Net HIGH/STRUCTURAL delta = 0`; Round 2 verified closure and emitted F4 = FIXER-PROGRESS. Three sub-LOW cosmetic residuals (κ-ceiling rounding 1102.7 vs 1101.24, $T_0=39$ vs 5.0 looseness, stale $T^\star=140$) noted but left unfixed as documentation polish. All Lemmas L1, L2, L3 marked VALID.

## Related results

- **Companion / dual**: `proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/proof.md` (Problem I5) — proves PR averaging *defeats* SHB cycling on Goujaud's hard non-SC instance ($O(LD^2/T^2)$ where last iterate is stuck at $\Theta(1)$). Together, I5 + this work characterize PR averaging as a **double-edged sword**: it kills cycling bias on adversarial non-SC instances but amplifies condition-number dependence on benign SC quadratics.
- **OP-2 lineage**: `proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/` (parent), `shb-no-acceleration-best-iterate/` (sibling iterate-type extension), `shb-interpolation-regime-lb/` (sibling noise-model extension).
- **HBI**: `proofs/research/optimization/convergence/heavy-ball-instability/` — provides the companion-matrix spectral analysis used in L1.

## Honest scope (what's proven, what isn't)

**Proven**:
- Part A: $f(x_T) \le C_1^2 \beta^T f(x_0)$ (tight in the spectral-radius rate).
- Part B: $f(\tilde x_T) \ge \kappa/(128\,\eta^2 L\,T^4)$ for $T \ge T_0(\beta) = \lceil 2/(1-\sqrt\beta)\rceil$.
- Part C analytic: $f(\tilde x_T)/f(x_T) \asymp \kappa\,\beta^{-T}/T^4$, giving κ-exponent **c=1** at the natural crossover $T^\star(\beta)$ (which is κ-independent).
- Part C FP-floor: in the regime $T \ge T_{\rm FP}(\beta) \approx \log(\varepsilon_{\rm mach})/\log\beta \approx 350$ for $\beta=0.9$, the apparent exponent is $c \approx 2$.

**Not proven**:
- The residual $\approx 0.94$ between empirical 2.94 and theoretical 2 in the FP-floor regime is unmodeled round-off and is NOT rigorously characterized.
- The under-damped boundary at $\kappa \approx 1101.24$ — for $\kappa$ above this, the μ-coordinate becomes over-damped and a separate analysis would be needed.
- Sharpness of $C_2 = 1/8$ — the empirical $|PR|\cdot\eta\lambda T^2 \ge 1.106$ shows $C_2$ could be tightened to ≈ 1.1, but the present proof uses the conservative absolute bound.

## Why this matters

The result completes the iterate-type picture for SHB on quadratic SC functions:
| Iterate type | Bias scaling on Goujaud (non-SC) | Bias scaling on quadratic SC |
|---|---|---|
| last iterate | $\Theta(LD^2)$ (stuck, no decay) | $\Theta(\beta^T)$ (geometric, fastest) |
| Cesàro avg | $\Theta(LD^2/T^2)$ (kills cycling) | $\Theta(1/T^2)$ |
| Polyak-Ruppert avg | $\Theta(LD^2/T^2)$ (kills cycling) | $\Theta(\kappa/T^4)$ — **κ-amplified** |

PR averaging is a double-edged sword: it acceleratingly fixes cycling bias in adversarial settings but simultaneously incurs $\kappa$-amplified loss in well-conditioned settings, with the dominance of the bad coordinate flipped (high-curvature dominates last iterate; low-curvature dominates PR average). No prior published result articulates this duality cleanly.

## Cross-pollination fragments preserved (from losing routes)

- **R5-A** (Route 5): $|a_\lambda|^2 = \eta\lambda/(4\sin^2\theta_\lambda)$ — initialization constant via the cleaner $z-\beta = z(1-\bar z)$ identity.
- **R2-A** (Route 2): tightened tail bound $[(T+1)+T\sqrt\beta]\beta^{T/2}$ — sharpens L2 Step 5.
- **R3-B** (Route 3): geometric phase mechanism — θ_L vs θ_μ contrast.

(Route 2's main κ³ claim was found to be a counterexample-to-itself: the identity $J_\infty + B_\mu K_\infty$ goes negative at the user's setting, invalidating the $c=3$ asymptote at $\kappa \ge 3.5$.)
