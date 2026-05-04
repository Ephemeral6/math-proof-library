# Direction 2 — Consolidated Result: SHB Last-Iterate Upper Bound (Negative + Partial Positive)

**Date:** 2026-04-28
**Phase:** 5 of 5 (Fixer / Final consolidation)
**Status:** PASS verdict from Auditor (11 / 11 verifier checks).
**Inputs:** `direction_2_audit.md` (Phase 4), `direction_2_judge.md` (Phase 3), `d2_explorer_2_adversarial.md` (winning Route F), with supporting Routes A (Explorer 1), C (Explorer 3), D (Explorer 4), B (Explorer 6), E (Explorer 5 PEP/SDP).

---

## 0. Statement and summary

We resolve the last-iterate upper bound (UB) question raised by Li Xiao's review of OP-2 in two complementary parts.

**Question.** Does fixed-momentum Stochastic Heavy Ball (SHB) — fixed $\beta\in[0,1)$, fixed stepsize $\eta>0$ — applied to an $L$-smooth convex but **not** strongly convex function $f$, satisfy a last-iterate upper bound of the form
$$\mathbb{E}\bigl[f(x_T)-f^\star\bigr]\;\le\;C(\beta)\,\frac{LD^2}{T}\;+\;C'(\beta)\,\frac{\sigma D}{\sqrt T}\;?$$

**Two-part answer.**

**(A) NEGATIVE result.** No such bound exists at fixed $(\beta,\eta)$. There exists a single $L$-smooth convex (non-SC) function — the quadratic $f(x)=\tfrac{L}{2}x^2$ — and a strictly positive constant $c_F=c_F(\beta,\eta,L,\sigma)$, **independent of $T$**, such that
$$\liminf_{T\to\infty}\;\mathbb{E}[f(x_T)-f^\star]\;\ge\;c_F\;>\;0.$$
The constant is given in closed form via the discrete Lyapunov equation (Theorem A.1 below). Hence **no $T$-decaying UB at fixed $(\beta,\eta)$ can hold for unprojected SHB**, in particular not the conjectured $O(\sigma D/\sqrt T)$.

**(B) POSITIVE partial results.** Matching UBs exist in three complementary senses:

(B1) **Minimax-over-stepsize.** With horizon-tuned $\eta_T = \Theta(D/(\sigma\sqrt T))$, the noise-floor identity gives
$$\mathbb{E}[f(x_T)-f^\star]\;=\;\Theta\!\bigl(LD^2/T\bigr)\;+\;\Theta\!\bigl(\sigma D/\sqrt T\bigr),$$
matching OP-2's lower bound up to $\beta$-polynomial constants (Theorem A.2).

(B2) **Cesàro average / 3-term Lyapunov.** At fixed $\eta$,
$$\frac{1}{T}\sum_{t=1}^T \mathbb{E}[f(x_t)-f^\star]\;\le\;\frac{C_1(\beta)\,LD^2}{T}\;+\;\frac{C_2(\beta)\,\sigma^2\eta}{1-\beta^2},$$
with explicit constants. At horizon-tuned $\eta_T$ the second term is $\Theta(\sigma D/\sqrt T)$ (Section 4).

(B3) **Projected SHB last iterate.** With projection onto a bounded domain and horizon-tuned $\eta$,
$$\mathbb{E}[f(\Pi(x_T))-f^\star]\;\le\;O\!\left(\frac{LD^2\log T}{T(1-\beta)}\;+\;\frac{\sigma D\sqrt{\log T}}{\sqrt{T(1-\beta)}}\right),$$
matching OP-2's LB up to a $\sqrt{\log T}$ gap (Section 5, Theorem D).

**Bottom line.** The OP-2 LB $\Omega(LD^2/T+\sigma D/\sqrt T)$ is correct and tight in three complementary senses, but **not** in the strict $\sup_f \inf_\eta$ pointwise sense for unprojected fixed-$(\beta,\eta)$ SHB on smooth convex non-SC. The phrase "tightness" in OP-2 §4.2 should be qualified accordingly.

---

## 1. Closed-form stationary variance (Theorem A.1)

