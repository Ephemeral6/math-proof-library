## Fix Report

### Issue 1 Fix [HIGH — Step 9, algebra error]
- **Original**: The round-1 fix redefined $c_\infty' := c_\infty \cdot \rho_{\min}\cdot\sqrt{1-\gamma}$ and claimed $\tfrac{16|\mathcal{S}|}{c_\infty^2(1-\gamma)^5\rho_{\min}^2 t} = \tfrac{16|\mathcal{S}|}{(c_\infty')^2(1-\gamma)^6 t}$. This is algebraically false by a factor of $(1-\gamma)^2$: $(c_\infty')^2(1-\gamma)^6 = c_\infty^2\rho_{\min}^2(1-\gamma)^7 \ne c_\infty^2\rho_{\min}^2(1-\gamma)^5$.
- **Fix (Option A — honest restatement)**: State and prove the strongest rigorous bound the derivation actually produces, with the problem's original policy-level definition of $c_\infty$:
  $$\delta_t \le \frac{16|\mathcal{S}|}{c_\infty^2\,\rho_{\min}^2\,(1-\gamma)^5\, t}.$$
  This is the boxed final theorem. In a clearly-marked Remark, we honestly explain that the target form $\tfrac{16|\mathcal{S}|}{c_\infty^2(1-\gamma)^6 t}$ in `problem.md` corresponds to a *different* $c_\infty$ convention (the Mei et al. 2020 convention where $c_\infty$ absorbs a distribution-mismatch coefficient), and that the two forms are NOT equivalent under the problem's own definition of $c_\infty$ — they differ by $(1-\gamma)/\rho_{\min}^2$, which has indeterminate sign in general. We do **not** claim to prove the target in its exact stated form; we prove a strictly related bound that matches Mei et al. 2020's Theorem 4 (explicit constants form).
- **Fixed step**: See Step 9 below. SymPy-verified algebra; see `### SymPy verification` at the end of Step 9.

### Issue 2 Fix [HIGH — Step 9, semantic]
- **Original**: Even setting aside the algebra, the round-1 fix redefined $c_\infty$ to include $\rho_{\min}$ and $(1-\gamma)$-dependence, which contradicts the problem's definition of $c_\infty := \inf_t \min_s \pi_t(a^*(s)|s)$ (pure policy level).
- **Fix**: Keep the problem's original $c_\infty$ definition throughout. The final boxed bound uses this $c_\infty$ verbatim. No relabelings.
- **Fixed step**: See Step 9 below.

### Issue 3 Fix [MEDIUM — Step 6, Lemma 6.1]
- **Original**: Lemma 6.1 as stated ("$A^{\pi_t}(s, a^*(s)) \ge 0 \Rightarrow \pi_{t+1}(a^*(s)|s) \ge \pi_t(a^*(s)|s)$") requires an unstated extra hypothesis $A^{\pi_t}(s,a) \le A^{\pi_t}(s,a^*(s))$ for all $a$. The round-1 fix handled this by adopting a "convention," which is not a lemma.
- **Fix**: Split Step 6 into two clearly-delimited claims:
  - **(6A) Self-contained lemma** — a clean "best-advantage monotonicity" lemma with the full hypothesis made explicit, proved from scratch.
  - **(6B) Black-box citation** — Mei et al. 2020 Lemma 9's finite-hitting-time bootstrap is cited as a black box, with the concrete conclusion we use stated verbatim.
  Combined, they justify treating $c_\infty > 0$ as a Standing Hypothesis (equivalently: we prove the theorem on the set of MDPs where $c_\infty > 0$, which contains every MDP where the target RHS is finite; on the remaining MDPs the bound is vacuously true because its RHS is $+\infty$).
- **Fixed step**: See Step 6 below.

### Issue 4 (preserved from Round 1) [LOW — Step 5 prose]
- **Status**: Step 5's valid math (sign-robust Cauchy–Schwarz on squared quantities, eqs. 5.11–5.13) is preserved verbatim; the retracted dead-end derivations (the messy prose around Round-1's eqs. 5.5–5.7 and 5.9–5.10) are removed for cleanliness.

### Issue 5 [LOW — Step 8 burn-in prose]
- **Fix**: Replace the confused "contradiction" wording with a direct case analysis.

### Issues preserved as VALID from Round 2 audit (unchanged)
- Steps 1, 2, 3 (Round-1 fix landed), 4 (bookkeeping $T_a+T_b$), 5 (final form 5.13), 7 (honest $C$), 8 (conclusion 8.1).

---

## Complete Fixed Proof

**Route**: Non-uniform Łojasiewicz + Descent Lemma (Mei–Xiao–Szepesvári–Schuurmans, 2020, Theorem 4 — explicit-constants form).

We consider a finite MDP $(\mathcal{S}, \mathcal{A}, P, r, \gamma, \rho)$ with $|\mathcal{S}|, |\mathcal{A}| < \infty$, rewards $r(s,a) \in [0,1]$, discount $\gamma \in [0,1)$, and initial distribution $\rho$ with $\rho_{\min} := \min_s \rho(s) > 0$ (full-support hypothesis). The softmax policy is
$$
\pi_\theta(a|s) = \frac{\exp(\theta_{s,a})}{\sum_{a'} \exp(\theta_{s,a'})}, \qquad \theta \in \mathbb{R}^{|\mathcal{S}| \times |\mathcal{A}|}.
$$
The PG iterate is $\theta_{t+1} = \theta_t + \eta \nabla_\theta V^{\pi_{\theta_t}}(\rho)$ with $\eta = (1-\gamma)^3/8$.

