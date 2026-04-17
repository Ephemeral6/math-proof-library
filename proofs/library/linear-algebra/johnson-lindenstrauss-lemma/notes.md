# Notes: Johnson-Lindenstrauss Lemma

## Proof technique
Route 1 (Sub-Gaussian MGF + Union Bound) won. This is the canonical, textbook approach:
1. Reduce to χ² concentration via Gaussian rotational invariance
2. Compute exact MGF of χ²(k)
3. Optimize Chernoff bound for both tails
4. Union bound over all pairs

## Key steps
- **Rotational invariance**: The key simplification — for a fixed unit vector x, Ax has i.i.d. N(0,1) components, regardless of the ambient dimension d. This completely decouples the problem from d.
- **Asymmetric tails**: The upper tail gives e^{-kε²/12} while the lower tail gives the tighter e^{-kε²/4}. This asymmetry arises because χ² is right-skewed (heavier right tail).
- **Taylor bound**: ln(1+ε) - ε ≤ -ε²/6 is the bottleneck; the lower tail bound ln(1-ε) + ε ≤ -ε²/2 is naturally tighter.

## Audit result
PASS on first round. Four LOW-severity presentation issues:
1. Sloppy constant tracking in union bound (factor of 2 absorbed)
2. Alternating series argument compressed
3. Existence vs explicit construction not discussed
4. ε³/3 < ε²/3 bound stated without full detail

## Related results
- **Achlioptas 2003**: Rademacher (±1) projections achieve the same bound — proved as Route 4 (k ≥ 48 ln(n)/ε²)
- **Optimal JL dimension**: Larsen & Nelson 2017 showed k = Θ(ε⁻² log n) is tight for linear maps
- **Fast JL transforms**: Ailon & Chazelle 2009 (FJLT) achieve same dimension with O(d log d) projection time
- **Sub-Gaussian covariance concentration**: Our proof of that result (in proofs/statistics/concentration/) uses similar χ² techniques
- **Matrix Bernstein**: The Route 3 (sub-exponential/Bernstein) approach connects to our matrix Bernstein proof
