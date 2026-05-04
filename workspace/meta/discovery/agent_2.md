# Discovery Agent 2 Report — Optimization/Convergence Part 2

Eight proofs analyzed; reverse-engineering the human discovery path for each.

---

## Proof 1: OGDA bilinear last-iterate

### 1. The Spark
**failure-of-natural-approach** — vanilla GDA on the simplest minimax problem $\min_x\max_y x^\top Ay$ does not converge (it cycles); the question becomes: what is the smallest modification that produces last-iterate convergence?

### 2. The Key Insight
The crucial leap is identifying the *exact* algebraic identity (E): $\|z_{t+1}\|^2 = \|z_t\|^2 + \|\delta_{t+1}-\delta_t\|^2 - \|\delta_t\|^2$. This is non-obvious because OGDA's three-term update normally gives messy expansions; only by exploiting skew-symmetry $\langle z, F(z)\rangle=0$ AND the linearity $F(z_t)-F(z_{t-1})=F(\delta_t)$ does the cross term collapse into a clean polarization. Prior knowledge: monotone operator language, optimism in OCO. Brute force fails — one must "see" that $F(z_t) = -\delta_{t+1}/\eta - F(\delta_t)$ produces the cancellation.

### 3. The Technique Chain
- Reformulate OGDA as a fixed-point operator with skew-symmetric $B$ (standard, monotone-operator literature).
- Compute $\|z_{t+1}\|^2$ by direct expansion + skew-symmetry zeroing of $\langle z_t, F(z_t)\rangle$ (standard).
- Polarization identity to convert $\langle\delta_{t+1},\delta_t\rangle$ into squares (standard textbook).
- Telescope identity (E) to bound $\sum_t\|\delta_t\|^2$ (non-standard combination).
- Convert "summable differences" to last-iterate decay via weighted sum trick (Tseng-style, adapted from monotone-operator splitting literature).

### 4. The Construction
Not a hard instance proof — analyzes a generic bilinear problem. SKIP.

### 5. The Failure Modes
- **Lyapunov $V_t = \|z_t\|^2 + c\|\delta_t\|^2$ with Cauchy-Schwarz on the cross term**: loses the constant — proof attempt visible in the file shows coefficient $3/4 > 0$ and the analysis collapses. Textbook student picks Young's inequality, but it discards exactly the structure that makes OGDA different from GDA.
- **Trying $V_t = \|z_t-z^*\|^2$ alone**: skew-symmetry shows this is constant for vanilla GDA, so the same iterate-norm Lyapunov gives nothing — the student would conclude OGDA "doesn't converge either".
- **Bounding $\|F(2\delta_t-\delta_{t-1})\|$ via triangle inequality**: introduces $\|\delta_{t-1}\|^2$ that does not telescope cleanly.

### 6. The Discovery Path
1. Observe GDA cycles on bilinear; OGDA empirically converges — *why?*
2. Try $\|z_t\|^2$-style Lyapunov; cross terms $\langle z_t, F(\delta_t)\rangle$ refuse to vanish via Young's inequality.
3. Realize the skew-symmetry forces a specific algebraic form — substitute $F(z_t) = -\delta_{t+1}/\eta - F(\delta_t)$, get the polarization that yields identity (E).
4. Use (E) to bound $\sum\|\delta_t\|^2$, then weighted-sum to extract last-iterate.
5. Verify constants and step-size restriction $\eta\le 1/(4L)$.

### 7. Transferable Patterns
- **Skew-symmetry exploitation template**: when the operator is anti-symmetric, the natural Lyapunov candidate is *not* the iterate norm but the iterate norm plus a difference term, with the cross term canceled via the operator's linearity.
- **Summable-differences-to-last-iterate trick**: showing $\sum\|x_{t+1}-x_t\|^2<\infty$ then using a weighted-sum identity is reusable across many proximal/extragradient analyses.

---

## Proof 2: TD(0) with linear function approximation, $O(1/T)$ convergence

### 1. The Spark
**gap-in-literature** — TD(0) was known to converge asymptotically (Tsitsiklis-Van Roy 1997) but *finite-time* rates remained open until Bhandari-Russo-Singal 2018 / Srikant-Ying 2019 closed it.

