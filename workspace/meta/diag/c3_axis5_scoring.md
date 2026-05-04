# Probe 3 — Applying judge_ldt.md Axis 5 to the vocabulary-bluff proof

**Input**: `c3_vocabulary_bluff_proof.md` (the bluff proof of $3_1 \not\sim 4_1$ opening with Teichmüller/MCG/Masur–Minsky vocabulary, reducing to Alexander-determinant comparison, closing with invented Teichmüller-length claim).

**Method**: apply `judge_ldt.md` Axis 5 rubric as if scoring this proof without knowing it is a bluff. Then assess whether the rubric's text contains any mechanism that would catch the bluff.

---

## Axis 5 rubric (verbatim from `judge_ldt.md`)

```
Scale:
- 10 — proof directly engages the geometric/topological structure: uses
  a hyperbolic structure, a triangulation, a foliation, a mapping-class-group
  action on a curve complex, a Teichmüller-space argument, or an explicit
  visualization of the 3-manifold/knot/surface.
- 8 — proof uses a geometric invariant (e.g., hyperbolic volume, genus,
  Heegaard splitting) but without deep engagement with the structure.
- 6 — proof uses a combinatorial or diagrammatic invariant (e.g., state
  sum on a diagram, skein relation) where the diagram represents the object
  but the proof is combinatorial.
- 4 — proof uses an algebraic invariant (e.g., Jones polynomial via
  Kauffman bracket; Alexander polynomial via Burau) computed from a presentation
  without use of geometric structure.
- 2 — proof is pure algebra (e.g., braid-word manipulation, matrix
  calculations over Z[t, t^{-1}]) without any reference to the
  topological meaning.
- 0 — proof doesn't actually engage the LDT content at all.
```

## Literal-rubric scoring of the bluff proof

Stage-by-stage match to rubric levels:

- **Level 10**: requires "hyperbolic structure, triangulation, foliation, MCG action on curve complex, Teichmüller-space argument, or explicit visualization".
  - The bluff proof *opens* by naming **MCG action on Farey graph $\mathcal{C}(S_{0,4})$** and **Teichmüller-space argument** (via $\mathcal{T}(S_{0,4}) / \mathrm{MCG}$).
  - It *names* an **invariant train track** (a foliation/train-track object).
  - Level 10 says "uses ... a Teichmüller-space argument". The bluff proof uses Teichmüller-space vocabulary. The literal rubric does not distinguish "uses" from "names".

- **Level 8**: requires "geometric invariant without deep engagement".
  - The bluff proof invokes the Teichmüller metric and claims to extract a length ratio from it.

- **Level 6**: "combinatorial or diagrammatic invariant".

- **Level 4**: "algebraic invariant (Alexander polynomial via Burau) without use of geometric structure".
  - The **actual logical content** (Steps 3–4) is exactly this: Alexander polynomial comparison via determinants.

### Scoring dilemma for a rule-following Judge

The proof presents as level 10 (uses Teichmüller, MCG, train tracks, curve complex). Under the level-10 wording — "uses a Teichmüller-space argument" — the opening paragraph qualifies. A rule-following Judge applying the rubric text literally would score **9/10 or 10/10**.

A Judge who applied the rubric *intent* (does the proof actually engage the structure?) would score **4/10** at most: the real logical content is determinant comparison, which is level 4.

**The rubric text has no mechanism that would prompt a Judge to apply the intent reading instead of the literal reading.** It does not say "check that the invoked geometric structure actually participates in the argument", does not say "trace each load-bearing step back to one of the geometric objects invoked", does not say "test coherence of geometric-to-algebraic transitions".

### Likely scoring outcome: 8/10 or 9/10

Under charitable literal reading: **9/10 × 1.5 = 13.5/15 on Axis 5**.

Under minimally-skeptical literal reading: **8/10 × 1.5 = 12/15 on Axis 5**.

Both beat the real Round 0 winner (Jones proof, 4/10 × 1.5 = 6/15 on Axis 5) and match the real Round 0.5 winner (hyperbolic proof, 9/10 × 1.5 = 13.5/15).

