# Probe 1 — Citation audit of Round 0 and Round 0.5 `best_proof.md`

**Purpose**: classify every load-bearing step in the two archived proofs into I (Independent argument), L (Library citation), or E (External citation, with sub-levels L1/L2/L3).

**Method**: read each step, identify the claim it advances, ask: "If this step's citation were struck out, would the proof still stand?"

- **I** = the argument/computation is produced inside the proof; no appeal to an external or library fact beyond axioms.
- **L** = cited from our own `proofs/library/`. We built these and can audit.
- **E1** = external, ≤30-second/1-line verification (a polynomial identity, an arithmetic fact).
- **E2** = external, one-theorem scope (single named paper/result of modest depth, ~1–2 pages of proof).
- **E3** = external, deep field-spanning machinery (Thurston hyperbolization, Perelman, Gordon–Luecke, Mostow rigidity, Wise, Agol, etc.).

The TSV tag `[CALL:tsv-knot]` is classified as **E1** when the value is in TSV's hardcoded `_KNOT_TABLE` (it is effectively a table lookup against KnotInfo values — 30-second verification against a published table). A TSV call that invokes a non-trivial computation would be classified differently, but the current TSV-Knot module does not do so for these proofs (see Probe 5).

## Proof A — Round 0 `best_proof.md` (Jones polynomial route, copied from `explorer_1_jones.md`)

Steps (as written in proof):

| Step | Claim | Bucket | Sub-level | Notes |
|------|-------|--------|-----------|-------|
| Setup | $3_1 = \widehat{\sigma_1^3}$; $4_1 = \widehat{\sigma_1 \sigma_2^{-1} \sigma_1 \sigma_2^{-1}}$; both oriented | **I** | — | Conventional setup; standard presentation |
| 1 | Kauffman bracket axioms (B1)–(B3), R2/R3 invariance, R1 scales by $-A^{\pm 3}$ | **E2** | — | Cited to Lickorish §3 implicitly; axioms stated, not proven |
| 2 | $\langle 3_1 \rangle = -A^5 - A^{-3} + A^{-7}$ | **E2** + TSV E1 | — | "Standard calculation (e.g., Lickorish §3)" — the 8-state expansion is NOT carried out in the proof; the answer is stated and TSV-verified. Without Lickorish OR TSV, the proof has nothing here. |
| 3 (writhe) | $(-A)^{-9} \cdot \langle 3_1 \rangle$ algebra | **I** | — | Genuinely produced inside the proof; one arithmetic computation |
| 3 (sign-convention pivot) | Explorer got left-handed polynomial; pivots to Lickorish convention to get $-q^{-4}+q^{-3}+q^{-1}$ | **E1 via TSV** | — | The correction is NOT derived; it is "adopt Lickorish's convention" then TSV confirms. TSV lookup in the hardcoded table is the only mechanism that validates the sign flip. **Critical observation**: if TSV's table value is wrong, this proof fails silently. |
| 4 | $V_{4_1}(q) = q^{-2} - q^{-1} + 1 - q + q^2$ | **E2** + TSV E1 | — | "Similar calculation … gives …" — NOT carried out; TSV confirms |
| 5 | Polynomials differ as Laurent polynomials | **I** | — | Polynomial arithmetic, carried out |
| 6 | Jones is an ambient-isotopy invariant ⇒ knots distinct | **E2** | — | Cited to "Jones 1985; standard" |

### Aggregate for Proof A (Round 0, 7 load-bearing items)

| Bucket | Count | Notes |
|--------|-------|-------|
| I (fully independent) | 3 (Setup, Step 3 writhe algebra, Step 5 polynomial comparison) | |
| L (library) | 0 | No library citations in Round 0 (library was empty at the time) |
| E1 (trivial external) | 3 TSV calls | All 4 TSV calls are table lookups against KnotInfo; each is E1 |
| E2 (one-theorem external) | 4 | Kauffman bracket axioms; $\langle 3_1 \rangle$ state-sum result; $V_{4_1}$ state-sum result; Jones invariance theorem |
| E3 (deep machinery) | 0 | No L3 citations in this proof |

**Observation for Proof A**: Steps 2 and 4 (the actual polynomial VALUES) are stated without derivation. Both are E2 citations to "standard textbook calculation". The proof does NOT carry out the state-sum; it carries out only the writhe-normalization arithmetic and the polynomial inequality check. **If you strike out Lickorish and TSV, the proof reduces to: "here is a sign flip, here is polynomial subtraction, Jones is an invariant."**

The "independent reasoning" in this proof amounts to: one 3-line arithmetic computation (writhe normalization) and one 1-line polynomial comparison. Everything else is cited.

## Proof B — Round 0.5 `best_proof.md` (Hyperbolic structure)

Steps (as written in proof):

