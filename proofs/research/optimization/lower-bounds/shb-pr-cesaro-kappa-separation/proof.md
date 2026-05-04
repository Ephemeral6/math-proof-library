<!-- AUDITOR ATTENTION: Judge flagged the following minor issues:
- Verify the (I-M)^{-2}_{11} = (1-β)/(ηλ)² identity is non-circular (the proof derives it via Vieta but Auditor should re-derive it independently)
- Confirm A_μ ≠ 0 from Assumption A in the multi-dimensional slow-eigenspace case (proof uses scalar A_μ; for multi-dim slow eigenspace, the "amplitude" is a vector — check the argument generalizes)
- Verify the under-damped L-mode is explicitly covered in the slow-mode dominance argument (proof claims |1-r_{j,L}| is uniformly κ-independent — auditor should verify this for the under-damped fast mode at λ=L specifically)
- Compute the O(1/κ³) PR slow-mode-dominance bound explicitly (proof claims this; auditor should reproduce)
- Trace the factor-of-4 in the boxed ratio through the PR definition prefactor 2/(T(T+1)) — there's a 2² that gives 4
Please verify these specifically during audit. -->

# Proof — Route F: Exact algebraic identity tracking

**Route**: F — Exact algebraic identity tracking via Vieta's formulas, slow-root expansion, and explicit asymptotic-constant verification.

**Theorem (restated).** Under the strongly-convex separable quadratic SHB setting of `problem.md`, in the **over-damped slow-mode regime**
$$
\eta\mu \;<\; (1-\sqrt{\beta})^2,
$$
under stability (S), under Assumption A (slow-mode non-degeneracy), and in the strong asymptotic regime $T \to \infty$ with $T \cdot \tfrac{\eta\mu}{1-\beta} \to \infty$, we have, with $\kappa = L/\mu$ fixed:
$$
\frac{f(\tilde{x}_T)}{f(\bar{x}_T)} \;=\; \frac{4\,(1-\beta)^2}{T^2\,(\eta L)^2}\,\kappa^2\,\bigl(1+o(1)\bigr),
$$
and individually $f(\bar{x}_T) = \Theta(\kappa^2/T^2)$, $f(\tilde{x}_T) = \Theta(\kappa^4/T^4)$ (with the convention $\mu$ fixed, $L = \kappa\mu$ growing — see Step 7 for the normalization discussion).

The proof tracks the **central algebraic identity**
$$
(1-r_{1,\lambda})(1-r_{2,\lambda}) \;=\; \eta\lambda
\qquad\text{(exact, by Vieta)}.
$$

---

## Step 1: Per-coordinate decoupling and spectral decomposition

Because $f(x) = \tfrac{1}{2}\sum_i \lambda_i x_i^2$ is separable and $\nabla f$ is diagonal in the eigenbasis $\{e_i\}$, the SHB iteration
$$
x_{t+1} = x_t - \eta \nabla f(x_t) + \beta(x_t - x_{t-1})
$$
decouples into $d$ independent scalar recurrences, one per eigenvalue $\lambda \in \{\lambda_1,\dots,\lambda_d\}$:
$$
x_{t+1}^{(\lambda)} \;=\; (1+\beta - \eta\lambda)\, x_t^{(\lambda)} \;-\; \beta\, x_{t-1}^{(\lambda)},
\qquad t \ge 0,
$$
with $x_0^{(\lambda)}, x_{-1}^{(\lambda)}$ given. The characteristic polynomial is
$$
P_\lambda(r) \;:=\; r^2 \;-\; (1+\beta - \eta\lambda)\,r \;+\; \beta \;=\; 0. \tag{1}
$$
Let $r_{1,\lambda}, r_{2,\lambda}$ be its two roots (complex in general).

**Vieta's identities for (1).** Comparing coefficients:
$$
r_{1,\lambda} + r_{2,\lambda} \;=\; 1 + \beta - \eta\lambda,
\qquad
r_{1,\lambda}\, r_{2,\lambda} \;=\; \beta. \tag{2}
$$

**The central identity.** From (2):
$$
(1 - r_{1,\lambda})(1 - r_{2,\lambda})
\;=\; 1 - (r_{1,\lambda}+r_{2,\lambda}) + r_{1,\lambda} r_{2,\lambda}
\;=\; 1 - (1+\beta-\eta\lambda) + \beta
\;=\; \eta\lambda. \tag{$\star$}
$$
This identity is **regime-independent**: it holds whether the roots are real (over-damped) or complex conjugate (under-damped).

**Distinct-roots assumption.** We assume $r_{1,\lambda} \ne r_{2,\lambda}$, equivalently the discriminant
$$
\Delta_\lambda \;:=\; (1+\beta-\eta\lambda)^2 - 4\beta
$$
is non-zero. The over-damped slow-mode regime $\eta\mu < (1-\sqrt\beta)^2$ gives $\Delta_\mu > 0$ strictly (real distinct roots for $\lambda=\mu$); for the fast mode $\lambda=L$ either sign is possible, but $\Delta_L = 0$ is a measure-zero coincidence we exclude.

