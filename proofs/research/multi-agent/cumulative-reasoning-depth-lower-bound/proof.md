# Proof: Depth Lower Bound for CR Compositional Reasoning

**Verdict:** Part (a) PASS. Parts (b), (c) PARTIAL (with explicit gaps).

## 1. Computational model

A CR-depth-$d$ task is a derivation tree of depth $d$ over $m$ primitive facts. Let $C_1, \ldots, C_d$ denote intermediate conclusions ($C_d$ = final).

- A **step** is one Proposer–Verifier interaction.
- The Verifier accepts a wrong proposition with probability $\le \varepsilon$ (soundness side).
- With $k$ i.i.d. retries per level, the cluster-effective error is at most $\varepsilon^k$.

**Hypothesis 1 (adversarial alternative).** At each level $\ell$ there exists a wrong candidate $C_\ell^\dagger$ that is verifier-statistically indistinguishable from $C_\ell^*$: under the correct proposition the Verifier returns 1 with probability $1-\varepsilon$, under $C_\ell^\dagger$ with probability $\varepsilon$.

This hypothesis holds for genuine compositional tasks (where alternative consistent derivations exist) and is necessary: without it, a single trivial step suffices.

## 2. Part (a) — Lower bound

**Theorem 1.** Under Hypothesis 1, any randomized agent solving the depth-$d$ task with overall failure probability $\le \delta$ requires
$$T \;\ge\; d \cdot \frac{\log(1/(2\delta))}{\log(1/\varepsilon)} \;=\; d \cdot \frac{\log(1/\delta)}{\log(1/\varepsilon)} - O(d).$$

In particular, for $\delta \le 1/2$ the simpler form $T \ge d \log(1/\delta)/\log(1/\varepsilon)$ holds modulo a sub-leading $O(d)$ correction.

### Proof

**Step 1: Per-level failure must be small.**
Let $E_\ell$ be the event "level $\ell$ outputs a wrong proposition (after all retries)". The chain succeeds iff $\bigcap_\ell E_\ell^c$ holds, so
$$1 - \delta \le \Pr\bigl[\bigcap_\ell E_\ell^c\bigr] \le \min_\ell \Pr[E_\ell^c] = 1 - \max_\ell \Pr[E_\ell].$$
Hence $\Pr[E_\ell] \le \delta$ for every level.

**Step 2: Adversary lower bound on per-level error (Yao's principle).**

Apply Yao's minimax principle on the hard distribution: each level's correct proposition is uniformly drawn from $\{C_\ell^*, C_\ell^\dagger\}$. Under Hypothesis 1, the Verifier's responses form Bernoulli$(1-\varepsilon)$ under one hypothesis and Bernoulli$(\varepsilon)$ under the other.

For any deterministic algorithm using $T_\ell$ Verifier queries at level $\ell$, the Bayes-optimal binary hypothesis test errs with probability
$$\Pr[\text{err}] \;\ge\; \tfrac{1}{2}\bigl[\min(\varepsilon, 1-\varepsilon)\bigr]^{T_\ell} \;=\; \tfrac{1}{2}\,\varepsilon^{T_\ell}\quad (\text{for } \varepsilon < 1/2).$$

By Yao's principle this lower bound transfers to any randomized algorithm:
$$\Pr[E_\ell] \ge \tfrac{1}{2}\varepsilon^{T_\ell}.$$

**Step 3: Combining.**
From Steps 1–2: $\tfrac{1}{2}\varepsilon^{T_\ell} \le \delta$, so $\varepsilon^{T_\ell} \le 2\delta$, and taking logs,
$$T_\ell \ge \frac{\log(1/(2\delta))}{\log(1/\varepsilon)}.$$
Summing over $d$ levels,
$$T \;=\; \sum_{\ell=1}^d T_\ell \;\ge\; d \cdot \frac{\log(1/(2\delta))}{\log(1/\varepsilon)}. \qquad\blacksquare$$

## 3. Part (b) — No-parallelization (transcript-dependency model)

**Definition (parallel CR computation).** A labeled DAG $G = (V, E)$ where each node $v$ outputs a proposition $p_v$ via Proposer–Verifier interaction; $(u, v) \in E$ means $p_u$ is a verified premise of $p_v$. Causality: a Proposer at node $v$ at time $\tau(v)$ has access only to outputs of nodes $u$ with $\tau(u) < \tau(v)$.

**Hypothesis 2 (transcript-dependency).** A Verifier accepting a level-$\ell$ proposition requires a verified level-$(\ell-1)$ proposition as input; the Verifier cannot soundly judge a proposition without verified premises.

**Theorem 2.** Under Hypothesis 2, any parallel CR computation establishing $C_d$ has makespan $\ge d$.

### Proof

Let $v_d$ output the certified $C_d$. By Hypothesis 2, $v_d$ has an in-neighbor $v_{d-1}$ outputting certified $C_{d-1}$; inductively, there exists a chain $v_d \succ v_{d-1} \succ \cdots \succ v_1$ in $G$. Causality gives $\tau(v_d) > \tau(v_{d-1}) > \cdots > \tau(v_1) \ge 1$, hence $\tau(v_d) \ge d$. $\blacksquare$

**Gap (PARTIAL).** Without Hypothesis 2 — under a *permissive* verifier model that judges each proposition on intrinsic logical merit independent of premise certification — parallel speedup is possible (the agent can guess all $d$ levels in parallel and verify each independently). Hence the no-parallelization claim is **model-dependent**.

## 4. Part (c) — Numerical evaluation

**Claim:** $T \ge 5 \log(100)/\log(1/0.14^3) \approx 18$.

**Audit:**
$$\frac{5 \log(100)}{\log(1/0.14^3)} \;=\; \frac{5 \times 4.6052}{5.8982} \;=\; 3.904.$$

| Interpretation | Bound formula | Value |
|---|---|---|
| Cluster-step ($\varepsilon^k$ per step) | $d \log(1/\delta)/\log(1/\varepsilon^k)$ | **3.90** |
| Verifier-call step ($\varepsilon$ per step) | $d \log(1/\delta)/\log(1/\varepsilon)$ | **11.71** |
| Stated claim | "$\approx 18$" | **DISCREPANCY** |

The stated formula is consistent with our derivation (matching the cluster-step interpretation), but the claimed numerical answer "≈ 18" is **arithmetically wrong by a factor of $\sim 4.6\times$**. We cannot make the formula and the numerical answer simultaneously correct.

**Honest verdict on (c):**
- Formula derivation (with retry interpretation): **CORRECT**.
- Numerical evaluation in the claim ($\approx 18$): **INCORRECT** — actual value is $\approx 3.9$.

## 5. Summary

| Part | Verdict | Notes |
|---|---|---|
| (a) | **PASS** | Modulo $\log 2$ in numerator; valid for $\delta \le 1/2$. Hypothesis 1 required. |
| (b) | **PARTIAL** | Proved under transcript-dependency model (Hypothesis 2). Permissive-model gap. |
| (c) | **PARTIAL** | Formula correct; numerical claim "18" is wrong (correct: 3.9). |

## 6. Verification

- **SymPy:** $\varepsilon^{T_\ell} = \delta \Rightarrow T_\ell = \log(\delta)/\log(\varepsilon) = \log(1/\delta)/\log(1/\varepsilon)$, symbolically confirmed.
- **Z3:** linearized inequality $T_\ell \log\varepsilon \le \log\delta$ implies $T_\ell \ge \log(1/\delta)/\log(1/\varepsilon)$; negation `unsat` at $\varepsilon=0.14, \delta=0.01$.
- **Numerical:** value of stated formula at problem parameters is $3.9038$.