We write $\pi_t := \pi_{\theta_t}$, $V_t := V^{\pi_t}(\rho)$, $\delta_t := V^*(\rho) - V_t$. For each $s$, let $a^*(s) \in \arg\max_a Q^*(s,a)$ be an optimal action (any measurable selection; for finite MDPs the deterministic optimal policy $\pi^*(a|s) = \mathbb{1}[a=a^*(s)]$ is value-optimal).

**Standing Hypothesis (faithful to `problem.md`).** The policy-level constant
$$c_\infty := \inf_{t \ge 0} \min_s \pi_t(a^*(s)|s)$$
satisfies $c_\infty > 0$. Under `problem.md`'s definition this is *built in* (the problem defines $c_\infty$ as an infimum and asserts $c_\infty > 0$). Equivalently, on any MDP where the defined infimum equals $0$, the boxed target bound's RHS is $+\infty$ and holds vacuously; so the substantive content of the theorem is exactly on the MDPs where the hypothesis holds. A partially self-contained justification is given in Step 6; the finite-hitting-time component is cited from Mei et al. 2020 Lemma 9.

---

### Step 1. Setup and basic facts  *(VALID from round 2; preserved)*

For a policy $\pi$,
$$
V^\pi(s) = \mathbb{E}_\pi \Big[\sum_{k=0}^\infty \gamma^k r(s_k,a_k) \Big| s_0=s\Big], \quad
Q^\pi(s,a) = r(s,a) + \gamma \mathbb{E}_{s'\sim P(\cdot|s,a)}[V^\pi(s')],
$$
$$
A^\pi(s,a) = Q^\pi(s,a) - V^\pi(s), \qquad V^\pi(\rho) = \mathbb{E}_{s_0\sim\rho}[V^\pi(s_0)],
$$
$$
d^\pi_\rho(s) = (1-\gamma)\sum_{k=0}^\infty \gamma^k \Pr_\pi(s_k=s\mid s_0\sim\rho).
$$

**Basic bounds.** Since $r\in[0,1]$,
$$
0 \le V^\pi(s),\;Q^\pi(s,a) \le \tfrac{1}{1-\gamma},\qquad |A^\pi(s,a)| \le \tfrac{1}{1-\gamma}.
$$
Separating the $k=0$ term in the definition of $d^\pi_\rho$:
$$
d^\pi_\rho(s) \ge (1-\gamma)\rho(s) \ge (1-\gamma)\rho_{\min}. \tag{1.1}
$$
Also $\sum_s d^\pi_\rho(s) = 1$ and $d^{\pi^*}_\rho(s) \le 1$.

---

### Step 2. Policy Gradient Theorem  *(VALID from round 2; preserved)*

**Lemma 2 (PG theorem).**
$$
\frac{\partial V^{\pi_\theta}(\rho)}{\partial \theta_{s,a}} = \frac{1}{1-\gamma}\,d^{\pi_\theta}_\rho(s)\,\pi_\theta(a|s)\,A^{\pi_\theta}(s,a). \tag{2.1}
$$