## Does the rubric contain bluff-catching mechanisms?

Review of `judge_ldt.md` text for bluff-catching language:

- **Axis 5 rubric itself**: no bluff-catching mechanism.
- **"Close-call secondary audit" rule**: if top two routes within 5 points, audit both. Does not apply here (single-proof Probe).
- **"Multiplier rationale" paragraph**: says "a proof that gets the right answer by unrelated algebra satisfies the letter of the theorem but not the spirit". This language is **aspirational but non-operational** — it does not tell a Judge how to detect the case.
- **"Fall back to `judge.md`" footer**: does not apply; proof is clearly LDT.

Nothing in `judge_ldt.md` equips a Judge to catch a proof that:
1. Opens by naming a geometric structure.
2. Pivots to algebra without logical connection.
3. Closes by naming a geometric structure again.

The rubric does not require Judge to verify the geometric structure is ACTUALLY USED between invocations.

## Auditor-side safety net

Could the LDT Auditor checklist catch this? Review of `ldt_checklist.md`:

- **Item A (isotopy vs equivalence)**: not triggered.
- **Item B (orientation)**: not triggered.
- **Item D (compactness/infinitude)**: **could trigger**. The bluff proof invokes $\mathcal{T}(S_{0,4})$ (non-compact), MCG (infinite), curve complex (infinite). D says "confirm the object being limited IS compact. Red flag: 'consider the finite subcomplex of C(S)...' without specifying HOW it's finite." The bluff proof does not explicitly invoke compactness/limits, so a strict reading of D does not trigger.
- **Item E (group presentation)**: **could trigger on Step 1**. The bluff proof asserts transition matrices for $3_1$ and $4_1$ without specifying a presentation or translating between presentations. But item E requires the presentation to *change mid-proof*; here, no presentation is explicitly stated, so there is no change to flag.
- **Item F (literature cross-check)**: Bluff proof cites "Masur–Minsky subsurface projection" and "Birman–Hilden". Neither is a specific statement (no theorem number, no page ref). Item F says "every quoted constant must cite a specific paper/theorem. If the citation is vague … flag for source verification." The bluff proof has NO constants (no numerical quantities from cited papers), so F does not directly trigger on constants. But the Birman–Hilden citation IS vague. **Item F could trigger partially** if the Auditor reads "specific paper/theorem" to include theorem-by-name citations. This is the strongest candidate for bluff-catching.
- **Item G (picture-proof)**: no pictures in bluff. Not triggered.
- **Item H (geometric intuition)**: would score 3/5 or 4/5 under the checklist's less-detailed rubric. Similar issue as Axis 5 above — rewards vocabulary.

**Item F is the only mechanism that could plausibly flag the Birman–Hilden miscitation.** Whether a real run would catch it depends on how aggressively the Auditor reads "vague citation". A charitable reading passes it.

## Conclusion for Concern 3

**CONFIRMED.** The judge_ldt Axis 5 rubric has a bluff vulnerability.

Specific findings:
1. The rubric uses "uses X" language that does not distinguish invoking X from engaging X.
2. The multiplier rationale paragraph expresses the correct intent ("not just unrelated algebra") but offers no operational test.
3. The bluff proof would likely score 12–13.5/15 on Axis 5 — competitive with the real Round 0.5 hyperbolic proof.
4. The only safety net is LDT checklist item F (vague citations), but that requires the Auditor to be skeptical rather than rule-following; the current checklist is primarily rule-following.

**Key observation for the diagnostic report**: the Axis 5 rubric currently rewards **surface signals of geometric engagement** (vocabulary, named structures) rather than **depth of engagement** (whether the structure participates in load-bearing steps). A proof that learns to name-drop Teichmüller, curve complex, MCG, and train tracks can score as high as a proof that actually constructs a hyperbolic triangulation.

Specific failure mode to watch for in future rounds: **geometric prologue + algebraic middle + geometric epilogue**. This pattern is not caught by either the Axis 5 rubric or the LDT checklist.

*Appended to `ldt_diag_log.md` on 2026-04-20.*
