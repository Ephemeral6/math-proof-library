/-
STATUS: ✅ Compiles, axiom-free, sorry-free.
AGENT: R3_Agent6 (Degeneration family).
DIRECTION: Item (H) — MDL + PAC-Bayes joint generalisation bound.
SUMMARY:
  Compose R.405 (Kolmogorov / MDL) and R.406 (PAC-Bayes) to derive a joint
  upper bound that wires the *information-theoretic* description-length
  inequality of R.405 into the *statistical* generalisation bound of R.406.

  Logic:
    1. R.405 gives  `K(p|X) ≤ N · log|M| + c`  (MDL-MIP).
    2. R.406 gives  `err ≤ err_S + sqrt(KL / (2 m))`  (PAC-Bayes).
    3. Identify the divergence in the PAC-Bayes bound with the MDL
       complexity: `KL ≥ K(p|X)` (the MDL-PAC-Bayes coupling, see e.g.
       Catoni / Dziugaite-Roy interpretation).  Under this identification,
       the PAC-Bayes bound dominates the MDL one in the sense that more
       description length (= more KL) loosens the generalisation bound —
       which is the *combined* MDL + PAC-Bayes message:

         err ≤ err_S + sqrt(N·log|M| + c / (2m))    (when KL ≤ MDL bound).

  We formalize:
    (i)  A simple sandwich: PAC-Bayes + MDL ⟹ a joint bound that monotonously
         degrades as either `K(p|X)` or `1/m` rises.
    (ii) The transitive chain: if `KL ≤ KL_max` AND `KL_max` is the MDL bound,
         then PAC-Bayes against `KL_max` upper-bounds PAC-Bayes against `KL`.
    (iii) The infinite-data limit transports: `err_S + sqrt(KL/(2m)) → err_S`
          (R.406 (5)).

Depends on:
  - MIP.KolmogorovMDL.R_405_mdl_mip_bound   (R.405)
  - MIP.KolmogorovMDL.R_405_info_ohm_lower  (R.405)
  - MIP.PACBayes.bound                      (R.406)
  - MIP.PACBayes.errS_le_bound              (R.406)
  - MIP.PACBayes.bound_mono_KL              (R.406)
  - MIP.PACBayes.bound_antitone_m           (R.406)
  - MIP.PACBayes.tendsto_bound_errS         (R.406)
-/
import MIP.Results.R405_KolmogorovMDL
import MIP.Results.R406_PACBayes

namespace MIP

namespace R3_Agent6_MDL_PACBayes

open MIP.KolmogorovMDL
open MIP.PACBayes
open Filter Topology

/-- **R3-A6 MDL+PAC (i) — MDL upper bound on the divergence dominates PAC-Bayes.**

Given the MDL-MIP bound `K(p|X) ≤ N·log|M| + c` (R.405) and a hypothesis
`KL ≤ K(p|X)` (the MDL-PAC-Bayes coupling: posterior-vs-prior divergence is
no larger than the MDL description-length surplus), the PAC-Bayes bound
against `KL` is upper-bounded by the PAC-Bayes bound against the MDL bound:

    `bound errS KL m ≤ bound errS (N·log|M| + c) m`.

Cites R.405 (`R_405_mdl_mip_bound`) and R.406 (`bound_mono_KL`). -/
theorem R3_A6_pacbayes_dominated_by_MDL
    (errS KL KpX Nbits N logM c m : ℝ)
    (hm : 0 < m)
    (hchan : KpX ≤ Nbits + c) (hcap : Nbits ≤ N * logM)
    (hKL_le_KpX : KL ≤ KpX) :
    bound errS KL m ≤ bound errS (N * logM + c) m := by
  -- (R.405) KpX ≤ N·logM + c.
  have hMDL : KpX ≤ N * logM + c :=
    R_405_mdl_mip_bound KpX Nbits N logM c hchan hcap
  -- Transitivity:  KL ≤ KpX ≤ N·logM + c.
  have hKL_le : KL ≤ N * logM + c := le_trans hKL_le_KpX hMDL
  -- (R.406) monotone in KL.
  exact bound_mono_KL errS m hm hKL_le