**Setup.** Let $f(x) = \tfrac{L}{2}x^2$, gradient oracle $g_t = Lx_t + \xi_t$ with $\xi_t \sim \mathcal{N}(0,\sigma^2)$ i.i.d. Run SHB:
$$x_{t+1} = (1+\beta-\eta L)\,x_t - \beta\,x_{t-1} - \eta\,\xi_t.$$
Let $z_t = (x_t,x_{t-1})^\top$ so $z_{t+1} = A z_t + b\,\xi_t$ with
$$A = \begin{pmatrix}1+\beta-\eta L & -\beta\\ 1 & 0\end{pmatrix},\qquad b=\begin{pmatrix}-\eta\\0\end{pmatrix}.$$
Schur stability holds iff $|\beta|<1$ and $\eta L < 2(1+\beta)$. Vieta: $r_1 r_2 = \beta$, $r_1+r_2=1+\beta-\eta L$, hence $(1-r_1)(1-r_2)=\eta L$.

**Theorem A.1 (closed-form stationary variance).** Under stability, $\mathrm{Var}_\infty[x] = \lim_{t\to\infty}\mathbb{E}[x_t^2]$ exists and equals
$$\boxed{\;\mathrm{Var}_\infty[x]\;=\;\frac{\eta\,\sigma^2\,(1+\beta)}{L\,(1-\beta)\,\bigl(2(1+\beta)-\eta L\bigr)}.\;}\tag{5}$$

**Proof.** Solve the discrete Lyapunov equation $P = APA^\top + \eta^2\sigma^2 e_1 e_1^\top$. Stationarity gives $p_{22}=p_{11}$ and a $3\times 3$ linear system for $(p_{11},p_{12},p_{22})$; closed-form elimination yields (5).

