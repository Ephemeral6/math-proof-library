# MIP Discoveries — Shared Briefing for Exploration Agents

You are one of 10 subagents launched in parallel to explore the MIP (Mathematical Principles of Intelligence) Lean formalization for **new, derivable theorems** that were NOT already stated in the natural-language manuscript or the existing Lean codebase.

This file is read by all 10 agents. Your specific exploration direction is in your prompt.

---

## 1. Hard constraints (DO NOT VIOLATE)

1. **Zero `sorry`.** Every theorem you write must close with a real proof.
2. **Zero new `axiom`.** You may only use the 4 axioms `Axioms.A1`–`Axioms.A4` already in `MIP/Axioms.lean`. Adding a new `axiom` is a failure.
3. **Every discovery file must compile** with `lake env lean MIP/Discoveries/<your-file>.lean`. Compile from `C:\Users\12729\Desktop\Math\lean\MIP\` (the project root). First compile takes ~45–90s loading oleans; incremental edits are similar. Budget your time accordingly.
4. **Namespace:** `namespace MIP` … `end MIP` around your content. Match existing files' style.
5. **No new opaque declarations.** Use existing opaque symbols (`N`, `Phi0`, `K`, `R`, `demandFamily`, `Cₑ`, `MetaSet`, `tokenReplace`, etc.) from `MIP/Axioms.lean`.
6. **File naming:** `MIP/Discoveries/Agent<N>_<TopicSlug>.lean`. Example: `Agent3_PiMomentBounds.lean`.

## 2. RAM budget — important

The host has ~15 GB RAM and another agent is running concurrently. Each `lake env lean` invocation uses ~1.5 GB working set. **Do not run more than one compile at a time inside your own agent.** Compile, wait, read the output, then iterate. Don't launch concurrent compiles via `&` or background jobs.

## 3. File header convention (REQUIRED)

Every file you create must start with one of these markers in a doc comment:

```lean
/-
  STATUS: DISCOVERY            -- new, fully proved theorem(s)
  -- or: STATUS: OBSERVATION   -- interesting structural fact, partial result, conjecture-strength statement (but still compiles, no sorry)
  -- or: STATUS: DEAD END      -- direction explored but no new derivable result; file documents what was tried and why it failed (still no sorry — use comments / `example : True := trivial`)

  AGENT: <N>
  DIRECTION: <one-line description>
  SUMMARY: <2-4 sentence summary of the finding>
-/
```

For `DEAD END` files, just write prose `/- ... -/` comments documenting the attempt; the file body can be empty or a single `example : True := trivial`. The point is to record the negative result so future agents don't repeat the exploration.

## 4. Project map — what's already proven

**Foundational** (everything depends on these — READ FIRST):
- `MIP/Basic.lean` — `Str α := List α`, `Agent α := Str α → PMF (Str α)`, `Problem α := Str α → Bool`.
- `MIP/Axioms.lean` — opaque symbols + axioms A.1–A.4.
- `MIP/Defs/Knowledge.lean` — `ActivationDist Ω` (probability dist on Ω, summing to 1), `SubdomainPartition Ω` (disjoint exhaustive partition), `knowledgeEntropy d = -∑ ω, p ω · log (p ω)`, `subdomainMass P d K_i = ∑ ω ∈ K_i, d.p ω`.
- `MIP/Defs/StateSpace.lean` — concrete model: `InternalState α := ⟨agent, problem, step⟩`, `Reachable := (· = ·)`, `T_m m s = {s with step := s.step + 1}`.
- `MIP/Defs/StateSequence.lean` — `Phi_state s := if step ≥ N then 0 else Phi0 X p`. **Note: in this concrete model `Z = 0`, `Z_min = 0`, `Z_max = ⊤`.** Many "impedance" statements are degenerate here.
- `MIP/Defs/Barriers.lean` — `BarrierData α`, `B_data p X = (range (N p X).toNat).image (b_synth X p)`, `B_data_card_eq_N : ((B_data p X).card : ℕ∞) = N p X` when `N ≠ ⊤`. `IsAtomic := True`, `Indep := True` in concrete model.

**Key theorems** (read the file for the statement you may use):
- `MIP/Theorems/T18_10_Conservation.lean` — `T18_10_conservation : ∑ S ∈ parts, ∑ ω ∈ S, p_X ω = 1` (mass conservation, pure Mathlib).
- `MIP/Theorems/T8_OhmLaw.lean` — `T8_OhmLaw_zero_case`, `T8_two_sided`, `T8_OhmLaw`. (Concrete-model degenerate.)
- `MIP/Theorems/T30_PhaseTransition.lean` — `T30_phase_transition`, `PhaseTransitionPrereq`.
- `MIP/Theorems/T6_Bidirectional.lean` — `T6_kernel`, `BidirectionalBound`, `T6_Bidirectional`.
- `MIP/Theorems/T31_FreeEnergy.lean`, `T35_PartitionFunction.lean` — partition function form.
- `MIP/Theorems/T18_*` — uncomputability / NP-hard / Goodhart / alignment / extrapolation / detection-gap / metric-unification.
- `MIP/Theorems/T7_Uniqueness.lean` — uniqueness of `N` under R1–R4.

**Conjectures already attempted** (look here BEFORE claiming a discovery — your "new" result may already be in here): `MIP/Conjectures/Cj*.lean`. Each Cj file documents an attempt, with verdict (proved sub-case / refuted / blocked).

## 5. The "is this actually new?" check

Before declaring `DISCOVERY`, do this:

```bash
# Grep the whole project for similar statement shape
grep -rn "your_key_phrase" MIP/ | head -20
# Look at INDEX (the project's NL manuscript reference)
ls ../../axioms/ ../../theorems/ ../../definitions/ 2>/dev/null
```

If the statement is a trivial rewrite of an existing lemma, downgrade to `OBSERVATION`. If it's a known corollary discussed in the NL manuscript but never Leanified, that still counts as a DISCOVERY (you found a derivable formal statement). If it's an obvious application of a single Mathlib lemma to a trivial special case, downgrade to `OBSERVATION`.

## 6. How to compile (Windows + PowerShell)

```powershell
cd C:\Users\12729\Desktop\Math\lean\MIP
lake env lean MIP/Discoveries/AgentN_YourFile.lean
```

Exit code 0 = success. Any non-zero exit means proof errors — read the stderr/stdout, fix, retry. The build cache is shared across files; subsequent compiles of the same file after edits are usually faster.

## 7. Working style

- **Don't fake compile success.** If you write `theorem foo := by sorry`, this violates Constraint 1. If you can't close a proof, demote to `OBSERVATION` and either (a) state the theorem with a fully-supplied proof of a weaker version, or (b) state the obstacle in a `/- ... -/` comment.
- **Prefer small, sharp statements** over long bundle theorems. Three crisp `DISCOVERY` lemmas beat one mushy 200-line theorem.
- **Use Mathlib liberally.** `Finset.sum_le_sum`, `Real.log_le_sub_one_of_pos`, `NNReal.coe_sum`, `ENNReal.le_div_iff_mul_le`, entropy bounds, etc. — search with `grep` on `~/.lake/packages/mathlib/Mathlib/` (path may vary) or by `lake env lean -e "#check Real.log_pos"` style.
- **Stop and document when stuck.** A clean `OBSERVATION` or `DEAD END` is more valuable than a fake-proved theorem.

---

End of briefing. Your direction follows in the prompt that launched you.
