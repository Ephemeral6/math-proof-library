# Route 2 (Naive) — Per-Coordinate AdaGrad Regret + Online-to-Batch Bridge

**Frame**: Naive
**Assigned route**: Route 2 from `routes.md`
**Output language**: English

---

## Pre-proof Hooks

### Step A — Strategy Signature Lookup (Layer 1)

Searched `workspace/strategy_index.md` for signatures matching `algorithm_type=AdaGrad`, `target_quantity=stationarity`, `setting=stochastic-nonconvex`, `iterate_type=coordinate-wise`. Three close matches:

- `adagrad-norm-nonconvex-convergence` — scalar AdaGrad, sub-Gaussian noise, won via predictable-scalar surrogate + log accumulator. Notably its meta-template is "descent + telescoping", NOT regret-to-batch.
- `adagrad-complexity-improvement-partial-refutation` — coordinate-wise AdaGrad, won via predictable-surrogate + CS-over-coordinates; its `failed_attempts/` contains a Route 4 ("regret-to-convergence") whose signature matches mine.
- `amsgrad-nonconvex-convergence` — also went through descent lemma, not regret bridge.

**Verdict**: the closest cousins all *deliberately abandoned* the regret-to-batch reduction. This is a strong negative signal for the assigned route.

### Step B — Meta-Template Slot-Filling (Layer 5)

Walked through MT1–MT8 in `meta_templates.md`:

- **MT1 (Cancellation Pair)**: would apply if I were doing the orthodox route — `V_t = f(x_t)`, descent identity gives the pair. Not naturally a fit for "regret-only" Naive frame.
- **MT2 (Exp supermartingale)**: not relevant — we want expected, not high-probability.
- **MT3 (Couple-and-track)**: no neighboring-input structure.
- **MT4–MT8**: do not match.

The Naive frame's recipe is structurally outside the 8 templates: the regret-to-batch reduction is its own short-circuit, valid only under convexity (or PL), and the explicit anti-pattern flagged inside MT1's anti-pattern note ("If you find yourself reaching for Young's inequality on an inner product `<a, b>`, STOP — Young's discards the cancellation") foreshadows what will go wrong here when the comparator is time-varying.

**Template selected**: none directly; attempted Naive walkthrough.

### Step C — Structure Map (Layer 4)

Searched `structure_map.md` for ANALOGY links between online learning and stochastic optimization. The relevant entry is the "online-to-batch isomorphism" — and its caveat states the isomorphism is valid for convex / strongly convex / PL objectives only. Nonconvex breaks the isomorphism at the very first step (regret bound on `<g_t, x_t - u>` is not a function-value bound).

**Verdict**: structure map confirms this is exactly the broken bridge.

---

## Proof attempt

**Route**: Naive — per-coordinate AdaGrad online regret + online-to-batch reduction.

### Step 1: Setup of per-coordinate online problem

For each coordinate $i \in [d]$ and each round $t = 0, 1, \dots, T-1$, let

$$
\ell_{t, i}(y) := g_{t, i} \cdot y, \qquad y \in \mathbb{R},
$$

be a linear loss in the 1-D online learning problem. The naive frame's idea: treat each coordinate independently as a 1-D OGD problem with adaptive step size $\eta_{t, i} = \eta / \sqrt{v_{t+1, i}}$.

The coordinate-wise AdaGrad update from `problem.md`,

$$
x_{t+1, i} = x_{t, i} - \eta \cdot g_{t, i} / \sqrt{v_{t+1, i}},
$$

is precisely an instance of online gradient descent with adaptive step size on the linear losses $\ell_{t, i}$.

**Justification**: this is the textbook AdaGrad-OGD setup — see e.g. Duchi–Hazan–Singer 2011 §3 and Hazan's *Online Convex Optimization* monograph Ch. 5.

### Step 2: Per-coordinate AdaGrad regret bound (standard)

Standard 1-D AdaGrad regret: for any FIXED comparator $u_i \in \mathbb{R}$ and any sequence of linear losses $\ell_{t, i}(y) = g_{t, i} y$,

$$
\sum_{t=0}^{T-1} \ell_{t, i}(x_{t, i}) - \sum_{t=0}^{T-1} \ell_{t, i}(u_i)
\;=\; \sum_{t=0}^{T-1} g_{t, i} (x_{t, i} - u_i)
\;\le\; \frac{D_i^2}{2 \eta} \sqrt{v_{T, i}} + \eta \sqrt{v_{T, i}},
\tag{R}
$$

