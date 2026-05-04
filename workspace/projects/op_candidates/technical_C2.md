# Technical Assessment: C2 — Failure Mode Classification for AI Proof Systems

> Date: 2026-04-28

---

## Core Technical Challenge

The central obstacle is definitional, not computational: **"failure mode" is not yet a mathematical object.** Before any lower bound can be proved, the following chain must be established:

```
Empirical failure pattern
    → Formal agent model (query/oracle model, or Turing machine with oracle)
    → Proof complexity analogue (which formula class captures this failure?)
    → Lower bound in the chosen complexity measure
```

Each arrow is a non-trivial formalization step. The research program is not one theorem but a sequence of definitions + one theorem per class.

---

## Proposed Technical Route (for the re-scoped version)

### Step 1: Model the agent as a query-complexity object

Fix the "AI proof agent" as a deterministic or randomized oracle machine M that:
- Takes as input a theorem statement T (as a formal expression, e.g., Lean 4 syntax)
- Queries an oracle O_tac(state, tactic) → {success, failure, subgoals} (tactic evaluator)
- Succeeds if it produces a valid proof certificate within q queries

This is a **black-box tactic-oracle model**, analogous to the decision-tree complexity model. It cleanly separates the agent's search strategy from the underlying proof system.

### Step 2: Identify the target failure class

From the user's failure database (workspace/failure_patterns.md), the most structurally crisp failure class is:

**Class QA: Quantifier-Alternation Traps**

Observed empirically as:
- Scout/Explorer consistently proposes "∀∃ swap" or "introduce a specific witness" as a route, but cannot close the ∃ witness construction
- The proof agent gets stuck at "Step N: Constructing the explicit witness satisfying..."
- Appears in convex analysis (existence of dual solutions), learning theory (minimax lower bounds), and optimization (existence of hard instances)

Formal analogue: Formulas of the form ∀x ∃y P(x,y) where P(x,y) requires an adversarial construction that depends non-trivially on x. In proof complexity, these correspond to formulas with high "dag-like" proof depth or high "functional" complexity in the underlying proof system.

### Step 3: Identify the proof complexity analogue

The "quantifier-alternation trap" corresponds, in proof complexity, to formulas that require:
- High width in Resolution (Ben-Sasson–Wigderson width lower bound method, 2001)
- High degree in Polynomial Calculus (Razborov degree lower bounds)
- High depth in Frege (Krajicek depth-width tradeoffs)

**The key connection**: Formulas of the form ∀x ∃y P(x,y) that cannot be witnessed by a polynomial-time function (assuming P ≠ NP or assuming specific circuit lower bounds) require the tactic oracle to be queried Ω(D) times before any witness can be certified, where D is the depth of the existential dependency.

### Step 4: The lower bound theorem (proposed)

**Candidate theorem (sketch)**: Let M be any deterministic tactic-oracle agent. Let F_n be the family of Lean-formalized theorems of the form "∃y ∀x, f(x,y) ≤ g(x)" where f, g are computed by circuits of size n. Then any M that succeeds on F_n with probability > 2/3 must make at least Ω(n^{1/2}) oracle queries.

**Proof route**: Reduction from the "search problem" associated with F_n to query complexity lower bounds via the adversary method (Ambainis 2002) or the polynomial method (Beals et al. 2001). The key insight is that each oracle query reveals at most one "certificate bit" for the witness y, and the adversary can delay revealing consistency-breaking information for Ω(n^{1/2}) steps.

**Difficulty rating**: High. The main technical hurdle is defining F_n precisely enough that the query-complexity reduction goes through while still capturing the empirically observed failures.

---

## Pipeline Reuse: The Differentiating Asset

The user's **failure_patterns.md** database is the unique empirical grounding that no other researcher has. Specifically:

- The database contains ~40+ failure entries with structured fields: domain, technique, step-stuck, reason, lesson
- Patterns visible across entries:
  1. **Missing structural insight** (Schur lemma, phase transitions, proxy measures) — these are "mathematical surprise" failures, likely not formalizable as complexity LBs
  2. **Circular dependency** (gradient direction ↔ iterate direction) — these map to fixed-point characterization failures
  3. **Witness construction** (∀∃ swap, explicit construction incomplete) — these map cleanly to query/proof complexity
  4. **Lyapunov tightness** (bound correct but too loose by O(n) factor) — these map to approximation lower bounds

Classes 3 and 4 are the most theorem-shaped. Class 3 (witness construction = quantifier-alternation traps) is the strongest candidate for a single clean LB.

---

## What's Genuinely New

1. **The formalization of "failure mode"** as a complexity-theoretic object. Existing work (Li et al. survey) is purely descriptive.
2. **Connecting the tactic-oracle model to classical proof complexity**. The Atserias–Müller / Goos framework is for classical proof systems; extending it to agent models with arbitrary tactic oracles is new.
3. **Using empirical data to motivate the formula class**. The standard proof complexity approach is "find a hard formula family and prove LB." Here, the formula family is motivated by observed failures in a real system.

---

## Scope Assessment: Research Program vs. Single Theorem

This direction is structured as a **research program**:

| Component | Status | Difficulty |
|---|---|---|
| Define tactic-oracle agent model | New formalization needed | Medium |
| Define "failure mode class" formally | New definition needed | Medium-High |
| Prove LB for Class QA (one class) | The single theorem | High |
| Prove LBs for Classes 1-4 | Multiple papers | Very High |
| Full classification theorem | Long-term goal | Research frontier |

**6-week realistic scope**: Define the tactic-oracle model + Class QA formalization + prove the query-complexity LB for one specific formula family. This is one self-contained paper of ~15–20 pages.

---

## Technical Risks

1. The tactic-oracle model may be too powerful or too weak relative to actual LLM agents — the model validity requires careful argument.
2. The query-complexity LB requires a formula family that is (a) hard for agents and (b) easy enough to analyze. Finding this family is the core creative challenge.
3. The "proof complexity analogue" step (Step 3) may require results that are only conditionally known (assuming P ≠ NP or circuit lower bounds).