| Step | Claim | Bucket | Sub-level | Notes |
|------|-------|--------|-----------|-------|
| Setup | Complements as compact oriented 3-manifolds with torus cusps | **I** | — | Standard |
| Setup | Gordon–Luecke: $K \sim K' \iff M_K \cong M_{K'}$ | **E3** | Gordon–Luecke 1989 | Load-bearing for the whole strategy |
| 1 | $3_1 = T(2,3)$ is a torus knot | **E1** | — | 1-line standard identification |
| 1 | Torus knots have explicit Seifert fibration with base $D^2(p,q)$ | **E2** | Birman/Burde–Zieschang | Standard but nontrivial |
| 1 | $\chi_{\text{orb}}(D^2(2,3)) = -1/6$ arithmetic | **I** | — | $1 - 1/2 - 2/3$ |
| 1 | Seifert with $\chi < 0$ ⇒ geometry is $\widetilde{SL}_2(\mathbb{R})$, not $\mathbb{H}^3$ | **E3** | Thurston's Seifert classification | Load-bearing structural fact |
| 2 | $M_{4_1}$ = two regular ideal tetrahedra glued | **E3** | Thurston's Princeton notes §4 | Explicit construction; this is a picture-fact cited as theorem |
| 2 | Ideal tetrahedron with angles $(\alpha,\beta,\gamma)$, $\alpha+\beta+\gamma=\pi$, has volume $\Lambda(\alpha)+\Lambda(\beta)+\Lambda(\gamma)$ | **E2** | Lobachevsky/Milnor | Standard formula |
| 2 | $6\Lambda(\pi/3) \approx 2.02988$ | **I** + TSV E1 | — | One numerical check against TSV's table |
| 3 | Mostow rigidity ⇒ hyperbolic structure topological | **E3** | Mostow 1968 | Load-bearing for argument |
| 4 | Contradiction assembly | **I** | — | Pure logic |
| 5 | Gordon–Luecke closes | **E3** | (same as setup) | Load-bearing |

### Aggregate for Proof B (Round 0.5, 12 load-bearing items)

| Bucket | Count | Notes |
|--------|-------|-------|
| I (fully independent) | 4 (Setup phrasing, $\chi_{\text{orb}}$ arithmetic, volume numerical check, contradiction assembly) | All of these are trivial or 1-line |
| L (library) | 0 | Library's Jones lemmas are not used in Route 3; the `conventions.md` registry is referenced nowhere in this proof |
| E1 (trivial external) | 2 (T(2,3) identification, TSV volume table lookup) | |
| E2 (one-theorem external) | 2 (Seifert fibration of torus-knot complements; ideal-tetrahedron volume formula) | |
| **E3 (deep machinery)** | **4** (Gordon–Luecke [×2 uses of same theorem]; Thurston Seifert classification; Thurston's figure-8 triangulation; Mostow rigidity) | **Four distinct deep theorems in a single proof** |

**Observation for Proof B**: Four E3 citations in a 5-step proof. The "independent reasoning" amounts to: one Euler-characteristic arithmetic, one logical contradiction assembly, one 1-line numerical cross-check. The proof's structural weight is carried entirely by external black boxes.

Striking out the E3 citations leaves: "$3_1$ is a torus knot, $4_1$'s complement has volume $\approx 2.03$" — no argument for inequivalence remains.

## Side-by-side summary

| Metric | Round 0 (Jones) | Round 0.5 (Hyperbolic) |
|--------|-----------------|------------------------|
| Load-bearing steps | 7 | 12 |
| I (independent) | 3 | 4 |
| L (library) | 0 | 0 |
| E1 (trivial external) | 3 | 2 |
| E2 (one-theorem external) | 4 | 2 |
| **E3 (deep machinery)** | **0** | **4** |
| Proof still stands if E3 struck | N/A (no E3) | **No** |
| Proof still stands if all E struck | **No** (loses all polynomial values) | **No** (loses all structural theorems) |
| Proof still stands if TSV struck | Maybe (if textbook values accepted) | Yes (TSV is only numerical anchor, not structural) |

## Finding

Both proofs are **organizationally correct but mathematically thin**. Neither proof carries out the bulk of its own mathematical content:
- Round 0 cites polynomial values from "standard calculation" + TSV table lookup.
- Round 0.5 cites four deep theorems (Gordon–Luecke, Thurston×2, Mostow) as black boxes.

**The pipeline's PASS verdicts are verdicts about *citation organization*, not about *mathematical production*.** Round 0.5 is *more* citation-heavy in absolute deep-machinery terms (4 E3 vs 0 E3) but is considered "geometrically richer" by the Judge — which highlights that the current rubric measures *topic of citation* rather than *independence of argument*.

Hypothesis for Concern 1: **Confirmed.** The PASSes are not independent LDT reasoning — they are organized appeals to external authority, with TSV as a narrow numerical backstop.

*Appended to `ldt_diag_log.md` on 2026-04-20.*
