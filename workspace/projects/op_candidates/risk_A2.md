# Risk Assessment: Direction A2
# SHB Non-Convex Stochastic Lower Bound for ε-Stationary Point
# Generated: 2026-04-28

---

## 1. Has Arjevani 2023 or follow-ups already covered SHB?

### Search result: NO — gap is NOT closed

Detailed search across all 2023–2026 literature confirms:

**Arjevani et al. 2023 (Math. Prog.)** [arxiv:1912.02365]:
- Proves minimax LB Ω(ε⁻⁴) for all SFO algorithms in smooth non-convex setting.
- Does NOT construct SHB-specific hard instance.
- Does NOT show β-dependent constant or prove SHB specifically cannot achieve better than ε⁻⁴.
- The paper explicitly targets the all-algorithms minimax bound, not algorithm-specific bounds.
- Conclusion: not a blocker for A2.

**Saad, Lee, Orabona 2025 (COLT)** [arxiv:2502.14060]:
- New LBs via divergence decomposition for structured classes (QC, QG, RSI).
- Tighter constants for specific function classes.
- Does NOT address SHB-specific or momentum-specific LBs.
- Conclusion: not a blocker; potential citation.

**Goujaud, Taylor, Dieuleveut 2023 / 2025** [arxiv:2307.11291]:
- SHB-specific cycling LB, but **strictly in convex/SC setting**.
- Non-convex smooth setting is explicitly out of scope.
- Future work section (COLT 2025 "Two Riddles") mentions non-convex extension as open.
- Conclusion: confirms the gap is open; strongest prior art to build on.

**Le 2023/2024** [arxiv:2304.13328]:
- Nonsmooth non-convex SHB: proves a.s. convergence to Clarke critical points.
- NO quantitative complexity bound (no ε⁻⁴ rate).
- NO lower bound.
- Conclusion: convergence result, not a LB paper; not a blocker.

**Varre et al. 2024/2025** [arxiv:2401.06738]:
- Strongly convex setting only (accelerated SHB with mini-batch threshold).
- Not non-convex.
- Conclusion: not a blocker.

**Wang et al. 2024 ICLR** [arxiv:2307.15196]:
- "Marginal value of momentum" in small-LR regime: SGD and SHB are equivalent.
- This is a UB equivalence result, not an LB for SHB.
- Applies to specific small-LR regime; does not give β-dependent hard instance.
- Conclusion: supportive context, not a blocker.

**IJCAI 2024 heavy ball β→1**:
- Shows β→1 hurts convergence. No tight LB construction.
- Not SHB-specific in the ε-stationary sense.
- Conclusion: supporting evidence, not a blocker.

**Overall verdict: Gap is open.** No paper has proved an SHB-specific LB with explicit β-dependence for smooth non-convex stochastic optimization.

---

## 2. Known Obstructions

### Obstruction 1: Non-convex cycling is topologically harder than convex cycling

In the convex/SC setting, the GTD cycle is around x* on a 2D function. The dynamics are nearly linear (the Hessian at x* controls the iteration matrix), and the cycling condition reduces to checking a quadratic inequality (the Goujaud feasibility region F_K).

In the non-convex setting:
- There is no distinguished point (x* is not the target; ε-stationarity is).
- Cycling must be "ε-gradient avoidance" on a non-linear system.
- The Brouwer fixed-point theorem implies any continuous map of a convex compact set into itself has a fixed point — so cycles must be arranged in non-contractible spaces. For smooth gradient flows on ℝ^d, cycles in the gradient descent dynamics require the function to have critical points "inside" the cycle (index theory). This is achievable (e.g., saddle points inside) but requires careful construction.

Mitigation: Restrict to 1-D stochastic case or periodic functions on a circle. On ℝ (or a quotient), cycles can persist without fixed points. The periodic function approach (e.g., f(x) = -cos(ωx) on the torus) is the standard non-convex cycling construction and avoids Brouwer issues.

### Obstruction 2: SHB may actually converge to ε-stationary in non-convex setting

Unlike in the convex/SC setting where SHB is provably non-convergent on GTD's function, in the non-convex stochastic setting it is NOT clear that fixed-β SHB fails to find ε-stationary points. In fact, heuristic arguments suggest SHB behaves similarly to SGD for E‖∇f‖² targets: both achieve O(ε⁻⁴) without acceleration. The "failure" of SHB in non-convex is not divergence but rather inability to beat ε⁻⁴ — the same rate as SGD.

Implication: A2 may not produce a statement of the form "SHB fails" but rather "SHB matches but does not improve upon SGD's ε⁻⁴." This is still publishable but is less dramatic than OP-2's "SHB cannot accelerate."

Mitigation: Frame A2 as confirming the tight complexity for SHB in non-convex setting, establishing that the Arjevani minimax hard instance is also hard for SHB with explicit β-dependent constant.

### Obstruction 3: The SHB convergence theory in non-convex smooth setting is incomplete

To state "SHB requires Ω(ε⁻⁴)" it is implicitly assumed that SHB can actually achieve ε-stationarity at all. For non-convex smooth stochastic problems, the convergence of SHB with fixed β is NOT rigorously established in full generality (unlike SGD, where Ghadimi-Lan 2013 gives the full proof). Le 2023 handles the nonsmooth case under semialgebraic assumptions; there is no clean analogue of Ghadimi-Lan for SHB in smooth non-convex.

