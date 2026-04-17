# Matrix Bernstein Inequality: Final Proof

## Theorem (Matrix Bernstein Inequality)

Let $X_1, \ldots, X_n$ be independent random symmetric matrices in $\mathbb{R}^{d \times d}$ with $\mathbb{E}[X_i] = 0$ and $\|X_i\| \leq L$ a.s. Let $\sigma^2 = \left\|\sum_{i=1}^n \mathbb{E}[X_i^2]\right\|$. Then:

$$\Pr\left[\left\|\sum_{i=1}^n X_i\right\| \geq t\right] \leq 2d \cdot \exp\!\left(\frac{-t^2/2}{\sigma^2 + Lt/3}\right).$$

---

## Lemma A: Scalar Bernstein MGF Bound

**Statement.** Let $Y$ be a real random variable with $\mathbb{E}[Y] = 0$ and $|Y| \leq L$ a.s. Then for all $0 < \theta < 3/L$:

$$\mathbb{E}[e^{\theta Y}] \leq \exp\!\left(\frac{\theta^2 \mathbb{E}[Y^2]}{2(1 - \theta L/3)}\right).$$

**Proof.**

**Step 1: Factorial bound.** We claim $k! \geq 2 \cdot 3^{k-2}$ for all integers $k \geq 2$.

*Proof by induction.* Base case $k = 2$: $2! = 2 = 2 \cdot 3^0$. Inductive step: assume $k! \geq 2 \cdot 3^{k-2}$ for some $k \geq 2$. Then

$$(k+1)! = (k+1) \cdot k! \geq (k+1) \cdot 2 \cdot 3^{k-2} \geq 3 \cdot 2 \cdot 3^{k-2} = 2 \cdot 3^{k-1},$$

where the second inequality uses $k + 1 \geq 3$ (since $k \geq 2$). $\square$

**Step 2: Pointwise bound on the exponential.** We prove: for $|y| \leq L$ and $0 < \theta < 3/L$,

$$e^{\theta y} \leq 1 + \theta y + \frac{\theta^2 y^2}{2(1 - \theta L/3)}. \tag{A1}$$

By Taylor's theorem with integral remainder:

$$e^{\theta y} = 1 + \theta y + \theta^2 y^2 \int_0^1 (1-s) e^{s \theta y}\, ds.$$

For $|y| \leq L$ and $s \in [0,1]$, we have $e^{s\theta y} \leq e^{s\theta |y|} \leq e^{s \theta L}$. (If $y \geq 0$ the first inequality is equality; if $y < 0$ then $s\theta y \leq 0 \leq s\theta|y|$, so $e^{s\theta y} \leq 1 \leq e^{s\theta|y|}$. The second inequality uses $|y| \leq L$.) Since $y^2 \geq 0$ and $(1-s) \geq 0$ on $[0,1]$, we may bound upward:

$$e^{\theta y} \leq 1 + \theta y + \theta^2 y^2 \int_0^1 (1-s) e^{s\theta L}\, ds.$$

Computing the integral with $u = \theta L$:

$$\int_0^1 (1-s) e^{su}\, ds = \frac{e^{u} - 1 - u}{u^2}.$$

(This is verified by integration by parts or the substitution $v = 1-s$.) So:

$$e^{\theta y} \leq 1 + \theta y + y^2 \cdot \frac{e^{\theta L} - 1 - \theta L}{L^2}.$$

We now bound $\frac{e^u - 1 - u}{u^2}$ for $u = \theta L \in (0, 3)$. Using the power series:

$$\frac{e^u - 1 - u}{u^2} = \sum_{k=2}^{\infty} \frac{u^{k-2}}{k!}.$$

By the factorial bound from Step 1, $\frac{1}{k!} \leq \frac{1}{2 \cdot 3^{k-2}}$ for all $k \geq 2$, so:

$$\sum_{k=2}^{\infty} \frac{u^{k-2}}{k!} \leq \frac{1}{2} \sum_{k=2}^{\infty} \left(\frac{u}{3}\right)^{k-2} = \frac{1}{2} \cdot \frac{1}{1 - u/3},$$

where the geometric series converges since $u/3 < 1$. Substituting back ($u = \theta L$, and $y^2 / L^2 \cdot (\theta L)^2 = \theta^2 y^2$):

$$e^{\theta y} \leq 1 + \theta y + \frac{\theta^2 y^2}{2(1 - \theta L/3)}.$$

