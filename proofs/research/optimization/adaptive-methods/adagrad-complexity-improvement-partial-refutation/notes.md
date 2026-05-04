# Notes: AdaGrad Coordinate-wise Complexity (COLT 2025 Conjecture — PARTIAL REFUTATION)

## Proof technique

**Hybrid MT1 (Route 1 UB) + MT6 (Route 3 LB), explicitly framed as REFUTATION with matched-pair partial.**

The original COLT 2025 conjecture claimed $T^{-2/3}d^{1/3}$ upper bound and $\sqrt{d}/\varepsilon^{3/2}$ lower bound for coordinate-wise AdaGrad under the variance-only oracle. This proof refutes both claims under the stated assumptions and instead establishes the matched pair $T \asymp d\sigma^2/\varepsilon$.

**Part A (UB) — MT1 Cancellation Pair:**
- Adaptive descent lemma (per-coordinate $L$-smoothness)
- Predictable-surrogate decomposition: $1/\sqrt{v_{t,i}} = 1/\sqrt{\hat v_{t,i}} + \text{correction}$
- NOI term is a martingale difference (zero mean)
- COR term bounded via corrected inequality $b/(2a\sqrt{a+b})$ (Round 1 fix), absorbed via $\kappa_M$ constant tracking
- QUAD term controlled by per-coordinate self-bounding sum $\sum_t g_{t,i}^2/\sqrt{v_{t,i}} \le 2\sqrt{v_{T,i}}$
- Cauchy-Schwarz over coordinates introduces $\sqrt{d}$ factor: $\sum_i \sqrt{v_{T,i}} \le \sqrt{d \sum_i v_{T,i}}$
- A.s. gradient envelope $\|g_t\| \le M$ closes the proof (variance-only path hits 4th-moment obstacle)
- AM-GM optimization on $\eta$ gives rate $C\sqrt{LM^2 d\Delta_0 \log T/T}$

**Part B (LB) — MT6 Le Cam Two-Point (d-needle variant):**
- Hard-instance family: $d$-dimensional problem with one "signal" coordinate $i^*$ (random) containing needle $\varphi_{i^*}$ and $d-1$ noise-only coordinates
- Under coordinate-query oracle (M2), algorithm cannot identify $i^*$ without spending $\Omega(\sigma^2/A^2)$ queries on each coordinate
- Per-coordinate Le Cam: KL $= A^2/(2\sigma^2)$ per step; stopping time bound gives $\mathbb{E}_0[T_j] \ge \sigma^2/(8A^2)$
- Detection-gap lemma: chi-squared $\chi^2 \le e^{1/8}-1 \approx 0.133 < 1/2$ (verified SymPy + Monte Carlo)
- Symmetrization: $d$-fold budget $\Rightarrow$ $T \ge \Omega(d\sigma^2/\varepsilon)$ total

## Key steps

**UB critical steps:**
1. The per-coordinate self-bounding sum identity $\sum_t g_{t,i}^2/\sqrt{v_{t,i}} \le 2\sqrt{v_{T,i}}$ (Lemma 2, sqrt form)
2. Cauchy-Schwarz over coordinates: $\sum_i \sqrt{v_{T,i}} \le \sqrt{d \cdot V_T^\Sigma}$ — this introduces the $\sqrt{d}$ factor
3. Corrected COR-INEQ bound $b/(2a\sqrt{a+b})$ (NOT the wrong $b/(2\sqrt{a}(a+b))$) — fixed in Round 1
4. A.s. envelope $\|g_t\| \le M$ allows the QUAD+COR tail bounding without 4th moments
5. Why $T^{-2/3}$ fails: the log-accumulator gives $T^{-1/2}$ (2-term AM-GM); the sqrt-SB gives $T^{-1/4}$ (2-term with worse exponent); $T^{-2/3}$ requires a 3-term AM-GM that needs affine-noise self-control

**LB critical steps:**
1. Oracle model clarification (M2 coordinate-query vs M1 joint $\ell_2$): under M1, per-coord noise is $\sigma^2/d$ and the $d$-factor cancels; under M2, per-coord noise is $\sigma^2$ and the $d$-factor survives
2. The $d$-needle symmetrization: adversary randomly selects $i^*$ AFTER the run; algorithm cannot concentrate queries on the "right" coordinate
3. Why single-level Le Cam cannot achieve $\varepsilon^{-3/2}$: the Markov-inversion of per-coord Bayes error bounds gives only $\varepsilon^{-1}$; the chain-of-needles (Carmon-Duchi-Hinder-Sidford 2020) is needed for $\varepsilon^{-3/2}$

## Audit result

