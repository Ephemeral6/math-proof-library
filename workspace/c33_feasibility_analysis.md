# C3.3 — Feasibility Analysis (Potential-game LOO stability ⇒ generalization)

**Conjecture**: In a potential game where each player's payoff is learned from a dataset, perturbing one sample in one player's dataset induces equilibrium perturbation quantifiable à la Bousquet–Elisseeff, yielding a generalization bound on the learned equilibrium strategy.

**Stakes**: last surviving candidate of the 12 from round-1 analogy generation. C3.4 died by literature subsumption (Kozachkov 2022); C1.4 died by information-theoretic lower bound (Kipnis–Varadhan). This analysis must be especially strict.

---

## Stage 0 — Modeling (most critical)

### M1. What is "training set" and "test set"?

Standard ML: $S = (z_1, \dots, z_n) \sim \mathcal{D}^n$, algorithm $A: S \mapsto w$, gen gap $= \mathbb{E}_S[R(A(S)) - R_S(A(S))]$.

**Three candidate formalizations for potential games**:

**(F1) Shared dataset, per-player loss**. One dataset $S = (z_1,\dots,z_n) \sim \mathcal{D}^n$. Each player $i$ has empirical payoff $u_i^S(\sigma) = \frac{1}{n}\sum_k \ell_i(\sigma, z_k)$ and population payoff $u_i^{\mathcal{D}}(\sigma) = \mathbb{E}_z[\ell_i(\sigma, z)]$. Algorithm $A$ runs best-response or no-regret dynamics on $\{u_i^S\}$ to equilibrium $\sigma^*(S)$. Gen gap for player $i$:
$$\Delta_i(S) := u_i^{\mathcal{D}}(\sigma^*(S)) - u_i^S(\sigma^*(S)).$$
**LOO perturbation**: replace $z_k$ by $z_k'$, affecting all players symmetrically.

**(F2) Per-player dataset**. Each player $i$ has private $S_i \sim \mathcal{D}_i^m$. Empirical payoff $u_i^{S_i}(\sigma) = \frac{1}{m}\sum_k \ell_i(\sigma, z_{i,k})$. Equilibrium $\sigma^*(S_1,\dots,S_n)$. LOO on player $i$: replace one sample in $S_i$.

**(F3) Shared dataset, player-perturbation**. One dataset $S$. "LOO" = replace one player's payoff function entirely (not one sample). This is closer to the user's original "perturb one player's payoff" phrasing but departs from the Bousquet–Elisseeff template.

**Fatal problem with (F1)**: if every $u_i^S$ is derived from the *same* global sum $L^S(\sigma) = \frac{1}{n}\sum_k \ell(\sigma, z_k)$ via $u_i^S = \partial L^S/\partial \sigma_i$, then the empirical game is a potential game with **potential = empirical risk**. Equilibrium = critical point of $L^S$. **The entire multi-agent structure collapses to single-agent ERM on $L^S$**, and Bousquet–Elisseeff for ERM already applies verbatim. No new theorem.

**Fatal problem with (F3)**: replacing a whole player's payoff is not a "one sample" perturbation; it's a $\Theta(1)$ change. Bousquet–Elisseeff-style $O(1/n)$ rates cannot hold.

**(F2) is the only non-trivial formulation**: heterogeneous per-player datasets, payoffs $u_i$ not derivable from a shared loss. For a potential to exist, payoffs must satisfy the integrability condition $\partial u_i/\partial \sigma_j = \partial u_j/\partial \sigma_i$. This is **not automatic** for arbitrary $\{u_i^{S_i}\}$ — it constrains the form of the $\ell_i$.

**Minimal non-trivial setup (F2 refined)**: weighted potential game with shared "interaction" term and private "self" terms:
$$u_i^{S_i}(\sigma) = \Phi_0(\sigma) + c_i^{S_i}(\sigma_i),\quad c_i^{S_i}(\sigma_i) = \tfrac{1}{m}\sum_k \ell_i(\sigma_i, z_{i,k})$$
where $\Phi_0$ is a known (deterministic) interaction potential and $c_i$ is learned from player $i$'s private data. Then empirical potential $\Phi^S = \Phi_0 + \sum_i c_i^{S_i}$. **LOO on $S_i$**: changes only $c_i$, hence only $\Phi$'s $i$-th additive component.

