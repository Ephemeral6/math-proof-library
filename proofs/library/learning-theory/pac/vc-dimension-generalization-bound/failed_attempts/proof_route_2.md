# Route 2: Rademacher Complexity + Dudley Entropy Integral

## Setup and Notation

Let $\mathcal{H}$ be a hypothesis class with VC dimension $d$, and let $\mathcal{F} = \{\ell \circ h : h \in \mathcal{H}\}$ be the associated loss class where $\ell : \{0,1\} \times \{0,1\} \to [0,1]$ is the 0-1 loss. Let $S = (z_1, \ldots, z_n)$ be $n$ i.i.d. samples from $\mathcal{D}$.

---

## Step 1: Rademacher Generalization Bound

**Theorem (Standard).** For any class $\mathcal{F}$ of functions $f: \mathcal{Z} \to [0,1]$, with probability at least $1 - \delta$ over $S$:

$$\sup_{f \in \mathcal{F}} \left|\mathbb{E}[f(z)] - \frac{1}{n}\sum_{i=1}^n f(z_i)\right| \leq 2\mathfrak{R}_n(\mathcal{F}) + \sqrt{\frac{\log(2/\delta)}{2n}}$$

where $\mathfrak{R}_n(\mathcal{F}) = \mathbb{E}_{S,\sigma}\left[\sup_{f \in \mathcal{F}} \frac{1}{n}\sum_{i=1}^n \sigma_i f(z_i)\right]$ is the Rademacher complexity.

**Proof sketch.** Define $\Phi(S) = \sup_{f \in \mathcal{F}} \left|\mathbb{E}[f] - \hat{\mathbb{E}}_S[f]\right|$. This satisfies bounded differences with $c_i = 1/n$ (changing one sample changes the supremum by at most $1/n$). By McDiarmid's inequality:

$$\Pr[\Phi(S) - \mathbb{E}[\Phi(S)] > t] \leq \exp\left(-\frac{2t^2}{\sum_i c_i^2}\right) = \exp(-2nt^2)$$

Setting $t = \sqrt{\log(2/\delta)/(2n)}$ gives $\Phi(S) \leq \mathbb{E}[\Phi(S)] + \sqrt{\log(2/\delta)/(2n)}$ w.p. $\geq 1 - \delta/2$.

By symmetrization (as in Route 1): $\mathbb{E}[\Phi(S)] \leq 2\mathfrak{R}_n(\mathcal{F})$.

Similarly, $\Pr[\Phi(S) < \mathbb{E}[\Phi(S)] - t] \leq \exp(-2nt^2)$, but we only need the upper bound direction. The two-sided statement uses a slightly different argument or simply notes $|R(h) - \hat{R}(h)| \leq |\cdot|$ and applies the one-sided bound to both $\mathcal{F}$ and $-\mathcal{F}$, paying a factor of 2 in $\delta$.

$\blacksquare$

---

## Step 2: Dudley's Entropy Integral Bound

**Theorem (Dudley, 1967).** Let $\mathcal{F}$ be a class of functions with $\|f\|_\infty \leq 1$ for all $f \in \mathcal{F}$. Then:

$$\mathfrak{R}_n(\mathcal{F}) \leq \inf_{\alpha \geq 0}\left(4\alpha + \frac{12}{\sqrt{n}} \int_{\alpha}^{1} \sqrt{\log \mathcal{N}(\epsilon, \mathcal{F}, L_2(\hat{P}_n))} \, d\epsilon \right)$$

where $\mathcal{N}(\epsilon, \mathcal{F}, L_2(\hat{P}_n))$ is the $\epsilon$-covering number of $\mathcal{F}$ under the empirical $L_2$ norm $\|f\|_{L_2(\hat{P}_n)}^2 = \frac{1}{n}\sum_{i=1}^n f(z_i)^2$, and $\hat{P}_n$ is the empirical measure.

**Proof sketch.** This follows from a chaining argument. Fix the sample $S$. Let $\mathcal{F}_k$ be an $\epsilon_k$-net for $\mathcal{F}$ in $L_2(\hat{P}_n)$ at scale $\epsilon_k = 2^{-k}$. For each $f \in \mathcal{F}$, define $\pi_k(f) \in \mathcal{F}_k$ as its nearest neighbor. Then:

