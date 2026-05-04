# Problem 27 — OP-2 Approach 4 Lyapunov Obstruction (No-Go)

## Goal
Prove no Lyapunov-based proof of $O(LD^2/T^2)$ acceleration exists for fixed-momentum SHB on $\mathcal F$.

## Formulation
Suppose $V_t$ is any non-negative function satisfying
$$V_t - V_{t+1} \;\ge\; \delta_t (f(x_t) - f^\star)$$
for some non-negative weights $\delta_t$. Telescoping:
$$\sum_{t=0}^{T-1}\delta_t(f(x_t)-f^\star) \;\le\; V_0 - V_T \le V_0.$$

By non-negativity of the gap, this gives $\min_t (f(x_t)-f^\star) \le V_0/\sum_t\delta_t$. To certify $O(1/T^2)$ on the **last** iterate, we'd need $\delta_t = \Theta(t^2)$ growth so that $\delta_T \cdot (f(x_T)-f^\star)$ dominates and gives $f(x_T)-f^\star \le V_0/\delta_T = O(1/T^2)$ if $V_0=O(1)$.

## Theorem (No-Go)
On Goujaud cycling orbits (i.e., $(\beta,\eta)\in\mathcal F$), the SHB recursion forces any such $\delta_t$ to be **bounded** (independent of $t$), hence $\sum_t\delta_t = O(T)$ and the Lyapunov-certified rate is $\Omega(1/T)$, not $1/T^2$.

## Proof

### Step 1. Cycling orbit structure
On the Goujaud–Taylor–Dieuleveut hard 2D quadratic at $(\beta,\eta)\in\mathcal F$, there exists a periodic orbit $\{(x_t,x_{t-1})\}_{t\ge 0}$ with period $P = P(\beta,\eta)$ (e.g., $P=4$ for the canonical example) such that
- $f(x_{t+P}) = f(x_t)$ for all $t$,
- $f(x_t) - f^\star \ge cLD^2$ for all $t$ (uniformly in $t$),
- iterates do **not** converge.

Existence of such an orbit is the defining property of $\mathcal F$ (Goujaud–Taylor–Dieuleveut 2023, Thm 3).

### Step 2. Lyapunov constraint on the orbit
Suppose $V_t$ is a Lyapunov function as in the hypothesis. By telescoping over one period,
$$V_t - V_{t+P} \ge \sum_{s=t}^{t+P-1}\delta_s(f(x_s)-f^\star) \ge cLD^2 \sum_{s=t}^{t+P-1}\delta_s.$$
Now, if $V_t$ is a function only of the iterate state $(x_t,x_{t-1})$ (which any reasonable Lyapunov should be), then by **periodicity** of the orbit:
$$V_{t+P} = V_t,$$
since the state $(x_{t+P},x_{t+P-1}) = (x_t,x_{t-1})$.

Therefore $V_t - V_{t+P} = 0$, hence
$$0 \ge cLD^2\sum_{s=t}^{t+P-1}\delta_s.$$
This forces $\sum_{s=t}^{t+P-1}\delta_s = 0$, i.e., $\delta_s = 0$ for all $s$ on the orbit.

### Step 3. Implication
$\delta_t = 0$ for all $t$ on the cycling orbit. So $\sum_t\delta_t \cdot \min_t(f(x_t)-f^\star) = 0$, and the Lyapunov telescoping gives **no information**.

This rules out any Lyapunov of the form $V_t = V(x_t,x_{t-1})$ with bound $V_t - V_{t+1}\ge \delta_t(f(x_t)-f^\star)$ on $\mathcal F$.

### Step 4. Generalization to non-state Lyapunovs
What if $V_t$ depends explicitly on $t$? E.g., $V_t = t^2(f(x_t)-f^\star) + \text{stuff}$ as in Nesterov-style Lyapunov.

For Nesterov AGD on convex $f$, the Lyapunov $V_t = t(t+1)(f(x_t)-f^\star)/2 + \tfrac{1}{2}\|z_t-x^\star\|^2$ (with auxiliary $z_t$) satisfies $V_{t+1}\le V_t$, giving $\delta_t = (t+1)(t+2) - t(t+1) = 2(t+1)\sim t$, so $\sum_t\delta_t \sim T^2$, hence $f(x_T)-f^\star\le V_0/\delta_T = O(1/T^2)$.

