# D1 Literature Survey: Counterexample Construction Query-Complexity Lower Bound

## Search date: 2026-04-28

---

## Core Question Addressed

Is there a query-complexity theory of *counterexample finding* for mathematical conjectures, or only of property testing? Short answer: **the specific framing is largely absent from the literature — a genuine gap exists**. Existing work splits into (a) property testing (testing membership in a fixed class), (b) average-case refutation complexity (SOS/low-degree lower bounds for random CSPs), and (c) empirical MCMC-style conjecture falsifiers. None of them study query-complexity lower bounds for a search algorithm that queries an oracle to find a counterexample to a parametric conjecture family.

---

## Paper Survey (6–10 papers, 2020–2026)

### 1. FunSearch — Mathematical discoveries from program search with large language models
- **Authors:** Romera-Paredes et al. (Google DeepMind)
- **Venue:** *Nature* 636, 2023 (published December 2023)
- **URL:** https://www.nature.com/articles/s41586-023-06924-6
- **Relevance:** FunSearch pairs an LLM with an evaluator to search the space of programs for mathematical constructions. Applied to the cap set problem, it found new lower-bound constructions exceeding the best known bounds for 20 years. It is not a query-complexity lower bound paper — it is an upper-bound algorithm — but it motivates the UB side: how many "function evaluations" (oracle calls) does a program-guided search need? The gap is that no corresponding LB theory exists.
- **Key point for D1:** FunSearch is an oracle/evaluator model for construction search. The question "what is the Omega-LB on queries needed to refute a cap set conjecture?" is *exactly* the dual question FunSearch does not address.

### 2. Adaptive Monte Carlo Search for Conjecture Refutation in Graph Theory
- **Authors:** Valentino Vito, Lim Yohanes Stefanus
- **Venue:** arXiv:2306.07956, June 2023
- **URL:** https://arxiv.org/abs/2306.07956
- **Relevance:** Proposes AMCS (Adaptive Monte Carlo Search), a MCTS-based algorithm for finding counterexamples to graph theory conjectures. Refutes 6 open conjectures, including 4 from AutoGraphiX. The paper is purely algorithmic (UB). It works in the model where the algorithm can query an objective function (conjecture score) on a graph. **No lower bounds are proven.** The query count per refutation is measured empirically but not analyzed theoretically.
- **Key point for D1:** Provides a natural oracle model (graph queries, score oracle) that D1 could formalize and prove LBs for.

### 3. Refutation of Spectral Graph Theory Conjectures with Search Algorithms
- **Authors:** Roucairol, Cazenave (and follow-up 2024 arXiv:2409.18626)
- **URL:** https://www.arxiv.org/pdf/2409.18626
- **Relevance:** Uses NMCS/NRPA algorithms to refute spectral graph theory conjectures. Again purely UB/empirical. Establishes the genre that D1 wants to bound from below.

### 4. A New Minimax Theorem for Randomized Algorithms (Ben-David & Blais)
- **Authors:** Shalev Ben-David, Eric Blais
- **Venue:** *Journal of the ACM*, November 2023
- **URL:** https://cs.uwaterloo.ca/~s4bendav/publication/bb-23/
- **arXiv:** https://arxiv.org/abs/2002.10802
- **Relevance:** Extends Yao's minimax principle to a single hard distribution that works for *all bias levels simultaneously*, applicable to randomized query complexity, randomized communication complexity, quantum query complexity, approximate polynomial degree. This is the sharpest version of the tool that D1 would use to prove lower bounds. Published 2023 in JACM — directly reusable.
- **Key point for D1:** Core technical tool. The "hard distribution" for a conjecture-refutation oracle would be constructed over the space of conjecture instances; this theorem then gives Omega-LBs uniformly.

