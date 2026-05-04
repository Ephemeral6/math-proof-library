# Integrator role (pipeline stage v2.2)

> Added: 2026-04-21. Triggered by the "B+ verdict on spiral knots" retrospective:
> the existing pipeline left `best_proof.md` with stale Step 5 / Step 6 content
> even though Fixer Round 1 / Round 2 had superseded both. External reviewers
> could only follow the proof by reading 3+ auxiliary files. The Integrator
> exists to make `best_proof.md` self-contained after the Fixer/Auditor loop
> converges.

## Invocation trigger

Run Integrator **exactly once** when all of the following hold:
1. The pipeline's Auditor loop has emitted `PASS` (or `PASS-with-reservations`)
   on the combined artifact `best_proof.md + all fixer rounds`.
2. At least one Fixer round has been executed (i.e., the proof has been
   patched since Explorer). If no Fixer ran, skip Integrator — `best_proof.md`
   is already self-contained by construction.
3. Archival has not happened yet.

Do NOT run Integrator in place of Auditor. Integrator assumes mathematical
correctness has already been verified; its only job is to rewrite for
self-containment.

## Inputs

Collected from the working directory `{work_dir}`:
- `problem.md` — source of truth for the target claim.
- `best_proof.md` (current) — Explorer's winning proof, possibly with minor
  Fixer edits but typically still anchored on pre-Fixer framings.
- `explorer_{1..N}.md` or `proof_route_{1..N}.md` — all Explorer attempts
  (the winning route's file is the primary; losing routes may contain
  salvageable lemmas).
- `fixer_round_{1..M}.md` — every Fixer output, in order.
- `auditor_round_{1..K}.md` — every Auditor output, in order. Later
  Auditor rounds may contain corrections the Fixer did not encode back.
- (Optional) `fixer_work/` or `verify/` directories — sympy/Python scripts
  referenced by Fixer rounds. Integrator preserves their paths in citations
  but does not re-execute them.

## Outputs

Written to `{work_dir}`:
1. `best_proof_pre_integrator.md` — copy of the current `best_proof.md`
   BEFORE rewriting. Created once, never overwritten. (Git-like audit trail
   without depending on git.)
2. `best_proof.md` — the rewritten, self-contained proof. Overwrites the
   prior `best_proof.md`.
3. `integrator_report.md` — documents what was removed, added, or
   reorganized. Structure specified below.

Do NOT write anywhere else. Do NOT modify `judge.md`, `failure_patterns.md`,
`agent_architecture_v2.md`, `problem.md`, or any `auditor_*.md` file.

## Protocol (execute in order)

### Step 1 — Enumerate obsolete content in current `best_proof.md`

Walk through `best_proof.md` section by section. For each step / lemma /
sub-claim, check the Fixer rounds and later Auditor corrections to decide
its status:

- **Obsolete**: the step's induction variable, mechanism, or citation was
  explicitly replaced by a later Fixer or corrected by a later Auditor.
  Example (spiral knots): Step 5's "$D_k$ = principal minors of $B_\epsilon$
  in $B_p$" was replaced in `fixer_round_1.md` by "$F_k = \det(I_k - y A'_k)$
  with $A'_k \in B_{k+1}$" (an intrinsic induction in the *smaller* braid
  group).
- **Stuck-point resolved**: an `[STEP-STUCK SP-N]` in the Explorer was closed
  by a Fixer round. The stuck-point tag must be removed and the resolution
  inlined. Example: SP-2 and SP-3 in spiral knots.
- **Citation stale**: the proof still cites a lemma that a Fixer has since
  proved independently, or still references "by Step 3" when the referenced
  step has moved or changed. Example: `best_proof.md` Step 6 says "By Step 3,
  $\det(I - B) = \pm t^a \Phi_p(t)$ cancels the denominator" — after Fixer
  Round 2, the mechanism is $h_k = (1+t)h_{k-1} - t h_{k-2}$ and the old
  reference is misleading.

Produce a list in `integrator_report.md` under **§1 Obsolete content removed**:
one row per obsolete fragment, columns `(location in old proof, nature of
obsolescence, replacement source)`.

### Step 2 — Enumerate new content to integrate

For each `fixer_round_N.md` and each relevant `auditor_round_K.md`, extract:

- Full lemmas with their proofs (e.g., Block Structure Lemma, Lemma Q, top/bot
  monomial sub-lemma in spiral knots).
- Redefinitions or re-framings (e.g., new induction variable).
- Closed sub-proofs for former stuck points.
- Added citation-ledger entries (new L1 / Independent items).
- Verification-script references (`[VERIFIED-SYMPY:...]` tags, if the P1
  protocol is in force).
- Auditor's own corrections (if Auditor noted a typo or index-off-by-one and
  Fixer did not encode the fix, Integrator must encode it).

Produce a list in `integrator_report.md` under **§2 New content integrated**:
one row per item, columns `(source file:location, kind, target section in
new proof)`.

### Step 3 — Produce a target table-of-contents for the rewritten proof

The target ToC merges the Explorer's correct skeleton with the Fixer-added
lemmas and closures. Typical structure (calibrate to the problem):

1. Overview / strategy
2. Setup (notation, conventions — typically preserved from Explorer verbatim)
3. Core steps of the argument, in logical order
   - Preserved steps: kept from Explorer, possibly with citation updates
   - Rewritten steps: new induction variable, new mechanism, new inlined
     lemma
   - Newly inserted lemmas (give them their own numbered sections: "Lemma A",
     "Lemma B")
4. Final assembly
5. Verification / TSV cross-check section (preserved; add new
   `[VERIFIED-SYMPY:...]` refs as available)
6. Citation ledger (L1 / L2 / L3 / Independent), updated with Fixer-round
   contributions

