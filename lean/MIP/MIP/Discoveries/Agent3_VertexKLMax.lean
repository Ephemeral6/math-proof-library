/-
  STATUS: DISCOVERY
  AGENT: 3
  DIRECTION: Combined result — vertex partition saturates the KL-to-uniform
             upper bound; nonempty partitions are "specialist-favored" if
             H_π = 0.
  SUMMARY:
    Combining the entropy-zero ↔ vertex characterisation (Agent3_PiEntropyBounds)
    with the KL-to-uniform identity (Agent3_KLToUniform):

      `KL_to_uniform(d, P) = log m`
         ⟺  `H_π(d, P) = 0`
         ⟺  every part has mass 0 or 1 (vertex / point-mass partition).

    This is the formal statement that catastrophic specialisation (point-mass
    on one subdomain) is *maximally divergent* from the generalist (uniform)
    profile, with divergence equal to `log m`. The "specialist extreme"
    side of the H_π geometry.

    Plus: an exact form of "log m equals the maximum KL gap", with the
    saturation attained at any vertex.
-/
import MIP.Discoveries.Agent3_KLToUniform
import MIP.Discoveries.Agent3_PiEntropyBounds

namespace MIP

namespace Agent3_VertexKLMax

open scoped BigOperators
open Real
open MIP.Agent3_PiEntropyBounds (Hpi Hpi_zero_iff_vertex)
open MIP.Agent3_KLToUniform (KL_to_uniform KL_to_uniform_max_at_vertex)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Combined headline — vertex ⟺ KL-saturated.**

A partition is "point-mass / vertex" (every part has mass 0 or 1) iff its
KL divergence to the uniform profile equals `log m`. -/
theorem vertex_iff_KL_max
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    (∀ S ∈ P.parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = 0
      ∨ ((P.subdomainMass d S : NNReal) : ℝ) = 1)
    ↔ KL_to_uniform d P = Real.log (P.parts.card : ℝ) := by
  constructor
  · intro h_vertex
    -- From the vertex iff, H_π = 0; then KL_to_uniform = log m - 0 = log m.
    have h_Hzero : Hpi d P = 0 :=
      (Hpi_zero_iff_vertex d P).mpr h_vertex
    exact KL_to_uniform_max_at_vertex d P h_Hzero
  · intro h_KL_max
    -- KL_to_uniform = log m  ⟹  log m - H_π = log m  ⟹  H_π = 0.
    have h_Hzero : Hpi d P = 0 := by
      unfold KL_to_uniform at h_KL_max
      linarith
    exact (Hpi_zero_iff_vertex d P).mp h_Hzero

/-- **Three-way characterisation — H_π = 0  ⟺  vertex  ⟺  KL-saturated.**

This is the *catastrophic specialisation* characterisation: zero coarse-
grained entropy ⟺ all attention on one subdomain ⟺ maximal divergence
from uniform attention. -/
theorem catastrophic_specialisation
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    ((Hpi d P = 0)
      ↔ ∀ S ∈ P.parts,
          ((P.subdomainMass d S : NNReal) : ℝ) = 0
          ∨ ((P.subdomainMass d S : NNReal) : ℝ) = 1)
    ∧ ((∀ S ∈ P.parts,
          ((P.subdomainMass d S : NNReal) : ℝ) = 0
          ∨ ((P.subdomainMass d S : NNReal) : ℝ) = 1)
        ↔ KL_to_uniform d P = Real.log (P.parts.card : ℝ)) :=
  ⟨Hpi_zero_iff_vertex d P, vertex_iff_KL_max d P⟩

end Agent3_VertexKLMax

end MIP