where $D_i := \max_t |x_{t, i} - u_i|$. Combined into the cleaner form

$$
\sum_{t=0}^{T-1} g_{t, i} (x_{t, i} - u_i) \;\le\; C(D_i, \eta) \cdot \sqrt{v_{T, i}}.
\tag{R'}
$$

[REF: standard AdaGrad regret, Duchi–Hazan–Singer 2011 Thm 5; structurally identical to the per-coordinate self-bounding sum used in `proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/proof.md`]

This part is correct — modulo the standing requirement that **$u_i$ is a single FIXED comparator**, the same for all $t$.

### Step 3: Attempted online-to-batch bridge — THIS IS WHERE THE ROUTE BREAKS

The Naive frame must now convert (R') into a bound on $\min_t \mathbb{E}\|\nabla f(x_t)\|_1$. The textbook online-to-batch reduction works as follows:

**Standard online-to-batch (convex case)**: choose comparator $u = x^\star := \arg\min f$. Convexity gives, for each $t$,

$$
f(x_t) - f(x^\star) \;\le\; \langle \nabla f(x_t),\, x_t - x^\star \rangle.
\tag{C}
$$

Taking expectations and using $\mathbb{E}[g_t \mid x_t] = \nabla f(x_t)$,

$$
\mathbb{E}[f(x_t) - f^\star] \;\le\; \mathbb{E}\langle g_t, x_t - x^\star \rangle.
$$

Summing over $t$, by (R) the RHS is $\le C \sum_i \sqrt{v_{T, i}}$, so dividing by $T$ gives a function-value gap, which can be converted to a stationarity bound via further structure (in convex/PL).

**Failure point**: in the present problem, $f$ is only **nonconvex** (with $(L_0, L_1)$-smoothness — no convexity assumption anywhere). Inequality (C) is FALSE in general. Concrete counterexample: take $d = 1$, $f(x) = -L_0 x^2 / 2$, which is $L_0$-smooth (in fact $(L_0, 0)$-smooth) but concave; then for any $x \neq 0$ and $u = x^\star = 0$,

$$
f(x) - f(0) = -L_0 x^2 / 2, \qquad \nabla f(x) (x - 0) = -L_0 x \cdot x = -L_0 x^2,
$$

so $f(x) - f(u) = -L_0 x^2 / 2 > -L_0 x^2 = \langle \nabla f(x), x - u \rangle$. (C) is reversed.

**Cite**: this is exactly **FT-OOB-NONCONVEX**, the failure trigger documented at `workspace/failure_patterns.md` line 265–270:

> *AdaGrad-Norm O(log T/√T) — Route 4: Online-to-Batch via AdaGrad Regret*
> *Stuck at: Step 3, bridging from regret to nonconvex $f$ convergence.*
> *Reason: in the nonconvex setting, $f(x_k) - f(u) \le \langle \nabla f(x_k), x_k - u \rangle$ does NOT hold (counterexample $f = -Lx^2/2$); the descent-step comparator $u_k = x_k - (\eta/b_k) \nabla f(x_k)$ varies with $k$, breaking the single-comparator telescoping of the regret lemma.*
> *Lesson: Online-to-batch reduction is fundamentally tied to convexity (or at least PL); in the nonconvex setting one should go directly through the descent lemma — the regret framework can only be archived as a side product (an AdaGrad-Norm regret bound).*

The same pattern blocked Route D of `q-learning-ucb-hoeffding-regret` — see `workspace/failure_patterns.md` lines 312–317.

### Step 4: Attempted patch via time-varying comparator — also fails

The natural patch is to replace the fixed $u = x^\star$ with the per-step descent comparator

$$
u_t := x_t - (\eta / \sqrt{v_{t+1}}) \nabla f(x_t),
$$

so that $\langle \nabla f(x_t), x_t - u_t \rangle$ becomes proportional to $\|\nabla f(x_t)\|_*^2$ (where $\|\cdot\|_*$ is the AdaGrad-weighted norm), which is the gradient norm we want to bound.

**Failure point**: AdaGrad's regret bound (R) holds **only for a single fixed comparator $u$, identical across all rounds $t$**. A time-varying comparator $u_t$ violates the telescoping argument that derives (R): explicitly, the standard derivation depends on

$$
\|x_{t+1} - u\|^2 \;=\; \|x_t - u\|^2 - 2 \eta_{t, i} g_{t, i} (x_{t, i} - u_i) + \eta_{t, i}^2 g_{t, i}^2,
$$

and summing telescopes only because $u$ does not change. Allowing $u_t$ adds a "comparator-drift" residual

$$
\sum_{t} \|u_{t+1} - u_t\| \cdot \|x_{t+1} - u_t\|,
$$

which in the present setting equals $O(\sum_t \|\nabla f(x_t)\|_* \cdot \|x_t - u_t\|) = O(\sum_t \|\nabla f(x_t)\|_*^2 \cdot \eta / \sqrt{v_{t+1}})$ — i.e., **the very quantity we are trying to bound appears on the RHS with no smaller coefficient than on the LHS**. The bound is circular.

The dynamic-regret literature (Zinkevich 2003, Jadbabaie et al. 2015) provides extensions of AdaGrad to time-varying comparators with a **path-length** correction term $P_T = \sum_t \|u_{t+1} - u_t\|$. Substituting our $u_t$ gives $P_T = O(\sum_t \eta \|\nabla f(x_t)\| / \sqrt{v_{t+1}})$, and the dynamic regret bound has the form

$$
\sum_t \langle g_t, x_t - u_t \rangle \;\le\; \text{const} \cdot \sqrt{v_{T}} \cdot (1 + P_T),
$$

so the would-be "stationarity sum" $\sum_t \|\nabla f(x_t)\|_*^2 \cdot \eta / \sqrt{v_{t+1}}$ on the LHS is dominated by a term $\sqrt{v_T} \cdot P_T$ which on the RHS is OF THE SAME ORDER as the LHS (with a non-summable coefficient). No useful bound results.

### Step 5: Attempted patch via descent lemma — collapses into Route 1

If, instead of regret, we add a descent inequality at each step, then the overall analysis becomes:

$$
f(x_{t+1}) \le f(x_t) + \langle \nabla f(x_t), x_{t+1} - x_t \rangle + \tfrac{1}{2} \sum_i (L_0 + L_1 |\partial_i f(x_t)|) \cdot (x_{t+1, i} - x_{t, i})^2.
$$

But this is **exactly the coordinate-wise generalized descent lemma of Route 1**. The "regret bound" then becomes a redundant accounting: every term of the regret-style identity (R) can be recovered from the descent lemma's inner product expansion, while the descent lemma additionally captures the second-order correction that the regret bound misses.

In other words: any patch that resurrects the Naive frame requires importing exactly the analytical machinery of Route 1, at which point the regret-bound layer is rendered irrelevant. This is the same collapse Scout flagged at the bottom of the Route 2 description in `routes.md`:

> "the failure pattern is very well-established. The Explorer for this route should be aware it will likely collapse into Route 1 or terminate with a documented reconfirmation of the FP."

### Step 6: Verifier check (CALL)

[CALL:math-verifier] {Verify by direct computation: for $f(x) = -L_0 x^2 / 2$ with $L_0 > 0$, $x = 1$, $u = 0$: the quantities $f(x) - f(u) = -L_0/2$ and $\nabla f(x)(x - u) = -L_0$. Conclude $f(x) - f(u) > \nabla f(x)(x - u)$, refuting the convexity inequality (C).}

Symbolic verification confirms that for $L_0 > 0$, $-L_0/2 > -L_0$ (since $L_0/2 < L_0$). The convex inequality (C) used by online-to-batch reduction fails on this $(L_0, 0)$-smooth, non-convex example. (No Z3/NumPy needed — elementary algebra.)

### Conclusion of Naive route

Per-coordinate AdaGrad regret bound (R) is correctly derivable. The bridge from (R) to a stationarity bound on the nonconvex $\ell_1$-gradient norm requires either (a) convexity (false here), (b) a time-varying comparator (breaks the telescoping that derived R), or (c) reintroduction of the full coordinate-wise generalized descent lemma (collapsing into Route 1). All three sub-bridges fail.

---

## Route Failure Report

**Route**: Naive (Route 2 of `routes.md`) — per-coordinate AdaGrad online regret + online-to-batch reduction.

**Failed at**: Step 3 (the bridge from regret bound to nonconvex stationarity).

**Failure trigger matched**: yes — exactly the FP documented in `workspace/failure_patterns.md` lines 265–270 (AdaGrad-Norm Route 4 "Online-to-Batch via AdaGrad Regret"), and analogously line 312–317 (UCB-Hoeffding Q-learning Route D). Both prior occurrences failed at the same "$f(x) - f(u) \le \langle \nabla f(x), x - u \rangle$" step in the absence of convexity / PL.

**Obstacle (precise)**: the online-to-batch reduction requires
$$
f(x_t) - f(u) \;\le\; \langle \nabla f(x_t), x_t - u \rangle \quad \text{for some fixed } u, \forall t.
$$
This is equivalent to convexity (with $u = x^\star$). The problem's $(L_0, L_1)$-smoothness condition does NOT imply convexity (counterexample: $f(x) = -L_0 x^2 / 2$ is $(L_0, 0)$-smooth but concave). Therefore the bridge inequality fails.

**Why the failure is not patchable inside this frame**:
1. **Time-varying comparator** $u_t = x_t - \eta \nabla f(x_t)/\sqrt{v_{t+1}}$ breaks the single-comparator telescoping identity that derives the AdaGrad regret bound (R); the dynamic-regret correction term has the same order as the would-be stationarity sum.
2. **Restricting attention to a region where $f$ is locally convex** is not allowed because the problem statement asks for a global rate over all initializations and all $(L_0, L_1)$-smooth $f$.
3. **Combining regret bound with a descent lemma** to recover convexity-like inequalities is not "Naive" anymore — it imports the full machinery of Route 1, with the regret layer being algebraically redundant once the descent lemma is in hand.
4. **Switching to PL or Polyak–Łojasiewicz** is also disallowed: the problem's $(L_0, L_1)$-smoothness + affine-noise setup makes no PL assumption.

**What a "fix" would require**: structurally moving outside the Naive frame. Specifically, one would need either (i) the coordinate-wise generalized descent lemma (Route 1's tool) to bridge $\langle g_t, x_t - u_t \rangle$ to $\|\nabla f(x_t)\|_1$, OR (ii) an entirely different non-regret framework such as the STORM-style three-term Lyapunov balance (Route 4 / Route 6).

**Concrete recommendation for the Judge**: do NOT attempt to salvage Route 2. Its failure is structural, well-documented (three independent occurrences of the same FP in this library), and the Naive frame cannot be made to work without becoming a different frame. Pass the proof effort to Route 1 (Orthodox) and Route 4 (Construction).

**Side product worth saving**: Step 2's per-coordinate AdaGrad regret bound (R) is a clean, convex-setting result that could be archived as a B-class library lemma; the Library does already contain a closely related per-coordinate self-bounding sum [REF: `proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/proof.md`]. No new fragment needed.

---

## Hooks Report

- Strategy signatures consulted: [`adagrad-norm-nonconvex-convergence`, `adagrad-complexity-improvement-partial-refutation`, `amsgrad-nonconvex-convergence`]; useful=YES; all three closest cousins explicitly avoided the regret-to-batch bridge, providing strong negative signal corroborating the failure prediction.
- Meta-template attempted: none of MT1–MT8 fits the Naive frame's regret-to-batch recipe; this is structurally outside the 8-template coverage. Free-form attempted; outcome: failure as predicted.
- Structure map links used: ["online-to-batch isomorphism" — confirmed nonconvex breaks the isomorphism at the first step]
- Failure triggers checked: 4 (FT-18-AUDITOR-MISSES-UB-LB-CONTRADICTION skipped — irrelevant; FT-OOB-NONCONVEX from `failure_patterns.md` lines 265–270 — MATCHED at Step 3; FT-COMPARATOR-DRIFT-DYNAMIC-REGRET, internal — MATCHED at Step 4; FT-LEGACY-CD-EUCLIDEAN-NORM — irrelevant); matched: [FT-OOB-NONCONVEX, FT-COMPARATOR-DRIFT-DYNAMIC-REGRET]; pivots taken: none — per assignment instruction "Do NOT switch frames", the route was honestly walked to its documented failure point and the reasons recorded.
