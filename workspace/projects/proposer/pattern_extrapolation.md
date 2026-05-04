# Pattern Extrapolation — Step A2

> Source: `workspace/discovery_reports/master_discovery_report.md`.
> The master report identifies discovery archetypes that recur across the library.
> For each archetype, generate the same question for every algorithm/setting where it has NOT been asked yet.
> Aim: 15-25 candidates.

Archetypes covered:
- **AT-1** Iteration-type asymmetry (4 known: SVRG last-vs-avg, SHB cycling vs PR, PR speedup under PL+interp, SHB best vs last)
- **AT-2** Restricted-geometry naming (4 known: NTK hyperplane cells, LASSO cone, SSL top-k block, matrix-Rényi trace-free)
- **AT-3** Conjecture-rescue / hypothesis-tightening (7 known: 4 SHB variants, 2 SSL, DYS variant, NPG gauge-invariant)
- **AT-4** Algorithm-design-as-proof-simplification (7 known: SPIDER→SARAH→STORM→PAGE; Adam→AMSGrad→AdaGrad-Norm; DYS variant; TS pivot)
- **AT-5** Cancellation-pair (18 known, dominant)
- **AT-6** Construction-search via adversarial polytope/sign-rotational geometry (6 known)
- **AT-7** Algorithm-existential refutation (~3 known: A3, A4, A5 in OP-2 cluster)
- **AT-8** Failure-of-natural-approach extension (15 known)

---

## Cluster A — Iteration-type asymmetry (AT-1) extrapolated to other algorithms (5 candidates)

### Candidate: PAGE last-iterate vs averaged-iterate $\Theta(\log T)$ gap
- **Problem statement**: PAGE for non-SC finite-sum non-convex has averaged $\frac1T\sum\mathbb E\|\nabla f(x_t)\|^2 = O(1/T)$ but last-iterate satisfies $\mathbb E\|\nabla f(x_T)\|^2 = \Omega(\log T/T)$ on a Bernoulli-reset hard instance.
- **Setting**: finite-sum non-convex, PAGE, comparing iterate types.
- **Why it's a pattern**: AT-1 has 4 instances all in optimization/SC; never applied to a VR algorithm. PAGE's Bernoulli reset is the ideal "predictable cycle" for a HLL-R-style log-gap.
- **Suggested proof strategy**: `descent_lemma_telescope` + Bernoulli-reset Lyapunov + reduction to Harvey-Liaw-Lu-Randhawa 2019.
- **Difficulty estimate**: research
- **Plausibility**: HIGH.

### Candidate: ULA Polyak-Ruppert speedup under LSI
- **Problem statement**: Under LSI with constant $\lambda$, ULA Polyak-Ruppert weighted-average satisfies $W_2(\bar\rho_T, \pi)^2 = O(1/T^2)$ vs ergodic $O(1/T)$ — strict $T$-factor speedup.
- **Setting**: LSI target, ULA, PR-weighted average iterate.
- **Why it's a pattern**: AT-1 has SHB→PR speedup (A5), SGD-PL→PR speedup. Never applied to MCMC/sampling.
- **Suggested proof strategy**: `couple_track` + Girsanov + arithmetico-geometric weighted sum (A5 template).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (could exist with smaller speedup; ULA is contractive in $W_2$ already).

### Candidate: ADMM Polyak-Ruppert weighted average defeats $O(1/T)$
- **Problem statement**: ADMM with $1, 2, \dots, T$ weights achieves $\|A\bar x_T + B\bar z_T-c\|^2 = O(1/T^2)$ on convex composite, strictly better than the He-Yuan ergodic rate.
- **Setting**: convex composite, ADMM with PR weights.
- **Why it's a pattern**: A5 (PR defeats SHB cycling) suggests PR is generically faster than uniform averaging when the underlying error has smooth structure. ADMM untouched.
- **Suggested proof strategy**: `cancellation_pair` (existing ADMM Lyapunov) + PR weighted residual analysis.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (ADMM ergodic is already optimal; speedup might be problem-dependent).

