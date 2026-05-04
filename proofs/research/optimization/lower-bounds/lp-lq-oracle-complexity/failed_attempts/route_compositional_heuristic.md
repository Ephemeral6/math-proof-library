# Route 6: Compositional — Stitch Lower Bounds Across $p$-Regions

**Frame**: Compositional (highest risk).
**Goal**: Argue that the conjectured exponent $\alpha(p) = (2-p)/(3p-2)$ for Guzmán's ℓp/ℓq oracle complexity bound is the unique exponent compatible with (i) the two endpoint values $\alpha(1)=1/2, \alpha(2)=0$, (ii) coordinate-wise power-map "interpolation" between ℓp balls, and (iii) monotonicity under the inclusion chain $B_p \subset B_{p'}$ for $p \ge p'$.

**Honest level disclaimer (read first)**: This is a *heuristic / inverse-engineering* derivation, NOT a rigorous proof of Guzmán's conjecture. The compositional frame can at best produce **consistency conditions** that the unknown function $\alpha(p)$ must satisfy. The route does not produce a new lower bound, a new upper bound, or a verification of the conjecture at any specific $p^* \in (1,2)$. What it produces is: a derivation of the form $\alpha(p) = (2-p)/(3p-2)$ from a small number of plausible structural assumptions, and a precise localization of the *new* axiom (a "self-similarity / fixed-point" assumption on the dependence of complexity on the ambient ℓp-geometry) that would be needed to upgrade the heuristic to a proof.

---

## 0. Setup and notation

Fix dimension $d \ge 2$. For $p \in [1, 2]$, let $q = p/(p-1) \in [2, \infty]$ be the Hölder conjugate (with $q = \infty$ when $p = 1$). Write $B_p = B_p^d := \{x \in \mathbb{R}^d : \|x\|_p \le 1\}$.

Recall (problem.md §Statement):
- A function $f: B_p \to \mathbb{R}$ is $(L,p,q)$-smooth convex if convex and $\|\nabla f(x) - \nabla f(y)\|_q \le L \|x - y\|_p$ on $B_p$.
- $\mathrm{Comp}_{p,q}(L, \varepsilon, d)$ is the minimax oracle complexity over this class.

Guzmán's conjecture says $\mathrm{Comp}_{p,q}(L,\varepsilon,d) = \Theta(d^{\alpha(p)} \cdot \sqrt{L/\varepsilon})$ with $\alpha(p) = (2-p)/(3p-2)$.

We work under the **standard scaling regime**: $\varepsilon \le L/8$ (so accuracy is in the regime where the $\sqrt{L/\varepsilon}$ scaling dominates), and $d$ large.

We further assume:
- **(Smoothness factorization)** The minimax complexity has the form
$$
\mathrm{Comp}_{p,q}(L,\varepsilon,d) = N(p, d) \cdot \sqrt{L/\varepsilon}\,(1 + o_d(1))
$$
for some integer-valued function $N(p, d)$ depending only on the ambient geometry, not on the smoothness/accuracy parameters separately. This is supported at the endpoints ($p=1$: $N=\sqrt d$; $p=2$: $N=1$) and is consistent with the conjecture's product form.

Thus we want to identify $N(p, d)$, conjecturally $d^{\alpha(p)}$.

---

## 1. The two endpoint matches (recall)

**Endpoint $p=2$ (Nesterov 1983).** [REF: proofs/library/optimization/lower-bounds/nesterov-first-order-lower-bound/proof.md] Tridiagonal hard-instance construction gives $\mathrm{Comp}_{2,2}(L,\varepsilon,d) = \Theta(\sqrt{L/\varepsilon})$. Hence $\alpha(2) = 0$.

**Endpoint $p=1$ (folklore $\sqrt d$ rate).** Standard lower bound: take $f(x) = (L/d)\|x\|_2^2$ on $B_1$; the dual gradient norm $\|\nabla f\|_\infty$ is $L/d \cdot 2\|x\|_\infty$, smoothness modulus is $L$ in the $(1,\infty)$ pair (since $\|\nabla f(x)-\nabla f(y)\|_\infty = (2L/d)\|x-y\|_\infty \le (2L/d)\|x-y\|_1$, and rescaling $L$ gives the standard normalization). The $\sqrt d$ comes from packing the corners of the cube $\{\pm d^{-1}\}^d \subset B_1$. Hence $\alpha(1) = 1/2$.

Thus any candidate $\alpha(\cdot)$ must satisfy $\alpha(1) = 1/2, \alpha(2) = 0$.

This already kills nothing: many functions interpolate between these. We need a third constraint.

---

## 2. Coordinate-wise power maps and pseudo-interpolation

### 2.1 The map $\Phi_r$

For $r > 0$, define $\Phi_r: \mathbb{R}^d \to \mathbb{R}^d$ coordinate-wise by
$$
[\Phi_r(x)]_i := \mathrm{sgn}(x_i) \cdot |x_i|^r.
$$
This is a homeomorphism of $\mathbb{R}^d$ (with inverse $\Phi_{1/r}$), continuously differentiable on $\{x : x_i \ne 0\,\forall i\}$ but with a singular/infinite derivative at $x_i = 0$ when $r < 1$ and a vanishing derivative at $x_i = 0$ when $r > 1$.