### 2. The Key Insight
Recognizing that $A = \mathbb{E}[\phi(s)(\phi(s)-\gamma\phi(s'))^\top]$ has a *symmetric part* satisfying $A_s\succeq(1-\gamma)\Phi^\top D_\pi\Phi\succ 0$ — proved by a Cauchy-Schwarz/Jensen argument exploiting the *stationarity* identity $\sum_s d_\pi(s)P_\pi(s'|s)=d_\pi(s')$. Without this symmetric-part PD bound, TD(0)'s update direction has no descent property at all (it's not a gradient method). The needed prior knowledge is stochastic approximation theory; the leap is realizing that for sample complexity one should *avoid* the ODE method and instead replicate Polyak's MSE recursion proof.

### 3. The Technique Chain
- Decomposition $A = A_s + A_{\rm anti}$ (standard linear algebra).
- Stationary-distribution Cauchy-Schwarz to bound the cross term $\Phi^\top D_\pi P_\pi\Phi$ (non-standard, specific to MDP analysis).
- Error recursion $e_{t+1}=(I-\alpha_t M_t)e_t+\alpha_t\xi_t$ with i.i.d.-sample independence (standard SA template, Robbins-Monro).
- Scalar MSE recursion $v_{t+1}\le(1-2\alpha_t\mu+\alpha_t^2 L^2)v_t+\alpha_t^2\sigma^2$ (standard Polyak-style).
- Lyapunov $w_t=(c+t)v_t$ with invariant $W=4c^2\sigma^2/\rho$ (standard but the right packaging matters).

### 4. The Construction
SKIP — no hard instance.

### 5. The Failure Modes
- **Naive: treat TD(0) as SGD on MSE loss $\|V-\hat V\|^2$**: but TD(0) is not a true gradient — Sutton's "TD-Gammon paradox", semi-gradient. The student is stuck because no convex potential exists.
- **ODE/asymptotic analysis (Tsitsiklis-Van Roy)**: gives convergence but no rate. The student concludes "no rate exists".
- **Direct contraction in $\|\cdot\|_2$**: $\|I-\alpha M\|_2$ can exceed 1 because $M$ is non-symmetric — the student gives up.

### 6. The Discovery Path
1. Question: TD(0) converges, but at what rate?
2. Try treating it as SGD; fail because no gradient structure.
3. Insight: the *expected* update matrix $A$ has positive symmetric part, making $A$ stable in the energy norm even though it's non-symmetric.
4. Replicate Polyak-Ruppert MSE recursion technique, treating the "noise" as $\xi_t$ with i.i.d. independence.
5. Solve scalar recursion via Lyapunov $w_t=(c+t)v_t$.

### 7. Transferable Patterns
- **Symmetric-part-positivity trick**: for any linear stochastic approximation $A\theta=b$, study $A_s=(A+A^\top)/2$ to extract a contraction even when $A$ is non-normal.
- **MSE Lyapunov template**: $w_t=(c+t)v_t$ with invariant set is the cleanest way to convert $v_{t+1}\le(1-c_1/(c+t))v_t+c_2/(c+t)^2$ into $O(1/T)$.

---

## Proof 3: Entropy-regularized NPG linear convergence (variant)

### 1. The Spark
**gap-in-literature** — Cen-Cheng-Chen-Chi-Wei 2020 proved $(1-\eta\tau)$ rate for entropy-regularized NPG; the proof pivots on a Lyapunov inequality whose constants are notoriously fragile to gauge choices in the log-policy. The "spark" is asking: what is the gauge-invariant version that works honestly?

### 2. The Key Insight
Replacing the broken non-gauge-invariant $\|\log\pi-\log\pi^*\|_\infty$ with the **centered seminorm** $\|\xi\|_c = \tfrac12\sup_s(\max_a\xi(s,a)-\min_a\xi(s,a))$. This kills the state-only normalizer term $G^{(k)}(s)$ in the log-policy recursion automatically. The leap is recognizing that log-policy is only defined modulo state-constants, so any Lyapunov norm *must* be invariant on this gauge orbit; the contraction rate one gets is then an honest $1-\eta\tau(1-\gamma)$ rather than the spurious $1-\eta\tau$.

### 3. The Technique Chain
- NPG-as-mirror-descent in probability space — log-policy update $(1-\alpha)\log\pi+\beta Q-\log Z$ (standard, Kakade 2001 / Agarwal et al.).
- Soft Bellman operator $\mathcal{T}_\tau$ as $\gamma$-contraction (standard).
- Gauge-invariance argument — adding state-constants to $\xi$ cancels in $\sum_a\pi(a|s)\xi(s,a)$ when both $\pi$ and $\pi^*$ are normalized (non-standard, the proof's main novelty).
- Lyapunov $\Phi=\|\Delta\|_\infty + C\|\xi\|_c$ with weight $C$ tuned to match cross-coupling coefficients (standard Lyapunov-design, but the obstruction analysis showing $(1-\eta\tau)$ is unattainable is honest).

### 4. The Construction
SKIP — no construction.

### 5. The Failure Modes
- **Use $\|\log\pi-\log\pi^*\|_\infty$ directly**: fails because the normalizer $\log Z(s)$ inflates the seminorm spuriously, giving a factor of 2 in the recursion.
- **Try uniform $\|\cdot\|_2$ on policy iterates**: loses the contractive structure of the soft Bellman operator (which is $\gamma$-contractive in $\|\cdot\|_\infty$ on Q, not in $L^2$ on policies).
- **Push for the original $(1-\eta\tau)$ rate**: the proof carefully shows the two Lyapunov constraints are incompatible without small constant $K$, so the obstruction is structural, not technical.

### 6. The Discovery Path
1. Read Cen et al.'s claim of $(1-\eta\tau)$; try to reproduce.
2. The cross-coupling $K\gamma\tau\alpha\|\xi\|_c$ in the Q-recursion forces the Lyapunov weight to satisfy $C\beta\le\eta\tau\gamma$, which combined with the second constraint requires $K\le\gamma(1-\gamma)(2-\gamma)$ — fails for $\gamma$ close to 1.
3. Switch to the gauge-invariant centered seminorm; the recursion is cleaner but the rate downgrades to $(1-\eta\tau(1-\gamma))$.
4. Honest write-up: prove the slower rate, document the gap.
5. Handle the quadratic h.o.t. via "small-error regime" induction.

### 7. Transferable Patterns
- **Gauge-invariance principle**: when working with quantities defined modulo a group action (here state-constants), choose norms that are gauge-invariant; otherwise contraction estimates are confounded by gauge inflation.
- **Honest-rate template**: when the target rate is unattainable with one's technique, prove the best achievable rate and document the obstruction explicitly.

---

## Proof 4: GDA nonconvex-strongly-concave $O(\kappa^2/\epsilon^2)$

### 1. The Spark
**question-asked** — Lin-Jin-Jordan 2020 ask: what is the iteration complexity of two-time-scale GDA on nonconvex-strongly-concave minimax? The natural single-loop algorithm should match the GD-on-$\Phi$ rate up to $\kappa$ factors.

### 2. The Key Insight
Use **Danskin's theorem** to reduce the analysis to descent on the *envelope* $\Phi(x)=\max_y f(x,y)$, which is $2\kappa L$-smooth (provable from $y^*$ being $\kappa$-Lipschitz), and then introduce a Lyapunov $V_t=\Phi(x_t)+c\delta_t$ that pays for the $y$-tracking error. The non-trivial leap is choosing the *right* Lyapunov weight $c=L/(4\kappa)$ — small enough that the $x$-step descent dominates, large enough that the $y$-step contraction kills the tracking error. Step-size separation $\eta_x=O(1/(\kappa^2 L))$, $\eta_y=O(1/L)$ comes from this constraint.

### 3. The Technique Chain
- Danskin's theorem to differentiate $\Phi$ (standard, classical).
- $\kappa$-Lipschitz of $y^*$ via strong-monotonicity (standard).
- Smoothness $L_\Phi\le 2\kappa L$ via chain rule (standard but key).
- Nesterov co-coercivity for $y$-step contraction $(1-1/\kappa)$ (textbook).
- Lyapunov assembly with constants tuned for two simultaneous inequalities (Lin-Jin-Jordan technique).

### 4. The Construction
SKIP.

### 5. The Failure Modes
- **Try descent on $f(x_t, y_t)$ directly**: $f$ is not bounded below in $y$, so no descent statement. Student gets stuck.
- **Single time scale $\eta_x=\eta_y$**: the $y$-tracking error doesn't decay fast enough; you get $O(\kappa^3/\epsilon^2)$ instead of $\kappa^2$.
- **Forget the Danskin smoothness blow-up**: assuming $\Phi$ is $L$-smooth instead of $2\kappa L$-smooth gives wrong step-size and a non-rigorous proof.

### 6. The Discovery Path
1. Notice GDA without two-time-scale fails; intuit that $y$ must be "fresh".
2. Compute envelope $\Phi$, find it's $\kappa L$-smooth (not $L$).
3. Set up Lyapunov $V=\Phi+c\delta$; the "gradient mismatch lemma" $\|\nabla_x f - \nabla\Phi\|\le L\sqrt\delta$ provides the bridge.
4. Tune $c$, $\eta_x$, $\eta_y$ by solving the two coupled inequalities (i) $x$-descent dominant and (ii) $y$-contraction dominant.
5. Telescope to get $1/T$ rate on $\|\nabla\Phi\|^2$ averaged.

### 7. Transferable Patterns
- **Envelope-based descent template**: in nested optimization, descend on the envelope $\Phi=\max_y f(x,y)$; pay tracking error with a Lyapunov coupling.
- **Two-time-scale Lyapunov coefficient tuning**: the "right" weight is determined by matching the cross-coupling rates.

---

## Proof 5: Softmax PG sublinear convergence $O(1/t)$

### 1. The Spark
**pattern-spotted** — Mei-Xiao-Szepesvari-Schuurmans 2020 spotted that softmax PG, despite the loss being *non-convex* in $\theta$, exhibits a Łojasiewicz-type inequality with a non-uniform constant $c_*=\min_s\pi(a^*(s)|s)$ that nonetheless suffices for $O(1/t)$ convergence.

### 2. The Key Insight
Two intertwined leaps. (a) The **non-uniform Łojasiewicz inequality** $\|\nabla V^\pi\|_2\ge\frac{c_*(1-\gamma)\rho_{\min}}{\sqrt{|\mathcal S|}}\delta$ — proved by sign-robust Cauchy-Schwarz on the squared advantages. (b) The **standing hypothesis $c_\infty>0$** — a non-trivial finite-hitting-time argument shows that under softmax, the optimal-action probability cannot collapse to zero (Lemma 6B). Without (a) you have no descent geometry; without (b) the Łojasiewicz constant could degenerate. The aggregate non-negativity $\sum_s d^{\pi^*}_\rho A^\pi(s,a^*(s))\ge 0$ (without pointwise sign control) is the crucial subtlety the proof carefully handles.

### 3. The Technique Chain
- Policy gradient theorem (standard, Sutton-Barto).
- Performance difference lemma, Kakade-Langford 2002 (standard).
- Smoothness $\beta=8/(1-\gamma)^3$ via second-derivative bookkeeping on $V^{\pi_\theta}$ (technical but standard).
- Sign-robust Cauchy-Schwarz to derive non-uniform Łojasiewicz (non-standard, this paper's innovation).
- Harmonic recursion $a_{t+1}\le a_t(1-ca_t)\Rightarrow a_t\le 1/(ct)$ (textbook).

### 4. The Construction
SKIP.

### 5. The Failure Modes
- **Try standard PL/Łojasiewicz with uniform constant**: fails because softmax allows the gradient to vanish whenever $\pi(a^*|s)\to 0$.
- **Convex relaxation**: softmax PG is fundamentally non-convex, so convex methods give nothing.
- **Pointwise advantage sign assumption**: a textbook student would assume $A^\pi(s,a^*(s))\ge 0$ pointwise — false in general; the proof must use only aggregate non-negativity.

### 6. The Discovery Path
1. Empirically observe softmax PG converges; Theory says it shouldn't (non-convex).
2. Look for a Łojasiewicz-type structure; find it depends on $c_*=\min_s\pi(a^*|s)$.
3. Worry: $c_*$ could degenerate. Prove via finite-hitting-time argument that $c_\infty=\inf_t c_*^{(t)}>0$.
4. Combine smoothness + NU-Ł + descent gives $\delta_{t+1}\le\delta_t(1-C\delta_t)$.
5. Standard harmonic argument finishes.

### 7. Transferable Patterns
- **Non-uniform Łojasiewicz template**: when the loss landscape has degenerate critical points (saddle slopes vanishing), a state-dependent Łojasiewicz constant can still rescue $O(1/t)$ if the iterates avoid the degenerate set.
- **Sign-robust Cauchy-Schwarz**: applying CS to *squared* quantities sidesteps the need for pointwise sign control.

---

## Proof 6: Q-learning UCB-Hoeffding $\tilde O(\sqrt{H^4 SAT})$ regret

### 1. The Spark
**gap-in-literature** — model-free Q-learning was thought to need $\Omega(SA H^2)$ samples per $(s,a,h)$ to be PAC-MDP; Jin-Allen-Zhu-Bubeck-Jordan 2018 closed the gap by showing UCB exploration achieves $\sqrt T$-regret without any model.

### 2. The Key Insight
The **visit-count exchange trick** (Step 6b). After unrolling $Q_h^k$ as a weighted sum over previous visits to $(s,a,h)$, the proof must "exchange" the order of summation: $\sum_k\sum_{i\le n_h^k}\alpha^i_{n_h^k}\phi^{k_i}_{h+1}$ becomes $(1+1/H)\sum_{(s,a)}\sum_j\phi^{e_j}_{h+1}$. The factor $(1+1/H)$ comes from the magical learning-rate identity $\sum_{t\ge i}\alpha^i_t = 1+1/H$ (L4) — provable via a clean telescoping in a beta-function-like sum. Without this trick the recursion $R_h\le \text{const}\cdot R_{h+1}+B_h$ becomes $R_h\le H\cdot R_{h+1}+B_h$ and the final regret blows up to $H^6$ instead of $H^4$.

### 3. The Technique Chain
- Recursive Q-error expansion (Lemma A) — standard induction from Bellman.
- Azuma-Hoeffding on weighted martingale differences (standard).
- Optimism via UCB bonus $b_t=cH^{3/2}\sqrt{\iota/t}$ tuned to dominate noise (this paper's calibration).
- Per-episode regret decomposition $\delta_h^k\le\phi_h^k+\xi_h^k+\delta_{h+1}^k$ (standard).
- The four learning-rate identities (L1)-(L4) — non-standard, this paper's innovation.
- Visit-count exchange (heart of proof).

### 4. The Construction
SKIP.

### 5. The Failure Modes
- **Constant step-size $\alpha_t=\alpha$**: gives biased Q-estimates that don't converge to $Q^*$. Wrong rate.
- **Use $\alpha_t=1/t$ (Robbins-Monro)**: identity (L4) becomes $\sum_t\alpha^i_t=O(\log)$, costing a $\log H$ in the regret per layer = $H^{O(\log)}$ total — wrong scaling.
- **Forget the $(1+1/H)$ factor**: gives $R_h\le H\cdot R_{h+1}$, leading to $H^6$ regret.

### 6. The Discovery Path
1. Question: can Q-learning avoid model-based methods?
2. Try standard UCB analysis; the recursive structure of Bellman makes the noise-accumulation analysis non-trivial.
3. Choose the special step size $\alpha_t=(H+1)/(H+t)$ — discover it makes $\sum_t\alpha^i_t = 1+1/H$ exactly.
4. The identity allows the recursion's contraction factor to be just $(1+1/H)$ per layer; $(1+1/H)^H\le e$, total constant.
5. Optimism + Azuma + visit-count exchange ⇒ $\sqrt{H^4 SAT}$.

### 7. Transferable Patterns
- **Designing step-size for clean recursive identities**: instead of analyzing a generic step size, *choose* the step size to make the cumulative weights satisfy a clean closed-form identity.
- **Layer-wise contraction $(1+1/H)$**: a per-layer factor of $(1+1/H)$ exponentiates to $e$, making horizon-uniform analyses possible.

---

## Proof 7: SVRG non-SC last-iterate has $\Theta(\log m)$ gap

### 1. The Spark
**failure-of-natural-approach** — the textbook claim "SVRG achieves $O(LD^2/(Sm))$ rate" is folklore-stated for the snapshot $\tilde x_S$. The natural question: does the *last iterate* enjoy the same rate? Spoiler: no.

### 2. The Key Insight
Recognize that within an epoch, **conditional on the snapshot**, SVRG's inner loop is *exactly* a non-SC SGD with bounded variance; therefore Harvey-Liang-Liaw-Randhawa's last-iterate vs. average gap of $\Theta(\log m)$ on non-SC SGD applies *verbatim* to SVRG's last iterate. The leap is realizing the snapshot rate (which uses averaging) cannot transfer to the last iterate, *because the same averaging that makes SVRG work also kills the $\log m$ — removing it brings the $\log m$ back*.

### 3. The Technique Chain
- Standard SVRG variance bound $\mathbb{E}_t\|v_t\|^2\le 4L[(f(x_t)-f^*)+(f(\tilde x_s)-f^*)]$ (Reddi 2016 Lemma 3).
- One-step descent + telescoping ⇒ epoch inequality (standard, Allen-Zhu-Yuan 2016).
- Snapshot bound $O(LD^2/(Sm))$ (standard).
- HLL-R 2019 last-iterate-vs-average reduction lemma (cited as black box).
- Hard instance for the lower bound: Huber-type $f_i(x) = (L/2)(x-b_i)_+^2$ + amplification with $c_i$ for non-vanishing variance (constructive).

### 4. The Construction
The hard instance is $f_i(x)=(L/2)(x-b_i)_+^2 + (L/2)(c_i-x)_+^2$ with random signs $b_i,c_i$. The single-Huber construction has variance vanishing at $x_t=\tilde x_s$ (SVRG's variance reduction kills it); adding the $c_i$-piece introduces $O(L^2)$ persistent variance independent of $x_t-\tilde x_s$. This forces SVRG to behave as SGD with constant variance, falling under HLL-R's $\Theta(\log m)$ lower bound.

### 5. The Failure Modes
- **Naive: claim last iterate inherits snapshot rate**: false; the averaging is structural.
- **Use a quadratic hard instance**: SVRG's variance reduction kills the variance at the snapshot, so HLL-R's lower bound doesn't activate.
- **Apply HLL-R directly without the snapshot**: misses the SVRG-specific variance bound (V).

### 6. The Discovery Path
1. Write down SVRG analysis; notice the snapshot rate uses averaging crucially.
2. Conjecture: last iterate is worse. Try a quadratic; SVRG's variance reduction kills the noise — no gap.
3. Insight: need a hard instance where SVRG's variance reduction *fails* to vanish — i.e., the gradient noise must NOT be a function of $x-x^*$. The piecewise-linear Huber + decoupled $c_i$-piece achieves this.
4. Apply HLL-R last-iterate-vs-avg lemma in a black-box manner.
5. Match upper bound (via Lemma 1) and lower bound — both are $\Theta(\log m \cdot LD^2/(Sm))$.

### 7. Transferable Patterns
- **Last-iterate-vs-average gap principle**: any algorithm whose convergence proof relies on averaging is *suspect* at the last iterate; the gap is typically $\Theta(\log m)$ in non-SC settings.
- **Variance-reduction-resistant hard instance template**: to defeat variance reduction, the noise must come from a component *uncorrelated with the iterate*.

---

## Proof 8: Polyak-Ruppert SHB defeats cycling on Goujaud's instance

### 1. The Spark
**question-asked** — Goujaud-Taylor-Dieuleveut 2023 showed SHB's last iterate cycles on a 2D K-gon with $\Theta(LD^2)$ gap forever. The natural question: does *Polyak-Ruppert weighted averaging* break the cycle?

### 2. The Key Insight
The cycling iterate $x_t=(D/\sqrt 2)e_{t\bmod K}$ is a finite Fourier sum; **complexifying** $\mathbb R^2\cong\mathbb C$ via $e_t\leftrightarrow\omega^t$ with $\omega=e^{2\pi i/K}$ converts the weighted average $\sum_t t\,e_t$ into the closed-form arithmetico-geometric sum $\sum_t t\omega^t = \omega(1-(T+1)\omega^T+T\omega^{T+1})/(1-\omega)^2$. The key observation: $|\sum_t t\omega^t|=O(T)$ while the denominator $W_T=T(T+1)/2=\Theta(T^2)$, giving $\|\tilde x_T\|=O(1/T)$ and thus $f(\tilde x_T)-f^*=O(LD^2/T^2)$ — a $T^2$ improvement over the last iterate.

### 3. The Technique Chain
- Reformulation as complex exponential sum (standard, harmonic analysis).
- Arithmetico-geometric closed form $\sum_{t=1}^T tz^t$ (textbook).
- Triangle inequality on the closed form (standard).
- $L$-smoothness gives $f(\tilde x_T)-f^*\le(L/2)\|\tilde x_T\|^2$ (standard).
- Sharpness verification via numerical computation (this paper).

### 4. The Construction
The Goujaud function $f_0(x)=D^2\psi(x/D)$ on a 2D K-gon is *given* — the proof uses it as a black box. The construction's role: it produces an iterate sequence that perfectly tessellates the K-gon, making it the cleanest possible test case for averaging-vs-last-iterate analysis. What breaks if simplified: using a 1D version loses the rotational structure that makes cycling stable; using $K=2$ is a trivial special case where the average is exactly zero.

### 5. The Failure Modes
- **Geometric intuition: "linear weights drag toward later vertices, away from $x^*$"**: false; the denominator $W_T=\Theta(T^2)$ dominates.
- **Try uniform Cesaro**: works ($\Theta(1/T^2)$), but the question was specifically about Polyak-Ruppert.
- **Try to get $\Omega(LD^2/T)$ lower bound for PR via a different hard instance**: the proof shows this is impossible — Fourier cancellation defeats any $K$-periodic instance.

### 6. The Discovery Path
1. Goujaud-Taylor-Dieuleveut 2023 prove SHB's last iterate is stuck.
2. Conjecture: PR averaging will inherit the same lower bound (intuition: linear weights).
3. Compute the closed form via complexification — discover $|\tilde x_T|=O(1/T)$.
4. The intuition was wrong; PR averaging is in fact a strong-bias-correction.
5. Verify numerically; document the $T^2$ separation between last iterate and PR.

### 7. Transferable Patterns
- **Complexification of 2D rotational dynamics**: when iterates lie on a discrete subgroup of the unit circle, complexifying converts averaging into Fourier sums with closed-form bounds.
- **Iterate-type-matters principle**: lower bounds for *one* iterate type (last) need not transfer to other iterate types (Cesaro, PR, exponential moving average).

---

## Three-line summary

- **File written**: `C:/Users/12729/Desktop/Math/workspace/discovery_reports/agent_2.md`
- **Proofs analyzed**: 8 (OGDA bilinear, TD(0) linear FA, entropy-NPG, GDA NC-SC, softmax PG, Q-learning UCB-H, SVRG last-iterate gap, Polyak-Ruppert SHB)
- **Most-interesting cross-cutting observation**: Five of the eight proofs (OGDA, TD(0), softmax PG, Q-learning, Polyak-Ruppert) hinge on a *carefully designed algebraic identity that makes a sum collapse into a closed-form constant* — Identity (E) for OGDA, $A_s\succ(1-\gamma)\Phi^\top D_\pi\Phi$ for TD, sign-robust Cauchy-Schwarz for PG, learning-rate identity (L4) $\sum_t\alpha^i_t=1+1/H$ for Q-learning, arithmetico-geometric sum for SHB. The "discovery" is almost never the choice of algorithm or Lyapunov template, but the discovery of the *one identity* that makes the technique work; conversely, the failure modes are uniformly cases where Young's/Cauchy-Schwarz/triangle inequality is applied prematurely and discards exactly the structure the identity exploits.