$$\frac{1}{n}\sum_{i=1}^n \sigma_i f(z_i) = \frac{1}{n}\sum_{i=1}^n \sigma_i \pi_0(f)(z_i) + \sum_{k=1}^{K} \frac{1}{n}\sum_{i=1}^n \sigma_i [\pi_k(f)(z_i) - \pi_{k-1}(f)(z_i)]$$

Each increment $\pi_k(f) - \pi_{k-1}(f)$ has empirical $L_2$ norm at most $2\epsilon_{k-1} = 2^{-k+2}$. Taking supremum and using sub-Gaussian maximal inequalities:

$$\mathbb{E}_\sigma\left[\max_{f \in \mathcal{F}} \frac{1}{n}\sum_{i=1}^n \sigma_i [\pi_k(f)(z_i) - \pi_{k-1}(f)(z_i)]\right] \leq \frac{2\epsilon_{k-1}\sqrt{2\log|\mathcal{F}_k||\mathcal{F}_{k-1}|}}{\sqrt{n}}$$

Summing over $k$ and taking $K \to \infty$ yields the integral form. $\blacksquare$

---

## Step 3: Covering Numbers from VC Dimension

**Theorem (Haussler, 1995).** If $\mathcal{H}$ has VC dimension $d$, then for any probability measure $Q$ and any $\epsilon > 0$:

$$\mathcal{N}(\epsilon, \mathcal{H}, L_1(Q)) \leq C_0 \cdot \frac{d(4e)^d}{\epsilon^d}$$

for a universal constant $C_0$. In particular, for the 0-1 loss class $\mathcal{F}$ (which inherits VC dimension $d$ from $\mathcal{H}$):

$$\log \mathcal{N}(\epsilon, \mathcal{F}, L_2(\hat{P}_n)) \leq \log \mathcal{N}(\epsilon^2, \mathcal{F}, L_1(\hat{P}_n)) \leq d \log\frac{C}{\epsilon}$$

for a constant $C$ depending on $d$ and universal constants.

**Justification of the norm conversion:** For $\{0,1\}$-valued functions, $f^2 = f$, so $\|f - g\|_{L_2}^2 = \frac{1}{n}\sum_i (f(z_i) - g(z_i))^2$. Since $|f - g| \in \{0,1\}$, we have $(f-g)^2 = |f-g|$, so $\|f - g\|_{L_2}^2 = \|f - g\|_{L_1}$. Hence an $\epsilon^2$-cover in $L_1$ is an $\epsilon$-cover in $L_2$.

Using the Haussler bound:
$$\log \mathcal{N}(\epsilon, \mathcal{F}, L_2(\hat{P}_n)) \leq d \log\frac{C'}{\epsilon^2} = 2d\log\frac{C'}{\epsilon}$$

We simplify: $\log \mathcal{N}(\epsilon, \mathcal{F}, L_2) \leq Ad\log(B/\epsilon)$ for universal constants $A, B$.

---

## Step 4: Evaluating the Dudley Integral

Plugging the covering number bound into Dudley's integral with $\alpha = 1/\sqrt{n}$:

$$\mathfrak{R}_n(\mathcal{F}) \leq \frac{4}{\sqrt{n}} + \frac{12}{\sqrt{n}} \int_{1/\sqrt{n}}^{1} \sqrt{Ad \log(B/\epsilon)} \, d\epsilon$$

Evaluate the integral. With the substitution and noting $\log(B/\epsilon) \leq \log(B\sqrt{n})$ for $\epsilon \geq 1/\sqrt{n}$:

$$\int_{1/\sqrt{n}}^{1} \sqrt{Ad\log(B/\epsilon)} \, d\epsilon \leq \int_0^1 \sqrt{Ad\log(B/\epsilon)} \, d\epsilon$$

For the upper bound, use the substitution $u = \log(B/\epsilon)$, $\epsilon = Be^{-u}$, $d\epsilon = -Be^{-u}du$:

