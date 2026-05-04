# OP-2-sharpened — Final Literature Clearing + Proof Setup

**Date**: 2026-04-17
**Method**: OPP-follow-up, backward-citation sweep + theorem sharpening + route selection
**Outcome**: **⚠️ RE-SCOPE before LAUNCH** — tentative statement has latent issues, but a *sharpened variant* is clearly open and actionable. Proceed to `problem.md` after rephrasing.

---

## Step 1 — Backward-citation sweep

### 1.1 Upstream literature actually claimed

| Paper | Setting | Result | Bearing on OP-2-sharpened |
|---|---|---|---|
| Lessard-Recht-Packard 2016 [1408.3595](https://arxiv.org/abs/1408.3595) | Deterministic smooth strongly convex (not quadratic) | IQC counter-example: HB diverges at κ≈25 | Upper bound on what HB can handle — *not* directly an impossibility rate |
| Ghadimi-Feyzmahdavian-Johansson 2015 [1412.7457](https://arxiv.org/abs/1412.7457) | Deterministic smooth convex (non-strongly) | HB achieves **O(1/T)** on function value (ergodic avg) | Establishes our target matching upper bound |
| Kidambi-Netrapalli-Jain-Kakade 2018 [1803.05591](https://arxiv.org/abs/1803.05591) | Stochastic smooth *quadratic* (strongly convex) | HB, NAG cannot improve over SGD on specific 2D quadratic instances | *Strongly-convex quadratic only*; does not address non-strongly-convex |
| Sebbouh-Gower-Defazio 2020/21 [2006.07867](https://arxiv.org/abs/2006.07867) | Stochastic smooth convex, bounded variance | **o(1/√T)** a.s. rate for SHB *weighted average* | Positive result; states *last iterate* o(1/√T) also, but under bounded-iterate hypothesis |
| Schaipp et al. 2024 [2406.04142](https://arxiv.org/abs/2406.04142) | Stochastic smooth convex, adaptive step (MomDecSPS) | Convergence to exact minimizer, no interpolation needed | Adaptive step, not fixed β — does not invalidate OP-2 |
| Goujaud-Taylor-Dieuleveut 2023→Math.Prog. 2025 [2307.11291](https://arxiv.org/abs/2307.11291) | Deterministic smooth **strongly** convex | HB **provably non-accelerated** — cycles exist for any param choice | Closes strongly-convex deterministic; **does not extend to non-strongly-convex** (cycling construction relies on μ > 0 spectral gap) |
| Goujaud 2025 [2502.19916](https://arxiv.org/abs/2502.19916) (COLT OP) | Deterministic smooth strongly convex | Two new riddles — 1D HB acceleration? Lyapunov-free regions? | Concerns dim≤1 strongly-convex — orthogonal to OP-2 |
| "Noise-adaptive SHB" 2024 [2401.06738](https://arxiv.org/abs/2401.06738) | Stochastic strongly convex (+ quadratic acceleration) | SC smooth `O(exp(-T/κ) + σ²/T)` | Strongly-convex; doesn't touch non-SC |
| AOR-HB 2024 [2406.09772](https://arxiv.org/abs/2406.09772) | Deterministic strongly convex | First HB variant with global acceleration | SC; requires a *modified* HB — reinforces that vanilla HB is stuck |

### 1.2 Forward-citation check on Goujaud 2023/25 (cite-this papers Sept 2025 – Apr 2026)

Scanned 9 direct citers of [2307.11291]. **None** extend the non-acceleration proof to either (a) non-strongly-convex smooth or (b) stochastic HB. The paper's own Future Work §7 explicitly lists stochastic extension as open.

### 1.3 Tentative statement stress-test

User's tentative:
> "对 L-smooth 凸（非强凸）函数 f 和 stochastic oracle（方差 σ²），不存在固定动量 β ∈ (0,1) 使 SHB 的收敛率优于 Ω(1/T)。"

**Three issues**:

1. **Latent contradiction with Sebbouh 2021.** Sebbouh proves SHB's *weighted-average* iterates converge at rate o(1/√T) a.s. in expectation, so "rate ≥ Ω(1/T)" is simply **false** in the noise-dominated regime (σ > 0, large T): the stochastic O(σ/√T) term is **worse** than 1/T. A statement "cannot beat 1/T" is vacuous when the actual rate is σ/√T » 1/T.

2. **The right comparison is with AC-SA (Lan 2012)**, which achieves the *optimal* smooth convex stochastic rate `O(L·D²/T² + σ·D/√T)`. The meaningful question is whether fixed-β SHB can match the **L/T²** deterministic component — i.e., can SHB accelerate the bias term?

3. **"Any fixed β"** is the correct quantifier — a time-varying β_t effectively gives you back the degrees of freedom needed for acceleration (cf. Nesterov's method is an HB-with-time-varying-momentum in disguise).

### 1.4 Sharpened statement (use this)

> **OP-2-sharpened (final)**.  Let ε > 0, L > 0, σ > 0. There exists an L-smooth convex (not strongly convex) function $f : \mathbb{R}^d \to \mathbb{R}$ with $\arg\min f$ non-empty and a stochastic first-order oracle with bounded variance σ² such that for every fixed momentum $\beta \in [0,1)$, every fixed or diminishing step-size schedule $(\eta_t)_{t \geq 1}$, and every $T \geq 1$, the stochastic heavy ball iterate $x_T$ satisfies
> $$ \mathbb{E}[f(x_T) - \min f] \ \geq \ c \cdot \Big(\frac{L D^2}{T} + \frac{\sigma D}{\sqrt T}\Big) $$
> where $D$ is the distance from initialization to the minimizer set and $c > 0$ is a universal constant. In particular, SHB **cannot** achieve the L/T² bias-term rate that AC-SA attains.

This is a **matching lower bound to Ghadimi et al. 2015's O(1/T) deterministic rate**, showing fixed-β SHB is at most as good as GD in the bias-term. Equivalently: **fixed-β SHB does not accelerate in the smooth convex stochastic setting.**

---

## Step 2 — Is this genuinely open?

**Yes**, with high confidence (~85%). Signals:

1. Goujaud 2023/25 explicitly leaves the non-strongly-convex version open.
2. Kidambi 2018 only handles 2D strongly-convex *quadratics*.
3. Sebbouh 2021 gives an *upper* bound and does not address a matching lower bound.
4. Six months post the "Provable non-accelerations" final publication (Oct 2025), no follow-up has extended to the non-SC case.
5. The 2025 COLT "Two Riddles" paper confirms the community's active open questions are all in the strongly-convex regime.

**Residual risk (~15%)**: a low-profile 2024–2026 preprint may have addressed exactly this case and we missed it in the citation sweep. Mitigation: do one more targeted pass with Google Scholar Alert keywords in the first session of Scout.

---

## Step 3 — Assumption list for the sharpened theorem

**Function class**:
- $f : \mathbb{R}^d \to \mathbb{R}$ convex, L-smooth (Lipschitz gradient)
- $\arg\min f \neq \emptyset$, minimum value $f^\star > -\infty$
- **Not strongly convex** (μ = 0)
- Bounded domain not required (but helps the construction — can be added)

**Oracle**:
- Stochastic first-order: oracle returns $g_t = \nabla f(x_t) + \xi_t$ where $\mathbb{E}[\xi_t \mid x_t] = 0$ and $\mathbb{E}[\|\xi_t\|^2 \mid x_t] \leq \sigma^2$
- Unbiased, finite variance, i.i.d. (standard)

**Algorithm**:
- SHB: $x_{t+1} = x_t - \eta_t g_t + \beta (x_t - x_{t-1})$
- Fixed β ∈ [0, 1)
- Step-size $\eta_t \in \mathbb{R}_{>0}$ deterministic (can be time-varying)
- $x_0 = x_{-1}$ (standard initialization)

**Quantifiers**:
- "There exists" on function + oracle (lower bound = worst-case over this class)
- "For all" on β, on step-size schedule, on T

---

## Step 4 — Three proof routes, weighed

### Route A — Explicit 1D or 2D construction (Goujaud-style, extended)

**Idea**: find a specific L-smooth convex non-SC function f and a simple stochastic oracle (e.g., Bernoulli noise on a few coordinates) such that the expected iterate dynamics of SHB for any fixed β yield $\mathbb{E}[f(x_T) - f^\star] \geq c/T$.

**Pros**:
- Constructive; most direct.
- Lessard's ratio-25 example is a natural starting point — take limit μ → 0.
- 1D or 2D case likely suffices for lower bound.

**Cons**:
- Non-SC cycling arguments are weaker than Goujaud's SC cycling. In 1D convex non-SC (e.g., $f(x) = x_+^2$), HB either converges or diverges — no finite cycle.
- May need to truncate HB's divergence with a stochastic "resetting" mechanism in the oracle — but this complicates variance control.

**Library fit**: ★★★ — Ghadimi-Lan deterministic lower bounds, Nesterov worst-case constructions, Lessard IQC-SDP tools.

**Feasibility**: 60%.

### Route B — IQC / performance-estimation framework (Lessard + Taylor-Hendrickx-Glineur)

**Idea**: encode SHB dynamics as an SDP under the non-SC smooth IQC (using [Taylor et al. 2017](https://arxiv.org/abs/1702.08235) PEP framework); prove the SDP value is ≥ c/T.

**Pros**:
- Rigorous, no construction guessing.
- Library has IQC tools.
- Taylor's PEPit can generate numerical evidence → tight bound guess.

**Cons**:
- PEP framework for stochastic methods is more recent (Colin-Sucker-Taylor 2024?) and less mature.
- Analytical extraction from SDP value often requires ansatz + verification — not fully automatic.

**Library fit**: ★★ — have IQC & Lyapunov tools, not stochastic PEP.

**Feasibility**: 45%.

### Route C — Arjevani-Shamir-Srebro-style oracle complexity lower bound

**Idea**: use the standard resisting-oracle technique. Build an oracle that forces any fixed-momentum method to behave like vanilla SGD on a sequence of hard directions; invoke the matching $\Omega(L D^2/T)$ lower bound for SGD on smooth convex non-SC (attributed to Nemirovski).

**Pros**:
- Most principled.
- Directly produces a matching-lower-bound statement.
- Connects OP-2 to the broader oracle-complexity literature.

**Cons**:
- Arjevani's 2019 lower bound [1912.02365](https://arxiv.org/abs/1912.02365) is for **non-convex** stochastic. The **convex** non-SC smooth lower bound is Nemirovski-Yudin 1983 — need to verify it's sharp at L/T (it's actually $\Omega(L D^2/\sqrt T)$ in some formulations when you include the stochastic term).
- Restricting to the "fixed momentum" algorithm class is a small twist on standard lower-bound machinery.

**Library fit**: ★★★ — have Arjevani 2019, Nemirovski-Yudin framework, oracle-complexity lower bound toolbox.

**Feasibility**: 70%.

### Recommendation: **Route C primary, Route A as backup**

Start with Route C: it gives the cleanest proof if successful, and it reuses library tools we've verified.

If Route C fails (e.g., the "fixed momentum" restriction does not reduce to standard lower bounds), fall back to Route A: construct a 2D convex non-SC example extending Lessard's κ=25 counter-example to μ=0 limit, with explicit Bernoulli stochastic oracle.

---

## Step 5 — problem.md draft

```
# Stochastic Heavy Ball does not accelerate on smooth convex functions

## Source
- Implicit open problem from: Lessard-Recht-Packard 2016; Kidambi et al. 2018.
- Strongly-convex analog closed by: Goujaud-Taylor-Dieuleveut 2025 (Math. Prog.).
- Context: SHB with fixed momentum β ∈ [0,1) is widely used in DL training;
  practitioners observe no advantage over SGD in convex but non-strongly-convex
  problems, but no lower bound exists.

## Statement

Let L, σ, D > 0 be fixed constants. There exists an L-smooth convex (not
strongly convex) function f : ℝ² → ℝ with ||x₀ - x⋆|| ≤ D, and an unbiased
stochastic gradient oracle with variance at most σ², such that for every
fixed momentum β ∈ [0,1), every deterministic step-size schedule (η_t)_{t≥1},
and every T ≥ 1, the stochastic heavy-ball iterate x_T satisfies

  E[f(x_T) - f⋆]  ≥  c · ( L·D² / T   +   σ·D / √T )

for some universal constant c > 0.

Equivalently, the bias-term (σ=0 limit) convergence of SHB is Ω(L·D²/T),
matching the GD rate — i.e. SHB provides no acceleration in the non-strongly-
convex stochastic smooth setting.

## Difficulty

Advanced / research. A-class under the RESEARCH_INDEX classification.

## Related results used

- Nemirovski-Yudin 1983 lower bound Ω(L·D²/T + σ·D/√T) for any
  first-order stochastic method on smooth convex non-SC functions.
- Ghadimi-Feyzmahdavian-Johansson 2015 matching **upper** bound O(L/T) for
  deterministic HB on smooth convex non-SC (ergodic average).
- Goujaud-Taylor-Dieuleveut 2025: deterministic HB non-acceleration on
  smooth μ-strongly-convex (used as template for cycling / anti-Lyapunov
  construction but NOT directly applicable since μ=0).
- Lessard-Recht-Packard 2016: κ=25 divergence example; we extend it to μ→0.

## Target routes (in priority order)

- Route C: resisting-oracle lower bound restricted to the fixed-momentum
  algorithm class; leverage Nemirovski-Yudin + Arjevani-Shamir-Srebro
  restriction machinery.
- Route A: constructive 2D example, extending Lessard's ratio-25
  counter-example to μ=0 limit, with Bernoulli stochastic oracle.

## Non-goals

- NOT claiming SHB cannot converge (it can, at rate O(1/√T) in expectation).
- NOT claiming anything about adaptive β_t — the statement fails in that
  case (Nesterov's method = time-varying-β HB in disguise).
- NOT claiming impossibility beyond the "bias-term" component — the
  stochastic O(σ/√T) component is optimal and unavoidable.
```

---

## Step 6 — Final decision

### ✅ LAUNCH with amended statement

- Tentative statement had a technical bug (1/T vs σ/√T) — fixed.
- Sharpened statement is a clean **matching lower bound for the smooth convex stochastic non-SC class, restricted to fixed-momentum HB**.
- Route C (resisting-oracle) is the primary path, Route A (explicit 2D) as backup.
- Library fit: Nemirovski-Yudin framework, Arjevani tools, IQC all present.
- Competition: very low — no active preprint on this exact statement in the last 6 months.
- Estimated sessions: **4–6 sessions** to full audit-passed proof.

### Next immediate action

1. Copy `problem.md` draft above to a new working directory `workspace/active/proof_work_20260417_op2/problem.md`.
2. Trigger Scout phase (math-proof-agent) on Route C.
3. Keep Route A in the back pocket for parallel deployment if Scout hits an obstruction on Route C by mid-Phase 2.

---

## Sources

- [Lessard-Recht-Packard 2016 (arXiv:1408.3595)](https://arxiv.org/abs/1408.3595)
- [Ghadimi-Feyzmahdavian-Johansson 2015 (arXiv:1412.7457)](https://arxiv.org/abs/1412.7457)
- [Kidambi-Netrapalli-Jain-Kakade 2018 (arXiv:1803.05591)](https://arxiv.org/abs/1803.05591)
- [Sebbouh-Gower-Defazio 2020/21 (arXiv:2006.07867)](https://arxiv.org/abs/2006.07867)
- [Schaipp et al. 2024, MomSPS (arXiv:2406.04142)](https://arxiv.org/abs/2406.04142)
- [Goujaud-Taylor-Dieuleveut 2023→Math.Prog. 2025 (arXiv:2307.11291)](https://arxiv.org/abs/2307.11291)
- [Goujaud 2025 COLT "Two Riddles" (arXiv:2502.19916)](https://arxiv.org/abs/2502.19916)
- [Arjevani-Carmon-Duchi-Foster-Srebro-Woodworth 2019 (arXiv:1912.02365)](https://arxiv.org/abs/1912.02365)
- [Lan 2012 AC-SA Math. Prog.](https://optimization-online.org/2010/07/2669/)
- [Taylor-Hendrickx-Glineur 2017 PEP (arXiv:1702.08235)](https://arxiv.org/abs/1702.08235)
- [Noise-adaptive SHB 2024 (arXiv:2401.06738)](https://arxiv.org/abs/2401.06738)
- [AOR-HB 2024 (arXiv:2406.09772)](https://arxiv.org/abs/2406.09772)
