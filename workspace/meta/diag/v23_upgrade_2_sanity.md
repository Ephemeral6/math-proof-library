# Sanity check — Upgrade 2 (Sub-pipeline recursion)

**Date.** 2026-04-21.
**Target.** Confirm Auditor rejects a `[SUB-PROBLEM:...]` marker whose
sub-claim is NOT strictly smaller than the parent theorem.

## Mock parent theorem

> **Theorem (parent).** For every prime $p$, the polynomial
> $\Phi_p(x) = 1 + x + \ldots + x^{p-1}$ is irreducible over $\mathbb{Q}$.

## Mock Explorer output emitting an inadmissible sub-problem

```
...
Step 5: The key step is to show $\Phi_p(x+1)$ is an Eisenstein
polynomial at the prime $p$. We delegate the general form.

[SUB-PROBLEM: For every prime $p$ and every integer $n \ge 1$, the
polynomial $\Phi_p(x+n)$ is Eisenstein at $p$.]
Strictly smaller because: lemma version of the main step.
Scope: [REF:sub-problem-1] is cited in Step 5 to close irreducibility.
...
```

## Simulated Auditor admissibility check

Reading `~/.claude/skills/math-proof-agent/prompts/auditor.md` v2.3
extension, "Sub-problem admissibility":

1. **"Strictly smaller because:" line present?** YES (literal string
   "Strictly smaller because: lemma version of the main step.").
2. **Reason is one of the 3 allowed types?**
   - Strictly smaller parameter range?
     - Parent quantifies over $p$ prime.
     - Sub-problem quantifies over $p$ prime AND $n \ge 1$.
     - The sub-problem's parameter space is STRICTLY LARGER, not smaller.
     Does not qualify.
   - Strictly fewer quantifiers?
     - Parent has 1 quantifier ($\forall p$).
     - Sub-problem has 2 quantifiers ($\forall p, \forall n$).
     - Sub-problem has MORE quantifiers. Does not qualify.
   - Strictly less general statement?
     - Parent statement: $\Phi_p(x)$ irreducible.
     - Sub-problem statement: $\Phi_p(x+n)$ is Eisenstein for all primes
       AND all integers $n \ge 1$.
     - Sub-problem implies parent (taking $n=1$, Eisenstein ⇒ irreducible
       after shift), but the converse does not hold. The sub-problem is
       MORE GENERAL than the parent, not less.
     Does not qualify.
3. **Reason is not vacuous?** The literal phrase "lemma version of the
   main step" is a vacuous classification — any sub-step of any proof
   can be called a lemma version. Auditor rejects vacuous reasons by
   the third admissibility clause.

**Decision.** Two failures:
- Concrete reason category: NONE of the 3 allowed types applies (the
  sub-problem is strictly MORE general, not strictly less).
- Reason vacuity: "lemma version of the main step" is vacuous.

**Auditor output:**
```
SUB-PROBLEM-REJECTED
Reason: the declared sub-problem is strictly MORE general than the
parent theorem (quantifies over both $p$ and $n$ where parent only
quantifies over $p$), violating the "strictly smaller" admissibility
requirement. Additionally, the "Strictly smaller because:" line is
vacuous ("lemma version of the main step" does not specify a
concrete parameter/quantifier/generality reduction).
Action: treat as a structural SP in the parent's next Auditor round.
Fixer must resolve in-line or propose a re-formulation.
```

## Auditor decision

**REJECTED.** The admissibility check correctly flags the sub-problem
as inadmissible on TWO grounds:
1. The sub-problem is strictly more general, not less.
2. The reason is vacuous.

## Contrast: admissible version

For comparison, an admissible formulation would be:

> [SUB-PROBLEM: For $p = 5$, the polynomial $\Phi_5(x+1)$ is Eisenstein
> at $p = 5$.]
> Strictly smaller because: strictly smaller parameter range — only the
> single prime $p = 5$ instead of all primes.

This version DOES pass admissibility: parameter range is strictly
smaller (one prime vs. infinitely many primes), reason is concrete.

## Result

**PASS.** The v2.3 admissibility check correctly rejects sub-problems
that are not strictly smaller than the parent theorem and correctly
flags vacuous "Strictly smaller because:" reasons.

The sanity check also confirms the admissibility check is not
over-restrictive: an appropriately formulated sub-problem (concrete
reason + one of the three allowed reduction types) passes.