For this to work on SHB on cycling orbit: we'd need $V_t = w_t(f(x_t)-f^\star) + R_t$ with $w_t\sim t^2$ growth. But:
$$V_t - V_{t+1} = w_t(f(x_t)-f^\star) - w_{t+1}(f(x_{t+1})-f^\star) + R_t - R_{t+1} \ge \delta_t (f(x_t)-f^\star).$$
On the cycling orbit, $f(x_t)-f^\star \approx f(x_{t+1})-f^\star \approx cLD^2$. So
$$(w_t - w_{t+1})\cdot cLD^2 + (R_t - R_{t+1}) \ge \delta_t \cdot cLD^2.$$
With $w_t = t^2$ (the Nesterov scaling), $w_t - w_{t+1} = -(2t+1)$ — **NEGATIVE and growing**! So we'd need $R_t - R_{t+1} \ge (2t+1+\delta_t)cLD^2$, requiring $R_t - R_{t+1}$ to grow linearly in $t$. Telescoping $R_0 \ge \sum_t(2t+1)cLD^2 = T^2 cLD^2$, so $R_0 = \Omega(T^2 LD^2)$.

But $R_0 = R_0$ is a **fixed** quantity, independent of $T$! So the Lyapunov $V_t = t^2(f(x_t)-f^\star)+R_t$ with $R_0$ bounded **cannot exist** on the cycling orbit for arbitrary $T$.

### Step 5. Formalization
**Theorem (No-go)**: Let $V_t$ be any Lyapunov function of the form
$$V_t = w_t(f(x_t)-f^\star) + Q_t(x_t,x_{t-1})$$
with $w_t \ge 0$ deterministic and $Q_t\ge 0$ continuous. Suppose $V_t - V_{t+1} \ge \delta_t(f(x_t)-f^\star)$ for all $t$ on the SHB iterates on the Goujaud instance at $(\beta,\eta)\in\mathcal F$. Then
$$\sum_{t=0}^{T-1}\delta_t = O(T),$$
hence the Lyapunov-certified rate is $\Omega(1/T)$, not $1/T^2$.

**Proof**: On the periodic orbit, $f(x_t)-f^\star \ge cLD^2$ (uniformly), and $Q_t(x_t,x_{t-1}) = Q(x_t,x_{t-1})$ depends only on the orbit state which has period $P$. So $Q_t - Q_{t+P} = 0$ if $Q$ doesn't depend on $t$ explicitly; more generally, $|Q_t - Q_{t+P}|\le \|\partial_t Q\|\cdot P$, bounded.

Telescoping over period:
$$V_t - V_{t+P} = (w_t - w_{t+P})(f(x_t)-f^\star) + (Q_t - Q_{t+P}) \ge cLD^2\sum_{s=t}^{t+P-1}\delta_s.$$
For this to give cumulative $\sum_t\delta_t\to\infty$ as $T\to\infty$, need $w_t - w_{t+P}\to\infty$ (linearly in $t$ at least). But $w_t$ is non-negative, and if $w_t\to\infty$ then $V_t = w_t(f(x_t)-f^\star) + Q_t \ge w_t\cdot cLD^2 \to\infty$. So $V_t$ is unbounded, contradicting $V_T\ge 0$ giving $V_0 \ge \sum\delta_t(\cdots)$ with finite $V_0$.

More precisely: $V_0 \ge \sum_{t=0}^{T-1}\delta_t\cdot cLD^2$, so $\sum\delta_t\le V_0/(cLD^2) = O(1)$, **constant in $T$**!

So $\sum\delta_t = O(1)$, not $O(T)$ as I claimed earlier. This is even **stronger**: the Lyapunov argument cannot certify even $1/T$ on cycling orbits, let alone $1/T^2$.

### Step 6. Reconciliation
The standard Lyapunov argument bounds $\min_t(f(x_t)-f^\star)\le V_0/\sum\delta_t$. On cycling orbit, $\min_t(f(x_t)-f^\star)\ge cLD^2$, and $\sum\delta_t \le V_0/(cLD^2)$ is bounded. So the bound is just $\min_t \le cLD^2$ — trivial.

This is consistent: cycling means no convergence, so no rate at all is certifiable.

## Conclusion (PASS)
**Theorem (Lyapunov No-Go)**: On the Goujaud cycling region $\mathcal F$, no Lyapunov function $V_t = w_t(f(x_t)-f^\star)+Q_t(x_t,x_{t-1})$ with $V_t,w_t,Q_t\ge 0$ and $w_t,Q_t$ bounded at $t=0$ can certify any non-trivial rate (let alone $O(1/T^2)$) for SHB at fixed $(\beta,\eta)\in\mathcal F$ — the cumulative weights $\sum_t\delta_t$ are bounded.

**Status: PASS**.

## Notes
- **Frame**: Adversarial (showed Lyapunov fails on cycling orbit by periodicity).
- **Key insight**: Periodicity of cycling orbit forces $V_t - V_{t+P}=0$, killing any Lyapunov gradient.
- **Connection to P22**: Energy $E_t = (f-f^\star) + c\|m\|^2$ is a special case ($w_t=1$, $Q_t = c\|m_t\|^2$) and fails by the same argument.