**PASS_PARTIAL after 1 fix round; 0 HIGH issues, 0 MEDIUM issues, 3 LOW cosmetic remaining.**

- Round 1 audit: 1 INVALID (§3.2 algebraic inequality wrong direction), 2 MEDIUM, 3 LOW/LOW-MEDIUM
- Fixer Round 1 applied 3 fixes: corrected COR-INEQ bound (F1, MEDIUM), explicit oracle model subsection (F2, MEDIUM), explicit chi-squared derivation replacing [CALL:math-verifier] (F3, LOW-MEDIUM)
- Round 2 audit: all fixes independently verified (8 hand-picked + 2000 random numerical cases for F1; 9 cross-reference checks for F2; SymPy + 200,000 Monte Carlo trials for F3)
- F4 gate: FIXER-NEARLY-DONE
- 3 remaining LOW cosmetic items: (L1) smoothness bound is ~1.385L, claimed 2L (loose but correct); (L2) $\inf\varphi_s$ approximation has 12% slack (absorbed into absolute constants); (L3) Hooks Report cosmetic notation for FT-RATE-UB-LB-MISMATCH

## Knowledge Reuse System impact

The failure trigger layer (Layer 2) provided the highest marginal value in this proof:

- **FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING** (fired for Routes 2 and 5): Prevented Route 5's joint Lyapunov approach from spending further effort. Route 5 would have derived the same $O(d^{1/2}T^{-1/2}\log^{1/2}T)$ bound as Route 1 via a different starting point but with more work. The trigger saved an estimated 2 Explorer iterations and directly confirmed that Lyapunov augmentation with $\sum_i\sqrt{v_{t,i}}$ adds no new analytical leverage.

- **FT-RATE-UB-LB-MISMATCH** (diagnostic for Routes 1, 3, 6): When each Explorer hit a rate weaker than the conjecture, this trigger motivated the REFUTATION framing rather than false claims. This was the correct response: all 6 routes failed, and the trigger's diagnostic role was to convert the all-failures outcome into an explicit structural argument against the conjecture.

- **FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM** (navigated by Route 3): Correctly prompted Route 3 to abandon the product-Le Cam approach (which would have hit dimension-independent SNR) and adopt the single-needle symmetrization instead.

**Layer 1 (strategy_index)**: Parent proof `adagrad-norm-nonconvex-convergence` provided the full scaffold for Part A (descent → log-accumulator → CS chain). Route 1 started from the verified skeleton rather than from scratch, saving one iteration.

**Layer 4 (structure_map)**: The Le Cam family cousin `shb-no-acceleration-restricted` provided the exact Pinsker + Le Cam template transferred to Route 3's Part B construction.

**New fragments generated** (for library inclusion):
- Corrected predictable-surrogate denominator inequality: $1/\sqrt{a} - 1/\sqrt{a+b} \le b/(2a\sqrt{a+b})$
- Detection-gap chi-squared bound (Round 1 verified): $\chi^2(\mathbb{P}_1\|\mathbb{P}_0) \le e^{1/8}-1 \approx 0.133$
- $d$-needle symmetrization lemma: under coord-query oracle, $d$-coord indistinguishability forces total budget $\ge d\sigma^2/(16A^2)$

## Related results

**Parent results (directly used):**
- `proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/` — scalar AdaGrad-Norm $O(\log T/\sqrt{T})$ rate (Ward-Wu-Bottou 2019); the coordinate-wise result is the scalar rate times $\sqrt{d}$ from the per-coordinate Cauchy-Schwarz coupling
- `proofs/research/optimization/adaptive-methods/amsgrad-nonconvex-convergence/` — predictable-surrogate trick (Reddi-Kale-Kumar 2018); attempted transfer FAILED for vanilla coordinate-wise AdaGrad (missing $1-\beta_2$ EMA cushion)

**Le Cam family (LB template):**
- `proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/` — SHB no-acceleration result (OP-2); provided the Le Cam + Pinsker + $d$-needle template

**Open question:** Can the conjecture's $T^{-2/3}$ rate be recovered under the affine-noise oracle $\mathbb{E}[\|\xi_t\|^2] \le \sigma_0^2 + \sigma_1^2\|\nabla f(x_t)\|^2$ specifically for coordinate-wise (not just scalar) AdaGrad? Faw–Tziotis–Caramanis–Mokhtari–Shakkottai–Ward 2022 proves this for scalar AdaGrad-Norm; the coordinate-wise extension requires the three-term AM-GM under per-coordinate affine-noise self-control ($\sigma_i^2(x) \le A + B(\nabla_i f(x))^2$). This is the most promising direction for recovering the original conjecture.
