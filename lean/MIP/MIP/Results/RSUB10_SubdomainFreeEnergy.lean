/-
Result R-SUB.10 — Subdomain version of C.12 free-energy inequality.

Reference: `workspace/subdomain_competition.md` §6.10 (A 无条件 —
C.12 restricted to a single subdomain).

**Statement.** For each subdomain `ℛ_i ⊆ ℛ(p)` with positive partition
function `Z_i := Σ_{R ∈ ℛ_i} exp(−Φ₀(R))`, define
* `F_i := −log Z_i`                                  (free energy),
* `E_R[Φ₀]_i := Σ_{R ∈ ℛ_i} p_R · Φ₀(R)`             (subdomain mean),
* `S_R,i := −Σ_{R ∈ ℛ_i} p_R · log p_R`               (subdomain entropy),
where `p_R := exp(−Φ₀(R)) / Z_i` is the local Boltzmann distribution.

Then:

    F_i  =  E_R[Φ₀]_i − S_R,i .

**Proof.** Direct application of the `Z_entropy_expansion` lemma (the
algebraic kernel of C.12 in `MIP.Corollaries.C12_FreeEnergy`) with the
indexing finset restricted to `ℛ_i`.

This file is a thin wrapper around `MIP.FreeEnergy.Z_entropy_expansion`.

**This file is `axiom`-free.**
-/
import MIP.Corollaries.C12_FreeEnergy

namespace MIP

namespace SubdomainFreeEnergy

open scoped BigOperators
open Real

/-- **R-SUB.10 — algebraic core.**

For any subdomain index set `s : Finset ι` with positive partition
function, the `Z`-entropy expansion `−log Z = E[Φ] − S` of C.12 holds
verbatim. -/
theorem R_SUB_10_subdomain_free_energy
    {ι : Type*} (s : Finset ι) (φ : ι → ℝ)
    (hZ_pos : 0 < ∑ R ∈ s, Real.exp (-φ R)) :
    let Z := ∑ R ∈ s, Real.exp (-φ R);
    let p := fun R => Real.exp (-φ R) / Z;
    -Real.log Z
      = (∑ R ∈ s, p R * φ R) - (-∑ R ∈ s, p R * Real.log (p R)) :=
  MIP.FreeEnergy.Z_entropy_expansion s φ hZ_pos

end SubdomainFreeEnergy

end MIP
