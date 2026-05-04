# D1 Technical Analysis: Counterexample Construction Query-Complexity Lower Bound

## Date: 2026-04-28

---

## Core Technical Setup

### Oracle Model (definition of "conjecture class")

The key formalization challenge is defining a "conjecture class" precisely enough to support a rigorous LB argument without trivializing. Proposed definition:

**Parametric Conjecture Family:** A family C = {f_n : D_n -> {0,1}} where:
- D_n is the domain (e.g., n-vertex graphs, degree-d polynomials over [0,1]^d, n-dimensional binary vectors)
- f_n(x) = 1 means "x is NOT a counterexample" (conjecture holds on x)
- The conjecture asserts: for all x in D_n, f_n(x) = 1

The refutation task: given oracle access to f_n (the "check oracle"), find x* in D_n such that f_n(x*) = 0. Query complexity = number of oracle calls.

**Important sub-model choices (each yields a different paper):**
1. **Combinatorial inequality conjectures:** D_n = graphs on n vertices, f_n = I[conjecture holds on graph G]. Queries: adaptive graph queries (edge/adjacency).
2. **Polynomial inequality conjectures:** D_n = {x in R^d : ||x|| <= 1}, f_n = I[p(x) >= 0] for degree-d polynomial p. Queries: evaluation of p at chosen points.
3. **Boolean identity conjectures:** D_n = {0,1}^n, f_n = I[sum conjecture holds]. Queries: function evaluations. Cleanest model.

**Recommended starting point for 6 weeks:** Model 3 (Boolean, clean, most tractable).

---

## Lower Bound Technique: Yao Minimax / Decision-Tree LB

### Primary route: Yao's minimax (decision-tree model)

**Steps:**
1. Construct a hard distribution mu over "conjecture-false" instances (instances where a counterexample exists but is hard to find).
2. Show that any deterministic decision tree needs Omega(T) queries to find the counterexample with probability > 1/2 over mu.
3. By Yao / Ben-David-Blais (2023) new minimax theorem, this gives the same Omega(T) LB for randomized algorithms (all bias levels simultaneously).

**Hard distribution construction (standard template for Boolean case):**
- Let n be the problem size parameter.
- Draw counterexample x* uniformly at random from D_n.
- Define the conjecture function: f(x) = 0 iff x = x* (planted counterexample model).
- Any algorithm must "find the needle" x* with as few queries as possible.
- Lower bound: Omega(|D_n| / Q) probability of missing x* after Q queries → Omega(|D_n|) queries needed for constant success probability.

**Richer models:** Conjecture where multiple counterexamples exist in structured locations (e.g., on a planted subgraph), analogous to planted clique. Then LBs require SOS/low-degree arguments. This is the harder version but closer to practice.

### Secondary route: Communication complexity reduction

For multiparty or distributed conjecture-finding, reduce to a communication problem. The pipeline already has Le Cam reduction machinery from adagrad-norm-last-iterate-lb (OP-2 precursor). That tool reduces oracle LBs to information-theoretic distinguishability. The same template applies here:
- Two distributions over conjecture families: one where no counterexample exists, one where exactly one does.
- Lower bound the mutual information between algorithm queries and counterexample location.
- Import directly from Le Cam / Fano reduction machinery.

### Tertiary route: Polynomial method (for quantum LBs)

If the Boolean conjecture-check function has approximate degree Omega(d), then any quantum algorithm needs Omega(d) queries (Beals-Buhrman-Cleve-Mosca-de Wolf). Approximate degree LBs for planted-structure functions are known to be Omega(n^{1/2}) in the unstructured case. This gives quantum LBs "for free" once the classical decision-tree LB is established.

---

## Pipeline Reuse Assessment

### From existing pipeline (optimization LB tools):

| Tool | Origin | Reuse in D1 |
|---|---|---|
| Le Cam reduction (two-point method) | adagrad-norm-nonconvex, OP-2 | Direct reuse: distinguish "conjecture true" vs "counterexample planted" |
| Oracle model formalization (Arjevani style) | OP-2, page-optimal-gradient | Structural template reuse |
| SymPy symbolic verification | Throughout | Verify candidate hard instances |
| Z3 inequality solver | math-verifier | Verify that claimed counterexample actually satisfies f(x*)=0 |

### New elements required for D1:

| Element | Status | Effort |
|---|---|---|
| Rigorous definition of conjecture class (parametric) | New — see above | 1 week |
| Hard distribution construction for chosen model | New — planted Boolean | 1-2 weeks |
| Matching UB algorithm (decision tree) | Mostly standard: adaptive binary search | 0.5 weeks |
| Yao minimax application to LB | Standard tool, new application | 0.5 weeks |
| Generalization to polynomial conjecture model | Extension | Beyond 6 weeks |

---

## Numerical Verification Plan

The math-constructor / math-verifier pipeline (SymPy + Z3 + NumPy) can support D1 as follows:

1. **Decision tree simulation (Python/NumPy):**
   - Implement the planted counterexample oracle for small n (n = 10..50).
   - Simulate randomized adaptive search algorithms.
   - Empirically measure average query counts; compare to theoretical Omega(n).
   - This directly validates the LB construction before formal proof.

2. **Hard instance construction (SymPy):**
   - For polynomial conjecture model: use SymPy to check that the planted x* satisfies p(x*) < 0 (is genuinely a counterexample).
   - For graph model: use NetworkX to generate planted-counterexample graphs.

3. **Z3 verification:**
   - For small parameter regimes, verify that the claimed Omega LB is tight (i.e., no algorithm can do better than the decision tree lower bound predicts).

**Estimated verification cost:** 3-4 days of SymPy/NumPy scripting — very clean by prior pipeline standards.

---

## Upper Bound Landscape (for matching)

| Conjecture model | Best known UB | Gap status |
|---|---|---|
| Boolean planted (unstructured) | O(|D_n|) trivial / O(sqrt(|D_n|)) quantum | Classically: LB = UB; Quantum: likely tight |
| Graph property conjecture | O(n^2) adaptive (read all edges) | Tight if LB Omega(n^2); non-trivial if Omega(n^{3/2}) |
| Polynomial conjecture over [0,1]^d | O(epsilon^{-d}) grid search | LB Omega(epsilon^{-d/2})? Open |

**Recommendation:** Start with Boolean unstructured model where LB = UB is classical and tight. Then attempt graph model for non-trivial separation. The interesting regime is where adaptive algorithms beat oblivious search.
