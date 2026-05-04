# Problem 3.1: Last-Iterate Convergence of Non-Strongly-Convex SVRG

## Source
- Paper: Allen-Zhu and Yuan, "Improved SVRG for Non-Strongly-Convex or Sum-of-Non-Convex Objectives", ICML 2016
- Context: Standard SVRG analysis bounds the **snapshot** (epoch-end averaged or final-of-epoch reference point) x̃_s. We ask whether the **true last iterate within an epoch** enjoys the same O(LD²/(sm)) rate.

## Statement
Let f(x) = (1/n) Σᵢ fᵢ(x), each fᵢ being L-smooth and convex (NOT strongly convex). Run SVRG with epoch length m and constant step size η = 1/(3L). Let s be the number of completed epochs and let x_T denote the final (last) iterate of epoch s, **not** the averaged snapshot. Define D = ‖x_0 - x*‖.

**Claim (to prove or disprove)**: there exists a universal constant C with
  E[f(x_T) - f*] ≤ C · L D² / (s · m).

If the claim fails, prove a **lower bound** quantifying the gap between last-iterate and snapshot rates.

## Difficulty
research