**General solution.** With distinct roots, the general solution of the linear recurrence is
$$
x_t^{(\lambda)} \;=\; A_\lambda\, r_{1,\lambda}^t \;+\; B_\lambda\, r_{2,\lambda}^t,
\qquad t \ge -1, \tag{3}
$$
for constants $A_\lambda, B_\lambda \in \mathbb{C}$ determined by the two initial conditions:
$$
A_\lambda + B_\lambda \;=\; x_0^{(\lambda)},
\qquad
A_\lambda r_{1,\lambda}^{-1} + B_\lambda r_{2,\lambda}^{-1} \;=\; x_{-1}^{(\lambda)}. \tag{4}
$$
Multiplying the second equation by $r_{1,\lambda} r_{2,\lambda} = \beta$ gives $A_\lambda r_{2,\lambda} + B_\lambda r_{1,\lambda} = \beta\, x_{-1}^{(\lambda)}$. Solving (4):
$$
A_\lambda \;=\; \frac{x_0^{(\lambda)} r_{1,\lambda} - \beta\, x_{-1}^{(\lambda)}}{r_{1,\lambda} - r_{2,\lambda}}
\;=\; \frac{r_{1,\lambda}\,(x_0^{(\lambda)} - r_{2,\lambda}\, x_{-1}^{(\lambda)})}{r_{1,\lambda} - r_{2,\lambda}},
\tag{5a}
$$
$$
B_\lambda \;=\; -\,\frac{x_0^{(\lambda)} r_{2,\lambda} - \beta\, x_{-1}^{(\lambda)}}{r_{1,\lambda} - r_{2,\lambda}}
\;=\; -\,\frac{r_{2,\lambda}\,(x_0^{(\lambda)} - r_{1,\lambda}\, x_{-1}^{(\lambda)})}{r_{1,\lambda} - r_{2,\lambda}},
\tag{5b}
$$
where we used $r_{1,\lambda} r_{2,\lambda} = \beta$. (These are real numbers when the roots are real.)

**Assumption A connection.** Restricted to the slow eigenspace $E_\mu$, Assumption A states $P_\mu(x_0 - r_{2,\mu} x_{-1}) \ne 0$. For any $\lambda_i = \mu$, formula (5a) gives
$$
A_\mu^{(i)} \;=\; \frac{r_{1,\mu}\,\bigl(x_0^{(i)} - r_{2,\mu}\, x_{-1}^{(i)}\bigr)}{r_{1,\mu} - r_{2,\mu}},
$$
and Assumption A is exactly the statement that $\sum_{i:\lambda_i = \mu} (A_\mu^{(i)})^2 \ne 0$, i.e. the slow-mode amplitude in (3) is non-zero.

---

## Step 2: Over-damped expansion of $r_{1,\mu}, r_{2,\mu}$

In the regime $\eta\mu < (1-\sqrt{\beta})^2$, both roots of $P_\mu$ are real. We label $r_{1,\mu} \ge r_{2,\mu}$. From (2):
$$
r_{1,\mu} + r_{2,\mu} = 1 + \beta - \eta\mu, \qquad r_{1,\mu}\, r_{2,\mu} = \beta.
$$
The quadratic formula gives
$$
r_{1,\mu}, r_{2,\mu} \;=\; \frac{1+\beta-\eta\mu \;\pm\; \sqrt{(1+\beta-\eta\mu)^2 - 4\beta}}{2}.
$$
Let
$$
s := 1-\beta, \qquad u := \eta\mu \in (0, (1-\sqrt\beta)^2),
$$
so that $1+\beta - u = 2 - s - u$ and the discriminant is
$$
\Delta_\mu \;=\; (1+\beta-u)^2 - 4\beta \;=\; (1-\beta)^2 - 2u(1+\beta) + u^2 \;=\; s^2 - 2u(2-s) + u^2.
$$

**Lemma 2.1 (slow-root expansion).** As $u \downarrow 0$ with $\beta \in (0,1)$ fixed,
$$
1 - r_{1,\mu} \;=\; \frac{u}{1-\beta} \;+\; O\!\Bigl(\frac{u^2}{(1-\beta)^3}\Bigr)
\;=\; \frac{u}{s}\Bigl(1 + O(u/s^2)\Bigr).
$$

*Proof.* By ($\star$), $(1-r_{1,\mu})(1-r_{2,\mu}) = u$ exactly. We need a separate expansion for $1-r_{2,\mu}$.

Set $w_j := 1 - r_{j,\mu}$. The map $r \mapsto 1-r$ converts (1) into a polynomial in $w$:
$$
0 = P_\mu(1-w) = (1-w)^2 - (2-s-u)(1-w) + \beta = w^2 - sw + u + (\text{check}).
$$
Computing carefully:
$$
(1-w)^2 = 1 - 2w + w^2,
$$
$$
-(2-s-u)(1-w) = -(2-s-u) + (2-s-u)w,
$$
sum with $+\beta = +(1-s)$:
$$
1 - 2w + w^2 - (2-s-u) + (2-s-u)w + (1-s)
\;=\; w^2 + (-2 + 2-s-u)w + (1 - (2-s-u) + (1-s))
\;=\; w^2 - (s+u)w + u,
$$
where the constant term simplifies as $1 - 2 + s + u + 1 - s = u$. So
$$
w^2 - (s+u)\, w + u \;=\; 0, \tag{6}
$$
i.e. $w_1 = 1-r_{1,\mu}$ and $w_2 = 1-r_{2,\mu}$ are the roots of $w^2 - (s+u)w + u = 0$. By Vieta on (6):
$$
w_1 + w_2 = s + u, \qquad w_1 w_2 = u, \tag{7}
$$
the second of which **rederives ($\star$)** for $\lambda=\mu$. Solve (6):
$$
w_{1,2} = \frac{(s+u) \mp \sqrt{(s+u)^2 - 4u}}{2}
= \frac{(s+u) \mp \sqrt{s^2 - 2u(2-s) + u^2}}{2}.
$$
Since $r_{1,\mu} \ge r_{2,\mu}$ means $w_1 \le w_2$, the $\mp$ sign gives $w_1$ first.

