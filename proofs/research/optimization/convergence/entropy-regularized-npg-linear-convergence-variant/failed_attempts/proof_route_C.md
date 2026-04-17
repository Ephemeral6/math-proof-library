# Route C — Log-Linear Parameter Iteration

**Target.** Prove linear convergence of entropy-regularized NPG by working in the
$\theta$-parameter space, deriving an affine recursion
$\theta^{(k+1)} - \theta_\tau^\star$ and coupling it with the soft $Q$-error.

**Conventions (gauge fixing).**
Softmax is invariant under per-state shifts $\theta(s,a) \mapsto \theta(s,a) + c(s)$.
To eliminate this gauge we work with the **centered parameter**
$$
\tilde\theta(s,a) := \theta(s,a) - \frac{1}{\tau}V_\tau^{\pi_\theta}(s),
$$
so that at the optimum $\tilde\theta_\tau^\star(s,a) = Q_\tau^\star(s,a)/\tau$
(the soft Bellman fixed-point identity).

For the proof it will turn out cleaner to track
$$
\boxed{\; \xi^{(k)}(s,a) := \tau\log\pi^{(k)}(a|s) - Q_\tau^\star(s,a) + V_\tau^\star(s)\;}
$$
which is the **same** object as $\tau(\tilde\theta^{(k)} - \tilde\theta_\tau^\star)$
up to a per-state shift that vanishes after softmax normalization. The quantity
$\xi^{(k)}$ enjoys three features that make Route C tractable:

(C1) $\xi^{(k)}$ determines $\pi^{(k)}$ via
$\pi^{(k)}(a|s) \propto \exp(\xi^{(k)}(s,a)/\tau)$;
(C2) $\xi_\tau^\star \equiv 0$ (by the soft Bellman optimality equation
$Q_\tau^\star(s,a) = \tau\log\pi_\tau^\star(a|s) + V_\tau^\star(s)$);
(C3) $\xi^{(k)}$ is gauge-invariant under per-state shifts
$\theta \to \theta + c(s)$ (both terms shift by the same amount).

---

## Step 1. Derivation of the $\theta$-recursion in Route C

**Starting point.** The exact NPG iteration is
$$
\theta^{(k+1)}(s,a) = \theta^{(k)}(s,a) + \frac{\eta}{1-\gamma}\,A_\tau^{(k)}(s,a),
$$
with soft advantage
$$
A_\tau^{(k)}(s,a) = Q_\tau^{(k)}(s,a) - \tau\log\pi^{(k)}(a|s) - V_\tau^{(k)}(s).
$$

Here $Q_\tau^{(k)} := Q_\tau^{\pi^{(k)}}$ and $V_\tau^{(k)} := V_\tau^{\pi^{(k)}}$.

**Taking $\tau\log$ of the equivalent policy update.**
The well-known simplification (route description, eqn. after (26))
$$
\pi^{(k+1)}(a|s) \;\propto\; \pi^{(k)}(a|s)^{1-\eta\tau/(1-\gamma)}
\exp\!\left(\frac{\eta}{1-\gamma}\,Q_\tau^{(k)}(s,a)\right)
$$
is derived by writing $\pi_{\theta^{(k+1)}}\propto\exp(\theta^{(k+1)})$ and
substituting the NPG step; the $-V_\tau^{(k)}(s)$ piece of $A_\tau^{(k)}$ is
independent of $a$ and thus is absorbed into the normalizer.

