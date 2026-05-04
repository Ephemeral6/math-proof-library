# Geometry / Low-Dim-Topology Capability Report

**Date:** 2026-04-30
**Scope:** stocktaking of agent's existing geometry/topology output, available
Mathlib modules, external computational tools, and tool-vs-problem matching for
the four questions Prof. Li suggested.

---

## Section 1 — Existing geometry/topology work

The agent already has substantial low-dim-topology (LDT) infrastructure built
out under v2.1 / v2.2 / v2.3 between 2026-04-20 and 2026-04-21. None of it is
in `RESEARCH_INDEX.md` yet — all live artifacts are still in
`workspace/active/`.

### 1.1 Architecture / verifiers (CERTIFIED-IN-USE)

| Asset | Path | Status | One-line summary |
|-------|------|--------|------------------|
| LDT extension log | `workspace/ldt_extension_log.md` | LIVE | 600+ line append-only progress log (Stage 1 → V2.3 Stage 2) |
| Convention registry | `proofs/library/low-dimensional-topology/conventions.md` | LIVE | Jones / Kauffman / Alexander / Burau / Dehn-twist / hyperbolic-volume conventions, single source of truth |
| Architecture doc v2.1 | `workspace/agent_architecture_v2.1_ldt_extension.md` | LIVE | LDT-specific judge, auditor, fixer prompts |
| Architecture doc v2.2 | `workspace/agent_architecture_v2.2_integrator.md` | LIVE | adds Integrator role + integration_check |
| TSV-Knot | `~/.claude/skills/math-verifier/tsv/tsv_knot.py` | CERTIFIED (60 self-tests) | Jones / Kauffman / Alexander / hyperbolic vol for ~10 named knots; Burau-B_2 fallback |
| TSV-Group | `~/.claude/skills/math-verifier/tsv/tsv_group.py` | CERTIFIED | Artin, Dehn-twist commute / braid / lantern / chain — bounded rewriting (NOT a complete decision proc) |
| TSV-Simplicial | `~/.claude/skills/math-verifier/tsv/tsv_simplicial.py` | CERTIFIED | finite local-neighborhood checks, distance upper bounds, flag tests |
| Verified-Sympy protocol | `~/.claude/skills/math-verifier/VERIFIED_SYMPY_PROTOCOL.md` | LIVE | inline-tag protocol; 4 templates + bespoke; auditor-checkable |
| LDT auditor checklist | `~/.claude/skills/math-auditor/ldt_checklist.md` | LIVE | F1–F4 + L1/L2/L3 citation depth + Axis-5 Evidence Field |
| Technique dictionary | `workspace/proof_techniques_ldt.md` | LIVE | 10 LDT techniques (vs 36 for optimization — gap acknowledged) |
| TSV upgrade roadmap | `workspace/diag/TSV_SIMPLICIAL_UPGRADE_ROADMAP.md` | LIVE | 39 capability demands tiered into 5 tiers, MVI scoped |

### 1.2 Past LDT proof attempts

| Target | Source | Working dir | Status | Notes |
|--------|--------|-------------|--------|-------|
| Spiral knots Theorem 3.5 (Alexander factorization) + Theorem 4.2 (genus formula) | Blackwell–Das–Mayer–Moyar–Quraishi–Stees, arXiv:2506.17889 (2025) | `workspace/active/ldt_spiral_knots_stress_test/` | **CERTIFIED Category-A** (independent reconstruction, post-Integrator self-contained) | 2 Fixer rounds; 0 L3 / 4 L2 / 10 L1 / ≥12 Independent steps; 9 verified-sympy scripts (643 cases total) |
| C(S_{1,1}) connectedness | LDT cold-start regression | `workspace/active/ldt_curve_complex_s11/` | **CERTIFIED** | Route D (coherent-resolution surgery) won; 1 Fixer round; 2 L2 citations (FM Prop 1.6 + 1.7); SP-A3 forensically resolved |
| Spiral knots Theorem 4.4 (param-swap = torus iff) | Blackwell et al. arXiv:2506.17889 §4 | `workspace/active/ldt_theorem_4_4/` | **PARTIAL** | accepted via orchestrator option (c); 2 HIGH/STRATEGIC SPs (FIXER-REFUSED-CONFIRMED); 3 reusable fragments extracted by Judge cross-pollination |
| LDT Round 0 (trefoil vs figure-8) | seed diagnostic | `workspace/active/ldt_round0_trefoil_vs_figure8/` + `ldt_round0_5_trefoil_vs_figure8/` | **DIAGNOSTIC** | gap-discovery run; not a target proof |
| Diag torus / Jones recursion | seed | `workspace/active/ldt_diag_torus_jones_recursion/` | **DIAGNOSTIC** | tooling probe |