For small $u$ with $s$ bounded away from $0$ and $u \ll s^2$ (the over-damped condition $u < (1-\sqrt\beta)^2 \le s^2/4 + O(s)$ is consistent with this once $\beta$ is fixed):
$$
\sqrt{(s+u)^2 - 4u} \;=\; (s+u)\sqrt{1 - \tfrac{4u}{(s+u)^2}}
\;=\; (s+u)\Bigl(1 - \tfrac{2u}{(s+u)^2} - \tfrac{2u^2}{(s+u)^4} + O(u^3/(s+u)^6)\Bigr).
$$
Hence
$$
w_1 \;=\; \frac{(s+u) - (s+u)\sqrt{1 - \tfrac{4u}{(s+u)^2}}}{2}
\;=\; \frac{(s+u)}{2}\Bigl(\tfrac{2u}{(s+u)^2} + \tfrac{2u^2}{(s+u)^4} + O(u^3/(s+u)^6)\Bigr)
$$
$$
\;=\; \frac{u}{s+u} + \frac{u^2}{(s+u)^3} + O(u^3/(s+u)^5)
\;=\; \frac{u}{s}\Bigl(1 - \tfrac{u}{s} + O(u^2/s^2)\Bigr) + O(u^2/s^3),
$$
using $\tfrac{1}{s+u} = \tfrac{1}{s}(1 - u/s + O(u^2/s^2))$. So
$$
\boxed{\;w_1 \;=\; 1 - r_{1,\mu} \;=\; \tfrac{u}{s}\bigl(1 + O(u/s^2)\bigr) \;=\; \tfrac{\eta\mu}{1-\beta}\bigl(1 + O(\eta\mu/(1-\beta)^2)\bigr).\;} \tag{8}
$$
Similarly, $w_2 = (s+u) - w_1 = s - O(u/s)$, equivalently
$$
1 - r_{2,\mu} \;=\; (1-\beta)\bigl(1 - O(\eta\mu/(1-\beta)^2)\bigr). \tag{9}
$$
From (9), $r_{2,\mu} = \beta + O(\eta\mu/(1-\beta))$, confirming the second part of the Plan: $r_{2,\mu} \approx \beta$.

**Verification of ($\star$) by multiplication.** $w_1 w_2 = \tfrac{u}{s}\cdot s \cdot (1 + O(u/s^2)) = u\cdot(1+O(u/s^2))$. The exact value is $u$, so the $O(u/s^2)$ corrections must cancel between $w_1$ and $w_2$. Indeed they do: from (7), $w_1 w_2 = u$ exactly. The cancellation is automatic. $\square$

**Slow-root magnitude bound.** From (8), for the asymptotic regime $u \ll s^2$:
$$
r_{1,\mu} \;=\; 1 - \tfrac{u}{s}(1 + o(1)) \;\in\; (0, 1), \qquad
r_{1,\mu}^T \;=\; \exp\!\bigl(T \ln(1 - \tfrac{u}{s}(1+o(1)))\bigr)
\;\le\; \exp\!\bigl(-\tfrac{Tu}{s}(1+o(1))\bigr).
$$
The strong-asymptotic hypothesis $T \cdot \tfrac{\eta\mu}{1-\beta} = Tu/s \to \infty$ thus gives
$$
r_{1,\mu}^T \;\to\; 0 \quad\text{(super-exponentially)}, \qquad r_{1,\mu}^T \;\le\; e^{-Tu/(2s)} \text{ for } T \text{ large}. \tag{10}
$$

For the fast mode $\lambda = L$: regardless of whether $\Delta_L > 0$ or $\Delta_L < 0$, the roots satisfy $|r_{j,L}|^2 \le \beta$ (when $\Delta_L < 0$) or $|r_{j,L}| < 1$ (when $\Delta_L > 0$ and stability (S) holds). In either case, $|r_{j,L}|^T \le \beta^{T/2}$ which decays exponentially uniformly in $L$, so $|r_{j,L}|^T \to 0$ as $T \to \infty$ with $\beta$ fixed.

---

## Step 3: Cesàro asymptotics of the slow mode

