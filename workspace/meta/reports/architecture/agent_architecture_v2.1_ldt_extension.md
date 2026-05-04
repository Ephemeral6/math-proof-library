# Math Agent Architecture v2.1 — LDT Extension

> Extension document. Does NOT modify the frozen `agent_architecture_v2.md`.
>
> Created: 2026-04-20.  Author: LDT extension Stage 1.
>
> **All design choices here are hypotheses. Round 0 (Stage 2) will falsify some of them, and Stage 3 will apply the top-3 fixes. This document is a Stage-1 snapshot, not a final design.**

---

## 1. What v2.1 adds over v2

The V2 pipeline (Scout → Explorer×N → Judge → Auditor ⇄ Fixer) is unchanged. The auditor's Step 0.5 (reverse-consistency check), `[REF:]` library references, `CALL` markers, cross-verification, and verification-annotation tags are all preserved.

v2.1 adds a **seventh research domain**: low-dimensional-topology (LDT), covering the five collaborator keywords 曲线复形 / 映射类群 / Teichmüller 理论 / 纽结理论 / 三维流形. The changes are domain-specific additions — no existing mechanism is altered.

### Summary of additions

| Component | v2 state | v2.1 addition |
|-----------|----------|---------------|
| `proofs/research/` | 6 domains | + `low-dimensional-topology/{knot-theory, mapping-class-groups, curve-complex, teichmuller-theory, 3-manifolds}/` with README stubs |
| `proofs/library/` | 6 domains | + `low-dimensional-topology/{knot-invariants, braid-group, dehn-twist-relations, simplicial-complexes, hyperbolic-geometry}/` with README stubs |
| `math-verifier` | 3 legs: SymPy, Z3, NumPy | + 4th leg: TSV (Topological Structure Verifier) with `tsv_knot.py`, `tsv_group.py`, `tsv_simplicial.py` |
| `math-problem-generator` | 6 rotation directions | + 7th direction (LDT), weight 10–15%.  New `ldt_seeds.md` with 18 candidate problems |
| Scout dictionary | `proof_techniques_summary.md` | + `workspace/proof_techniques_ldt.md` (10 seeded techniques) |
| Auditor | single `auditor.md` prompt | + `math-auditor/ldt_checklist.md` with 8 LDT-specific items (A–H) |
| `failure_patterns.md` | flat list | + `domain` / `subdomain` tag schema; grep-addressable by tag |

---

## 2. Component-by-component details

### 2.1 Directory structure (§1.1 of task brief)

Under `proofs/research/low-dimensional-topology/`:
- `knot-theory/` — Jones / Alexander / Khovanov research results
- `mapping-class-groups/` — MCG subgroups, cohomology, quasi-morphisms
- `curve-complex/` — hyperbolicity, subsurface projection, boundary
- `teichmuller-theory/` — geodesic flow, extremal length, moduli-space volumes
- `3-manifolds/` — geometrization consequences, Heegaard splittings, hyperbolic volume

Under `proofs/library/low-dimensional-topology/`:
- `knot-invariants/` — computations for named knots
- `braid-group/` — Artin relations, Burau representation
- `dehn-twist-relations/` — braid / chain / lantern
- `simplicial-complexes/` — finite subcomplex / flag / link facts
- `hyperbolic-geometry/` — hyperbolic isometries, Margulis, volume formulas

Each leaf has a README.md that specifies what belongs there and what does NOT. A proof is archived to the branch matching the keywords in its `problem.md`.

### 2.2 TSV — fourth verifier leg (§1.2)

Located at `~/.claude/skills/math-verifier/tsv/`:
- `tsv_knot.py` — Jones, Alexander, Kauffman bracket, hyperbolic volume, KnotInfo lookup, Reidemeister-equivalence heuristic
- `tsv_group.py` — B_n Artin relations, Farb–Margalit relations, symbolic Dehn-twist action
- `tsv_simplicial.py` — finite simplicial complex, flag condition, distance-upper-bound witness, local C(S) neighborhood