**Step 3: Take expectation.** Applying $\mathbb{E}[\cdot]$ to (A1) and using $\mathbb{E}[Y] = 0$:

$$\mathbb{E}[e^{\theta Y}] \leq 1 + \frac{\theta^2 \mathbb{E}[Y^2]}{2(1 - \theta L/3)}.$$

**Step 4: Exponentiate.** Using $1 + x \leq e^x$ for all $x \in \mathbb{R}$:

$$\mathbb{E}[e^{\theta Y}] \leq \exp\!\left(\frac{\theta^2 \mathbb{E}[Y^2]}{2(1 - \theta L/3)}\right). \qquad \blacksquare$$

---

## Lemma B: Matrix MGF Bound via Functional Calculus

**Statement.** Let $X$ be a random symmetric matrix in $\mathbb{R}^{d \times d}$ with $\mathbb{E}[X] = 0$ and $\|X\| \leq L$ a.s. Then for $0 < \theta < 3/L$:

$$\mathbb{E}[e^{\theta X}] \preceq \exp\!\left(\frac{\theta^2 \mathbb{E}[X^2]}{2(1 - \theta L/3)}\right)$$

where $\preceq$ denotes the Loewner (positive semidefinite) order.

**Proof.**

**Step 1: Scalar inequality applied via functional calculus.** From (A1), we have the scalar inequality

$$e^{\theta x} \leq 1 + \theta x + \frac{\theta^2 x^2}{2(1 - \theta L/3)} \qquad \text{for all } |x| \leq L.$$

By the **spectral mapping principle**, if $A$ is a symmetric matrix with $\|A\| \leq L$ (so all eigenvalues lie in $[-L, L]$), then applying both sides as functions of $A$ preserves the Loewner order:

$$e^{\theta A} \preceq I + \theta A + \frac{\theta^2 A^2}{2(1 - \theta L/3)}. \tag{B1}$$

*Justification:* Write $A = U \Lambda U^T$ with $\Lambda = \operatorname{diag}(\lambda_1, \ldots, \lambda_d)$, $|\lambda_i| \leq L$. Then (B1) holds eigenvalue-by-eigenvalue since the scalar inequality $e^{\theta\lambda_i} \leq 1 + \theta\lambda_i + \frac{\theta^2\lambda_i^2}{2(1-\theta L/3)}$ holds for each $i$.

**Step 2: Take expectation.** Expectation preserves the Loewner order: if $M(\omega) \preceq N(\omega)$ a.s., then $\mathbb{E}[M] \preceq \mathbb{E}[N]$ (for any vector $u$, $u^T \mathbb{E}[M] u = \mathbb{E}[u^T M u] \leq \mathbb{E}[u^T N u] = u^T \mathbb{E}[N] u$). Applying to (B1) and using $\mathbb{E}[X] = 0$:

$$\mathbb{E}[e^{\theta X}] \preceq I + \frac{\theta^2 \mathbb{E}[X^2]}{2(1 - \theta L/3)}. \tag{B2}$$

**Step 3: The $I + M \preceq e^M$ step.** Let $M = \frac{\theta^2 \mathbb{E}[X^2]}{2(1-\theta L/3)}$. Since $\mathbb{E}[X^2] \succeq 0$ and the scalar coefficient is positive, $M \succeq 0$. The scalar inequality $1 + x \leq e^x$ for $x \geq 0$, applied via the functional calculus to the eigenvalues $\mu_i \geq 0$ of $M$, gives $I + M \preceq e^M$. Therefore:

$$\mathbb{E}[e^{\theta X}] \preceq I + M \preceq e^M = \exp\!\left(\frac{\theta^2 \mathbb{E}[X^2]}{2(1 - \theta L/3)}\right). \qquad \blacksquare$$

---

## Lemma C: Lieb's Concavity Theorem and Transfer Rule

