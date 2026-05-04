# Explorer Route 4: p-stable SDE / continuous-time heuristic check

## Idea

The continuous-time limit of SGD with heavy-tailed gradient noise (finite p-th moment, infinite variance) is a Levy-driven SDE:

  dtheta_t  =  -grad L_S(theta_t) dt  +  eta^{1/2} dL_t^{(p)},

where L^{(p)} is a symmetric p-stable Levy process. Strictly speaking p-stability requires E|X|^p = infty, so we are in the "heavy-tail with finite p-th moment" regime which sits *just inside* the p-stable basin of attraction.

## Heuristic on the noise scale

For a p-stable Levy process L^{(p)}, ||L^{(p)}_T||_p  has scaling **T^{1/p}**, not sqrt(T). Hence, after T steps,

  noise scale ~ eta^{1/2} * T^{1/p}.

But here we only have finite p-th moment, not stability. The closest rigorous statement is the MZ inequality from Route 2:

  E ||M_T||^p  <=  C T G^p eta^p.

Take p-th root: E||M_T|| <= C^{1/p} T^{1/p} eta G. Yes, this matches the p-stable scaling.

## Stability of Levy SDE

The Levy SDE has on-average stability of magnitude O(T^{1/p} / m^{(2-p)/2}) heuristically (the m factor coming from the fact that L^{(p)} as a Levy process is the limit of normalized i.i.d. heavy-tailed sums, and replacing one out of m random variables changes the limit by factor m^{(p-1)/p} / m = m^{-1/p}; squared root of variance proxy is m^{(2-p)/2}).

Combining: gen gap <= G * (eta T^{1/p}) / m^{(2-p)/(2p)}.

## Sanity check: rate after clipping

Clipping cuts off the Levy jumps larger than tau, leaving a SDE with finite variance. Variance ~ G^p tau^{2-p}. Standard L^2 analysis gives gen gap ~ sqrt(G^p tau^{2-p} T / m). Bias ~ T G^p / tau^{p-1}. Same balance as Route 3.

## Verdict

Route 4 is purely heuristic and does not give a rigorous proof. Its value is as a sanity check that:
- Pre-clip noise scales as eta T^{1/p} (matches MZ).
- Post-clip rate matches Route 3.

We DROP Route 4 from the final proof but keep its scaling predictions as a sanity check on Routes 1–3.
