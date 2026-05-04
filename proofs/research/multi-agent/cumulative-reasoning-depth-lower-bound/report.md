# Final Report: Problem 7.9 — CR Compositional Reasoning Depth Lower Bound

**Verdict:**
- Part (a): **PASS** (with stated computational model and Hypothesis 1 below).
- Part (b): **PARTIAL** — proved under transcript-dependency model; permissive-verifier gap remains.
- Part (c): **PARTIAL** — formula is consistent with derivation; **the stated numerical answer "≈ 18 steps" is arithmetically incorrect**. Correct value is $\approx 3.9$.

**Audit rounds consumed:** 1 (no fixer needed — gaps are honesty disclosures, not technical errors).

---

## Computational model

A CR-depth-$d$ task has a derivation tree of depth $d$ over $m$ primitive facts; the agent must establish $C_1, C_2, \ldots, C_d$ in sequence. A **step** is one Proposer–Verifier interaction. The Verifier accepts a wrong proposition with probability $\le \varepsilon$. With $k$ retries per level (i.i.d.), the *cluster*-effective error is $\varepsilon^k$.

**Hypothesis 1 (adversarial alternative).** At each level, there exists at least one wrong candidate $C_\ell^\dagger$ that is verifier-indistinguishable from the correct $C_\ell^*$ (returns 1 with prob $\varepsilon$ vs $1-\varepsilon$).

## Part (a): Lower bound

**Theorem.** Under Hypothesis 1, any randomized agent solving the depth-$d$ task with failure probability $\le \delta$ requires
$$T \;\ge\; d \cdot \frac{\log(1/\delta)}{\log(1/\varepsilon)} \;-\; O(d).$$

**Proof sketch.**
1. Failure event: chain succeeds iff every level succeeds. Hence $\max_\ell \Pr[E_\ell] \le \delta$, so $\Pr[E_\ell] \le \delta$ per level.
2. Adversary argument (Route 3 Yao): on the hard distribution where each level has equal prior over correct/wrong-indistinguishable candidates, optimal Bayes test errs with prob $\ge \tfrac{1}{2}\varepsilon^{T_\ell}$. So $\tfrac{1}{2}\varepsilon^{T_\ell} \le \delta$, giving $T_\ell \ge \log(1/2\delta)/\log(1/\varepsilon)$.
3. Sum: $T \ge d \log(1/2\delta)/\log(1/\varepsilon) = d \log(1/\delta)/\log(1/\varepsilon) - d \log 2/\log(1/\varepsilon)$.

For $\delta \le 1/2$ the lower-order term is non-positive in the desired direction; the claim holds modulo $O(d)$.

**Verified by SymPy** (solved $\varepsilon^{T_\ell} = \delta \Rightarrow T_\ell = \log(\delta)/\log(\varepsilon)$) and **Z3** (`unsat` on negation of the inequality at sample parameters).

## Part (b): No-parallelization

**Theorem (transcript-dependency model).** In a parallel CR computation modelled as a causal DAG where each node certifying a level-$\ell$ proposition must depend on a node certifying a level-$(\ell-1)$ proposition, makespan is $\ge d$ regardless of Proposer count.

**Proof.** Critical-path argument: any node $v_d$ outputting $C_d$ has an ancestor chain $v_d \succ v_{d-1} \succ \cdots \succ v_1$ in the DAG; causality forces $\tau(v_d) \ge d$. $\blacksquare$

**Gap (acknowledged).** Under a permissive verifier model — where the Verifier judges propositions on intrinsic logical merit without requiring verified premises — parallel speedup IS possible. The argument therefore proves the claim only under transcript-based verification. **Hence PARTIAL.**

## Part (c): Numerical claim

**Stated:** $T \ge 5 \log(100)/\log(1/0.14^3) \approx 18$.

**Correct evaluation:**
- $0.14^3 = 0.002744$
- $1/0.14^3 \approx 364.43$
- $\log(364.43) / \log(100) \approx 5.898 / 4.605 \approx 1.281$
- $T \ge 5 \times 4.605 / 5.898 = \mathbf{3.904}$

**The claim of "≈ 18 steps" is an arithmetic error of factor $\sim 4.6\times$.** The formula is consistent with our bound (steps = retry-clusters, effective error $\varepsilon^k$), but the stated value 18 cannot be reconciled with the stated formula at the stated parameters.

**Honest interpretation possibilities:**
- If "step" means *verifier call* (not cluster), then $T \ge d \log(1/\delta)/\log(1/\varepsilon) = 5 \times \log(100)/\log(1/0.14) \approx 11.71$. With $k=3$ retries enforced per level, this becomes $T = k \cdot d \cdot \lceil \log(1/\delta)/(k \log(1/\varepsilon))\rceil = 3 \cdot 5 \cdot 1 = 15$. Even this doesn't reach 18.
- The closest plausible interpretation that yields ~18 is $T \ge k \cdot d \cdot \lceil \log(1/\delta)/\log(1/\varepsilon^k) \rceil = 3 \cdot 5 \cdot \lceil 0.78\rceil = 15$, plus a per-level Proposer step: $5 \times (3+1) = 20$. Still not 18.

**Hence (c) is PARTIAL:** the bound's formula is verified; the claim "≈ 18" must be flagged as a computational error in the original problem.

## Numerical confirmation table

| Interpretation | Formula | Value |
|---|---|---|
| Cluster-step (formula as written) | $d \log(1/\delta)/\log(1/\varepsilon^k)$ | **3.90** |
| Verifier-call step | $d \log(1/\delta)/\log(1/\varepsilon)$ | **11.71** |
| Each level uses k retries (15 calls) plus 1 Proposer step per cluster | mixed | **15-20** |
| **Claimed** | "≈ 18" | **does not match** |

---

## Archive plan

- Class: A-class (research-level, conjecture difficulty).
- Branch: `multi-agent`.
- Path: `proofs/research/multi-agent/cumulative-reasoning-depth-lower-bound/`.
- Verdict tag: PARTIAL (one PASS, two PARTIAL).
