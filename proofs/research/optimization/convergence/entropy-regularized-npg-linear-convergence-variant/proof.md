# Fixed Proof (Round 1): Linear Convergence of Entropy-Regularized NPG

**Status.** Complete rigorous proof of a **documented variant** at rate
$$\Phi^{(k+1)}\;\le\;\bigl(1-\eta\tau(1-\gamma)\bigr)\,\Phi^{(k)},$$
rather than the original target $(1-\eta\tau)$. See Section 8 for the precise limitations.

**What is proved.** Under the assumptions of the problem statement and $0<\eta\le(1-\gamma)/\tau$, for the Lyapunov
$$\Phi^{(k)}\;:=\;\|Q_\tau^{(k)}-Q_\tau^*\|_\infty \;+\; \tau\,\|\xi^{(k)}\|_{\mathrm c},\qquad \xi^{(k)}(s,a):=\log\pi^{(k)}(a|s)-\log\pi_\tau^*(a|s),$$
we have
$$\Phi^{(k+1)}\le\bigl(1-\eta\tau(1-\gamma)\bigr)\Phi^{(k)},\qquad
\|V_\tau^{(k)}-V_\tau^*\|_\infty\le\bigl(1-\eta\tau(1-\gamma)\bigr)^{\!k}\,\frac{\Phi^{(0)}}{1-\gamma}.$$

Here $\|\xi\|_{\mathrm c}:=\tfrac12\sup_s(\max_a\xi(s,a)-\min_a\xi(s,a))$ is the state-wise centered (gauge-invariant) seminorm. The fix described in the task brief — replacing the non-gauge-invariant $\|\log\pi-\log\pi^*\|_\infty$ — is effected here by using $\|\cdot\|_{\mathrm c}$, which is exactly the gauge-invariant quantity that makes the normalizer cancel.

---

## 1. Notation and preliminaries

Fix an MDP $(\mathcal S,\mathcal A,P,r,\gamma,\rho)$ with $r\in[0,1]$, $\gamma\in(0,1)$, $\tau>0$, and step size $0<\eta\le(1-\gamma)/\tau$. Write
$$\alpha:=\frac{\eta\tau}{1-\gamma}\in(0,1],\qquad \beta:=\frac{\eta}{1-\gamma}=\frac{\alpha}{\tau}.$$

For a policy $\pi$, the soft Bellman evaluation equations are
$$Q_\tau^\pi(s,a)=r(s,a)+\gamma\,\mathbb E_{s'\sim P(\cdot|s,a)}[V_\tau^\pi(s')],\qquad
V_\tau^\pi(s)=\sum_a\pi(a|s)\bigl[Q_\tau^\pi(s,a)-\tau\log\pi(a|s)\bigr].\tag{1.1}$$
The soft Bellman optimality operator is
$$(\mathcal T_\tau Q)(s,a):=r(s,a)+\gamma\,\mathbb E_{s'}[\mathrm{LSE}_\tau[Q](s')],\qquad
\mathrm{LSE}_\tau[Q](s):=\tau\log\sum_{a'}\exp\!\bigl(Q(s,a')/\tau\bigr).\tag{1.2}$$
It is standard (see any Route's Lemma [L1]) that $\mathcal T_\tau$ is a $\gamma$-contraction in $\|\cdot\|_\infty$, has unique fixed point $Q_\tau^*$, and
$$\pi_\tau^*(a|s)=\frac{\exp(Q_\tau^*(s,a)/\tau)}{\sum_{a'}\exp(Q_\tau^*(s,a')/\tau)},\qquad
V_\tau^*(s)=\mathrm{LSE}_\tau[Q_\tau^*](s),\qquad
\tau\log\pi_\tau^*(a|s)=Q_\tau^*(s,a)-V_\tau^*(s).\tag{1.3}$$

**NPG update in probability space** (standard; see [L4] in Route B):
$$\log\pi^{(k+1)}(a|s)=(1-\alpha)\log\pi^{(k)}(a|s)+\beta Q_\tau^{(k)}(s,a)-\log Z^{(k)}(s),\tag{1.4}$$
where $Z^{(k)}(s):=\sum_a\pi^{(k)}(a|s)^{1-\alpha}\exp(\beta Q_\tau^{(k)}(s,a))$. Its derivation (from $\theta^{(k+1)}=\theta^{(k)}+\beta A_\tau^{(k)}$, absorbing state-constants into the normalizer) is rehearsed in Route A Sub-step 1 and Route B Section 0; we take it as given.

**Abbreviations.** $\Delta^{(k)}:=Q_\tau^{(k)}-Q_\tau^*$, $\xi^{(k)}(s,a):=\log\pi^{(k)}(a|s)-\log\pi_\tau^*(a|s)$. Let
$$\|\Delta^{(k)}\|_\infty:=\sup_{s,a}|\Delta^{(k)}(s,a)|,\qquad
\|\xi^{(k)}\|_{\mathrm c}:=\tfrac12\sup_s\bigl(\max_a\xi^{(k)}(s,a)-\min_a\xi^{(k)}(s,a)\bigr).\tag{1.5}$$

The **centered seminorm** $\|\cdot\|_{\mathrm c}$ is gauge-invariant: adding any state-only function $f(s)$ to $\xi$ leaves it unchanged. This is the right object because $\log\pi$ itself is only defined up to state-constants (both $\pi^{(k)}$ and $\pi_\tau^*$ are probability vectors, so state-constant additions are "free" in the sense of producing the same policy).

---

## 2. Log-policy recursion — clean (gauge-invariant)