### Candidate: Catoni PAC-Bayes for per-prefix posteriors (last vs averaged posterior)
- **Problem statement**: For online SGD with Catoni PAC-Bayes posterior $Q_t \propto e^{-\alpha L_t}$, the last posterior $Q_T$ has gen-bound $O(\sqrt{\text{KL}/n})$, but the averaged-posterior $\bar Q_T = \frac1T\sum Q_t$ has gen-bound $O(\log T/n)$ — strictly tighter via concentration.
- **Setting**: online learning, Catoni PAC-Bayes.
- **Why it's a pattern**: AT-1 has not been asked in PAC-Bayes context.
- **Suggested proof strategy**: `exp_supermartingale` + posterior averaging + Donsker-Varadhan.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: Q-learning best-iterate vs last-iterate regret
- **Problem statement**: For tabular Q-learning UCB-Hoeffding, the best-policy regret $V^\star(s) - V^{\pi^{\text{best}}}(s)$ is $\tilde O(\sqrt{H^2 SAT})$ — strict factor of $H$ improvement over the last-policy regret $\tilde O(\sqrt{H^4 SAT})$.
- **Setting**: tabular MDP, online RL, best-policy iterate.
- **Why it's a pattern**: AT-1 untouched in online RL.
- **Suggested proof strategy**: `couple_track` (existing chain) + best-iterate selection via empirical Q-gap.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

---

## Cluster B — Restricted-geometry naming (AT-2) extrapolated (4 candidates)

### Candidate: PDHG restricted-cone analysis for sparse saddle-point (LASSO-LP duality)
- **Problem statement**: For PDHG on the LASSO LP, the iterate error decomposes onto an "active-set cone" $C = \{Δ : \|\Delta_{S^c}\|_1 \le 3\|\Delta_S\|_1\}$ on which restricted strong concavity holds, giving linear rate $(1-c\mu_C/L)^T$.
- **Setting**: PDHG on LASSO-style sparse saddle-point.
- **Why it's a pattern**: D3 (LASSO cone) + C2 cluster (PDHG cancellation) sit in different clusters; their cross is open.
- **Suggested proof strategy**: `cancellation_pair` (PDHG chain) + cone-restricted strong concavity (LASSO chain).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: NTK Gram positive-definiteness restricted to a "data-active" subspace
- **Problem statement**: For 2-layer ReLU with $m$ neurons and $n$ data points where $m \ll n$, the Gram matrix $H_\infty$ restricted to a "data-active" subspace of dimension $r_\text{eff}$ has $\lambda_{\min}(H_\infty|_{\text{active}}) \ge c r_\text{eff}/n$, governing the convergence rate.
- **Setting**: under-parameterized NTK, 2-layer ReLU.
- **Why it's a pattern**: A39 (NTK Gram PD) is for over-parameterized; under-parameterized regime is open.
- **Suggested proof strategy**: `OTHER:cone_constraint` + sparse-subspace eigenvalue analysis.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: GDA / minimax restricted-strong-monotonicity cone
- **Problem statement**: For non-convex-non-concave minimax with monotonicity restricted to an interaction cone $C(\beta) = \{(δ_x, δ_y) : \|\delta_x\|^2 + \|\delta_y\|^2 \ge \beta\langle\delta_x, B\delta_y\rangle\}$, GDA achieves $O(1/T)$ on $C(\beta)$.
- **Setting**: non-convex-non-concave saddle, GDA.
- **Why it's a pattern**: AT-2 has not been applied to minimax.
- **Suggested proof strategy**: `OTHER:cone_constraint` + adversarial-parameter restriction (LASSO chain) + skew-symmetric polarization (OGDA chain).
- **Difficulty estimate**: research
- **Plausibility**: LOW-MEDIUM (interaction cone might not be a natural object).

