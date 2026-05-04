# Notes — Adversarial Trajectory Tradeoff (Problem 7.10)

## Proof technique

The winning route is **Route 1: certified-Lipschitz chain**. The structure is:

  max_{||δ||≤r} L(θ; x+δ) − L(θ; x)
       ≤ r · ||∇_x L(θ; x)||              (Cauchy-Schwarz on first-order Taylor)
       ≤ r · ( C_0 + H · ||θ_T − θ_0|| )  (Lipschitzness of grad-norm in θ)
       ≤ r · ( C_0 + H · G · √(T·η) )     (canonical SGD trajectory length).

Adding back the second-order ½ M_x r² term and the standard generalization gap G_S+G_N gives the full inequality. Route 2 (full Taylor) is the same chain stated differently and serves as sanity.

## Key steps

1. **Curvature × trajectory chain**: The mixed Hessian H = ||∇_θ∇_x L||_op is the "curvature scale" that turns the trajectory length √(Tη) into a bound on data-gradient norm growth. This is the heart of the argument.

2. **Argmin-shift lemma**: Adding a strictly increasing function p(T) to a U-shaped function g(T) shifts the minimizer strictly to the left. This gives **strict inequality** T*_adv < T*_clean for any r,H > 0. Pure analysis fact, no functional form needed.

3. **Literal formula caveat**: T*_adv = T*_clean / (1 + r²H²η) is an **asymptotic shape**, not pointwise true. Under (G_S = α/T, G_N = β√(Tη)), the exact answer is (β/(β+crH))^{2/3}, which linearizes to 1 − (2/3)·crH/β — linear in (rH), not quadratic. The stated form requires squared-Pythagorean absorption + unit rescaling.

## Audit result

- SymPy: confirmed all algebra (Penalty(r) chain, optimal-stopping ratio).
- NumPy: T*_adv = 386 < T*_clean = 396 in SGD-on-quadratic experiment; Penalty bound holds with slack ≈ 1.5×.
- Z3: strict inequality 1/(β+crH) < 1/β VALID.

No fixer round needed. PASS for Claim 1, PASS for strict inequality, PARTIAL for literal formula (intrinsic obstruction — not fixable, only honest scope).

## Related results

- Hardt, Recht & Singer 2016 (SGD uniform stability): the trajectory-length bound ||θ_T − θ_0|| ≤ G·√(Tη) we use is canonical from this analysis.
- Zhang et al. 2022 (ICLR, Signal-Noise Decomposition): provides the (G_S, G_N) decomposition framework.
- Madry et al. 2018: the inner-max adversarial formulation; certified-radius style Lipschitz bound is standard there.
- Cohen et al. 2019 (Certified Robustness via Randomized Smoothing): related certified-Lipschitz argument.

## Honest scope

Claim 1: rigorous (constants explicit).
Claim 2 strict: rigorous (argmin-shift).
Claim 2 literal formula: structural / asymptotic only — exponents differ from the natural parameterization.