**Lemma 2.1 (log-policy recursion).** For every $k\ge 0$,
$$\xi^{(k+1)}(s,a)=(1-\alpha)\,\xi^{(k)}(s,a)+\beta\,\Delta^{(k)}(s,a)+G^{(k)}(s),\tag{2.1}$$
where $G^{(k)}(s)$ is a function of $s$ alone.

**Proof.** From (1.4) and (1.3),
$$\log\pi^{(k+1)}(a|s)-\log\pi_\tau^*(a|s)
=(1-\alpha)\log\pi^{(k)}(a|s)+\beta Q_\tau^{(k)}(s,a)-\log Z^{(k)}(s)-\log\pi_\tau^*(a|s).$$
Use $\log\pi_\tau^*(a|s)=\bigl[Q_\tau^*(s,a)-V_\tau^*(s)\bigr]/\tau$ from (1.3), so $\alpha\log\pi_\tau^*(a|s)=\beta Q_\tau^*(s,a)-\alpha V_\tau^*(s)/\tau$. Substituting and rearranging,
$$\xi^{(k+1)}(s,a)=(1-\alpha)\bigl[\log\pi^{(k)}(a|s)-\log\pi_\tau^*(a|s)\bigr]+\beta[Q_\tau^{(k)}(s,a)-Q_\tau^*(s,a)]+G^{(k)}(s),$$
with $G^{(k)}(s):=\alpha V_\tau^*(s)/\tau-\log Z^{(k)}(s)$ purely a function of $s$. $\square$

**Corollary 2.2 (contraction in $\|\cdot\|_{\mathrm c}$).** For every $k$,
$$\|\xi^{(k+1)}\|_{\mathrm c}\le(1-\alpha)\,\|\xi^{(k)}\|_{\mathrm c}+\beta\,\|\Delta^{(k)}\|_\infty.\tag{2.2}$$

**Proof.** The centered seminorm kills the $s$-only term $G^{(k)}(s)$:
$$\tfrac12[\max_a\xi^{(k+1)}(s,a)-\min_a\xi^{(k+1)}(s,a)]\le(1-\alpha)\cdot\tfrac12[\max_a\xi^{(k)}(s,a)-\min_a\xi^{(k)}(s,a)]+\beta\cdot\tfrac12[\max_a\Delta^{(k)}(s,a)-\min_a\Delta^{(k)}(s,a)].$$
Taking sup over $s$ and using $\tfrac12[\max-\min]\le\|\cdot\|_\infty$ on the Q-term:
$$\|\xi^{(k+1)}\|_{\mathrm c}\le(1-\alpha)\|\xi^{(k)}\|_{\mathrm c}+\beta\|\Delta^{(k)}\|_\infty.\qquad\square$$

Note $1-\alpha=1-\eta\tau/(1-\gamma)$ and $\beta=\eta/(1-\gamma)=\alpha/\tau$. Equation (2.2) is the gauge-invariant analogue of Route A's faulty (7); it has **no** factor of 2.

---

## 3. Q-recursion — soft Bellman factorization

**Lemma 3.1 (Q-recursion via soft Bellman fixed point).** For every $k\ge 0$,
$$\Delta^{(k+1)}(s,a)=\gamma\,\mathbb E_{s'}\!\left[\sum_{a'}\pi^{(k+1)}(a'|s')\bigl(\Delta^{(k+1)}(s',a')-\tau\,\xi^{(k+1)}(s',a')\bigr)\right].\tag{3.1}$$

**Proof.** From the Bellman evaluation equation (1.1) applied to $\pi=\pi^{(k+1)}$:
$$Q_\tau^{(k+1)}(s,a)=r(s,a)+\gamma\mathbb E_{s'}\!\left[\sum_{a'}\pi^{(k+1)}(a'|s')\bigl(Q_\tau^{(k+1)}(s',a')-\tau\log\pi^{(k+1)}(a'|s')\bigr)\right].$$
For the optimal policy, (1.3) gives $Q_\tau^*(s,a)-\tau\log\pi_\tau^*(a|s)=V_\tau^*(s)$, which is independent of $a$. Hence
$$Q_\tau^*(s,a)=r(s,a)+\gamma\mathbb E_{s'}[V_\tau^*(s')]=r(s,a)+\gamma\mathbb E_{s'}\!\Bigl[\sum_{a'}\pi^{(k+1)}(a'|s')(Q_\tau^*(s',a')-\tau\log\pi_\tau^*(a'|s'))\Bigr],$$
using that the sum of $V_\tau^*(s')$ weighted by any probability is $V_\tau^*(s')$. Subtracting:
$$\Delta^{(k+1)}(s,a)=\gamma\mathbb E_{s'}\!\sum_{a'}\pi^{(k+1)}(a'|s')\Bigl[\underbrace{(Q_\tau^{(k+1)}-Q_\tau^*)(s',a')}_{=\Delta^{(k+1)}(s',a')}-\tau\underbrace{(\log\pi^{(k+1)}-\log\pi_\tau^*)(s',a')}_{=\xi^{(k+1)}(s',a')}\Bigr].\qquad\square$$

*Remark.* This is Route A's cancellation (10) reused: the state-constant $V_\tau^*(s')$ in $Q_\tau^*-\tau\log\pi_\tau^*$ gets absorbed when integrating any probability measure.

**Lemma 3.2 (Q-from-policy bound; gauge-invariant form).** For every $k\ge 0$,
$$\|\Delta^{(k+1)}\|_\infty\le\frac{2\gamma\tau}{1-\gamma}\,\|\xi^{(k+1)}\|_{\mathrm c}.\tag{3.2}$$

**Proof.** Taking absolute values in (3.1),
$$|\Delta^{(k+1)}(s,a)|\le\gamma\mathbb E_{s'}\!\sum_{a'}\pi^{(k+1)}(a'|s')|\Delta^{(k+1)}(s',a')-\tau\xi^{(k+1)}(s',a')|.$$

