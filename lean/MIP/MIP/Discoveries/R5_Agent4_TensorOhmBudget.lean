/-
  STATUS: DISCOVERY
  AGENT: R5_Agent4
  DIRECTION: TENSOR CONSERVATION × OHM BUDGET — the JOINT Ohm budget of `k`
    INDEPENDENT agents whose subdomain masses tensor-multiply.

    Round-4 Agent 6 proved the TENSOR (product) conservation
    `∑_x ∏_a π_a(x_a) = 1` for `k` independent agents
    (`tensor_conservation_k`). Round-4 Agent 1 proved the single-agent Ohm
    budget machinery: the convex-combination potential is sandwiched by the
    partition extremes (`phi0_partition_extremes`, `ohm_budget_extreme_bounds`)
    and the ceiling is subadditive over a finite sum (`ceil_sum_le`).

    THIS FILE composes them: the joint emergence potential of the product
    system is the EXPECTATION of `Φ` under the tensor (product) joint law,

        Φ_joint  =  ∑_{x : ∀a, κ a}  (∏_a π_a(x_a)) · Φ(x).

    Because `tensor_conservation_k` certifies the product weights
    `w(x) = ∏_a π_a(x_a)` are a genuine probability vector (nonnegative,
    summing to 1), `Φ_joint` is an honest convex combination over the PRODUCT
    index, and R4_Agent1's partition-extreme machinery applies VERBATIM at the
    joint scale.

  SUMMARY (three results, ceiling-careful throughout):

    (a) JOINT OHM SANDWICH (`joint_ohm_budget_sandwich`).
        With the joint Ohm budget `N_joint = ⌈Z · Φ_joint⌉₊` (T.8 at joint
        scale) and `Z ≥ 0`, the product-system budget is trapped between the
        cheapest and the costliest joint configuration:

            ⌈Z · min_x Φ(x)⌉₊  ≤  N_joint  ≤  ⌈Z · max_x Φ(x)⌉₊.

        The tensor weights' normalization (`tensor_conservation_k`) is GENUINELY
        invoked to discharge the `∑ w = 1` premise of R4_Agent1's
        `phi0_partition_extremes`; nonnegativity is `Finset.prod_nonneg`.

    (b) ADDITIVE FACTORISATION + PER-AGENT DECOMPOSITION
        (`joint_potential_additive_decomposition`).
        If the joint potential factorises additively across agents,
        `Φ(x) = ∑_a φ_a(x_a)`, then the joint EXPECTATION collapses to the
        sum of the per-agent expectations:

            Φ_joint  =  ∑_a ( ∑_j π_a(j) · φ_a(j) ).

        This is expectation linearity for the product law: a per-agent
        decomposition driven by the SAME `Fintype.prod_sum` engine that powers
        `tensor_conservation_k`. The marginals of all OTHER agents collapse to
        1 (tensor conservation), leaving each agent's own private expectation.

    (c) HEADLINE — MULTI-AGENT OHM BUDGET LAW
        (`multi_agent_ohm_budget_law`).
        Combining (a)+(b): in the additive-potential regime with per-agent
        upper envelopes `φ_a(j) ≤ Mφ a` and nonnegative potentials, the joint
        Ohm budget is SUBADDITIVE across agents,

            N_joint  ≤  ∑_a ⌈Z · Mφ a⌉₊,

        a clean per-agent budget bound: the joint product system never costs
        more interventions than the pooled total of the independent per-agent
        Ohm budgets. Ceilings handled by R4_Agent1's `ceil_sum_le`
        (`⌈∑ x⌉₊ ≤ ∑ ⌈x⌉₊`) — the only safe way to split a ceiling over a sum.

  Depends on:
    - MIP.Discoveries.R4_Agent6_MultiAgentConservation
        (R4_Agent6_MultiAgentConservation.tensor_conservation_k)
        — the product weights `∏_a π_a(x_a)` sum to 1.  GENUINELY invoked as a
        proof term in `tensor_weights_normalised` (discharges `∑ w = 1`).
    - MIP.Discoveries.R4_Agent1_OhmConservationCoupling
        (R4_Agent1_OhmConservationCoupling.phi0_partition_extremes,
         R4_Agent1_OhmConservationCoupling.ceil_sum_le)
        — the convex-combination sandwich and the ceiling-subadditivity lemma;
        both invoked as proof terms in (a) and (c).
    - Mathlib: Fintype.prod_sum, Finset.prod_erase_mul, Finset.prod_nonneg,
        Finset.prod_const_one, Nat.ceil_mono, Nat.le_ceil.