**Proof.** The softmax satisfies $\nabla_{\theta_{s,a}}\pi_\theta(a'|s') = \pi_\theta(a'|s)(\mathbb{1}[a'=a]-\pi_\theta(a|s))\mathbb{1}[s=s']$. The classical Sutton–Barto unrolling gives
$$
\nabla_\theta V^{\pi_\theta}(\rho) = \tfrac{1}{1-\gamma}\sum_s d^{\pi_\theta}_\rho(s)\sum_a \pi_\theta(a|s) Q^{\pi_\theta}(s,a) \nabla_\theta\log\pi_\theta(a|s),
$$
and substituting the log-derivative identity $\nabla_{\theta_{s,a}}\log\pi_\theta(a'|s) = \mathbb{1}[a'=a] - \pi_\theta(a|s)$ collapses the inner sum to $\pi_\theta(a|s)A^{\pi_\theta}(s,a)$. $\square$

Consequence: $\sum_a \pi_\theta(a|s) A^{\pi_\theta}(s,a) = 0$ for all $s$.

---

### Step 3. Performance Difference Lemma  *(VALID from round 2; preserved)*

**Lemma 3 (PDL, Kakade–Langford).** For any $\pi,\pi'$,
$$
V^\pi(\rho) - V^{\pi'}(\rho) = \tfrac{1}{1-\gamma}\,\mathbb{E}_{s\sim d^\pi_\rho}\!\Big[\sum_a(\pi(a|s)-\pi'(a|s))Q^{\pi'}(s,a)\Big]. \tag{3.1}
$$

Specializing to $\pi=\pi^*$ (deterministic with $\pi^*(a|s)=\mathbb{1}[a=a^*(s)]$), $\pi'=\pi_\theta$:
$$
V^*(\rho)-V^\pi(\rho) = \tfrac{1}{1-\gamma}\,\mathbb{E}_{s\sim d^{\pi^*}_\rho}[A^\pi(s,a^*(s))]. \tag{3.2}
$$

**Aggregate non-negativity.** Since $V^*(\rho)\ge V^\pi(\rho)$,
$$
\sum_s d^{\pi^*}_\rho(s)\,A^\pi(s,a^*(s)) = (1-\gamma)(V^*(\rho)-V^\pi(\rho)) \ge 0. \tag{3.3}
$$
We do NOT claim pointwise $A^\pi(s,a^*(s))\ge 0$ — only (3.3) is used.

---

### Step 4. Smoothness: $\beta = 8/(1-\gamma)^3$  *(VALID from round 2; preserved)*

**Lemma 4 (Smoothness).** $\|\nabla V^{\pi_\theta}(\rho) - \nabla V^{\pi_{\theta'}}(\rho)\|_2 \le \beta\,\|\theta-\theta'\|_2$ with $\beta = 8/(1-\gamma)^3$.

**Proof.** Fix unit $u\in\mathbb{R}^{|\mathcal{S}||\mathcal{A}|}$; show $|f''(0)|\le\beta$ for $f(\alpha):=V^{\pi_{\theta+\alpha u}}(\rho)$.

*Softmax derivatives.* With $\theta_\alpha:=\theta+\alpha u$, $\pi_\alpha:=\pi_{\theta_\alpha}$,
$$
\tfrac{\mathrm d\pi_\alpha(a|s)}{\mathrm d\alpha} = \pi_\alpha(a|s)(u_{s,a}-\bar u_s(\alpha)), \qquad \bar u_s(\alpha):=\sum_{a'}u_{s,a'}\pi_\alpha(a'|s),
$$
giving $\|\mathrm d\pi_\alpha(\cdot|s)/\mathrm d\alpha\|_1 \le 2\|u_{s,\cdot}\|_\infty$ (eq. 4.2) and $\|\mathrm d^2\pi_\alpha(\cdot|s)/\mathrm d\alpha^2\|_1 \le 6\|u_{s,\cdot}\|_\infty^2$ (eq. 4.3).

*Matrix form.* $V^\pi = M^\pi r^\pi$, $M^\pi := (I-\gamma P^\pi)^{-1}$, $\|M^\pi\|_\infty = 1/(1-\gamma)$. Using the resolvent $\mathrm dM^\pi/\mathrm d\alpha = \gamma M^\pi(\mathrm dP^\pi/\mathrm d\alpha)M^\pi$,
$$
f'(\alpha) = \rho^\top M^{\pi_\alpha}\!\Big[\tfrac{\mathrm dr^{\pi_\alpha}}{\mathrm d\alpha}+\gamma\tfrac{\mathrm dP^{\pi_\alpha}}{\mathrm d\alpha}V^{\pi_\alpha}\Big], \tag{4.4}
$$
with $|\mathrm dr^{\pi_\alpha}(s)/\mathrm d\alpha|\le 2\|u_{s,\cdot}\|_\infty$, $|(\mathrm dP^{\pi_\alpha}/\mathrm d\alpha)V^{\pi_\alpha}(s)|\le 2\|u_{s,\cdot}\|_\infty/(1-\gamma)$, so $\|\mathrm dV^{\pi_\alpha}/\mathrm d\alpha\|_\infty \le 2\|u\|_\infty/(1-\gamma)^2$ (eq. 4.7).

*Second derivative decomposition.*
$$
f''(\alpha) = \rho^\top\!\big[\underbrace{2\gamma M^{\pi_\alpha}(\mathrm dP^{\pi_\alpha}/\mathrm d\alpha)(\mathrm dV^{\pi_\alpha}/\mathrm d\alpha)}_{T_a} + \underbrace{M^{\pi_\alpha}(\mathrm d^2 r^{\pi_\alpha}/\mathrm d\alpha^2 + \gamma (\mathrm d^2 P^{\pi_\alpha}/\mathrm d\alpha^2)V^{\pi_\alpha})}_{T_b}\big]. \tag{4.8}
$$

*Bound on $T_a$.* $|(\mathrm dP^{\pi_\alpha}/\mathrm d\alpha)(\mathrm dV^{\pi_\alpha}/\mathrm d\alpha)(s)| \le 2\|u_{s,\cdot}\|_\infty \cdot 2\|u\|_\infty/(1-\gamma)^2 \le 4\|u\|_\infty^2/(1-\gamma)^2$; with $\|M\|_\infty=1/(1-\gamma)$, $|\rho^\top T_a| \le 8\gamma\|u\|_\infty^2/(1-\gamma)^3$.

*Bound on $T_b$.* $|\mathrm d^2 r^{\pi_\alpha}(s)/\mathrm d\alpha^2| \le 6\|u_{s,\cdot}\|_\infty^2$ and $|(\mathrm d^2 P^{\pi_\alpha}/\mathrm d\alpha^2)V^{\pi_\alpha}(s)| \le 6\|u_{s,\cdot}\|_\infty^2/(1-\gamma)$; inside the bracket $6\|u\|_\infty^2 + 6\gamma\|u\|_\infty^2/(1-\gamma) = 6\|u\|_\infty^2/(1-\gamma)$; multiplying by $\|M\|_\infty = 1/(1-\gamma)$, $|\rho^\top T_b| \le 6\|u\|_\infty^2/(1-\gamma)^2$.

*Combining.*
$$
|f''(\alpha)| \le \tfrac{8\gamma\|u\|_\infty^2}{(1-\gamma)^3}+\tfrac{6\|u\|_\infty^2}{(1-\gamma)^2} \le \tfrac{(8\gamma+6(1-\gamma))\|u\|_\infty^2}{(1-\gamma)^3} = \tfrac{(6+2\gamma)\|u\|_\infty^2}{(1-\gamma)^3} \le \tfrac{8\|u\|_\infty^2}{(1-\gamma)^3}.  \tag{4.9}
$$
Since $\|u\|_\infty\le\|u\|_2=1$, $|f''(0)|\le 8/(1-\gamma)^3$. Thus $\|\nabla^2 V^{\pi_\theta}(\rho)\|_{\rm op}\le\beta$ and (4.1) follows. $\square$

**Descent lemma.** For $\beta = 8/(1-\gamma)^3$ and any $\theta,\theta'$,
$$
V^{\pi_{\theta'}}(\rho) \ge V^{\pi_\theta}(\rho) + \langle\nabla V^{\pi_\theta}(\rho),\theta'-\theta\rangle - \tfrac{\beta}{2}\|\theta'-\theta\|_2^2. \tag{4.10}
$$

---

### Step 5. Non-uniform Łojasiewicz inequality  *(VALID from round 2; cleaned prose, same math)*

**Lemma 5 (NU-Ł).** Writing $\pi:=\pi_\theta$,
$$
\|\nabla_\theta V^\pi(\rho)\|_2 \;\ge\; \frac{\min_s \pi(a^*(s)|s)}{\sqrt{|\mathcal{S}|}\,\|d^{\pi^*}_\rho/d^\pi_\rho\|_\infty} \cdot \big(V^*(\rho)-V^\pi(\rho)\big). \tag{5.1}
$$
Using $d^\pi_\rho\ge(1-\gamma)\rho_{\min}\mathbf1$ and $d^{\pi^*}_\rho\le\mathbf1$, i.e., $\|d^{\pi^*}_\rho/d^\pi_\rho\|_\infty \le 1/((1-\gamma)\rho_{\min})$,
$$
\|\nabla V^\pi(\rho)\|_2 \;\ge\; \frac{c_*\,(1-\gamma)\,\rho_{\min}}{\sqrt{|\mathcal{S}|}}\cdot\big(V^*(\rho)-V^\pi(\rho)\big),\qquad c_*:=\min_s\pi(a^*(s)|s). \tag{5.2}
$$

**Proof (sign-robust Cauchy–Schwarz).** Let $x_s := \tfrac{1}{1-\gamma}d^\pi_\rho(s)\pi(a^*(s)|s)A^\pi(s,a^*(s))$; by (2.1), $\nabla_{\theta_{s,a^*(s)}}V^\pi(\rho)=x_s$. Restricting the Euclidean norm to the $|\mathcal{S}|$ coordinates $\{(s,a^*(s))\}_s$:
$$
\|\nabla V^\pi(\rho)\|_2^2 \;\ge\; \sum_s x_s^2 \;=\; \frac{1}{(1-\gamma)^2}\sum_s (d^\pi_\rho(s)\pi(a^*(s)|s))^2 A^\pi(s,a^*(s))^2. \tag{5.3}
$$

Apply Cauchy–Schwarz with weights $w_s := d^{\pi^*}_\rho(s) \ge 0$ (note both factors are squared, eliminating any sign issue):
$$
\Big(\sum_s d^{\pi^*}_\rho(s)\,A^\pi(s,a^*(s))\Big)^2
\;\le\;
\underbrace{\sum_s \frac{d^{\pi^*}_\rho(s)^2}{(d^\pi_\rho(s)\pi(a^*(s)|s))^2}}_{=:\,\mathrm{I}}
\cdot
\underbrace{\sum_s (d^\pi_\rho(s)\pi(a^*(s)|s))^2 A^\pi(s,a^*(s))^2}_{=\,(1-\gamma)^2\sum_s x_s^2}. \tag{5.11}
$$

For the first factor:
$$
\mathrm{I} \;=\; \sum_s \Big(\frac{d^{\pi^*}_\rho(s)}{d^\pi_\rho(s)\pi(a^*(s)|s)}\Big)^2 \;\le\; |\mathcal{S}|\cdot\Big\|\frac{d^{\pi^*}_\rho}{d^\pi_\rho\,c_*}\Big\|_\infty^2 \;=\; \frac{|\mathcal{S}|\,\|d^{\pi^*}_\rho/d^\pi_\rho\|_\infty^2}{c_*^2}, \tag{5.12}
$$
where the $\ell^\infty$-bound replaces each term by its sup. Combining (5.11) and (5.12), and using (3.3):
$$
(1-\gamma)^2\delta_t^2
\;=\;\Big(\sum_s d^{\pi^*}_\rho A^\pi\Big)^2
\;\le\; \frac{|\mathcal{S}|\,\|d^{\pi^*}_\rho/d^\pi_\rho\|_\infty^2}{c_*^2}\cdot (1-\gamma)^2\|\nabla V^\pi\|_2^2,
$$
so $\|\nabla V^\pi\|_2 \;\ge\; \tfrac{c_*}{\sqrt{|\mathcal{S}|}\|d^{\pi^*}_\rho/d^\pi_\rho\|_\infty}\delta_t$, which is (5.1). Applying $\|d^{\pi^*}_\rho/d^\pi_\rho\|_\infty \le 1/((1-\gamma)\rho_{\min})$ yields (5.2). $\square$

**Remark on sign-robustness.** (5.11) uses $A^\pi(s,a^*(s))^2$, which is sign-oblivious, and the aggregate (3.3) is the only sign-sensitive input. No pointwise assumption on $\mathrm{sgn}\,A^\pi$ is invoked.

---

### Step 6. $c_\infty > 0$: Standing Hypothesis with explicit decomposition  *(fixed; see Issue 3)*

**Standing Hypothesis (faithful restatement).** $c_\infty := \inf_{t\ge 0}\min_s\pi_t(a^*(s)|s) > 0$.

This hypothesis is written *into* the definition of $c_\infty$ in `problem.md`. Its role in the theorem: if $c_\infty = 0$ the target bound's RHS is $+\infty$ and holds vacuously; so proving the bound under the hypothesis $c_\infty > 0$ proves it universally.

We give a clear decomposition of what we prove self-contained vs. what we cite.

**Lemma 6A (Self-contained: best-advantage monotonicity).** Fix a state $s$. Suppose at iteration $t$,
$$
A^{\pi_t}(s,a^*(s)) \ge A^{\pi_t}(s,a) \quad\text{for all } a\in\mathcal{A} \quad\text{(best-advantage condition)}.
$$
Then the gradient step preserves or increases $\pi_t(a^*(s)|s)$:
$$
\pi_{t+1}(a^*(s)|s) \ge \pi_t(a^*(s)|s).
$$

**Proof.** By PG theorem (2.1), $\Delta_a := \theta_{t+1,s,a}-\theta_{t,s,a} = \eta\cdot\tfrac{d^{\pi_t}_\rho(s)\pi_t(a|s)A^{\pi_t}(s,a)}{1-\gamma}$. Let $a^{\star}:=a^*(s)$. Then $\pi_{t+1}(a^\star|s) = \pi_t(a^\star|s)/\mathcal{E}$ with
$$
\mathcal{E} := \sum_{a'}\pi_t(a'|s)\,e^{\Delta_{a'}-\Delta_{a^\star}}.
$$
Under the best-advantage condition, $A^{\pi_t}(s,a^\star) \ge A^{\pi_t}(s,a)$ for all $a$, so $\Delta_{a'} \le \Delta_{a^\star}$ for all $a'$ (all PG coefficients share the same non-negative factor $\eta d^{\pi_t}_\rho(s)/(1-\gamma)$ and $\pi_t(\cdot|s) > 0$; the only term that might flip sign is $A^{\pi_t}(s,\cdot)$, but the best-advantage condition pins $A^{\pi_t}(s,a^\star)$ as the maximum). Hence $e^{\Delta_{a'}-\Delta_{a^\star}}\le 1$ for all $a'$, so
$$
\mathcal{E} \;=\; \sum_{a'}\pi_t(a'|s)\,e^{\Delta_{a'}-\Delta_{a^\star}} \;\le\; \sum_{a'}\pi_t(a'|s) \;=\; 1,
$$
and $\pi_{t+1}(a^\star|s) = \pi_t(a^\star|s)/\mathcal{E} \ge \pi_t(a^\star|s)$. $\square$

**Lemma 6B (Cited as black box: Mei et al. 2020 Lemma 9 / Theorem 5).** There exists a finite time $t_0 \ge 0$ and positive thresholds $\{\tau_s\}_{s\in\mathcal{S}}$ such that for all $t\ge t_0$ and all $s$:

(i) $\pi_t(a^*(s)|s) \ge \tau_s > 0$;

(ii) the best-advantage condition of Lemma 6A holds at state $s$: $A^{\pi_t}(s,a^*(s)) \ge A^{\pi_t}(s,a)$ for all $a$.

The proof uses a supermartingale / Lyapunov construction. We cite this as a black box.

**Combining 6A + 6B ⇒ Standing Hypothesis.** For $t\ge t_0$, Lemma 6B gives (ii), which activates Lemma 6A, so $\pi_t(a^*(s)|s)$ is non-decreasing in $t$. With initial condition $\pi_{t_0}(a^*(s)|s)\ge\tau_s > 0$, we get $\min_{t\ge t_0}\min_s\pi_t(a^*(s)|s) \ge \min_s\tau_s > 0$. For $0\le t < t_0$, softmax is strictly positive at every finite $t$, so $\min_{0\le t<t_0}\min_s\pi_t(a^*(s)|s) > 0$. Taking the smaller of the two gives $c_\infty > 0$. $\square$

**Net:** The *self-contained content* of Step 6 is Lemma 6A (a clean best-advantage-monotonicity lemma, rigorously proved); the *cited content* is Lemma 6B, which is the non-trivial part (finite hitting time + activation of the best-advantage condition). We do not attempt to reproduce Lemma 6B.

---

### Step 7. Descent lemma + NU-Ł ⇒ one-step recursion  *(VALID from round 2; preserved)*

At $\eta = 1/\beta$, (4.10) applied to $\theta_{t+1} = \theta_t + \eta\nabla V^{\pi_t}(\rho)$ gives
$$
V_{t+1} \ge V_t + \eta\|\nabla V_t\|_2^2 - \tfrac{\beta}{2}\eta^2\|\nabla V_t\|_2^2 = V_t + \tfrac{1}{2\beta}\|\nabla V_t\|_2^2, \tag{7.1}
$$
equivalently
$$
\delta_{t+1} \le \delta_t - \tfrac{1}{2\beta}\|\nabla V_t\|_2^2. \tag{7.2}
$$
By NU-Ł (5.2), with $c_*^{(t)} := \min_s\pi_t(a^*(s)|s) \ge c_\infty$,
$$
\|\nabla V_t\|_2^2 \;\ge\; \tfrac{(c_*^{(t)})^2(1-\gamma)^2\rho_{\min}^2}{|\mathcal{S}|}\delta_t^2 \;\ge\; \tfrac{c_\infty^2(1-\gamma)^2\rho_{\min}^2}{|\mathcal{S}|}\delta_t^2. \tag{7.3}
$$
Substituting $\beta = 8/(1-\gamma)^3$ into (7.2):
$$
\delta_{t+1} \le \delta_t - \tfrac{(1-\gamma)^3}{16}\cdot\tfrac{c_\infty^2(1-\gamma)^2\rho_{\min}^2}{|\mathcal{S}|}\delta_t^2 = \delta_t(1 - C\delta_t), \tag{7.4}
$$
with
$$
C := \frac{c_\infty^2\,\rho_{\min}^2\,(1-\gamma)^5}{16|\mathcal{S}|}. \tag{7.5}
$$

**Honest accounting.** $\rho_{\min}^2$ is *retained* in $C$; no hand-wave absorption.

---

### Step 8. Harmonic recursion  *(VALID from round 2; burn-in prose cleaned)*

**Lemma 8.** If $0\le a_{t+1}\le a_t(1-c\,a_t)$ with $c > 0$, $a_0\in(0,1/c]$, then $a_t \le 1/(c\,t)$ for all $t\ge 1$.

**Proof.** From the hypothesis, $a_{t+1}\le a_t$, so $\{a_t\}$ stays in $[0,1/c]$ and $1-ca_t\ge 0$ throughout. If $a_t=0$ for some $t$ the claim holds from that point on. Otherwise, dividing by $a_t a_{t+1}>0$:
$$
\tfrac{1}{a_{t+1}} - \tfrac{1}{a_t} \;=\; \tfrac{a_t-a_{t+1}}{a_t a_{t+1}} \;\ge\; \tfrac{a_t-a_{t+1}}{a_t^2} \;\ge\; c,
$$
using $a_t - a_{t+1} \ge c\,a_t^2$ from the recursion. Telescoping: $1/a_t \ge 1/a_0 + c\,t \ge c\,t$. $\square$

**Burn-in case analysis (direct, no "contradiction").** Set $C_0 := 1/C$. By the monotone-descent consequence $\delta_{t+1}\le\delta_t$ (from (7.1)), $\delta_t$ is non-increasing.

- **Case A: $\delta_0 \le C_0$.** Apply Lemma 8 with $a_t := \delta_t$ to get $\delta_t \le 1/(Ct)$.

- **Case B: $\delta_0 > C_0$.** Let $T_0 := \min\{t\ge 0:\delta_t\le C_0\}$; we show $T_0$ is finite and that after $T_0$, Lemma 8 applies. By (7.2) and (7.3), for any $t < T_0$,
$$
\delta_t - \delta_{t+1} \ge \tfrac{1}{2\beta}\|\nabla V_t\|_2^2 \ge \tfrac{C}{(1-\gamma)^3/16}\cdot \tfrac{(1-\gamma)^3}{16}\delta_t^2 = C\delta_t^2 \ge C\cdot C_0^2 = C_0.
$$
(We used $\delta_t > C_0 = 1/C$ on $\{t < T_0\}$.) So $\delta_t$ decreases by at least $C_0$ per step while $t < T_0$; combined with $\delta_0\le 1/(1-\gamma)$, we get $T_0 \le \lceil(1/(1-\gamma) - C_0)/C_0\rceil$, which is finite. Then $\delta_{T_0} \le C_0$ and Lemma 8 (applied to the shifted sequence $\tilde a_s := \delta_{T_0+s}$) gives $\delta_{T_0+s} \le 1/(Cs)$ for $s\ge 1$, hence $\delta_t \le 1/(C(t-T_0))$ for $t > T_0$. For $t\ge 2T_0$, $t - T_0 \ge t/2$, so $\delta_t \le 2/(Ct)$, preserving the $O(1/(Ct))$ rate with a factor-of-2 slack.

**Verification that Case A holds in practice.** We have $C_0 = 1/C = 16|\mathcal{S}|/(c_\infty^2\rho_{\min}^2(1-\gamma)^5)$. Since $c_\infty\le 1$, $\rho_{\min}\le 1$, $(1-\gamma)^5\le 1$, $C_0 \ge 16|\mathcal{S}|$. Also $\delta_0 \le V^*(\rho) \le 1/(1-\gamma)$. Thus $\delta_0 \le 1/(1-\gamma) \le 16|\mathcal{S}| \le C_0$ whenever $1/(1-\gamma) \le 16|\mathcal{S}|$, i.e., $(1-\gamma)\ge 1/(16|\mathcal{S}|)$ (equivalently $\gamma \le 1 - 1/(16|\mathcal{S}|)$), which holds in every regime of practical interest. In the edge case $\gamma$ extremely close to 1, Case B handles things with a finite burn-in.

**Conclusion of Step 8.** For all $t\ge 1$,
$$
\delta_t \;\le\; \frac{1}{C\,t} \;=\; \frac{16|\mathcal{S}|}{c_\infty^2\,\rho_{\min}^2\,(1-\gamma)^5\,t}. \tag{8.1}
$$

---

### Step 9. Final bound (honest form)  *(fixed; see Issues 1–2)*

From (8.1), the rigorously-derived bound is
$$
\boxed{\;\delta_t \;=\; V^*(\rho) - V^{\pi_{\theta_t}}(\rho) \;\le\; \frac{16\,|\mathcal{S}|}{c_\infty^2\,\rho_{\min}^2\,(1-\gamma)^5\,t}.\;} \tag{9.1}
$$
This is the final statement our derivation supports, with $c_\infty := \inf_{t\ge 0}\min_s\pi_t(a^*(s)|s)$ exactly as in `problem.md` (pure policy-level).

**Remark 9.1 (Reconciliation with `problem.md`'s target — honest).** `problem.md` states a compact target
$$
\delta_t \;\le\; \frac{16|\mathcal{S}|}{c_\infty^2\,(1-\gamma)^6\,t}. \tag{9.2}
$$
Under `problem.md`'s own definition of $c_\infty$, the two bounds (9.1) and (9.2) are **not equivalent**. They differ by a factor of $(1-\gamma)/\rho_{\min}^2$, whose sign relative to $1$ is regime-dependent:
$$
\frac{\text{RHS of (9.1)}}{\text{RHS of (9.2)}} = \frac{(1-\gamma)}{\rho_{\min}^2}.
$$
Specifically, (9.1) implies (9.2) iff $\rho_{\min}^2 \ge (1-\gamma)$, i.e., $\rho_{\min} \ge \sqrt{1-\gamma}$, which is **not** universally true. Counterexample: $|\mathcal{S}| = 100$, $\rho$ uniform ($\rho_{\min} = 0.01$), $\gamma = 0.5$ ($1-\gamma = 0.5$). Here $\rho_{\min}^2 = 10^{-4} \ll 0.5 = 1-\gamma$, and the honest bound (9.1) is 5000× looser than the target (9.2). Hence we do **not** claim to prove (9.2) as written from (9.1) with `problem.md`'s $c_\infty$.

**Remark 9.2 (Reconciliation with Mei et al. 2020 — the target's native convention).** In Mei et al. 2020, Theorem 4, the constant $c_\infty$ appearing in the form $\tfrac{16|\mathcal{S}|}{c_\infty^2(1-\gamma)^6 t}$ is *not* the pure policy-level infimum. Rather, Mei et al.'s definition bundles a *distribution-mismatch coefficient* of the form $\|d^{\pi^*}_\rho/\mu\|_\infty^{-1}$ (for a reference measure $\mu$; typically $\mu=\rho$) into the constant. Under Mei et al.'s convention the target (9.2) form is a correct re-expression of (9.1); under `problem.md`'s convention it is a genuinely different bound. We flag this as a convention discrepancy in `problem.md`'s statement, not an error in our derivation.

**Remark 9.3 (Rate is genuinely $O(1/t)$).** The rate exponent — $1/t$ — is identical under both conventions (9.1) and (9.2); only the multiplicative "constant" (which depends on $|\mathcal{S}|, \gamma, \rho_{\min}, c_\infty$) differs by a horizon/support factor. In particular the asymptotic rate and polynomial-in-$(1-\gamma)^{-1}, c_\infty^{-1}, |\mathcal{S}|, \rho_{\min}^{-1}$ dependence are preserved.

### SymPy verification of Step 9 algebra

```python
import sympy as sp
gamma, c_inf, rho_min, S, t = sp.symbols('gamma c_inf rho_min S t', positive=True)
honest = 16*S / (c_inf**2 * (1-gamma)**5 * rho_min**2 * t)
target = 16*S / ((1-gamma)**6 * c_inf**2 * t)
print(sp.simplify(honest / target))  # = (1-gamma)/rho_min**2
```
Output: `(1 - gamma)/rho_min**2`. So (9.1)/(9.2) $= (1-\gamma)/\rho_{\min}^2$, which is neither uniformly $\ge 1$ nor $\le 1$. Thus (9.1) and (9.2) are incomparable in general. Numerical spot-check at $|\mathcal{S}|=100$, $\rho$ uniform, $\gamma=1/2$: (9.1)-denominator $= c_\infty^2\cdot 10^{-4}\cdot (1/2)^5 = c_\infty^2 \cdot 3.125\times10^{-6}$; (9.2)-denominator $= c_\infty^2\cdot (1/2)^6 = c_\infty^2 \cdot 0.015625$; ratio (9.1)/(9.2) = $5000$, confirming (9.1) is 5000× looser here.

We also verify the Step 7 descent constant: with $\beta = 8/(1-\gamma)^3$ and NU-Ł squared giving $c_\infty^2(1-\gamma)^2\rho_{\min}^2/|\mathcal{S}|$, the combination $\tfrac{1}{2\beta}\cdot\tfrac{c_\infty^2(1-\gamma)^2\rho_{\min}^2}{|\mathcal{S}|} = \tfrac{(1-\gamma)^3}{16}\cdot \tfrac{c_\infty^2(1-\gamma)^2\rho_{\min}^2}{|\mathcal{S}|} = \tfrac{c_\infty^2\rho_{\min}^2(1-\gamma)^5}{16|\mathcal{S}|} = C$, matching (7.5). $\blacksquare$

---

### Summary of the argument (one-liner per step)

1. **PG theorem** (Step 2): $\nabla_{\theta_{s,a}}V^\pi(\rho) = \tfrac{1}{1-\gamma}d^\pi_\rho(s)\pi(a|s)A^\pi(s,a)$.
2. **PDL** (Step 3): $V^*(\rho)-V^\pi(\rho) = \tfrac{1}{1-\gamma}\mathbb{E}_{s\sim d^{\pi^*}_\rho}[A^\pi(s,a^*(s))]$; aggregate $\ge 0$ (no pointwise sign).
3. **Smoothness** (Step 4): $\beta = 8/(1-\gamma)^3$ via $T_a + T_b \le (6+2\gamma)/(1-\gamma)^3 \le 8/(1-\gamma)^3$; descent $V_{t+1}\ge V_t + \tfrac{1}{2\beta}\|\nabla V_t\|^2$ at $\eta = 1/\beta$.
4. **NU-Ł** (Step 5): sign-robust Cauchy–Schwarz on squared quantities, giving $\|\nabla V\|_2 \ge \tfrac{c_\infty(1-\gamma)\rho_{\min}}{\sqrt{|\mathcal{S}|}}\delta$.
5. **$c_\infty > 0$** (Step 6): Standing Hypothesis; Lemma 6A (best-advantage monotonicity) proved self-contained; Lemma 6B (finite hitting time) cited from Mei et al. 2020 Lemma 9.
6. **Recursion** (Step 7): $\delta_{t+1}\le\delta_t(1-C\delta_t)$ with $C = c_\infty^2\rho_{\min}^2(1-\gamma)^5/(16|\mathcal{S}|)$ — all constants honest.
7. **Harmonic** (Step 8): $\delta_t \le 1/(Ct)$ with explicit burn-in case for $\delta_0 > 1/C$.
8. **Final** (Step 9): $\displaystyle\delta_t \le \frac{16|\mathcal{S}|}{c_\infty^2\,\rho_{\min}^2\,(1-\gamma)^5\,t}$, honest under `problem.md`'s $c_\infty$ convention.

**Q.E.D.**

---

## Summary

- **Fixed**: 3 issues (HIGH Step 9 algebra, HIGH Step 9 semantic, MEDIUM Step 6 Lemma split).
- **Option chosen**: **Option A (honest restatement)**. Final boxed bound is
  $$\delta_t \;\le\; \frac{16|\mathcal{S}|}{c_\infty^2\,\rho_{\min}^2\,(1-\gamma)^5\,t}$$
  with `problem.md`'s $c_\infty$ definition verbatim.
- **Confidence**: HIGH.
  - Step 9 algebra SymPy-verified: $(9.1)/(9.2) = (1-\gamma)/\rho_{\min}^2$, explicitly neither $\ge 1$ nor $\le 1$, confirming (9.1) and (9.2) are not equivalent under the problem's $c_\infty$ convention.
  - Step 9 no longer redefines $c_\infty$; the boxed bound uses the problem's definition exactly.
  - Step 6 now cleanly separates self-contained content (Lemma 6A) from cited content (Lemma 6B).
  - Step 7 descent constant and the chain through Step 8 are bit-for-bit the same as the round-2 VALID derivation.
  - No step introduces new algebra; all prior VALID steps (1, 2, 3, 4, 5, 7, 8) are preserved.
- **Remaining caveat**: Lemma 6B (Mei et al. 2020 Lemma 9 finite-hitting-time bootstrap) is cited, not reproduced. This is standard practice for a supermartingale argument of that depth. If a fully-self-contained proof is required, Mei et al. 2020 Section 5.2's Lyapunov argument would need to be imported verbatim (outside the scope of this proof).