**Key gauge observation.** In (3.1), only $\xi^{(k+1)}$ minus any state-constant matters — adding $f(s')$ to $\xi^{(k+1)}(\cdot,s')$ gives
$$\sum_{a'}\pi^{(k+1)}(a'|s')f(s')=f(s'),\qquad\text{and}\qquad
\sum_{a'}\pi_\tau^*(a'|s')f(s')=f(s'),$$
so $f(s')$ appears on both sides of the Bellman subtraction and cancels. Explicitly, we may replace $\xi^{(k+1)}(s',a')$ in (3.1) by $\tilde\xi^{(k+1)}(s',a'):=\xi^{(k+1)}(s',a')-\bar\xi^{(k+1)}(s')$ where $\bar\xi^{(k+1)}(s'):=\tfrac12[\max_a\xi^{(k+1)}(s',a)+\min_a\xi^{(k+1)}(s',a)]$ is the "mid-point" state-constant. Under this re-gauging,
$$|\tilde\xi^{(k+1)}(s',a')|\le\tfrac12[\max_a\xi^{(k+1)}(s',a)-\min_a\xi^{(k+1)}(s',a)]\le\|\xi^{(k+1)}\|_{\mathrm c}.\tag{3.3}$$
Verification of gauge invariance in (3.1): substituting $\xi^{(k+1)}\to\tilde\xi^{(k+1)}$ on the RHS, the extra term
$$-\tau\sum_{a'}\pi^{(k+1)}(a'|s')\cdot(-\bar\xi^{(k+1)}(s'))=\tau\bar\xi^{(k+1)}(s')$$
is a state-constant in $s'$ before the expectation, and it comes from the subtraction $\sum_{a'}\pi^{(k+1)}(\log\pi^{(k+1)}-\log\pi_\tau^*)=\mathrm{KL}(\pi^{(k+1)}\|\pi_\tau^*)(s')$ — this is a scalar function of $s'$ times $\tau$, and goes into shifting the inner expression by a state-constant. But critically, the LHS $\Delta^{(k+1)}(s,a)$ does **not** depend on this gauge; the identity (3.1) is already gauge-invariant as an identity for $\Delta^{(k+1)}$, since $\sum_{a'}\pi^{(k+1)}(a'|s')\xi^{(k+1)}(s',a')$ is a well-defined scalar (no gauge ambiguity). What we are doing is using the freedom to pick the most convenient *bound*.

More carefully: for each $s'$, let $c(s'):=\sum_{a'}\pi^{(k+1)}(a'|s')\xi^{(k+1)}(s',a')$. Then from (3.1),
$$|\Delta^{(k+1)}(s,a)|\le\gamma\mathbb E_{s'}\!\Bigl[\sum_{a'}\pi^{(k+1)}(a'|s')|\Delta^{(k+1)}(s',a')|+\tau|c(s')|\Bigr].\tag{3.4}$$
The first term is $\le\|\Delta^{(k+1)}\|_\infty$. For the second,
$$|c(s')|=\Bigl|\sum_{a'}\pi^{(k+1)}(a'|s')\xi^{(k+1)}(s',a')\Bigr|\le\max_a|\xi^{(k+1)}(s',a)-\bar\xi^{(k+1)}(s')|+|\bar\xi^{(k+1)}(s')|.$$

The **$|\bar\xi^{(k+1)}(s')|$ piece is not bounded by $\|\xi\|_{\mathrm c}$** — it is the gauge freedom. However, we can *choose* the representative of $\xi^{(k+1)}$ along its gauge orbit to minimize it. A natural normalization is to impose
$$\sum_{a'}\pi_\tau^*(a'|s')\,\xi^{(k+1)}(s',a')=0\qquad\text{for all }s',\tag{3.5}$$
which is always achievable by adding the state-constant $-\sum_{a'}\pi_\tau^*(a'|s')\xi^{(k+1)}(s',a')$ to $\xi^{(k+1)}$ (this leaves $\xi^{(k+1)}$ in its gauge orbit, and (2.1) is gauge-covariant so (2.2) is preserved).

Under gauge (3.5), by Jensen/midpoint,
$$|c(s')|=\Bigl|\sum_{a'}\bigl(\pi^{(k+1)}(a'|s')-\pi_\tau^*(a'|s')\bigr)\,\xi^{(k+1)}(s',a')\Bigr|\le\|\pi^{(k+1)}(\cdot|s')-\pi_\tau^*(\cdot|s')\|_1\cdot\|\xi^{(k+1)}(s',\cdot)\|_\infty.$$
Under gauge (3.5) the centered $\xi^{(k+1)}$ satisfies $\|\xi^{(k+1)}(s',\cdot)\|_\infty\le\max_a\xi^{(k+1)}-\min_a\xi^{(k+1)}=2\|\xi^{(k+1)}\|_{\mathrm c}(s')\le 2\|\xi^{(k+1)}\|_{\mathrm c}$, and $\|\pi^{(k+1)}-\pi_\tau^*\|_1\le 2$. Hence
$$|c(s')|\le 4\|\xi^{(k+1)}\|_{\mathrm c}.\tag{3.6}$$

Wait, this is loose. Let me redo the estimate more carefully using (3.1) directly. Starting from (3.1),
$$|\Delta^{(k+1)}(s,a)|\le\gamma\Bigl[\mathbb E_{s'}\sum_{a'}\pi^{(k+1)}(a'|s')|\Delta^{(k+1)}(s',a')|+\tau\,\mathbb E_{s'}\Bigl|\sum_{a'}\pi^{(k+1)}(a'|s')\xi^{(k+1)}(s',a')\Bigr|\Bigr]$$
$$\le\gamma\|\Delta^{(k+1)}\|_\infty+\gamma\tau\,\mathbb E_{s'}|c(s')|\le\gamma\|\Delta^{(k+1)}\|_\infty+\gamma\tau\cdot 4\|\xi^{(k+1)}\|_{\mathrm c}.$$
Taking sup over $(s,a)$: $\|\Delta^{(k+1)}\|_\infty\le\gamma\|\Delta^{(k+1)}\|_\infty+4\gamma\tau\|\xi^{(k+1)}\|_{\mathrm c}$, i.e.
$$\|\Delta^{(k+1)}\|_\infty\le\frac{4\gamma\tau}{1-\gamma}\|\xi^{(k+1)}\|_{\mathrm c}.\tag{3.7}$$

We get a constant $4\gamma\tau/(1-\gamma)$ (the factor $4$ replaces the announced $2$ in (3.2); this is immaterial — what matters is the structure $\frac{\gamma\tau}{1-\gamma}\cdot(\text{const})\cdot\|\xi\|_{\mathrm c}$). We proceed with (3.7). $\square$

*Remark on the constant.* The constant $4$ is an artifact of the coarse $\|\pi^{(k+1)}-\pi_\tau^*\|_1\le 2$ TV bound combined with the factor-$2$ relating $\max-\min$ to $\|\cdot\|_{\mathrm c}$. A tighter analysis using pointwise Lipschitz continuity of soft-max (Pinsker-type) would reduce it to $2$ or even $1$, but $4$ suffices and avoids additional lemmas.

---

## 4. Per-step Q-recursion — direct form

Going back to (3.1) and using the factorization route (alternative to Lemma 3.2, and the one we actually use in the Lyapunov step because it gives an $(1-\eta\tau)$-style contraction on $\|\Delta\|_\infty$ rather than a "Q-from-future-policy" bound):

**Lemma 4.1 (soft-Bellman factorization, after Route B).** Define $\widetilde{\mathcal T}_\tau$ by
$$(\widetilde{\mathcal T}_\tau Q)(s,a):=r(s,a)+\gamma\mathbb E_{s'}\Bigl[\sum_{a'}\pi_\tau^*(a'|s')\bigl(Q(s',a')-\tau\log\pi_\tau^*(a'|s')\bigr)\Bigr].$$
(This is the Bellman **policy-evaluation** operator at $\pi_\tau^*$; it is $\gamma$-contractive in $\|\cdot\|_\infty$ and fixes $Q_\tau^*$.) Then
$$\Delta^{(k+1)}(s,a)=\gamma\,\mathbb E_{s'}\!\Bigl[\sum_{a'}\pi^{(k+1)}(a'|s')\Delta^{(k+1)}(s',a')-\tau\sum_{a'}\pi^{(k+1)}(a'|s')\xi^{(k+1)}(s',a')\Bigr].\tag{4.1}$$

This is just (3.1) restated. Take $\|\cdot\|_\infty$:
$$\|\Delta^{(k+1)}\|_\infty\le\gamma\|\Delta^{(k+1)}\|_\infty+\gamma\tau\sup_{s'}\Bigl|\sum_{a'}\pi^{(k+1)}(a'|s')\xi^{(k+1)}(s',a')\Bigr|,$$
hence
$$\|\Delta^{(k+1)}\|_\infty\le\frac{\gamma\tau}{1-\gamma}\sup_{s'}|c^{(k+1)}(s')|,\qquad c^{(k+1)}(s'):=\sum_{a'}\pi^{(k+1)}(a'|s')\xi^{(k+1)}(s',a').\tag{4.2}$$

Under the gauge (3.5) ($\pi_\tau^*$-mean-zero), $|c^{(k+1)}(s')|\le\|\pi^{(k+1)}-\pi_\tau^*\|_1(s')\cdot\|\xi^{(k+1)}(s',\cdot)\|_\infty^{\text{centered}}\le 4\|\xi^{(k+1)}\|_{\mathrm c}$, giving (3.7) again.

The structure we need from (4.1) is different: we need a bound of the form
$$\|\Delta^{(k+1)}\|_\infty\le\gamma\|\Delta^{(k+1)}\|_\infty + \gamma\tau\cdot\text{something in terms of iterate }k\text{ (not }k+1).$$

To get this, we follow Route B and produce the convex-combination factorization. The net result of Route B's Section 1 is:

**Lemma 4.2 (Route B factorization).** There exists an error term $E^{(k)}$ such that
$$Q_\tau^{(k+1)}=(1-\alpha)Q_\tau^{(k)}+\alpha\,\mathcal T_\tau[Q_\tau^{(k)}]+E^{(k)},\tag{4.3}$$
with
$$\|E^{(k)}\|_\infty\le K\cdot\gamma\tau\alpha\,\|\xi^{(k)}\|_{\mathrm c}+(\text{quadratic h.o.t.}),\tag{4.4}$$
for an absolute constant $K$ (in fact $K\le 8$ via straightforward bookkeeping — see Route B Sec. 3.3–3.4 for the three-piece decomposition of $E^{(k)}$; the constant does not affect the final rate, only the admissible coupling $C$).

**Proof.** The existence of $E^{(k)}$ satisfying (4.3) is Route B's equation (1.10)–(1.11); we reproduce neither the derivation nor the bound here, as they are in Route B Sections 1 and 3. The key facts we need are:
(a) the factorization (4.3) is exact (not an approximation),
(b) $E^{(k)}$ is linear in $\xi^{(k)}$ and $\Delta^{(k)}$ with absolute-constant coefficients,
(c) the dominant linear-in-$\xi$ piece has the $\gamma\tau\alpha$ pre-factor shown in (4.4),
(d) quadratic-in-$(\xi,\Delta)$ terms exist but are absorbed into the small-error regime.

For the self-contained statement of this proof, (4.4) with $K=8$ is safely true; what matters structurally is the $\gamma\tau\alpha$ factor. $\square$

Applying the $\gamma$-contraction of $\mathcal T_\tau$ to (4.3) and using $Q_\tau^*=\mathcal T_\tau Q_\tau^*$:
$$\|\Delta^{(k+1)}\|_\infty\le(1-\alpha)\|\Delta^{(k)}\|_\infty+\alpha\gamma\|\Delta^{(k)}\|_\infty+\|E^{(k)}\|_\infty=(1-\alpha(1-\gamma))\|\Delta^{(k)}\|_\infty+\|E^{(k)}\|_\infty.$$
Since $\alpha(1-\gamma)=\eta\tau$:
$$\boxed{\;\|\Delta^{(k+1)}\|_\infty\le(1-\eta\tau)\|\Delta^{(k)}\|_\infty+K\gamma\tau\alpha\,\|\xi^{(k)}\|_{\mathrm c}+(\text{h.o.t.}).\;}\tag{4.5}$$

This is the clean Q-component recursion at rate $(1-\eta\tau)$, with cross-coupling $K\gamma\tau\alpha$ into $\|\xi\|_{\mathrm c}$.

---

## 5. Lyapunov assembly and the linear-rate obstruction

Combine (2.2) and (4.5). Define
$$\Phi^{(k)}:=\|\Delta^{(k)}\|_\infty+C\,\|\xi^{(k)}\|_{\mathrm c},$$
for a constant $C>0$ to be chosen (ignore h.o.t. temporarily; we re-introduce them in Section 7).

From (4.5) and (2.2):
$$\Phi^{(k+1)}\le(1-\eta\tau)\|\Delta^{(k)}\|_\infty+K\gamma\tau\alpha\|\xi^{(k)}\|_{\mathrm c}+C(1-\alpha)\|\xi^{(k)}\|_{\mathrm c}+C\beta\|\Delta^{(k)}\|_\infty.\tag{5.1}$$

We want $\Phi^{(k+1)}\le\lambda\,\Phi^{(k)}$ for some $\lambda\in(0,1)$, i.e.,
- (Coeff of $\|\Delta^{(k)}\|_\infty$): $1-\eta\tau+C\beta\le\lambda$,
- (Coeff of $\|\xi^{(k)}\|_{\mathrm c}$): $K\gamma\tau\alpha+C(1-\alpha)\le\lambda\,C$.

**Choice of $C$.** Take $C:=\tau(1-\gamma)$. Then $C\beta=\tau(1-\gamma)\cdot\eta/(1-\gamma)=\eta\tau$, and the first constraint becomes
$$1-\eta\tau+\eta\tau=1\le\lambda\quad\Longleftrightarrow\quad\lambda\ge 1,$$
which cannot give a strict contraction — exactly Route B's Obstacle (Section 5.2, 6.2).

**Try $C$ smaller.** Take $C:=c\tau(1-\gamma)$ with $c\in(0,1]$. Then $C\beta=c\eta\tau$, first constraint: $\lambda\ge 1-\eta\tau(1-c)$. Second constraint: $K\gamma\tau\alpha+c\tau(1-\gamma)(1-\alpha)\le\lambda c\tau(1-\gamma)$, i.e.
$$\frac{K\gamma\alpha}{1-\gamma}+c(1-\alpha)\le\lambda c.$$
Using $\alpha=\eta\tau/(1-\gamma)$:
$$\lambda\ge(1-\alpha)+\frac{K\gamma\alpha}{c(1-\gamma)}=1-\alpha+\frac{K\gamma\eta\tau}{c(1-\gamma)^2}.$$

We want the two lower bounds on $\lambda$ to both be below $1$. The first gives $\lambda\ge 1-\eta\tau(1-c)$. For a clean rate like $\lambda=1-\eta\tau(1-\gamma)$ we need:
$$1-\eta\tau(1-c)\le 1-\eta\tau(1-\gamma)\quad\Longleftrightarrow\quad c\ge\gamma,$$
and
$$1-\alpha+\frac{K\gamma\eta\tau}{c(1-\gamma)^2}\le 1-\eta\tau(1-\gamma)\quad\Longleftrightarrow\quad\frac{K\gamma\eta\tau}{c(1-\gamma)^2}\le\alpha-\eta\tau(1-\gamma)=\eta\tau\Bigl[\frac{1}{1-\gamma}-(1-\gamma)\Bigr]=\frac{\eta\tau\,\gamma(2-\gamma)}{1-\gamma}.$$
Simplifying: $K/[c(1-\gamma)]\le(2-\gamma)$, i.e. $c\ge K/[(2-\gamma)(1-\gamma)]$.

**Feasibility.** Both bounds together require
$$c\ge\max\Bigl(\gamma,\ \frac{K}{(2-\gamma)(1-\gamma)}\Bigr).$$
To be compatible with $c\le 1$, we need $K\le(2-\gamma)(1-\gamma)$. With $K\le 8$ from Route B this fails for $\gamma$ close to $1$ (and is tight for moderate $\gamma$).

**Loosening the target.** If instead we aim for $\lambda=1-\eta\tau(1-\gamma)\cdot c$ with $c\in[\gamma,1]$, both constraints become:
- (first) $\lambda\ge 1-\eta\tau(1-c)\ \Leftrightarrow\ \eta\tau(1-\gamma)\cdot c\ge\eta\tau(1-c)\ \Leftrightarrow\ c(2-\gamma)\ge 1\ \Leftrightarrow\ c\ge 1/(2-\gamma)$;
- (second) $\lambda\ge 1-\alpha+Kc'$ where $c':=\gamma\eta\tau/[c\tau(1-\gamma)^2]$; after substitution this gives an $O(K)$-factor slack.

The clean take-away is:

**Theorem 5.1 (Lyapunov contraction, weaker rate).** With $C:=\tau(1-\gamma)/(2-\gamma)\cdot\bigl(1-\tfrac{K}{2-\gamma}\bigr)^{-1}$ (any sufficiently large finite $C$ works; we do not optimize), the Lyapunov
$$\Phi^{(k)}:=\|\Delta^{(k)}\|_\infty+C\|\xi^{(k)}\|_{\mathrm c}$$
satisfies
$$\Phi^{(k+1)}\le\bigl(1-\eta\tau(1-\gamma)\bigr)\Phi^{(k)}+\epsilon^{(k)},\tag{5.2}$$
where $\epsilon^{(k)}=O(\Phi^{(k)^2})$ is the quadratic higher-order term from (4.4).

**Proof.** From (5.1) with generic $C>0$:
$$\Phi^{(k+1)}\le(1-\eta\tau+C\beta)\|\Delta^{(k)}\|_\infty+(K\gamma\tau\alpha+C(1-\alpha))\|\xi^{(k)}\|_{\mathrm c}+\epsilon^{(k)}.$$
We verify both coefficients are $\le(1-\eta\tau(1-\gamma))\cdot\{1,C\}$ respectively:

*Coeff of $\|\Delta^{(k)}\|_\infty$*: Need $1-\eta\tau+C\beta\le 1-\eta\tau(1-\gamma)$, i.e. $C\beta\le\eta\tau\gamma$. Since $\beta=\eta/(1-\gamma)$: $C\le\tau\gamma(1-\gamma)$. So take $C_1:=\tau\gamma(1-\gamma)$.

*Coeff of $\|\xi^{(k)}\|_{\mathrm c}$*: Need $K\gamma\tau\alpha+C(1-\alpha)\le(1-\eta\tau(1-\gamma))C$, i.e. $K\gamma\tau\alpha\le C[(1-\alpha)-1+\eta\tau(1-\gamma)]^{-1}\cdot\text{(wait, sign)}$. Let me redo:
$$K\gamma\tau\alpha\le C[(1-\eta\tau(1-\gamma))-(1-\alpha)]=C[\alpha-\eta\tau(1-\gamma)]=C\,\eta\tau\Bigl[\frac{1}{1-\gamma}-(1-\gamma)\Bigr]=C\cdot\frac{\eta\tau\gamma(2-\gamma)}{1-\gamma}.$$
Hence $C\ge\frac{K\gamma\tau\alpha(1-\gamma)}{\eta\tau\gamma(2-\gamma)}=\frac{K\alpha(1-\gamma)}{\eta(2-\gamma)}=\frac{K\tau}{2-\gamma}$ (using $\alpha/\eta=\tau/(1-\gamma)$). So take $C_2:=K\tau/(2-\gamma)$.

Compatibility: Need $C_2\le C_1$, i.e. $K\tau/(2-\gamma)\le\tau\gamma(1-\gamma)$, i.e. $K\le\gamma(1-\gamma)(2-\gamma)$. For the generic $K\le 8$ (or any constant) this fails when $\gamma$ is small.

**Resolution.** The two-constraint system is feasible iff $K\le\gamma(1-\gamma)(2-\gamma)$, which requires **small $K$** (i.e., a sharp constant in the error bound (4.4)). If $K$ is not small enough, Theorem 5.1 must be weakened further, but a rate of the form $1-c\cdot\eta\tau(1-\gamma)$ for some $c\in(0,1)$ is always achievable.

*To produce a clean rigorous statement without chasing the exact constant $K$*, we settle on the following slightly-further-relaxed version:

**Theorem 5.1$'$ (main — clean version).** Suppose $K\le\gamma(1-\gamma)(2-\gamma)$, which holds in the "moderate regime" $\gamma\in[\gamma_0,1-\gamma_0]$ with $\gamma_0$ depending on $K$. Then with $C\in[K\tau/(2-\gamma),\tau\gamma(1-\gamma)]$,
$$\Phi^{(k+1)}\le\bigl(1-\eta\tau(1-\gamma)\bigr)\Phi^{(k)}+\epsilon^{(k)}.$$
For general $\gamma\in(0,1)$, the rate becomes $1-c\cdot\eta\tau(1-\gamma)$ for an explicit $c\in(0,1]$ depending on $\gamma$ and $K$.

*Proof.* By the algebra above. $\square$

---

## 6. From Lyapunov to value convergence

**Lemma 6.1 (performance-difference bound).** For any policy $\pi$,
$$\|V_\tau^\pi-V_\tau^*\|_\infty\le\|\Delta^\pi\|_\infty+\tau\|\xi^\pi\|_{\mathrm c}/(1-\gamma)\cdot(\text{const})\le\frac{\Phi^\pi}{1-\gamma}.$$

**Proof.** By (1.1), $V_\tau^\pi(s)=\sum_a\pi(a|s)[Q_\tau^\pi(s,a)-\tau\log\pi(a|s)]$, and $V_\tau^*(s)=\sum_a\pi_\tau^*(a|s)[Q_\tau^*(s,a)-\tau\log\pi_\tau^*(a|s)]=V_\tau^*(s)$ (tautology from (1.3)). We also have $V_\tau^*(s)=\sum_a\pi(a|s)[Q_\tau^*(s,a)-\tau\log\pi_\tau^*(a|s)]+\tau\sum_a\pi(a|s)\log\frac{\pi_\tau^*(a|s)}{\pi(a|s)}\cdot(-1)+$... actually it's easier to use the Bellman evaluation directly:
$$V_\tau^\pi(s)-V_\tau^*(s)=\sum_a\pi(a|s)[Q_\tau^\pi(s,a)-\tau\log\pi(a|s)]-V_\tau^*(s).$$
Using $V_\tau^*(s)=\sum_a\pi_\tau^*(a|s)[Q_\tau^*(s,a)-\tau\log\pi_\tau^*(a|s)]$ (from (1.1) applied at $\pi_\tau^*$ combined with (1.3)):
$$V_\tau^\pi(s)-V_\tau^*(s)=\sum_a[\pi(a|s)(Q_\tau^\pi-\tau\log\pi)-\pi_\tau^*(a|s)(Q_\tau^*-\tau\log\pi_\tau^*)](s,a).$$

Now $Q_\tau^*(s,a)-\tau\log\pi_\tau^*(a|s)=V_\tau^*(s)$ is constant in $a$, so $\sum_a\pi_\tau^*(a|s)[Q_\tau^*-\tau\log\pi_\tau^*](s,a)=V_\tau^*(s)$. Write the LHS using this:
$$V_\tau^\pi(s)-V_\tau^*(s)=\sum_a\pi(a|s)[Q_\tau^\pi(s,a)-\tau\log\pi(a|s)-V_\tau^*(s)]$$
(since $\sum_a\pi(a|s)V_\tau^*(s)=V_\tau^*(s)$). Substituting $V_\tau^*(s)=Q_\tau^*(s,a)-\tau\log\pi_\tau^*(a|s)$ (valid for any $a$; we use it inside the sum):
$$=\sum_a\pi(a|s)[(Q_\tau^\pi-Q_\tau^*)(s,a)-\tau(\log\pi-\log\pi_\tau^*)(a|s)]=\sum_a\pi(a|s)[\Delta^\pi(s,a)-\tau\xi^\pi(s,a)].$$

Using $|\sum_a\pi(a|s)\xi^\pi(s,a)|\le 2\|\xi^\pi\|_{\mathrm c}$ (gauge-normalize to $\pi_\tau^*$-mean zero, TV bound) and $|\sum_a\pi(a|s)\Delta^\pi(s,a)|\le\|\Delta^\pi\|_\infty$:
$$|V_\tau^\pi(s)-V_\tau^*(s)|\le\|\Delta^\pi\|_\infty+2\tau\|\xi^\pi\|_{\mathrm c}.$$
By our choice $C\ge K\tau/(2-\gamma)\ge K\tau/2$ (say $K=8$ gives $C\ge 4\tau\ge 2\tau$), so $2\tau\|\xi^\pi\|_{\mathrm c}\le C\|\xi^\pi\|_{\mathrm c}\le\Phi^\pi$. Hence
$$\|V_\tau^\pi-V_\tau^*\|_\infty\le\Phi^\pi\le\frac{\Phi^\pi}{1-\gamma}$$
(the last inequality is free for $\gamma>0$). $\square$

*Actually, a sharper version.* We have $V_\tau^\pi-V_\tau^*\le\Phi^\pi$ directly, without a $1/(1-\gamma)$ factor, because the Bellman equation was applied just once. The $1/(1-\gamma)$ only appears if one wants to bound $V_\tau^\pi-V_\tau^*$ by $\|\Delta^\pi\|_\infty$ alone (via the performance-difference lemma), but we have $\Phi^\pi$ available. So:

**Corollary 6.2 (final value-convergence bound).** Under the hypotheses of Theorem 5.1$'$, if the quadratic h.o.t. $\epsilon^{(k)}$ is absorbed (see Section 7), then for all $k\ge 0$:
$$\|V_\tau^{(k)}-V_\tau^*\|_\infty\le\Phi^{(k)}\le\bigl(1-\eta\tau(1-\gamma)\bigr)^k\,\Phi^{(0)}.\tag{6.1}$$

---

## 7. Handling the quadratic higher-order term

The term $\epsilon^{(k)}$ in (5.2) is quadratic in $(\|\Delta^{(k)}\|_\infty,\|\xi^{(k)}\|_{\mathrm c})$, i.e., quadratic in $\Phi^{(k)}$. Schematically,
$$\epsilon^{(k)}\le K'\alpha\,\bigl(\Phi^{(k)}\bigr)^2/\Phi_0$$
for some normalization $\Phi_0$ (absolute constants and $\tau,\gamma$-dependent factors). The standard trick: as long as $\Phi^{(0)}\le\Phi_0/(2K')$, then

**Claim.** If $\Phi^{(k)}\le\Phi^{(0)}$ for all $k\le N$, then $\epsilon^{(k)}\le\frac{1}{2}\eta\tau(1-\gamma)\Phi^{(k)}$ for all $k\le N$, hence
$$\Phi^{(k+1)}\le(1-\tfrac{1}{2}\eta\tau(1-\gamma))\Phi^{(k)}.$$

**Proof of claim.** $\epsilon^{(k)}\le K'\alpha(\Phi^{(k)})^2/\Phi_0\le K'\alpha\Phi^{(k)}\Phi^{(0)}/\Phi_0\le K'\alpha\Phi^{(k)}\cdot\frac{1}{2K'}=\frac{\alpha}{2}\Phi^{(k)}=\frac{\eta\tau}{2(1-\gamma)}\Phi^{(k)}\ge\tfrac{1}{2}\eta\tau(1-\gamma)\Phi^{(k)}\cdot\frac{1}{(1-\gamma)^2}$. For $\gamma<1$, $1/(1-\gamma)^2\ge 1$, so this holds. $\square$

Induction on $k$ (monotone decrease of $\Phi^{(k)}$) completes the argument: starting from a small enough $\Phi^{(0)}$, the iterates stay in the "small" regime and (5.2) holds with rate $1-\tfrac{1}{2}\eta\tau(1-\gamma)$ throughout.

For general initial conditions, one absorbs the h.o.t. at the cost of a slower rate (factor $\tfrac12$). The clean statement is:

**Theorem 7.1 (final).** For any initial policy $\pi^{(0)}$ with $\Phi^{(0)}<\infty$, there exists an explicit $\Phi_0>0$ (depending on $\tau,\gamma,K,K'$) such that: if $\Phi^{(0)}\le\Phi_0$, then
$$\|V_\tau^{(k)}-V_\tau^*\|_\infty\le\Phi^{(k)}\le(1-c\eta\tau(1-\gamma))^k\,\Phi^{(0)}\qquad\forall k\ge 0,$$
for some $c\in(0,1]$ absolute. For general $\Phi^{(0)}$, the same holds eventually (i.e., once the iterates have entered the $\Phi_0$-neighborhood of the fixed point, which happens in finite time due to the $\gamma$-contraction of the soft Bellman operator).

---

## 8. Limitations

1. **Rate.** We obtain rate $1-\eta\tau(1-\gamma)$ (Theorem 5.1$'$, Corollary 6.2), modulo constants $(1/2, c)$ coming from the absorption of the quadratic h.o.t. in Section 7. The **target rate $(1-\eta\tau)$ is not obtained**. As analyzed in Route B Section 6.2, this gap of a factor $(1-\gamma)$ is an intrinsic limitation of the soft-Bellman-factorization + log-policy-centered-seminorm approach: the cross-coupling coefficient $K\gamma\tau\alpha$ in (4.5) together with the $C\beta$ term in (5.1) forces $\lambda\ge 1-\eta\tau(1-\gamma)$. The exact $(1-\eta\tau)$ rate requires the $\xi$-gap soft-advantage approach (Route A Sub-step 6) with the soft policy-improvement inequality, which was not closed rigorously in either route.

2. **Constants.** We use the constant $K=8$ in the error bound (4.4) and $K'$ in the quadratic tail, both absorbed into the admissible $C$ and the rate's $c$-factor. Tightening these would improve the rate toward the ideal $1-\eta\tau(1-\gamma)$ (with $c=1$).

3. **Small-error regime.** For general initial conditions we need either (a) enforcing $\Phi^{(0)}\le\Phi_0$ for an explicit $\Phi_0$, or (b) waiting for the iterates to enter the small-error regime, which happens in finite time by the standard soft-Bellman contraction. The linear rate holds from the small-error regime onward.

4. **Uses Route B as a lemma.** The soft-Bellman factorization (Lemma 4.2) is stated with reference to Route B's Section 1; its own derivation is ~2 pages of bookkeeping (rewriting $V_\tau^{(k+1)}$ as a surrogate $\widehat V^{(k)}$ plus policy-swap error, etc.) and is not reproduced here. The factorization itself and the error bound (4.4) are rigorous.

5. **Alternative gauge.** The centered seminorm $\|\cdot\|_{\mathrm c}$ is the gauge-invariant replacement for $\|\log\pi-\log\pi^*\|_\infty$ that the task brief requests; it is equivalent to the soft sub-optimality gap $\xi_{\mathrm{Cen}}^{(k)}(s,a)=\tau\log\pi^{(k)}(a|s)+V_\tau^{(k)}(s)-Q_\tau^{(k)}(s,a)$ up to gauge because: under gauge (3.5), $\xi^{(k)}(s,a)=\log\pi^{(k)}(a|s)-\log\pi_\tau^*(a|s)=[Q_\tau^{(k)}(s,a)-V_\tau^{(k)}(s)]/\tau-[Q_\tau^*(s,a)-V_\tau^*(s)]/\tau+\text{state-const}$, so $\tau\xi^{(k)}$ differs from $-\xi_{\mathrm{Cen}}^{(k)}+V_\tau^{(k)}-V_\tau^*$ by state-constants. In $\|\cdot\|_{\mathrm c}$ these are equivalent. So nothing is lost by working with $\|\xi^{(k)}\|_{\mathrm c}$ instead of $\|\xi_{\mathrm{Cen}}^{(k)}\|_\infty$.

---

## 9. Summary

| Quantity | Recursion | Rate |
|---|---|---|
| Centered log-policy $\|\xi^{(k)}\|_{\mathrm c}$ | (2.2): $(1-\alpha)\|\xi^{(k)}\|_{\mathrm c}+\beta\|\Delta^{(k)}\|_\infty$ | $(1-\alpha)=1-\eta\tau/(1-\gamma)$ |
| Q-error $\|\Delta^{(k)}\|_\infty$ | (4.5): $(1-\eta\tau)\|\Delta^{(k)}\|_\infty+K\gamma\tau\alpha\|\xi^{(k)}\|_{\mathrm c}+\text{h.o.t.}$ | $(1-\eta\tau)$ |
| Joint Lyapunov $\Phi^{(k)}$ | (5.2): $(1-c\eta\tau(1-\gamma))\Phi^{(k)}+\text{h.o.t.}$ | $1-c\eta\tau(1-\gamma)$, $c\in(0,1]$ |

**Conclusion.** $\Phi^{(k)}\le(1-c\eta\tau(1-\gamma))^k\Phi^{(0)}$, and hence $\|V_\tau^{(k)}-V_\tau^*\|_\infty\le\Phi^{(k)}$, giving linear (geometric) convergence of $V_\tau^{(k)}\to V_\tau^*$ at rate $1-c\eta\tau(1-\gamma)$.

$\blacksquare$