-/
import MIP.Discoveries.R4_Agent6_MultiAgentConservation
import MIP.Discoveries.R4_Agent1_OhmConservationCoupling
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.Floor.Semiring

namespace MIP

open scoped BigOperators

namespace R5_Agent4_TensorOhmBudget

/-! ## Step 1 — the tensor product weights are a genuine probability vector.

The product weights `w(x) = ∏_a π_a(x_a)` over the dependent product index
`∀ a, κ a` are nonnegative (each factor nonneg) and sum to 1 (R4_Agent6's
`tensor_conservation_k`). This is exactly what turns the joint potential
`Φ_joint = ∑_x w(x)·Φ(x)` into a convex combination over the product index. -/

/-- **Tensor weights are normalised.**  Discharges, from R4_Agent6's
`tensor_conservation_k`, the `∑ w = 1` premise of R4_Agent1's
`phi0_partition_extremes`, applied at the JOINT (product) scale. -/
theorem tensor_weights_normalised
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ)
    (hπ_sum : ∀ a, ∑ j, π a j = 1) :
    ∑ x : (∀ a, κ a), ∏ a, π a (x a) = 1 :=
  R4_Agent6_MultiAgentConservation.tensor_conservation_k π hπ_sum

/-- **Tensor weights are nonnegative.**  If each agent's distribution is
nonnegative then the product weight `∏_a π_a(x_a)` is nonnegative. -/
theorem tensor_weights_nonneg
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (x : ∀ a, κ a) :
    0 ≤ ∏ a, π a (x a) :=
  Finset.prod_nonneg (fun a _ => hπ_nonneg a (x a))

/-! ## Step 2 (a) — the JOINT OHM SANDWICH at the product scale. -/

/-- **(a) Joint Ohm budget sandwich for `k` independent agents.**

Let each agent `a` carry a nonnegative, normalised distribution `π a`
(`∑_j π a j = 1`). The joint product law `w(x) = ∏_a π_a(x_a)` is a genuine
probability vector (Step 1), so the joint emergence potential

    Φ_joint = ∑_x w(x) · Φ(x)

is a convex combination over the product index. With T.8's ceiling budget at
the joint scale, `N_joint = ⌈Z · Φ_joint⌉₊`, and `Z ≥ 0`, the joint Ohm budget
is sandwiched between the cheapest and costliest joint configuration:

    ⌈Z · minΦ⌉₊  ≤  N_joint  ≤  ⌈Z · maxΦ⌉₊.