All three submodules return `(value, tag_dict)` following the V2 verifier protocol. Tags include `method`, `submethod`, `confidence ∈ {high, medium, low}`, and optional `reason`. Out-of-scope calls return `method="none", confidence="low"` — callers must propagate `[VERIFIED: method=none, confidence=low, reason=...]` rather than faking a verification.

**Honest scope**: TSV-Simplicial is toy-level (only finite subcomplexes); SnapPy is absent on this machine (hyperbolic volume uses a 10-knot hardcoded table); generic-braid Jones is not implemented outside the named-knot table. See `tsv/README.md` for the full scope matrix.

The main `math-verifier/SKILL.md` was updated to document TSV as Mode 4, including Auto-mode routing (topology claims → TSV).

### 2.3 Problem generator (§1.3)

`math-problem-generator/SKILL.md` was edited to add direction 7 (LDT) with 10–15% rotation weight. `math-problem-generator/ldt_seeds.md` holds 18 seed problems tagged by keyword across C / B / A classes. The generator consults this list on LDT rounds until the library matures enough to synthesize new problems from existing entries.

### 2.4 Scout technique dictionary (§1.4)

`workspace/proof_techniques_ldt.md` seeds 10 techniques across the five keywords. Explicitly acknowledges that the dictionary is thin and will grow as library entries archive. Scout's Step 0a (technique lookup) reads this file alongside `proof_techniques_summary.md` when the domain is LDT.

### 2.5 LDT Auditor checklist (§1.5)

`~/.claude/skills/math-auditor/ldt_checklist.md` adds 8 LDT-specific audit items:
- **A.** Isotopy vs. equivalence distinction
- **B.** Orientation check (mirror, reverse)
- **C.** Dimension check (3D vs. 4D)
- **D.** Compactness / infinitude check (curve complex is infinite!)
- **E.** Group presentation consistency
- **F.** Literature cross-check (hyperbolic constants vary)
- **G.** Picture-proof handling (attempt TSV; else PARTIAL)
- **H.** Geometric-intuition assessment (0–5 scale; explicit collaborator criterion)

Run alongside the V2 auditor prompt, not as a replacement.

### 2.6 Failure-pattern schema (§1.6)

`workspace/failure_patterns.md` gained an entry template with `domain` and `subdomain` tags. Single file preserved; grep by tag enables filtering. Existing pre-2026-04-20 entries are grandfathered without tags; new entries follow the template.

---

## 3. What is UNCHANGED

Explicit list so reviewers don't have to hunt:
- Five-phase pipeline: Scout → Explorer×N → Judge → Auditor ⇄ Fixer
- Auditor Step 0.5 reverse-consistency check
- `[REF:]` library-reference protocol in Explorer
- `[CALL:math-verifier]` / `[CALL:math-constructor]` markers
- Verification annotation tags (`[VERIFIED:...]`, `[NEEDS-VERIFY]`, `[UNVERIFIABLE]`)
- Cross-verification table in Auditor output
- Step F failure-mode extraction
- Difficulty-adaptive Explorer count and audit round limits
- Scoring rubric (A/B/C/D/E dimensions)
- All 6 pre-existing domains and their existing proofs (89+ total)

---

## 4. Known limitations (Stage 1 snapshot)

