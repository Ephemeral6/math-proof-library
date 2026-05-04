# A2 Final Summary — OP-2 v6 / Fixed-Momentum SHB Non-Convex Stationary-Point LB

**Project**: A2 (the non-convex extension of OP-2 v5).
**Date**: 2026-04-28 to 2026-04-29.
**Status**: ✅ **COMPLETE.** All 6 phases passed; numerical gate 19/19 PASS.

---

## TL;DR

We proved an algorithm-specific lower bound for the last-iterate stationary
gradient norm of fixed-momentum stochastic heavy ball (SHB):

> **Theorem A2.** Let $L, D, \sigma > 0$, $T \geq 1$, $K = 3$, $\mu := 0.01\,L$,
> and let $\mathcal F_{K=3} := \{(\beta, L\eta) : \gamma_{\mathrm{crit}}(\beta) <
> L\eta < 2(1+\beta)\}$ where $\gamma_{\mathrm{crit}}(\beta) = 3(1+\beta+\beta^2)/(1+2\beta)$.
> There exists an $L$-smooth **non-convex** function $f^{(s)}: \R^4 \to \R$ and
> an unbiased stochastic gradient oracle with variance $\leq \sigma^2$ such that
> for every $(\beta, L\eta) \in \mathcal F_{K=3}$, the SHB last-iterate satisfies
> $$\boxed{\;
> \max_{s \in \{\pm 1\}}\E_s\bigl[\|\nabla f^{(s)}(x_T, y_T, z_T)\|^2\bigr]
> \;\geq\; \max\Bigl\{\frac{\sigma^2}{27\,T},\ \frac{3 D^2 (1+\beta+\beta^2)}{2\,\eta^2}\Bigr\}
> \quad \forall T \geq 1.\;}$$

The first term is the Arjevani-style variance LB (Frame 2). The second is the
**algorithm-specific cycling constant** $B_{\mathrm{NC}}(\beta, \eta)$ (Frame 1)
which is **constant in $T$** and dominates the variance term whenever
$T \geq T_0 := 2\sigma^2 \eta^2 / [81 D^2(1+\beta+\beta^2)]$.

In contrast, SGD ($\beta = 0$) on the same instance achieves $\E[\|\nabla f\|^2]
= O(L\Delta/T + L\sigma^2/\sqrt T) \to 0$ at the standard Ghadimi–Lan rate,
giving an unbounded ratio SHB/SGD as $T \to \infty$ (Phase 6 G3 verified at
T=200: SGD has ‖grad‖² ~ 10⁻⁸ while SHB has ~ 0.33 — separation > 10⁷).

---

## Phase-by-phase results

### Phase 1 — Literature scan
- 14 papers verified by web_search + WebFetch.
- A2 is **open** with ~88% confidence.
- 3 obstacles identified:
  - **O1** (Sun et al. IJCAI 2019): HB a.s. escapes strict saddles.
  - **O2** (Okamura et al. 2024): HB-ODE achieves ε⁻⁷/⁴ under Lipschitz Hessian.
  - **O3** (Wang–Abernethy 2020, Gupta–Wojtowytsch 2025): HB beats GD on benign / phase-retrieval / cubic-reg.

### Phase 2 — Hard instance design (Candidate A)
$$f^{(s)}(x, y, z) = f_0(x) + \alpha_s y + w(y) + h(z), \quad h(z) = \tfrac{L}{2}\,z^2 e^{-z^2/D^2}.$$
- $f_0$: rescaled Goujaud (OP-2 v5 §2.1).
- $\alpha_s y + w(y)$: OP-2 v5 wall (verbatim).
- $h(z)$: new non-convex bump (Phase-2 contribution).