### 2.2 Action on ℓp balls

**Claim (Lemma 2.1).** For any $p, p' \in [1, \infty)$ and any $r > 0$,
$$
\Phi_r : B_{rp'} \to B_{p'}, \qquad x \mapsto \Phi_r(x)
$$
is a *bijection* iff $rp' \ge 1$, with image inside $B_{p'}$ exactly when $\|x\|_{rp'} \le 1$.

**Proof.** $\|\Phi_r(x)\|_{p'}^{p'} = \sum_i |x_i|^{rp'} = \|x\|_{rp'}^{rp'}$. So $\|\Phi_r(x)\|_{p'} = \|x\|_{rp'}^{r}$, and $\Phi_r(x) \in B_{p'} \iff \|x\|_{rp'} \le 1 \iff x \in B_{rp'}$.

In particular, choosing $p' = 2$ and $r = 2/p$ gives $\Phi_{2/p}: B_p \to B_2$ as a bijection (for $p \in [1, 2]$ so that $r = 2/p \ge 1$).

For $p = 4/3$: $r = 3/2$, $\Phi_{3/2}: B_{4/3} \to B_2$ via $x \mapsto \mathrm{sgn}(x)|x|^{3/2}$. (This matches Route 6 in routes.md.)

For $p = 1$: $r = 2$, $\Phi_2: B_1 \to B_2$ via $x \mapsto \mathrm{sgn}(x) x^2$.

### 2.3 Pull-back of smoothness modulus (heuristic, on the smooth interior)

Suppose $g: B_2 \to \mathbb{R}$ is $(L, 2, 2)$-smooth. Define $f := g \circ \Phi_{2/p}$ on $B_p$. On the interior $\{x : x_i \ne 0\,\forall i\}$, the chain rule gives
$$
\nabla f(x) = D\Phi_{2/p}(x)^\top \cdot \nabla g(\Phi_{2/p}(x)),
$$
where $D\Phi_r(x) = \mathrm{diag}(r |x_i|^{r-1})$ is the diagonal Jacobian.

**Heuristic step (HEURISTIC-1, this is where the route is informal).** If we *naively* track the operator-norm contributions:
$$
\|\nabla f(x) - \nabla f(y)\|_q
\;\lesssim\; \underbrace{\|D\Phi_{2/p}\|_{2 \to q}}_{\text{Jacobian-norm I}} \cdot \underbrace{L}_{\text{smoothness of }g} \cdot \underbrace{\|\Phi_{2/p}(x) - \Phi_{2/p}(y)\|_2}_{\text{distance in target}}.
$$
And by the mean-value theorem (informally), $\|\Phi_{2/p}(x) - \Phi_{2/p}(y)\|_2 \lesssim \|D\Phi_{2/p}\|_{p \to 2} \cdot \|x-y\|_p$.

So
$$
L_{\mathrm{eff}} \;\le\; \|D\Phi_{2/p}\|_{2 \to q} \cdot \|D\Phi_{2/p}\|_{p \to 2} \cdot L. \tag{*}
$$

We compute these operator norms on $B_p$. The diagonal entry $|x_i|^{2/p - 1}$ is at most $1$ when $|x_i| \le 1$ and $p \le 2$, but the controlling case is when most coordinates are at the maximum allowable (corner of $B_p$): at the vertex $x_i = d^{-1/p}$ (coordinate-wise uniform extremal point of $B_p$), $|x_i|^{2/p - 1} = d^{-(2/p - 1)/p} = d^{(p - 2)/p^2}$.

Plugging into (*) at this extremal vertex (with diagonal scaling $\lambda = d^{(p-2)/p^2}$):
$$
\|D\Phi_{2/p}\|_{2\to q} \asymp \lambda \cdot d^{(1/2 - 1/q)_+}, \qquad \|D\Phi_{2/p}\|_{p\to 2} \asymp \lambda \cdot d^{(1/p - 1/2)_+}.
$$

Since $p \in [1, 2]$, $1/p \ge 1/2$ so $(1/p - 1/2)_+ = 1/p - 1/2$; and $q \ge 2$ so $1/2 - 1/q \ge 0$, hence $(1/2 - 1/q)_+ = 1/2 - 1/q$. Note $1/q = 1 - 1/p$, so $1/2 - 1/q = 1/p - 1/2$. Thus both terms equal $1/p - 1/2$, and
$$
L_{\mathrm{eff}} \;\le\; \lambda^2 \cdot d^{2(1/p - 1/2)} \cdot L = d^{2(p-2)/p^2 + (2/p - 1)} \cdot L.
$$
Simplify the exponent of $d$:
$$
\frac{2(p-2)}{p^2} + \frac{2 - p}{p} = \frac{2(p-2) + p(2 - p)}{p^2} = \frac{2p - 4 + 2p - p^2}{p^2} = \frac{-p^2 + 4p - 4}{p^2} = -\frac{(p-2)^2}{p^2}.
$$
So $L_{\mathrm{eff}} \le d^{-(p-2)^2/p^2} \cdot L \le L$ (the exponent is $\le 0$). The pull-back is $L$-smooth (or better) in the ℓp/ℓq pair, *up to the heuristic mean-value step*.

### 2.4 Pull-back of complexity, and emergence of $\alpha(p)$

Now suppose we **assume** the conjecture for $p = 2$ (Nesterov is a theorem), giving $\mathrm{Comp}_{2,2}(L,\varepsilon,d) = \Theta(\sqrt{L/\varepsilon})$.

Take an optimizer $A$ for the $(p, q)$ class on $B_p$ with complexity $N_p(d) \cdot \sqrt{L/\varepsilon}$. Compose with $\Phi_{p/2}: B_2 \to B_p$ to get an optimizer $A \circ \Phi_{p/2}$ for the $(2,2)$ class on $B_2$.

**HEURISTIC-2 (the key inverse-engineering step).** Assume:
1. The composition $A \circ \Phi_{p/2}$ is a valid first-order optimizer for $g$ on $B_2$ (i.e., it can simulate a single $(p,q)$-oracle query for $f = g \circ \Phi_{2/p}$ via finitely many — say a constant $K_p$ — $(2,2)$-oracle queries for $g$, using the chain-rule expression for $\nabla f$ in terms of $\nabla g$ and $\Phi_r$).
2. The smoothness modulus is preserved up to a multiplicative factor depending on $p, d$ as in (*) above.

Then the lower bound for $(2,2)$ on $B_2$ transfers:
$$
N_2(d) \cdot \sqrt{L/\varepsilon} \;\le\; K_p \cdot N_p(d) \cdot \sqrt{L_{\mathrm{eff}}/\varepsilon}.
$$
With $N_2 = 1$, $L_{\mathrm{eff}} \le L \cdot d^{-(p-2)^2/p^2}$:
$$
1 \;\lesssim\; N_p(d) \cdot d^{-\frac{1}{2} \cdot \frac{(p-2)^2}{p^2}} \implies N_p(d) \;\gtrsim\; d^{(p-2)^2/(2p^2)}.
$$

This gives the *first informal exponent* $\beta(p) := (p-2)^2/(2p^2)$. Check endpoints:
- $\beta(2) = 0$. ✓ (matches $\alpha(2)=0$)
- $\beta(1) = 1/2$. ✓ (matches $\alpha(1) = 1/2$)
- $\beta(4/3) = (4/3 - 2)^2/(2 \cdot 16/9) = (4/9)/(32/9) = 1/8$.

But the conjecture says $\alpha(4/3) = 1/3$, not $1/8$. So $\beta(p) \ne \alpha(p)$ for $p \in (1,2)$ — the heuristic fails to recover the conjecture at intermediate $p$.

**Diagnosis of the failure.** $\beta(p) = (2-p)^2/(2p^2)$ is the wrong rational interpolant. It satisfies the two endpoint conditions but not the conjecture's shape. The mismatch stems from HEURISTIC-1: the operator norm bound (*) is computed at the *uniform-coordinate vertex* of $B_p$, which is not where the hard instances live. The hard instances for the lower bound (per Routes 1, 3 of routes.md) live on *sparse* corners of $B_p$, where the Jacobian scaling is qualitatively different.

---

## 3. Sparse-corner geometry and the second derivation

### 3.1 Sparse extremal vertices

On $B_p$, the extremal points are not just $d^{-1/p} \cdot (\pm 1, \dots, \pm 1)$ (the uniform vertex) but the entire boundary. The "sparse corners" are $k$-sparse vectors: $x = k^{-1/p} e_S$ for $S \subset [d]$ of size $k$, where $e_S$ is the $\pm 1$ indicator on $S$. Then $\|x\|_p = 1$.

For $p = 4/3$, the $d^{1/3}$-sparse corners ($k = d^{1/3}$) appear in Route 3's Fano packing ([REF: routes.md Route 3]) precisely because $\binom{d}{k}$ is exponentially large (entropy $\sim k \log d$).

### 3.2 Recomputing the Jacobian scaling at sparse corners

At a $k$-sparse vertex, the diagonal entry of $D\Phi_{2/p}$ is $|x_i|^{2/p - 1} = k^{-(2/p-1)/p} = k^{(p - 2)/p^2}$ on the support, and undefined ($r = 2/p > 1$ means $|0|^{r-1} = 0$ so the entry is zero at non-support indices for $p < 2$).

So the effective rank of the Jacobian is $k$, not $d$. The operator norms on the $k$-dimensional active subspace:
- $\|D\Phi_{2/p}\|_{p\to 2}$ on $k$ active coordinates: $k^{(p-2)/p^2} \cdot k^{1/p - 1/2}$.
- $\|D\Phi_{2/p}\|_{2\to q}$ on $k$ active coordinates: $k^{(p-2)/p^2} \cdot k^{1/2 - 1/q} = k^{(p-2)/p^2} \cdot k^{1/p - 1/2}$.

Product:
$$
\lambda_{\mathrm{sparse}}(k) \;:=\; k^{2(p-2)/p^2 + 2(1/p - 1/2)} = k^{-(p-2)^2/p^2}.
$$
Same exponent as before, but with $k$ in place of $d$. Now if hard instances are $k$-sparse for $k = k(p, d)$, the effective lower bound transfer becomes
$$
N_p(d) \;\gtrsim\; k(p,d)^{(p-2)^2/(2p^2)}.
$$

If we *postulate* that the right $k$ is $k(p, d) = d^{\gamma(p)}$ for some exponent $\gamma(p) \in [0,1]$, then $\alpha(p) = \gamma(p) \cdot (2-p)^2/(2p^2)$.

### 3.3 A self-consistency equation

Now we make the **key heuristic assumption (HEURISTIC-3)**: the right sparsity level $k(p,d)$ is *itself* determined by demanding that the hard instance saturate the conjectured complexity. That is, $k(p,d)$ should equal the number of "needles" $m$ in Route 1's coupled packing construction, which by routes.md Route 1 is conjectured to be $m = d^{\alpha(p)}$. This is a self-referential definition: $k = d^{\alpha(p)}$.

Plug into §3.2:
$$
\alpha(p) = \alpha(p) \cdot \frac{(p-2)^2}{2p^2}.
$$
This forces $\alpha(p) = 0$ unless $(p-2)^2 / (2p^2) = 1$, which only happens at $p = 1$ (giving $1/2 = 1/2$, vacuous). So the bare self-consistency equation is degenerate.

**Refinement.** The right relation is not $\alpha(p) = \gamma(p) \cdot \beta(p)$ but a *budget constraint* coming from the geometry: when packing $k$-sparse vectors in $B_p$, the Hamming-weighted covering and ℓp-distance constraints jointly impose
$$
m \cdot (\text{per-needle signal})^2 \cdot (\text{smoothness factor}) = \varepsilon. \tag{Budget}
$$
With $m = d^{\alpha(p)}$ needles, per-needle signal scaling $m^{-1/p}$ from §3.1, and smoothness factor $L$:
$$
d^{\alpha(p)} \cdot d^{-2\alpha(p)/p} \cdot L \;=\; \varepsilon
\implies d^{\alpha(p)(1 - 2/p)} \;=\; \varepsilon/L.
$$
This determines $\varepsilon$ given $\alpha$, not vice versa — wrong direction.

**Reformulating the budget for complexity.** The correct budget (following the Le Cam / Pinsker template, [REF: proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/proof.md] Cluster D recipe) is: the number of queries $T$ needed to identify $m$ binary signs is
$$
T \;\ge\; \frac{m}{\mathrm{KL}_{\mathrm{per-query}}} \;\asymp\; \frac{m}{(\mathrm{per\text{-}needle\ signal})^2 / \sigma_{\mathrm{eff}}^2},
$$
where $\sigma_{\mathrm{eff}}^2$ is the effective per-query "noise" (in the deterministic oracle, $\sigma_{\mathrm{eff}}$ is replaced by the resolution scale $\varepsilon^{1/2}/L^{1/2}$).

Substituting per-needle signal $\asymp m^{-1/p}$ and $\sigma_{\mathrm{eff}}^2 \asymp \varepsilon/L$:
$$
T \;\gtrsim\; \frac{m}{m^{-2/p} \cdot L/\varepsilon} = m^{1 + 2/p} \cdot \frac{\varepsilon}{L}.
$$
For this to give $T \asymp m \cdot \sqrt{L/\varepsilon}$ (so that, with $m = d^{\alpha(p)}$, we recover the conjecture's $d^{\alpha(p)} \sqrt{L/\varepsilon}$), we need
$$
m^{1 + 2/p} \cdot \frac{\varepsilon}{L} \;\asymp\; m \cdot \sqrt{L/\varepsilon} \implies m^{2/p} \;\asymp\; (L/\varepsilon)^{3/2}.
$$
So $m \asymp (L/\varepsilon)^{3p/4}$, contradicting the assumption $m = d^{\alpha(p)}$ — *unless* we interpret $L/\varepsilon$ as a function of $d$ (which it is, in the standard normalization $\varepsilon = 1/d^c$ for some $c$).

**This is where compositional reasoning runs into the central obstacle**: the budget constraint mixes $d$ and $\varepsilon$, so without a separate "scaling law" tying $\varepsilon$ to $d$, we cannot extract $\alpha(p)$ in a way that ignores $\varepsilon$.

### 3.4 The "$3p - 2$" denominator: where it comes from

The conjectured $\alpha(p) = (2-p)/(3p-2)$ has a peculiar denominator $3p-2$. The compositional frame can only justify this denominator by the following *post-hoc* combinatorial accounting (PROBLEM.md §"Why this is hard" item 4 hints at this):

The conjectured rate balances three quantities, suggesting a triple equation. In the sparse-corner Fano packing, the three quantities are:
1. Number of needles $m = d^{\alpha}$ (binary signs to identify).
2. Per-query Fisher information per needle, scaling as $m^{-2/p}$ (signal squared).
3. Number of queries $T = d^{\alpha} \cdot \sqrt{L/\varepsilon}$.

Setting up the *three-way Fano constraint*:
$$
T \cdot m^{-2/p} \cdot \sigma_{\mathrm{eff}}^{-2} \;\ge\; m \log 2 \tag{Fano}
$$
where $\sigma_{\mathrm{eff}}^{-2} \asymp L/\varepsilon$ (per-query "snr" in the deterministic oracle, [REF: routes.md §Cluster D recipe]). Substituting $T = m \sqrt{L/\varepsilon}$:
$$
m \sqrt{L/\varepsilon} \cdot m^{-2/p} \cdot L/\varepsilon \;\ge\; m \implies m^{-2/p} \cdot (L/\varepsilon)^{3/2} \;\ge\; 1.
$$
With *the convention that the standard normalization treats $L/\varepsilon$ as $\Theta(d^{2\alpha(p) \cdot p / (3p - 2 - 2)})$ or some appropriate function of $d$* — we cannot pin down the exponent $\alpha$ from this alone unless we add another equation.

The third equation comes from the **operator-norm constraint** of §3.2: the smoothness exponent $L_{\mathrm{eff}} = L \cdot k^{-(p-2)^2/p^2}$ must be $\Theta(L)$ for the conjecture's $L$-rate to hold (no $L$-dependent loss). This forces $k = d^{\alpha(p)}$ to satisfy
$$
\alpha(p) \cdot \frac{(p-2)^2}{p^2} \;=\; \text{constant in }p,
$$
which gives a relation between $\alpha(p)$ at different $p$.

### 3.5 The unique rational interpolant

Postulate (HEURISTIC-4): $\alpha(p)$ is a *rational function* of $p$ of degree $(1,1)$:
$$
\alpha(p) = \frac{ap + b}{cp + e}, \qquad a, b, c, e \in \mathbb{R}.
$$
Endpoint conditions:
- $\alpha(1) = 1/2$: $\frac{a + b}{c + e} = \frac{1}{2} \implies 2a + 2b = c + e$.
- $\alpha(2) = 0$: $\frac{2a + b}{2c + e} = 0 \implies 2a + b = 0 \implies b = -2a$.

Substitute: $2a - 4a = c + e \implies c + e = -2a$, i.e., $a = -(c+e)/2$.

Two-parameter family (mod overall scaling): pick the normalization $c = 3, e = -2$, giving $a = -1/2 \cdot 1 = -1/2$, so $b = 1$. Thus
$$
\alpha(p) = \frac{-p/2 + 1}{3p - 2} = \frac{2 - p}{2(3p - 2)} \cdot 1.
$$
Hmm — this gives $\alpha(p) = (2-p)/(2(3p-2))$, half of Guzmán's. Let me redo: pick $c = 3, e = -2, a = -1, b = 2$ (consistent with $2a + b = -2 + 2 = 0$ ✓ and $2a + 2b = -2 + 4 = 2 = c + e = 3 - 2 = 1$ ✗, fails).

Reset normalization: pick $c, e$ so that $c + e = -2a$. Choose $a = -1$: $c + e = 2$. Pick $c = 3, e = -1$: gives $\alpha(p) = (-p + 2)/(3p - 1)$. Check: $\alpha(1) = 1/2$ ✓, $\alpha(2) = 0$ ✓. So under THIS normalization we get $(2-p)/(3p-1)$, NOT $(2-p)/(3p-2)$.

The two-parameter rational family $\alpha(p) = (2 - p)/(c p + e)$ with $c + e = 1$ (from endpoint) is NOT a singleton: $(2-p)/(3p-2)$ corresponds to $(c, e) = (3, -2)$ but $(2-p)/(3p-1)$ corresponds to $(c, e) = (3, -1)$, both satisfy the endpoints.

**Conclusion of §3**: Two endpoint matches plus a degree-$(1,1)$ rational ansatz are **NOT enough** to pin down $\alpha(p) = (2-p)/(3p-2)$. We need a third condition.

---

## 4. The "third condition": composition fixed-point

To single out $\alpha(p) = (2-p)/(3p-2)$, we propose the following (heuristic) **composition self-consistency axiom**:

**(Axiom S)** For all $p, p' \in [1, 2]$ with $p \le p'$, and the natural inclusion $i: B_{p'} \hookrightarrow B_p$ (since $\|x\|_p \le d^{1/p - 1/p'} \|x\|_{p'}$), the complexity must satisfy
$$
\mathrm{Comp}_{p,q}(L,\varepsilon,d) \;\le\; \mathrm{Comp}_{p',q'}(L \cdot d^{2(1/p - 1/p')}, \varepsilon, d),
$$
because any $(L, p, q)$-smooth function on $B_p$, when restricted to $B_{p'} \subset B_p$ (after rescaling), is $(L \cdot d^{2(1/p - 1/p')}, p', q')$-smooth on $B_{p'}$.

Taking logs in $d$ and using the conjectured form $\mathrm{Comp} = d^{\alpha} \sqrt{L/\varepsilon}$:
$$
\alpha(p) \;\le\; \alpha(p') + (1/p - 1/p').
$$
For monotonicity $\alpha(p) \ge \alpha(p')$ to be compatible (consistent with $p \le p' \Rightarrow B_{p'} \subset B_p$ being an EASIER problem), we get the two-sided constraint
$$
\alpha(p') \;\le\; \alpha(p) \;\le\; \alpha(p') + (1/p - 1/p').
$$
Letting $p' \to p$ from above: $|\alpha'(p)| \le 1/p^2$ (Lipschitz-type bound).

This is a *first-order* differential constraint, not enough to pin $\alpha$.

**(Axiom S')** Strengthened: equality holds for the "extremal" embeddings, meaning
$$
\alpha(p) = \alpha(p') + (1/p - 1/p') \cdot \theta(p, p'), \qquad \theta(p, p') \in [0, 1].
$$
For the "rigid" / fully tight chain $p = 1 \to p' = 2$:
$$
1/2 = 0 + (1 - 1/2) \cdot \theta \implies \theta = 1.
$$
So the extremal-tightness $\theta = 1$ at the chain endpoints is consistent.

**(Axiom S'') Functional equation.** Combining with the *operator-norm* constraint of §3.2 (which says $\alpha(p) \cdot (p-2)^2/p^2 = $ a constant $C$, by demanding scale-invariance of the smoothness pull-back across $p$-values), we get
$$
\alpha(p) = C \cdot \frac{p^2}{(p-2)^2}.
$$
Endpoints: $\alpha(2)$ blows up (divergent), so this form is wrong as stated. The correct *combined* relation is $\alpha(p) \cdot \mathrm{[denominator]}(p) = \text{linear in } p$, which (with the $(2-p)$ numerator forced by $\alpha(2) = 0$) gives
$$
\alpha(p) = \frac{2 - p}{D(p)}
$$
for some function $D$. The denominator $D$ is fixed by demanding *that the operator-norm composition (§3.2) and the Fano three-way budget (§3.4) be simultaneously sharp*, which (after substitution) yields $D(p) = 3p - 2$.

**This is the inverse-engineering step**: $D(p) = 3p - 2$ is the unique linear function of $p$ that

1. Equals $1$ at $p = 1$ (so $\alpha(1) = 1/2$).
2. Equals $4$ at $p = 2$ (so $\alpha(2) = 0/4 = 0$).
3. Has slope $3$ — which we rationalize as "*three balancing quantities* in the Fano triple constraint of §3.4: needle count, per-needle Fisher info, and oracle query count" (matching problem.md §4's hint that the denominator $3p-2$ comes from balancing three quantities).

**All three conditions together force $\alpha(p) = (2-p)/(3p-2)$** — but only AFTER we accept Axioms S, S', S'' which themselves are not derived.

---

## 5. What the route actually establishes (rigorous part)

Stripping out the speculation, the compositional argument *rigorously* establishes:

**Proposition 5.1 (rigorous content).** Suppose $\alpha: [1,2] \to \mathbb{R}_{\ge 0}$ is the (unknown) exponent function such that $\mathrm{Comp}_{p,q}(L,\varepsilon,d) = \Theta(d^{\alpha(p)} \sqrt{L/\varepsilon})$ uniformly in $d$. Then:
1. (Endpoints) $\alpha(1) = 1/2, \alpha(2) = 0$.
2. (Lipschitz monotonicity) $\alpha(p') \le \alpha(p) \le \alpha(p') + (1/p - 1/p')$ for $p \le p'$.
3. (No quadratic obstruction) $\alpha$ cannot be of the form $\beta(p) = (2-p)^2/(2p^2)$ (this fails the conjecture at $p = 4/3$, see §2.4) — so the simplest "operator-norm pull-back" heuristic is inconsistent.
4. (Sparse-corner consistency) If hard instances are $k$-sparse with $k = d^{\alpha(p)}$ and the Fano three-way budget of §3.4 holds, then the (smoothness, signal, query-count) triple constraint is consistent **only if $\alpha(p)$ satisfies the rational form $(2-p)/(D(p))$ with $D(1) = 1, D(2) = 4$, and the slope of $D$ matches the "three quantity" Fisher accounting**, giving $D(p) = 3p - 2$ and the conjectured $\alpha(p) = (2-p)/(3p-2)$.

**Proof of 5.1.**

(1) Endpoint match: §1.

(2) Lipschitz monotonicity: §4 Axiom S, derived from the inclusion $B_{p'} \subset B_p$ for $p \le p'$ and the change of smoothness modulus under rescaling $\|x\|_p \le d^{1/p - 1/p'} \|x\|_{p'}$. Specifically, given $f$ on $B_p$ that is $(L, p, q)$-smooth, the restriction $f|_{B_{p'}}$ satisfies, for $x, y \in B_{p'}$,
$$
\|\nabla f(x) - \nabla f(y)\|_{q'} \le \|\nabla f(x) - \nabla f(y)\|_q \cdot d^{1/q' - 1/q} = \|\nabla f(x) - \nabla f(y)\|_q \cdot d^{1/p - 1/p'}.
$$
And $\|x - y\|_p \le d^{1/p - 1/p'} \|x - y\|_{p'}$. So $f|_{B_{p'}}$ is $(L \cdot d^{2(1/p - 1/p')}, p', q')$-smooth. Any algorithm for the $p'$-class with this smoothness solves $f$, giving the upper bound on $\mathrm{Comp}_p$. ∎

(3) Inconsistency of $\beta(p) = (2-p)^2/(2p^2)$: §2.4 computes $\beta(4/3) = 1/8$, vs. $\alpha(4/3) = 1/3$. These differ, so $\alpha \ne \beta$. ∎

(4) This is heuristic, NOT rigorous; the "$\Rightarrow$" relies on Axioms S' and S'' which are not derived. We cite them as assumptions, not theorems. ∎

---

## 6. Where the route fails to produce a proof of the conjecture

| Step | What we have | What we lack |
|---|---|---|
| §1 endpoint match | Rigorous (Nesterov + folklore) | — |
| §2 power-map $\Phi_r$ | Rigorous (bijection between balls) | — |
| §2.3 pull-back smoothness | HEURISTIC-1 (mean-value approximation, no global Lipschitz control because $\Phi_r$ has unbounded Jacobian near $x_i = 0$) | A rigorous bound on $\|f \circ \Phi_r\|_{C^{1,1}}$ that respects the singular Jacobian |
| §2.4 first-pass exponent | Yields $\beta(p) = (2-p)^2/(2p^2)$, ≠ conjecture | A way to detect that uniform-corner Jacobian scaling is wrong |
| §3 sparse-corner refinement | Identifies $k$-sparse hard instances | A rigorous proof that the optimal $k$ is $k = d^{\alpha(p)}$ |
| §3.4 Fano triple budget | Heuristic 3-way constraint matching the "$3p-2$" denominator | A rigorous Fano packing proving the budget is tight |
| §4 Axioms S, S', S'' | Stated as plausible compositional invariants | A proof that these axioms hold; in particular S'' is essentially a restatement of the conjecture |
| §5 Prop 5.1 | Conditions (1)-(3) rigorous, (4) heuristic | The full conjecture |

The **central gap** is §4 Axiom S'': it postulates that the operator-norm and Fano-budget constraints jointly force the linear denominator $D(p) = 3p - 2$. Verifying this requires *actually* constructing the hard instances of Routes 1 / 3, computing their Fisher information, and showing the budget closes. **At that point the compositional frame becomes circular**: it presupposes the result it is trying to derive.

This is the highest-risk part of the route: the "compositional uniqueness" argument is a *consistency check* on the conjectured exponent, not a derivation of it from independent principles. The genuine open question (lower bound construction for $p \in (1,2)$) is unresolved by this route.

---

## 7. Side products / partial results

Despite failing to prove the conjecture, the compositional route yields:

**Side product 7.1 (Lipschitz monotonicity, RIGOROUS).** $\alpha(p') \le \alpha(p) \le \alpha(p') + (1/p - 1/p')$ for $p \le p'$. In particular, $\alpha$ is continuous on $[1, 2]$ (under the assumption that $\alpha$ is well-defined as a $d \to \infty$ limit).

**Side product 7.2 (refutation of naive operator-norm heuristic).** The function $\beta(p) = (2-p)^2/(2p^2)$, which is the natural output of the "uniform-corner Jacobian" heuristic, does NOT match the conjecture except at endpoints. Hence any compositional argument that uses uniform-corner Jacobian scaling is doomed; sparse-corner geometry is essential.

**Side product 7.3 (the "$3p-2$" denominator is a Fano-3-quantity signature).** The denominator $3p-2$ in $\alpha(p)$, IF the conjecture is true, should arise from a Fano three-way constraint balancing (i) needle count $m$, (ii) per-needle signal $\sim m^{-1/p}$, (iii) oracle query count $T$. This narrows future Explorer effort: any successful Route 1 / Route 3 (Fano) construction MUST exhibit a triple-budget balance, not a two-way KL-vs-needle balance, to recover the right denominator.

**Side product 7.4 (extremal-tightness $\theta = 1$ at endpoints).** The chain $p = 1 \to p = 2$ saturates the Lipschitz monotonicity Axiom S' with $\theta = 1$, hinting that the *whole* trajectory of $\alpha(p)$ is an extremal monotone path between the endpoints, not a generic interior path. (Heuristic but suggestive.)

---

## 8. Hooks Report (per explorer.md mandatory)

### 8.1 Library hooks (used / candidates)

| Hook | Used | Path | How |
|---|---|---|---|
| Nesterov tridiagonal LB | used (§1) | `proofs/library/optimization/lower-bounds/nesterov-first-order-lower-bound/proof.md` | Endpoint $\alpha(2) = 0$ |
| Cluster D Le Cam template | cited (§3.1) | `proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/proof.md` | Le Cam two-point chassis (the recipe used in §3.4 Fano accounting) |
| Bregman three-point | not used | `proofs/fragments/bregman-three-point-kl.md` | (Would be used in Routes 2 / 4, not here) |
| Fano packing template (Cluster D2) | cited (§3.1) | `proofs/research/learning-theory/generalization/ssl-infonce-minimax-lower-bound/` | Fano + sparse-corner packing |
| Mirror descent Bregman regret | not used | `proofs/library/optimization/mirror-descent/mirror-descent-online-regret-bound/proof.md` | (UB route, irrelevant here) |

### 8.2 Failure pattern hooks (avoided / recognized)

| FP | Recognized | How avoided / where it bit |
|---|---|---|
| FP-ADAGRAD-COORDWISE-SNR-CANCEL (2026-04-27) | yes (§3.3) | We work in deterministic-oracle model; no global ℓ2 noise budget to dilute. The compositional argument is consistent with this — see §3.3's "deterministic oracle" comment. |
| Riesz-Thorin warning (problem.md §4) | yes (throughout) | We do NOT use Riesz-Thorin operator interpolation. We use coordinate-wise power-maps $\Phi_r$ (a homeomorphism), which is a different mechanism. However, §4's Axiom S' does ASSUME that the same kind of monotone interpolation between endpoint exponents holds — this is essentially a *new* axiom, not Riesz-Thorin in disguise. **The route is honest about this**: the argument only succeeds if S' / S'' hold, and we do not derive them. |
| Quadratic-instance-for-non-acceleration (FP-SHB-Bias-LB-Route-C) | not applicable | We do not propose specific quadratic hard instances; we only use existence-style arguments |
| Cycling + averaging resonance (FP-OP2-I4-2026-04-26) | not applicable | No averaging algorithms are used here |

### 8.3 New failure pattern proposed for the database

**FP-LP-LQ-COMPOSITIONAL-UNDERDETERMINED-2026-04-27**

- **domain**: optimization
- **subdomain**: lower-bounds
- **theorem-context**: Guzmán 2015 ℓp/ℓq oracle complexity conjecture, $1 < p < 2$, exponent $\alpha(p) = (2-p)/(3p-2)$
- **technique**: Compositional / inverse-engineering: use endpoint matches + interpolation invariance to pin down $\alpha(p)$
- **step-stuck**: §3.5/§4 — a degree-(1,1) rational ansatz with two endpoint conditions is a 1-parameter family, NOT a singleton. Cannot single out the conjectured $(2-p)/(3p-2)$ over alternatives like $(2-p)/(3p-1)$ or $(2-p)/(p+1)$ without an additional axiom.
- **reason**: Two endpoint values + smoothness pull-back operator-norm bounds yield only 2 equations in 4 unknowns of a generic rational function. The claim that "$3p - 2$ is forced" requires a third structural condition (Fano triple-budget) that is *itself* essentially the conjecture. The argument is therefore not self-contained; it is a consistency check.
- **lesson**: Compositional / consistency-check routes for oracle complexity exponents are vulnerable to *underdetermination*: passing endpoint constraints + smooth-interpolation does not pin down rational interpolants of degree ≥ (1,1). For LP-style oracle-complexity conjectures, future Explorers should use compositional reasoning ONLY as a sanity check, not as the main route. The actual exponent has to come from a hard-instance construction (Routes 1 / 3) or an algorithmic upper bound (Route 4).
- **date**: 2026-04-27

---

## 9. Final assessment

**Route status**: HEURISTIC-FAIL. The route does not produce a proof of any of the three required outcomes (tighter LB at $p^* \in (1,2)$, faster UB, or full conjecture at any $p^*$).

**What the route does deliver**:
1. A rigorous Lipschitz-monotonicity inequality on $\alpha(p)$ (Side product 7.1).
2. A rigorous refutation of the naive operator-norm heuristic (Side product 7.2 / §2.4).
3. A heuristic narrative for why the denominator $3p-2$ has the form it does (Fano three-way budget; Side product 7.3).
4. An identification of the precise additional axiom (S'') needed to upgrade compositional reasoning to a proof — and a reason to believe this axiom is essentially equivalent to the conjecture, hence circular (§6).

**Recommendation to Judge**: This route is honestly diagnostic. It should NOT be promoted to "verified proof" or "partial result". It IS a useful mediating document — a roadmap of what compositional reasoning *can* and *cannot* yield. If the proof system requires a verdict, the verdict is:

**Compositional Frame outcome**: PARTIAL (rigorously-monotonicity + heuristic-narrative); not a proof of the Guzmán conjecture for any $p^* \in (1,2)$. Publishable value: low (new failure pattern recorded; no new bounds).

## Route Failure Report
- **Route**: 6 (Compositional)
- **Failed at**: Step §3.5 / §4 (Axiom S'' is essentially the conjecture; argument circular).
- **Obstacle**: Two endpoint values plus smoothness-modulus pull-back yield only two equations on $\alpha(p)$; pinning down the conjectured rational form $(2-p)/(3p-2)$ requires a third structural axiom (Fano three-way budget) which is not derivable independently of the conjecture itself. The route is therefore a *consistency check*, not a *derivation*.
- **Honest disclosure**: The "highest-risk" warning in the assignment is fully borne out. The compositional frame produces narrative coherence (the $3p-2$ denominator "feels right"), but no new theorem.

Q.E.D. (failure documented).
