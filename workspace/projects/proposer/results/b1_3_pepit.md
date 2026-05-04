# B1.3 PEPit Worst-Case Search
PEPit imported (version attr missing)

## SHB on smooth convex (L=1), eta=1/L, several beta, T in {3,5,10}
SHB beta=0.5 T=3: worst-case f(x_T)-f* = 1.1117e-01
SHB beta=0.5 T=5: worst-case f(x_T)-f* = 6.0822e-02
SHB beta=0.5 T=10: worst-case f(x_T)-f* = 2.4289e-02
SHB beta=0.9 T=3: worst-case f(x_T)-f* = 5.7353e-01
SHB beta=0.9 T=5: worst-case f(x_T)-f* = 4.7168e-01
SHB beta=0.9 T=10: worst-case f(x_T)-f* = 6.9065e-01

## GD on smooth convex (L=1), eta=1/L, T in {3,5,10}  -- sanity check
GD T=3: worst-case f(x_T)-f* = 7.1428e-02  (theory ~ L/(4T+2) = 7.1429e-02)
GD T=5: worst-case f(x_T)-f* = 4.5455e-02  (theory ~ L/(4T+2) = 4.5455e-02)
GD T=10: worst-case f(x_T)-f* = 2.3809e-02  (theory ~ L/(4T+2) = 2.3810e-02)

## NAG on smooth convex L=1, T in {3,5,10}
NAG T=3: worst-case f(x_T)-f* = 5.8822e-02  (theory O(1/T^2) ~ 1.1111e-01)
NAG T=5: worst-case f(x_T)-f* = 3.1250e-02  (theory O(1/T^2) ~ 4.0000e-02)
NAG T=10: worst-case f(x_T)-f* = 1.1494e-02  (theory O(1/T^2) ~ 1.0000e-02)

## Adam on smooth convex (L=1), T in {3,5,10} -- attempted manual PEP encoding
PEPit's PEP framework treats decision variables as elements of a Hilbert space and operations
must be linear in gradient + function-class queries. Adam's normalization v_hat^{-1/2} is NOT
expressible directly. SKIPPING — would require a custom interpolation class.

## SVRG: PEPit has limited support for variance-reduction worst-case PEPs without finite-sum interpolation
PEPit does support finite-sum settings via SmoothStronglyConvexFunction list, but constructing SVRG
with snapshot frequency m requires careful encoding. Skipping for time budget.