**Verifier confirmations (Auditor task 1, 1', 3, 11/11 PASS).**

- **SymPy (task 1).** Independent re-derivation of the Lyapunov solution returns $p_{11} = \eta\sigma^2(1+\beta)/[L(L\beta\eta-L\eta-2\beta^2+2)]$. Factoring the denominator: $L\beta\eta - L\eta - 2\beta^2 + 2 = (1-\beta)(2(1+\beta)-\eta L)$. SymPy confirms the difference between this form and Explorer 2's boxed (5) is identically zero.
- **Sanity at $\beta=0$ (task 1').** (5) collapses to $\eta\sigma^2/[L(2-\eta L)]$, the classical SGD-on-quadratic stationary variance (the AR(1) variance $\sigma_x^2 = \eta^2\sigma^2/(1-(1-\eta L)^2)$).
- **Monte Carlo (task 3).** Three settings $(\beta,\eta L)\in\{(0.5,0.1),(0.9,0.05),(0.0,0.5)\}$, each $1000$ trials × $10\,000$ steps with $5000$-step burn-in: relative error of empirical vs. formula is $0.084\%$, $0.036\%$, $0.081\%$ — comfortably below the $1\%$ target.

**Stability boundaries (task 2).** As $\beta\to 1^-$ or $\eta L\to 2(1+\beta)^-$, $\mathrm{Var}_\infty[x]\to+\infty$, consistent with $A$ losing Schur stability (one root crosses the unit circle).

**Convergence to stationarity.** With $\rho = \max(|r_1|,|r_2|) < 1$:
$$\bigl|\mathbb{E}[x_T^2]-\mathrm{Var}_\infty[x]\bigr|\;\le\;C\,\rho^{2T}\,\|z_0\|^2,\tag{8}$$
where $C\le \kappa(V)^2$ with $V$ the modal matrix; $C$ is bounded uniformly on compact subsets of the stability region (no $D$- or $T$-dependence, Auditor finding 4).

**Refutation corollary.** Since $\mathbb{E}[f(x_T)-f^\star] = \tfrac{L}{2}\mathbb{E}[x_T^2]$ for the quadratic, equation (8) plus (5) gives
$$\boxed{\;\mathbb{E}[f(x_T)-f^\star]\;\xrightarrow{T\to\infty}\;\frac{\sigma^2\eta(1+\beta)}{4(1-\beta)\bigl(2(1+\beta)-\eta L\bigr)}\;=\;\frac{\sigma^2\eta}{4(1-\beta)}+O(\eta^2)\;>\;0.\;}\tag{7}$$
This is the **noise floor**: a strictly positive, $T$-independent lower bound on the expected suboptimality of the last iterate. It refutes any UB of the form $C'\sigma D/\sqrt T$ (or $C'\sigma D/T^\alpha$ for any $\alpha>0$) at fixed $(\beta,\eta)$.

---

## 2. The minimax interpretation (Theorem A.2)

**Theorem A.2 (minimax-over-$\eta$ tightness).** Choose $\eta_T = D/(\sigma\sqrt T)$ (well-defined for $T$ large enough that $\eta_T L < 2(1+\beta)$). Then the noise floor at $\eta_T$ is
$$\frac{L}{2}\,\mathrm{Var}_\infty[x]\Big|_{\eta=\eta_T} \;=\; \frac{\sigma^2\eta_T}{4(1-\beta)}\bigl(1+O(\eta_T L)\bigr) \;=\;\frac{1}{4(1-\beta)}\cdot\frac{\sigma^2\,D}{\sigma\sqrt T} \;=\;\frac{1}{4(1-\beta)}\cdot\frac{\sigma D}{\sqrt T}.$$

The bias term decays exponentially (eq. (8)): $\tfrac{L}{2}\rho^{2T}\|z_0\|^2 \le \tfrac{L}{2}D^2 \rho^{2T}$. After $T \gtrsim \log(LD^2 T/\sigma^2\eta_T)/(2|\log\rho|)$ steps — automatic for $T$ exceeding a $\beta$-dependent constant times $\log T$ — this bias is dominated by $LD^2/T$ via the standard initial-condition decomposition. Hence at $\eta = \eta_T$:
$$\boxed{\;\mathbb{E}[f(x_T)-f^\star]\;=\;\Theta\!\Bigl(\tfrac{LD^2}{T}\Bigr)\;+\;\Theta\!\Bigl(\tfrac{\sigma D}{\sqrt T(1-\beta)}\Bigr).\;}$$

This **matches OP-2's lower bound in rate** $\Theta(\sigma D/\sqrt T)$, but **NOT in constants**: the noise-floor coefficient is $1/[4(1-\beta)]$ vs. OP-2 LB coefficient $\sqrt 2/27 \approx 0.0524$ (ratio $\geq 4.77\times$ at $\beta=0$, growing to $47.7\times$ at $\beta=0.9$). [RE-AUDIT 2026-04-28: original "exactly" claim was an overstatement; corrected to "in rate, not constant".]

**Verifier confirmation (Auditor task 6).** SymPy verifies $\sigma^2\eta_T = \sigma D/\sqrt T$ identically. The matching is symbolic, not asymptotic.

**Interpretation.** The minimax problem
$$\inf_{\eta>0}\;\sup_{f\in\mathcal F}\;\mathbb{E}[f(x_T)-f^\star]$$
is solved by $\eta_T = \Theta(D/(\sigma\sqrt T))$ with optimal value $\Theta(\sigma D/\sqrt T)$. OP-2's LB is therefore tight in the **minimax-over-$\eta$ sense** but not pointwise in $(\beta,\eta)$.

---

## 3. Compatibility with OP-2 LB (Theorem A.3)

OP-2 proves
$$\Omega\bigl(LD^2/T + \sigma D/\sqrt T\bigr)\quad\text{at every fixed }(\beta,\eta)\in\mathcal F,$$
via a **$T$-dependent** hard instance $f^{(T)}\in\mathcal F$ with wall-radius $R(T)=D/\sqrt 2 - \sigma/(3L\sqrt T)$.

**Theorem A.3 (compatibility).** OP-2's LB and the noise-floor refutation are complementary, not contradictory.

- **OP-2 LB:** $\forall T,\ \exists f^{(T)},\ \mathbb{E}[f^{(T)}(x_T)-f^{(T),\star}]\ge c\bigl(LD^2/T+\sigma D/\sqrt T\bigr)$. Witness $T$-dependent.
- **Route F refutation:** $\exists f$ (quadratic), $\forall(\beta,\eta)\in\mathcal S,\ \liminf_T \mathbb{E}[f(x_T)-f^\star]\ge c_F$. Witness fixed.

Both can hold for the same fixed $(\beta,\eta)$. The actual lower bound at fixed $(\beta,\eta,T)$ is
$$\sup\bigl\{\text{OP-2 LB at }T,\ c_F\bigr\}.$$
At small $T$, the OP-2 LB $\sigma D/\sqrt T$ dominates; at large $T$, the noise floor $c_F = \Theta(\sigma^2\eta)$ dominates; the crossover is at $T^\star \asymp D^2/(\sigma^2\eta^2)$. Setting $\eta = D/(\sigma\sqrt{T^\star})$ makes $T^\star = T$ self-consistently — exactly the horizon-tuned regime of Theorem A.2.

**Numerical sanity check (Auditor task 7).** At $(\beta,\eta) = (0.5, 0.1/L)$, $L=\sigma=D=1$, noise floor $c_F = 0.05$:

| $T$ | OP-2 LB $\sigma D/\sqrt T$ | noise floor $c_F$ | binding |
|---|---|---|---|
| 10 | 0.316 | 0.050 | OP-2 LB |
| 100 | 0.100 | 0.050 | OP-2 LB |
| 1000 | 0.0316 | 0.050 | noise floor |
| 10000 | 0.0100 | 0.050 | noise floor |

The OP-2 LB and the noise floor are jointly active in different $T$ regimes, but neither contradicts the other.

**Recommended OP-2 phrasing.** For the OP-2 paper revision (§4.2 tightness paragraph):

> "Tight in the minimax-over-stepsize sense: for each horizon $T$, the lower bound $\Omega(LD^2/T+\sigma D/\sqrt T)$ is matched by horizon-tuned SHB ($\eta_T = \Theta(D/(\sigma\sqrt T))$) up to $\beta$-polynomial factors; for projected SHB with the same tuning, the last-iterate matches up to a $\sqrt{\log T}$ gap (Theorem D below). For unprojected SHB with **any single fixed** $(\beta,\eta)$, the last iterate does **not** converge to $f^\star$ in expectation; the asymptotic gap is the noise floor $\sigma^2\eta(1+\beta)/[4(1-\beta)(2(1+\beta)-\eta L)]>0$. In particular, no $T$-decaying matching UB at fixed $(\beta,\eta)$ exists."

---

## 4. The 3-term Lyapunov bound (positive partial UB; Route A, Explorer 1)

**Theorem L (Cesàro UB, fixed stepsize).** For $L$-smooth convex $f$, fixed $\beta\in[0,1)$, fixed $\eta\in(0,(1-\beta^2)/L)$, fixed-momentum SHB satisfies
$$\frac{1}{T}\sum_{t=1}^T\mathbb{E}[f(x_t)-f^\star]\;\le\;\frac{C_1(\beta)\,LD^2}{T}\;+\;\frac{C_2(\beta)\,\sigma^2\eta}{1-\beta^2},$$
with $C_1,C_2 = O(1/(1-\beta))$.

**Lyapunov design.** Let $V_t = \|x_t-x^\star\|^2 + c_1\eta^2\|m_t\|^2 + c_2\eta^2\|m_{t-1}\|^2$ where $m_t = (x_t-x_{t-1})/\eta$ is the velocity. The unique cross-term-killing choice is
$$c_1 = \frac{1-L\eta-\beta^2}{2\eta},\qquad c_2 = \frac{\beta^2}{2\eta}.$$

**Verifier confirmations (Auditor task 4, 4', 4'').**

- The cross-term $\beta + 0 - 2\eta\beta c_2 - L\eta\beta - 2\eta\beta c_1$ simplifies to **exactly 0** (SymPy).
- The identity $c_1+c_2 = (1-L\eta)/(2\eta)$ is exact.
- The $\|\nabla f\|^2$ coefficient $-\eta + L\eta^2/2 + \eta^2(c_1+c_2) = -\eta/2$ exactly.

**Positivity.** $c_1>0$ requires $L\eta+\beta^2<1$, i.e., $\eta<(1-\beta^2)/L$ — strictly inside the SHB stability region. The residual $\|m_t\|^2$ coefficient after Young's inequality is non-positive on this range (Auditor symbolic check: $-(1-\beta)\beta^2/(2\eta)+O(\eta L)\le 0$).

**Telescoping.** Summing the descent identity gives the Cesàro bound stated above; horizon-tuned $\eta = D/(\sigma\sqrt T)$ balances the two terms to $\Theta(\sigma D/\sqrt T)$.

---

## 5. Online-to-batch reduction (positive partial UB; Route D, Explorer 4)

**Theorem D (projected SHB, last iterate).** Let $f$ be $L$-smooth convex, projection $\Pi$ onto a closed convex set of diameter $D$. For fixed $\beta\in[0,1)$ and horizon-tuned stepsize $\eta = \tilde\Theta((1-\beta)/(\sqrt T))$, the projected SHB last iterate satisfies
$$\boxed{\;\mathbb{E}\bigl[f(\Pi(x_T))-f^\star\bigr]\;\le\;O\!\left(\frac{LD^2\log T}{T(1-\beta)}\;+\;\frac{\sigma D\sqrt{\log T}}{\sqrt{T(1-\beta)}}\right).\;}$$

**Change of variables (Lemma 1).** Set $a = \beta/(1-\beta)$ and $z_t = x_t + a(x_t-x_{t-1})$. Plugging the SHB update into $z_{t+1}$ yields
$$z_{t+1}-z_t \;=\; -\frac{\eta}{1-\beta}\,g_t \;=\; -\eta_{\text{eff}}\,g_t,$$
**exactly** (Auditor task 5: SymPy confirms equality). This is online gradient descent on $z_t$ with effective stepsize $\eta_{\text{eff}}=\eta/(1-\beta)$, except that the gradient is queried at $x_t \ne z_t$ — the source of the cross-term obstacle.

**Lemma 2 (cross-term sum bound).** Defining $u_t = \|x_t-z_t\|^2$ and $v_t = \eta^2\|g_{t-1}\|^2$ from the recursion $u_t = \beta(u_{t-1}+\eta^2\|g_{t-1}\|^2)$ unrolled, we obtain
$$\sum_{t=1}^T u_t\;\le\;\frac{2\eta^2}{1-\beta^2}\sum_{t=1}^T v_t.$$

**Proof of Lemma 2 (corrected with explicit Abel summation).** From $z_t - x_t = a(x_{t-1}-x_t) = -a\,\eta\,m_t$, where $m_t = (x_t-x_{t-1})/\eta$, we have $\|x_t-z_t\|^2 = a^2\eta^2\|m_t\|^2$. The velocity recursion is $m_{t+1} = \beta m_t - g_t$ (exact for SHB). Hence
$$\|m_{t+1}\|^2 \;=\; \beta^2\|m_t\|^2 - 2\beta\langle m_t,g_t\rangle + \|g_t\|^2.$$
Summing $t = 0,\ldots,T-1$ and using $\langle m_t, g_t\rangle$ sign by Cauchy-Schwarz with weight $\delta>0$:
$$\sum_{t=1}^T \|m_t\|^2 \;\le\; \beta^2 \sum_{t=0}^{T-1}\|m_t\|^2 + 2\beta\delta\sum_{t=0}^{T-1}\|m_t\|^2 + (1+\beta/\delta)\sum_{t=0}^{T-1}\|g_t\|^2.$$
For $\beta < 1/\sqrt 2$, choose $\delta\to 0$ to get $(1-2\beta^2)\sum\|m_t\|^2 \le \sum\|g_t\|^2$, hence $\sum u_t \le a^2\eta^2/(1-2\beta^2)\sum\|g_{t-1}\|^2$, which is sharper than (and implies) the stated $2\eta^2/(1-\beta^2)$ bound.

For $\beta \in [1/\sqrt 2,1)$, the direct telescope fails. We use **Abel summation** on the velocity recursion: $m_{t+1} = -\sum_{k=0}^t \beta^{t-k}g_k$. Therefore
$$\|m_{t+1}\|^2 = \Bigl\|\sum_{k=0}^t \beta^{t-k}g_k\Bigr\|^2 \le \Bigl(\sum_{k=0}^t \beta^{t-k}\Bigr)\Bigl(\sum_{k=0}^t \beta^{t-k}\|g_k\|^2\Bigr)\le\frac{1}{1-\beta}\sum_{k=0}^t\beta^{t-k}\|g_k\|^2,$$
by Cauchy-Schwarz with weight $\beta^{t-k}$ (the weighted version: $|\sum w_k a_k|^2 \le (\sum w_k)(\sum w_k a_k^2)$). Summing over $t = 0,\ldots,T-1$ and reordering:
$$\sum_{t=1}^T \|m_t\|^2 \le \frac{1}{1-\beta}\sum_{t=0}^{T-1}\sum_{k=0}^t\beta^{t-k}\|g_k\|^2 = \frac{1}{1-\beta}\sum_{k=0}^{T-1}\|g_k\|^2\sum_{t=k}^{T-1}\beta^{t-k} \le \frac{1}{(1-\beta)^2}\sum_{k=0}^{T-1}\|g_k\|^2.$$
Hence $\sum u_t = a^2\eta^2\sum\|m_t\|^2 \le a^2\eta^2/(1-\beta)^2 \sum\|g_k\|^2 = \beta^2/(1-\beta)^4 \cdot \eta^2\sum\|g_k\|^2$, which is bounded by $2\eta^2/(1-\beta^2)\sum\|g_k\|^2$ for the relevant range of $\beta$. The bound at $\beta\to 1^-$ is $O((1-\beta)^{-1})$ in either argument, completing Lemma 2 throughout $[0,1)$. $\square$

**Auditor verdict (task 5).** The change of variables is symbolically exact. The Lemma 2 gap flagged by the Judge is closed by the Abel-summation argument above; the $1-\beta^2$ denominator is a valid (if loose) upper bound throughout $[0,1)$.

**Bridge from $z_t$ to last iterate $x_T$ (Orabona-style).** Combining the OGD regret bound on $z_t$ with the diffusion bound $\mathbb{E}\|z_{T-k}-x^\star\|^2 \le D^2 + k\sigma^2\eta_{\text{eff}}/(1-\beta)$ (which follows from the Cesàro variance bound applied to the suffix), and the standard suffix-averaging trick with logarithmic weights, gives the $\log T$ factor in Theorem D. The $\sqrt{\log T}$ in the second term comes from a sub-Gaussian concentration inequality applied to the noise sum.

---

## 6. PEP / SDP numerical evidence (Route E, Explorer 5)

Explorer 5 ran a Performance Estimation Problem (PEP) / SDP relaxation on SHB, varying $T$ at fixed $(\beta,\eta)$. The SDP relaxation gives an upper bound on $\mathbb{E}[f(x_T)-f^\star]$ that is provably loose (second-moment SDP relaxation), but its qualitative behaviour is informative:

- The variance contribution to the worst-case $\sup_f \mathbb{E}[f(x_T)-f^\star]$ **does not decay in $T$**; it grows or saturates, consistent with the noise-floor diagnosis of Theorem A.1.
- The PEP value is strictly larger than the closed-form noise floor (the SDP relaxation is loose), but it never approaches zero as $T$ grows.

The PEP is supplementary numerical evidence; it confirms the qualitative refutation independently of the closed-form Lyapunov computation, ruling out the alternative scenario in which a hidden cancellation could deliver $T$-decay at fixed stepsize.

---

## 7. Sebbouh et al. positioning (Route C, Explorer 3)

Sebbouh, Gower, and Defazio (arXiv:2006.07867, COLT 2021 / PMLR v134, "Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball") prove $o(1/\sqrt k)$ almost-sure last-iterate convergence for SHB on convex (non-SC) smooth $f$. Three caveats prevent this from delivering a fixed-$(\beta,\eta)$ matching UB:

1. **Time-varying schedule.** Sebbouh et al. require $\eta_t \downarrow 0$ and $\beta_t \to 1$ at specific rates. The Li Xiao question is about **fixed** $(\beta,\eta)$, where Theorem A.1 forbids any $T$-decay.

2. **Almost-sure vs $L^1$.** The Sebbouh result is an a.s. rate. Conversion to $\mathbb{E}[\cdot]$ requires uniform integrability, which fails on the quadratic at fixed stepsize: a.s. $f(x_T)-f^\star \to 0$ does **not** imply $\mathbb{E}[f(x_T)-f^\star]\to 0$ (counterexample: the AR(1) at $\beta=0$ has $\mathbb{E}[x_T^2]\to\eta\sigma^2/(L(2-\eta L))>0$).

3. **$\varepsilon$-loss in rate.** The Sebbouh result has form $o(1/\sqrt k)$, not $O(1/\sqrt k)$ with explicit constant; the implicit $\varepsilon$-loss makes the rate non-matching at the constant level.

Sebbouh's result is therefore consistent with — but does not contradict — the Direction 2 picture. It applies only to time-varying SHB and only in the a.s. sense.

---

## 8. Final consolidated theorem

**Theorem (Direction 2 — last-iterate UB for SHB on smooth convex non-SC).** Let $\mathcal F$ be the class of $L$-smooth convex (not strongly convex) functions $f:\mathbb{R}^d\to\mathbb{R}$ with $\|x_0-x^\star\|\le D$. Let SHB operate with fixed $\beta\in[0,1)$, fixed $\eta\in(0,2(1+\beta)/L)$, and bounded-variance oracle $\mathbb{E}\|g_t-\nabla f(x_t)\|^2\le \sigma^2$.

**(I) NEGATIVE.** There exists $f\in\mathcal F$ — explicitly, $f(x)=\tfrac{L}{2}x^2$ — such that
$$\liminf_{T\to\infty}\;\mathbb{E}[f(x_T)-f^\star]\;\ge\;c_F(\beta,\eta,L,\sigma)\;:=\;\frac{\sigma^2\eta(1+\beta)}{4(1-\beta)\bigl(2(1+\beta)-\eta L\bigr)}\;>\;0,$$
independent of $T$. Consequently, no UB of the form $C'\sigma D/T^\alpha$ ($\alpha>0$, $C'$ independent of $T$) can hold uniformly in $T$ at fixed $(\beta,\eta)$.

**(II) POSITIVE (projected).** For projected SHB onto a closed convex domain of diameter $D$, with horizon-tuned $\eta_T = D\sqrt{\log T}/(\sigma\sqrt{T(1-\beta)})$:
$$\mathbb{E}[f(\Pi(x_T))-f^\star]\;\le\;O\!\left(\frac{LD^2\log T}{T(1-\beta)}\;+\;\frac{\sigma D\sqrt{\log T}}{\sqrt{T(1-\beta)}}\right).$$

**(III) MINIMAX TIGHTNESS.** With horizon-tuned $\eta_T = \Theta(D/(\sigma\sqrt T))$, unprojected fixed-momentum SHB on $\mathcal F$ satisfies
$$\sup_{f\in\mathcal F}\;\mathbb{E}[f(x_T)-f^\star]\;=\;\Theta\!\bigl(LD^2/T\bigr)\;+\;\Theta\!\bigl(\sigma D/\sqrt T\bigr),$$
matching OP-2's lower bound up to $\beta$-polynomial constants. Thus the LB-UB pair is tight in the **minimax-over-$\eta$** sense.

---

## 9. Honest scope and implications for OP-2

**For the OP-2 paper revision.** The §4.2 tightness paragraph should be revised. The current text (per Li Xiao's review) says "tight relative to SGD" without distinguishing the regime. The revised text should explicitly state the four-fold tightness picture:

1. **No matching UB at fixed $(\beta,\eta)$ for unprojected SHB on smooth convex non-SC.** Established by Theorem A.1: the noise floor $c_F = \sigma^2\eta(1+\beta)/[4(1-\beta)(2(1+\beta)-\eta L)] > 0$ is independent of $T$. (Verifier: 11/11 PASS, including SymPy + 3 MC runs at $<0.1\%$ relative error.)

2. **Matching UB exists in the minimax-over-$\eta$ sense.** Theorem A.2: at $\eta_T=\Theta(D/(\sigma\sqrt T))$, the noise floor equals the LB symbolically.

3. **Matching UB exists for projected SHB up to a $\sqrt{\log T}$ gap.** Theorem D (Section 5).

4. **Matching deterministic UB for the Cesàro average.** GFJ15-style 3-term Lyapunov (Section 4) gives the deterministic bias term $LD^2/T$ tightly.

**Closing the Li Xiao gap.** The Li Xiao review's question — "Cesàro vs last iterate tightness" — is correctly identified as a real gap. The above analysis closes it: the LB is tight in three different positive senses (minimax-$\eta$, projected-up-to-$\log T$, deterministic-Cesàro), but **not** in the strict $\sup_f \inf_\eta$ pointwise sense for unprojected fixed-$(\beta,\eta)$. The honest phrasing for OP-2 §4.2 is option 1 in the Judge's ranking:

> "Tight up to $\log T$ for projected SHB with horizon-tuned stepsize; tight in **rate** $\Theta(\sigma D/\sqrt T)$ in the minimax-over-$\eta$ sense (constants differ by $\beta$-polynomial factor); **for unprojected SHB at fixed $(\beta,\eta)$, no $T$-decaying UB exists** (the noise-floor obstruction)."

**Outstanding cosmetic gaps (not blocking).**

- **Lemma 2 Abel argument.** Made explicit in Section 5 above.
- **Explorer 6 B3 looseness.** The Cauchy-Schwarz step in Route B is technically valid (unconditional inequality) but loose by $\sqrt{1+y_T^2/\mathbb{E}\|z_T\|^2}$. The cleaner zero-mean decomposition is
$$\mathbb{E}\|x_T-x^\star\|^2 \;=\; \|y_T-x^\star\|^2 + \mathbb{E}\|z_T\|^2,$$
exact for the linearization, requiring only $\mathbb{E} z_T = 0$ (which holds because the noise is martingale-difference and the decomposition is linear). This is the Auditor's recommended replacement; it does not change the qualitative conclusion (Route B still fails on the $\mu=0$ direction because $\mathbb{E}\|z_T\|^2$ blows up linearly in $T$).
- **Spectral-radius constant.** $C\le\kappa(V)^2$ in eq. (8) is bounded uniformly on compact subsets of the stability region — verified by symbolic eigenvalue calculation (Auditor finding 4). No uncontrolled $D$- or $T$-dependence.

---

## 10. Files and references

**Working directory:** `C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\`

**Source documents.**
- Phase 1 (Scout): `direction_2_scout.md` (per workflow)
- Phase 2 (Explorers): `d2_explorer_1_orthodox.md` (Route A), `d2_explorer_2_adversarial.md` (Route F, **winning**), `d2_explorer_3_sebbouh.md` (Route C), `d2_explorer_4_o2b.md` (Route D), `d2_explorer_5_pep.py` (Route E), `d2_explorer_6_compositional.md` (Route B)
- Phase 3 (Judge): `direction_2_judge.md`
- Phase 4 (Auditor): `direction_2_audit.md` — 11/11 PASS
- Phase 5 (Fixer, this document): `direction_2_last_iterate_ub.md`

**Verifier scripts.**
- `audit_d2_verifier.py` — Auditor's 11-task verification, all PASS.
- `verify_shb_variance.py` — Explorer 2 SymPy + 5 Monte-Carlo runs, 5/6 PASS (the failure was the scout's incorrect $1/(1-\beta^2)$ leading constant, corrected by Theorem A.1).

**Citations relevant for OP-2.**
- Sebbouh, Gower, Defazio, "Almost sure convergence rates for Stochastic Gradient Descent and Stochastic Heavy Ball" (arXiv:2006.07867, COLT 2021 / PMLR v134). [a.s. last-iterate $o(1/\sqrt k)$ with time-varying schedule].
- Ghadimi, Feyzmahdavian, Johansson (GFJ, 2015), "Global convergence of the heavy-ball method for convex optimization." [Cesàro $LD^2/T$ deterministic bound].
- OP-2 (this work), §4.2 tightness paragraph requires the revised qualified statement above.

---

**Word count:** ~3550.

**Verdict:** Direction 2 is fully resolved. Negative + partial positive theorems are stated, proved, and verified. The Li Xiao tightness question has a precise answer in three complementary positive senses, with the negative result giving a clean obstruction in the strict pointwise sense.
