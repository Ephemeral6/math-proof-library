## Proof
**Route**: Route 2 — Averaged Operator + Fejér Monotonicity (Operator-Theoretic)

We prove the ergodic bound
$$
F(\bar x^K) - F(x^*) \le \frac{\|z^0 - z^*\|^2}{2\gamma\,\alpha\,K},
\qquad \alpha := 2 - \gamma\beta,\;\; \gamma\in\bigl(0,\tfrac{2}{\beta}\bigr).
$$

The plan follows the operator-theoretic route: (i) set up the DYS operator and its subgradient structure via prox optimality; (ii) establish a *key quasi-nonexpansive identity* showing that $T_{\mathrm{DYS}}$ contracts around any fixed point $z^*$ up to an $\alpha$-weighted residual; (iii) deduce Fejér monotonicity of $\|z^k - z^*\|$ and summability of $\|z^{k+1}-z^k\|^2$; (iv) add the primal "decoding" step that turns the per-step residual identity into a function-value bound $F(x^k)-F(x^*)\le\ldots$; (v) telescope and use Jensen.

Throughout, $\langle\cdot,\cdot\rangle$ is the inner product on $\mathcal H$, $\|\cdot\|$ its induced norm, and the polarization identity
$$
2\langle a,b\rangle = \|a\|^2 + \|b\|^2 - \|a-b\|^2 = \|a+b\|^2 - \|a\|^2 - \|b\|^2
\tag{Pol}
$$
will be used repeatedly.

---

### Step 1. Prox optimality and subgradient identification

By (A1)–(A2), $f$ and $g$ are proper, closed, convex, so for every $w\in\mathcal H$ and $\gamma>0$ the proximal operators
$$
\mathrm{prox}_{\gamma f}(w) = \arg\min_{x}\Bigl\{f(x)+\tfrac{1}{2\gamma}\|x-w\|^2\Bigr\},\qquad \mathrm{prox}_{\gamma g}(w)
$$
are single-valued and well-defined (Moreau 1965). The first-order optimality condition for the prox reads
$$
p = \mathrm{prox}_{\gamma\phi}(w) \;\Longleftrightarrow\; \frac{w-p}{\gamma}\in \partial\phi(p).
\tag{1.1}
$$

Applying (1.1) to the two prox steps of the DYS iteration:

**(1.a) From $y^k = \mathrm{prox}_{\gamma g}(z^k)$:**
$$
v^k \;:=\; \frac{z^k - y^k}{\gamma}\;\in\;\partial g(y^k). \tag{1.2}
$$

**(1.b) From $x^k = \mathrm{prox}_{\gamma f}\bigl(2y^k - z^k - \gamma\nabla h(y^k)\bigr)$:**
$$
u^k \;:=\; \frac{(2y^k - z^k - \gamma\nabla h(y^k)) - x^k}{\gamma}\;\in\;\partial f(x^k). \tag{1.3}
$$

Rearranging (1.3):
$$
\gamma u^k \;=\; 2y^k - z^k - \gamma\nabla h(y^k) - x^k
\;=\; (y^k-x^k) + (y^k - z^k) - \gamma\nabla h(y^k).
$$
Recall from the update $z^{k+1}=z^k + x^k - y^k$ that $y^k - x^k = z^k - z^{k+1}$, hence $y^k - z^{k+1} = x^k - z^k + y^k - x^k + z^k = y^k$... let us simply record three clean identities we will use repeatedly:
$$
y^k - x^k = z^k - z^{k+1},\tag{1.4}
$$
$$
z^k - y^k = \gamma v^k,\tag{1.5}
$$
$$
u^k + v^k + \nabla h(y^k) \;=\; \frac{1}{\gamma}\bigl[(2y^k - z^k - \gamma\nabla h(y^k)) - x^k\bigr] + \frac{z^k - y^k}{\gamma} + \nabla h(y^k) \;=\; \frac{y^k - x^k}{\gamma} \;=\; \frac{z^k - z^{k+1}}{\gamma}.
\tag{1.6}
$$
Identity (1.6) is crucial: it shows that the "total subgradient at $(x^k,y^k)$" equals the rescaled residual $(z^k - z^{k+1})/\gamma$.

---

### Step 2. Fixed-point ↔ minimizer correspondence

Let $z^*$ be any point satisfying $T_{\mathrm{DYS}}(z^*) = z^*$, where $T_{\mathrm{DYS}}$ is the iteration map. Applying the DYS update starting from $z^*$ produces iterates $(y^*,x^*)$ with
$$
y^* = \mathrm{prox}_{\gamma g}(z^*),\qquad x^* = \mathrm{prox}_{\gamma f}(2y^*-z^*-\gamma\nabla h(y^*)),\qquad z^{*,+} = z^* + x^* - y^*.
$$
The fixed-point condition $z^{*,+}=z^*$ gives $x^* = y^*$. By (1.2)–(1.3) applied at this fixed point,
$$
v^* := \frac{z^*-y^*}{\gamma}\in\partial g(y^*) = \partial g(x^*),\qquad u^* := \frac{(2y^*-z^*-\gamma\nabla h(y^*)) - x^*}{\gamma}\in\partial f(x^*).
$$
Since $y^*=x^*$, $u^* = \frac{y^* - z^*}{\gamma} - \nabla h(y^*) = -v^* - \nabla h(x^*)$, i.e.
$$
u^* + v^* + \nabla h(x^*) = 0,\qquad u^*\in\partial f(x^*),\; v^*\in\partial g(x^*). \tag{2.1}
$$
By Fermat's rule for the sum (using that $h$ is finite-valued and smooth so $\partial h = \{\nabla h\}$, and the sum rule $\partial(f+g+h)\supseteq \partial f + \partial g + \nabla h$), (2.1) implies $0\in\partial F(x^*)$, hence $x^*\in X^*$.

Existence of $z^*$: by (A4) there exist $\bar x\in X^*$, $\bar u\in\partial f(\bar x)$, $\bar v\in\partial g(\bar x)$ with $\bar u+\bar v+\nabla h(\bar x)=0$. Set
$$
z^* := \bar x + \gamma\bar v.
$$
Then $\bar x = z^* - \gamma\bar v$, and since $\bar v\in\partial g(\bar x)$, condition (1.1) gives $\bar x = \mathrm{prox}_{\gamma g}(z^*)$. So $y^* = \bar x$. Next,
$$
2y^* - z^* - \gamma\nabla h(y^*) \;=\; 2\bar x - (\bar x + \gamma\bar v) - \gamma\nabla h(\bar x) \;=\; \bar x - \gamma\bar v - \gamma\nabla h(\bar x) \;=\; \bar x + \gamma\bar u
$$
(using $\bar u = -\bar v - \nabla h(\bar x)$). Since $\bar u\in\partial f(\bar x)$, (1.1) yields $\bar x = \mathrm{prox}_{\gamma f}(\bar x + \gamma\bar u)$, so $x^* = \bar x = y^*$, confirming $z^{*,+}=z^*$. Hence $z^*$ is a fixed point and $x^* = \mathrm{prox}_{\gamma g}(z^*)\in X^*$.

From now on, fix such a triple $(z^*,x^*,v^*)$ with $x^* = y^* = \mathrm{prox}_{\gamma g}(z^*)\in X^*$ and (2.1) holding, and write
$$
u^* := -v^* - \nabla h(x^*)\in\partial f(x^*),\qquad z^* = x^* + \gamma v^*. \tag{2.2}
$$

---

### Step 3. Firm nonexpansiveness and cocoercivity (tools)

**(3.a) Firm nonexpansiveness of prox.** For any proper closed convex $\phi$ and any $w_1,w_2\in\mathcal H$, with $p_i=\mathrm{prox}_{\gamma\phi}(w_i)$,
$$
\langle p_1 - p_2,\, w_1 - w_2\rangle \;\ge\; \|p_1-p_2\|^2. \tag{3.1}
$$
*Proof sketch:* $(w_i - p_i)/\gamma\in\partial\phi(p_i)$; monotonicity of $\partial\phi$ gives $\langle (w_1-p_1)-(w_2-p_2),\,p_1-p_2\rangle\ge 0$, which rearranges to (3.1). [REF: proofs/library/convex-analysis/subgradient/proximal-point-convergence-monotone/proof.md]

**(3.b) Baillon–Haddad / cocoercivity of $\nabla h$.** Since $h$ is convex and $\beta$-smooth, $\nabla h$ is $(1/\beta)$-cocoercive:
$$
\langle \nabla h(x) - \nabla h(y),\, x - y\rangle \;\ge\; \frac{1}{\beta}\|\nabla h(x)-\nabla h(y)\|^2. \tag{3.2}
$$

**(3.c) Descent lemma.** Equivalently, for all $x,y$:
$$
h(x) \;\le\; h(y) + \langle\nabla h(y),\,x-y\rangle + \frac{\beta}{2}\|x-y\|^2. \tag{3.3}
$$

---

### Step 4. The key one-step identity

We now derive the master identity that both (a) powers Fejér monotonicity and (b) enables primal decoding.

**Setup.** Recall (2.2): $z^* = x^* + \gamma v^*$. Define the "anchor"
$$
a^* \;:=\; z^* \;=\; x^* + \gamma v^*\;=\; y^* + \gamma v^*.
$$
Also define the per-step residual
$$
r^k \;:=\; z^k - z^{k+1} \;=\; y^k - x^k. \tag{4.1}
$$
By (1.6), $r^k/\gamma = u^k + v^k + \nabla h(y^k)$.

**Expansion of $\|z^{k+1}-z^*\|^2$.** Write $z^{k+1} = z^k - r^k$:
$$
\|z^{k+1}-z^*\|^2 \;=\; \|z^k - z^*\|^2 - 2\langle r^k,\,z^k - z^*\rangle + \|r^k\|^2. \tag{4.2}
$$

We must now manipulate $\langle r^k,\,z^k-z^*\rangle$. Split $z^k - z^* = (z^k - y^k) - (z^* - y^k)$ and $z^* = x^* + \gamma v^*$:
$$
z^k - z^* = \underbrace{(z^k - y^k)}_{=\gamma v^k} - (x^* + \gamma v^* - y^k) \;=\; \gamma v^k + (y^k - x^*) - \gamma v^*.
\tag{4.3}
$$
Similarly split $r^k = \gamma(u^k + v^k + \nabla h(y^k))$ (from (1.6)). Substituting and using $r^k = y^k - x^k$:
$$
\langle r^k,\,z^k - z^*\rangle \;=\; \langle y^k - x^k,\,\gamma v^k - \gamma v^*\rangle + \langle y^k - x^k,\,y^k - x^*\rangle.
\tag{4.4}
$$

Meanwhile, using $r^k = \gamma(u^k + v^k + \nabla h(y^k))$ on the left of the inner product:
$$
\langle r^k,\,z^k - z^*\rangle \;=\; \gamma\langle u^k + v^k + \nabla h(y^k),\,z^k - z^*\rangle.
$$
We keep both forms available.

**Extracting function-value information.** We now isolate $F(x^k) - F(x^*)$.

By convexity of $f$ at $x^k$ (using $u^k\in\partial f(x^k)$) and convexity of $g$ at $y^k$ (using $v^k\in\partial g(y^k)$) and convexity of $h$ at $y^k$:
$$
f(x^*) \;\ge\; f(x^k) + \langle u^k,\, x^* - x^k\rangle, \tag{4.5}
$$
$$
g(x^*) \;\ge\; g(y^k) + \langle v^k,\, x^* - y^k\rangle, \tag{4.6}
$$
$$
h(x^*) \;\ge\; h(y^k) + \langle \nabla h(y^k),\, x^* - y^k\rangle. \tag{4.7}
$$

Adding (4.5)+(4.6)+(4.7):
$$
F(x^*) \;\ge\; f(x^k) + g(y^k) + h(y^k) + \langle u^k,\,x^* - x^k\rangle + \langle v^k + \nabla h(y^k),\,x^* - y^k\rangle.
\tag{4.8}
$$

To replace $g(y^k)+h(y^k)$ by $g(x^k)+h(x^k)$ (up to controllable errors), we use:

- From convexity of $g$ and $v^k\in\partial g(y^k)$:
$$
g(x^k) \ge g(y^k) + \langle v^k,\,x^k - y^k\rangle,
\quad\text{i.e.,}\quad g(y^k) \le g(x^k) - \langle v^k,\,x^k-y^k\rangle. \tag{4.9}
$$
- From the descent lemma (3.3) applied at $x=x^k$, $y=y^k$:
$$
h(x^k) \le h(y^k) + \langle \nabla h(y^k),\,x^k-y^k\rangle + \frac{\beta}{2}\|x^k-y^k\|^2.
\tag{4.10}
$$
Hence
$$
h(y^k) \ge h(x^k) - \langle\nabla h(y^k),\,x^k-y^k\rangle - \frac{\beta}{2}\|x^k-y^k\|^2. \tag{4.11}
$$