**Statement (Lieb's Concavity Theorem).** For a fixed Hermitian matrix $H$, the map

$$A \mapsto \operatorname{tr} \exp(H + \log A)$$

is concave on the cone of positive definite matrices.

*This is a deep result due to Lieb (1973). We take it as a black box; for a proof, see Lieb, "Convex Trace Functions and the Wigner-Yanase-Dyson Conjecture," Advances in Mathematics 11(3), 267--288, or Bhatia, "Matrix Analysis," Ch. IX.*

**Corollary (Transfer Rule).** Let $H$ be a fixed Hermitian matrix and $Y$ be a random Hermitian matrix independent of $H$. Then:

$$\mathbb{E}\left[\operatorname{tr} \exp(H + Y)\right] \leq \operatorname{tr} \exp\!\left(H + \log \mathbb{E}[e^Y]\right).$$

**Proof of Corollary.**

Define $f(A) = \operatorname{tr} \exp(H + \log A)$ for $A \succ 0$. By Lieb's theorem, $f$ is concave on the PD cone. Set $A = e^Y$, which is positive definite a.s. since $Y$ is Hermitian. Then $f(e^Y) = \operatorname{tr} \exp(H + Y)$.

By Jensen's inequality for the concave real-valued function $f$ on the convex PD cone:

$$\mathbb{E}[f(e^Y)] \leq f(\mathbb{E}[e^Y]).$$

This is valid because $e^Y \succ 0$ a.s. and $\mathbb{E}[e^Y]$ is PD (for any $u \neq 0$, $u^T \mathbb{E}[e^Y] u = \mathbb{E}[u^T e^Y u] > 0$). The left side is $\mathbb{E}[\operatorname{tr}\exp(H+Y)]$. The right side is $\operatorname{tr}\exp(H + \log \mathbb{E}[e^Y])$. $\qquad \blacksquare$

---

## Lemma D: Master Trace Bound

**Statement.** Let $S = \sum_{i=1}^n X_i$ where $X_1, \ldots, X_n$ are independent random symmetric matrices with $\mathbb{E}[X_i] = 0$ and $\|X_i\| \leq L$ a.s. Let $\sigma^2 = \|\sum_{i=1}^n \mathbb{E}[X_i^2]\|$. Then for $0 < \theta < 3/L$:

$$\mathbb{E}\left[\operatorname{tr} e^{\theta S}\right] \leq d \cdot \exp\!\left(\frac{\theta^2 \sigma^2}{2(1 - \theta L/3)}\right).$$

**Proof.**

We apply Lemma C iteratively to peel off one summand at a time.

**Step 1: Peeling off $X_n$.** Write $\theta S = \theta \sum_{i=1}^{n-1} X_i + \theta X_n$. Setting $H = \theta \sum_{i=1}^{n-1} X_i$ (measurable w.r.t. $X_1, \ldots, X_{n-1}$) and $Y = \theta X_n$ (independent of $H$), Lemma C gives:

$$\mathbb{E}\left[\operatorname{tr} \exp(\theta S) \,\Big|\, X_1, \ldots, X_{n-1}\right] \leq \operatorname{tr} \exp\!\left(\theta \sum_{i=1}^{n-1} X_i + \log \mathbb{E}[e^{\theta X_n}]\right).$$

By Lemma B:

$$\mathbb{E}[e^{\theta X_n}] \preceq \exp\!\left(\frac{\theta^2 \mathbb{E}[X_n^2]}{2(1-\theta L/3)}\right).$$

Since $\log$ is operator monotone on $(0, \infty)$ --- i.e., $0 \prec A \preceq B$ implies $\log A \preceq \log B$ (a classical result of Loewner (1934); see Bhatia, *Matrix Analysis*, Theorem V.2.5):

$$\log \mathbb{E}[e^{\theta X_n}] \preceq \frac{\theta^2 \mathbb{E}[X_n^2]}{2(1-\theta L/3)}.$$

(Here $\mathbb{E}[e^{\theta X_n}] \succ 0$ since $e^{\theta X_n} \succ 0$ a.s.)

We now use the monotonicity of the trace exponential: if $A \preceq B$ (both Hermitian), then $\operatorname{tr} e^{H + A} \leq \operatorname{tr} e^{H + B}$ for any Hermitian $H$.

*Proof of this property:* Set $g(t) = \operatorname{tr}\exp(H + A + t(B-A))$ for $t \in [0,1]$. Its derivative is $g'(t) = \operatorname{tr}[(B-A)\exp(H + A + t(B-A))]$. (The identity $\frac{d}{dt}\operatorname{tr} e^{M(t)} = \operatorname{tr}[M'(t) e^{M(t)}]$ holds for the trace by the Duhamel formula and cyclicity of trace.) Since $B - A \succeq 0$ and $\exp(H + A + t(B-A)) \succ 0$, the trace $\operatorname{tr}(PQ) \geq 0$ for $P \succeq 0$, $Q \succeq 0$ (because $\operatorname{tr}(PQ) = \operatorname{tr}(P^{1/2}QP^{1/2}) \geq 0$). Therefore $g'(t) \geq 0$, so $g(0) \leq g(1)$.

