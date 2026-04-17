# Proof Report: Compressed Sensing RIP Recovery Guarantee

## 1. Problem Statement

**Theorem (RIP Recovery Guarantee).** Let $A \in \mathbb{R}^{m \times n}$ with $m \ll n$ satisfy the Restricted Isometry Property (RIP) of order $2s$ with constant $\delta_{2s} < \sqrt{2} - 1$:

$$(1 - \delta_{2s})\|x\|_2^2 \leq \|Ax\|_2^2 \leq (1 + \delta_{2s})\|x\|_2^2, \quad \forall \|x\|_0 \leq 2s.$$

If $x^* \in \mathbb{R}^n$ is $s$-sparse ($\|x^*\|_0 \leq s$) and we observe $b = Ax^*$, then the solution to:

$$\hat{x} = \arg\min_{x} \|x\|_1 \quad \text{s.t.} \quad Ax = b$$

satisfies $\hat{x} = x^*$ (exact recovery).

**Source:** Candès & Tao 2005 (IEEE IT); Candès, Romberg & Tao 2006; Candès 2008.

**Difficulty:** Research

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed |
| Explorer | Opus | 4 proofs attempted, 1 succeeded (Route 3) |
| Judge | Sonnet | Route 3 selected (score: 35/40) |
| Audit | Opus | PASS (2 rounds) |
| Fix | Opus | 1 issue fixed (ROP lemma proof) |

## 3. Proof Routes Explored

### Route 1: Block Decomposition with Naive Cauchy-Schwarz (FAILED)
- Attempted standard block decomposition with Cauchy-Schwarz on $\|Ah_{T_{01}}\|_2$
- **Obstacle:** Bound $\sqrt{(1+\delta)/(1-\delta)} \cdot \|h_{T_0}\|_2$ gives ratio $> 1$, circular argument
- Score: 12/40

### Route 2: Null Space Property via RIP (FAILED)
- Showed NSP → recovery, then attempted RIP → NSP
- **Obstacle:** Same Cauchy-Schwarz looseness as Route 1
- Score: 13/40

### Route 3: Refined RIP/ROP Inner Product Approach (SUCCESS)
- Used separate inner products with $Ah_{T_0}$ and $Ah_{T_1}$, combined into $T_{01}$ analysis
- Key insight: decompose $\langle Ah_{T_{01}}, Ah_{T_j}\rangle$ into two ROP-controllable terms
- Reduced to quadratic infeasibility in $t = \|h_{T_1}\|/\|h_{T_0}\|$
- Score: 35/40

### Route 4: Dual Certificate / KKT (FAILED)
- Constructed pseudoinverse dual certificate
- **Obstacle:** Off-support bound $\delta\sqrt{s}/(1-\delta) < 1$ is $s$-dependent and too restrictive
- Score: 14/40

## 4. Final Proof

**Theorem.** Let $A \in \mathbb{R}^{m \times n}$ satisfy RIP of order $2s$ with $\delta_{2s} < \sqrt{2} - 1$. If $x^*$ is $s$-sparse and $b = Ax^*$, then $x^*$ is the unique $\ell_1$ minimizer subject to $Ax = b$.

**Lemma (ROP).** For disjointly supported $u, v$ with $|\text{supp}(u) \cup \text{supp}(v)| \leq k$: $|\langle Au, Av\rangle| \leq \delta_k\|u\|\|v\|$.

*Proof via rescaling:* Apply polarization to $\lambda u, v/\lambda$, then optimize $\lambda$ to get $2\|u\|\|v\|$ instead of $\|u\|^2+\|v\|^2$. □

**Main proof (7 steps):**

1. **Cone constraint:** $\|h_{T_0^c}\|_1 \leq \|h_{T_0}\|_1$ from $\ell_1$ optimality
2. **Block decomposition:** Tail bound $\beta = \sum_{j\geq 2}\|h_{T_j}\|_2 \leq \|h_{T_0}\|_2$
3. **Identity:** $\|Ah_{T_{01}}\|^2 = -\sum_{j\geq 2}\langle Ah_{T_{01}}, Ah_{T_j}\rangle$ from $Ah = 0$
4. **RIP lower bound:** $\|Ah_{T_{01}}\|^2 \geq (1-\delta)(a^2+b^2)$
5. **ROP upper bound:** $\|Ah_{T_{01}}\|^2 \leq \delta(a+b)\beta$ via decomposition into pairs
6. **Quadratic:** $(1-\delta)(1+t^2) \leq \delta(1+t)$ has no solution when $\Delta = -7\delta^2+12\delta-4 < 0$, which holds for $\delta < \frac{6-2\sqrt{2}}{7} \supset [\text{condition } \delta < \sqrt{2}-1]$
7. **Conclusion:** $h_{T_0} = 0 \Rightarrow h = 0$ by cone constraint. **Q.E.D.** □

## 5. Audit Result

**Round 1:** FAIL — ROP lemma proof had an error (AM-GM direction in deriving $\delta\|u\|\|v\|$ from $\frac{\delta}{2}(\|u\|^2+\|v\|^2)$). Fixed by rescaling trick.

**Round 2:** PASS — All 7 steps + lemma validated. Three additional checks confirmed: last block size, $h_{T_1}=0$ case, block series convergence. Numerical verification confirmed $\Delta \approx -0.2304$ at $\delta = \sqrt{2}-1$.

## 6. Fix History

### Round 1 Fix
- **Issue:** ROP lemma proof incorrectly used AM-GM to go from $\frac{\delta}{2}(\|u\|^2+\|v\|^2)$ to $\delta\|u\|\|v\|$ (AM-GM goes the wrong direction)
- **Fix:** Apply polarization to rescaled vectors $\lambda u$, $v/\lambda$, then optimize $\lambda > 0$ to minimize $\lambda^2\|u\|^2 + \|v\|^2/\lambda^2 = 2\|u\|\|v\|$ at $\lambda^2 = \|v\|/\|u\|$
- **Confidence:** HIGH