### 1.3 Library entries on disk (B/C-class)

| Theorem | Path | Class |
|---------|------|-------|
| Jones polynomial of right trefoil | `proofs/library/low-dimensional-topology/knot-invariants/jones-trefoil-right.md` | C |
| Jones polynomial of figure-eight | `proofs/library/low-dimensional-topology/knot-invariants/jones-figure-eight.md` | C |
| Kauffman bracket axioms | `proofs/library/low-dimensional-topology/knot-invariants/kauffman-bracket-axioms.md` | C |

Subfolders that exist but are **README-only** (placeholders, no proofs yet):
braid-group, dehn-twist-relations, hyperbolic-geometry, simplicial-complexes;
under research/: knot-theory, mapping-class-groups, curve-complex, teichmuller-theory, 3-manifolds.

### 1.4 LDT failure patterns recorded

5 entries in `workspace/failure_patterns.md`:

- `FP-KAUFFMAN-CONVENTION-2026-04-20` — TSV silently shipped wrong Kauffman bracket convention with `confidence=high`; root cause was q-vs-t variable mixup (`q = A^4` vs `q = A^{-4}`).
- `FP-SPIRAL-BLOCK-CIRCULANT-BASIS-2026-04-20` — tree basis destroys cyclic symmetry of spiral braid.
- `FP-SPIRAL-SKEIN-LEAVES-FAMILY-2026-04-20` — skein at seam crossing leaves the periodic-braid family.
- `FP-SPIRAL-PRINCIPAL-MINOR-MISFRAMING-2026-04-20` — induction on Burau matrix size must use "word in B_{k+1}", not "principal k×k minor of B_p".
- `FP-SPIRAL-PARAMSWAP-MIXED-CASE-LEVEL1-GAP-2026-04-21` — Theorem 4.4 mixed-sign case has no scaffolding lemma in level-1 library; STRATEGIC SP cannot be closed by Fixer.

### 1.5 What is NOT yet covered

- No work on **non-orientable surfaces** (no `N_{g,n}` infrastructure).
- No **Markoff / Markoff–Hurwitz** number-theoretic machinery.
- No **Kakimizu complex** (Seifert-surface complex).
- No **mapping class group** computations beyond presentation lemmas.
- No **Teichmüller / hyperbolic 3-manifold** numerical work (volume table is hardcoded for ~10 knots).
- No **subsurface projection** or Masur–Minsky machinery.

---

## Section 2 — Mathlib geometry / topology coverage

**Lean toolchain:** `leanprover/lean4:v4.30.0-rc2`
**Mathlib:** `v4.30.0-rc2` (commit 5450b53e)

### 2.1 Available modules (from `.lake/packages/mathlib/Mathlib/`)

**Topology** — broad and deep:
- `Topology/CWComplex/` — CW complexes
- `Topology/Homotopy/{Basic, Equiv, Path, Contractible, HomotopyGroup, LocallyContractible, Lifting, Affine, Product, HSpaces}` — full homotopy theory primitives
- `Topology/MetricSpace`, `EMetricSpace`, `Metrizable`
- `Topology/Connected`, `Compactness`, `Covering`, `FiberBundle`
- `Topology/Sets`, `Constructions`, `Maps`, `Homeomorph`

**AlgebraicTopology**:
- `AlgebraicTopology/SimplicialComplex/` — abstract simplicial complexes
- `AlgebraicTopology/FundamentalGroupoid/` — fundamental group / groupoid
- `AlgebraicTopology/{SimplexCategory, SimplicialObject, SimplicialNerve, SimplicialCategory}`
- `AlgebraicTopology/{ModelCategory, Quasicategory, RelativeCellComplex, DoldKan}`
- `AlgebraicTopology/{TopologicalSimplex, SingularSet, MooreComplex}`

**Geometry**:
- `Geometry/Manifold/{IsManifold, MFDeriv, ContMDiff, IntegralCurve, Algebra, Instances, Sheaf, VectorBundle, VectorField}`
- `Geometry/Manifold/Riemannian/` — Riemannian metric infrastructure
- `Geometry/Euclidean/{Angle, Inversion, Sphere, Volume}`
- `Geometry/Convex/{Cone}`, `Geometry/Polygon`, `Geometry/Group/Growth`, `Geometry/Diffeology`, `Geometry/RingedSpace`

