# proofs/fragments/

Harvested sub-lemmas and technical identities extracted from full proof
attempts. **Not** A/B/C-class archived proofs — these are reusable fragments
without their parent context.

## Classification vs `proofs/research/` and `proofs/library/`

| Class | Location | Origin | Audited? |
|-------|----------|--------|----------|
| A     | `proofs/research/<branch>/<name>/` | 2015+ research paper, novel technique | full 5-stage report |
| B / C | `proofs/library/<branch>/<name>/`  | classic / textbook result | full 5-stage report |
| Fragment | `proofs/fragments/<name>.md` | sub-lemma extracted mid-proof | self-contained but **not separately audited** |

A fragment graduates to library/ only after it is re-stated as a standalone
theorem and run through the full proof pipeline. Until then, each fragment
documents its parent context and assumes the reader will re-verify before
reusing in a new proof.

## Layout

Flat — one `.md` per fragment, plus `INDEX.md` grouped by tag cluster
(convex analysis, concentration, optimization dynamics, …).

See `INDEX.md` for the searchable catalog.

## When to add here

- A sub-step from a research/library proof has obvious reuse value beyond
  its parent (e.g. a sharp identity, a tight inequality, a generic recursion
  lemma).
- The fragment is too small or too tangential to justify its own
  research/library entry.
- You want the result discoverable without committing to a full audit pass.

## When to promote out

If a fragment gets cited from ≥ 2 distinct proofs, or is invoked in a future
research-grade proof, lift it to `proofs/library/<branch>/` with a full
5-phase report.