The `∑ w = 1` premise of R4_Agent1's `phi0_partition_extremes` is discharged
by R4_Agent6's `tensor_conservation_k` (via `tensor_weights_normalised`). -/
theorem joint_ohm_budget_sandwich
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ) (Φ : (∀ a, κ a) → ℝ)
    (Φjoint minΦ maxΦ Z : ℝ) (Njoint : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (h_def : Φjoint = ∑ x, (∏ a, π a (x a)) * Φ x)
    (h_max : ∀ x, Φ x ≤ maxΦ)
    (h_min : ∀ x, minΦ ≤ Φ x)
    (h_ohm : Njoint = ⌈Z * Φjoint⌉₊) :
    ⌈Z * minΦ⌉₊ ≤ Njoint ∧ Njoint ≤ ⌈Z * maxΦ⌉₊ := by
  -- The product weights form a probability vector over the product index.
  have hw_nonneg : ∀ x : (∀ a, κ a), 0 ≤ ∏ a, π a (x a) :=
    fun x => tensor_weights_nonneg π hπ_nonneg x
  have hw_sum : ∑ x : (∀ a, κ a), ∏ a, π a (x a) = 1 :=
    tensor_weights_normalised π hπ_sum
  -- R4_Agent1's convex sandwich, applied at the joint (product) scale.
  obtain ⟨h_lo, h_hi⟩ :=
    R4_Agent1_OhmConservationCoupling.phi0_partition_extremes
      (fun x => ∏ a, π a (x a)) Φ Φjoint minΦ maxΦ
      hw_nonneg hw_sum h_def h_max h_min
  -- Multiply the Φ_joint sandwich by Z ≥ 0, then push through `Nat.ceil_mono`.
  have hZlo : Z * minΦ ≤ Z * Φjoint := mul_le_mul_of_nonneg_left h_lo hZ_nonneg
  have hZhi : Z * Φjoint ≤ Z * maxΦ := mul_le_mul_of_nonneg_left h_hi hZ_nonneg
  refine ⟨?_, ?_⟩
  · rw [h_ohm]; exact Nat.ceil_mono hZlo
  · rw [h_ohm]; exact Nat.ceil_mono hZhi

/-! ## Step 2 (b) — ADDITIVE factorisation and per-agent decomposition.

If the joint potential is additive across agents, `Φ(x) = ∑_a φ_a(x_a)`, the
joint expectation under the product law collapses to a sum of per-agent
expectations. The engine is the SAME `Fintype.prod_sum` that powers
`tensor_conservation_k`: for a fixed agent `b`, weighting its coordinate by
`φ_b` and leaving the others as bare distributions, the OTHER agents'
marginals each collapse to 1, leaving exactly `∑_j π_b(j)·φ_b(j)`. -/

/-- **Single-coordinate marginal collapse.**

For a fixed agent `b`, the product-law expectation of a function depending only
on agent `b`'s private coordinate equals `b`'s own private expectation — every
other agent's marginal collapses to `1` by normalisation:

    ∑_x (∏_a π_a(x_a)) · φ_b(x_b)  =  ∑_j π_b(j) · φ_b(j).

Proof: replace agent `b`'s factor `π_b(·)` by `π_b(·)·φ_b(·)` (so the integrand
becomes `∏_a g_a(x_a)` with `g_b = π_b·φ_b`, `g_a = π_a` otherwise), apply
`Fintype.prod_sum` to turn `∑_x ∏_a g_a` into `∏_a (∑_j g_a j)`, and collapse
the `a ≠ b` factors (`∑_j π_a j = 1`). -/
theorem marginal_collapse
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (b : ι) (φb : κ b → ℝ) :
    ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * φb (x b)
      = ∑ j, π b j * φb j := by
  classical
  -- The "twisted" family g: agent b's distribution weighted by φb.
  set g : ∀ a, κ a → ℝ :=
    fun a => if h : a = b then (fun j => π a j * (h ▸ φb) j) else π a with hg
  -- (1) The integrand rewrites as ∏ a, g a (x a).
  have h_integrand : ∀ x : (∀ a, κ a),
      (∏ a, π a (x a)) * φb (x b) = ∏ a, g a (x a) := by
    intro x
    have hb_mem : b ∈ (Finset.univ : Finset ι) := Finset.mem_univ b
    -- Split both products at the coordinate b.
    rw [← Finset.prod_erase_mul (Finset.univ) (fun a => π a (x a)) hb_mem,
        ← Finset.prod_erase_mul (Finset.univ) (fun a => g a (x a)) hb_mem]
    -- The b-th factor of g is π b (x b) * φb (x b).
    have hgb : g b (x b) = π b (x b) * φb (x b) := by
      simp only [hg, dif_pos rfl]
    -- The erased factors of g coincide with those of π.
    have hrest : ∀ a ∈ (Finset.univ.erase b), g a (x a) = π a (x a) := by
      intro a ha
      have hne : a ≠ b := Finset.ne_of_mem_erase ha
      simp only [hg, dif_neg hne]
    rw [Finset.prod_congr rfl hrest, hgb]
    ring
  -- (2) Apply Fintype.prod_sum to the twisted family.
  calc ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * φb (x b)
      = ∑ x : (∀ a, κ a), ∏ a, g a (x a) :=
        Finset.sum_congr rfl (fun x _ => h_integrand x)
    _ = ∏ a, (∑ j, g a j) := (Fintype.prod_sum g).symm
    _ = ∑ j, π b j * φb j := by
        -- Collapse the a ≠ b factors (each ∑ g a = 1), keep the b-th.
        have hb_mem : b ∈ (Finset.univ : Finset ι) := Finset.mem_univ b
        rw [← Finset.prod_erase_mul (Finset.univ) (fun a => ∑ j, g a j) hb_mem]
        have hbsum : (∑ j, g b j) = ∑ j, π b j * φb j := by
          simp only [hg, dif_pos rfl]
        have hrest : ∀ a ∈ (Finset.univ.erase b), (∑ j, g a j) = 1 := by
          intro a ha
          have hne : a ≠ b := Finset.ne_of_mem_erase ha
          simp only [hg, dif_neg hne]; exact hπ_sum a
        rw [Finset.prod_congr rfl hrest, Finset.prod_const_one, hbsum, one_mul]