Taking $\tau\cdot\log$ of this policy update gives, for each $(s,a)$,
$$
\tau\log\pi^{(k+1)}(a|s) = \Bigl(1-\tfrac{\eta\tau}{1-\gamma}\Bigr)\,
\tau\log\pi^{(k)}(a|s) \;+\; \tfrac{\eta\tau}{1-\gamma}\,Q_\tau^{(k)}(s,a)
\;-\; \tau\log Z_s^{(k)},\tag{1}
$$
where
$$
Z_s^{(k)} := \sum_{a'}\pi^{(k)}(a'|s)^{1-\eta\tau/(1-\gamma)}
\exp\!\left(\tfrac{\eta}{1-\gamma}Q_\tau^{(k)}(s,a')\right)
$$
is the per-state normalizer.

Identity (1) is the **log-linear parameter iteration** that Route C works with.
Subtracting the identity $Q_\tau^\star(s,a) = \tau\log\pi_\tau^\star(a|s) + V_\tau^\star(s)$
from both sides is the next step.

---

## Step 2. The centered recursion and its normalizer

**Subtracting the fixed point.** From (1):
$$
\tau\log\pi^{(k+1)}(a|s) - \tau\log\pi_\tau^\star(a|s)
= \Bigl(1-\tfrac{\eta\tau}{1-\gamma}\Bigr)\bigl(\tau\log\pi^{(k)}(a|s) - \tau\log\pi_\tau^\star(a|s)\bigr)
$$
$$
\quad\;\;+\tfrac{\eta\tau}{1-\gamma}\bigl(Q_\tau^{(k)}(s,a) - Q_\tau^\star(s,a)\bigr)
\;+\;\tfrac{\eta\tau}{1-\gamma}\bigl(Q_\tau^\star(s,a) - \tau\log\pi_\tau^\star(a|s)\bigr) - \tau\log\pi_\tau^\star(a|s)\cdot\tfrac{\eta\tau}{1-\gamma}\cdot\tfrac{1}{\cdot}
$$

Careful: let me redo this substitution cleanly.
Rewrite (1) as
$$
\tau\log\pi^{(k+1)}(a|s) - \tau\log\pi_\tau^\star(a|s)
= \Bigl(1-\tfrac{\eta\tau}{1-\gamma}\Bigr)\tau\log\pi^{(k)}(a|s)
+ \tfrac{\eta\tau}{1-\gamma}Q_\tau^{(k)}(s,a) - \tau\log Z_s^{(k)} - \tau\log\pi_\tau^\star(a|s).
$$

Use $\tau\log\pi_\tau^\star(a|s) = Q_\tau^\star(s,a) - V_\tau^\star(s)$, and split
$\tau\log\pi_\tau^\star(a|s)$ on the RHS into
$\bigl(1-\tfrac{\eta\tau}{1-\gamma}\bigr)\tau\log\pi_\tau^\star(a|s) + \tfrac{\eta\tau}{1-\gamma}\tau\log\pi_\tau^\star(a|s)$:
$$
\tau\log\pi^{(k+1)}(a|s) - \tau\log\pi_\tau^\star(a|s)
= \Bigl(1-\tfrac{\eta\tau}{1-\gamma}\Bigr)\bigl[\tau\log\pi^{(k)}(a|s) - \tau\log\pi_\tau^\star(a|s)\bigr]
$$
$$
\quad+\tfrac{\eta\tau}{1-\gamma}\bigl[Q_\tau^{(k)}(s,a) - \tau\log\pi_\tau^\star(a|s)\bigr]
- \tau\log Z_s^{(k)}.\tag{2}
$$

Using $Q_\tau^\star(s,a) - \tau\log\pi_\tau^\star(a|s) = V_\tau^\star(s)$:
$$
\tfrac{\eta\tau}{1-\gamma}\bigl[Q_\tau^{(k)}(s,a) - \tau\log\pi_\tau^\star(a|s)\bigr]
= \tfrac{\eta\tau}{1-\gamma}\bigl[Q_\tau^{(k)}(s,a) - Q_\tau^\star(s,a)\bigr]
+ \tfrac{\eta\tau}{1-\gamma}V_\tau^\star(s).
$$

Substituting back into (2) and grouping the $a$-independent (per-state) terms:
$$
\tau\log\pi^{(k+1)}(a|s) - \tau\log\pi_\tau^\star(a|s)
= \Bigl(1-\tfrac{\eta\tau}{1-\gamma}\Bigr)\bigl[\tau\log\pi^{(k)}(a|s) - \tau\log\pi_\tau^\star(a|s)\bigr]
$$
$$
\quad+\tfrac{\eta\tau}{1-\gamma}\bigl[Q_\tau^{(k)}(s,a) - Q_\tau^\star(s,a)\bigr]
\;+\;\underbrace{\Bigl(\tfrac{\eta\tau}{1-\gamma}V_\tau^\star(s) - \tau\log Z_s^{(k)}\Bigr)}_{=:\;c^{(k)}(s)}.\tag{3}
$$

The constant $c^{(k)}(s)$ depends only on $s$ (not on $a$). This is the
"per-state constant that softmax absorbs" mentioned in the route description.

---

## Step 3. The key gauge-invariant recursion on $\xi^{(k)}$

Define
$$
\xi^{(k)}(s,a) := \tau\log\pi^{(k)}(a|s) - \tau\log\pi_\tau^\star(a|s),
$$
the logarithmic policy discrepancy.

From (3):
$$
\boxed{\;\xi^{(k+1)}(s,a) = \Bigl(1-\tfrac{\eta\tau}{1-\gamma}\Bigr)\xi^{(k)}(s,a)
+ \tfrac{\eta\tau}{1-\gamma}\bigl[Q_\tau^{(k)}(s,a) - Q_\tau^\star(s,a)\bigr] + c^{(k)}(s).\;}\tag{4}
$$

Key observation: $\xi^{(k)}(s,\cdot)$ is not itself gauge-fixed (both
$\log\pi^{(k)}$ and $\log\pi_\tau^\star$ sum to something depending on $s$), but
we shall control $\xi^{(k)}$ **only through its oscillation in $a$**, which is
gauge-free. Specifically, we will actually bound
$$
\bar\xi^{(k)}(s,a) := \xi^{(k)}(s,a) - \mathbb{E}_{a'\sim\pi_\tau^\star(\cdot|s)}\xi^{(k)}(s,a')
$$
(projection onto the zero-mean-under-$\pi_\tau^\star$ subspace). Under this
projection, the per-state constant $c^{(k)}(s)$ disappears: taking
$\pi_\tau^\star(\cdot|s)$-mean of (4) subtracts the same $c^{(k)}(s)$ from both
sides, and we obtain
$$
\bar\xi^{(k+1)}(s,a) = \Bigl(1-\tfrac{\eta\tau}{1-\gamma}\Bigr)\bar\xi^{(k)}(s,a)
+ \tfrac{\eta\tau}{1-\gamma}\,\overline{\Delta Q}^{(k)}(s,a),\tag{5}
$$
where
$\overline{\Delta Q}^{(k)}(s,a) := Q_\tau^{(k)}(s,a) - Q_\tau^\star(s,a)
- \mathbb{E}_{a'\sim\pi_\tau^\star(\cdot|s)}\bigl[Q_\tau^{(k)}(s,a') - Q_\tau^\star(s,a')\bigr]$.

**Why the centering is harmless.** Since $\pi^{(k)}$ and $\pi_\tau^\star$ are
each probability vectors, they are invariant under adding any constant to
$\log\pi$; therefore any bound on $\bar\xi^{(k)}$ implies the same bound on the
quantity that actually matters — the policy $\pi^{(k)}$ — because
$$
\pi^{(k)}(a|s) = \frac{\exp(\xi^{(k)}(s,a)/\tau + \log\pi_\tau^\star(a|s))}
{\sum_{a'}\exp(\xi^{(k)}(s,a')/\tau + \log\pi_\tau^\star(a'|s))},
$$
and shifting $\xi^{(k)}(s,\cdot)$ by a scalar leaves $\pi^{(k)}$ unchanged.

---

## Step 4. Estimates on the two building blocks

We now need to bound two things:

**(B1) Policy-from-$\xi$ bound:** $\|\log\pi^{(k)} - \log\pi_\tau^\star\|_\infty$
in terms of $\|\bar\xi^{(k)}\|_\infty$.

**(B2) $Q$-error coupling back to policy error:** $\|Q_\tau^{(k)} - Q_\tau^\star\|_\infty$
in terms of $\|\log\pi^{(k)} - \log\pi_\tau^\star\|_\infty$.

### (B1) Policy bound from centered $\xi$

Pick any $s$ and $a$:
$$
\tau\log\pi^{(k)}(a|s) - \tau\log\pi_\tau^\star(a|s)
= \xi^{(k)}(s,a) = \bar\xi^{(k)}(s,a) + \mathbb{E}_{\pi_\tau^\star}\xi^{(k)}(s,\cdot).
$$
Summing over $a$ with weights $\pi^{(k)}(a|s)$ and with weights
$\pi_\tau^\star(a|s)$ gives two identities that pin down the unknown additive
constant. A convenient form: since
$\sum_a\pi^{(k)}(a|s) = \sum_a\pi_\tau^\star(a|s) = 1$,
$$
0 = \sum_a(\pi^{(k)}(a|s) - \pi_\tau^\star(a|s)),
$$
so the oscillation of $\tau\log(\pi^{(k)}/\pi_\tau^\star)$ in $a$ is bounded by
the oscillation of $\bar\xi^{(k)}$ in $a$:
$$
\max_a\tau\log\tfrac{\pi^{(k)}(a|s)}{\pi_\tau^\star(a|s)}
- \min_a\tau\log\tfrac{\pi^{(k)}(a|s)}{\pi_\tau^\star(a|s)}
= \max_a\bar\xi^{(k)}(s,a) - \min_a\bar\xi^{(k)}(s,a)
\leq 2\|\bar\xi^{(k)}\|_\infty.\tag{6}
$$
Moreover, since $\log\pi^{(k)}(a|s), \log\pi_\tau^\star(a|s)\in(-\infty,0]$ but
their difference has oscillation bounded as in (6), we get
$$
\bigl|\log\pi^{(k)}(a|s) - \log\pi_\tau^\star(a|s) - m^{(k)}(s)\bigr|
\leq \tfrac{2}{\tau}\|\bar\xi^{(k)}\|_\infty\quad\forall s,a,\tag{6'}
$$
for some $s$-dependent shift $m^{(k)}(s)$. But the policies themselves are
determined by $\log\pi^{(k)} - \log\pi_\tau^\star$ **modulo a per-state shift**
(softmax is shift-invariant). Equivalently one can choose $m^{(k)}(s)=0$ by
requiring the log-ratio to be zero-mean under some reference measure, and then
$\|\log\pi^{(k)} - \log\pi_\tau^\star\|_\infty \leq \tfrac{2}{\tau}\|\bar\xi^{(k)}\|_\infty$.

### (B2) Q-error from policy error — the CIRCULAR DEPENDENCY

We need an estimate of the form
$$
\|Q_\tau^{(k)} - Q_\tau^\star\|_\infty \le L\cdot\|\log\pi^{(k)} - \log\pi_\tau^\star\|_\infty\tag{7}
$$
for some constant $L = L(\gamma,\tau,\eta)$. The purpose of (7) is to close the
loop in (5): once we have
$$
\|\bar\xi^{(k+1)}\|_\infty \leq \bigl(1-\tfrac{\eta\tau}{1-\gamma}\bigr)\|\bar\xi^{(k)}\|_\infty
+ \tfrac{\eta\tau}{1-\gamma}\cdot 2L\cdot\tfrac{2}{\tau}\|\bar\xi^{(k)}\|_\infty,\tag{7'}
$$
we can combine the two terms into a geometric factor.

**Attempting (7).** The Bellman evaluation equation gives
$$
Q_\tau^\pi(s,a) = r(s,a) + \gamma\mathbb E_{s'\sim P(\cdot|s,a)}\Bigl[\sum_{a'}\pi(a'|s')\bigl(Q_\tau^\pi(s',a') - \tau\log\pi(a'|s')\bigr)\Bigr].
$$
Subtracting the $\pi_\tau^\star$ version and letting $\Delta Q(s,a) := Q_\tau^{(k)}(s,a) - Q_\tau^\star(s,a)$:
$$
\Delta Q(s,a) = \gamma\mathbb E_{s'}\Bigl[\sum_{a'}\pi^{(k)}(a'|s')\Delta Q(s',a')\Bigr]
+ \gamma\mathbb E_{s'}\Bigl[\sum_{a'}(\pi^{(k)}-\pi_\tau^\star)(a'|s')\cdot Q_\tau^\star(s',a')\Bigr]
$$
$$
\quad- \gamma\tau\mathbb E_{s'}\Bigl[\sum_{a'}\pi^{(k)}\log\pi^{(k)}(a'|s') - \sum_{a'}\pi_\tau^\star\log\pi_\tau^\star(a'|s')\Bigr].
$$
Taking $\|\cdot\|_\infty$ and using $\sum_{a'}\pi^{(k)}(a'|s')=1$:
$$
\|\Delta Q\|_\infty \leq \gamma\|\Delta Q\|_\infty + \gamma\|Q_\tau^\star\|_\infty\cdot\|\pi^{(k)}-\pi_\tau^\star\|_1 + \gamma\tau\cdot\mathrm{(entropy\ diff)}.
$$
Rearranging:
$$
\|\Delta Q\|_\infty \leq \frac{\gamma}{1-\gamma}\cdot\bigl[\|Q_\tau^\star\|_\infty\cdot\|\pi^{(k)}-\pi_\tau^\star\|_1 + \tau\cdot\mathrm{(entropy\ diff)}\bigr].
$$

The entropy and $L^1$ differences are controlled by
$\|\log\pi^{(k)}-\log\pi_\tau^\star\|_\infty$ via Pinsker / direct bounds (if
$|\log\pi-\log\pi'|\le\varepsilon$ pointwise, then
$\|\pi-\pi'\|_1\le A\cdot(e^\varepsilon-1)$ and the entropy difference is also
$\le |A|\varepsilon\cdot e^\varepsilon$). So indeed we obtain **a non-uniform
Lipschitz bound**
$$
\|\Delta Q\|_\infty \leq L(\varepsilon)\cdot\|\log\pi^{(k)}-\log\pi_\tau^\star\|_\infty\quad
\text{with }L(\varepsilon) = \tfrac{\gamma}{1-\gamma}\cdot O(|A|\cdot e^\varepsilon).\tag{7*}
$$

---

## Step 5. Attempted Lyapunov closure — where Route C stalls

Substitute (7*) into (7'):
$$
\|\bar\xi^{(k+1)}\|_\infty \leq \Bigl(1-\tfrac{\eta\tau}{1-\gamma}\Bigr)\|\bar\xi^{(k)}\|_\infty
+ \tfrac{\eta\tau}{1-\gamma}\cdot\tfrac{2}{\tau}\cdot L(\varepsilon_k)\cdot\|\bar\xi^{(k)}\|_\infty,
$$
where $\varepsilon_k := \|\log\pi^{(k)}-\log\pi_\tau^\star\|_\infty$.

For this to give a contraction rate of $(1-\eta\tau)$, we would need
$$
\tfrac{2\eta}{1-\gamma}\cdot L(\varepsilon_k) \;\leq\; \eta\tau\cdot\tfrac{1-\gamma\cdot(\text{something})}{1-\gamma}\cdot\eta\tau,
$$
i.e. roughly $L(\varepsilon_k) \leq \tau(1-\gamma)/2 - \tau\eta/2 \cdot (\cdots)$.

This is a **per-step requirement** on $L(\varepsilon_k)$, which from (7*) means
$$
\tfrac{\gamma}{1-\gamma}\cdot |A|\cdot e^{\varepsilon_k} \;\leq\; \tfrac{\tau(1-\gamma)}{2}.
$$

**OBSTACLE I: the constant $L$ is not small.** For typical problems with
$\gamma$ close to 1 and $|A|$ moderate, $L \gg \tau$, so the "cross term"
completely swamps the $(1-\eta\tau/(1-\gamma))$ linear factor and we do not
obtain any contraction, let alone the desired $(1-\eta\tau)$ rate.

**OBSTACLE II: the $\|Q_\tau^\star\|_\infty\cdot\|\pi-\pi^\star\|_1$ path loses
too much.** The naive Bellman-evaluation bound (7*) is very lossy because it
drops all sign information. In reality the recursion (5) has a definite sign:
the $Q$-error $\overline{\Delta Q}^{(k)}$ pulls $\bar\xi^{(k)}$ toward zero on
average (this is the content of the soft policy improvement lemma), not away
from it. But Route C's $\|\cdot\|_\infty$ treatment cannot see this sign: it
only sees the worst-case magnitude of $\overline{\Delta Q}^{(k)}$.

**OBSTACLE III: circular normalizer.** Even before reaching the cross-term
issue, closing the $\theta$-recursion requires bounding $\tau\log Z_s^{(k)}$.
By the LSE 1-Lipschitz property (Lemma 1 of
[REF: proofs/research/optimization/convergence/entropy-regularized-value-iteration/proof.md]),
$$
|\tau\log Z_s^{(k)} - \tau\log Z_s^\star|
\leq \bigl(1-\tfrac{\eta\tau}{1-\gamma}\bigr)\cdot\tau\|\log\pi^{(k)}-\log\pi_\tau^\star\|_\infty
+ \tfrac{\eta\tau}{1-\gamma}\|Q_\tau^{(k)}-Q_\tau^\star\|_\infty,
$$
which is **exactly as large** as the terms we are trying to bound in (3).
Thus the normalizer subtracts some correlated amount rather than providing
extra contraction. This is the standard circularity warned about in the route
description's "potential pitfalls".

---

## Step 6. Why Route C cannot close by itself

Route C pins the contraction rate to $(1-\eta\tau/(1-\gamma))$ from the
$\theta$-recursion (3), while the $Q$-error in (3) is **not** of the order
$\eta\tau/(1-\gamma)$ smaller than $\xi^{(k)}$ (absent the Lyapunov coupling of
Route A). Concretely:

- The affine recursion (4) gives a self-contraction factor
  $(1-\eta\tau/(1-\gamma))$ on $\bar\xi^{(k)}$ **only** when the $Q$-error term
  $\overline{\Delta Q}^{(k)}$ is zero or sub-linear in $\|\bar\xi^{(k)}\|$.
- Bounding $\overline{\Delta Q}^{(k)}$ via (7*) introduces a constant $L$ of
  order $\gamma|A|/(1-\gamma)$ multiplied by $e^{\varepsilon_k}$, which in the
  large-$\gamma$ or large-$|A|$ regime exceeds $\tau(1-\gamma)/(2\eta)$ and so
  destroys the contraction.
- The only way to avoid this is to **control $Q$-error and log-policy error
  jointly**, by which we mean: introduce a Lyapunov function
  $\Phi = \|Q-Q^\star\|_\infty + C\|\bar\xi\|_\infty$ for $C$ large, as Route A
  does. But at that point we have left Route C and are doing Route A.

Furthermore, the rate Route C derives from (4) alone, ignoring the cross term,
is $(1-\eta\tau/(1-\gamma))$ — which is **strictly worse** than the target
$(1-\eta\tau)$ in the regime where the discount is nontrivial. Route C's
parameter-space calculus thus gives the wrong rate: it captures the
"self-contraction of $\bar\xi$" but not the **additional** $Q$-induced pull
that makes the rate jump from $1-\eta\tau/(1-\gamma)$ to $1-\eta\tau$.

---

## Step 7. Where Route C succeeds partially

Route C does successfully contribute two partial results:

**(P1) Closed-form $\theta$-recursion.** Identity (1) with its per-state
constant $c^{(k)}(s) = \tfrac{\eta\tau}{1-\gamma}V_\tau^\star(s) - \tau\log Z_s^{(k)}$
is an exact identity — it is one-line algebra from the NPG update and is
independent of any smallness assumption. This identity is used as an ingredient
in Route A.

**(P2) Gauge-invariant centered recursion.** Equation (5),
$$
\bar\xi^{(k+1)} = \bigl(1-\tfrac{\eta\tau}{1-\gamma}\bigr)\bar\xi^{(k)}
+ \tfrac{\eta\tau}{1-\gamma}\overline{\Delta Q}^{(k)},
$$
is clean and useful. It shows:
- If $\eta\le(1-\gamma)/\tau$, the linear self-contraction factor
  $(1-\eta\tau/(1-\gamma)) \in [0,1)$.
- The policy error accumulates only through $\overline{\Delta Q}^{(k)}$, i.e.
  through the zero-mean (under $\pi_\tau^\star$) part of $Q$-error.

This recursion is a **building block** of the Route-A Lyapunov argument, but on
its own (5) has the same structural obstacle: the $\overline{\Delta Q}^{(k)}$
term is not a priori smaller than $\bar\xi^{(k)}$.

---

## Step 8. Conclusion — Route C fails to close

**Route C stalls at Step 5.** The $\theta$-space affine recursion (3) + (4) is
derivable and correct, but closing it requires a coupling with $\|Q-Q^\star\|$
— exactly the Lyapunov structure of Route A. Attempting to bound
$\|\Delta Q\|_\infty$ purely by $\|\log\pi-\log\pi^\star\|_\infty$ via Bellman
evaluation (eqn. (7*)) yields a constant $L = O(\gamma|A|/(1-\gamma))$ that is
typically **much larger** than the $\tau(1-\gamma)/(2\eta)$ needed to absorb
the cross term into a $(1-\eta\tau)$ contraction.

**Obstacle in one sentence.** Route C's parameter-space calculus naturally
produces the contraction rate $1-\eta\tau/(1-\gamma)$, not $1-\eta\tau$; and
the $Q$-side cannot be closed without a second Lyapunov term that effectively
reintroduces Route A.

**Recommendation.** Use Route A as the primary route. The two ingredients that
Route C correctly extracts — identity (1) and centered recursion (5) — can be
imported into Route A's log-policy-component bound.

---

## References to library

- [REF: proofs/research/optimization/convergence/entropy-regularized-value-iteration/proof.md]
  Lemma 1 (LSE 1-Lipschitz), Lemma 2 (variational form of LSE with entropy),
  definition and $\gamma$-contraction of $T_\tau$.
- [REF: proofs/research/optimization/convergence/npg-softmax-tabular-convergence/problem.md]
  NPG softmax simplification used to derive the closed-form policy update that
  underlies identity (1).