/-- **R3-A6 MDL+PAC (ii) — joint sandwich `err_S ≤ err ≤ MDL-PAC-bound`.**

If a PAC-Bayes guarantee gives `err ≤ bound errS KL m` and `KL ≤ K(p|X)` with
the R.405 MDL-MIP bound active, then we obtain the joint two-sided bound:

    `err_S ≤ bound errS KL m ≤ bound errS (N·logM + c) m`.

The empirical error never exceeds either bound, and the MDL-relaxed bound is
the most pessimistic.  Cites R.405 (`R_405_mdl_mip_bound`) and R.406
(`errS_le_bound`, `bound_mono_KL`). -/
theorem R3_A6_joint_sandwich
    (err errS KL KpX Nbits N logM c m : ℝ)
    (hm : 0 < m)
    (hchan : KpX ≤ Nbits + c) (hcap : Nbits ≤ N * logM)
    (hKL_le_KpX : KL ≤ KpX)
    (hPB : err ≤ bound errS KL m) :
    errS ≤ bound errS KL m ∧
    bound errS KL m ≤ bound errS (N * logM + c) m ∧
    err ≤ bound errS (N * logM + c) m := by
  refine ⟨errS_le_bound errS KL m, ?_, ?_⟩
  · exact R3_A6_pacbayes_dominated_by_MDL errS KL KpX Nbits N logM c m hm hchan hcap hKL_le_KpX
  · exact le_trans hPB (R3_A6_pacbayes_dominated_by_MDL errS KL KpX Nbits N logM c m hm hchan hcap hKL_le_KpX)

/-- **R3-A6 MDL+PAC (iii) — joint asymptotic: more data and a fixed MDL bound.**

As `m → ∞` with the MDL bound `N·logM + c` held fixed, the PAC-Bayes bound
against `N·logM + c` collapses to `err_S` (R.406 (5)).  This is the
*statistical-MDL coupling at scale*: even the most pessimistic divergence
(the MDL bound) becomes irrelevant in the infinite-data limit. -/
theorem R3_A6_joint_asymptotic
    (errS N logM c : ℝ) :
    Tendsto (fun m : ℝ => bound errS (N * logM + c) m) atTop (nhds errS) :=
  tendsto_bound_errS errS (N * logM + c)

/-- **R3-A6 MDL+PAC (iv) — packaged joint MDL + PAC-Bayes generalisation theorem.**

Bundles the joint coupling: under the PAC-Bayes probabilistic guarantee
`err ≤ bound errS KL m` and the R.405 MDL hypothesis bundle, with
`KL ≤ K(p|X)`, the true error is sandwiched between empirical error and the
*MDL-relaxed* PAC-Bayes bound, AND that relaxed bound converges to empirical
error as data scales.  Cites R.405 + R.406. -/
theorem R3_A6_MDL_PACBayes_joint
    (err errS KL KpX Nbits N logM c m : ℝ)
    (hm : 0 < m)
    (hchan : KpX ≤ Nbits + c) (hcap : Nbits ≤ N * logM)
    (hKL_le_KpX : KL ≤ KpX)
    (hPB : err ≤ bound errS KL m) :
    (errS ≤ bound errS (N * logM + c) m) ∧
    (err ≤ bound errS (N * logM + c) m) ∧
    Tendsto (fun m : ℝ => bound errS (N * logM + c) m) atTop (nhds errS) := by
  have ⟨h1, _, h3⟩ := R3_A6_joint_sandwich err errS KL KpX Nbits N logM c m hm hchan hcap
                       hKL_le_KpX hPB
  -- h1 : errS ≤ bound errS KL m;
  -- compose with monotone bound on relaxation.
  refine ⟨?_, h3, R3_A6_joint_asymptotic errS N logM c⟩
  -- errS ≤ bound errS (N·logM + c) m follows from errS_le_bound applied to the
  -- relaxed KL, which is the R.406 (1) statement at the relaxed argument.
  exact errS_le_bound errS (N * logM + c) m

end R3_Agent6_MDL_PACBayes

end MIP