Applying this with $A = \log \mathbb{E}[e^{\theta X_n}]$ and $B = \frac{\theta^2 \mathbb{E}[X_n^2]}{2(1-\theta L/3)}$:

$$\mathbb{E}\left[\operatorname{tr} \exp(\theta S) \,\Big|\, X_1, \ldots, X_{n-1}\right] \leq \operatorname{tr} \exp\!\left(\theta \sum_{i=1}^{n-1} X_i + \frac{\theta^2 \mathbb{E}[X_n^2]}{2(1-\theta L/3)}\right).$$

**Step 2: Take full expectation and iterate.** Taking $\mathbb{E}$ over $X_1, \ldots, X_{n-1}$ (tower property):

$$\mathbb{E}\left[\operatorname{tr} e^{\theta S}\right] \leq \mathbb{E}\left[\operatorname{tr} \exp\!\left(\theta \sum_{i=1}^{n-1} X_i + \frac{\theta^2 \mathbb{E}[X_n^2]}{2(1-\theta L/3)}\right)\right].$$

The accumulated deterministic shift is absorbed into $H$. Repeating the peeling for $X_{n-1}, \ldots, X_1$ (at each step, $X_k$ is independent of $H$ which is $\sigma(X_1, \ldots, X_{k-1})$-measurable plus deterministic terms), we obtain:

$$\mathbb{E}\left[\operatorname{tr} e^{\theta S}\right] \leq \operatorname{tr} \exp\!\left(\frac{\theta^2}{2(1-\theta L/3)} \sum_{i=1}^n \mathbb{E}[X_i^2]\right).$$

**Step 3: Trace bound.** Let $V = \sum_{i=1}^n \mathbb{E}[X_i^2]$, so $\sigma^2 = \|V\|$ (largest eigenvalue, since $V \succeq 0$). Let $\mu_1 \geq \cdots \geq \mu_d \geq 0$ be the eigenvalues of $V$. Then:

$$\operatorname{tr} \exp\!\left(\frac{\theta^2 V}{2(1-\theta L/3)}\right) = \sum_{j=1}^d \exp\!\left(\frac{\theta^2 \mu_j}{2(1-\theta L/3)}\right) \leq d \cdot \exp\!\left(\frac{\theta^2 \sigma^2}{2(1-\theta L/3)}\right),$$

using $\mu_j \leq \mu_1 = \sigma^2$ and monotonicity of $\exp$. $\qquad \blacksquare$

---

## Lemma E: Chernoff Optimization

**Statement.** For $t > 0$, $\sigma^2 > 0$, $L > 0$, define

$$\phi(\theta) = -\theta t + \frac{\theta^2 \sigma^2}{2(1 - \theta L/3)}$$

for $0 < \theta < 3/L$. Setting $\theta^* = \frac{t}{\sigma^2 + Lt/3}$ gives

$$\phi(\theta^*) = \frac{-t^2/2}{\sigma^2 + Lt/3}.$$

**Proof.**

**Step 1: Verify feasibility.** We need $\theta^* \in (0, 3/L)$. Clearly $\theta^* > 0$. Also:

$$\theta^* = \frac{3t}{3\sigma^2 + Lt} < \frac{3t}{Lt} = \frac{3}{L},$$

since $3\sigma^2 > 0$. So $\theta^* \in (0, 3/L)$.

**Step 2: Compute $\phi(\theta^*)$.** We have:

$$\theta^* L/3 = \frac{Lt}{3\sigma^2 + Lt}, \qquad 1 - \theta^* L/3 = \frac{3\sigma^2}{3\sigma^2 + Lt}.$$

Using $\sigma^2 + Lt/3 = (3\sigma^2 + Lt)/3$:

$$\frac{(\theta^*)^2 \sigma^2}{2(1 - \theta^* L/3)} = \frac{\sigma^2}{2} \cdot \frac{t^2}{(\sigma^2 + Lt/3)^2} \cdot \frac{3\sigma^2 + Lt}{3\sigma^2} = \frac{\sigma^2}{2} \cdot \frac{9t^2}{(3\sigma^2 + Lt)^2} \cdot \frac{3\sigma^2 + Lt}{3\sigma^2} = \frac{t^2}{2(\sigma^2 + Lt/3)}.$$