All 4 obstacles sidestepped:
- O1: SHB iterate stays at $z = 0$ forever (h'(0) = 0, no z-noise).
- O2: $f_0$ is $C^{1,1}$ but not $C^2$ (polytope distance Hessian discontinuous).
- O3: cycling is the OPPOSITE of benign.
- μ → 0 limit: μ cancels in the LB algebra (verified at 100-digit precision).

### Phase 3 — Cycling-saddle correspondence
The cycling is **NOT** any of (heteroclinic, saddle-attracted limit cycle,
trapped near saddle). It is **rotational-symmetry algebraic limit cycling on a
convex polytope boundary**, with the non-convex saddle structure *orthogonal*
to the cycling subspace. This evades Sun 2019 escape entirely.

### Phase 4 — 6-frame Explorer (all 6 closed)
| Frame | Output | Length | Highlight |
|---|---|---|---|
| 1 | `frame1_proof.md` | 25 KB | Direct migration; complete proof of B_NC = 3D²(1+β+β²)/(2η²) |
| 2 | `frame2_proof.md` | 8.6 KB | Le Cam two-point on ‖∇f‖²; constant 1/27 |
| 3 | `frame3_constants.md` + `.py` | 6 KB + verifier | sup/inf closed forms; β* = (√13-3)/2 |
| 4 | `frame4_arjevani.md` | 10.7 KB | A2 vs Arjevani: orthogonal results |
| 5 | `frame5_verify.py` + `frame5_numerical.md` | 22 KB + 14 KB | 6 tests at 100-dps precision |
| 6 | `frame6_dynamics.md` | 11.5 KB | Floquet stability; categorical: no natural functor |

### Phase 5a — Judge: Frame 1 (with Frame 2 supplement) selected as winner.

### Phase 5b — Auditor: PASS with 1 MEDIUM + 2 LOW citation hygiene defects.
- M1: Sun et al. IJCAI 2019 author list garbled in verification log (math impact: 0).
- L1: "OP-2 v5 Lemma 1.4" mis-labeled (should be Lemma 1.1 + 1.3(i)).
- L2: Okamura first name "Kansei Ushiyama" → "Kaito".

### Phase 5c — Fixer: All 3 defects resolved (text-only fixes; no math change).

### Phase 6 — Numerical gate: **19/19 PASS** (G1: 4/4, G2: 5/5, G3: 4/4, G4: 3/3, G5: 3/3).

---

## Key results

### Closed-form LB constant
$$B_{\mathrm{NC}}(\beta, \eta) = \frac{3 D^2 (1 + \beta + \beta^2)}{2\,\eta^2}$$
- **μ-independent** (proven analytically by exact cancellation; verified at 10⁻¹⁰¹ precision).
- **T-independent** (constant for all T ≥ 1).
- **Vanishes only at β = 0** (where ℱ_{K=3} also becomes empty).

### Constants over ℱ_{K=3}
- **Sup**: $B^{\sup}(\beta) = (L^2 D^2/6) \cdot (1+2\beta)^2/(1+\beta+\beta^2)$, max at $\beta \to 1, \gamma \to 3^+$ giving $L^2 D^2 / 2$.
- **Inf**: $B^{\inf}(\beta) = (3L^2 D^2/8) \cdot (1+\beta+\beta^2)/(1+\beta)^2$, min at $\beta \to 1, \gamma \to 4^-$ giving $9 L^2 D^2 / 32$.
- **β-threshold**: $\beta^\star = (\sqrt{13} - 3)/2 \approx 0.3028$ below which ℱ is empty.

### Floquet stability of the cycle
At $(\beta, L\eta, \mu/L) = (0.5, 2.8, 0.01)$, the 3-step Floquet multipliers are
$\lambda_+^3 = 0.831$ and $\lambda_-^3 = 0.150$ — both $< 1$, so the cycle is
**asymptotically stable** in the (x, x_{-1}) phase space. At μ → 0:
$\lambda_+^K \to 1$ (neutral in the rotational direction), explaining the
init-sensitivity (FP-OP2-CYCLING-INIT-BASIN-DEPENDENCE) in Floquet language.

### Comparison with prior literature
- **Arjevani et al. 2019/2023** (arXiv:1912.02365): minimax LB $\Omega(\Delta L \sigma^2/\varepsilon^4)$ for any first-order method on L-smooth non-convex. **Algorithm-agnostic**, decays as $1/T$. SGD attains this. A2 is **orthogonal**: algorithm-specific to fixed-momentum SHB, constant in $T$ (after $T_0$).
- **Sun et al. IJCAI 2019** (arXiv:1907.09697): deterministic HB a.s. avoids strict saddles. **Sidestepped** by Candidate A's z-coordinate decoupling.
- **Okamura et al. 2024** (arXiv:2406.06100): HB-ODE attains $\varepsilon^{-7/4}$ under Lipschitz Hessian. **Sidestepped** because $f_0$ is $C^{1,1}$ but not $C^2$.
- **OP-2 v5** (Pan 2026): convex bias-term LB; the present work is its non-convex stationary-point analog with the same Goujaud cycling skeleton plus an orthogonal non-convex bump.

---

## Files written

```
workspace/active/op2_v6_a2/
├── a2_progress.md                    [Phase tracking]
├── a2_final_summary.md               [THIS FILE]
├── literature_scan.md                [Phase 1; 14 verified citations]
├── hard_instance_candidates.md       [Phase 2; Candidate A construction]
├── cycling_saddle_correspondence.md  [Phase 3; orthogonal non-convexity framing]
├── phase2_verify.py                  [Phase 2; 11-step verifier]
├── frame1_proof.md                   [Frame 1; primary proof]
├── frame2_proof.md                   [Frame 2; variance term]
├── frame3_constants.md               [Frame 3; sup/inf closed forms]
├── frame3_constants.py               [Frame 3 verifier]
├── frame3_constants_sweep.csv        [Frame 3 numerical sweep]
├── frame3_constants_heatmap.png      [Frame 3 visualization]
├── frame4_arjevani.md                [Frame 4; Arjevani comparison]
├── frame5_verify.py                  [Frame 5; 100-dps verifier]
├── frame5_numerical.md               [Frame 5; 6-test report]
├── frame5_output.txt                 [Frame 5 actual run output]
├── frame6_dynamics.md                [Frame 6; Floquet + categorical]
├── judge_verdict.md                  [Phase 5a]
├── auditor_report.md                 [Phase 5b]
├── fixer_log.md                      [Phase 5c]
├── phase6_gate.py                    [Phase 6 gate]
├── phase6_output.txt                 [Phase 6 actual run output]
└── phase6_report.md                  [Phase 6 report]
```

Total deliverables: ~22 files, ~250 KB.

---

## Citation hygiene log (the Pedregosa-vs-Dieuleveut lesson)

OP-2 v3-v4 had 387 occurrences of a "Goujaud-Pedregosa-Taylor" hallucination,
fixed in v5 [MOD v5-7]. For A2, every author/venue/year was verified by:
- Phase 1: WebSearch + WebFetch on arXiv abstract pages.
- Each Frame: in-frame web_search before quoting any new paper.
- Phase 5b Auditor: re-verified all 7 citations.
- Phase 5c Fixer: corrected 3 transcription typos (none affecting math).

Verified citations in the final proof:
1. Goujaud–Taylor–Dieuleveut, Math. Prog. 2025, arXiv:2307.11291.
2. Sun–Li–Quan–Jiang–Li–Dou, IJCAI 2019, arXiv:1907.09697.
3. Okamura–Marumo–Takeda, Optim. Lett. 2025, arXiv:2406.06100.
4. Wang–Abernethy, arXiv:2010.01449 (2020).
5. Arjevani–Carmon–Duchi–Foster–Srebro–Woodworth, Math. Prog. 2023, arXiv:1912.02365.
6. Yu, "Assouad, Fano, Le Cam", Festschrift for L. Le Cam 1997, Ch. 24.
7. Yan–Yang–Li–Lin–Yang, arXiv:1808.10396 (2018).
8. OP-2 v5 (`workspace/op2_proof_v5.tex`, Pan 2026).
9. Lessard–Recht–Packard, SIOPT 2016, arXiv:1408.3595.
10. Ghadimi–Feyzmahdavian–Johansson, arXiv:1412.7457 (2015).
11. Kidambi–Netrapalli–Jain–Kakade, ICLR 2018, arXiv:1803.05591.
12. Loizou–Richtárik, NeurIPS OPT workshop 2017, arXiv:1710.10737.
13. Jin–Ge–Netrapalli–Kakade–Jordan, ICML 2017, arXiv:1703.00887.
14. Du–Jin–Lee–Jordan–Póczos–Singh, NeurIPS 2017, arXiv:1705.10412.

Plus 4 supporting recent papers in literature_scan.md §2A (Saad-Lee-Orabona
COLT 2025, Sahu-Hogan-Wells Jan 2026, Wang-Yurtsever Feb 2026, Le JOTA 2024).

---

## Suggested next steps (for archiving)

Per the project CLAUDE.md auto-archive workflow (Step A-E):

- **Class**: A (research-level, 2025-2026 paper-relevant, novel proof technique).
- **Branch**: `optimization/convergence` or `optimization/lower-bounds` (the latter
  better fits the "algorithm-specific LB" content). Suggest:
  `proofs/research/optimization/lower-bounds/shb-stationary-point-orthogonal-nonconvex/`
- **Folder contents**:
  - `problem.md` — the A2 theorem statement (use Phase 1 §3.3 + Phase 2 §A.8).
  - `proof.md` — clean version (Frame 1 + Frame 2 merged, ~30 KB).
  - `report.md` — full report (this file + auditor report + numerical gate).
  - `notes.md` — the proof technique (Phase 3's "orthogonal non-convexity" framing) + how Candidate A relates to the four obstacles.
  - `failed_attempts/` — the 3 deferred candidates (B multi-well, C cubic perturbation, plus any per-frame STUCK if any). Frame 4 is non-failed but optional.

- **Index**: add row to `RESEARCH_INDEX.md`:
  `| Fixed-momentum SHB does not match Arjevani on non-convex stationary points | OP-2 v6 / 本工作 (2026-04) | research | 2026-04-29 | proofs/research/optimization/lower-bounds/shb-stationary-point-orthogonal-nonconvex/ |`

- **Strategy index update**: add the new strategy signature
  `shb-stationary-point-lb-orthogonal-nonconvex` (per Phase 3 §6.3).

- **Failure pattern update**: none new from A2 (all 5 prior warnings respected).

The CLAUDE.md auto-archive can be triggered by saying "archive this".
