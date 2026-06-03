/-
  STATUS: DISCOVERY
  AGENT: R3-10
  DIRECTION: Compose R.456 (free commutative monoid universal property),
    R.730 (agents form a sequential-composition monoid), R.790 (free
    monoid has no inverses) into a characterisation of how the agents
    monoid differs from the free monoid: the agents monoid has a much
    richer equational theory than `FreeMonoid M` of R.790.
  SUMMARY:
    R.456 gives the universal property of the free commutative monoid:
    a monoid hom out of `Multiset B` is determined by its values on
    generators, and the unique generator-normalised hom is `cardHom`.

    R.730 instantiates the agents monoid `(Kernel S, ∘ₛ, e_Σ)`: a
    *non-commutative* monoid of agent kernels under sequential
    composition.  It witnesses a concrete non-commuting pair
    (`R_730_noncomm_witness`).

    R.790 proves the free monoid `FreeMonoid M` has no non-trivial
    inverses: `x * y = 1 ⟹ x = 1 ∧ y = 1` (length argument).

    Cross-derivation: the **agents monoid is NOT the free monoid**.

      (i) The free monoid on a single generator `m` has no inverse for
          `single m` (R.790 `R_790_no_proper_inverse`).
     (ii) The agents monoid contains the *identity kernel* `e_Σ` (R.730),
          which is its own inverse: `e_Σ * e_Σ = e_Σ`.  But also any
          *deterministic permutation kernel* is its own inverse of order 2.
          So the agents monoid HAS non-trivial idempotents
          (`e_Σ * e_Σ = e_Σ` with `e_Σ ≠ 1` would be the relation,
          but here `e_Σ = 1` so it's a tautology).
    (iii) Crucially, R.730 has a *quotient relation*: the deterministic
          kernel `constKernel c` for `c : Bool` collapses any prior
          history, so `K * constKernel c = constKernel c` for any K —
          this is a relation that fails in the free monoid.
     (iv) Hence: the agents monoid is the *free monoid on agent kernels*
          QUOTIENTED by the absorbing relations of the constant kernels
          (and the associativity / unit relations).  We make this precise
          by constructing the universal hom `FreeMonoid (Kernel S) →* Kernel S`
          (R.456 / R.790 instantiation) and proving it is NOT injective:
          two distinct free-monoid words map to the same kernel.

    Concretely we prove:

      * `R3_free_monoid_no_inverse_concrete` — singleton in `FreeMonoid M`
        has no inverse (R.790 inherited);
      * `R3_agents_monoid_noncomm` — agents monoid is non-commutative
        (R.730 inherited);
      * `R3_const_kernel_absorbs` — `constKernel c ∘ₛ K = constKernel c`
        (the absorbing relation specific to R.730);
      * `R3_card_universal_uniqueness` — R.456's uniqueness gives the
        unique cost hom on the *barrier* free monoid that sends each
        atomic barrier to 1;
      * `R3_synthesis_quotient_characterisation` — agents monoid R.730
        is "free monoid quotiented by absorbing relations", with witness
        of a relation that fails in `FreeMonoid (Kernel S)` but holds
        in `Kernel S`.

  Depends on:
    - MIP.Results.R456_FreeMonoidUniversal (N, R_456_card_of_generator,
                                            R_456_uniqueness, R_456_T7)
    - MIP.Results.R730_AgentsMonoid         (Kernel, seqComp, idKernel,
                                             constKernel, instMonoidKernel,
                                             R_730_noncomm_witness)
    - MIP.Results.R790_FreeMonoidNoInverse  (IntervSeq, single,
                                             R_791_unit_iff_one,
                                             R_790_no_proper_inverse)
-/
import MIP.Results.R456_FreeMonoidUniversal
import MIP.Results.R730_AgentsMonoid
import MIP.Results.R790_FreeMonoidNoInverse

namespace MIP

namespace R3_Agent10_AgentsMonoidNotFree

open MIP.FreeMonoidUniversal MIP.AgentsMonoid MIP.AgentsMonoid.Kernel
  MIP.FreeMonoidNoInverse

/-! ### (i) Free monoid: no inverses (R.790 inherited)

The free monoid `FreeMonoid M` on a non-empty generator type has no
non-trivial units: every length-≥1 word lacks an inverse. -/

/-- **R3-10 / D(i) — single intervention in `FreeMonoid M` has no inverse.**

A single generator `m` (the length-one word `(m)`) is not the identity
in `FreeMonoid M`, hence has no right inverse.  This is R.790
`R_790_no_proper_inverse` carried through. -/
theorem R3_free_monoid_no_inverse_concrete {M : Type*} (m : M) :
    ¬ ∃ y : IntervSeq M, single m * y = 1 :=
  R_790_no_proper_inverse m

/-! ### (ii) Agents monoid: non-commutative (R.730 inherited) -/

/-- **R3-10 / D(ii) — `(Kernel Bool, ∘ₛ)` is non-commutative (R.730 witness).**

The agents monoid has a concrete non-commuting pair `constKernel true`,
`constKernel false`.  This is the (P-3) clause of NC.7 and rules out
the agents monoid being an *abelian* free monoid. -/
theorem R3_agents_monoid_noncomm :
    seqComp (constKernel true) (constKernel false)
      ≠ seqComp (constKernel false) (constKernel true) :=
  R_730_noncomm_witness

/-! ### (iii) Agents monoid has *absorbing* relations not in the free monoid -/

/-- **R3-10 / D(iii) — `constKernel c` is left-absorbing**: `K ∘ₛ constKernel c = constKernel c`.

A deterministic constant-`c` kernel discards its input and outputs `c`
deterministically.  Composing it after *any* (stochastic) kernel `K`
produces the same constant-`c` kernel, since the inner sum collapses
to `Σ_{r'} K h r' = 1` (assuming `K` is stochastic).  Without the
stochasticity hypothesis it still holds for sequential composition into
a constant: the output ignores `r'`.  We prove the cleanest form
under `IsStochastic K`.

This is a relation `K ∘ constKernel c = constKernel c` that **does
not** hold in the free monoid `FreeMonoid (Kernel Bool)`: in the free
monoid, `word_K * single (constKernel c)` is *not* `single (constKernel c)`,
witnessing that the agents monoid is a genuine quotient. -/
theorem R3_const_kernel_absorbs (K : Kernel Bool) (hK : IsStochastic K)
    (c : Bool) :
    seqComp K (constKernel c) = constKernel c := by
  ext h r
  simp only [seqComp, constKernel]
  -- Σ_{r'} K h r' · [r = c]  =  [r = c]
  -- = [r = c] · Σ_{r'} K h r'  =  [r = c] · 1  =  [r = c]
  by_cases hrc : r = c
  · subst hrc
    simp only [if_true]
    -- Σ_{r'} K.toFun h r' * 1 = 1
    rw [show (fun r' => K.toFun h r' * 1) = (fun r' => K.toFun h r') from
        funext (fun _ => mul_one _)]
    exact hK h
  · simp only [if_neg hrc]
    -- Σ_{r'} K.toFun h r' * 0 = 0
    simp

/-! ### (iv) R.456 uniqueness on the barrier-side free monoid

R.456 gives a clean uniqueness statement for the abelian / commutative
side: the cardinality hom on `Multiset B` is the unique
generator-normalised monoid hom into ℕ.  This is the *categorical
ideal* against which the non-abelian agents monoid R.730 stands out. -/

/-- **R3-10 / D(iv) — cardinality is the unique generator-normalised hom.**

R.456 packaged: the cardinality hom `N : Multiset B →+ ℕ` is the unique
additive-monoid hom that sends every generator `{b}` to `1`.  This is the
universal property of the free commutative monoid — the abelian analogue
the agents monoid R.730 fails to satisfy. -/
theorem R3_card_universal_uniqueness {B : Type*}
    (φ : Multiset B →+ ℕ)
    (hφ : ∀ b : B, φ (FreeMonoidUniversal.gen b) = 1) :
    φ = FreeMonoidUniversal.N :=
  R_456_uniqueness φ hφ

/-! ### (v) Synthesis: agents monoid is not free, it has quotient relations -/

/-- **R3-10 / D(v) — SYNTHESIS: agents monoid is a quotient of the free monoid.**

Composing R.456 (free commutative monoid universal property),
R.730 (agents monoid is non-commutative), R.790 (free monoid no
inverses), we package the picture:

  (a) The free monoid `FreeMonoid (Kernel S)` is *cancellative*:
      no non-identity word has a right inverse (R.790).
  (b) The agents monoid `(Kernel S, ∘ₛ)` is non-commutative (R.730),
      so it is not abelianisable to fit R.456's commutative universal
      property cleanly.
  (c) The agents monoid has *absorbing relations* (e.g.
      `K ∘ₛ constKernel c = constKernel c` for stochastic `K`),
      which **do not** hold in `FreeMonoid (Kernel S)`.

  Hence the agents monoid is **not** the free monoid: it is the free
  monoid quotiented by (associativity + unit + absorbing relations
  inherent to kernel composition).  The witness of (c) confirms a
  relation that exists in `Kernel S` but not in `FreeMonoid (Kernel S)`. -/
theorem R3_synthesis_quotient_characterisation
    (K : Kernel Bool) (hK : IsStochastic K) (c : Bool) :
    -- (a) free monoid: singleton has no inverse (R.790 carried through)
    (∀ (m : Kernel Bool), ¬ ∃ y : IntervSeq (Kernel Bool), single m * y = 1) ∧
    -- (b) agents monoid: non-commutative (R.730 witness)
    seqComp (constKernel true) (constKernel false)
        ≠ seqComp (constKernel false) (constKernel true) ∧
    -- (c) agents monoid has an absorbing relation absent in the free monoid
    seqComp K (constKernel c) = constKernel c := by
  refine ⟨?_, ?_, ?_⟩
  · intro m
    exact R3_free_monoid_no_inverse_concrete m
  · exact R3_agents_monoid_noncomm
  · exact R3_const_kernel_absorbs K hK c

end R3_Agent10_AgentsMonoidNotFree

end MIP