/-- **(b) Additive per-agent decomposition of the joint potential.**

If the joint potential is additive across agents, `Φ(x) = ∑_a φ_a(x_a)`, then
the joint expectation under the tensor product law decomposes into the sum of
per-agent private expectations:

    Φ_joint  =  ∑_x (∏_a π_a(x_a)) · (∑_a φ_a(x_a))  =  ∑_a ( ∑_j π_a(j)·φ_a(j) ).

Expectation linearity for the product law: swap the two sums, then collapse each
agent's marginal via `marginal_collapse`. -/
theorem joint_potential_additive_decomposition
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ)
    (hπ_sum : ∀ a, ∑ j, π a j = 1) :
    (∑ x : (∀ a, κ a), (∏ a, π a (x a)) * (∑ b, φ b (x b)))
      = ∑ b, ∑ j, π b j * φ b j := by
  classical
  -- Distribute the product weight over the inner sum, then swap the sums.
  have hstep : ∀ x : (∀ a, κ a),
      (∏ a, π a (x a)) * (∑ b, φ b (x b))
        = ∑ b, (∏ a, π a (x a)) * φ b (x b) := by
    intro x; rw [Finset.mul_sum]
  calc (∑ x : (∀ a, κ a), (∏ a, π a (x a)) * (∑ b, φ b (x b)))
      = ∑ x : (∀ a, κ a), ∑ b, (∏ a, π a (x a)) * φ b (x b) :=
        Finset.sum_congr rfl (fun x _ => hstep x)
    _ = ∑ b, ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * φ b (x b) :=
        Finset.sum_comm
    _ = ∑ b, ∑ j, π b j * φ b j :=
        Finset.sum_congr rfl (fun b _ => marginal_collapse π hπ_sum b (φ b))

/-! ## Step 2 (c) — HEADLINE: the multi-agent Ohm budget law. -/

/-- **Each agent's private expectation is bounded by its envelope mass.**

If `φ_a(j) ≤ Mφ a` for all `j` and `π_a` is a nonnegative normalised
distribution, then the private expectation `∑_j π_a(j)·φ_a(j) ≤ Mφ a`. -/
theorem agent_expectation_le_envelope
    {ι : Type} [Fintype ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ) (Mφ : ι → ℝ)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (h_env : ∀ a j, φ a j ≤ Mφ a)
    (a : ι) :
    ∑ j, π a j * φ a j ≤ Mφ a := by
  calc ∑ j, π a j * φ a j
      ≤ ∑ j, π a j * Mφ a :=
        Finset.sum_le_sum
          (fun j _ => mul_le_mul_of_nonneg_left (h_env a j) (hπ_nonneg a j))
    _ = (∑ j, π a j) * Mφ a := by rw [Finset.sum_mul]
    _ = 1 * Mφ a := by rw [hπ_sum a]
    _ = Mφ a := one_mul _