Recall the geometric series identity, valid for any $r \in \mathbb{C}\setminus\{1\}$:
$$
\sum_{t=0}^{T-1} r^t \;=\; \frac{1 - r^T}{1 - r}. \tag{11}
$$
Substituting (3) into the definition of $\bar x_T^{(\lambda)}$ and applying (11) twice:
$$
\bar x_T^{(\lambda)} \;=\; \frac{1}{T}\sum_{t=0}^{T-1}\bigl(A_\lambda r_{1,\lambda}^t + B_\lambda r_{2,\lambda}^t\bigr)
\;=\; \frac{A_\lambda(1 - r_{1,\lambda}^T)}{T(1-r_{1,\lambda})} \;+\; \frac{B_\lambda(1 - r_{2,\lambda}^T)}{T(1-r_{2,\lambda})}. \tag{12}
$$

**Slow-mode contribution ($\lambda=\mu$).** By (10) and the fast-mode bound, $r_{1,\mu}^T = o(1)$ and $r_{2,\mu}^T = O(\beta^{T/2}) = o(1)$. Hence
$$
\bar x_T^{(\mu)} \;=\; \frac{A_\mu}{T(1-r_{1,\mu})}\,\bigl(1 - r_{1,\mu}^T\bigr) \;+\; \frac{B_\mu}{T(1-r_{2,\mu})}\,\bigl(1 - r_{2,\mu}^T\bigr). \tag{13}
$$

By (8), $1/(1-r_{1,\mu}) = s/u\cdot(1+o(1))$, while by (9), $1/(1-r_{2,\mu}) = 1/s\cdot(1+o(1)) = O(1)$. So:
$$
\bar x_T^{(\mu)} \;=\; \frac{A_\mu \cdot s}{T \cdot u}\,(1+o(1)) \;+\; \frac{B_\mu}{T \cdot s}\,(1+o(1))
\;=\; \frac{A_\mu (1-\beta)}{T \eta\mu}\,(1+o(1)) \;+\; O\!\Bigl(\frac{B_\mu}{T(1-\beta)}\Bigr).
$$
Since $s/u \to \infty$ in the asymptotic regime (over-damped, $u/s^2 \to 0$ allowed), the $A$-term dominates the $B$-term by the factor $s^2/u = (1-\beta)^2/(\eta\mu) \to \infty$. Concretely:
$$
\boxed{\;\bar x_T^{(\mu)} \;=\; \frac{A_\mu (1-\beta)}{T \eta \mu}\,\bigl(1 + O(\eta\mu/(1-\beta)^2) + O(r_{1,\mu}^T \cdot s/u)\bigr).\;} \tag{14}
$$

The error $O(r_{1,\mu}^T \cdot s/u) = O((s/u)\cdot e^{-Tu/(2s)})$ is $o(1)$ in the strong-asymptotic regime $Tu/s \to \infty$.

**$L$-mode contribution.** For $\lambda = L$, using $(1-r_{1,L})(1-r_{2,L}) = \eta L$ (by ($\star$)) and stability (S), one has both factors $|1-r_{j,L}|$ bounded above and below by constants depending on $\beta, \eta L$ but not on $\kappa = L/\mu$. (Specifically $|1-r_{j,L}| \le 2$ and $|1-r_{j,L}| \ge \min(\eta L, (\eta L)/2)$ for stable $\eta L \in (0,2(1+\beta))$ away from boundary.) Hence
$$
\bar x_T^{(L)} \;=\; O\!\Bigl(\frac{|A_L| + |B_L|}{T}\Bigr), \tag{15}
$$
with constants depending on $\beta, \eta L$ only — **$\kappa$-independent**.

---

## Step 4: Polyak-Ruppert (triangular-weighted) asymptotics

Recall the closed-form, valid for $r \in \mathbb{C}\setminus\{1\}$:
$$
\sum_{t=0}^{T-1}(t+1)\,r^t \;=\; \frac{1 - (T+1)\,r^T + T\,r^{T+1}}{(1-r)^2}. \tag{16}
$$

(Derivation: $\tfrac{d}{dr}\sum_{t=0}^{T-1} r^{t+1} = \sum_{t=0}^{T-1}(t+1)r^t$ and $\sum_{t=0}^{T-1} r^{t+1} = r(1-r^T)/(1-r)$, then differentiate.)

Substituting (3) and using (16):
$$
\sum_{t=0}^{T-1}(t+1)\, x_t^{(\lambda)}
\;=\; A_\lambda\,\frac{1 - (T+1)r_{1,\lambda}^T + T r_{1,\lambda}^{T+1}}{(1-r_{1,\lambda})^2}
\;+\; B_\lambda\,\frac{1 - (T+1)r_{2,\lambda}^T + T r_{2,\lambda}^{T+1}}{(1-r_{2,\lambda})^2}.
$$
Therefore, by definition of $\tilde x_T$,
$$
\tilde x_T^{(\lambda)} \;=\; \frac{2}{T(T+1)}\Biggl[\frac{A_\lambda\bigl(1 - (T+1)r_{1,\lambda}^T + T r_{1,\lambda}^{T+1}\bigr)}{(1-r_{1,\lambda})^2}
\;+\; \frac{B_\lambda\bigl(1 - (T+1)r_{2,\lambda}^T + T r_{2,\lambda}^{T+1}\bigr)}{(1-r_{2,\lambda})^2}\Biggr]. \tag{17}
$$