$$\int_0^1 \sqrt{Ad\log(B/\epsilon)} \, d\epsilon = B\int_{\log B}^{\infty} \sqrt{Adu} \cdot e^{-u} \, du \leq B\sqrt{Ad} \int_0^\infty \sqrt{u} \cdot e^{-u} \, du = B\sqrt{Ad} \cdot \Gamma(3/2) = B\sqrt{Ad} \cdot \frac{\sqrt{\pi}}{2}$$

This is a constant (depending on $d$). But this is too loose -- it gives $\sqrt{d}/\sqrt{n}$ without the $\log(n/d)$ factor.

**More careful evaluation.** We need to track the $n$-dependence more carefully. Using the integral directly:

$$\int_{1/\sqrt{n}}^{1} \sqrt{Ad\log(B/\epsilon)} \, d\epsilon$$

Split at $\epsilon_0 = d/n$ (assuming $d \leq n$). Actually, let us use a cleaner approach. Note:

$$\int_{1/\sqrt{n}}^{1} \sqrt{d\log(1/\epsilon)} \, d\epsilon \leq \sqrt{d} \int_{1/\sqrt{n}}^1 \sqrt{\log(1/\epsilon)} \, d\epsilon$$

Via integration by parts, $\int_\alpha^1 \sqrt{\log(1/\epsilon)} \, d\epsilon = O(1)$ for any $\alpha > 0$. So:

$$\mathfrak{R}_n(\mathcal{F}) \leq O\left(\frac{\sqrt{d}}{\sqrt{n}}\right)$$

**But we want the $\log(n/d)$ factor.** The Dudley integral route actually gives the *tighter* bound $O(\sqrt{d/n})$ without the log factor. To recover the stated bound $O(\sqrt{d\log(n/d)/n})$, we can use the simpler approach of Step 3 directly with Massart's finite class lemma instead of the full Dudley integral.

**Alternative via Massart's Lemma.** Given the growth function bound, we use the finite class approach directly.

**Massart's Lemma.** For a finite set $V \subset \mathbb{R}^n$ with $|V| = N$:
$$\mathbb{E}_\sigma\left[\max_{v \in V} \frac{1}{n}\sum_{i=1}^n \sigma_i v_i\right] \leq \frac{\max_{v \in V}\|v\|_2}{n} \cdot \sqrt{2\log N}$$

Apply this to the set of loss vectors $v^{(j)} = (\ell(h_j, z_1), \ldots, \ell(h_j, z_n))$ restricted to the at most $\Pi_{\mathcal{H}}(n) \leq (en/d)^d$ distinct patterns:

$$\mathfrak{R}_n(\mathcal{F}) \leq \frac{\sqrt{n}}{n}\sqrt{2d\log(en/d)} = \sqrt{\frac{2d\log(en/d)}{n}}$$

where we used $\|v\|_2 \leq \sqrt{n}$ since $v \in \{0,1\}^n$.

---

## Step 5: Final Assembly

Combining Step 1 and Step 4 (Massart variant):

With probability $\geq 1 - \delta$:

$$\sup_{h \in \mathcal{H}} |R(h) - \hat{R}_S(h)| \leq 2\sqrt{\frac{2d\log(en/d)}{n}} + \sqrt{\frac{\log(2/\delta)}{2n}}$$

$$= O\left(\sqrt{\frac{d\log(n/d)}{n}}\right) + O\left(\sqrt{\frac{\log(1/\delta)}{n}}\right)$$

$$= O\left(\sqrt{\frac{d\log(n/d) + \log(1/\delta)}{n}}\right)$$

where the last step uses $\sqrt{a} + \sqrt{b} \leq \sqrt{2(a+b)}$.

$\blacksquare$

---

## Remarks

- The Dudley entropy integral actually gives a *tighter* bound of $O(\sqrt{d/n})$ for the Rademacher complexity, but we used Massart's lemma to recover the classical bound with the $\log(n/d)$ factor as stated.
- The Rademacher approach has the advantage of cleanly separating the complexity measure (Rademacher complexity) from the concentration argument (McDiarmid).
- The covering number approach via Dudley can be strengthened to give the optimal rate $\sqrt{d/n}$ using generic chaining (Talagrand's $\gamma_2$ functional), but this is beyond the scope of the stated result.