### Candidate: SAM convergence restricted to "flat-region geometry"
- **Problem statement**: For non-convex $f$ with a "flat region" $F = \{x: \|\nabla f(x)\| \le \rho L\}$, SAM with radius $\rho$ guarantees first-passage-time to $F$ in $O(L^2/\rho^2 \cdot 1/T)$ steps — escape from sharp regions, settle in flat ones.
- **Setting**: non-convex, SAM restricted to flat region geometry.
- **Why it's a pattern**: AT-2 + SAM (which already uses approximate gradient) is an unexplored combination.
- **Suggested proof strategy**: `descent_lemma_telescope` (SAM chain) + first-passage-time cone analysis.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (this is also a quasi-empirical claim folded into the SAM intuition).

---

## Cluster C — Conjecture-rescue / hypothesis-tightening (AT-3) extrapolated (4 candidates)

### Candidate: ULA mixing under weakened Poincaré inequality (rescue)
- **Problem statement**: ULA mixing time under the weak Poincaré inequality (sub-exponential decay) is $T(\varepsilon) = \tilde O(\log(1/\varepsilon)/\lambda^{1/(1-\alpha)})$ for $\alpha\in(0,1)$, with literal LSI rate REFUTED in this regime.
- **Setting**: weak-Poincaré target distribution, ULA.
- **Why it's a pattern**: ULA-LSI is filled (`ula-kl-convergence-lsi/`); the literal LSI rate is widely believed but FALSE under weak Poincaré (Cattiaux-Guillin family). Rescue analog of SSL phase transition refutation.
- **Suggested proof strategy**: `couple_track` + Girsanov + identification of the right weakened condition.
- **Difficulty estimate**: research
- **Plausibility**: HIGH (the field has multiple such weakening lines).

### Candidate: Catoni PAC-Bayes "literal sharpness" rescue
- **Problem statement**: Catoni's bound is sharper than McAllester at small empirical risk; show its literal "$\sqrt{(L_S(1-L_S))/n}$" form is FALSE for non-binary losses, but a refined "$\sqrt{V/n}$" with empirical variance $V$ holds universally.
- **Setting**: PAC-Bayes for general losses.
- **Why it's a pattern**: SSL refutation pattern: literal claim REFUTED, refined version PROVED.
- **Suggested proof strategy**: Counterexample for a 3-valued loss + Bernstein-style empirical-variance refinement.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: SPIDER's "$\sqrt n$ rate" universality rescue
- **Problem statement**: The literal claim "$\sqrt n/\varepsilon^2$ for ALL non-convex finite-sum" is FALSE; under a "trivial-Hessian-sum" instance (componentwise gradients perfectly anticorrelated), SPIDER's rate degenerates to $n/\varepsilon^2$ — no $\sqrt n$ improvement.
- **Setting**: finite-sum non-convex with engineered anticorrelation.
- **Why it's a pattern**: AT-3 + AT-7 (algorithm-existential refutation). Sibling A14 (SVRG log-gap disproof).
- **Suggested proof strategy**: `OTHER:algorithm_existential_refutation` + anticorrelated-gradient construction.
- **Difficulty estimate**: research
- **Plausibility**: LOW-MEDIUM (anticorrelation may not arise in natural problems; refutation is intricate).

### Candidate: Adam "no-ad-hoc-step" rescue: under what conditions is no learning-rate decay needed?
- **Problem statement**: The literal claim "Adam with constant $\eta$ converges on smooth non-convex" is FALSE (Reddi 2018 in different parameterization). Refined: under bounded-gradient + $\beta_2 \to 1$ regime, constant-$\eta$ Adam achieves $O(1/\sqrt T)$.
- **Setting**: smooth non-convex, Adam constant $\eta$, $\beta_2 \to 1$.
- **Why it's a pattern**: AT-3 + AT-1 + AT-7. Sibling: SHB cycling restriction (A1 → A3).
- **Suggested proof strategy**: `descent_lemma_telescope` + EMA-asymptotic regime analysis + counterexample for $\beta_2$ bounded away from 1.
- **Difficulty estimate**: research
- **Plausibility**: HIGH (Defossez et al. 2022 essentially do this).

