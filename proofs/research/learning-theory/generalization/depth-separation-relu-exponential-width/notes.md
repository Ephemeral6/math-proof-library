# Notes: Depth Separation - Exponential Width Lower Bound

## Proof technique
Hermite polynomial / spherical harmonics frequency analysis. Two key ingredients:
1. Target function (ball indicator) has energy at high Hermite degrees (up to Θ(√d))
2. Each ReLU neuron's radial projection at degree 2k is attenuated by 1/√(N(d,2k)) where N(d,2k) = binomial coefficient (exponentially large)

## Key steps
- Theorem A: degree-2 Hermite analysis shows √d neurons needed for quadratic radial function
- Theorem B: Funk-Hecke formula quantifies per-neuron contribution to radial harmonics; Cauchy-Schwarz forces exponential width

## Audit result
Theorem A: 9/10 (fully rigorous). Theorem B: 6.5/10 (structural argument complete, Laguerre coefficient energy lower bound stated without full derivation). Overall: 7.5/10, CONDITIONAL PASS for conjecture level.

## Related results
- ReLU universal approximation quantitative (proofs/research/learning-theory/generalization/relu-universal-approximation-quantitative/) — upper bound counterpart
- NTK Gram positive definiteness (proofs/research/learning-theory/generalization/ntk-gram-matrix-positive-definiteness/) — overparameterized network theory
