## Proof
**Route**: KL Potential + Gradient Flow + Euler Discretization

We attempt to prove
$$\delta_t := V^*(\rho) - V^{\pi_{\theta_t}}(\rho) \le \frac{16 |\mathcal{S}|}{(1-\gamma)^6 \, c_\infty^2 \, t}$$
by tracking the potential
$$\Psi_t := \sum_s d^{\pi^*}_\rho(s) \, \mathrm{KL}\!\big(\pi^*(\cdot|s) \,\|\, \pi_{\theta_t}(\cdot|s)\big) = -\sum_s d^{\pi^*}_\rho(s) \log \pi_{\theta_t}\!\big(a^*(s)\,\big|\,s\big) \ge 0,$$
where $a^*(s)$ is the (assumed unique) optimal action at $s$.

We will show that Route 3 runs into a concrete structural obstruction at Step 6 (closing the Lyapunov inequality for *vanilla* PG rather than NPG). The derivation up to Step 5 is clean and reusable; the failure at Step 6 is documented explicitly, and a "Route Failure Report" is issued at the end.

---

### Step 1. Setup, notation, basic facts

Fix a finite MDP with $r \in [0,1]$, $\gamma \in [0,1)$, full-support $\rho$. Define
- $V^\pi(s) := \mathbb{E}_\pi\!\big[\sum_{k\ge 0} \gamma^k r(s_k,a_k) \mid s_0 = s\big]\in[0, 1/(1-\gamma)]$,
- $Q^\pi(s,a) := r(s,a) + \gamma \mathbb{E}_{s'\sim P(\cdot|s,a)}[V^\pi(s')]$,
- $A^\pi(s,a) := Q^\pi(s,a) - V^\pi(s)$,
- $d^\pi_\rho(s) := (1-\gamma)\sum_{k\ge 0}\gamma^k\Pr_\pi(s_k=s\mid s_0\sim\rho)$,
- $\delta_t := V^*(\rho) - V^{\pi_{\theta_t}}(\rho)$.

