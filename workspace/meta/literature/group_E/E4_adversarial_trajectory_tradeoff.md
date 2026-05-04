# E4: Adversarial Trajectory Tradeoff (Problem 7.10, PARTIAL)

**Path**: `proofs/research/learning-theory/stability/adversarial-trajectory-tradeoff/`
**Source**: Internal synthesis with Hardt 2016 + Madry 2018 (1706.06083) + Zhang 2022

## Verdict: CONFIRMED as NOVEL SYNTHESIS (PARTIAL declared honestly)

## Our claim
- Claim 1 (PASS rigorously): R_adv(theta_T) <= G_S(T) + G_N(T) + Penalty(r),
  Penalty(r) = r*C_0 + r*G*H*sqrt(T*eta) + (1/2)*M_x*r^2.
- Claim 2 strict T*_adv < T*_clean (PASS rigorously via argmin-shift lemma).
- Claim 2 LITERAL formula T*_adv = T*_clean / (1 + r^2 H^2 eta): PARTIAL.
  Natural parameterization gives ratio (beta / (beta + crH))^{2/3}.

## Literature comparison
Madry et al. 2018 (1706.06083) is purely algorithmic/empirical — presents PGD-AT, demonstrates
"first-order adversary" concept, but does NOT prove a formal generalization-robustness tradeoff
nor an early-stopping shift theorem.

Therefore E4 is a NOVEL THEORETICAL SYNTHESIS of:
- HRS-style stability bound (E1)
- Teng-Ma-Yuan signal-noise decomposition (E3)
- Madry's r-radius adversarial perturbation framework
- Argmin-shift on a U-shaped trajectory cost

The trajectory-length x curvature x radius penalty (Penalty(r) = O(r*H*sqrt(T*eta))) is a
clean novel quantity, derivable from first principles (Cauchy-Schwarz on adv inflation +
chain-rule curvature transfer).

## Honest scope (declared in proof)
The literal stated formula T*_adv = T*_clean/(1+r^2 H^2 eta) is NOT recovered exactly under any
natural parameterization. The proof correctly flags this as "structural shape" rather than
literal identity. The strict-inequality content is the rigorous core.

## Discrepancies
None hidden. PARTIAL is declared at top of proof.

## Confidence: MEDIUM
Novel synthesis with honest scope. The argmin-shift technique is standard calculus; the
trajectory-curvature penalty derivation is a clean original contribution though not at the
level of a publishable theorem (relies on assumed (A1)-(A5) which packaging existing results).