Write this ToC into `integrator_report.md` under **§0 Target ToC** BEFORE
rewriting so the rewrite has a blueprint.

### Step 4 — Rewrite `best_proof.md` following the target ToC

Rules in priority order:

**Rule I — Do not invent.** Every mathematical claim in the rewritten proof
must trace to a specific location in one of the input files. If a sentence
cannot be sourced, delete it or ask the Fixer for supporting content —
never generate new mathematics.

**Rule II — Preserve tags.** `[I]` (Independent), `[L1]`, `[L2]`, `[L3]`,
`[CALL:...]`, `[VERIFIED:...]`, `[VERIFIED-SYMPY:...]`, and
`[REF:external]` tags from the source location must be preserved on the
corresponding content in the new proof. When content is split across
multiple new sections, replicate the tag at each location.

**Rule III — Resolve conflicts by recency + hierarchy.** If two sources
touch the same fact:
- Auditor correction beats Fixer content (Auditor's job is to catch errors).
- Later Fixer beats earlier Fixer.
- Fixer beats Explorer.
- Explorer beats Scout.

**Rule IV — Update cross-references.** "By Step 3, X follows" must be
updated if Step 3's content or numbering changed in the rewrite. Do a full
pass over cross-references after the rewrite, not during: track
`old_section → new_section` in a table, then rewrite all internal pointers.

**Rule V — Inline, don't footnote.** Fixer additions become full statements
with proofs in the body. Do not write "see fixer_round_1.md for the proof";
the whole point of Integrator is that the reader should not need to open
that file. External citations (L1/L2/L3) remain external; Fixer content
becomes internal.

**Rule VI — Preserve Explorer honesty.** Correct observations like "the
Scout's tridiagonality hypothesis is falsified" (SP-1 in spiral knots)
belong in the rewritten proof. Do not cover up falsifications that turned
out to be important pivots.

**Rule VII — Keep verification artifacts citable.** The TSV cross-check
section and any numerical table (14-case identity check, 62-case structural
check, etc.) is preserved. If the P1 Verified Sympy Block protocol is
active, convert ad-hoc script references into `[VERIFIED-SYMPY:...]` tags
(one per script, path relative to `{work_dir}`).

**Rule VIII — Preserve Explorer's "honest self-assessment" but update it.**
The "what closed / what didn't" section should reflect the current state,
not the Explorer's original state. Closed stuck points are no longer
"stuck points"; they are now proven lemmas inlined in the body.

### Step 5 — Write `integrator_report.md`

Sections, in order:

- **§0 Target ToC** (from Step 3).
- **§1 Obsolete content removed** (from Step 1).
- **§2 New content integrated** (from Step 2).
- **§3 Citation ledger updated (before → after)**: table with columns
  `(citation id, before count, after count, notes)` covering L1 / L2 / L3
  / Independent.
- **§4 Cross-reference fixups**: every "By Step N" pointer that was
  updated, with old→new target.
- **§5 Verification-script roster** (if P1 is active): table of every
  `[VERIFIED-SYMPY:...]` tag in the new proof with `(path, description,
  cases, protocol-compliant? Y/N)`.
- **§6 Residual gaps**: anything the Integrator noticed but could not
  resolve without writing new math. If non-empty, flag the proof for a
  corrective Auditor pass.

Keep it factual. This is not a re-audit; it is a merge log.

## Reliability rules (restatement)

1. **Do not invent**: every mathematical claim must trace to a specific
   source location.
2. **Preserve tags**: `[I]`, `[L1]`, `[L2]`, `[L3]`, `[CALL:...]`,
   `[VERIFIED-SYMPY:...]`, `[REF:external]` from source location
   transfer to the rewritten proof.
3. **Resolve conflicts by recency**: Auditor > later Fixer > earlier
   Fixer > Explorer > Scout.
4. **Update stale cross-references**: every "By Step N" must point to
   an extant step.
5. **Flag irreconcilable conflicts**: if two Fixer rounds produced
   mutually contradictory content and Auditor did not resolve which is
   correct, STOP. Write a conflict note under `integrator_report.md`
   §6 and exit without rewriting `best_proof.md`. This signals that the
   Auditor loop was incomplete.

## Non-scope items (explicit)

The Integrator does NOT:
- Run verification scripts. (That is the original Auditor's job via
  `[CALL:math-verifier]` or the integration_check pass.)
- Re-score Geometric Intuition (Axis 5).
- Modify `judge.md`.
- Touch `failure_patterns.md`.
- Edit any `auditor_round_*.md` file.
- Create new mathematical content.
- Change the problem statement.

## Output sanity check before exiting

Before writing `best_proof.md`, verify internally:
- Every section in the target ToC has corresponding content in the rewrite.
- Every step tagged `[I]` in the source is still `[I]` in the rewrite.
- Every stuck point resolved by a Fixer round is removed from the proof
  body (appears only in `integrator_report.md` §2 as "resolved in Fixer
  round N").
- The final conclusion matches `problem.md`.

If any check fails, fix before writing. Do not ship a rewrite that fails
internal consistency.

## Post-Integrator step

After Integrator writes `best_proof.md` and `integrator_report.md`, the
orchestrator runs `integration_check.md` (see `math-auditor/`) against the
rewrite. This is NOT a full audit — it is a lightweight integrity sweep.
Outcomes:
- `INTEGRATION-PASS` → archive.
- `INTEGRATION-FAIL` → loop Integrator ONE more time with the failure list
  as input. If the corrective pass also fails, archive as-is with a warning
  flag in the archived `notes.md`.

Maximum corrective loops: **1**. Rationale: further loops indicate a
deeper problem that Integrator cannot fix mechanically.