---

## Cluster D — Algorithm-design-as-proof-simplification (AT-4) extrapolated (4 candidates)

### Candidate: Design "BernoulliSGD": Bernoulli-reset SGD with provable $O(1/\sqrt T)$ for non-SC
- **Problem statement**: Construct an SGD variant that uses Bernoulli($p=1/\sqrt T$) snapshot resets (à la PAGE). Prove this variant has the cleanest possible convergence proof: a 1-line geometric variance recursion.
- **Setting**: smooth non-convex, finite-sum, designed algorithm.
- **Why it's a pattern**: AT-4: SPIDER → PAGE was Bernoulli-driven. The same trick should clean up vanilla SGD's analysis.
- **Suggested proof strategy**: `descent_lemma_telescope` + Bernoulli reset variance recursion (PAGE chain).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (algorithm exists implicitly; the contribution is the cleaner proof).

### Candidate: Design "Predictable-Adam": Adam variant with predictable surrogate $\hat v_{t-1}$
- **Problem statement**: Construct Adam variant that uses $\hat v_{t-1}$ in the denominator (à la AMSGrad's monotone surrogate, but predictable not monotone). Prove convergence under bounded gradients via `predictable_surrogate` template.
- **Setting**: smooth non-convex, designed Adam variant.
- **Why it's a pattern**: AT-4: AMSGrad's surrogate trick is intermediate; "fully predictable" is the clean limit.
- **Suggested proof strategy**: `cancellation_pair` (martingale-restoring trick) + AMSGrad-style monotone bound.
- **Difficulty estimate**: research
- **Plausibility**: HIGH.

### Candidate: Design "AC-DR splitting": accelerated Douglas-Rachford via Catalyst-style restart
- **Problem statement**: Construct an accelerated DR-splitting variant with $O(1/k^2)$ rate via Catalyst-style outer-loop momentum.
- **Setting**: convex composite, designed DR variant.
- **Why it's a pattern**: AT-4 + AT-5 (cancellation). DR-splitting `O(1/k)` is filled; the accelerated version is open.
- **Suggested proof strategy**: `fixed_point_contraction` + Catalyst momentum + averagedness cancellation.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (Catalyst-DR exists; clean proof is the contribution).

### Candidate: Design "InterpAdam": Adam variant for interpolation regime with tight bound
- **Problem statement**: Construct Adam variant that, under interpolation, achieves linear rate $(1-c)^T$ — design $\beta_1, \beta_2$ schedules so the EMA collapses to a clean contraction.
- **Setting**: interpolation regime, designed Adam.
- **Why it's a pattern**: AT-4 + sibling momentum-SGD interpolation contraction (3 variants in library).
- **Suggested proof strategy**: `lyapunov_potential` + interpolation contraction (SGD chain) + EMA design.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

---

## Cluster E — Construction-search via adversarial polytope (AT-6) extrapolated (3 candidates)

### Candidate: Adversarial polytope hard instance for natural gradient methods (NPG / NGD)
- **Problem statement**: Construct a tabular MDP where natural policy gradient with constant $\eta$ exhibits a $K$-cycle in the simplex, giving $V^\star - V^{\pi_t} = \Omega(1/T)$ matching the upper bound.
- **Setting**: tabular MDP, NPG, lower bound.
- **Why it's a pattern**: AT-6 untouched in RL. Sibling A1 (Goujaud SHB cycling).
- **Suggested proof strategy**: `polytope_construction` + simplex-rotational geometry.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: Adversarial polytope for Davis-Yin three-op (sharp $\Omega(1/k)$ LB)
- **Problem statement**: Construct a 3-operator monotone inclusion where Davis-Yin three-op-splitting has $\|z_k - z^\star\| = \Omega(1/k)$ — matching upper bound.
- **Setting**: monotone inclusion, DY-splitting.
- **Why it's a pattern**: AT-6 + AT-3 (DYS already has rescue tradition).
- **Suggested proof strategy**: `polytope_construction` + monotone-operator rotational geometry.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: Adversarial polytope for STORM with cycling oracle
- **Problem statement**: Construct an oracle on smooth non-convex such that STORM exhibits cycling in $(\nabla f, v_t)$ space with $\|v_t - \nabla f(x_t)\| = \Omega(1)$, giving $\frac1T\sum\mathbb E\|\nabla f\|^2 = \Omega(1/T^{2/3})$.
- **Setting**: streaming non-convex, STORM, lower bound.
- **Why it's a pattern**: AT-6 untouched in VR/streaming.
- **Suggested proof strategy**: `polytope_construction` + EMA-cycling geometry.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (STORM is conjectured optimal so the LB has to match the UB).

---

## Cluster F — Failure-of-natural-approach extension (AT-8) extrapolated (3 candidates)

### Candidate: Wasserstein analysis fails for ULA under non-LSI = "bad gradient" instance
- **Problem statement**: Exhibit smooth log-concave (no LSI) target where ULA in $W_2$ achieves rate $O(1/\sqrt T)$ but the corresponding KL-rate is $\Omega(1)$ — refuting "$W_2$-rate implies KL-rate" folklore.
- **Setting**: smooth log-concave target, ULA.
- **Why it's a pattern**: AT-8 + AT-7. The key insight from `ula-kl-convergence-lsi` is that Wasserstein + LSI gives KL via direct path; without LSI, the implication breaks.
- **Suggested proof strategy**: `OTHER:algorithm_existential_refutation` + log-concave-no-LSI construction.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH.

### Candidate: PDHG fails to accelerate under partial smoothness (failure-driven LB)
- **Problem statement**: Show PDHG cannot achieve $O(1/T^2)$ under partial smoothness alone (without partial SC), exhibiting an instance where PDHG plateaus at $\Omega(1/T)$.
- **Setting**: convex-concave saddle, PDHG, lower bound.
- **Why it's a pattern**: AT-8 in PDHG context. Failure-of-natural-approach for "smoothness implies acceleration" intuition.
- **Suggested proof strategy**: `polytope_construction` + structured-smoothness counterexample.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: Implicit bias of Adam — does Adam converge to max-margin like GD?
- **Problem statement**: For separable logistic regression, plain GD's iterate-direction converges to max-margin (Soudry et al. 2018, in library). Show that Adam's iterate-direction does NOT converge to max-margin — exhibit a 2-D instance where Adam converges to a strictly suboptimal margin direction.
- **Setting**: separable binary classification, Adam.
- **Why it's a pattern**: AT-8 + AT-1. `implicit-bias-gd-max-margin/` is the GD baseline. Adam's per-coord scaling should provably break the max-margin property.
- **Suggested proof strategy**: `OTHER:divergence_direction_analysis` (GD chain, but with Adam-specific failure).
- **Difficulty estimate**: research
- **Plausibility**: HIGH (Wang-Wibisono-Wilson 2021 noted this; clean theorem in library would be valuable).

---

## Summary table

| Cluster | Archetype | # Candidates | Plausibility |
|---|---|---|---|
| A | Iteration-type asymmetry | 5 | HIGH/MED |
| B | Restricted-geometry naming | 4 | MEDIUM |
| C | Conjecture-rescue | 4 | HIGH/MED |
| D | Algorithm-design-as-proof | 4 | HIGH/MED |
| E | Adversarial polytope | 3 | MEDIUM |
| F | Failure-of-natural-approach | 3 | HIGH/MED |
| **Total** | | **23** | |

Top picks across clusters: A1 (PAGE last vs averaged), A2 (ULA PR speedup), C4 (Adam constant-η rescue), D2 (Predictable-Adam), F3 (Adam implicit bias divergence from max margin).