Under softmax parametrization $\pi_\theta(a|s) = e^{\theta_{s,a}} / \sum_{a'} e^{\theta_{s,a'}}$, the Jacobian identity is
$$\frac{\partial \pi_\theta(a|s')}{\partial \theta_{s,b}} = \mathbf{1}\{s=s'\}\, \pi_\theta(a|s)\,\big(\mathbf{1}\{a=b\} - \pi_\theta(b|s)\big). \qquad(\star)$$

The PG update is $\theta_{t+1} = \theta_t + \eta \nabla_\theta V^{\pi_{\theta_t}}(\rho)$ with $\eta = (1-\gamma)^3/8$.

**Standing assumptions throughout** (inherited from Mei–Xiao–Szepesvári–Schuurmans 2020): (i) $a^*(s)$ is unique at every $s$; (ii) $c_\infty := \inf_{t\ge 0}\min_s \pi_{\theta_t}(a^*(s)|s) > 0$; (iii) $\rho_{\min} := \min_s \rho(s) > 0$.

---

### Step 2. Policy gradient theorem (cited)

For softmax tabular, combining $(\star)$ with the standard PG theorem:
$$\frac{\partial V^{\pi_\theta}(\rho)}{\partial \theta_{s,a}} = \frac{1}{1-\gamma}\, d^{\pi_\theta}_\rho(s)\,\pi_\theta(a|s)\, A^{\pi_\theta}(s,a). \qquad(\text{PG})$$

We also use the identity $\sum_a \pi_\theta(a|s) A^{\pi_\theta}(s,a) = 0$ (so shifting $A$ by a state-only baseline leaves PG unchanged).

---

### Step 3. Performance difference lemma (cited)

For any two policies $\pi, \pi'$:
$$V^\pi(\rho) - V^{\pi'}(\rho) = \frac{1}{1-\gamma}\sum_s d^\pi_\rho(s)\sum_a \big(\pi(a|s)-\pi'(a|s)\big)\,Q^{\pi'}(s,a). \qquad(\text{PDL})$$

Applying PDL with $\pi = \pi^*$ (deterministic: $\pi^*(a|s) = \mathbf{1}\{a = a^*(s)\}$) and $\pi' = \pi_{\theta_t}$:
$$\delta_t = \frac{1}{1-\gamma} \sum_s d^{\pi^*}_\rho(s) \Big[ Q^{\pi_t}(s,a^*(s)) - \sum_a \pi_{\theta_t}(a|s)\, Q^{\pi_t}(s,a) \Big]$$
$$= \frac{1}{1-\gamma}\sum_s d^{\pi^*}_\rho(s) \big(A^{\pi_t}\!(s,a^*(s)) - \underbrace{\textstyle\sum_a \pi_{\theta_t}(a|s) A^{\pi_t}(s,a)}_{=0}\big) = \frac{1}{1-\gamma}\sum_s d^{\pi^*}_\rho(s) A^{\pi_t}\!(s,a^*(s)). \quad(\text{PDL}^*)$$

Because $a^*(s)$ is optimal under $V^*$, $A^{\pi_t}(s, a^*(s)) \ge 0$ is not automatic, but in fact $A^{\pi_t}(s,a^*(s)) \ge 0$ is not what is used; instead we note $A^{\pi_t}(s,a^*(s))$ satisfies (from Cauchy–Schwarz on PG; see Step 5)
$$\sum_s d^{\pi^*}_\rho(s) A^{\pi_t}(s,a^*(s)) = (1-\gamma)\,\delta_t \ge 0. \qquad(3.1)$$

---

### Step 4. Continuous-time KL dynamics

Consider the **gradient flow** $\dot\theta_{s,a}(\tau) = \partial V^{\pi_\theta}(\rho)/\partial\theta_{s,a}$ (continuous time $\tau$; we overload $t$ for both continuous and discrete). Writing $\pi_\tau := \pi_{\theta_\tau}$ and using $(\star)$:
$$\dot\pi_\tau(a|s) = \sum_b \frac{\partial \pi_\tau(a|s)}{\partial \theta_{s,b}}\dot\theta_{s,b} = \pi_\tau(a|s)\Big[\dot\theta_{s,a} - \sum_b \pi_\tau(b|s)\dot\theta_{s,b}\Big].$$

Substituting $\dot\theta_{s,b} = \frac{1}{1-\gamma}d^{\pi_\tau}_\rho(s)\pi_\tau(b|s) A^{\pi_\tau}(s,b)$:
$$\dot\pi_\tau(a|s) = \frac{d^{\pi_\tau}_\rho(s)}{1-\gamma}\pi_\tau(a|s)\Big[\pi_\tau(a|s)A^{\pi_\tau}(s,a) - \sum_b \pi_\tau(b|s)^2 A^{\pi_\tau}(s,b)\Big]. \qquad(4.1)$$

Now compute $\dot\Psi_\tau$. Since $\Psi_\tau = -\sum_s d^{\pi^*}_\rho(s)\log\pi_\tau(a^*(s)|s)$ and $d^{\pi^*}_\rho$ does not depend on $\tau$,
$$\dot\Psi_\tau = -\sum_s d^{\pi^*}_\rho(s)\,\frac{\dot\pi_\tau(a^*(s)|s)}{\pi_\tau(a^*(s)|s)}.$$

Using (4.1) at $a = a^*(s)$:
$$\frac{\dot\pi_\tau(a^*(s)|s)}{\pi_\tau(a^*(s)|s)} = \frac{d^{\pi_\tau}_\rho(s)}{1-\gamma}\Big[\pi_\tau(a^*(s)|s)A^{\pi_\tau}(s,a^*(s)) - \sum_b \pi_\tau(b|s)^2 A^{\pi_\tau}(s,b)\Big].$$

Thus
$$\boxed{\; \dot\Psi_\tau = -\frac{1}{1-\gamma}\sum_s d^{\pi^*}_\rho(s)\, d^{\pi_\tau}_\rho(s)\,\Big[\pi_\tau(a^*(s)|s) A^{\pi_\tau}(s,a^*(s)) - \sum_b \pi_\tau(b|s)^2 A^{\pi_\tau}(s,b)\Big]. \;} \qquad(4.2)$$

Writing $p_s := \pi_\tau(a^*(s)|s)$ and grouping, the bracket in (4.2) equals
$$p_s A^{\pi_\tau}(s,a^*(s)) - \sum_b \pi_\tau(b|s)^2 A^{\pi_\tau}(s,b) = p_s(1-p_s)A^{\pi_\tau}(s,a^*(s)) - \sum_{b\ne a^*(s)}\pi_\tau(b|s)^2 A^{\pi_\tau}(s,b). \qquad(4.3)$$

For the off-optimal terms, use $A^{\pi_\tau}(s,b) = A^{\pi_\tau}(s,b) - A^{\pi_\tau}(s,a^*(s)) + A^{\pi_\tau}(s,a^*(s))$ and the constraint $\sum_b \pi_\tau(b|s)A^{\pi_\tau}(s,b)=0$. A cleaner algebraic form: define $\Delta_s(b) := A^{\pi_\tau}(s,a^*(s)) - A^{\pi_\tau}(s,b) \ge 0$ (sign depends on $\tau$). The bracket becomes
$$\text{bracket}(s) = A^{\pi_\tau}(s,a^*(s))\big[p_s - \textstyle\sum_b \pi_\tau(b|s)^2\big] + \sum_b \pi_\tau(b|s)^2 \Delta_s(b). \qquad(4.4)$$

Both terms are *non-negative when* $A^{\pi_\tau}(s,a^*(s)) \ge 0$, which holds for all $s$ (since $a^*(s)$ attains $\max_a Q^{\pi_\tau}(s,a)$ is **not** automatic — this is where the first subtle issue appears).

---

### Step 5. Sign analysis and lower bound on $-\dot\Psi$ (pointwise)

**Claim 5.1.** For every state $s$, $A^{\pi_\tau}(s,a^*(s)) \ge 0$ need not hold; however, one has the following *aggregate* non-negativity:
$$\sum_s d^{\pi^*}_\rho(s)\, d^{\pi_\tau}_\rho(s)\, p_s(1-p_s) A^{\pi_\tau}(s,a^*(s)) \quad\text{is } \ge 0\text{ "on average"}.$$

This statement is not strong enough to conclude $\dot\Psi\le 0$ pointwise in state, *and this is the first fragility of the route*. However, it suffices to use (PDL$^*$) from Step 3 to relate $\dot\Psi$ to $\delta_t$ aggregately — which is exactly what we attempt next.

**Attempted continuation** — Summing (4.2)+(4.4) across states and ignoring the (bounded) off-optimal $\Delta_s$ term (which is *non-negative*, and gives a further decrease of $\Psi$), we obtain the *one-sided* inequality
$$-\dot\Psi_\tau \;\ge\; \frac{1}{1-\gamma}\sum_s d^{\pi^*}_\rho(s)\, d^{\pi_\tau}_\rho(s)\, p_s(1-p_s)\, A^{\pi_\tau}(s,a^*(s)). \qquad(5.1)$$

**Difficulty with signs.** The advantage $A^{\pi_\tau}(s,a^*(s))$ is *not* uniformly non-negative in $s$: while the *policy-averaged advantage* $\sum_a \pi_\tau(a|s) A^{\pi_\tau}(s,a) = 0$, individual entries can be negative. When $V^{\pi_\tau}$ is far from $V^*$, $a^*(s)$ may have negative advantage under $\pi_\tau$ at particular $s$. In that case term (5.1) picks up a negative contribution that cannot be cancelled by the non-negative $\Delta_s$ term without further work.

**Local workaround.** Because $c_\infty > 0$, the lower bound $p_s \ge c_\infty$ is uniform in $s$ and $\tau$. Combined with the easy fact $1 - p_s \le 1$, one has $p_s(1-p_s) \le p_s$ and $p_s(1-p_s) \ge c_\infty(1-p_s)$. Still, the sign issue in $A^{\pi_\tau}(s,a^*(s))$ blocks a clean bound on (5.1) **from below by a positive multiple of $\delta_t$**. What the aggregation (3.1) gives is only
$$\sum_s d^{\pi^*}_\rho(s) A^{\pi_\tau}(s,a^*(s)) = (1-\gamma)\delta_t.$$
But (5.1) has the extra *state-dependent* weight $d^{\pi_\tau}_\rho(s)\, p_s(1-p_s)$ — this weight varies with $s$ and $\tau$, so Cauchy–Schwarz is not enough.

---

### Step 6. Failed attempt to close the Lyapunov loop

We now formally attempt, and fail, to establish a clean inequality of the form $-\dot\Psi_\tau \ge C\cdot \delta_\tau^2$ (the "non-uniform Łojasiewicz for the KL potential").

**Attempt 6.1 (Cauchy–Schwarz via $d^{\pi^*}_\rho$).** By Cauchy–Schwarz in the measure $d^{\pi^*}_\rho$:
$$\delta_\tau^2 = \Big(\frac{1}{1-\gamma}\sum_s d^{\pi^*}_\rho(s) A^{\pi_\tau}(s,a^*(s))\Big)^2$$
$$\le \frac{1}{(1-\gamma)^2} \underbrace{\Big(\sum_s \frac{d^{\pi^*}_\rho(s)}{w_\tau(s)}\Big)}_{=:\,B_\tau} \cdot \Big(\sum_s d^{\pi^*}_\rho(s)\, w_\tau(s)\, A^{\pi_\tau}(s,a^*(s))^2\Big),$$
for any positive weights $w_\tau(s)$. With the natural choice $w_\tau(s) := d^{\pi_\tau}_\rho(s)\, p_s(1-p_s)$ to match (5.1), we get
$$-\dot\Psi_\tau \;\ge\; \frac{1}{1-\gamma}\sum_s d^{\pi^*}_\rho(s)\, w_\tau(s)\, A^{\pi_\tau}(s,a^*(s)) \;\underset{?}{\ge}\; \frac{1}{1-\gamma}\cdot\frac{(1-\gamma)^2 \delta_\tau^2 / B_\tau}{\max_s A^{\pi_\tau}(s,a^*(s))}. \qquad(6.1)$$

The "$?$" is the fundamental issue: we need
$$\sum_s d^{\pi^*}_\rho w A \;\gtrsim\; \Big(\sum_s d^{\pi^*}_\rho A\Big)^2 \big/ \text{(something)}.$$
Going through Cauchy–Schwarz once to upper-bound $\delta_\tau = \frac{1}{1-\gamma}\sum_s d^{\pi^*}_\rho A$ gives
$$\delta_\tau \le \frac{1}{1-\gamma}\sqrt{\sum_s d^{\pi^*}_\rho(s)/w_\tau(s)}\sqrt{\sum_s d^{\pi^*}_\rho(s) w_\tau(s)\, A^{\pi_\tau}(s,a^*(s))^2}. \qquad(6.2)$$

But (5.1) has $A$ linearly, not $A^2$! To *match* linear $A$ in (5.1) with $A^2$ appearing naturally from Cauchy–Schwarz on $\delta_\tau$, we would have to further bound $A$ by $A^2$, which requires $|A^{\pi_\tau}(s,a^*(s))| \le$ constant, then at best
$$\sum_s d^{\pi^*}_\rho w A \ge \frac{1}{\|A\|_\infty}\sum_s d^{\pi^*}_\rho w A^2 \ge \frac{\delta_\tau^2\, (1-\gamma)^2}{\|A\|_\infty\cdot B_\tau}. \qquad(6.3)$$

Plugging $\|A\|_\infty \le 1/(1-\gamma)$ (uniform reward bound) and $B_\tau \le |\mathcal{S}|/(c_\infty^2 \cdot d^{\pi_\tau}_{\rho,\min})$ (from $w_\tau \ge c_\infty^2 d^{\pi_\tau}_{\rho,\min}$):
$$-\dot\Psi_\tau \;\ge\; \frac{(1-\gamma)^2}{1-\gamma}\cdot \frac{\delta_\tau^2\cdot(1-\gamma)}{|\mathcal{S}|/(c_\infty^2 d^{\pi_\tau}_{\rho,\min})} = \frac{(1-\gamma)^2\, c_\infty^2\, d^{\pi_\tau}_{\rho,\min}}{|\mathcal{S}|}\,\delta_\tau^2. \qquad(6.4)$$

Using $d^{\pi_\tau}_\rho(s)\ge (1-\gamma)\rho(s)\ge (1-\gamma)\rho_{\min}$, we could obtain $-\dot\Psi_\tau \ge \frac{(1-\gamma)^3\rho_{\min} c_\infty^2}{|\mathcal{S}|}\delta_\tau^2$.

**However, (6.3) is wrong in general.** The step "$\sum w A \ge \frac{1}{\|A\|_\infty}\sum w A^2$" requires $A\ge 0$ pointwise, which we have already noted does NOT hold. When $A^{\pi_\tau}(s,a^*(s))$ can be negative at some states, the inequality flips sign and fails to yield a one-sided Lyapunov bound.

**Attempt 6.2 (softmax-specific identity).** One might try to use the sharper softmax identity (Mei et al. 2020, Lemma 8):
$$\|\nabla_\theta V^{\pi_\theta}(\rho)\|_2^2 \ge \frac{c_\infty^2}{|\mathcal{S}|}\, (1-\gamma)^2 \delta_\tau^2 \qquad(\text{NU–Łojasiewicz})$$
to relate $\dot\Psi$ to $\|\nabla V\|^2$. Under gradient flow, $\dot V^{\pi_\tau}(\rho) = \|\nabla_\theta V\|_2^2 \ge \frac{c_\infty^2(1-\gamma)^2}{|\mathcal{S}|}\delta_\tau^2$, which implies $\dot\delta_\tau \le -\frac{c_\infty^2(1-\gamma)^2}{|\mathcal{S}|}\delta_\tau^2$, giving $\delta_\tau \le \frac{|\mathcal{S}|}{c_\infty^2(1-\gamma)^2\tau}$. This is Route 1/2 — **not Route 3**: it bypasses the KL potential entirely, using $V^*(\rho)-V^{\pi_\tau}(\rho)$ itself as Lyapunov.

The reduction "$\dot\Psi \lesssim -\delta^2$" we sought for *Route 3* is strictly stronger than the $V$-Lyapunov result, because it would propagate decrease in KL geometry, which under NPG (preconditioned by Fisher information) gives *linear* convergence. The missing piece is precisely that vanilla PG does *not* move in the natural-gradient direction, so the KL potential does not have the clean form $\dot\Psi = -\langle \nabla_\theta\Psi, F^{-1}\nabla_\theta V\rangle$ needed for the closed form.

**Attempt 6.3 (via Pinsker).** Pinsker gives $\|\pi^*(\cdot|s)-\pi_\tau(\cdot|s)\|_{\mathrm{TV}}\le\sqrt{\Psi_\tau(s)/2}$ where $\Psi_\tau(s):= -\log p_s$. Combined with PDL$^*$ and $|A^{\pi_\tau}|\le 1/(1-\gamma)$:
$$\delta_\tau = \frac{1}{1-\gamma}\sum_s d^{\pi^*}_\rho A^{\pi_\tau}(s,a^*(s)) \le \frac{2}{(1-\gamma)^2}\sum_s d^{\pi^*}_\rho\,\|\pi^*(\cdot|s)-\pi_\tau(\cdot|s)\|_{\mathrm{TV}}$$
$$\le \frac{\sqrt{2}}{(1-\gamma)^2}\sum_s d^{\pi^*}_\rho\sqrt{\Psi_\tau(s)} \le \frac{\sqrt{2}}{(1-\gamma)^2}\sqrt{\Psi_\tau}, \qquad(6.5)$$
using Jensen ($\sqrt{\cdot}$ is concave, so $\sum d^{\pi^*}_\rho\sqrt{\Psi_\tau(s)}\le \sqrt{\sum d^{\pi^*}_\rho \Psi_\tau(s)}=\sqrt{\Psi_\tau}$).

So $\Psi_\tau \ge \frac{(1-\gamma)^4}{2}\delta_\tau^2$. This gives us the *wrong-direction* inequality for our Lyapunov argument: we would need $\Psi_\tau \le C\delta_\tau$ or similar, to translate rate of decrease of $\Psi$ into rate of decrease of $\delta$.

Indeed if we had $-\dot\Psi_\tau\ge\alpha\delta_\tau^2$ **and** $\delta_\tau\le\beta\Psi_\tau^{1/2}$ (from Pinsker), we'd get
$-\dot\Psi_\tau\ge\alpha(\delta_\tau^2)\ge\alpha\cdot(\Psi_\tau/\beta^2)$  [**wrong** direction]
or $-\dot\Psi_\tau\ge\alpha\delta_\tau^2$ can be integrated against $\Psi_\tau\ge (1-\gamma)^4\delta_\tau^2/2$ to give... nothing directly.

The correct coupling needs a **reverse Pinsker** $\Psi\le C\delta$, which holds only under smoothness/strong-convexity structure that PG does not provide.

**Conclusion of Step 6.** None of Attempts 6.1–6.3 yield a clean closed-loop Lyapunov inequality of the form $\dot\Psi_\tau\le -f(\Psi_\tau)$ with $\int\!df/f < \infty$ compatible with $O(1/t)$ on $\delta_\tau$.

---

### Step 7. Attempted Euler discretization (would have been the next step)

Had Step 6 succeeded with $-\dot\Psi_\tau\ge \alpha\Psi_\tau^2$ (the clean form needed), the Euler-scheme error bound would have proceeded as follows. With step $\eta = (1-\gamma)^3/8 = 1/\beta$ (smoothness constant), Taylor expanding $\Psi$ along discrete iterates:
$$\Psi_{t+1} - \Psi_t = \eta\langle\nabla_\theta\Psi,\nabla_\theta V\rangle + \tfrac{\eta^2}{2}\langle\nabla_\theta V,\nabla_\theta^2\Psi\,\nabla_\theta V\rangle + O(\eta^3).$$

Computing $\nabla_\theta \Psi$ requires $\partial(-\log\pi_\theta(a^*(s)|s))/\partial\theta_{s,b} = \pi_\theta(b|s)-\mathbf{1}\{b=a^*(s)\}$, so
$$\langle\nabla_\theta\Psi,\nabla_\theta V\rangle = \sum_{s,b} d^{\pi^*}_\rho(s)\big(\pi_\theta(b|s)-\mathbf{1}\{b=a^*(s)\}\big)\cdot \frac{d^{\pi_\theta}_\rho(s)}{1-\gamma}\pi_\theta(b|s)A^{\pi_\theta}(s,b).$$

Using $\sum_b\pi_\theta(b|s)^2 A^{\pi_\theta}(s,b)$ and $\pi_\theta(a^*(s)|s)A^{\pi_\theta}(s,a^*(s))$, this *recovers* (4.2) exactly — good, the discrete dynamics match continuous. But without a clean $-\dot\Psi\ge\alpha\delta^2$ or $-\dot\Psi\ge\alpha\Psi^2$ from Step 6, the Euler error analysis has nothing to be "small compared to".

---

### Step 8/9. Would-have-been harmonic recursion

If $-\dot\Psi_\tau\ge\alpha\Psi_\tau^2$ (continuous), then $\Psi_\tau\le 1/(\alpha\tau)$, and with $\Psi\ge(1-\gamma)^4\delta^2/2$ (6.5 reversed), we'd get $\delta_\tau\le\sqrt{2/((1-\gamma)^4 \alpha\tau)}$, i.e. $O(1/\sqrt{t})$ — *even worse* than the target. The target rate $O(1/t)$ on $\delta$ is incompatible with the $O(1/t)$ rate on $\Psi$ unless $\Psi$ is **linearly comparable** to $\delta$, not only quadratically (6.5). This comparability requires reverse-Pinsker which is false here.

---

## Route Failure Report

- **Route**: KL Potential + Gradient Flow + Euler Discretization
- **Failed at**: Step 6 (closing the Lyapunov loop $-\dot\Psi \ge \alpha\cdot f(\delta,\Psi)$ compatible with the target rate).
- **Obstacle**: Three independent structural issues, each fatal:
  1. **Sign issue**: In (5.1), $A^{\pi_\tau}(s,a^*(s))$ is *not* pointwise non-negative across states, so the seemingly natural descent formula (4.2) does not give a clean sign for $\dot\Psi$. A Cauchy–Schwarz that linearizes $A$ into $A^2$ (Attempt 6.1) requires pointwise $A\ge 0$, which fails.
  2. **Wrong-direction Pinsker**: Pinsker yields $\Psi \ge \frac{(1-\gamma)^4}{2}\delta^2$ (Step 6.3), but the Lyapunov argument needs the *reverse* inequality $\Psi \le C\delta$. A reverse Pinsker holds in exponential-family / natural-parameter settings, but the vanilla-PG direction is not the natural-gradient direction, so the reverse bound has no basis.
  3. **Preconditioning gap**: The KL potential has clean descent precisely for NPG ($\dot\theta = F^{-1}\nabla V$), where $\dot\Psi = -\|\nabla V\|_F^2$ directly (Kakade 2002, Agarwal–Kakade–Lee–Mahajan 2021). For vanilla PG, $\dot\Psi$ involves the *softmax Jacobian* $\pi(1-\pi)$ factors that couple $\Psi$-geometry and $V$-geometry in incompatible ways; these do *not* linearize to a clean quadratic form in $\delta$.

- **Lesson**: The KL potential is a *natural-gradient* Lyapunov. For vanilla PG, the correct Lyapunov is $V^* - V^\pi$ itself (Route 1, using the non-uniform Łojasiewicz inequality of Mei et al. 2020), or the gradient-norm integral bound (Route 2). Any attempt to salvage Route 3 would require re-deriving exactly the non-uniform Łojasiewicz inequality inside the KL machinery, at which point the KL step becomes decorative — Route 3 collapses into Route 1 after unwrapping.

  More fundamentally: the $O(1/t)$ rate for vanilla PG is *slow* precisely because PG lacks the Fisher preconditioning that makes KL a natural Lyapunov. The $c_\infty^2/|\mathcal{S}|$ factor in the final bound is the "penalty" for this missing preconditioning. Since $c_\infty$ depends on the entire trajectory in a non-KL way, a clean KL argument cannot produce it.

- **What was salvaged**: Steps 1–5 provide a clean derivation of the continuous-time KL dynamics (4.2) and the forward-Pinsker bound $\Psi\ge\tfrac{(1-\gamma)^4}{2}\delta^2$ (6.5), which may be useful as building blocks for future NPG-style analyses or for lower-bound constructions. Step 7 shows the Euler-discretization machinery would have gone through had Step 6 closed.

**Recommendation**: Use Route 1 (non-uniform Łojasiewicz + smoothness descent lemma) to establish the $O(1/t)$ bound. Route 3 is *not viable* for the stated target without importing the Route 1 machinery.

Q.E.D. (Route Failure Reported)