This is **structurally** the federated-learning-in-games setup: shared interaction, private data.

**Verdict on M1**: A self-consistent formulation exists (F2-refined), but it's narrow. Two of three natural formalizations collapse to triviality.

---

### M2. What is "LOO stability"?

Classic HRS: $S, S'$ differ in one sample; $\beta = \sup_z |\ell(A(S),z) - \ell(A(S'),z)|$.

**In F2-refined**:
- $S_i, S_i'$ differ in one sample; $S_{-i}$ unchanged.
- Equilibria $\sigma^* = \sigma^*(S_1,\dots,S_n)$, $\sigma^{*\prime} = \sigma^*(S_1,\dots,S_i',\dots,S_n)$.
- Two candidate stability definitions:
  - **Strategy stability**: $\beta_{\text{strat}} = \|\sigma^* - \sigma^{*\prime}\|$.
  - **Payoff stability**: $\beta_{\text{pay}} = \sup_{z,j} |u_j(\sigma^*, z) - u_j(\sigma^{*\prime}, z)|$.

**Equilibrium-selection issue**: if Nash equilibrium is non-unique, $\sigma^*(S)$ is a *set*, not a point. "$\|\sigma^* - \sigma^{*\prime}\|$" is ambiguous (Hausdorff distance? matching? selection rule?). In degenerate potential games (e.g., $\Phi$ with flat regions or multiple minima), this is not a minor issue — it's a modeling hole.

**Resolution**: restrict to **strongly convex $\Phi$** or **strictly monotone games**, where equilibrium is unique. This is the technically tractable regime. Moderately restrictive but standard in the games-with-learning literature.

**LOO-to-generalization step**: Bousquet–Elisseeff gives gen-gap $\le \beta + O(L\sqrt{\log(1/\delta)/n})$ for bounded loss; ported to games, this would give **player $i$'s** gen gap $\le \beta_{\text{strat}}\cdot L_i + \text{(tail term)}$. Structurally plausible; ports if IFT on Nash equations gives $\sigma^*(S_i)$ Lipschitz in empirical distributions.

**Verdict on M2**: Workable in the strongly-monotone / strongly-convex-potential regime. Breaks in the non-unique-equilibrium case.

---

### M3. Role of the potential function

A potential game has $\Phi$ with $\partial \Phi/\partial \sigma_i = u_i$. Candidates for $\Phi$'s role:

1. **$\Phi$ as global loss**: if $\Phi^S$ is treated as the ERM objective and the algorithm finds $\arg\min \Phi^S$, the analysis **is** single-agent ERM. Multi-agent structure is a formality. Bousquet–Elisseeff + smoothness gives $O(L^2/n)$ stability; no novelty.

2. **$\Phi$ absent from analysis**: if the algorithm is per-player best-response or online no-regret, each player optimizes $u_i$ using only local info. The potential is a proof device (guaranteeing BR dynamics converges), but the stability analysis operates on $u_i$ directly. **This is where the potential game gives non-trivial structure**: BR converges because $\Phi$ decreases, but the per-player updates are not gradient descent on $\Phi$ globally.

3. **$\Phi$ as Lyapunov**: in the coupling argument, track $\Phi(\sigma_t) - \Phi(\sigma_t^\prime)$ as potential gap. If BR is contractive (strongly monotone game), this decays.

**(2) is the non-trivial regime**. It's exactly **decentralized no-regret learning in potential games** (Mertikopoulos, Sandholm, Bravo, Leslie school). The potential plays a structural but indirect role: it certifies convergence of distributed dynamics without forcing the algorithm to compute $\Phi$ globally.

**Verdict on M3**: Non-trivial case exists (regime 2). But this regime is where the existing multi-agent learning literature is densest — risk of ADJACENT/REDISCOVERED classification.

---

### M4. Minimum working example

**Cournot oligopoly with learned costs**.

Setup:
- $n$ firms, strategy $q_i \in [0, Q_{\max}]$ (quantity produced).
- Inverse demand $p(\sum q_j) = a - b\sum q_j$ (known).
- Firm $i$ has private marginal cost $c_i$, estimated from data $S_i = \{c_{i,1},\dots,c_{i,m}\}$ i.i.d. from distribution with mean $c_i^*$.
- Empirical profit: $u_i^{S_i}(q) = q_i(a - b\sum q_j) - \hat{c}_i^{S_i} q_i$, where $\hat{c}_i^{S_i} = \frac{1}{m}\sum_k c_{i,k}$.
- Potential: $\Phi^S(q) = \sum_i (a - \hat c_i^{S_i}) q_i - \frac{b}{2}(\sum q_j)^2 - \frac{b}{2}\sum q_i^2$ (Monderer–Shapley construction).
- Strongly concave in $q$, unique Nash $q^*(S_1,\dots,S_n)$.

Closed form: $q_i^*(S) = \frac{1}{b(n+1)}\Big((a - \hat c_i^{S_i}) \cdot n - \sum_{j\ne i}(\hat c_j^{S_j} - \hat c_i^{S_i})\Big)$ (up to algebra).

LOO on $S_i$: $\hat c_i^{S_i} \mapsto \hat c_i^{S_i\prime}$, difference $O(1/m)$. Then $q_i^* - q_i^{*\prime} = O(1/(b \cdot m))$ — strategy stability $\beta_{\text{strat}} = O(1/m)$. Gen gap for firm $i$: $O(1/m)$.

**This works concretely**. But the analysis is **linear-algebra closed-form** — no deep coupling or Lyapunov argument needed. The Bousquet–Elisseeff framing is a sledgehammer for a problem that yields to direct calculation.

**Is there a harder example?** Logit quantal-response equilibrium, routing games with nonlinear costs, multi-action matrix games — harder but also more specialized.

**Verdict on M4**: Concrete examples exist, but the cleanest ones (Cournot) are solvable without the HRS/Bousquet–Elisseeff machinery. The novelty of C3.3's framework is undermined by the triviality of the flagship example.

---

## Stage 1 — Information-theoretic check

### Q1. Known lower bounds / impossibilities?

Relevant results:
- **Rubinstein 2017** (STOC): query complexity of approximate Nash is exponential in $n$ (number of players) for general games. **Does not apply** to potential games — they're PLS-complete, not PPAD-complete.
- **Fearnley–Gairing–Goldberg–Savani 2015**: sample complexity of Nash from query access. For potential games, polynomial in game size.
- **Potential games are tractable**: equilibrium is local minimum of $\Phi$; gradient methods converge. Sample complexity of $\Phi$-minimization is standard ERM, $O(1/\varepsilon^2)$ for bounded loss.

**Automatic-stability question**: "If each player's learned payoff is LOO-stable, is the equilibrium automatically stable?" 

Yes — via the **implicit function theorem on Nash equations** $\{u_i(\sigma^*) = 0\}_i$. If the Jacobian $J = (\partial u_i/\partial \sigma_j)$ is non-degenerate at $\sigma^*$ (equivalent to $\nabla^2 \Phi \succ 0$ in potential games, i.e., strong convexity), then $\sigma^*$ is a smooth function of the empirical data, and its stability is controlled by $\|J^{-1}\| \cdot \beta_u$ where $\beta_u$ is payoff stability.

**Consequence**: in the non-degenerate regime, C3.3 is a **one-line corollary of IFT + ERM stability**. The theorem is true but its content is standard real-analysis reduction. It's not a *deep* result — it's a bookkeeping exercise.

**Verdict on Q1**: No hard information-theoretic blocker (unlike C1.4's Kipnis–Varadhan). But there's a **mathematical triviality blocker**: in the tractable regime, the theorem follows from IFT + HRS with little residual content.

---

### Q2. Existing multi-agent generalization work

Literature scan:

**(a) Learning in potential games — convergence-focused**
- **Monderer & Shapley 1996** — foundational potential games paper.
- **Chen & Syrgkanis, "Greedy no-regret learning in potential games" (ICLR 2018 / NeurIPS adjacent)** — finite-sample analysis of no-regret dynamics in potential games, $\tilde O(1/\varepsilon^2)$ sample complexity. **Overlaps significantly with F2-refined setup.** Uses potential-decrease bound instead of LOO framework.
- **Heliou–Cohen–Mertikopoulos 2017** and Mertikopoulos–Sandholm 2016 — convergence of learning dynamics in potential games, continuous-time, $O(1/t)$ rate.
- **Bravo–Leslie–Mertikopoulos 2018 (NeurIPS)** — bandit learning in concave $N$-person games, sample complexity bounds.

**(b) Generalization in multi-agent learning**
- **Syrgkanis–Krishnamurthy–Schapire, "Efficient algorithms for adversarial contextual learning" (ICML 2016)** — related but contextual, not game-theoretic.
- **Balcan–Sandholm–Vitercik, "Sample complexity of multi-player mechanism design"** series (2018–2022) — generalization bounds for learning *mechanisms*, not equilibrium strategies.
- **Federated-learning stability line** (Yuan–Ma 2020, Hu et al. 2022) — uniform stability of FedAvg; adjacent but not game-theoretic equilibrium.

**(c) PAC learning of equilibria**
- **Kearns et al.** on correlated equilibrium from samples.
- **Fictitious play sample complexity** (Leslie–Collins 2006).

**Closest overlap**: Chen & Syrgkanis (ICLR 2018) — finite-sample analysis of no-regret dynamics converging to approximate Nash in potential games. Their bound is on *distance-to-equilibrium*, not *generalization gap of realized payoff*. So **framing** differs, but the technical content is close: they bound $\Phi(\bar\sigma_T) - \Phi(\sigma^*)$ via potential-decrease + empirical-process arguments. A LOO-style bound would give a different quantity but likely a similar rate.

**Verdict on Q2**: No paper proves C3.3 in exactly its Bousquet–Elisseeff framing. But **Chen–Syrgkanis and the Mertikopoulos corpus cover the same rate and much of the same terrain**. Risk of "ADJACENT — not subsumed but published work is close enough that the contribution reads as reframing rather than novel."

---

## Stage 2 — Technical feasibility

### Q3. Does HRS coupling port?

HRS recipe:
1. Couple runs on $S, S'$ via shared randomness.
2. Non-expansion per step: for convex $\beta$-smooth loss, SGD step with $\alpha \le 2/\beta$ is non-expansive.
3. Differing-sample step adds $2\alpha L/n$.
4. Telescope: $\delta_T \le 2L^2 \sum_t \alpha_t / n$.

**Porting to potential game + BR / gradient play**:

1. **Coupling**: synchronize player update order and randomization. Feasible.
2. **Non-expansion**: for strongly monotone game with monotonicity modulus $\mu$ and smoothness $\beta$, the gradient-play step $\sigma \mapsto \sigma - \alpha \nabla_{\sigma_i} u_i$ is **contractive in the pseudogradient map**, rate $1 - \alpha\mu$. Standard (Nesterov 2007; Facchinei–Pang). Ports.
3. **Differing-sample step**: when player $i$'s update uses the perturbed sample, contributes $O(\alpha_t L/m)$. Direct analog.
4. **Telescope**: combine contraction $(1-\alpha\mu)$ with additive perturbation $\alpha L/m$. Geometric sum gives $\delta_T \le L/(\mu m)$ in the $T\to\infty$ limit. Ports.

**Where it *could* break**:
- **BR with large-step discrete updates** (best-response to pure strategy): not contractive pointwise; analysis must use potential decrease, not step-wise non-expansion. Argument form changes.
- **Stochastic BR** (quantal response, logit): smooth approximation restores contraction. Standard.
- **Asynchronous updates** (players update at independent random times): effective update is convex combination of updates; analysis needs asynchronous SGD extensions (Mania et al.).

**Verdict on Q3**: Coupling argument ports cleanly in the strongly-monotone, synchronous-gradient-play regime. Deviations (async, discrete BR) complicate but don't break the approach.

---

### Q4. Tentative theorem statement

**Tentative theorem (C3.3 revised, YELLOW-candidate form)**:

> Let $\mathcal{G}$ be an $n$-player strongly monotone potential game with potential $\Phi$, $\mu$-strongly convex and $\beta$-smooth. Each player $i$ has private dataset $S_i = \{z_{i,k}\}_{k=1}^m \sim \mathcal{D}_i^m$, and empirical payoff $u_i^{S_i}(\sigma) = \Phi_0(\sigma) + \frac{1}{m}\sum_k \ell_i(\sigma_i, z_{i,k})$ with $\ell_i(\cdot, z)$ being $L$-Lipschitz in $\sigma_i$.
> 
> Let $\sigma^*(S_1,\dots,S_n)$ be the unique Nash equilibrium of the empirical game. Then for each player $i$:
> $$\mathbb{E}\big[u_i^{\mathcal{D}_i}(\sigma^*) - u_i^{S_i}(\sigma^*)\big] \le \frac{2L^2}{\mu \, m}.$$

Shape: $O(L^2/(\mu m))$ per-player gen gap, matching HRS for strongly convex losses with $m$ replaced by player $i$'s sample count. Proof would: (a) establish strategy-stability $\beta_{\text{strat}} = O(1/(\mu m))$ via IFT or coupling, (b) apply Bousquet–Elisseeff with $L$-Lipschitz payoff, (c) sum.

**Assessment of this statement**:
- Technically well-posed.
- Rate is expected (no rate novelty — would match single-agent ERM with $n$-independent constant). 
- Novelty lies in: (i) the multi-agent heterogeneous-data setup, (ii) the equilibrium-as-algorithm-output framing, (iii) per-player generalization rather than global.

---

## Stage 3 — Deep literature search

Additional targeted queries (to avoid third C3.4-style surprise):

**Query A — "potential game" + "generalization" + "stability"**
- No direct match on arXiv. Chen–Syrgkanis 2018 is closest.
- Syrgkanis's broader generalization-in-games work focuses on revenue/welfare of mechanisms, not payoff-of-equilibrium.

**Query B — "multi-agent" + "uniform stability" + "PAC"**
- **Sessa et al. (NeurIPS 2019) "No-regret learning in unknown games with correlated payoffs"** — bandit framework, different angle.
- **Anagnostides et al. 2022–2024 (NeurIPS series)** — "near-optimal no-regret in games" — sample complexity for equilibrium computation. Does not state a Bousquet–Elisseeff-style gen bound.

**Query C — "game" + "leave-one-out" + "learning"**
- No direct match. LOO is rarely used in games literature.

**Query D — "Nash equilibrium" + "sample complexity" + "best response"**
- Foster-Rakhlin-Sekhari and collaborators (COLT 2021+) on equilibrium sample complexity. Focus on computation, not generalization gap.
- **Sessa–Krause–Kamgarpour 2020**: no-regret with correlated rewards.

**Query E — "potential game" + "empirical" + "population"**
- Generic statistical analogies; no direct technical overlap.

**Query F — "implicit function theorem" + "Nash equilibrium" + "sample complexity"**
- **Classical** — Kyparisis 1985, Dontchev–Rockafellar on parametric VIs. Strategy stability from IFT is textbook. This is actually the **standard tool** used in sensitivity analysis of equilibrium problems.

**New finding from Query F**: the strategy-stability bound $\beta_{\text{strat}} = O(1/\mu m)$ follows directly from Dontchev–Rockafellar-style perturbation analysis of variational inequalities (see Dontchev–Rockafellar, *Implicit Functions and Solution Mappings*, 2009, Chapter 2). **This is a textbook reduction.**

**Synthesis**: 
- The raw technical content of C3.3-revised (strategy stability of Nash under data perturbation, in strongly monotone regime) is a textbook corollary of VI sensitivity analysis.
- The "packaging" (Bousquet–Elisseeff → gen bound on equilibrium payoff) is not explicitly in any paper I found, but is a natural combination of two textbook results.
- **Contribution value**: reframing, not discovery. Would read as "here's a natural framing of known facts" rather than "here's a new mathematical result."

---

## Identified issues and risks

| # | Issue | Severity |
|---|---|---|
| I1 | **Collapse risk**: natural formulations (F1, F3) trivially reduce to ERM or have wrong rate | Structural |
| I2 | **IFT triviality**: in tractable (strongly monotone) regime, strategy stability is a direct corollary of VI sensitivity (Dontchev–Rockafellar) | Mathematical |
| I3 | **Equilibrium non-uniqueness**: in the hard regime (multiple equilibria), $\sigma^*(S)$ is ill-defined; HRS framework doesn't apply | Modeling |
| I4 | **Audience overlap**: Chen–Syrgkanis 2018 and Mertikopoulos corpus cover adjacent ground; contribution reads as reframing | Publication-value |
| I5 | **Rate non-novelty**: expected $O(L^2/(\mu m))$ matches single-agent ERM rate; no acceleration or improvement | Impact |

---

## Verdict

### 🟡 **YELLOW** — technically executable, but contribution value uncertain

**Not RED**: modeling admits a self-consistent formulation (F2-refined), no information-theoretic blocker, HRS coupling ports in the strongly-monotone regime. A statement of the form in Q4 is provable.

**Not GREEN**: the provable statement is a direct combination of (a) VI sensitivity (textbook, Dontchev–Rockafellar) and (b) Bousquet–Elisseeff applied to a Lipschitz map. The proof is a bookkeeping exercise, not a new technique. Literature overlap (Chen–Syrgkanis, Mertikopoulos school) covers adjacent terrain.

**Revised statement (reasonable YELLOW target)** — see Q4.

---

## Recommendation

**Do not pursue C3.3 as a research-level result.** Two reasons:

1. **Trivializability**: even the F2-refined formulation reduces, in the tractable regime, to a textbook corollary of VI sensitivity + HRS. We'd be writing a framework paper in a space (learning in potential games) that already has strong framework papers.
2. **Third-strike pattern**: C3.4 subsumed, C1.4 lower-bounded, C3.3 trivializable. The analogy-generation route has produced zero clean hits from three candidates. This is evidence that the analogy route, at least as executed, has insufficient prior against established literature.

### **Pivot recommendation: switch to "hypothesis-generalization" route**

Instead of generating conjectures by cross-domain analogy, pick an existing proof from our library and ask: *which hypothesis is known to be tight, and which is a convenience assumption that could be relaxed?* This is a more surgical search strategy with a better hit rate.

### Top 3 proofs in our library most suitable for hypothesis-generalization

Selected from `RESEARCH_INDEX.md` by the criteria: (a) proof's bottleneck hypothesis is a known convenience, (b) relaxation direction is identifiable, (c) literature has not exhausted the relaxation.

**R1. HRS SGD uniform stability → Markovian-sample SGD stability**
- **Base proof**: `proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/` (HRS 2016).
- **Hypothesis to relax**: i.i.d. samples in the per-step SGD update.
- **Target**: samples drawn from a Markov chain with mixing time $\tau_{\text{mix}}$. Generalize stability bound to $O(L^2 \tau_{\text{mix}} / n)$ or similar.
- **Prior work**: Sun–Sun–Yin (2018) "On Markov chain gradient descent" has convergence but not stability; Duchi–Agarwal–Wainwright (2012) for ergodic optimization without stability. **Clear gap on the stability side.**
- **Technique**: combine HRS coupling with Markov-chain coupling (Pitman, Rosenthal). Proof template mostly ports; Markov-to-i.i.d. reduction via block-decomposition is standard.
- **Difficulty**: research-level but tractable.

**R2. OGDA bilinear last-iterate → OGDA nonconvex-nonconcave Minty**
- **Base proof**: `proofs/research/optimization/convergence/ogda-bilinear-last-iterate/` (Golowich et al. 2020).
- **Hypothesis to relax**: bilinear structure, which gives closed-form spectral analysis.
- **Target**: nonconvex-nonconcave saddle-point problems satisfying the **Minty variational inequality** (weak MVI). Does OGDA still achieve last-iterate $O(1/T)$?
- **Prior work**: **Diakonikolas–Daskalakis–Jordan 2021** established convergence of OGDA-like methods under Minty with $O(1/\sqrt T)$ rate; Liu–Mokhtari et al. 2020 under different conditions. **Gap in last-iterate $O(1/T)$ under weak MVI.**
- **Technique**: Minty gives a Lyapunov function; spectral argument from bilinear case is replaced by generic inner-product calculation.
- **Difficulty**: research-level, genuinely open in specific sub-regime.

**R3. STORM non-convex convergence → STORM with biased oracle**
- **Base proof**: `proofs/research/optimization/stochastic/storm-nonconvex-convergence/` (Cutkosky–Orabona 2019).
- **Hypothesis to relax**: unbiased stochastic gradient oracle $\mathbb{E}[g_t | x_t] = \nabla f(x_t)$.
- **Target**: biased oracle with bias $\|b_t\| \le B$ (e.g., from clipping, quantization, compressed gradients). Does STORM still achieve $O(\sigma^{2/3}/T^{2/3})$ modulo a bias floor?
- **Prior work**: **Ajalloeian–Stich 2020** for biased SGD; **Chen–Giannakis** for compressed SGD. **STORM-specific biased analysis is not cleanly in the literature.**
- **Technique**: modify the recursive variance identity to include a bias-drift term; show Lyapunov still decreases up to $O(B^2)$ floor.
- **Difficulty**: research-level, feasible, immediate applications in federated/compressed optimization.

### Ranking (for next pivot)

| Rank | Target | Feasibility | Novelty likelihood | Impact |
|---|---|---|---|---|
| 1 | **R1 (HRS-Markov)** | High | High (clear gap) | Medium (federated / RL stability) |
| 2 | **R3 (STORM-biased)** | High | Medium (adjacent to Ajalloeian) | Medium-high (compressed/federated) |
| 3 | **R2 (OGDA-Minty)** | Medium | High (specific sub-regime open) | Medium (min-max / GAN stability) |

**Primary recommendation: R1 (HRS → Markovian-sample SGD stability)**. Clean hypothesis relaxation, clear literature gap, proof template ports, concrete application (RL / federated).

---

## Sources consulted

- Monderer & Shapley 1996 — "Potential games." GEB. Foundational.
- Chen & Syrgkanis 2018 (ICLR) — "Greedy no-regret learning in potential games." **Closest adjacent result.**
- Mertikopoulos, Bravo, Leslie — no-regret in concave games, various 2017–2019.
- Dontchev & Rockafellar 2009 — *Implicit Functions and Solution Mappings*. **VI sensitivity, gives C3.3-revised as corollary.**
- Rubinstein 2017 (STOC) — query complexity of Nash.
- Sessa–Krause–Kamgarpour 2020 (NeurIPS) — unknown games with correlated payoffs.
- Anagnostides et al. 2022–2024 (NeurIPS series) — near-optimal no-regret in games.
- Ajalloeian & Stich 2020 — biased SGD (for R3 reference).
- Diakonikolas–Daskalakis–Jordan 2021 — Minty VI and first-order methods (for R2 reference).
- Sun–Sun–Yin 2018 — Markov chain gradient descent (for R1 reference).