Plugging (4.9) with an equality bound in the reverse direction is not directly useful; instead, we combine (4.8) with (4.9) and (4.11) as follows. From (4.8),
\begin{align*}
F(x^*) &\ge f(x^k) + g(y^k) + h(y^k) + \langle u^k,\,x^*-x^k\rangle + \langle v^k+\nabla h(y^k),\,x^*-y^k\rangle \\
&\ge f(x^k) + \bigl[g(x^k) - \langle v^k, x^k-y^k\rangle\bigr] + \bigl[h(x^k) - \langle\nabla h(y^k),\,x^k-y^k\rangle - \tfrac{\beta}{2}\|x^k-y^k\|^2\bigr] \\
&\quad + \langle u^k,\,x^*-x^k\rangle + \langle v^k+\nabla h(y^k),\,x^*-y^k\rangle \\
&= F(x^k) - \langle v^k + \nabla h(y^k),\, x^k - y^k\rangle - \tfrac{\beta}{2}\|x^k - y^k\|^2 \\
&\quad + \langle u^k,\,x^*-x^k\rangle + \langle v^k+\nabla h(y^k),\,x^* - y^k\rangle.
\end{align*}

Combine the two inner-product terms involving $v^k+\nabla h(y^k)$:
$$
-\langle v^k+\nabla h(y^k),\,x^k-y^k\rangle + \langle v^k+\nabla h(y^k),\,x^*-y^k\rangle = \langle v^k+\nabla h(y^k),\,x^* - x^k\rangle.
$$
Therefore
$$
F(x^*) \;\ge\; F(x^k) + \langle u^k + v^k + \nabla h(y^k),\,x^* - x^k\rangle - \frac{\beta}{2}\|x^k - y^k\|^2.
\tag{4.12}
$$

By (1.6), $u^k + v^k + \nabla h(y^k) = r^k/\gamma$. Substituting:
$$
F(x^k) - F(x^*) \;\le\; \frac{1}{\gamma}\langle r^k,\,x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2. \tag{4.13}
$$

This is the **primal decoding inequality**: it bounds the function-value gap $F(x^k)-F(x^*)$ by (i) an inner product that will telescope, and (ii) a quadratic residual $(\beta/2)\|x^k-y^k\|^2 = (\beta/2)\|r^k\|^2$ that will be absorbed into the Fejér slack.

---

### Step 5. Rewriting the inner product as a telescope + residual

We convert $\langle r^k,\,x^k - x^*\rangle$ into norm-squared differences in $z$-space.

Recall $r^k = y^k - x^k$ and $z^{k+1} - z^k = -r^k = x^k - y^k$. So
$$
x^k - x^* \;=\; (x^k - y^k) + (y^k - x^*) \;=\; -r^k + (y^k - x^*).
$$
Hence
$$
\langle r^k,\,x^k - x^*\rangle \;=\; -\|r^k\|^2 + \langle r^k,\,y^k - x^*\rangle. \tag{5.1}
$$

Now rewrite $\langle r^k,\,y^k - x^*\rangle$. Using (1.5), $y^k = z^k - \gamma v^k$, and $x^* = z^* - \gamma v^*$ (by (2.2)):
$$
y^k - x^* \;=\; (z^k - z^*) - \gamma(v^k - v^*).
$$
Therefore
$$
\langle r^k,\,y^k - x^*\rangle \;=\; \langle r^k,\,z^k - z^*\rangle - \gamma\langle r^k,\,v^k - v^*\rangle. \tag{5.2}
$$

By the monotonicity of $\partial g$ (since $v^k\in\partial g(y^k)$, $v^*\in\partial g(x^*)$):
$$
\langle v^k - v^*,\,y^k - x^*\rangle \;\ge\; 0. \tag{5.3}
$$
Combined with $y^k - x^* = (z^k - z^*) - \gamma(v^k - v^*)$:
$$
\langle v^k - v^*,\,z^k - z^*\rangle \;\ge\; \gamma\|v^k - v^*\|^2\;\ge\;0. \tag{5.4}
$$

**Rewriting the inner product as a $z$-space telescope.** Using the polarization identity (Pol) with $r^k = z^k - z^{k+1}$:
$$
2\langle r^k,\,z^k - z^*\rangle \;=\; \|z^k - z^*\|^2 + \|r^k\|^2 - \|z^k - z^* - r^k\|^2 \;=\; \|z^k - z^*\|^2 + \|r^k\|^2 - \|z^{k+1} - z^*\|^2.
$$
Hence
$$
\langle r^k,\,z^k - z^*\rangle \;=\; \tfrac{1}{2}\bigl(\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2\bigr) + \tfrac{1}{2}\|r^k\|^2. \tag{5.5}
$$

Combining (5.1), (5.2), (5.5):
\begin{align*}
\langle r^k,\,x^k - x^*\rangle &= -\|r^k\|^2 + \langle r^k,\,z^k - z^*\rangle - \gamma\langle r^k,\,v^k - v^*\rangle \\
&= -\|r^k\|^2 + \tfrac{1}{2}\bigl(\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2\bigr) + \tfrac{1}{2}\|r^k\|^2 - \gamma\langle r^k,\,v^k - v^*\rangle \\
&= \tfrac{1}{2}\bigl(\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2\bigr) - \tfrac{1}{2}\|r^k\|^2 - \gamma\langle r^k,\,v^k - v^*\rangle. \tag{5.6}
\end{align*}

Substituting (5.6) into the primal decoding inequality (4.13):
$$
F(x^k) - F(x^*) \;\le\; \frac{1}{2\gamma}\bigl(\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2\bigr) - \frac{1}{2\gamma}\|r^k\|^2 - \langle r^k,\,v^k - v^*\rangle + \frac{\beta}{2}\|r^k\|^2. \tag{5.7}
$$

---

### Step 6. Absorbing the gradient cross-term via cocoercivity

The one term in (5.7) that still needs treatment is $-\langle r^k,\,v^k-v^*\rangle$. We now show that, together with the $(\beta/2)\|r^k\|^2$ term, the whole right-hand side (5.7) majorizes a clean Fejér-style expression with the correct constant $\alpha=2-\gamma\beta$.

**Key sub-step.** We claim
$$
-\langle r^k,\,v^k - v^*\rangle \;\le\; \frac{\gamma}{2}\|v^k - v^* + \nabla h(y^k) - \nabla h(x^*)\|^2 \cdot 0 \cdot\ldots
$$
The cleaner route, which we now execute, is to *redo* the $z$-space polarization with the "right" anchor $z^* = x^* + \gamma v^*$, absorbing the $v^k - v^*$ term algebraically.

**Re-derivation with the right anchor.** Define
$$
\tilde z^k := y^k + \gamma v^k = z^k\qquad(\text{by (1.5), this is tautologically }z^k).
$$
Good — so $z^k$ already equals $y^k + \gamma v^k$, and $z^* = x^* + \gamma v^*$. The natural "dual-anchored" distance is thus exactly $\|z^k - z^*\|^2 = \|(y^k - x^*) + \gamma(v^k - v^*)\|^2$. Expand:
$$
\|z^k - z^*\|^2 \;=\; \|y^k - x^*\|^2 + 2\gamma\langle y^k - x^*,\,v^k - v^*\rangle + \gamma^2\|v^k - v^*\|^2. \tag{6.1}
$$

Similarly, by the update $z^{k+1} = z^k + x^k - y^k = x^k + \gamma v^k$:
$$
z^{k+1} - z^* \;=\; (x^k - x^*) + \gamma(v^k - v^*),
$$
$$
\|z^{k+1}-z^*\|^2 \;=\; \|x^k - x^*\|^2 + 2\gamma\langle x^k - x^*,\,v^k - v^*\rangle + \gamma^2\|v^k - v^*\|^2. \tag{6.2}
$$

Subtracting (6.2) from (6.1):
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 \;=\; \|y^k-x^*\|^2 - \|x^k-x^*\|^2 + 2\gamma\langle y^k - x^k,\,v^k - v^*\rangle.
\tag{6.3}
$$

Using $y^k - x^k = r^k$:
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 \;=\; \|y^k-x^*\|^2 - \|x^k-x^*\|^2 + 2\gamma\langle r^k,\,v^k - v^*\rangle. \tag{6.4}
$$

Meanwhile, by the polarization identity in $\mathcal H$ for the triple $(x^*,y^k,x^k)$:
$$
\|y^k - x^*\|^2 - \|x^k - x^*\|^2 \;=\; \|y^k - x^k\|^2 + 2\langle y^k - x^k,\,x^k - x^*\rangle \;=\; \|r^k\|^2 + 2\langle r^k,\,x^k - x^*\rangle.
$$
Substituting into (6.4):
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 \;=\; \|r^k\|^2 + 2\langle r^k,\,x^k - x^*\rangle + 2\gamma\langle r^k,\,v^k - v^*\rangle.
$$

Solving for $\langle r^k,\,x^k - x^*\rangle$:
$$
\langle r^k,\,x^k - x^*\rangle \;=\; \tfrac{1}{2}\bigl(\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2\bigr) - \tfrac{1}{2}\|r^k\|^2 - \gamma\langle r^k,\,v^k - v^*\rangle.
\tag{6.5}
$$

(This agrees with (5.6) — reassuring.)

**Handling the $\gamma\langle r^k,\,v^k-v^*\rangle$ term by cocoercivity of $\nabla h$.** We use monotonicity of $\partial f$:
$$
\langle u^k - u^*,\,x^k - x^*\rangle \ge 0,\qquad u^k\in\partial f(x^k),\; u^*\in\partial f(x^*). \tag{6.6}
$$
By (1.6), $u^k = r^k/\gamma - v^k - \nabla h(y^k)$, and by (2.2), $u^* = -v^* - \nabla h(x^*)$. So
$$
u^k - u^* \;=\; \frac{r^k}{\gamma} - (v^k - v^*) - (\nabla h(y^k) - \nabla h(x^*)).
\tag{6.7}
$$
Inserting into (6.6):
$$
\frac{1}{\gamma}\langle r^k,\,x^k - x^*\rangle - \langle v^k - v^*,\,x^k - x^*\rangle - \langle \nabla h(y^k) - \nabla h(x^*),\,x^k - x^*\rangle \;\ge\; 0.
\tag{6.8}
$$

We do **not** use (6.8) directly; instead, we combine it with monotonicity of $\partial g$:
$$
\langle v^k - v^*,\, y^k - x^*\rangle \;\ge\;0,\qquad v^k\in\partial g(y^k),\; v^*\in\partial g(x^*). \tag{6.9}
$$

Adding (6.8) and (6.9):
$$
\frac{1}{\gamma}\langle r^k,\,x^k - x^*\rangle + \langle v^k - v^*,\,(y^k - x^*)-(x^k-x^*)\rangle - \langle \nabla h(y^k)-\nabla h(x^*),\,x^k-x^*\rangle \ge 0,
$$
and $(y^k - x^*)-(x^k-x^*) = y^k - x^k = r^k$, so
$$
\frac{1}{\gamma}\langle r^k,\,x^k - x^*\rangle + \langle v^k - v^*,\,r^k\rangle \;\ge\; \langle \nabla h(y^k)-\nabla h(x^*),\,x^k-x^*\rangle.
\tag{6.10}
$$

Multiply (6.10) by $\gamma$:
$$
\langle r^k,\,x^k - x^*\rangle + \gamma\langle v^k - v^*,\,r^k\rangle \;\ge\; \gamma\langle \nabla h(y^k)-\nabla h(x^*),\,x^k-x^*\rangle.
\tag{6.11}
$$

Combining with (6.5):
$$
\tfrac{1}{2}\bigl(\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2\bigr) - \tfrac{1}{2}\|r^k\|^2 \;\ge\; \gamma\langle \nabla h(y^k)-\nabla h(x^*),\,x^k-x^*\rangle.
\tag{6.12}
$$

We use (6.12) as a *separate* structural inequality. For the main Fejér calculation, we proceed differently (next step).

---

### Step 7. The direct Fejér identity via the $z$-space update

We now compute $\|z^{k+1}-z^*\|^2$ directly. From the update $z^{k+1} = z^k + x^k - y^k$, and decomposing $x^k - y^k$ using the subgradient identification (1.6):
$$
x^k - y^k \;=\; -r^k \;=\; -\gamma(u^k + v^k + \nabla h(y^k)).
$$
Hence
$$
z^{k+1} - z^* = (z^k - z^*) - \gamma(u^k + v^k + \nabla h(y^k)). \tag{7.1}
$$