And $\theta^* t = \frac{t^2}{\sigma^2 + Lt/3}$. Therefore:

$$\phi(\theta^*) = -\frac{t^2}{\sigma^2 + Lt/3} + \frac{t^2}{2(\sigma^2 + Lt/3)} = \frac{-t^2/2}{\sigma^2 + Lt/3}. \qquad \blacksquare$$

**Remark.** Since the Chernoff bound is valid for every $\theta \in (0, 3/L)$, evaluating at any particular value yields a valid upper bound. The value $\theta^*$ is in fact the exact minimizer of $\phi$, but this optimality is not needed --- only the identity $\phi(\theta^*) = -t^2/(2(\sigma^2 + Lt/3))$ matters.

---

## Main Theorem: Proof of the Matrix Bernstein Inequality

**Proof.**

**Step 1: Symmetrization.** For a symmetric matrix $M$, $\|M\| = \max(\lambda_{\max}(M), \lambda_{\max}(-M))$. By the union bound:

$$\Pr\left[\|S\| \geq t\right] \leq \Pr\left[\lambda_{\max}(S) \geq t\right] + \Pr\left[\lambda_{\max}(-S) \geq t\right].$$

The matrices $-X_1, \ldots, -X_n$ satisfy the same hypotheses (zero mean, bound $L$, same $\sigma^2$). By symmetry, it suffices to bound $\Pr[\lambda_{\max}(S) \geq t]$; the final result carries a factor of 2.

**Step 2: Laplace transform method.** For any $\theta > 0$:

$$\Pr[\lambda_{\max}(S) \geq t] = \Pr[e^{\theta\lambda_{\max}(S)} \geq e^{\theta t}] \leq e^{-\theta t} \cdot \mathbb{E}[e^{\theta\lambda_{\max}(S)}]$$

by Markov's inequality. Now $e^{\theta\lambda_{\max}(S)} = \lambda_{\max}(e^{\theta S})$ (spectral mapping) and $\lambda_{\max}(e^{\theta S}) \leq \operatorname{tr}(e^{\theta S})$ (trace dominates the largest eigenvalue since all eigenvalues of $e^{\theta S}$ are positive). Therefore:

$$\Pr[\lambda_{\max}(S) \geq t] \leq e^{-\theta t} \cdot \mathbb{E}[\operatorname{tr}(e^{\theta S})]. \tag{1}$$

**Step 3: Apply Lemma D.** For $0 < \theta < 3/L$:

$$\mathbb{E}[\operatorname{tr}(e^{\theta S})] \leq d \cdot \exp\!\left(\frac{\theta^2 \sigma^2}{2(1-\theta L/3)}\right).$$

Substituting into (1):

$$\Pr[\lambda_{\max}(S) \geq t] \leq d \cdot \exp\!\left(-\theta t + \frac{\theta^2 \sigma^2}{2(1-\theta L/3)}\right) = d \cdot e^{\phi(\theta)}.$$

**Step 4: Optimize via Lemma E.** Choosing $\theta = \theta^* = \frac{t}{\sigma^2 + Lt/3} \in (0, 3/L)$:

$$\Pr[\lambda_{\max}(S) \geq t] \leq d \cdot \exp\!\left(\frac{-t^2/2}{\sigma^2 + Lt/3}\right).$$

**Step 5: Combine both tails.**

$$\Pr[\|S\| \geq t] \leq 2d \cdot \exp\!\left(\frac{-t^2/2}{\sigma^2 + Lt/3}\right). \qquad \blacksquare$$

---

## Summary of Proof Architecture

| Component | Role | Key technique |
|-----------|------|---------------|
| Lemma A | Scalar MGF bound | Taylor integral remainder + factorial bound $k! \geq 2 \cdot 3^{k-2}$ |
| Lemma B | Lift scalar bound to matrices | Spectral functional calculus + $I + M \preceq e^M$ |
| Lemma C | Decouple sum inside trace-exp | Lieb's concavity theorem (1973) + Jensen's inequality |
| Lemma D | Master trace bound for the sum | Iterative peeling via Lemma C + Lemma B + operator monotonicity of $\log$ |
| Lemma E | Optimize Chernoff parameter | Direct computation of $\theta^*$ |
| Main Theorem | Assemble the pieces | Symmetrization + Markov + Lemmas D, E |