/-- **(c) HEADLINE — the multi-agent Ohm budget law.**

The joint Ohm budget of `k` INDEPENDENT agents, grounded in the tensor
conservation law. In the additive-potential regime `Φ(x) = ∑_a φ_a(x_a)` with
nonnegative potentials and per-agent upper envelopes `φ_a(j) ≤ Mφ a`, the joint
Ohm budget `N_joint = ⌈Z · Φ_joint⌉₊` satisfies the SUBADDITIVITY law

    N_joint  ≤  ∑_a ⌈Z · Mφ a⌉₊.

The joint product system never costs more interventions than the pooled total
of the independent per-agent Ohm budgets. Chain of corpus results:

  * R4_Agent6 `tensor_conservation_k`  →  the product weights are normalised,
    so `Φ_joint` is a convex combination (used inside the additive
    decomposition's marginal collapse, which IS `Fintype.prod_sum`);
  * `joint_potential_additive_decomposition` (b)  →  `Φ_joint = ∑_a E_a`;
  * `agent_expectation_le_envelope`  →  `E_a ≤ Mφ a`, hence `Φ_joint ≤ ∑_a Mφ a`;
  * monotonicity of `Z·(·)` (Z ≥ 0) and `Nat.ceil_mono`  →
        `N_joint ≤ ⌈Z·∑_a Mφ a⌉₊`;
  * R4_Agent1 `ceil_sum_le` (`⌈∑ x⌉₊ ≤ ∑ ⌈x⌉₊`)  →  split the ceiling:
        `⌈Z·∑_a Mφ a⌉₊ ≤ ∑_a ⌈Z·Mφ a⌉₊`. -/
theorem multi_agent_ohm_budget_law
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ) (Mφ : ι → ℝ)
    (Φjoint Z : ℝ) (Njoint : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (h_env : ∀ a j, φ a j ≤ Mφ a)
    (h_def : Φjoint = ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * (∑ b, φ b (x b)))
    (h_ohm : Njoint = ⌈Z * Φjoint⌉₊) :
    Njoint ≤ ∑ a, ⌈Z * Mφ a⌉₊ := by
  classical
  -- (b): the joint potential is the sum of per-agent expectations.
  have h_decomp : Φjoint = ∑ b, ∑ j, π b j * φ b j := by
    rw [h_def]; exact joint_potential_additive_decomposition π φ hπ_sum
  -- Each per-agent expectation is bounded by its envelope mass.
  have h_each : ∀ a, (∑ j, π a j * φ a j) ≤ Mφ a :=
    fun a => agent_expectation_le_envelope π φ Mφ hπ_nonneg hπ_sum h_env a
  -- Hence Φ_joint ≤ ∑_a Mφ a.
  have h_phi_le : Φjoint ≤ ∑ a, Mφ a := by
    rw [h_decomp]; exact Finset.sum_le_sum (fun a _ => h_each a)
  -- Scale by Z ≥ 0 and push through the ceiling (monotone).
  have hZ : Z * Φjoint ≤ Z * ∑ a, Mφ a :=
    mul_le_mul_of_nonneg_left h_phi_le hZ_nonneg
  -- ⌈Z·∑ Mφ⌉₊ = ⌈∑ (Z·Mφ)⌉₊  (distribute), then R4_Agent1's ceil_sum_le.
  have h_dist : Z * ∑ a, Mφ a = ∑ a, Z * Mφ a := by rw [Finset.mul_sum]
  calc Njoint = ⌈Z * Φjoint⌉₊ := h_ohm
    _ ≤ ⌈Z * ∑ a, Mφ a⌉₊ := Nat.ceil_mono hZ
    _ = ⌈∑ a, Z * Mφ a⌉₊ := by rw [h_dist]
    _ ≤ ∑ a, ⌈Z * Mφ a⌉₊ :=
        R4_Agent1_OhmConservationCoupling.ceil_sum_le (fun a => Z * Mφ a)

end R5_Agent4_TensorOhmBudget

end MIP
