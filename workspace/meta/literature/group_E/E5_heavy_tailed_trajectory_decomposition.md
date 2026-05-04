# E5: Heavy-Tailed Trajectory Decomposition (Problem 7.6)

**Path**: `proofs/research/learning-theory/stability/heavy-tailed-trajectory-decomposition/`
**Source**: Internal — claimed reference Wang-Mao 2021 (arXiv 2102.04259)

## ERROR FLAG: arXiv ID misattributed

arXiv 2102.04259 is **NOT** Wang-Mao on heavy-tailed SGD. It is Even-Massoulié,
"Concentration of Non-Isotropic Random Tensors with Applications to Learning and Empirical
Risk Minimization." This is a citation/attribution error in our index, not in the proof
content per se.

The actual relevant paper for clipped SGD heavy-tail rate G T^{1-1/p}/sqrt(m) is likely
- Wang, Mao, Stich et al. "Convergence of SGD under Heavy-Tailed Noise" (different arXiv ID)
- Or Vural et al. 2022 / Gorbunov et al. 2020 (1912.07467, 2005.10785) — the latter on clipped SGD
- Or Zhang et al. 2020 / 2021 on clipped SGD heavy-tail

## Verdict: CONFIRMED RATE, REFERENCE NEEDS CORRECTION

## Our claim
Under bounded p-th gradient moment (1 < p < 2):
- E ||Delta_T||^p decomposes into signal G_S^(p)(T) + noise G_N^(p)(T) terms.
- After clipping at tau = G T^{1/p - 1/2} (Polyak-Ruppert averaged), gen gap <= O(G T^{1-1/p} / sqrt(m)).

## Literature comparison
The rate G T^{1-1/p}/sqrt(m) is the established minimax rate for SGD under bounded p-th moment
(p ∈ (1,2)). It appears in:
- Gorbunov et al. 2020 (clipped SGD)
- Zhang et al. 2020 (high-prob clipped SGD)
- Sadiev et al. / Cutkosky-Mehta line of work

The novel content of our proof:
- A trajectory (signal/noise) decomposition INSIDE a heavy-tail recurrence
- Clipping balance via calculus optimization at the Polyak-Ruppert level
- The exponent T^{1-1/p} matches known minimax rates (so the calibration is correct)

## Discrepancies
- **ERROR**: index arXiv ID is wrong (2102.04259 is a different paper). Correct
  attribution is to the clipped-SGD heavy-tail line.
- The Stage C noise bound (Eq 4) re-normalizes via "m^{-(2-p)/2}" by analogy to bounded-2nd-moment
  case; this is heuristic and not rigorously derived. The signal stage shock-integration
  argument is also heuristic. The MATCHING of the final rate to the known minimax G T^{1-1/p}/sqrt(m)
  is reassuring but the derivation is not fully tight.

## Confidence: MEDIUM-LOW
The final rate matches the literature, but the path to it (martingale renormalization in
Stage C, signal shock integration in Stage C signal term) involves hand-waving steps that a
rigorous referee would flag. PARTIAL synthesis is appropriate. Reference correction is needed.