### 2.2 Critical absences

- **No** `Mathlib.Topology.Knot` — no knot diagrams, braid groups as algebraic objects, knot invariants.
- **No** `HyperbolicGeometry` / `HyperbolicSpace` module. Riemannian infrastructure exists; hyperbolic 3-space H^3 is constructible but not pre-built.
- **No** mapping class group, **no** Teichmüller space, **no** curve complex, **no** Kakimizu complex — none of these are first-class Mathlib objects.
- **No** Seifert surface, **no** normal surface, **no** Heegaard splitting.
- **No** Markoff equation (statistics/concentration has nothing relevant; `NumberTheory` does have continued-fraction infrastructure).

### 2.3 Implication for the four problems

Mathlib supports the **scaffolding**: simplicial complexes (Q1, Q3, Q4),
fundamental group / homotopy types (Q1), Riemannian manifold structure (Q2).
But every problem-specific definition (curve complex, Kakimizu complex,
Markoff equation, geodesic length on N_{1,5}) would have to be **hand-built**
on top of Mathlib primitives. None of the four problems is "Lean-formalizable
out of the box".

---

## Section 3 — External computational tools

| Tool | Status | Version | Install path | Notes |
|------|--------|---------|--------------|-------|
| **SnapPy** | ✅ INSTALLED | 3.3.2 | `pip install snappy` (just succeeded on Windows) | Python; hyperbolic 3-manifold computation; knot/link complement structure; covers Q3/Q4 needs. Earlier attempt (2026-04-20) failed with network timeout — has now succeeded. |
| **curver** | ✅ INSTALLED | 0.5.1 | `pip install curver` (just succeeded) | Python; mapping class group + curves on surfaces; intersection numbers; covers Q1 directly. |
| **flipper** | ❌ NOT INSTALLED | — | `pip install flipper` (separate, did not auto-install) | Python; pseudo-Anosov flipper algorithm; complements curver. Optional for Q1. |
| **Regina** | ❌ NOT INSTALLED | — | Native binary; download from regina-normal.github.io OR `apt install regina-normal` on WSL | Normal-surface enumeration, 3-manifold triangulations; required for Kakimizu complex enumeration in Q3/Q4. |
| **SageMath** | ❌ NOT INSTALLED | — | WSL: `apt install sagemath`; or use the standalone Windows installer (≥2 GB) | Markoff-equation symbolic / number-theoretic tools (Q2); also has knot-theory & graph modules. |

### 3.1 Current install verdict

**Newly available (today):** SnapPy + curver. These cover the bulk of needed
computational power for Q1 (curver), Q3 (SnapPy + Regina), Q4 (SnapPy + Regina,
plus KnotInfo).

**Still missing:** Regina, SageMath. Both are heavy installs; recommended via
WSL Ubuntu rather than native Windows.

### 3.2 Quick capability sketch of newly installed tools

- **SnapPy 3.3.2** (Python): `Manifold("4_1")` gives figure-eight knot complement; `.volume()`, `.fundamental_group()`, `.identify()`, `.symmetry_group()` all work. Has the LinkExteriors and HTLinkExteriors knot censuses (~1.7M knots). For Q4 specifically, it can iterate over genus-2 knots in the census.
- **curver 0.5.1** (Python): `curver.load(genus, punctures)` gives a triangulated surface; mapping class group elements and intersection-number primitives; explicit curve representation. Directly suitable for Q1 explicit small-case checks.

---

## Section 4 — Per-problem tool match + feasibility

### Q1 — homotopy type of the 1-curve complex

**Math summary.** Let S = orientable surface, possibly punctured. The
*1-curve complex* C^1(S) has vertices = isotopy classes of essential SCC,
and a k-simplex for every (k+1)-tuple of curves with pairwise geometric
intersection ≤ 1 (Farey-graph generalization). Question: what is its
homotopy type?

**Reference compass.**
- Harvey 1981 — original curve complex.
- Hatcher 1991 (arc complex contractibility) — toolbox.
- Hensel–Przytycki–Webb 2015 — uniform hyperbolicity of curve complex.
- Wajnryb / Schleimer arc-graph results — relevant for connectedness.

**Existing agent capacity.** **High.** The C(S_{1,1}) connectedness
proof is already CERTIFIED. The agent has Routes B (intersection-number
induction) and D (coherent-resolution surgery) battle-tested.
TSV-Simplicial handles finite local checks; the Verified-Sympy protocol
handles small-parameter empirical certification.