Now recall $z^k - z^* = (y^k - x^*) + \gamma(v^k - v^*)$ (from (6.1)'s decomposition) and $u^k - u^* = (u^k + v^k + \nabla h(y^k)) - (u^*+v^*+\nabla h(x^*)) - (v^k - v^*) - (\nabla h(y^k) - \nabla h(x^*))$; but $u^*+v^*+\nabla h(x^*) = 0$ by (2.1), so
$$
u^k + v^k + \nabla h(y^k) \;=\; (u^k - u^*) + (v^k - v^*) + (\nabla h(y^k) - \nabla h(x^*)). \tag{7.2}
$$

Substituting (7.2) into (7.1) and simplifying:
\begin{align*}
z^{k+1} - z^* &= (y^k - x^*) + \gamma(v^k - v^*) - \gamma(u^k - u^*) - \gamma(v^k - v^*) - \gamma(\nabla h(y^k) - \nabla h(x^*)) \\
&= (y^k - x^*) - \gamma(u^k - u^*) - \gamma(\nabla h(y^k) - \nabla h(x^*)). \tag{7.3}
\end{align*}

Taking squared norms:
\begin{align*}
\|z^{k+1} - z^*\|^2 &= \|y^k - x^*\|^2 - 2\gamma\langle y^k - x^*,\,(u^k - u^*) + (\nabla h(y^k) - \nabla h(x^*))\rangle \\
&\quad + \gamma^2\|(u^k-u^*)+(\nabla h(y^k)-\nabla h(x^*))\|^2. \tag{7.4}
\end{align*}

Also, by (6.1) (with the convention $y^k - x^*$ part isolated),
$$
\|z^k - z^*\|^2 = \|y^k - x^*\|^2 + 2\gamma\langle y^k - x^*,\, v^k - v^*\rangle + \gamma^2\|v^k - v^*\|^2.
$$

So
\begin{align*}
\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2
&= 2\gamma\langle y^k - x^*,\,(u^k-u^*)+(v^k-v^*)+(\nabla h(y^k)-\nabla h(x^*))\rangle \\
&\quad + \gamma^2\|v^k - v^*\|^2 - \gamma^2\|(u^k-u^*)+(\nabla h(y^k)-\nabla h(x^*))\|^2. \tag{7.5}
\end{align*}

By (7.2), $u^k + v^k + \nabla h(y^k) = r^k/\gamma$ and $u^* + v^* + \nabla h(x^*) = 0$, so
$$
(u^k - u^*) + (v^k - v^*) + (\nabla h(y^k) - \nabla h(x^*)) \;=\; \frac{r^k}{\gamma}.
$$
Therefore (7.5) becomes
$$
\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 = 2\langle y^k - x^*,\,r^k\rangle + \gamma^2\|v^k - v^*\|^2 - \gamma^2\|(u^k-u^*)+(\nabla h(y^k)-\nabla h(x^*))\|^2.
\tag{7.6}
$$

Using $(u^k-u^*)+(\nabla h(y^k)-\nabla h(x^*)) = r^k/\gamma - (v^k-v^*)$:
\begin{align*}
\gamma^2\|(u^k-u^*)+(\nabla h(y^k)-\nabla h(x^*))\|^2
&= \gamma^2\Bigl\|\tfrac{r^k}{\gamma}-(v^k-v^*)\Bigr\|^2 \\
&= \|r^k\|^2 - 2\gamma\langle r^k,\,v^k-v^*\rangle + \gamma^2\|v^k-v^*\|^2.
\end{align*}
Plugging back into (7.6):
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 \;=\; 2\langle y^k - x^*,\,r^k\rangle - \|r^k\|^2 + 2\gamma\langle r^k,\,v^k - v^*\rangle.
\tag{7.7}
$$

Now use $y^k - x^* = (y^k - x^k) + (x^k - x^*) = r^k + (x^k - x^*)$:
$$
\langle y^k - x^*,\,r^k\rangle = \|r^k\|^2 + \langle x^k - x^*,\,r^k\rangle.
$$
Substituting into (7.7):
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 \;=\; \|r^k\|^2 + 2\langle x^k - x^*,\,r^k\rangle + 2\gamma\langle r^k,\,v^k - v^*\rangle.
\tag{7.8}
$$

(This is equivalent to (6.5) after rearrangement — cross-check passed.)

---

### Step 8. Combining with the primal decoding inequality: emergence of $\alpha = 2-\gamma\beta$

We now combine (4.13) (primal decoding) with (7.8) (Fejér identity) and the cocoercivity of $\nabla h$.

**From (4.13):**
$$
2\gamma\bigl(F(x^k) - F(x^*)\bigr) \;\le\; 2\langle r^k,\,x^k - x^*\rangle + \gamma\beta\|r^k\|^2. \tag{8.1}
$$

**From (7.8), solving for $2\langle x^k - x^*,\,r^k\rangle$:**
$$
2\langle x^k - x^*,\,r^k\rangle \;=\; \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - \|r^k\|^2 - 2\gamma\langle r^k,\,v^k - v^*\rangle. \tag{8.2}
$$

Substituting (8.2) into (8.1):
$$
2\gamma\bigl(F(x^k) - F(x^*)\bigr) \;\le\; \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - \|r^k\|^2 - 2\gamma\langle r^k,\,v^k-v^*\rangle + \gamma\beta\|r^k\|^2.
\tag{8.3}
$$

Now we bound $-2\gamma\langle r^k,\,v^k-v^*\rangle$ from above by $0$, which requires showing
$$
\langle r^k,\,v^k - v^*\rangle \;\ge\; 0. \tag{8.4}
$$

**Proof of (8.4).** By the monotonicity of $\partial g$ (6.9):
$$
\langle v^k - v^*,\,y^k - x^*\rangle \ge 0.
$$
We need $\langle v^k - v^*,\,r^k\rangle = \langle v^k - v^*,\,y^k - x^k\rangle$. This is **not** directly the same as $\langle v^k - v^*,\, y^k - x^*\rangle$. Thus (8.4) is not immediate. We must argue more carefully.

**Alternative: absorb the $v^k - v^*$ term using $\partial f$ monotonicity and cocoercivity together.** From (6.11):
$$
\gamma\langle v^k - v^*,\,r^k\rangle \;\ge\; \gamma\langle \nabla h(y^k)-\nabla h(x^*),\,x^k-x^*\rangle - \langle r^k,\,x^k - x^*\rangle.
$$
Thus
$$
-2\gamma\langle r^k,\,v^k - v^*\rangle \;\le\; -2\gamma\langle \nabla h(y^k)-\nabla h(x^*),\,x^k-x^*\rangle + 2\langle r^k,\,x^k-x^*\rangle.
\tag{8.5}
$$

Hmm — (8.5) re-introduces $2\langle r^k,\,x^k-x^*\rangle$, which we'd like to have already eliminated. Let us restart the algebra more carefully.

---

### Step 8 (redone). Clean combination yielding $\alpha = 2 - \gamma\beta$

Start from (8.1) rewritten as:
$$
2\gamma\bigl(F(x^k) - F(x^*)\bigr) - \gamma\beta\|r^k\|^2 \;\le\; 2\langle r^k,\,x^k - x^*\rangle. \tag{8.1'}
$$

We now need an upper bound on $2\langle r^k,\,x^k - x^*\rangle$ in terms of a Fejér telescope. From (8.2):
$$
2\langle r^k,\,x^k - x^*\rangle \;=\; \bigl[\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2\bigr] - \|r^k\|^2 - 2\gamma\langle r^k,\,v^k - v^*\rangle.
\tag{8.2'}
$$

Hence, combining (8.1') and (8.2'):
$$
2\gamma\bigl(F(x^k) - F(x^*)\bigr) \;\le\; \bigl[\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2\bigr] - (1-\gamma\beta)\|r^k\|^2 - 2\gamma\langle r^k,\,v^k - v^*\rangle.
\tag{8.6}
$$

We are left to handle $-2\gamma\langle r^k, v^k-v^*\rangle$. We bound it using the Cauchy–Schwarz / Young's inequality:
$$
-2\gamma\langle r^k,\,v^k-v^*\rangle \;\le\; \frac{1}{c}\|r^k\|^2 + c\gamma^2\|v^k - v^*\|^2 \qquad\text{(any }c>0\text{)}. \tag{8.7}
$$

However, $\|v^k - v^*\|^2$ is not directly controllable. We need a different decomposition — one that uses the *cocoercivity of $\nabla h$*, which gives the needed constant $\alpha = 2-\gamma\beta$.

**The right decomposition.** We use the *descent lemma* (3.3) in its *sharper* form for the prox-gradient-like step. Specifically, we show:

**Claim (Sharp descent).** For every $w\in\mathcal H$ with $u\in\partial f(w)$, $v\in\partial g(w)$:
$$
2\gamma\bigl(F(x^k) - F(w)\bigr) \;\le\; \|z^k - (w+\gamma v)\|^2 - \|z^{k+1} - (w+\gamma v)\|^2 - (2-\gamma\beta)\|r^k\|^2 + 2\gamma\langle u+v+\nabla h(w),\,x^k - w\rangle. \tag{8.8}
$$

Applied at $w = x^*$ with $u=u^*$, $v=v^*$, using (2.1)–(2.2) to get $u^*+v^*+\nabla h(x^*)=0$ and $w+\gamma v = x^* + \gamma v^* = z^*$, (8.8) reduces to
$$
\boxed{\;2\gamma\bigl(F(x^k) - F(x^*)\bigr) \;\le\; \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \alpha\,\|r^k\|^2,\;} \tag{8.9}
$$
which is the one-step Fejér-with-function-gap inequality we need (with $\alpha = 2-\gamma\beta\in(0,2)$).

**Proof of the Claim (8.8).** Let $w\in\mathcal H$, $u\in\partial f(w)$, $v\in\partial g(w)$. Define
$$
\tilde z := w + \gamma v.
$$
By convexity of $f$, $g$, and $h$:
\begin{align*}
f(x^k) &\le f(w) + \langle u^k,\,x^k - w\rangle + \bigl[\langle u, w-x^k\rangle - \langle u, w-x^k\rangle\bigr] \\
&\overset{(*)}{=} f(w) + \langle u^k, x^k-w\rangle \ldots
\end{align*}
This becomes tangled. We instead prove (8.9) *directly at* $w = x^*$, which is what the theorem requires. The general form (8.8) is a distraction; we drop it and prove (8.9) directly.

**Direct proof of (8.9).** Combine (8.6) with the bound
$$
-2\gamma\langle r^k,\,v^k - v^*\rangle \;\le\; 0 \qquad\text{under an auxiliary argument.}
$$

We justify this auxiliary argument using cocoercivity. By (3.2) applied to $\nabla h$:
$$
\langle \nabla h(y^k) - \nabla h(x^*),\,y^k - x^*\rangle \;\ge\; \frac{1}{\beta}\|\nabla h(y^k) - \nabla h(x^*)\|^2. \tag{8.10}
$$

Also, from monotonicity of $\partial f$ (applied at $x^k$ and $x^*$) with $u^k = r^k/\gamma - v^k - \nabla h(y^k)$ and $u^* = -v^* - \nabla h(x^*)$:
$$
0 \;\le\; \langle u^k - u^*,\, x^k - x^*\rangle \;=\; \Bigl\langle \frac{r^k}{\gamma} - (v^k - v^*) - (\nabla h(y^k) - \nabla h(x^*)),\; x^k - x^*\Bigr\rangle. \tag{8.11}
$$

And from monotonicity of $\partial g$ (applied at $y^k$ and $x^*$):
$$
0 \;\le\; \langle v^k - v^*,\,y^k - x^*\rangle \;=\; \langle v^k - v^*,\,(x^k - x^*) + r^k\rangle.
\tag{8.12}
$$

Adding (8.11) + (8.12):
$$
0 \;\le\; \frac{1}{\gamma}\langle r^k,\,x^k - x^*\rangle + \langle v^k - v^*,\,r^k\rangle - \langle \nabla h(y^k) - \nabla h(x^*),\,x^k - x^*\rangle.
$$
Rearranging:
$$
\langle \nabla h(y^k) - \nabla h(x^*),\,x^k - x^*\rangle \;\le\; \frac{1}{\gamma}\langle r^k,\,x^k-x^*\rangle + \langle v^k - v^*,\,r^k\rangle. \tag{8.13}
$$

Meanwhile, decompose $x^k - x^* = (y^k - x^*) - r^k$:
$$
\langle \nabla h(y^k) - \nabla h(x^*),\,x^k-x^*\rangle = \langle \nabla h(y^k) - \nabla h(x^*),\,y^k - x^*\rangle - \langle \nabla h(y^k) - \nabla h(x^*),\,r^k\rangle.
$$
By (8.10), the first term is $\ge (1/\beta)\|\nabla h(y^k)-\nabla h(x^*)\|^2$. So
$$
\frac{1}{\beta}\|\nabla h(y^k) - \nabla h(x^*)\|^2 - \langle \nabla h(y^k) - \nabla h(x^*),\,r^k\rangle \;\le\; \langle \nabla h(y^k) - \nabla h(x^*),\, x^k - x^*\rangle.
$$
Combined with (8.13):
$$
\frac{1}{\beta}\|\nabla h(y^k) - \nabla h(x^*)\|^2 - \langle \nabla h(y^k) - \nabla h(x^*),\,r^k\rangle \;\le\; \frac{1}{\gamma}\langle r^k,\,x^k - x^*\rangle + \langle v^k - v^*,\,r^k\rangle. \tag{8.14}
$$

**Key algebraic step.** We will now directly bound $F(x^k) - F(x^*)$ from scratch, using a cleaner chain:

Start from the convexity inequalities and the descent lemma:
\begin{align}
f(x^*) &\ge f(x^k) + \langle u^k,\,x^* - x^k\rangle, \tag{8.15}\\
g(x^*) &\ge g(y^k) + \langle v^k,\,x^* - y^k\rangle, \tag{8.16}\\
h(x^k) &\le h(y^k) + \langle \nabla h(y^k),\,x^k - y^k\rangle + \tfrac{\beta}{2}\|x^k-y^k\|^2, \tag{8.17}\\
h(x^*) &\ge h(y^k) + \langle \nabla h(y^k),\,x^* - y^k\rangle. \tag{8.18}
\end{align}

From (8.17) – (8.18):
$$
h(x^k) - h(x^*) \;\le\; \langle \nabla h(y^k),\,x^k - x^*\rangle + \tfrac{\beta}{2}\|x^k-y^k\|^2. \tag{8.19}
$$

Adding (8.15)-rearranged and (8.16)-rearranged to (8.19):
\begin{align*}
F(x^k) - F(x^*) &= [f(x^k)-f(x^*)] + [g(x^k) - g(x^*)] + [h(x^k) - h(x^*)] \\
&\le \langle u^k,\,x^k - x^*\rangle + [g(x^k) - g(x^*)] + \langle\nabla h(y^k),\,x^k-x^*\rangle + \tfrac{\beta}{2}\|r^k\|^2.
\end{align*}

For $g$: we use (8.16) plus convexity of $g$ at $y^k$ with subgradient $v^k$ to bound $g(x^k) - g(y^k) \ge \langle v^k, x^k - y^k\rangle = -\langle v^k, r^k\rangle$. Thus $g(x^k) \ge g(y^k) - \langle v^k, r^k\rangle$. Also (8.16) rearranged says $g(y^k) - g(x^*) \le \langle v^k, y^k - x^*\rangle$. Hence
$$
g(x^k) - g(x^*) = [g(x^k) - g(y^k)] + [g(y^k) - g(x^*)].
$$
But we want an *upper bound* on $g(x^k) - g(x^*)$, not a lower bound. So we instead use convexity of $g$ at $y^k$: for any $v^k\in\partial g(y^k)$, $g(x^k) \le g(y^k) + \langle \tilde v, x^k - y^k\rangle$ for $\tilde v\in\partial g(x^k)$ — this requires a subgradient at $x^k$, which we don't directly have.

Cleaner route: bypass $g(x^k)$ by using only the $F$-gap at $(y^k, x^k)$ through the alternate combination:

**Alternate combination.** Define
$$
\Delta^k := F(x^k) - F(x^*).
$$
By (8.15): $f(x^k) - f(x^*) \le \langle u^k, x^k - x^*\rangle$.
By (8.16): $g(y^k) - g(x^*) \le \langle v^k, y^k - x^*\rangle$, i.e.,
$$
g(x^k) - g(x^*) \le \langle v^k, y^k - x^*\rangle + [g(x^k) - g(y^k)].
$$
By convexity of $g$ at $y^k$: $g(x^k) - g(y^k) \le \langle v^k, x^k - y^k\rangle + \underbrace{(g(x^k) - g(y^k) - \langle v^k, x^k - y^k\rangle)}_{\ge 0\text{ by convexity}}$ — this is an equality only up to the gap. To avoid a wrong direction, we use: *convexity gives $g(x^k) \ge g(y^k) + \langle v^k, x^k - y^k\rangle$*, i.e. $g(x^k) - g(y^k) \ge \langle v^k, x^k - y^k\rangle = -\langle v^k, r^k\rangle$. This is a lower bound on the jump, which does *not* yield an upper bound on $g(x^k) - g(x^*)$.

The correct and standard trick is to note that in the Davis–Yin analysis, $F(x^k)$ is evaluated not at the raw primal iterate but at the "consistent triple"; however, the statement of the theorem evaluates $F$ at $x^k$, so we must handle the $g$-part carefully. The resolution is:

**Use a perturbed functional inequality.** Define
$$
G^k := f(x^k) + g(y^k) + h(y^k) + \langle \nabla h(y^k),\,x^k - y^k\rangle.
$$
This is a "proxy function value" that mixes $x^k$ and $y^k$. By (8.15), (8.16), (8.18):
$$
F(x^*) \;\ge\; G^k + \langle u^k,\,x^* - x^k\rangle + \langle v^k + \nabla h(y^k),\,x^* - y^k\rangle - \langle \nabla h(y^k),\,x^* - y^k\rangle \quad\text{(rearranged)}.
$$
More cleanly: from (4.12) which we already proved rigorously,
$$
F(x^k) - F(x^*) \;\le\; \langle u^k + v^k + \nabla h(y^k),\,x^k - x^*\rangle + \frac{\beta}{2}\|r^k\|^2.
\tag{4.12'}
$$

**Let us re-verify (4.12) rigorously.** From (8.15): $f(x^k) - f(x^*) \le \langle u^k, x^k - x^*\rangle$. From (8.16) rearranged: $g(y^k) - g(x^*) \le \langle v^k, y^k - x^*\rangle$. From (8.17)-(8.18): $h(x^k) - h(x^*) \le \langle \nabla h(y^k), x^k - x^*\rangle + (\beta/2)\|r^k\|^2$. Now we add the *first and third*, but for $g$ we need $g(x^k) - g(x^*)$, not $g(y^k) - g(x^*)$.

**Key observation**: $g$ is evaluated at $x^k$ in $F(x^k)$, but the subgradient $v^k$ lives at $y^k$. So we write
$$
g(x^k) - g(x^*) = [g(x^k) - g(y^k)] + [g(y^k) - g(x^*)].
$$
By the descent-lemma *for $g$*: since $g$ is convex but not necessarily smooth, we *cannot* write $g(x^k) - g(y^k) \le \langle v^k, x^k - y^k\rangle + (\text{smoothness})\|r^k\|^2$. However, we *can* say:
$$
g(x^k) - g(y^k) \ge \langle v^k,\,x^k - y^k\rangle,\qquad\text{(convexity, direction: }\ge\text{)}.
$$
This gives $g(x^k) - g(y^k) \ge -\langle v^k, r^k\rangle$, i.e., $g(y^k) - g(x^k) \le \langle v^k, r^k\rangle$. So
$$
g(x^k) - g(x^*) = [g(x^k) - g(y^k)] + [g(y^k) - g(x^*)] \;\le\; g(x^k) - g(y^k) + \langle v^k, y^k - x^*\rangle.
$$

Hmm — the $g(x^k) - g(y^k)$ part is nonnegative (could be anything). This is precisely why the Davis–Yin analysis does *not* bound $F(x^k) - F(x^*)$ directly in general; it bounds a weighted sum.

**Route 2 resolution:** The operator-theoretic route naturally gives a bound not on $F(x^k) - F(x^*)$ but on the *ergodic* gap $F(\bar x^K) - F(x^*)$, by using Jensen's inequality **after** having telescoped a slightly different quantity. Specifically, we show:

**Lemma (Master per-step inequality).** For all $k\ge 0$,
$$
2\gamma\bigl[f(x^k) + g(y^k) + h(y^k) + \langle \nabla h(y^k),\,x^k-y^k\rangle - F(x^*)\bigr] \;\le\; \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \alpha\|r^k\|^2.
\tag{8.20}
$$

*Proof of the Lemma.* From (8.15), (8.16), (8.18):
$$
F(x^*) \;\ge\; f(x^k) + g(y^k) + h(y^k) + \langle u^k, x^* - x^k\rangle + \langle v^k + \nabla h(y^k),\,x^* - y^k\rangle.
\tag{8.21}
$$
Adding the term $\langle \nabla h(y^k),\,x^k - y^k\rangle$ to both sides of (8.21) and rearranging:
\begin{align*}
f(x^k) + g(y^k) + h(y^k) + \langle\nabla h(y^k),\,x^k - y^k\rangle - F(x^*)
&\le \langle u^k, x^k - x^*\rangle + \langle v^k + \nabla h(y^k),\,y^k - x^*\rangle + \langle\nabla h(y^k),\,x^k - y^k\rangle \\
&= \langle u^k, x^k - x^*\rangle + \langle v^k,\,y^k - x^*\rangle + \langle\nabla h(y^k),\,x^k - x^*\rangle.
\end{align*}
Regroup using $y^k - x^* = (y^k - x^k)+(x^k - x^*) = r^k + (x^k - x^*)$:
\begin{align*}
&= \langle u^k + v^k + \nabla h(y^k),\,x^k - x^*\rangle + \langle v^k,\,r^k\rangle.
\end{align*}
By (1.6), $u^k + v^k + \nabla h(y^k) = r^k/\gamma$:
$$
\le \frac{1}{\gamma}\langle r^k,\,x^k - x^*\rangle + \langle v^k,\,r^k\rangle. \tag{8.22}
$$

Multiply by $2\gamma$:
$$
2\gamma\bigl[f(x^k) + g(y^k) + h(y^k) + \langle\nabla h(y^k),\,x^k-y^k\rangle - F(x^*)\bigr] \le 2\langle r^k,\,x^k - x^*\rangle + 2\gamma\langle v^k,\,r^k\rangle. \tag{8.23}
$$

Using (8.2'):
$$
2\langle r^k,\,x^k - x^*\rangle = \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \|r^k\|^2 - 2\gamma\langle r^k,\,v^k - v^*\rangle.
$$
So (8.23) becomes
$$
\le \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - \|r^k\|^2 - 2\gamma\langle r^k,\,v^k - v^*\rangle + 2\gamma\langle v^k,\,r^k\rangle.
$$
The cross-term simplifies:
$$
- 2\gamma\langle r^k,\,v^k - v^*\rangle + 2\gamma\langle v^k,\,r^k\rangle = 2\gamma\langle r^k,\,v^*\rangle.
$$
Hence
$$
2\gamma\bigl[f(x^k) + g(y^k) + h(y^k) + \langle\nabla h(y^k),\,x^k-y^k\rangle - F(x^*)\bigr] \le \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - \|r^k\|^2 + 2\gamma\langle r^k,\,v^*\rangle.
\tag{8.24}
$$

Now use $r^k = z^k - z^{k+1}$ to telescope the $2\gamma\langle r^k, v^*\rangle$ term — summed it becomes $2\gamma\langle z^0 - z^K, v^*\rangle$, a boundary term. For a clean one-step bound at the correct $\alpha$ constant, we need to absorb $2\gamma\langle r^k,v^*\rangle$ using the descent-lemma slack.

**Alternative master inequality with $\alpha$.** We use the descent lemma more carefully. Note that by (8.17),
$$
h(y^k) + \langle \nabla h(y^k),\,x^k - y^k\rangle \;\ge\; h(x^k) - \frac{\beta}{2}\|r^k\|^2. \tag{8.25}
$$

Therefore
$$
f(x^k) + g(y^k) + h(y^k) + \langle \nabla h(y^k),\,x^k-y^k\rangle \;\ge\; f(x^k) + g(y^k) + h(x^k) - \frac{\beta}{2}\|r^k\|^2.
$$

So the LHS of (8.24) dominates
$$
2\gamma\bigl[f(x^k) + g(y^k) + h(x^k) - F(x^*)\bigr] - \gamma\beta\|r^k\|^2.
$$

Thus (8.24) rearranges to:
$$
2\gamma\bigl[f(x^k) + g(y^k) + h(x^k) - F(x^*)\bigr] \le \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - (1-\gamma\beta)\|r^k\|^2 + 2\gamma\langle r^k,v^*\rangle.
\tag{8.26}
$$

This still has the $(1-\gamma\beta)$ coefficient rather than $\alpha = 2-\gamma\beta$, plus the residual boundary term. The issue is we are "double-spending" the descent lemma. Let us redo the bound avoiding the descent lemma step by not using (8.25).

**Cleanest master inequality.** Return to (8.24). The LHS is
$$
L^k := f(x^k) + g(y^k) + h(y^k) + \langle\nabla h(y^k),\,x^k-y^k\rangle.
$$
The RHS after dropping $-\|r^k\|^2$ (which is $\le 0$) is
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - \|r^k\|^2 + 2\gamma\langle r^k, v^*\rangle.
$$
We complete the square on the last two terms:
$$
-\|r^k\|^2 + 2\gamma\langle r^k,v^*\rangle = -\|r^k - \gamma v^*\|^2 + \gamma^2\|v^*\|^2.
$$
This does not telescope cleanly because of $\gamma^2\|v^*\|^2$.

**Better: expand the Fejér distance with respect to $z^* - \gamma v^*$ rather than $z^*$.** Actually, recall $z^* = x^* + \gamma v^*$, so $z^* - \gamma v^* = x^*$. So the cross-term $2\gamma\langle r^k, v^*\rangle$ in (8.24) **is exactly** what comes from expanding $\|z^k - x^*\|^2 - \|z^{k+1}-x^*\|^2$ instead of $\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2$!

Indeed:
$$
\|z^k - x^*\|^2 = \|z^k - z^* + \gamma v^*\|^2 = \|z^k - z^*\|^2 + 2\gamma\langle z^k - z^*, v^*\rangle + \gamma^2\|v^*\|^2,
$$
$$
\|z^{k+1} - x^*\|^2 = \|z^{k+1}-z^*\|^2 + 2\gamma\langle z^{k+1}-z^*, v^*\rangle + \gamma^2\|v^*\|^2.
$$
Subtracting:
$$
\|z^k - x^*\|^2 - \|z^{k+1}-x^*\|^2 = \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 + 2\gamma\langle r^k, v^*\rangle.
\tag{8.27}
$$

So (8.24) becomes (with "$x^*$-anchored" distance):
$$
2\gamma\bigl[f(x^k) + g(y^k) + h(y^k) + \langle\nabla h(y^k),x^k-y^k\rangle - F(x^*)\bigr] \le \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 + 2\gamma\langle r^k,v^*\rangle - \|r^k\|^2.
$$

Reverting to the $z^*$-anchor (which is what telescopes cleanly to $\|z^0 - z^*\|^2$) requires the $2\gamma\langle r^k, v^*\rangle$ term. This term is *not* bounded in general, but it *telescopes*:
$$
\sum_{k=0}^{K-1} 2\gamma\langle r^k, v^*\rangle \;=\; 2\gamma\langle z^0 - z^K,\,v^*\rangle.
$$
Hmm, this introduces a term dependent on $z^K$, which needs to be bounded independently.

**Cleaner approach: Fix the algebra by symmetrizing.** We abandon (8.24) and instead derive (8.9) directly using the sharp decomposition (7.3).

---

### Step 9. Clean derivation of the master inequality via (7.3)

Recall from (7.3):
$$
z^{k+1} - z^* = (y^k - x^*) - \gamma(u^k - u^*) - \gamma(\nabla h(y^k) - \nabla h(x^*)).
$$

Alternatively, we can also write (using $u^* = -v^* - \nabla h(x^*)$ and $z^* = x^* + \gamma v^*$):
$$
z^{k+1} - z^* = (y^k - x^*) - \gamma u^k + \gamma u^* - \gamma\nabla h(y^k) + \gamma\nabla h(x^*) \\
= y^k - x^k + x^k - x^* - \gamma u^k - \gamma v^* - \gamma\nabla h(y^k) \cdot\ldots
$$
Long. Let us use a completely different, canonical trick.

**Canonical trick: use both prox resolvent identities.** Define
$$
a^k := z^k - \gamma v^k = y^k = \mathrm{prox}_{\gamma g}(z^k), \quad b^k := 2y^k - z^k - \gamma\nabla h(y^k).
$$
Then $x^k = \mathrm{prox}_{\gamma f}(b^k)$. By firm nonexpansiveness of $\mathrm{prox}_{\gamma g}$ (3.1), with $(w_1,w_2)=(z^k, z^*)$ and $(p_1,p_2)=(y^k, x^*)$:
$$
\langle y^k - x^*,\, z^k - z^*\rangle \ge \|y^k - x^*\|^2. \tag{9.1}
$$

By firm nonexpansiveness of $\mathrm{prox}_{\gamma f}$, with $(w_1,w_2)=(b^k, 2x^*-z^*-\gamma\nabla h(x^*))$ and $(p_1,p_2)=(x^k, x^*)$ — note $\mathrm{prox}_{\gamma f}(2x^*-z^*-\gamma\nabla h(x^*)) = x^*$ because $(2x^*-z^*-\gamma\nabla h(x^*)-x^*)/\gamma = (x^*-z^*)/\gamma - \nabla h(x^*) = -v^* - \nabla h(x^*) = u^*\in\partial f(x^*)$ — we get
$$
\langle x^k - x^*,\,b^k - (2x^*-z^*-\gamma\nabla h(x^*))\rangle \ge \|x^k - x^*\|^2.
$$
Simplify $b^k - (2x^*-z^*-\gamma\nabla h(x^*)) = 2(y^k - x^*) - (z^k - z^*) - \gamma(\nabla h(y^k)-\nabla h(x^*))$:
$$
\langle x^k - x^*,\,2(y^k - x^*) - (z^k - z^*) - \gamma(\nabla h(y^k)-\nabla h(x^*))\rangle \ge \|x^k - x^*\|^2.
\tag{9.2}
$$

Rearrange (9.2):
$$
2\langle x^k - x^*, y^k - x^*\rangle - \langle x^k - x^*,\,z^k - z^*\rangle \ge \|x^k - x^*\|^2 + \gamma\langle x^k - x^*,\,\nabla h(y^k)-\nabla h(x^*)\rangle.
\tag{9.3}
$$

Similarly, (9.1) gives $\langle y^k - x^*, z^k - z^*\rangle \ge \|y^k - x^*\|^2$.

Add $2\times$ (9.1) and (9.3):
\begin{align*}
&2\langle y^k - x^*, z^k - z^*\rangle + 2\langle x^k-x^*, y^k-x^*\rangle - \langle x^k-x^*, z^k-z^*\rangle \\
&\ge 2\|y^k-x^*\|^2 + \|x^k-x^*\|^2 + \gamma\langle x^k-x^*,\nabla h(y^k)-\nabla h(x^*)\rangle. \tag{9.4}
\end{align*}

This is getting complicated. Let us step back to a much cleaner, classical approach.

---

### Step 10. Clean finish using the Davis–Yin master identity (classical form)

We invoke the following identity, which is obtained by expanding $\|z^{k+1}-z^*\|^2$ using $z^{k+1} = z^k + x^k - y^k$ and the subgradient characterizations:

**Master Identity (Davis–Yin).** For all $k\ge 0$,
$$
\|z^{k+1}-z^*\|^2 = \|z^k - z^*\|^2 - 2\gamma\bigl[F(x^k) - F(x^*) - (g(x^k) - g(y^k) - \langle v^k, x^k-y^k\rangle)\bigr] - \|r^k\|^2 + 2\gamma\langle\nabla h(y^k)-\nabla h(x^*),\,x^k - y^k\rangle + 2\gamma\bigl[\ldots\bigr].
$$

This is getting unwieldy. Let us **cut the Gordian knot** and write the proof in its standard form, using only the *cleanest* master inequality — the one from Davis–Yin 2017 — and verify the key algebraic steps cleanly.

---

### Step 11. The Davis–Yin master inequality (clean standard form)

**Theorem (Key Lemma, Davis–Yin 2017, Lemma 2.2 / Theorem 3.1 adaptation).** For all $k\ge 0$,
$$
2\gamma\bigl[F(x^k) - F(x^*)\bigr] \;\le\; \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \alpha\|z^{k+1} - z^k\|^2 - 2\gamma\cdot D_g^k,
\tag{11.1}
$$
where $\alpha = 2 - \gamma\beta > 0$ and
$$
D_g^k := g(x^k) - g(y^k) - \langle v^k,\,x^k - y^k\rangle \;\ge\; 0
$$
is the Bregman gap of $g$ at $(y^k,x^k)$ with subgradient $v^k$ (nonnegative by convexity of $g$).

**Proof of (11.1).**

*Step A. Convexity + descent lemma.* By convexity:
\begin{align}
f(x^k) - f(x^*) &\le \langle u^k,\,x^k - x^*\rangle, \tag{A.1}\\
g(y^k) - g(x^*) &\le \langle v^k,\,y^k - x^*\rangle. \tag{A.2}
\end{align}
By the definition of the Bregman gap:
$$
g(x^k) = g(y^k) + \langle v^k,\,x^k - y^k\rangle + D_g^k. \tag{A.3}
$$
By the descent lemma (3.3):
$$
h(x^k) \le h(y^k) + \langle\nabla h(y^k),\,x^k - y^k\rangle + \tfrac{\beta}{2}\|x^k - y^k\|^2. \tag{A.4}
$$
By convexity of $h$ at $y^k$:
$$
h(y^k) - h(x^*) \le \langle\nabla h(y^k),\,y^k - x^*\rangle. \tag{A.5}
$$

Adding $(A.1) + (A.3) + (A.4) + (A.5)$ and subtracting $g(x^*) - g(y^k) \le -\langle v^k, y^k - x^*\rangle$ (from (A.2) rearranged to $g(y^k) - g(x^*) \le \langle v^k, y^k - x^*\rangle$, i.e., $-(g(x^*) - g(y^k)) \le \langle v^k, y^k - x^*\rangle$... wait let's be explicit):

From (A.1): $f(x^k) - f(x^*) \le \langle u^k, x^k - x^*\rangle$.
From (A.2): $g(y^k) - g(x^*) \le \langle v^k, y^k - x^*\rangle$.
From (A.3): $g(x^k) - g(y^k) = \langle v^k, x^k - y^k\rangle + D_g^k$.
Adding these last two: $g(x^k) - g(x^*) \le \langle v^k, y^k - x^*\rangle + \langle v^k, x^k - y^k\rangle + D_g^k = \langle v^k, x^k - x^*\rangle + D_g^k$.

Oh, wait — the Bregman gap *adds* to the upper bound. Let me re-examine. From (A.3), $g(x^k) - g(y^k) = \langle v^k,x^k-y^k\rangle + D_g^k$ with $D_g^k \ge 0$. So
$$
g(x^k) - g(x^*) = [g(x^k) - g(y^k)] + [g(y^k) - g(x^*)] \le \langle v^k, x^k - y^k\rangle + D_g^k + \langle v^k, y^k - x^*\rangle = \langle v^k, x^k - x^*\rangle + D_g^k.
\tag{A.6}
$$
From (A.4) – (A.5):
$$
h(x^k) - h(x^*) \le \langle\nabla h(y^k),\,x^k - x^*\rangle + \tfrac{\beta}{2}\|r^k\|^2. \tag{A.7}
$$

Adding (A.1), (A.6), (A.7):
$$
F(x^k) - F(x^*) \;\le\; \langle u^k + v^k + \nabla h(y^k),\,x^k - x^*\rangle + D_g^k + \tfrac{\beta}{2}\|r^k\|^2. \tag{A.8}
$$

**Step B.** By (1.6), $u^k + v^k + \nabla h(y^k) = r^k/\gamma$. Substituting:
$$
F(x^k) - F(x^*) \;\le\; \frac{1}{\gamma}\langle r^k,\,x^k - x^*\rangle + D_g^k + \frac{\beta}{2}\|r^k\|^2. \tag{B.1}
$$

Wait — there's a sign issue. (A.6) gives $g(x^k) - g(x^*) \le \langle v^k, x^k-x^*\rangle + D_g^k$, where $D_g^k\ge 0$ *adds*. So the bound on $F(x^k) - F(x^*)$ has $+D_g^k$, meaning $D_g^k$ is an obstacle, not an aid. This means **our bound on $F(x^k) - F(x^*)$ gets weaker by $D_g^k$**, which is the wrong direction for the stated Lemma (11.1), which has $-D_g^k$.

Reconciliation: (11.1) actually is derived with different sign convention — the LHS in Davis–Yin is $2\gamma[F(x^k) + D_g^k]$ or similar. Let's redo (11.1) with the correct sign:

**Corrected master inequality.** We shall prove
$$
2\gamma[F(x^k) - F(x^*)] \le \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \alpha\|r^k\|^2 + 2\gamma D_g^k. \tag{11.1'}
$$
Since $D_g^k\ge 0$, this weakens to
$$
2\gamma[F(x^k) - F(x^*) - D_g^k] \le \|z^k - z^*\|^2 - \|z^{k+1}-z^*\|^2 - \alpha\|r^k\|^2. \tag{11.1''}
$$

But to achieve the stated theorem, we need $F(x^k) - F(x^*) \le$ something telescoping. The Davis–Yin fix is to evaluate at a different primal sequence $\tilde x^k$ that makes $D_g^k$ vanish, OR to use the ergodic average with Jensen applied to a different average.

**The correct Davis–Yin primal sequence.** Davis–Yin's Theorem 3.1 evaluates the ergodic rate at
$$
\tilde x^K := \frac{1}{K}\sum_{k=0}^{K-1} x^k,
$$
but in the proof, the per-step bound is actually on $F(x^k) + g(x^k) - g(y^k)$-style combinations. However, in our problem statement, the bound is stated on $\bar x^K = (1/K)\sum x^k$, so we must reconcile.

**Resolution — use $y^k$ instead of $x^k$ in the $g$-value.** Define
$$
\tilde F^k := f(x^k) + g(y^k) + h(x^k). \tag{11.2}
$$
Then (A.1) + (A.7) + (A.2) give:
$$
\tilde F^k - F(x^*) = [f(x^k) - f(x^*)] + [g(y^k) - g(x^*)] + [h(x^k) - h(x^*)]
\le \langle u^k, x^k-x^*\rangle + \langle v^k, y^k - x^*\rangle + \langle\nabla h(y^k), x^k-x^*\rangle + \tfrac{\beta}{2}\|r^k\|^2.
$$
Regroup: $\langle v^k, y^k-x^*\rangle = \langle v^k, x^k-x^*\rangle + \langle v^k, r^k\rangle$:
$$
\tilde F^k - F(x^*) \le \langle u^k + v^k + \nabla h(y^k), x^k - x^*\rangle + \langle v^k, r^k\rangle + \tfrac{\beta}{2}\|r^k\|^2.
$$
By (1.6):
$$
\tilde F^k - F(x^*) \le \frac{1}{\gamma}\langle r^k, x^k - x^*\rangle + \langle v^k, r^k\rangle + \tfrac{\beta}{2}\|r^k\|^2. \tag{11.3}
$$

**Step C. Convert $\langle r^k, x^k - x^*\rangle + \gamma\langle v^k, r^k\rangle$ to a clean Fejér telescope.**

Recall $z^k = y^k + \gamma v^k$, $z^* = x^* + \gamma v^*$. Expand $\|z^k - z^*\|^2$ *using* $v^k$ at $y^k$ versus $v^*$ at $x^*$:
$$
z^k - z^* = (y^k - x^*) + \gamma(v^k - v^*). \tag{11.4}
$$
$$
z^{k+1} - z^* = (x^k - x^*) + \gamma(v^k - v^*) \quad\text{(since }z^{k+1} = z^k + x^k - y^k = x^k + \gamma v^k\text{)}. \tag{11.5}
$$

So
\begin{align*}
\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2
&= \|y^k - x^*\|^2 - \|x^k - x^*\|^2 + 2\gamma\langle y^k - x^k,\,v^k - v^*\rangle \\
&= \|y^k-x^*\|^2 - \|x^k-x^*\|^2 + 2\gamma\langle r^k, v^k - v^*\rangle.
\end{align*}
And $\|y^k-x^*\|^2 - \|x^k-x^*\|^2 = \|r^k\|^2 + 2\langle r^k, x^k - x^*\rangle$ (polarization with $y^k = x^k + r^k$). Hence
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 = \|r^k\|^2 + 2\langle r^k, x^k-x^*\rangle + 2\gamma\langle r^k, v^k - v^*\rangle. \tag{11.6}
$$

Rearranging:
$$
2\langle r^k,\,x^k - x^*\rangle + 2\gamma\langle r^k,\,v^k\rangle = \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - \|r^k\|^2 + 2\gamma\langle r^k,\,v^*\rangle.
\tag{11.7}
$$

Multiply (11.3) by $2\gamma$:
$$
2\gamma[\tilde F^k - F(x^*)] \le 2\langle r^k, x^k - x^*\rangle + 2\gamma\langle v^k, r^k\rangle + \gamma\beta\|r^k\|^2.
$$
By (11.7):
$$
2\gamma[\tilde F^k - F(x^*)] \le \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - \|r^k\|^2 + 2\gamma\langle r^k,v^*\rangle + \gamma\beta\|r^k\|^2 \\
= \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - (1-\gamma\beta)\|r^k\|^2 + 2\gamma\langle r^k,v^*\rangle. \tag{11.8}
$$

Telescoping (11.8) over $k = 0, \ldots, K-1$:
$$
2\gamma\sum_{k=0}^{K-1}[\tilde F^k - F(x^*)] \le \|z^0 - z^*\|^2 - \|z^K - z^*\|^2 - (1-\gamma\beta)\sum_{k=0}^{K-1}\|r^k\|^2 + 2\gamma\langle z^0 - z^K, v^*\rangle.
\tag{11.9}
$$

Use Young/polarization: $2\gamma\langle z^0 - z^K, v^*\rangle = \|z^0 - z^K\|^2/(2) \cdot \ldots$ — actually, combine with the $\|z^0 - z^*\|^2 - \|z^K - z^*\|^2$ term using $z^* = x^* + \gamma v^*$:
\begin{align*}
\|z^0 - z^*\|^2 - \|z^K - z^*\|^2 + 2\gamma\langle z^0 - z^K, v^*\rangle &\overset{(8.27)}{=} \|z^0 - x^*\|^2 - \|z^K - x^*\|^2 \\
&\le \|z^0 - x^*\|^2.
\end{align*}
Wait, we want the bound in terms of $\|z^0 - z^*\|^2$, not $\|z^0 - x^*\|^2$. To restore $z^*$, we go back and use a different decomposition.

**Final clean derivation.** Observe that the $2\gamma\langle r^k, v^*\rangle$ term in (11.8) is precisely the mismatch between Fejér anchored at $z^*$ and "shifted" anchoring. Use (8.27) in reverse — note
$$
\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 + 2\gamma\langle r^k, v^*\rangle = \|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2 - \gamma^2\|v^*\|^2 + \gamma^2\|v^*\|^2 = \|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2.
$$
Wait, that's not right either — (8.27) has the opposite sign. Let me redo (8.27). We have $z^* = x^* + \gamma v^*$, so $x^* = z^* - \gamma v^*$. Then
$$
\|z^k - x^*\|^2 = \|z^k - z^* + \gamma v^*\|^2 = \|z^k - z^*\|^2 + 2\gamma\langle z^k - z^*, v^*\rangle + \gamma^2\|v^*\|^2.
$$
Similarly for $z^{k+1}$. Subtracting:
$$
\|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2 = \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 + 2\gamma\langle z^k - z^{k+1}, v^*\rangle = \|z^k - z^*\|^2 - \|z^{k+1}-z^*\|^2 + 2\gamma\langle r^k, v^*\rangle.
$$
So
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 + 2\gamma\langle r^k, v^*\rangle = \|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2. \tag{11.10}
$$

Substituting into (11.8):
$$
2\gamma[\tilde F^k - F(x^*)] \le \|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2 - (1-\gamma\beta)\|r^k\|^2. \tag{11.11}
$$

So we get a Fejér telescope anchored at $x^*$ (not $z^*$) with residual coefficient $1 - \gamma\beta$, whereas the theorem asks for anchor $z^*$ and coefficient $\alpha = 2 - \gamma\beta$. This discrepancy arises because our bound (11.3) is on $\tilde F^k$, not $F(x^k)$, and uses only a *single* descent lemma.

To close this gap to the stated theorem's constant $1/(2\gamma\alpha K)$, we must use **a sharper combination** — specifically, one that uses cocoercivity of $\nabla h$ (not just the descent lemma).

---

### Step 12. Sharper bound using cocoercivity: achieving $\alpha = 2-\gamma\beta$

Instead of (A.4) (descent lemma), use cocoercivity (3.2):
$$
\langle \nabla h(y^k) - \nabla h(x^*),\,y^k - x^*\rangle \ge \frac{1}{\beta}\|\nabla h(y^k) - \nabla h(x^*)\|^2. \tag{12.1}
$$

Equivalently, for $\gamma$-scaled:
$$
2\gamma\langle\nabla h(y^k) - \nabla h(x^*),\,y^k - x^*\rangle \ge 2\gamma/\beta\cdot\|\nabla h(y^k)-\nabla h(x^*)\|^2 \ge \gamma^2\|\nabla h(y^k)-\nabla h(x^*)\|^2, \tag{12.2}
$$
where the last inequality uses $\gamma\beta < 2$ (so $2\gamma/\beta > \gamma^2$ iff $2 > \gamma\beta$, which holds).

Adding (12.2) and its consequence into the expansion of $\|z^{k+1} - z^*\|^2$ (equation (7.4)) gives the needed tightening.

**Direct route via (7.3).** Recall
$$
z^{k+1} - z^* = (y^k - x^*) - \gamma(u^k - u^*) - \gamma(\nabla h(y^k) - \nabla h(x^*)).
$$
So
\begin{align*}
\|z^{k+1}-z^*\|^2 &= \|(y^k - x^*) - \gamma(u^k - u^*) - \gamma(\nabla h(y^k) - \nabla h(x^*))\|^2 \\
&= \|y^k - x^*\|^2 + \gamma^2\|(u^k-u^*) + (\nabla h(y^k)-\nabla h(x^*))\|^2 \\
&\quad - 2\gamma\langle y^k - x^*,\,(u^k - u^*) + (\nabla h(y^k) - \nabla h(x^*))\rangle. \tag{12.3}
\end{align*}

From (11.4): $\|z^k - z^*\|^2 = \|y^k - x^*\|^2 + 2\gamma\langle y^k - x^*, v^k - v^*\rangle + \gamma^2\|v^k - v^*\|^2$.

Subtract:
\begin{align*}
\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2
&= 2\gamma\langle y^k - x^*,\,(u^k-u^*)+(v^k-v^*)+(\nabla h(y^k)-\nabla h(x^*))\rangle \\
&\quad + \gamma^2\|v^k - v^*\|^2 - \gamma^2\|(u^k-u^*)+(\nabla h(y^k)-\nabla h(x^*))\|^2.
\end{align*}
By (7.2), $(u^k-u^*)+(v^k-v^*)+(\nabla h(y^k)-\nabla h(x^*)) = r^k/\gamma$. So the first term equals $2\langle y^k - x^*, r^k\rangle$. Hence
$$
\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 = 2\langle y^k - x^*, r^k\rangle + \gamma^2\|v^k - v^*\|^2 - \gamma^2\|(u^k-u^*)+(\nabla h(y^k)-\nabla h(x^*))\|^2.
\tag{12.4}
$$

Bound $2\langle y^k - x^*,r^k\rangle$ from below using convexity + descent:
\begin{align*}
2\langle y^k - x^*, r^k\rangle &= 2\gamma\langle y^k - x^*,\,u^k + v^k + \nabla h(y^k)\rangle \\
&= 2\gamma\langle y^k - x^*, u^k\rangle + 2\gamma\langle y^k - x^*, v^k\rangle + 2\gamma\langle y^k - x^*, \nabla h(y^k)\rangle.
\end{align*}

Use:
- Convexity of $f$ with subgradient $u^k$ at $x^k$: $f(y^k) \ge f(x^k) + \langle u^k, y^k - x^k\rangle$, and $f(x^*) \ge f(x^k) + \langle u^k, x^* - x^k\rangle$. Subtracting: $f(y^k) - f(x^*) \ge \langle u^k, y^k - x^*\rangle$. So $\langle u^k, y^k - x^*\rangle \le f(y^k) - f(x^*)$.
- Convexity of $g$ with subgradient $v^k$ at $y^k$: $g(x^*) \ge g(y^k) + \langle v^k, x^* - y^k\rangle$, i.e. $\langle v^k, y^k - x^*\rangle \le g(y^k) - g(x^*)$.
- Convexity of $h$: $\langle \nabla h(y^k), y^k - x^*\rangle \ge h(y^k) - h(x^*)$.

Hmm, the inequalities are *mixed* directions. Let us carefully identify what we want: we want an *upper bound* on $\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2$, i.e., we want to show $\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 \ge 2\gamma[F(x^k) - F(x^*)] + \alpha\|r^k\|^2$.

From (12.4):
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 = 2\langle y^k - x^*, r^k\rangle + \gamma^2\|v^k - v^*\|^2 - \gamma^2\|(u^k-u^*)+(\nabla h(y^k)-\nabla h(x^*))\|^2.
\tag{12.4}
$$

**Lower bound on $2\langle y^k - x^*, r^k\rangle$.** We use convexity of $f$, $g$, and $h$ **in the right directions**:

Monotonicity of $\partial f$: $\langle u^k - u^*, x^k - x^*\rangle \ge 0$, so
$$
\langle u^k, x^k - x^*\rangle \ge \langle u^*, x^k - x^*\rangle.
$$
Combined with the subgradient inequality $f(x^k) - f(x^*) \ge \langle u^*, x^k - x^*\rangle$... hmm, different direction.

**Use convexity directly, not monotonicity.**
- $f(x^*) \ge f(x^k) + \langle u^k, x^* - x^k\rangle$, i.e., $\langle u^k, x^k - x^*\rangle \ge f(x^k) - f(x^*)$.
- $g(x^*) \ge g(y^k) + \langle v^k, x^* - y^k\rangle$, i.e., $\langle v^k, y^k - x^*\rangle \ge g(y^k) - g(x^*)$.
- $h(x^*) \ge h(y^k) + \langle\nabla h(y^k), x^* - y^k\rangle$, i.e., $\langle \nabla h(y^k), y^k - x^*\rangle \ge h(y^k) - h(x^*)$.

We want $\langle y^k - x^*, r^k\rangle = \gamma\langle y^k - x^*, u^k + v^k + \nabla h(y^k)\rangle$. Split:
$$
\langle y^k - x^*, u^k\rangle = \langle x^k - x^*, u^k\rangle + \langle y^k - x^k, u^k\rangle = \langle u^k, x^k - x^*\rangle + \langle u^k, r^k\rangle.
$$
So
$$
\langle y^k - x^*, r^k\rangle = \gamma\langle u^k, x^k - x^*\rangle + \gamma\langle u^k, r^k\rangle + \gamma\langle v^k, y^k - x^*\rangle + \gamma\langle\nabla h(y^k), y^k - x^*\rangle.
\tag{12.5}
$$

By convexity:
$$
\gamma\langle u^k, x^k - x^*\rangle \ge \gamma[f(x^k) - f(x^*)],
$$
$$
\gamma\langle v^k, y^k - x^*\rangle \ge \gamma[g(y^k) - g(x^*)],
$$
$$
\gamma\langle\nabla h(y^k), y^k - x^*\rangle \ge \gamma[h(y^k) - h(x^*)].
$$
Also by convexity of $f$ at $x^k$: $\langle u^k, y^k - x^k\rangle \le f(y^k) - f(x^k)$ (using the gradient inequality in the reverse direction).

Hmm wait: $f(y^k) \ge f(x^k) + \langle u^k, y^k - x^k\rangle$ (since $u^k\in\partial f(x^k)$). So $\langle u^k, y^k - x^k\rangle \le f(y^k) - f(x^k)$, i.e. $\langle u^k, r^k\rangle \le f(y^k) - f(x^k)$.

Actually we need a *lower bound* on $\langle y^k - x^*, r^k\rangle$. The term $\gamma\langle u^k, r^k\rangle$ is bounded **above** by $\gamma[f(y^k) - f(x^k)]$, which means *lower bound* direction goes the wrong way.

To avoid this issue, we absorb $\gamma\langle u^k, r^k\rangle$ differently. Use the descent lemma for $h$ instead — the descent lemma applied to $h$ gives a *smoothness cushion* rather than a pure convexity bound, which provides the needed $\alpha$ factor.

**Trade $\langle u^k, r^k\rangle$ for descent lemma on $h$.** Note
$$
\gamma u^k \overset{(1.3)}{=} (2y^k - z^k - \gamma\nabla h(y^k)) - x^k = y^k - x^k + (y^k - z^k) - \gamma\nabla h(y^k) = r^k - \gamma v^k - \gamma\nabla h(y^k).
$$
So
$$
\gamma\langle u^k, r^k\rangle = \|r^k\|^2 - \gamma\langle v^k, r^k\rangle - \gamma\langle\nabla h(y^k), r^k\rangle.
\tag{12.6}
$$

Plugging (12.6) into (12.5):
\begin{align*}
\langle y^k - x^*, r^k\rangle &= \gamma\langle u^k, x^k - x^*\rangle + \|r^k\|^2 - \gamma\langle v^k, r^k\rangle - \gamma\langle\nabla h(y^k), r^k\rangle \\
&\quad + \gamma\langle v^k, y^k - x^*\rangle + \gamma\langle\nabla h(y^k), y^k - x^*\rangle. \tag{12.7}
\end{align*}

Now $\langle v^k, y^k - x^*\rangle - \langle v^k, r^k\rangle = \langle v^k, y^k - x^* - r^k\rangle = \langle v^k, x^k - x^*\rangle$. And $\langle\nabla h(y^k), y^k - x^*\rangle - \langle\nabla h(y^k), r^k\rangle = \langle\nabla h(y^k), x^k - x^*\rangle$. So
$$
\langle y^k - x^*, r^k\rangle = \gamma\langle u^k + v^k + \nabla h(y^k),\,x^k - x^*\rangle - \gamma\langle u^k + v^k + \nabla h(y^k), r^k\rangle + \gamma\langle u^k, r^k\rangle + \|r^k\|^2 - \gamma\langle v^k, r^k\rangle - \gamma\langle\nabla h(y^k), r^k\rangle.
$$
But $\gamma\langle u^k + v^k + \nabla h(y^k), r^k\rangle = \langle r^k, r^k\rangle = \|r^k\|^2$ (by (1.6)). So
$$
\langle y^k - x^*, r^k\rangle = \langle r^k, x^k - x^*\rangle - \|r^k\|^2 + \gamma\langle u^k, r^k\rangle + \|r^k\|^2 - \gamma\langle v^k + \nabla h(y^k), r^k\rangle.
$$
And $\gamma\langle u^k, r^k\rangle - \gamma\langle v^k + \nabla h(y^k), r^k\rangle = \gamma\langle u^k - v^k - \nabla h(y^k), r^k\rangle$. But $u^k = r^k/\gamma - v^k - \nabla h(y^k)$, so $u^k - v^k - \nabla h(y^k) = r^k/\gamma - 2v^k - 2\nabla h(y^k)$. This is a mess.

Let me verify the cancellation more simply: $\langle y^k - x^*, r^k\rangle = \langle y^k - x^k, r^k\rangle + \langle x^k - x^*, r^k\rangle = \|r^k\|^2 + \langle x^k - x^*, r^k\rangle$. (This is trivially true since $y^k - x^* = r^k + (x^k - x^*)$.) So
$$
2\langle y^k - x^*, r^k\rangle = 2\|r^k\|^2 + 2\langle x^k - x^*, r^k\rangle.
\tag{12.8}
$$

Substituting into (12.4):
$$
\|z^k - z^*\|^2 - \|z^{k+1}-z^*\|^2 = 2\|r^k\|^2 + 2\langle x^k - x^*, r^k\rangle + \gamma^2\|v^k - v^*\|^2 - \gamma^2\|(u^k-u^*)+(\nabla h(y^k)-\nabla h(x^*))\|^2.
\tag{12.9}
$$

**Bound the $\gamma^2$-difference-of-squares term.** Let $\xi := (u^k - u^*) + (\nabla h(y^k) - \nabla h(x^*))$ and $\eta := v^k - v^*$. Then
$$
\xi + \eta = \frac{r^k}{\gamma} \quad\text{(by (7.2))}. \tag{12.10}
$$
So $\gamma^2\|\eta\|^2 - \gamma^2\|\xi\|^2 = \gamma^2(\|\eta\|^2 - \|\xi\|^2) = \gamma^2(\eta - \xi)(\eta+\xi) = \gamma(\eta-\xi)\cdot r^k \cdot 1$. Actually:
$$
\|\eta\|^2 - \|\xi\|^2 = \langle \eta - \xi, \eta + \xi\rangle = \langle \eta - \xi, r^k/\gamma\rangle.
$$
So
$$
\gamma^2\|\eta\|^2 - \gamma^2\|\xi\|^2 = \gamma\langle \eta - \xi, r^k\rangle = \gamma\langle (v^k - v^*) - (u^k - u^*) - (\nabla h(y^k) - \nabla h(x^*)),\,r^k\rangle.
\tag{12.11}
$$

Substituting (12.11) into (12.9):
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 = 2\|r^k\|^2 + 2\langle x^k - x^*, r^k\rangle + \gamma\langle (v^k-v^*)-(u^k-u^*)-(\nabla h(y^k)-\nabla h(x^*)),\,r^k\rangle.
\tag{12.12}
$$

We want to extract $2\gamma[F(x^k) - F(x^*)] + \alpha\|r^k\|^2$. To this end, we need
$$
2\langle x^k - x^*, r^k\rangle + \gamma\langle (v^k-v^*)-(u^k-u^*)-(\nabla h(y^k)-\nabla h(x^*)),\,r^k\rangle \;\ge\; 2\gamma[F(x^k) - F(x^*)] + (\alpha - 2)\|r^k\|^2.
\tag{12.13}
$$
Since $\alpha - 2 = -\gamma\beta$, this becomes
$$
2\langle x^k - x^*, r^k\rangle + \gamma\langle (v^k-v^*)-(u^k-u^*)-(\nabla h(y^k)-\nabla h(x^*)), r^k\rangle \;\ge\; 2\gamma[F(x^k) - F(x^*)] - \gamma\beta\|r^k\|^2.
\tag{12.14}
$$

**Proof of (12.14).** Expand using $(u^k - u^*) + (v^k - v^*) + (\nabla h(y^k) - \nabla h(x^*)) = r^k/\gamma$:

$(v^k-v^*)-(u^k-u^*)-(\nabla h(y^k)-\nabla h(x^*)) = 2(v^k - v^*) - r^k/\gamma$.

So
$$
\gamma\langle 2(v^k-v^*) - r^k/\gamma,\, r^k\rangle = 2\gamma\langle v^k-v^*,\,r^k\rangle - \|r^k\|^2.
$$
Substituting into (12.12):
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 = 2\|r^k\|^2 + 2\langle x^k - x^*, r^k\rangle + 2\gamma\langle v^k - v^*, r^k\rangle - \|r^k\|^2 = \|r^k\|^2 + 2\langle x^k - x^*, r^k\rangle + 2\gamma\langle v^k-v^*, r^k\rangle.
\tag{12.15}
$$

(This matches (11.6) — good sanity check.)

So (12.15), equivalently (11.6), is the **exact** Fejér identity. We now need an inequality connecting this to $F(x^k) - F(x^*)$.

From (B.1) [which was proven from (A.1)+(A.6)+(A.7), using the descent lemma for $h$]:
$$
F(x^k) - F(x^*) \le \frac{1}{\gamma}\langle r^k, x^k - x^*\rangle + D_g^k + \tfrac{\beta}{2}\|r^k\|^2. \tag{B.1}
$$

Multiply by $2\gamma$:
$$
2\gamma[F(x^k) - F(x^*)] \le 2\langle r^k, x^k - x^*\rangle + 2\gamma D_g^k + \gamma\beta\|r^k\|^2.
\tag{12.16}
$$

From (12.15):
$$
2\langle r^k, x^k - x^*\rangle = \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - \|r^k\|^2 - 2\gamma\langle v^k - v^*, r^k\rangle.
\tag{12.17}
$$

Substituting (12.17) into (12.16):
$$
2\gamma[F(x^k) - F(x^*)] \le \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - (1-\gamma\beta)\|r^k\|^2 - 2\gamma\langle v^k - v^*, r^k\rangle + 2\gamma D_g^k.
\tag{12.18}
$$

**Handling $-2\gamma\langle v^k - v^*, r^k\rangle + 2\gamma D_g^k$.** Recall $r^k = y^k - x^k$, so
$$
-2\gamma\langle v^k - v^*, r^k\rangle = 2\gamma\langle v^k - v^*, x^k - y^k\rangle = 2\gamma\langle v^k, x^k - y^k\rangle - 2\gamma\langle v^*, x^k - y^k\rangle.
$$
And $D_g^k = g(x^k) - g(y^k) - \langle v^k, x^k - y^k\rangle$. So
$$
2\gamma D_g^k - 2\gamma\langle v^k - v^*, r^k\rangle = 2\gamma[g(x^k) - g(y^k) - \langle v^k, x^k-y^k\rangle] + 2\gamma\langle v^k, x^k - y^k\rangle - 2\gamma\langle v^*, x^k - y^k\rangle \\
= 2\gamma[g(x^k) - g(y^k)] - 2\gamma\langle v^*, x^k - y^k\rangle.
\tag{12.19}
$$

By convexity of $g$ at $x^*$ (using $v^*\in\partial g(x^*)$):
$$
g(y^k) \ge g(x^*) + \langle v^*, y^k - x^*\rangle,\qquad g(x^k) \ge g(x^*) + \langle v^*, x^k - x^*\rangle.
$$
Subtracting: $g(x^k) - g(y^k) \ge \langle v^*, x^k - y^k\rangle$, i.e.,
$$
2\gamma[g(x^k) - g(y^k)] - 2\gamma\langle v^*, x^k - y^k\rangle \;\ge\; 0.
\tag{12.20}
$$

But wait — (12.20) says $2\gamma[g(x^k) - g(y^k)] - 2\gamma\langle v^*, x^k - y^k\rangle \ge 0$, not $\le 0$. Substituting into (12.18) gives:
$$
2\gamma[F(x^k) - F(x^*)] \le \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - (1-\gamma\beta)\|r^k\|^2 + \underbrace{[2\gamma(g(x^k)-g(y^k)) - 2\gamma\langle v^*,x^k-y^k\rangle]}_{\ge 0}.
\tag{12.21}
$$

The residual is nonnegative, so (12.21) is valid. This does not give $-\alpha\|r^k\|^2$ on the RHS; it gives $-(1-\gamma\beta)\|r^k\|^2$ plus a nonnegative nuisance.

**Key observation to get $\alpha$.** Since (12.21) has a **nonnegative** extra term on the RHS, we cannot directly drop it. We need to incorporate it into the $F(x^k)$ on the LHS or exploit a different bound on $F(x^k)$.

Here's the trick: instead of bounding $F(x^k) - F(x^*)$, we bound the *modified functional*
$$
\hat F^k := f(x^k) + g(y^k) + h(x^k),
$$
which evaluates $g$ at $y^k$ (the $g$-prox output) rather than $x^k$.

From (A.1), (A.2), (A.7):
$$
\hat F^k - F(x^*) \le \langle u^k, x^k - x^*\rangle + \langle v^k, y^k - x^*\rangle + \langle\nabla h(y^k), x^k - x^*\rangle + \tfrac{\beta}{2}\|r^k\|^2.
$$
Regroup: $\langle v^k, y^k - x^*\rangle = \langle v^k, x^k - x^*\rangle + \langle v^k, r^k\rangle$:
$$
\hat F^k - F(x^*) \le \langle u^k + v^k + \nabla h(y^k), x^k - x^*\rangle + \langle v^k, r^k\rangle + \tfrac{\beta}{2}\|r^k\|^2 = \tfrac{1}{\gamma}\langle r^k, x^k - x^*\rangle + \langle v^k, r^k\rangle + \tfrac{\beta}{2}\|r^k\|^2.
\tag{12.22}
$$

Multiply by $2\gamma$:
$$
2\gamma[\hat F^k - F(x^*)] \le 2\langle r^k, x^k - x^*\rangle + 2\gamma\langle v^k, r^k\rangle + \gamma\beta\|r^k\|^2. \tag{12.23}
$$

Substitute (12.17):
$$
2\gamma[\hat F^k - F(x^*)] \le \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - \|r^k\|^2 - 2\gamma\langle v^k - v^*, r^k\rangle + 2\gamma\langle v^k, r^k\rangle + \gamma\beta\|r^k\|^2 \\
= \|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 - (1-\gamma\beta)\|r^k\|^2 + 2\gamma\langle v^*, r^k\rangle.
\tag{12.24}
$$

And by (11.10), $\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 + 2\gamma\langle v^*,r^k\rangle = \|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2$. So
$$
2\gamma[\hat F^k - F(x^*)] \le \|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2 - (1-\gamma\beta)\|r^k\|^2.
\tag{12.25}
$$

This is a clean telescope — but the anchor is $x^*$, the coefficient is $(1-\gamma\beta)$, and the LHS is $\hat F^k$, not $F(x^k)$.

**Connecting $\hat F^k$ to $F(x^k)$.** Note
$$
F(x^k) - \hat F^k = g(x^k) - g(y^k),
$$
and the Bregman gap gives $g(x^k) = g(y^k) + \langle v^k, x^k - y^k\rangle + D_g^k$, i.e., $g(x^k) - g(y^k) = -\langle v^k, r^k\rangle + D_g^k$. Hence
$$
F(x^k) = \hat F^k - \langle v^k, r^k\rangle + D_g^k.
\tag{12.26}
$$

**Ergodic averaging with Jensen.** Define $\bar x^K = (1/K)\sum_{k=0}^{K-1} x^k$ and $\bar y^K = (1/K)\sum_{k=0}^{K-1} y^k$. By Jensen's inequality (convexity of $F$, $f$, $g$, $h$):
$$
F(\bar x^K) \le \frac{1}{K}\sum_{k=0}^{K-1} F(x^k).
$$

We do NOT have a direct bound on $\sum F(x^k)$, only on $\sum \hat F^k$.

Claim: $\sum_{k=0}^{K-1}[\hat F^k - F(x^*)]$ upper bounds $K[F(\bar x^K) - F(x^*)]$ modulo a boundary term.

$\sum_k \hat F^k = \sum_k [f(x^k) + g(y^k) + h(x^k)]$. By convexity (Jensen):
- $\sum_k f(x^k) \ge K f(\bar x^K)$,
- $\sum_k h(x^k) \ge K h(\bar x^K)$,
- $\sum_k g(y^k) \ge K g(\bar y^K)$.

So $\sum_k \hat F^k \ge K[f(\bar x^K) + g(\bar y^K) + h(\bar x^K)]$.

Since $g$ is convex and $\bar x^K \ne \bar y^K$ in general, $g(\bar y^K)$ does not equal $g(\bar x^K)$, so we get a bound involving mixed averages.

**Clean ergodic bound via the mixed average.** Define
$$
\bar F^K := f(\bar x^K) + g(\bar y^K) + h(\bar x^K).
$$
By Jensen, $\bar F^K \le (1/K)\sum_k \hat F^k$.

Summing (12.25) over $k = 0, \ldots, K-1$:
$$
2\gamma\sum_{k=0}^{K-1}[\hat F^k - F(x^*)] \le \|z^0 - x^*\|^2 - \|z^K - x^*\|^2 - (1-\gamma\beta)\sum_{k=0}^{K-1}\|r^k\|^2.
\tag{12.27}
$$

Dropping the nonpositive term $-(1-\gamma\beta)\sum\|r^k\|^2$ (**nonpositive since $1 - \gamma\beta > -1$**; but we need $1 - \gamma\beta \ge 0$, i.e., $\gamma\le 1/\beta$, which is **stricter** than $\gamma < 2/\beta$):

If $\gamma < 1/\beta$, then $(1-\gamma\beta) > 0$ and we can drop the residual term. If $1/\beta \le \gamma < 2/\beta$, then $(1-\gamma\beta) \le 0$ and we cannot.

This is the **fundamental limitation of the descent-lemma-only approach**. To cover the full range $\gamma\in(0, 2/\beta)$ with coefficient $\alpha = 2 - \gamma\beta$, we *must* use cocoercivity.

---

### Step 13. Obstacle summary

Route 2 (averaged operator + Fejér monotonicity) requires replacing the descent-lemma estimate in (A.4) by the sharper cocoercivity estimate (3.2). Doing so changes (A.7) from
$$
h(x^k) - h(x^*) \le \langle\nabla h(y^k), x^k - x^*\rangle + \tfrac{\beta}{2}\|r^k\|^2
$$
to an inequality that, combined with monotonicity of $\partial f$ and $\partial g$, yields the factor $\alpha = 2 - \gamma\beta$ directly.

However, as attempted in Step 12, the cocoercivity-based route leads to an intermediate bound (12.25) with coefficient $(1-\gamma\beta)$ rather than $\alpha = (2-\gamma\beta)$, and on $\hat F^k$ rather than $F(x^k)$.

**Obstacle.** The operator-theoretic route (Route 2) as stated in routes.md presumes that $T_{\mathrm{DYS}}$ being averaged yields the Fejér bound
$$
\|z^{k+1} - z^*\|^2 \le \|z^k - z^*\|^2 - \alpha\|r^k\|^2.
$$
But this Fejér bound does **not** directly yield $F(x^k) - F(x^*) \le O(\|r^k\|^2 /\gamma)$; it only yields summability of $\|r^k\|^2$. The primal decoding step needed to convert $\|r^k\|^2$-summability into $F(x^k) - F(x^*)$-summability is *exactly the He-Yuan subgradient identification + telescoping of Route 1*. When we attempt it within Route 2, we reproduce Route 1's algebra.

Specifically, at the step where we combine the Fejér identity (12.15) with the convexity/descent bound (B.1), we reach (12.21) with coefficient $(1-\gamma\beta)$, not $\alpha = (2-\gamma\beta)$. Closing the gap requires either:
1. Using cocoercivity of $\nabla h$ (which converts the descent bound into a tighter form using the $\|\nabla h(y^k) - \nabla h(x^*)\|^2$ term — this is essentially Route 1's closing step); or
2. Accepting the bound on $\hat F^K$ with mixed averages $\bar y^K, \bar x^K$, which does **not** match the theorem's stated bound $F(\bar x^K) - F(x^*)\le \ldots$.

**Conclusion of Route 2 attempt.** Route 2 (pure operator-theoretic averaged-operator + Fejér + primal decoding) does *not* close to the stated bound with constant $1/(2\gamma\alpha K)$ over the full range $\gamma\in(0, 2/\beta)$ without invoking the cocoercivity-based subgradient algebra that is the heart of Route 1.

The obstacle lies in **Step 12**: the Fejér identity (12.15) is exact, but converting it into a bound on $F(x^k) - F(x^*)$ with the $\alpha = 2-\gamma\beta$ coefficient requires cocoercivity of $\nabla h$, which is not naturally deployed in the pure averaged-operator framework. The averaged-operator framework gives
$$
\|z^{k+1} - z^*\|^2 \le \|z^k - z^*\|^2 - \alpha\|r^k\|^2,\tag{Fejér with $\alpha$}
$$
but the function-value bound is not a direct consequence.

**Partial result obtainable via Route 2.** If the bound is stated for the *mixed-average* functional
$$
\bar F^K := f(\bar x^K) + g(\bar y^K) + h(\bar x^K)
$$
with coefficient $(1-\gamma\beta)$ in the range $\gamma\in(0, 1/\beta)$, then Route 2 closes via (12.27) + Jensen:
$$
\bar F^K - F(x^*) \;\le\; \frac{\|z^0 - x^*\|^2}{2\gamma K}.
$$
This is weaker than the stated theorem in two ways: (a) mixed averages, (b) restricted $\gamma$-range and missing $\alpha$ factor.

**Where Route 2 succeeds partially.** Route 2 *does* yield:
- Existence of fixed point $z^*$ (Step 2);
- Well-definedness and uniqueness of the iteration;
- Fejér monotonicity $\|z^{k+1} - z^*\|^2 \le \|z^k - z^*\|^2 - \alpha\|r^k\|^2$ (via combined monotonicity of $\partial f,\partial g$ + cocoercivity of $\nabla h$, as in (6.12) and (12.12));
- Summability: $\sum_{k=0}^{\infty}\|r^k\|^2 \le \|z^0 - z^*\|^2/\alpha$ (telescoping the Fejér bound);
- Convergence rate on residual: $\min_{0\le k<K}\|r^k\|^2 \le \|z^0-z^*\|^2/(\alpha K)$.

But the **ergodic function-value rate** at the stated constant $1/(2\gamma\alpha K)$ for the full range $\gamma\in(0, 2/\beta)$ is **not obtainable** within pure Route 2 — it requires invoking the Route 1 He-Yuan algebra to convert the residual summability into the function-value bound.

---

### Step 14. Concluding statement

**Route 2 obstruction.** Following strictly Route 2 (averaged operator + Fejér monotonicity + Cesàro averaging), we have:

1. Established well-posedness, fixed-point correspondence with minimizers, and existence of $z^*$ (Steps 1–2).
2. Derived the exact Fejér identity
$$
\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2 = \|r^k\|^2 + 2\langle r^k, x^k-x^*\rangle + 2\gamma\langle v^k - v^*, r^k\rangle,\tag{12.15}
$$
and the **Fejér monotonicity with $\alpha$-residual**
$$
\|z^{k+1}-z^*\|^2 \le \|z^k - z^*\|^2 - \alpha\|r^k\|^2,\qquad\alpha = 2-\gamma\beta,
$$
derivable by combining (12.15) with monotonicity of $\partial f,\partial g$ and cocoercivity of $\nabla h$. Telescoping gives $\sum\|r^k\|^2 \le \|z^0-z^*\|^2/\alpha$.

3. Obtained the intermediate function-value bound on the mixed functional $\hat F^k = f(x^k) + g(y^k) + h(x^k)$:
$$
2\gamma[\hat F^k - F(x^*)] \le \|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2 - (1-\gamma\beta)\|r^k\|^2,\tag{12.25}
$$
valid for $\gamma\in(0, 1/\beta)$ (to keep $(1-\gamma\beta)\ge 0$).

4. **Obstacle** (Step 12 & 13): Converting (12.25) to the stated theorem bound $F(\bar x^K) - F(x^*)\le \|z^0-z^*\|^2/(2\gamma\alpha K)$ requires:
   - replacing $\hat F^k$ (evaluated with $g(y^k)$) by $F(x^k)$ (evaluated with $g(x^k)$);
   - upgrading the residual coefficient from $(1-\gamma\beta)$ to $\alpha = (2-\gamma\beta)$ to cover the full $\gamma$-range.

Both upgrades require the cocoercivity-based subgradient algebra of Route 1 (He-Yuan style), which is precisely the technique that Route 2 was supposed to bypass. In other words, the pure operator-theoretic Route 2 *reduces to Route 1* at the primal-decoding step.

**Route 2 therefore fails to independently establish the stated ergodic bound with constant $1/(2\gamma\alpha K)$.** It succeeds only for the weaker mixed-functional, restricted-$\gamma$ version.

Q.E.D. (partial — Route 2 obstruction identified at Step 12–13)
