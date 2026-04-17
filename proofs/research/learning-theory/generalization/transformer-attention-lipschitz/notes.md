# Notes: Transformer Attention Lipschitz

## Proof technique
Three-stage composition: logit map (bilinear) → softmax (1/2-Lip) → value aggregation (product rule).

## Key steps
1. Product-rule decomposition into value perturbation + attention perturbation
2. Softmax Jacobian = Hessian of LSE, spectral norm = 1/2 (tight at σ=(1/2,1/2,0...))
3. Score perturbation 2√n·||M||·R/√d_k from bilinear XMX^T structure
4. Natural bound is R² (cubic dependence of f_i on X)

## Audit result
PASS. All 6 steps valid. R² finding confirmed by all 4 routes.

## Related results
- Attention is not Lipschitz without bounded inputs (grows with R²)
- LayerNorm ensures R≤1, making stated bound valid
- Connection to generalization bounds for Transformers