This creates a logical gap: if SHB does not converge at all, then an ε⁻⁴ LB is trivially "true" but vacuous.

Mitigation: Either prove a matching O(ε⁻⁴) UB for SHB as part of A2 (doable; standard SHB analysis extends to non-convex under bounded variance), or restrict the LB statement to "SHB with β in a specific regime satisfies convergence, and for this regime the complexity is Ω(ε⁻⁴)."

### Obstruction 4: Birkhoff averaging collapse (inherited from OP-2 failure)

The known failure trap: if the LB construction uses an averaging argument, Birkhoff's theorem can collapse the bound. In the non-convex setting, averaging over iterates is used to define ε-stationarity (E[min_{t≤T}‖∇f‖²] or E[‖∇f(x̄_T)‖²] with uniform average). If the construction is cycling, the average ‖∇f‖ may collapse to 0 despite each individual iterate having ‖∇f‖ ≥ ε — if the cycle is symmetric.

Mitigation: Same fix as in OP-2 — use asymmetric cycles where ‖∇f‖ ≥ ε at all cycle points (not just in average). Or target the last-iterate / minimum-iterate criterion explicitly (as was done in OP-2).

---

## 3. 6-Week Feasibility

**Verdict: MEDIUM**

### Breakdown

| Phase | Task | Time | Confidence |
|---|---|---|---|
| Week 1 | Literature deep-read; write precise theorem statement; identify best route (I vs II vs III from technical_A2.md) | 1 week | HIGH |
| Week 2 | Attempt Route I (oracle restriction + bias): adapt Arjevani hard instance for SHB; derive β-dependent constant | 1 week | MEDIUM |
| Week 3 | Attempt Route II (cycling in non-convex): 1-D periodic construction; check Brouwer obstruction; verify cycling persists stochastically | 1 week | MEDIUM-LOW |
| Week 4 | Combine Routes I+II or consolidate the strongest result; numerical verification | 1 week | MEDIUM |
| Week 5 | Write proof; audit; fix gaps | 1 week | MEDIUM |
| Week 6 | Polish; write paper section; archive | 1 week | HIGH |

### Risk factors

- Route II (non-convex cycling) may fail if the topological obstruction is severe — fallback to Route I only, which gives a weaker but clean result.
- The upper bound for SHB in non-convex may need to be proved as a sub-result (adding ~1 week).
- If the result is "SHB matches SGD at ε⁻⁴, no separation," the publication value decreases — still publishable but as a "tight analysis" rather than "new failure phenomenon."

### Best-case outcome (6 weeks)

Theorem: For any fixed β ∈ (0,1), there exists a smooth non-convex f and a bounded-variance stochastic oracle such that SHB with parameter β requires at least C(β)·ε⁻⁴ oracle queries to find E‖∇f(x_t)‖ ≤ ε, where C(β) > C(0) = C_SGD — i.e., momentum strictly hurts relative to SGD.

This would be the first algorithm-specific LB showing momentum is provably suboptimal in smooth non-convex stochastic optimization with an explicit β-dependent constant.

### Worst-case outcome (6 weeks)

The gap analysis shows SHB achieves ε⁻⁴ (same as SGD) and the cycling construction either fails or produces only a trivial separation. Result: clean confirmation that SHB has complexity Θ(ε⁻⁴), matching Arjevani's minimax LB, with proof of matching UB for SHB. Still publishable as a "tight analysis of SHB in non-convex stochastic" but less impactful.

---

## 4. Top 3 Risks

### Risk 1 (HIGHEST): Incremental over OP-2 — reviewers may see A2 as "obvious corollary"

The conceptual move from OP-2 (smooth convex SHB LB) to A2 (smooth non-convex SHB LB) is technically non-trivial but thematically similar. Reviewers familiar with OP-2 may view A2 as an extension, not a new result. Specifically:
- If the Arjevani minimax LB already applies to SHB by definition, then A2's contribution is only the β-explicit constant or the cycling construction — both of which may be seen as "technical improvements."
- Mitigation: Frame A2 as answering a complementary question — OP-2 asks "does SHB accelerate?" (No). A2 asks "does SHB converge to stationary points at the same rate as SGD?" (possibly No — SHB may be strictly worse with explicit β-dependent slowdown). If the latter holds, A2 is a genuinely new phenomenon.

### Risk 2 (HIGH): Non-convex cycling construction fails

The non-convex cycling approach (Route II) requires constructing a smooth f on which SHB orbits avoid ε-stationary points for Ω(ε⁻⁴) steps. This is a genuinely new construction with no existing template. If the topological or analytic constraints prevent such a function from existing, the main route fails and A2 degrades to Route I (oracle restriction) which is less novel.

### Risk 3 (MEDIUM): Competing paper appears during 6-week window

The field is active (COLT 2025, ICLR 2025, 2026 preprints on momentum LBs). A paper on "SHB non-convex stochastic LB" from Arjevani's group or Goujaud/Taylor's group would close the gap. The COLT 2025 Saad et al. paper shows the field is moving; a follow-up from that group extending to algorithm-specific LBs would be the most direct threat.

Probability estimate: ~15–20% in a 6-week window based on current publication rate.