### 5. Separations in Query Complexity for Total Search Problems
- **Authors:** Shalev Ben-David, Srijita Kundu
- **Venue:** arXiv:2410.16245, October 2024
- **URL:** https://arxiv.org/abs/2410.16245
- **Relevance:** Studies the query complexity analogue of TFNP (total search problems with guaranteed solutions). Gives exponential separation between quantum query complexity and approximate degree for total search problems. "Counterexample finding" for a parametric conjecture is naturally modeled as a TFNP search problem (solutions always exist when the conjecture is false). The LB machinery developed here is partially portable.
- **Key point for D1:** The TFNP query model is a natural fit for conjecture refutation (when the conjecture is false, a counterexample is guaranteed to exist). D1 can inherit the separation techniques.

### 6. The Query Complexity of Certification (Beigi, Shor, Sra et al.)
- **Authors:** various (arXiv:2201.07736, 2022)
- **URL:** https://arxiv.org/abs/2201.07736
- **Relevance:** Studies the problem: given a Boolean function f with certificate complexity k, find a certificate of size k using as few adaptive queries as possible. Proves O(k^8 log n) UB and Omega(k log n) LB. "Finding a counterexample" is closely related: finding a 0-certificate for a conjecture function. The LB proof uses information-theoretic arguments.
- **Key point for D1:** The "find certificate" model is a special case of "find counterexample" when the conjecture is a monotone Boolean function. D1 would generalize beyond monotone/Boolean to polynomial or combinatorial inequalities.

### 7. Approximate Degree Lower Bounds for Oracle Identification Problems
- **Authors:** Ben-David, Kundu et al.
- **Venue:** TQC 2023 / arXiv:2303.03921
- **URL:** https://arxiv.org/abs/2303.03921
- **Relevance:** Proves Omega(n / log^2 n) approximate degree LBs for hidden string problems. Hidden string = "find the string satisfying a property" — structurally similar to "find the counterexample to a conjecture parameterized by n." Approximate degree LBs immediately yield quantum query LBs.

### 8. Counterexamples to the Low-Degree Conjecture (Hopkins)
- **Authors:** Sam Hopkins
- **Venue:** arXiv:2004.08454 (ITCS 2021)
- **URL:** https://arxiv.org/abs/2004.08454
- **Relevance:** Refutation of a specific conjecture about low-degree polynomials and statistical algorithms. Demonstrates that refutation of algorithmic conjectures is itself a research problem. The broader program of Schramm-Wein (2022) provides low-degree lower bounds for refutation of random CSPs — "refutation lower bounds" in the average-case complexity sense. This is adjacent to but distinct from D1's query-complexity framing.

### 9. An Exponential Separation Between Quantum Query Complexity and Polynomial Degree (CCC 2023)
- **Authors:** see https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.CCC.2023.24
- **URL:** https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.CCC.2023.24
- **Relevance:** Demonstrates limits of the polynomial method for proving query lower bounds. Relevant to D1 because the polynomial method (Aaronson-Shi) is the main quantum lower bound tool; this separation shows it does not always work, which means D1's classical decision-tree LBs would be technically distinct and potentially stronger.

---

## Gap Assessment

**The specific framing of D1 is genuinely novel.** The literature splits into:

| Stream | Query LBs for conjectures? | Relevant to D1? |
|---|---|---|
| Property testing (Goldreich-Ron) | No — tests membership, not refutes conjectures | Partial: framework reusable |
| Certification query complexity | Partial — finds certificates for fixed functions | Yes: special case |
| TFNP query complexity (Ben-David) | Yes — total search problems | Yes: directly applicable |
| MCTS conjecture refutation (empirical) | No — UBs only, no theory | Motivates oracle model |
| Average-case refutation (SOS/low-degree) | No — not query model | Adjacent only |
| FunSearch / AlphaProof (LLM search) | No — oracle calls not analyzed | Motivates the question |

**Conclusion:** There is no paper that proves Omega query-complexity lower bounds for a parameterized family of counterexample-finding problems in the style of Arjevani et al. oracle lower bounds for optimization. The gap is real.
