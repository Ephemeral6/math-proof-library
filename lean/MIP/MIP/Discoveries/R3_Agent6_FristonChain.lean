/-
STATUS: ✅ Compiles, axiom-free, sorry-free.
AGENT: R3_Agent6 (Degeneration family).
DIRECTION: Item (B) — Friston degeneration chain: R.408 + R.409 + R.410.
SUMMARY:
  Compose three Friston-flavoured results into a unified "FEP boundary"
  statement:

    (1) R.408 establishes the degeneration `F = Φ₀ + C_train` with
        `Z · Π = 1` (impedance-precision reciprocity);
    (2) R.409 supplies the 13-row variable map that — under the *same*
        degeneration — forces `C_train = KL` (the consistency between
        Friston's two VFE decompositions);
    (3) R.410 then upgrades the static identities to dynamical claims
        (perception descent, value sign, Hebbian Gompertz).

  This file proves a "unified FEP boundary" theorem: if a system carries
  BOTH the R.408 algebraic bundle (`FEPMap`) AND a compatible R.409
  variable map (`VarMap`) at the same `Pi`, then

    (i)   `F = Surprise + KL` (R.408 reduction + R.409 `Ctrain = KL`);
    (ii)  `F = N · Π + KL` (R.408 step 2 + R.409 forced `Ctrain = KL`);
    (iii) `Z · Π = 1` agrees in BOTH bundles (consistency).

  Plus a single-bundle "value sign" cross-derivation from R.410(e):
  if `F = Surprise + Ctrain` (R.408) and `Π > 0`, then non-negative
  expected Surprise forces non-positive `Value` (R.410(e)).

Depends on:
  - MIP.FristonDegeneration.FEPMap                   (R.408)
  - MIP.FristonDegeneration.FEPMap.R_408_free_energy (R.408)
  - MIP.FristonDegeneration.FEPMap.R_408_Z_mul_Pi    (R.408)
  - MIP.FristonDegeneration.FEPMap.R_408_step2_decomposition (R.408)
  - MIP.FristonVariableMap.VarMap                    (R.409)
  - MIP.FristonVariableMap.VarMap.row2_Ctrain_eq_KL  (R.409)
  - MIP.FristonVariableMap.VarMap.row5_Z_mul_Pi      (R.409)
  - MIP.FristonPropositions.Value                    (R.410)
  - MIP.FristonPropositions.R_410_e_value_nonpos     (R.410)
-/
import MIP.Results.R408_FristonDegeneration
import MIP.Results.R409_FristonVariableMap
import MIP.Results.R410_FristonPropositions

namespace MIP

namespace R3_Agent6_FristonChain

open MIP.FristonDegeneration
open MIP.FristonVariableMap
open MIP.FristonPropositions

/-- **R3-A6 FristonChain (i) — joint F-decomposition under R.408 + R.409.**

If an FEP-mapping bundle `M` (R.408) and a variable-map bundle `V` (R.409)
share the same `F` and the same `Surprise`, then *both* yield
`F = Surprise + C_train` (R.408 main) AND `F = Surprise + KL` (R.409 row2
Surprise+KL), so `C_train = KL` is forced (R.409 row2_Ctrain_eq_KL).

Output: a single, unified equation `F = Surprise + KL = Surprise + C_train`. -/
theorem R3_A6_friston_F_unified
    (M : FEPMap) (V : VarMap)
    (hF : V.F = M.F) (hSurp : V.Surprise = M.Surprise) :
    M.F = M.Surprise + V.KL ∧ M.F = M.Surprise + M.Ctrain := by
  -- From R.408: `F = Surprise + Ctrain`.
  have h408 : M.F = M.Surprise + M.Ctrain := M.R_408_free_energy
  -- From R.409 row 2 (Surprise + KL): `V.F = V.Surprise + V.KL`.
  have h409 : V.F = V.Surprise + V.KL := V.row2_surprise_kl
  -- Transport via `hF`, `hSurp`.
  have hF' : M.F = M.Surprise + V.KL := by rw [← hF, h409, hSurp]
  exact ⟨hF', h408⟩

/-- **R3-A6 FristonChain (ii) — joint step-2 decomposition `F = N·Π + KL`.**

The R.408 step-2 decomposition gives `F = N · Π + C_train`; the R.409 row 2
consistency forces `C_train = V.KL` (when `V.F = M.F` and `V.Surprise = M.Surprise`).
Combining: `F = N · Π + KL` — the *T.8-form* of Friston's free energy where
the complexity drift is the posterior KL. -/
theorem R3_A6_friston_NPi_plus_KL
    (M : FEPMap) (V : VarMap)
    (hF : V.F = M.F) (hSurp : V.Surprise = M.Surprise) :
    M.F = M.N * M.Pi + V.KL := by
  -- R.408 step 2:  F = N·Π + Ctrain.
  have hstep2 : M.F = M.N * M.Pi + M.Ctrain := M.R_408_step2_decomposition
  -- (R.409 derivation) Ctrain in V's bundle equals V.KL.
  have hCtKL : V.Ctrain = V.KL := V.row2_Ctrain_eq_KL
  -- And we need M.Ctrain = V.Ctrain (so that M.Ctrain = V.KL).
  -- The R.409 row 2 main eq:  V.F = V.Phi0 + V.Ctrain.  R.409 row 1:
  -- V.Surprise = V.Phi0.  So V.F = V.Surprise + V.Ctrain.
  have hV_main : V.F = V.Surprise + V.Ctrain := by rw [V.row2_main, V.row1]
  -- M.F = M.Surprise + M.Ctrain   (R.408)
  have hM_main : M.F = M.Surprise + M.Ctrain := M.R_408_free_energy
  -- Subtract:  V.F − V.Surprise = V.Ctrain  and  M.F − M.Surprise = M.Ctrain.
  -- With hF, hSurp:  V.Ctrain = V.F − V.Surprise = M.F − M.Surprise = M.Ctrain.
  have hCt_eq : M.Ctrain = V.Ctrain := by
    have h1 : V.Ctrain = V.F - V.Surprise := by linarith
    have h2 : M.Ctrain = M.F - M.Surprise := by linarith
    rw [h2, ← hF, ← hSurp, ← h1]
  rw [hstep2, hCt_eq, hCtKL]

/-- **R3-A6 FristonChain (iii) — Z·Π = 1 consistency across the two bundles.**

R.408 (`R_408_Z_mul_Pi`) and R.409 (`row5_Z_mul_Pi`) both establish the
impedance–precision reciprocity for their own `Z, Pi` — at the *same* `Pi > 0`
they produce the same `Z = 1/Pi`, so the two bundles agree on this row. -/
theorem R3_A6_friston_ZPi_consistent
    (M : FEPMap) (V : VarMap) (hPi : M.Pi = V.Pi) :
    M.Z * M.Pi = 1 ∧ V.Z * V.Pi = 1 ∧ M.Z * V.Pi = 1 := by
  refine ⟨M.R_408_Z_mul_Pi, V.row5_Z_mul_Pi, ?_⟩
  rw [← hPi]
  exact M.R_408_Z_mul_Pi

/-- **R3-A6 FristonChain (iv) — value sign on the unified bundle (R.408 + R.410(e)).**

Cross-derive R.410(e) `Value ≤ 0` directly from the R.408 free-energy
formula:  with `Π > 0` (R.408 bundle) and non-negative expected `Φ₀ = Surprise`,
the Friston "value = −Surprise" reading gives `Value ≤ 0` — non-positive
adaptive value at unresolved Surprise. -/
theorem R3_A6_friston_value_nonpos
    (M : FEPMap) (EPhi0 : ℝ)
    (hE : 0 ≤ EPhi0) :
    Value EPhi0 M.Pi ≤ 0 :=
  R_410_e_value_nonpos EPhi0 M.Pi hE M.Pi_pos

/-- **R3-A6 FristonChain (v) — packaged unified FEP boundary.**

Bundles items (i)–(iv) into ONE theorem citing R.408, R.409, R.410:
the same physical regime supports the static `F = Surprise + KL = N·Π + KL`,
the impedance–precision reciprocity `Z·Π = 1` (consistent across bundles),
and the dynamical sign condition `Value ≤ 0` for non-negative expected
Surprise. -/
theorem R3_A6_friston_unified
    (M : FEPMap) (V : VarMap)
    (hF : V.F = M.F) (hSurp : V.Surprise = M.Surprise) (hPi : M.Pi = V.Pi)
    (EPhi0 : ℝ) (hE : 0 ≤ EPhi0) :
    (M.F = M.Surprise + V.KL) ∧
    (M.F = M.N * M.Pi + V.KL) ∧
    (M.Z * M.Pi = 1 ∧ V.Z * V.Pi = 1) ∧
    (Value EPhi0 M.Pi ≤ 0) := by
  obtain ⟨h1, _⟩ := R3_A6_friston_F_unified M V hF hSurp
  refine ⟨h1, ?_, ?_, ?_⟩
  · exact R3_A6_friston_NPi_plus_KL M V hF hSurp
  · obtain ⟨ha, hb, _⟩ := R3_A6_friston_ZPi_consistent M V hPi
    exact ⟨ha, hb⟩
  · exact R3_A6_friston_value_nonpos M EPhi0 hE

end R3_Agent6_FristonChain

end MIP