**Tools needed beyond what's installed.** Probably none for the
S_{1,1} / S_{0,4} / S_{1,2} small-genus cases. For higher-genus the
agent can still proceed with citations + finite-case sympy.

**Verdict.** **Most accessible** of the four. Recommended first target.

---

### Q2 — N_{1,5} geodesics + Markoff–Hurwitz

**Math summary.** N_{1,5} = non-orientable surface of genus 1 with 5
cross-caps (or equivalently with 5 punctures depending on convention).
Length spectrum of geodesics relates to a Markoff–Hurwitz Diophantine
equation $x_1^2 + \cdots + x_n^2 = a x_1 \cdots x_n$.

**Reference compass.**
- Markoff 1879 — original triple equation $x^2+y^2+z^2=3xyz$.
- Hurwitz 1907 — generalization.
- Cohn 1955, Springborn 2017 — geodesic / Markoff bijection.
- Goldman 2003 — Markoff dynamics on character varieties.
- For non-orientable: Norbury, Stantchev — character varieties of N_{g}.

**Existing agent capacity.** **None.** Zero prior non-orientable surface
work. tsv_simplicial does not handle non-orientable; tsv_knot is knot-only.

**Tools needed.**
- **SnapPy** (✅ now installed) — for the orientation double-cover ̃N_{1,5}
  (an orientable surface). SnapPy operates on orientable manifolds, so the
  non-orientable case must be lifted.
- **SageMath** (❌) — for Markoff equation symbolic work, character variety
  computation, integer-point enumeration on the Markoff surface.
- Number-theoretic Diophantine handling — partly covered by SymPy; SageMath
  is much stronger.

**Verdict.** **Hardest tool barrier.** Mathematically deepest. Requires
SageMath install AND substantial new library buildout (non-orientable
surface infrastructure, Markoff-surface dynamics).

---

### Q3 — Kakimizu complex + Gromov hyperbolicity

**Math summary.** Kakimizu complex KC(K) of a knot K: vertices =
isotopy classes of minimal-genus Seifert surfaces; edges = disjoint
pairs (and higher simplices for collections of pairwise disjoint
representatives). Question: when is KC(K) Gromov-hyperbolic, or
"quasi-Euclidean", or contractible?

**Reference compass.**
- Kakimizu 1992 — definition.
- Sakuma–Shackleton 2009 — finiteness of diameter for hyperbolic knots.
- Schultens 2010 — connectedness + initial diameter bounds.
- Johnson–Kotschick 2013, Banks 2011 — explicit diameters for small knots.
- Recent: Iijima, Ozawa — Kakimizu complex of cable knots.

**Existing agent capacity.** **Partial.** The agent has Seifert-surface
familiarity from the spiral-knot work (Theorem 4.2 was the genus formula);
tsv_knot has Alexander polynomial + signature. But no Kakimizu-complex
machinery.

**Tools needed.**
- **Regina** (❌) — *required* for normal-surface enumeration. Seifert
  surfaces of genus g are codimension-1 normal surfaces in the knot
  complement; Regina can enumerate them explicitly and detect isotopy.
- **SnapPy** (✅) — for the knot complement's hyperbolic structure +
  fundamental group, used as a sanity check.

**Verdict.** **Concrete, computable for specific knots.** The general
Gromov-hyperbolicity question is open / partially answered. The agent
can either (a) attempt the conceptual proof citing Sakuma–Shackleton,
or (b) compute KC(K) for specific knots via Regina and verify
hyperbolicity empirically. Either path requires Regina.

---

### Q4 — diameter of Kakimizu complex for genus-2 knots ≤ 8

**Math summary.** Conjecture: for every knot K of Seifert genus exactly 2,
diam KC(K) ≤ 8. (Possibly already a theorem; check Banks 2011 / Schultens
2010 for the genus-2 case.)

**Reference compass.**
- Banks 2011 — diameter bounds for genus-1 (= 2g) and small genus.
- Schultens 2010 — KC connectedness + general diameter machinery.
- KnotInfo — has Seifert genus column; ~80–120 prime knots of genus 2 in
  the standard tables (depends on crossing-number cutoff).

**Existing agent capacity.** **None for KC**, but SnapPy + KnotInfo
gives the genus-2 enumeration directly.

**Tools needed.**
- **SnapPy** (✅) — KnotInfo / HTLinkExteriors filtering by Seifert genus.
- **Regina** (❌) — *required* to compute KC(K) for each genus-2 knot.