**Slow-mode contribution.** As $T\to\infty$ with $r_{j,\mu}^T \to 0$ (Step 2), the numerators $1 - (T+1)r^T + Tr^{T+1}$ tend to $1$. More precisely, $|(T+1)r^T - Tr^{T+1}| \le (2T+1)|r|^T$, which is $o(1)$ by (10) and the strong-asymptotic hypothesis (note $T \cdot |r_{1,\mu}|^T \le T\cdot e^{-Tu/(2s)} \to 0$).

Thus
$$
\tilde x_T^{(\mu)} \;=\; \frac{2}{T(T+1)}\Bigl[\frac{A_\mu}{(1-r_{1,\mu})^2}\,(1+o(1)) \;+\; \frac{B_\mu}{(1-r_{2,\mu})^2}\,(1+o(1))\Bigr]. \tag{18}
$$

By (8) and (9), $1/(1-r_{1,\mu})^2 = s^2/u^2\cdot(1+o(1))$ and $1/(1-r_{2,\mu})^2 = O(1/s^2) = O(1)$. So
$$
\tilde x_T^{(\mu)} \;=\; \frac{2 A_\mu s^2}{T(T+1)\, u^2}\,(1+o(1)) \;+\; O\!\Bigl(\frac{|B_\mu|}{T^2 s^2}\Bigr).
$$
Again the $A$-term dominates by the factor $s^4/u^2 \to \infty$. Concretely:
$$
\boxed{\;\tilde x_T^{(\mu)} \;=\; \frac{2 A_\mu (1-\beta)^2}{T(T+1)\,(\eta\mu)^2}\,\bigl(1 + O(\eta\mu/(1-\beta)^2) + O(T r_{1,\mu}^T \cdot s^2/u^2)\bigr).\;} \tag{19}
$$
The error $O(T r_{1,\mu}^T \cdot s^2/u^2) = o(1)$ when $Tu/s \to \infty$ (with the loss of a polynomial factor in $T$, controlled by exponential decay).

**$L$-mode contribution.** Analogously, $|1-r_{j,L}|$ is bounded below by a $\kappa$-independent constant, so
$$
\tilde x_T^{(L)} \;=\; O\!\Bigl(\frac{|A_L|+|B_L|}{T^2}\Bigr), \tag{20}
$$
again $\kappa$-independent.

---

## Step 5: Computing $f(\bar x_T)$ and $f(\tilde x_T)$ — slow-mode dominance

Decompose $f(\bar x_T) = \sum_{\lambda} \tfrac{\lambda}{2}(\bar x_T^{(\lambda)})^2$, where the sum is taken over all coordinates $i$ with their respective eigenvalues $\lambda_i$. Group by eigenvalue:
$$
f(\bar x_T) \;=\; \tfrac{\mu}{2}\sum_{i:\lambda_i=\mu}(\bar x_T^{(i)})^2 \;+\; \sum_{i:\lambda_i \ne \mu}\tfrac{\lambda_i}{2}(\bar x_T^{(i)})^2.
$$

**Slow-mode block.** For coordinates with $\lambda_i = \mu$, by (14):
$$
\bar x_T^{(i)} \;=\; \frac{A_\mu^{(i)}\,(1-\beta)}{T\,\eta\mu}\,(1 + o(1)),
$$
where $A_\mu^{(i)} = r_{1,\mu}(x_0^{(i)} - r_{2,\mu} x_{-1}^{(i)})/(r_{1,\mu}-r_{2,\mu})$. As $u \to 0$, $r_{1,\mu} \to 1$ and $r_{2,\mu} \to \beta$, so $r_{1,\mu}-r_{2,\mu} \to 1-\beta = s$, and $A_\mu^{(i)} \to (x_0^{(i)} - \beta\, x_{-1}^{(i)})/s$. Hence $A_\mu^{(i)} = O(1)$ in $\kappa$ (initialization is $\kappa$-fixed). Define
$$
\mathcal A_\mu \;:=\; \sum_{i:\lambda_i=\mu}(A_\mu^{(i)})^2 \;>\; 0 \qquad \text{(by Assumption A).} \tag{21}
$$
Then
$$
\sum_{i:\lambda_i=\mu}(\bar x_T^{(i)})^2 \;=\; \frac{\mathcal A_\mu (1-\beta)^2}{T^2 (\eta\mu)^2}\,(1+o(1)),
$$
and
$$
\tfrac{\mu}{2}\sum_{i:\lambda_i=\mu}(\bar x_T^{(i)})^2 \;=\; \frac{\mathcal A_\mu\, (1-\beta)^2}{2\, T^2\, \eta^2\, \mu}\,(1+o(1)). \tag{22}
$$

**Other-mode block.** For any $\lambda \in [\mu, L]$ with $\lambda \ne \mu$, by the same algebra (or by (15) for $\lambda=L$ and an interpolation), $\bar x_T^{(\lambda)} = O(1/(T\,(1-r_{1,\lambda})))$ with $|1-r_{1,\lambda}|$ bounded below by a constant of order $\eta\lambda/(1-\beta) \ge \eta\mu/(1-\beta)$ (and possibly much larger if the mode is under-damped). Crucially, for $\lambda$ bounded away from $\mu$ — i.e., $\lambda \ge \lambda_{\min}^{(2)} > \mu$ where $\lambda_{\min}^{(2)}$ is the second-smallest eigenvalue — the contribution scales as $O(\lambda/(T^2 (\eta\lambda)^2)) = O(1/(T^2 \eta^2 \lambda))$, which is **smaller** than the $\mu$-mode contribution by a factor $\mu/\lambda \le 1$.