1. **TSV-Simplicial is toy-level.** Only finite local subcomplexes. Cannot verify global properties of C(S) (Masur–Minsky hyperbolicity, asymptotic dimension, Gromov boundary).
2. **SnapPy is not installed** on this machine (network-install timeout). `tsv_knot.hyperbolic_volume` falls back to a hardcoded 10-knot reference table. Out-of-table queries return `out-of-TSV-scope`.
3. **Generic-braid Jones/Alexander** is not implemented. Table match required, with a Burau fallback for n = 2 strands only. Arbitrary braid-word → invariant is `out-of-TSV-scope`.
4. **Technique dictionary starts thin.** 10 seeded items vs. 36 in the optimization dictionary. Scout WILL recommend routes that draw on techniques outside this list; these must be tagged `[TECHNIQUE-NEW]` and absorbed at Step F.
5. **LDT library starts empty.** The `[REF:]` mechanism produces no matches in LDT proofs. Explorer cannot rely on lemma reuse until the library has a few entries.
6. **Evaluation runs INDEPENDENTLY** from the main V2 score. The LDT domain is rated on a simplified rubric for Round 0; do NOT merge into the 89-proof score until a stable body of LDT proofs exists.
7. **TSV's Reidemeister-equivalence heuristic never returns `True`.** It returns `False` (when invariants disagree) or `"unknown"` (when they agree — only probabilistic). A `True` answer would require Khovanov / concordance tools not in scope.
8. **GAP is not installed** — TSV-Group's word-problem decision is bounded-rewriting, not Garside normal form. Undecidable cases return `"unknown"`.

---

## 5. Risks and hypotheses to be falsified in Round 0

Each of the following is a hypothesis, not a claim. Round 0 will tell us which hold.

- **H1**: Scout reading `proof_techniques_ldt.md` will produce at least one route using a listed LDT technique.
- **H2**: At least one Explorer will call TSV (any submode) during the proof.
- **H3**: Auditor's LDT checklist will flag at least one item (A–H) on the Round 0 proof.
- **H4**: The V2 auditor's Step 0.5 reverse-consistency check will NOT fire (trefoil vs. figure-eight has no conflicting quantitative bounds).
- **H5**: If Explorer produces a picture argument, Fixer will succeed in reformulating at least one of them via TSV.
- **H6**: The final verdict will be PASS, PARTIAL, or FAIL — and whichever it is, we will have a gap report worth acting on.

Round 0's value is in which hypotheses break.

---

## 6. Explicit acknowledgment

**All design choices here are hypotheses. Round 0 will falsify some of them.**

Stage 3 will apply the top-3 highest-impact fixes. Items NOT fixed in Stage 3 remain open and will be revisited in future rounds once a body of 3–5 LDT proofs exists.

---

## 7. File manifest (v2.1 deliverables from Stage 1)

Created:
- `proofs/research/low-dimensional-topology/{knot-theory, mapping-class-groups, curve-complex, teichmuller-theory, 3-manifolds}/README.md` (5 files)
- `proofs/library/low-dimensional-topology/{knot-invariants, braid-group, dehn-twist-relations, simplicial-complexes, hyperbolic-geometry}/README.md` (5 files)
- `~/.claude/skills/math-verifier/tsv/tsv_knot.py`
- `~/.claude/skills/math-verifier/tsv/tsv_group.py`
- `~/.claude/skills/math-verifier/tsv/tsv_simplicial.py`
- `~/.claude/skills/math-verifier/tsv/README.md`
- `~/.claude/skills/math-problem-generator/ldt_seeds.md`
- `~/.claude/skills/math-auditor/ldt_checklist.md`
- `workspace/proof_techniques_ldt.md`
- `workspace/agent_architecture_v2.1_ldt_extension.md` (this file)
- `workspace/ldt_extension_log.md` (progress log, stage checkpoints)

Modified:
- `~/.claude/skills/math-verifier/SKILL.md` (added TSV as Mode 4)
- `~/.claude/skills/math-problem-generator/SKILL.md` (added direction 7)
- `workspace/failure_patterns.md` (added v2.1 entry template)

Unchanged:
- `workspace/agent_architecture_v2.md` (frozen)
- All `math-proof-agent/prompts/*` — Auditor, Scout, Explorer, etc.
- All pre-existing `proofs/` entries (85+ proofs)
- All pre-existing `workspace/` evaluation files