**Verdict.** **Most concrete / falsifiable** of the four. Once Regina is
installed, the conjecture is mechanically checkable on the entire
genus-2 census; either it confirms uniformly, or it produces an
explicit counterexample knot. This is the most "agent-friendly"
formulation: clear computational test → either a verified bound or a
disproof.

---

## Section 5 — Recommendations

### 5.1 Tool installation priority

1. **flipper** (pip-installable on Windows; complements curver for Q1). Cost: ~30s. Risk: low.
2. **Regina** (required for Q3 and Q4). Recommended path: WSL Ubuntu + `apt install regina-normal` (~5 min). Native Windows installer also exists at regina-normal.github.io. **High value:** unlocks both Q3 and Q4.
3. **SageMath** (required for Q2 Markoff machinery). Recommended path: WSL + `apt install sagemath` (~15 min, ~3 GB). **Defer until Q2 is committed-to** — Sage is a heavy dependency.

### 5.2 Problem-attempt priority

Ranked by feasibility × value:

| Rank | Problem | Why first / why later |
|------|---------|----------------------|
| 1 | **Q4** (genus-2 KC diameter ≤ 8) | Concrete, falsifiable, mechanical check across genus-2 census. Output is a verifiable yes/no with explicit knot-by-knot data. **Best agent fit.** Blocks on Regina install. |
| 2 | **Q1** (1-curve complex homotopy) | Agent already has curve-complex infrastructure; high reuse from C(S_{1,1}) success. Less concrete payoff than Q4 but lowest tool barrier. |
| 3 | **Q3** (KC Gromov hyperbolicity) | Builds directly on Q4 work. Conceptually deeper; depends on which subclass of knots is targeted. Blocks on Regina install. |
| 4 | **Q2** (N_{1,5} + Markoff) | Hardest tool barrier (needs Sage), deepest math (non-orientable + number theory), zero prior infrastructure. Defer. |

### 5.3 Suggested next concrete actions

If the user picks **Q4**, the immediate steps are:

1. Install Regina (WSL or Windows native).
2. Build a small Python script that, for each genus-2 knot in HTLinkExteriors, enumerates its minimal-genus Seifert surfaces via Regina and computes pairwise disjointness.
3. Construct KC(K) as a finite simplicial complex, compute graph diameter.
4. If max diameter ≤ 8 across the census: this is empirical evidence. The agent then attempts a proof citing Banks / Schultens.
5. If a knot violates: produce the explicit counterexample.

If the user picks **Q1**, the immediate steps are:

1. Run a Scout pass on the 1-curve complex of S_{0,5} or S_{1,2} (the simplest non-trivial cases beyond the agent's done work).
2. Use curver to enumerate small curve representatives + intersection numbers as TSV-Simplicial input.
3. Apply the existing C(S_{1,1}) Route-D machinery + adapt to i ≤ 1 instead of i = 0 edge condition.

### 5.4 Honest caveats

- **TSV-Knot is table-based.** The seven-knot table + Burau-B_2 fallback is the entire generic-knot Jones machinery; for knots not in the table, the verifier returns `out-of-scope` with `confidence=low`. Q4 will repeatedly hit this for higher-crossing genus-2 knots.
- **TSV-Simplicial is local-only.** Global Gromov-hyperbolicity, asymptotic dimension, etc. are out-of-scope; Q3 will require `[REF:external]` citations for the global structural theorems.
- **TSV-Group is bounded rewriting.** Not a complete decision procedure; word-equality checks beyond depth ~6 may return `confidence=medium`.
- **All four problems will trigger the L3-citation watchdog** if proofs lean on Masur–Minsky / Hensel–Przytycki–Webb / Schultens machinery as black boxes. STRUCTURAL-CITATION-WARNING firing is not a blocker, but the agent will flag the gap explicitly.
- **Mathlib formalization for any of these is a research-grade project on its own.** Do not promise Lean-verified output for Q1–Q4 in the short term.

---

## Section 6 — One-line summary

The agent has solid LDT proof-pipeline infrastructure (CERTIFIED on
spiral-knots Theorems 3.5/4.2 and on C(S_{1,1}) connectedness) plus
SnapPy + curver now installed, which makes **Q4 (concrete diameter
check) and Q1 (homotopy type, reusing existing curve-complex routes)**
the two immediately tractable starting points; Q3 is reachable after
a Regina install; Q2 is the deepest and should be deferred until
SageMath is in place.