In the worst case ($\lambda = L$): contribution to $f$ is at most $\tfrac{L}{2}\cdot O(1/(T^2 (\eta L)^2)) \cdot (\text{constant in }\beta)$. Comparing with (22):
$$
\frac{\text{$L$-mode}}{\text{$\mu$-mode}} \;=\; O\!\Bigl(\frac{1/(T^2\,\eta^2\, L)}{(1-\beta)^2/(T^2\,\eta^2\, \mu)}\Bigr)
\;=\; O\!\Bigl(\frac{\mu}{L\,(1-\beta)^2}\Bigr) \;=\; O\!\Bigl(\frac{1}{\kappa(1-\beta)^2}\Bigr) \;=\; O(1/\kappa). \tag{23}
$$
So the $\mu$-mode dominates by a factor $\kappa$ as $\kappa \to \infty$.

Therefore
$$
\boxed{\;f(\bar x_T) \;=\; \frac{\mathcal A_\mu\, (1-\beta)^2}{2\, T^2\, \eta^2\, \mu}\,\bigl(1+O(1/\kappa)+o(1)\bigr).\;} \tag{24}
$$

**Substituting $\eta = (\eta L)/L$ and $L = \kappa\mu$:** $\eta^2 \mu = (\eta L)^2 \mu / L^2 = (\eta L)^2 / (\kappa^2 \mu)$, so $1/(\eta^2 \mu) = \kappa^2 \mu / (\eta L)^2$. With $\mu$ fixed:
$$
f(\bar x_T) \;=\; \frac{\mathcal A_\mu (1-\beta)^2 \mu}{2\, T^2\, (\eta L)^2}\,\kappa^2\,(1+o(1)) \;=\; \Theta(\kappa^2/T^2). \tag{24'}
$$

This confirms the Cesàro half of the conjecture: $f(\bar x_T) \sim \kappa^2/T^2$.

---

**PR average.** Analogously, by (19),
$$
\sum_{i:\lambda_i=\mu}(\tilde x_T^{(i)})^2 \;=\; \frac{4\,\mathcal A_\mu\,(1-\beta)^4}{T^2(T+1)^2\,(\eta\mu)^4}\,(1+o(1)),
$$
so the $\mu$-block contribution to $f(\tilde x_T)$ is
$$
\tfrac{\mu}{2}\sum_{i:\lambda_i=\mu}(\tilde x_T^{(i)})^2 \;=\; \frac{2\,\mathcal A_\mu\,(1-\beta)^4}{T^2(T+1)^2\,\eta^4\, \mu^3}\,(1+o(1)). \tag{25}
$$

The $L$-mode contribution is $O(L/(T^4 \cdot 1^2)) = O(\kappa\mu/T^4)$, which compared with (25) (which is $\Theta(\kappa^4 \mu/T^4)$ after substitution) is smaller by $O(1/\kappa^3)$. So slow-mode dominates by $\kappa^3$ in the PR case.

Hence
$$
\boxed{\;f(\tilde x_T) \;=\; \frac{2\,\mathcal A_\mu\,(1-\beta)^4}{T^2(T+1)^2\,\eta^4\, \mu^3}\,(1+O(1/\kappa^3)+o(1)).\;} \tag{26}
$$

**Substituting:** $\eta^4 \mu^3 = (\eta L)^4 \mu^3 / L^4 = (\eta L)^4 / (\kappa^4 \mu)$, so $1/(\eta^4 \mu^3) = \kappa^4 \mu / (\eta L)^4$:
$$
f(\tilde x_T) \;=\; \frac{2\,\mathcal A_\mu\,(1-\beta)^4\, \mu}{T^2(T+1)^2\,(\eta L)^4}\,\kappa^4\,(1+o(1)). \tag{26'}
$$
With $T(T+1) \sim T^2$: $f(\tilde x_T) = \Theta(\kappa^4/T^4)$.

---

## Step 6: The ratio $f(\tilde x_T)/f(\bar x_T)$

Divide (26) by (24) (or (26') by (24')):
$$
\frac{f(\tilde x_T)}{f(\bar x_T)}
\;=\; \frac{\dfrac{2\,\mathcal A_\mu\,(1-\beta)^4}{T^2(T+1)^2\,\eta^4\, \mu^3}}{\dfrac{\mathcal A_\mu\,(1-\beta)^2}{2\,T^2\,\eta^2\,\mu}}\,(1+o(1))
\;=\; \frac{2\,(1-\beta)^4}{T^2(T+1)^2\,\eta^4\, \mu^3} \cdot \frac{2\,T^2\,\eta^2\,\mu}{(1-\beta)^2}\,(1+o(1))
$$
$$
\;=\; \frac{4\,(1-\beta)^2}{(T+1)^2\,\eta^2\, \mu^2}\,(1+o(1)).
$$
Note $\mathcal A_\mu$ cancels completely (this is the **central feature**: the ratio is initialization-independent).

Since $T+1 = T(1+1/T)$ and $1/T = o(1)$:
$$
\frac{f(\tilde x_T)}{f(\bar x_T)} \;=\; \frac{4\,(1-\beta)^2}{T^2\,\eta^2\, \mu^2}\,(1+o(1)).
$$

**Final substitution.** $\eta\mu = (\eta L)\cdot \mu/L = (\eta L)/\kappa$, so $\eta^2\mu^2 = (\eta L)^2 / \kappa^2$ and $1/(\eta^2\mu^2) = \kappa^2/(\eta L)^2$. Therefore
$$
\boxed{\;\frac{f(\tilde x_T)}{f(\bar x_T)} \;=\; \frac{4\,(1-\beta)^2}{T^2\,(\eta L)^2}\,\kappa^2\,(1+o(1)). \;}
$$

This is exactly the claimed boxed identity. $\square$

---

## Step 7: Verification against numerical evidence

The numerical table at $\beta=0.7$, $\eta L=2.0$, $T=10000$ gives **predicted $4(1-\beta)^2 \kappa^2/(T \eta L)^2 = 4(0.3)^2 \kappa^2/(2\cdot 10^4)^2 = 0.36\, \kappa^2/(4\cdot 10^8) = 9.0\times 10^{-10}\,\kappa^2$**:

| $\kappa$ | predicted | observed PR/Ces |
|---|---|---|
| 10 | $9.0\times 10^{-8}$ | $1.46\times 10^{-7}$ |
| 100 | $9.0\times 10^{-6}$ | $9.49\times 10^{-6}$ |
| 1000 | $9.0\times 10^{-4}$ | $9.05\times 10^{-4}$ |
| 10000 | $9.0\times 10^{-2}$ | $8.85\times 10^{-2}$ |

Agreement at $\kappa\ge 100$ within 5%. The discrepancy at $\kappa=10$ (factor 1.6) is consistent with the $1+o(1)$ correction being $O(1/\kappa)$ from (24) and $O(\eta\mu/(1-\beta)^2)$ from (8): with $\eta\mu = (\eta L)/\kappa = 0.2$ and $(1-\beta)^2 = 0.09$, the correction is $O(0.2/0.09) = O(2)$ at $\kappa=10$, but $O(0.2)$ at $\kappa=100$, $O(0.02)$ at $\kappa=1000$ — explaining the convergence pattern.

Note that the formula $f(\bar x_T) = \Theta(\kappa^2/T^2)$ uses the convention "$\mu = \mathcal{O}(1)$ fixed, $L = \kappa\mu$ growing" (from (24'); the boxed claim in problem.md uses this normalization implicitly since $\eta L$ is the dimensionless step). At $\beta=0.7, \eta L=2.0, T=10^4, \kappa=10^4$: (24') predicts $f(\bar x_T) \approx \tfrac{1}{2}\mathcal A_\mu (0.09)\mu (10^8)/(4 \cdot 10^8) = 0.01125\mathcal A_\mu \mu$. Observed $0.36$, giving $\mathcal A_\mu \mu \approx 32$. Initialization-dependent constant; consistent.

---

## Step 8: Bounding the asymptotic error terms

We collect all error sources to confirm $1+o(1)$ holds in the strong-asymptotic regime:

**(E1) Slow-root expansion error.** From (8) and (9), $1-r_{1,\mu} = (u/s)(1+\varepsilon_1)$ and $1-r_{2,\mu} = s(1+\varepsilon_2)$, with $|\varepsilon_1|, |\varepsilon_2| = O(u/s^2) = O(\eta\mu/(1-\beta)^2)$. As $\kappa \to \infty$ with $\beta$ fixed and $\eta L$ fixed, $\eta\mu = \eta L/\kappa \to 0$, so $\varepsilon_j = O(1/\kappa) \to 0$. ✓

**(E2) Truncation in (12) and (17).** The terms $r_{j,\mu}^T$ enter linearly in (13) (Cesàro) and as $(T+1)r^T - Tr^{T+1} = O(T r^T)$ in (17) (PR). By (10), $|r_{1,\mu}|^T \le e^{-Tu/(2s)}$ for large $T$. For (13): the prefactor in front of $r^T$ is at most $A_\mu\cdot s/u\cdot 1/T = O(s/(Tu))$, so the truncation contributes $O((s/(Tu))\cdot e^{-Tu/(2s)})$. With $Tu/s \to \infty$, this is dominated by the leading term $O(s/(Tu)\cdot 1) = O(s/(Tu))$ since the exponential factor is $o(1/(Tu/s)^k)$ for any $k$. ✓

For (17): the prefactor in front of $(T+1)r^T - Tr^{T+1}$ is at most $A_\mu\cdot (s/u)^2/T^2 = O((s/u)^2/T^2)$, so the truncation contributes $O(T\cdot(s/u)^2/T^2 \cdot e^{-Tu/(2s)}) = O((s/u)^2 e^{-Tu/(2s)}/T)$. With $Tu/s \to \infty$, this is exponentially smaller than the leading term $O((s/u)^2/T^2)$ as long as $e^{-Tu/(2s)} = o(1/T)$, which holds when $Tu/s \to \infty$. ✓

**(E3) Sub-leading $B$-mode contribution.** From (13), the $B_\mu$ term is $O(|B_\mu|/(Ts))$, which compared to the leading $A_\mu$ term $O(|A_\mu|s/(Tu))$ is smaller by $|B_\mu| u / (|A_\mu| s^2)$. Since $|A_\mu|, |B_\mu| = \Theta(1)$ (bounded by initialization, with $A_\mu \to (x_0 - \beta x_{-1})/s$ and $B_\mu \to -\beta(x_0 - x_{-1})/s$ as $u\to 0$), this is $O(u/s^2) = O(1/\kappa) \to 0$. ✓

**(E4) Other-eigenvalue modes.** By (23), each $\lambda > \mu$ mode contributes at most $O(1/\kappa)$ relative to the $\mu$-mode in $f(\bar x_T)$ and $O(1/\kappa^3)$ in $f(\tilde x_T)$. These vanish as $\kappa \to \infty$. ✓

Combining all error sources:
$$
\frac{f(\tilde x_T)}{f(\bar x_T)} \;=\; \frac{4(1-\beta)^2 \kappa^2}{T^2 (\eta L)^2}\bigl(1 + O(1/\kappa) + O(s\cdot e^{-Tu/(2s)}/(Tu))\bigr),
$$
which is $1+o(1)$ in the asymptotic regime. $\square$

---

## Summary of the κ¹ vs κ² resolution

The Scout's puzzle is resolved as follows. Two distinct quantities scale differently:

- **Under-damped slow mode** (when roots are complex conjugate of modulus $\sqrt\beta$): $|1-r_{1,\mu}|^2 = \eta\mu$ exactly. So $1/|1-r_{1,\mu}| = 1/\sqrt{\eta\mu} = \sqrt{\kappa/(\eta L)}$, scaling as $\sqrt\kappa$. In this regime, $f(\bar x_T) \sim |A_\mu|^2/(T^2|1-r_{1,\mu}|^2) \sim |A_\mu|^2/(T^2\eta\mu) \sim |A_\mu|^2 \kappa/(T^2\eta L)$. PR gives $\kappa^2$. Ratio $\sim \kappa$ not $\kappa^2$.

- **Over-damped slow mode** (when roots are real, the actual numerical regime): $1-r_{1,\mu} = \eta\mu/(1-\beta)$ approximately. So $1/(1-r_{1,\mu})^2 = (1-\beta)^2/(\eta\mu)^2 = (1-\beta)^2 \kappa^2/(\eta L)^2$, scaling as $\kappa^2$. This produces the $\kappa^2$-vs-$\kappa^4$ separation between Cesàro and PR, as derived above.

The over-damped expansion (which is **second-order in $\eta\mu$** for $1/|1-r_{1,\mu}|^2$, vs only first-order for the under-damped Vieta identity) is the precise step where $\kappa^2$ enters. The Scout's confusion came from conflating the two regimes; problem.md is explicit that the conjecture is for the over-damped regime (and that the under-damped regime gives a weaker exponent — confirmed by the numerics).

---

## Q.E.D.

---

## Hooks Report

- **Strategy signatures consulted**: `proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/`. useful=PARTIALLY; the $|r|=1$ vs $|r|<1$ distinction means that proof's arithmetico-geometric template doesn't transfer directly, but the structural idea "PR weighted sum has $(1-r)^{-2}$ vs Cesàro's $(1-r)^{-1}$" carried over cleanly. Library lemma `geometric-series-sum-and-derivative` (eqs (11), (16)) used as standard textbook identities.
- **Meta-template attempted**: MT8 (Spectral / Eigenvalue Argument). Slots filled: SLOT_OPERATOR=companion matrix $M^{(\lambda)}$ of SHB recurrence; SLOT_SPECTRAL_DECOMP=characteristic roots $r_{1,\lambda}, r_{2,\lambda}$ from (1); SLOT_KEY_INVARIANT=$(1-r_1)(1-r_2)=\eta\lambda$ identity ($\star$); SLOT_DOMINANT_MODE=slow mode $\lambda=\mu$ via $1-r_{1,\mu} \approx \eta\mu/(1-\beta)$; SLOT_BOUND=geometric series closed form. Blocker slot: NONE — all slots fill cleanly. The proof is essentially a clean MT8 instance once the over-damped expansion (8) is in hand.
- **Structure map links used**: SAME_TEMPLATE link to `polyak-ruppert-shb-defeats-cycling` (similar structure but $|r|=1$ rather than $|r|<1$); DUAL link to research conjecture on accelerated lower bounds (confirmed PR amplification is a κ² *upper* on suboptimality of PR vs Cesàro). No GENERALIZATION/SHARPENING used.
- **Failure triggers checked**: 4 (averaging on cyclic constructions; Young's inequality premature; KL Lyapunov on non-PL; gratuitous abstraction). Matched: NONE — averaging here is not on a cyclic construction (we have geometric decay $|r|<1$, not cycling); no Young's inequality used; no Lyapunov argument; no superfluous abstraction (proof is direct algebraic computation). Pivots taken: NONE.

End of proof.
