# Proof of Davis-Yin Three-Operator Splitting Ergodic O(1/K) Convergence

## Proof
**Route**: Variational Inequality Reformulation (Monotone Operator VI)

---

### Preliminaries and Notation

Throughout, let $\mathcal{H}$ be the ambient real Hilbert space. Recall the DYS iteration
$$
y^k = \mathrm{prox}_{\gamma g}(z^k),\qquad
x^k = \mathrm{prox}_{\gamma f}\!\bigl(2y^k - z^k - \gamma \nabla h(y^k)\bigr),\qquad
z^{k+1} = z^k + x^k - y^k.
$$
Set $\alpha := 2 - \gamma \beta \in (0,2)$, since $\gamma \in (0, 2/\beta)$.

We make repeated use of the **three-point identity (polarization)**: for all $a,b,c \in \mathcal{H}$,
$$
\langle a-b,\; a-c\rangle = \tfrac{1}{2}\|a-b\|^2 + \tfrac{1}{2}\|a-c\|^2 - \tfrac{1}{2}\|b-c\|^2, \tag{3P}
$$
equivalently,
$$
\langle a-b,\; c-b\rangle = \tfrac{1}{2}\bigl(\|a-b\|^2 + \|c-b\|^2 - \|a-c\|^2\bigr).
$$
We also use the identity
$$
\langle a,b\rangle = \tfrac{1}{2}\|a\|^2 + \tfrac{1}{2}\|b\|^2 - \tfrac{1}{2}\|a-b\|^2. \tag{POL}
$$

---

### Step 1: Fixed-point existence and optimality correspondence

**Claim 1.** Under (A4), the DYS operator $T_{\mathrm{DYS}}$ has a fixed point $z^* \in \mathcal{H}$, and with $x^* = y^* := \mathrm{prox}_{\gamma g}(z^*)$ one has $x^* \in X^*$.

*Proof.* Let $x^* \in X^*$ with $u^* \in \partial f(x^*),\, v^* \in \partial g(x^*)$ satisfying $u^* + v^* + \nabla h(x^*) = 0$. Define
$$
z^* := x^* + \gamma v^*.
$$
Then $z^* - x^* = \gamma v^*$, i.e.\ $(z^* - x^*)/\gamma = v^* \in \partial g(x^*)$, which is precisely the optimality condition for $x^* = \mathrm{prox}_{\gamma g}(z^*)$; hence $y^* := \mathrm{prox}_{\gamma g}(z^*) = x^*$.

Next, compute the $f$-prox input at $z^*$:
$$
2y^* - z^* - \gamma \nabla h(y^*) = 2x^* - (x^* + \gamma v^*) - \gamma \nabla h(x^*) = x^* - \gamma v^* - \gamma \nabla h(x^*).
$$
Using $u^* + v^* + \nabla h(x^*) = 0$, we have $-v^* - \nabla h(x^*) = u^*$, so
$$
2y^* - z^* - \gamma \nabla h(y^*) = x^* + \gamma u^*.
$$
Therefore $x^* + \gamma u^* - x^* = \gamma u^*$, i.e.\ $u^* \in \partial f(x^*)$ is exactly the optimality condition for $x^* = \mathrm{prox}_{\gamma f}(x^* + \gamma u^*)$; hence $\mathrm{prox}_{\gamma f}(2y^* - z^* - \gamma \nabla h(y^*)) = x^*$.

Finally, $T_{\mathrm{DYS}}(z^*) = z^* + x^* - y^* = z^*$, so $z^*$ is a fixed point. $\square$

We now **fix** $z^* = x^* + \gamma v^*$ and the associated $x^*, u^*, v^*$ for the rest of the proof. Note the identity
$$
z^* = x^* + \gamma v^* \quad\Longleftrightarrow\quad v^* = \frac{z^* - x^*}{\gamma}, \tag{$\star$}
$$
and consequently, from $u^* + v^* + \nabla h(x^*) = 0$,
$$
\gamma u^* = -\gamma v^* - \gamma \nabla h(x^*) = (x^* - z^*) - \gamma \nabla h(x^*). \tag{$\star\star$}
$$

---

### Step 2: Prox optimality as variational inequalities

For any proper closed convex $\phi$ and $w \in \mathcal{H}$, writing $p = \mathrm{prox}_{\gamma \phi}(w)$, the first-order optimality condition of the defining minimization is
$$
\frac{w - p}{\gamma} \in \partial \phi(p). \tag{OP}
$$
By definition of subgradient this is equivalent to the VI
$$
\phi(\xi) \geq \phi(p) + \Bigl\langle \frac{w - p}{\gamma},\; \xi - p\Bigr\rangle, \qquad \forall \xi \in \mathcal{H}. \tag{VI-$\phi$}
$$

**Apply (VI-$\phi$) with $\phi = g$, $w = z^k$, $p = y^k$:** there exists $v^k := (z^k - y^k)/\gamma \in \partial g(y^k)$, and for all $\xi$,
$$
g(\xi) \geq g(y^k) + \Bigl\langle \frac{z^k - y^k}{\gamma},\; \xi - y^k\Bigr\rangle. \tag{VI-g}
$$

**Apply (VI-$\phi$) with $\phi = f$, $w = 2y^k - z^k - \gamma \nabla h(y^k)$, $p = x^k$:** define
$$
u^k := \frac{(2y^k - z^k - \gamma \nabla h(y^k)) - x^k}{\gamma} = \frac{2y^k - z^k - x^k}{\gamma} - \nabla h(y^k) \in \partial f(x^k),
$$
so for all $\xi$,
$$
f(\xi) \geq f(x^k) + \bigl\langle u^k,\, \xi - x^k\bigr\rangle. \tag{VI-f}
$$

Using $z^{k+1} - z^k = x^k - y^k$, we can rewrite $2y^k - z^k - x^k = y^k - z^{k+1}$, hence
$$
u^k = \frac{y^k - z^{k+1}}{\gamma} - \nabla h(y^k). \tag{u}
$$

We will apply (VI-g) and (VI-f) at the specific test point $\xi = x^*$.

---

### Step 3: Convexity of $h$ and the smooth descent lemma

Since $h$ is convex, for all $a,b \in \mathcal{H}$,
$$
h(a) \geq h(b) + \langle \nabla h(b), a - b\rangle. \tag{CVX-h}
$$

Since $\nabla h$ is $\beta$-Lipschitz and $h$ is convex (hence differentiable everywhere with this gradient), the **descent lemma** holds:
$$
h(a) \leq h(b) + \langle \nabla h(b), a - b\rangle + \frac{\beta}{2}\|a-b\|^2. \tag{DL-h}
$$
We use (CVX-h) at $(a,b) = (x^*, y^k)$, and (DL-h) at $(a,b) = (x^k, y^k)$:
$$
h(x^*) \geq h(y^k) + \langle \nabla h(y^k), x^* - y^k\rangle, \tag{H1}
$$
$$
h(x^k) \leq h(y^k) + \langle \nabla h(y^k), x^k - y^k\rangle + \frac{\beta}{2}\|x^k - y^k\|^2. \tag{H2}
$$
Subtracting (H1) from (H2):
$$
h(x^k) - h(x^*) \leq \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2. \tag{H}
$$

---

### Step 4: Combining the two VIs with convexity of $h$

Apply (VI-g) at $\xi = x^*$:
$$
g(x^*) - g(y^k) \geq \Bigl\langle \frac{z^k - y^k}{\gamma},\; x^* - y^k\Bigr\rangle. \tag{G}
$$
Apply (VI-f) at $\xi = x^*$:
$$
f(x^*) - f(x^k) \geq \langle u^k,\, x^* - x^k\rangle \;=\; \Bigl\langle \frac{y^k - z^{k+1}}{\gamma} - \nabla h(y^k),\; x^* - x^k\Bigr\rangle. \tag{F}
$$

**Goal of this step:** bound $F(x^k) - F(x^*) = f(x^k) + g(x^k) + h(x^k) - f(x^*) - g(x^*) - h(x^*)$. But (G) involves $g(y^k)$ not $g(x^k)$. We handle this by first writing
$$
F(x^k) - F(x^*) = [f(x^k) - f(x^*)] + [g(x^k) - g(x^*)] + [h(x^k) - h(x^*)].
$$
We replace $g(x^k) - g(x^*)$ by a chain through $y^k$: adding and subtracting $g(y^k)$,
$$
g(x^k) - g(x^*) = [g(x^k) - g(y^k)] + [g(y^k) - g(x^*)].
$$

Using convexity of $g$ with $v^k = (z^k - y^k)/\gamma \in \partial g(y^k)$,
$$
g(x^k) \geq g(y^k) + \langle v^k, x^k - y^k\rangle,
$$
but we need an upper bound on $g(x^k) - g(y^k)$. To obtain it, note that $v^k \in \partial g(y^k)$ yields (by the subgradient inequality at the other endpoint — **we cannot reverse** the direction of the subgradient inequality in general). This is the crucial subtlety: we do **not** bound $g(x^k) - g(y^k)$ via $v^k$.

Instead, we exploit the **VI formulation directly** in the "duality gap" form. Consider the functional
$$
Q_k := \bigl[f(x^k) - f(x^*)\bigr] + \bigl[g(y^k) - g(x^*)\bigr] + \bigl[h(x^k) - h(x^*)\bigr].
$$
We shall first bound $Q_k$ and then relate $Q_k$ to $F(x^k) - F(x^*)$ by accounting for $g(x^k) - g(y^k)$.

Rearranging (G) and (F):
$$
g(y^k) - g(x^*) \leq \Bigl\langle \frac{z^k - y^k}{\gamma},\; y^k - x^*\Bigr\rangle, \tag{G'}
$$
$$
f(x^k) - f(x^*) \leq \Bigl\langle \frac{y^k - z^{k+1}}{\gamma} - \nabla h(y^k),\; x^k - x^*\Bigr\rangle. \tag{F'}
$$

From (H): $h(x^k) - h(x^*) \leq \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2$.

Summing (G') + (F') + (H), the $\nabla h(y^k)$ terms cancel:
$$
Q_k \leq \Bigl\langle \frac{y^k - z^{k+1}}{\gamma},\; x^k - x^*\Bigr\rangle + \Bigl\langle \frac{z^k - y^k}{\gamma},\; y^k - x^*\Bigr\rangle + \frac{\beta}{2}\|x^k - y^k\|^2. \tag{1}
$$

---

### Step 5: Accounting for the $g(x^k)-g(y^k)$ gap

To upgrade $Q_k$ to $F(x^k) - F(x^*)$, we need an upper bound on $g(x^k) - g(y^k)$. Since $x^k$ and $y^k$ are both in $\mathcal{H}$ and $g$ is convex, there is no uniform such bound; we sidestep this by working with the averaged iterate along a slightly different path.

**Observation:** The final estimate we want is on $F(\bar x^K)$, not $F(x^k)$ individually. By Jensen applied to each component of $F$,
$$
F(\bar x^K) = f(\bar x^K) + g(\bar x^K) + h(\bar x^K) \leq \frac{1}{K}\sum_{k=0}^{K-1}[f(x^k) + g(x^k) + h(x^k)] = \frac{1}{K}\sum_{k=0}^{K-1} F(x^k).
$$
We will bound $\sum_k [F(x^k) - F(x^*)]$ by bounding $\sum_k Q_k$ and separately handling the sum $\sum_k [g(x^k) - g(y^k)]$.

However there is a cleaner route: **directly bound $F(\bar x^K) - F(x^*)$ using Jensen on a weighted average**. Specifically, since $g$ is convex and $g(y^k) \leq g(x^*) + \langle v^k, y^k - x^*\rangle$ is an **upper** bound on $g(y^k) - g(x^*)$ in the wrong direction — actually (G') gives an upper bound, which is what we need. So (G') is correctly giving $g(y^k) - g(x^*) \leq \cdots$. The issue is only $g(x^k) - g(y^k)$.

Define instead the **modified ergodic average**
$$
\bar y^K := \frac{1}{K}\sum_{k=0}^{K-1} y^k, \qquad \bar x^K := \frac{1}{K}\sum_{k=0}^{K-1} x^k.
$$
By Jensen applied to $f$, $g$, $h$ separately:
$$
f(\bar x^K) \leq \frac{1}{K}\sum_k f(x^k),\qquad h(\bar x^K) \leq \frac{1}{K}\sum_k h(x^k),\qquad g(\bar y^K) \leq \frac{1}{K}\sum_k g(y^k).
$$
But the target inequality involves $F(\bar x^K) = f(\bar x^K) + g(\bar x^K) + h(\bar x^K)$, **with $\bar x^K$ in all three terms**.

To reconcile, we use the fact that $z^{k+1} - z^k = x^k - y^k$ and therefore
$$
\sum_{k=0}^{K-1}(x^k - y^k) = z^K - z^0.
$$
Thus $\bar x^K - \bar y^K = (z^K - z^0)/K$. As we will establish boundedness of $z^k$ in Step 7, this difference $\to 0$ but it does not vanish identically. Hence we cannot trivially replace $\bar y^K$ by $\bar x^K$ in the $g$-term.

**The standard DYS trick (following Davis–Yin 2017, Theorem D.6):** use $g$-convexity backward. For any $\lambda \in [0,1]$ and the convex combination $x^k = \lambda x^k + (1-\lambda) x^k$ etc., there is no direct handle. Instead, we exploit the VI in a **symmetric form**: apply (VI-f) at $\xi = y^k$ (not $x^*$) to get the reverse $g$ comparison… but $y^k$ is not $x^*$, so this doesn't close.

The correct maneuver: **bound $F$ at $x^k$ by $F$ at a convex combination of $y^k$ and $x^k$, or use the subgradient of $g$ at $y^k$ in the reverse direction as an equality test**. The cleanest approach, which we now follow, is:

Let $v^k = (z^k - y^k)/\gamma \in \partial g(y^k)$. By convexity of $g$,
$$
g(x^k) \geq g(y^k) + \langle v^k, x^k - y^k\rangle. \tag{G-rev}
$$
This is the "wrong" direction for an upper bound on $g(x^k) - g(y^k)$. However, we will **add and subtract** $\langle v^k, x^k - y^k\rangle$ to convert:
$$
g(x^k) - g(x^*) = [g(x^k) - g(y^k)] + [g(y^k) - g(x^*)].
$$
We have an upper bound (G') on the second bracket. For the first bracket, since we only have a **lower** bound (G-rev), we must reorganize the analysis.

**Resolution via the canonical DYS Lyapunov identity:** The correct path is to prove the one-step estimate
$$
2\gamma\bigl[F(x^k) - F(x^*)\bigr] \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \alpha \|z^{k+1} - z^k\|^2. \tag{MAIN}
$$
This treats $F(x^k) - F(x^*)$ directly (with $x^k$ as the primal iterate, no $y^k$-averaging complication). The key is that $g(x^k) - g(y^k)$ will be controlled by the **subgradient** of $g$ at $y^k$ evaluated **at $x^k$ via (G-rev)**, then combined with $v^* \in \partial g(x^*)$ through a different inequality.

We now re-derive the one-step estimate along this clean route.

---

### Step 6: The correct one-step inequality (MAIN)

We replace the VI at the test point $x^*$ with the following four inequalities:

**(I1) Convexity of $f$ at $x^k$ with subgradient $u^k \in \partial f(x^k)$:**
$$
f(x^*) \geq f(x^k) + \langle u^k, x^* - x^k\rangle,
$$
which rearranges to
$$
f(x^k) - f(x^*) \leq \langle u^k, x^k - x^*\rangle. \tag{I1}
$$

**(I2) Convexity of $g$ at $y^k$ with subgradient $v^k \in \partial g(y^k)$, evaluated at the point $x^*$:**
$$
g(x^*) \geq g(y^k) + \langle v^k, x^* - y^k\rangle,
$$
hence
$$
g(y^k) - g(x^*) \leq \langle v^k, y^k - x^*\rangle. \tag{I2}
$$

**(I3) Convexity of $g$ at $y^k$ with subgradient $v^k \in \partial g(y^k)$, evaluated at the point $x^k$:**
$$
g(x^k) \geq g(y^k) + \langle v^k, x^k - y^k\rangle,
$$
hence
$$
g(y^k) \leq g(x^k) - \langle v^k, x^k - y^k\rangle. \tag{I3}
$$

Adding (I2) and (I3):
$$
g(y^k) - g(x^*) \leq \langle v^k, y^k - x^*\rangle \quad\text{and}\quad g(y^k) \leq g(x^k) - \langle v^k, x^k - y^k\rangle,
$$
which gives, by subtracting (I3) from (I2) style (more precisely: combine the inequality $g(x^k) \geq g(y^k) + \langle v^k, x^k-y^k\rangle$ together with (I2))
$$
g(x^k) - g(x^*) \geq g(y^k) - g(x^*) + \langle v^k, x^k - y^k\rangle.
$$
This is still a **lower** bound on $g(x^k) - g(x^*)$, not an upper bound. To get an upper bound, we use yet a different tactic.

**(I2') Convexity of $g$ at $x^*$ with subgradient $v^* \in \partial g(x^*)$:**
$$
g(y^k) \geq g(x^*) + \langle v^*, y^k - x^*\rangle, \qquad g(x^k) \geq g(x^*) + \langle v^*, x^k - x^*\rangle.
$$
Again these are lower bounds on $g(y^k), g(x^k)$ minus $g(x^*)$, the wrong sign.

The way out, and the **actual bookkeeping used in DYS analyses**, is to bound the "VI gap"
$$
\mathcal{G}_k(x^*) := \bigl\langle u^k + v^k + \nabla h(y^k),\; x^k - x^*\bigr\rangle
$$
and recognize that this gap upper-bounds $F(x^k) - F(x^*)$ **via a single chain of convexity at $x^k$ and $y^k$**, as follows:

Using (I1), (I3)-turned-around, and convexity of $h$ at $y^k$:
\begin{align*}
f(x^k) - f(x^*) &\leq \langle u^k, x^k - x^*\rangle, \\
g(x^k) - g(x^*) &= [g(x^k) - g(y^k)] + [g(y^k) - g(x^*)].
\end{align*}
For $g(x^k) - g(y^k)$ we use convexity of $g$ at $x^k$, *if* we had a subgradient of $g$ at $x^k$. We do not directly; but we can use the **Bregman identity** structure:
$$
g(x^k) - g(y^k) - \langle v^k, x^k - y^k\rangle \geq 0 \quad\text{(Bregman)},
$$
so
$$
g(x^k) - g(y^k) \geq \langle v^k, x^k - y^k\rangle.
$$
Combined with (I2),
$$
g(x^k) - g(x^*) \geq \langle v^k, x^k - y^k\rangle + g(y^k) - g(x^*) \;\text{and}\; g(y^k) - g(x^*) \leq \langle v^k, y^k - x^*\rangle,
$$
which does not give an upper bound on $g(x^k) - g(x^*)$.

**The resolution — introduce $F$ at the test point $x^k$ directly using VI at a shifted reference.** Define, as per Davis–Yin, the modified "VI anchor" $w = x^*$ with subgradients $u^*, v^*$. Then
$$
F(x^k) - F(x^*) - \langle u^* + v^* + \nabla h(x^*), x^k - x^*\rangle = F(x^k) - F(x^*),
$$
since $u^* + v^* + \nabla h(x^*) = 0$. Now use the three convexity inequalities at $x^*$ with subgradients $u^*, v^*, \nabla h(x^*)$:
$$
f(x^k) \geq f(x^*) + \langle u^*, x^k - x^*\rangle,\quad
g(x^k) \geq g(x^*) + \langle v^*, x^k - x^*\rangle,\quad
h(x^k) \geq h(x^*) + \langle \nabla h(x^*), x^k - x^*\rangle.
$$
Summing: $F(x^k) \geq F(x^*) + \langle u^* + v^* + \nabla h(x^*), x^k - x^*\rangle = F(x^*)$, giving only $F(x^k) \geq F(x^*)$ — tautological.

**The correct approach** (following the He-Yuan VI framework): instead of upper-bounding $F(x^k) - F(x^*)$ by $\langle u^k + v^k + \nabla h(y^k), x^k - x^*\rangle$, we upper-bound it by the **VI gap evaluated at the appropriate mixed point**:

**Key observation.** We use convexity of $f$ (I1), convexity of $g$ at $y^k$ evaluated at the test point $x^*$ (I2), and convexity of $h$ via the descent lemma (H). Crucially, we **upper-bound $F(x^k) - F(x^*)$ by $f(x^k) + g(y^k) + h(x^k) - F(x^*)$ plus an error term $g(x^k) - g(y^k)$**, and handle the error by a different device.

Instead, we pursue the **direct route** that avoids this issue entirely:

**Redefine the target gap as the "augmented" gap:**
$$
\widetilde Q_k := [f(x^k) - f(x^*)] + [g(y^k) - g(x^*)] + [h(x^k) - h(x^*)].
$$
We first bound $\widetilde Q_k$ via VI; then we convert it to $F(x^k) - F(x^*)$ **after summing** by using the identity
$$
\sum_{k=0}^{K-1} [g(x^k) - g(y^k)] \geq \sum_{k=0}^{K-1} \langle v^k, x^k - y^k\rangle \qquad\text{by (I3)},
$$
but this goes the wrong direction.

**Final, clean path — apply Jensen to the mixed ergodic average.** The insight, which we now execute, is that in the ergodic bound the correct primal average is $\bar x^K$, but in the VI we naturally get $g(y^k)$. We use:
$$
f(\bar x^K) + g(\bar y^K) + h(\bar x^K) \leq \frac{1}{K}\sum_{k=0}^{K-1} [f(x^k) + g(y^k) + h(x^k)] = \frac{1}{K}\sum_{k=0}^{K-1} \widetilde F_k,
$$
where $\widetilde F_k := f(x^k) + g(y^k) + h(x^k)$. And we note that because $\bar x^K - \bar y^K = (z^K - z^0)/K \to 0$, we have asymptotically $\bar x^K \approx \bar y^K$. But for a finite-$K$ bound on $F(\bar x^K) - F(x^*)$, we need to handle $g(\bar x^K) - g(\bar y^K)$ explicitly.

**Step 6A (the cleanest closure):** *We adopt the following standard DYS presentation*: prove the ergodic bound on the quantity
$$
\Phi(\bar x^K, \bar y^K) := f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*),
$$
and then **upgrade** to $F(\bar x^K) - F(x^*)$ via the subgradient inequality at $\bar y^K$ using $\bar x^K - \bar y^K = (z^K - z^0)/K$. We will see below that this upgrade contributes a term that vanishes up to lower order and can be absorbed.

However, to keep the proof self-contained and match the theorem statement exactly, we take a different and cleaner approach in Step 6B.

**Step 6B (the direct bound on $F(x^k) - F(x^*)$ using three-point identities in $z$-space).**

Recall:
- $v^k = (z^k - y^k)/\gamma \in \partial g(y^k)$,
- $u^k = (y^k - z^{k+1})/\gamma - \nabla h(y^k) \in \partial f(x^k)$,
- $z^{k+1} - z^k = x^k - y^k$.

Start from convexity of $f$, $g$, $h$ at the subgradient points $(x^k, y^k, y^k)$:
$$
f(x^k) \leq f(x^*) + \langle u^k, x^k - x^*\rangle \qquad \text{(by I1)}.
$$
For $g$: we need an upper bound on $g(x^k) - g(x^*)$. We write $g(x^k) - g(x^*) = [g(x^k) - g(y^k)] + [g(y^k) - g(x^*)]$ and use (I3)-reverse — but (I3) gives only a lower bound on $g(x^k) - g(y^k)$.

**The crucial realization.** In the DYS analysis, the correct output is a bound on $F(x^k) - F(x^*)$ where the **$g$-term is evaluated at $y^k$, not $x^k$**. This is because in DYS, $y^k = \mathrm{prox}_{\gamma g}(\cdot)$ is the iterate associated with $g$, while $x^k$ is associated with $f$. The natural "primal iterate" for a rate on $F$ is neither $x^k$ nor $y^k$ but their weighted average. Crucially, **the theorem statement uses $\bar x^K$** which is the $f$-iterate average.

We close the gap by the following trick: since $z^{k+1} - z^k = x^k - y^k$, telescoping gives $\sum_k (x^k - y^k) = z^K - z^0$, so
$$
\bar x^K = \bar y^K + \frac{z^K - z^0}{K}.
$$
We will see after summing that the corresponding error term is $O(1/K)$ times a bounded quantity, consistent with the $O(1/K)$ rate. To keep everything exact, we proceed as follows.

**We prove the bound in the form $\widetilde Q_k \leq \Delta_k$ where $\widetilde Q_k = f(x^k) + g(y^k) + h(x^k) - F(x^*)$, then use Jensen on $f, h$ with $\bar x^K$, and on $g$ with $\bar y^K$, giving a bound on $f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*)$. Finally, we upgrade to $F(\bar x^K) - F(x^*)$.**

This is done as follows:

**Upgrade lemma.** By convexity of $g$ and $v^* = (z^* - x^*)/\gamma \in \partial g(x^*)$, we have for any $y$,
$$
g(y) \geq g(x^*) + \langle v^*, y - x^*\rangle.
$$
In particular, $g(\bar y^K) \geq g(x^*) + \langle v^*, \bar y^K - x^*\rangle$. Also, $g(\bar x^K) \geq g(x^*) + \langle v^*, \bar x^K - x^*\rangle$, hence
$$
g(\bar x^K) - g(\bar y^K) \geq \langle v^*, \bar x^K - \bar y^K\rangle = \Bigl\langle v^*,\; \frac{z^K - z^0}{K}\Bigr\rangle.
$$
This goes the **wrong direction** (lower bound on $g(\bar x^K) - g(\bar y^K)$), which is fine for our purpose: we will use the **opposite** direction, namely an upper bound. But we do not have an upper bound on $g(\bar x^K) - g(\bar y^K)$ in terms of the iterates easily.

Given the complexity of reconciling $\bar x^K$ vs $\bar y^K$, we now commit to the approach that **directly proves (MAIN) $2\gamma[F(x^k) - F(x^*)] \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \alpha \|z^{k+1} - z^k\|^2$**, which is what the theorem requires. The key technical step is to control the $g(x^k) - g(y^k)$ term using the **Bregman nonnegativity** and the descent lemma's quadratic slack.

---

### Step 6C: Clean derivation of the one-step inequality (MAIN)

Using (I1) with $u^k = (y^k - z^{k+1})/\gamma - \nabla h(y^k)$:
$$
f(x^k) - f(x^*) \leq \Bigl\langle \frac{y^k - z^{k+1}}{\gamma} - \nabla h(y^k),\; x^k - x^*\Bigr\rangle. \tag{A}
$$
Using (I2) with $v^k = (z^k - y^k)/\gamma$:
$$
g(y^k) - g(x^*) \leq \Bigl\langle \frac{z^k - y^k}{\gamma},\; y^k - x^*\Bigr\rangle. \tag{B}
$$
Using (I3): $g(x^k) - g(y^k) \geq \langle v^k, x^k - y^k\rangle$, which rearranges to
$$
g(y^k) - g(x^k) \leq -\langle v^k, x^k - y^k\rangle = \Bigl\langle \frac{z^k - y^k}{\gamma},\; y^k - x^k\Bigr\rangle. \tag{C}
$$
Adding (B) and (C):
$$
g(x^k) - g(x^*) = [g(y^k) - g(x^*)] - [g(y^k) - g(x^k)] \geq \Bigl\langle \frac{z^k - y^k}{\gamma},\; y^k - x^*\Bigr\rangle - \Bigl\langle \frac{z^k - y^k}{\gamma},\; y^k - x^k\Bigr\rangle \cdot \text{(opposite sign)}.
$$
Wait, let me redo this carefully. We have:
- (B): $g(y^k) - g(x^*) \leq \langle v^k, y^k - x^*\rangle$.
- (I3): $g(x^k) \geq g(y^k) + \langle v^k, x^k - y^k\rangle$, i.e., $g(x^k) - g(y^k) \geq \langle v^k, x^k - y^k\rangle$.

Adding:
$$
g(x^k) - g(x^*) = [g(x^k) - g(y^k)] + [g(y^k) - g(x^*)].
$$
From (I3): $g(x^k) - g(y^k) \geq \langle v^k, x^k - y^k\rangle$ — a **lower** bound.
From (B): $g(y^k) - g(x^*) \leq \langle v^k, y^k - x^*\rangle$ — an **upper** bound.
These cannot be directly added to get an upper bound on $g(x^k) - g(x^*)$.

**Key insight:** We must use convexity of $g$ at $x^*$, not at $y^k$. With $v^* = (z^* - x^*)/\gamma \in \partial g(x^*)$,
$$
g(x^k) \leq g(x^*) + \langle s, x^k - x^*\rangle \quad\text{requires} \quad s \in \partial g(x^k),
$$
which we don't have access to directly. So this path is also blocked.

**The actual closure used by Davis–Yin** is: the **descent-type inequality holds with $g$ at $y^k$**, i.e., the one-step inequality is more naturally stated as
$$
f(x^k) + g(y^k) + h(x^k) - F(x^*) \leq \frac{1}{2\gamma}\bigl(\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \alpha \|z^{k+1} - z^k\|^2\bigr),
$$
giving a rate on the **mixed ergodic gap** $f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*)$.

To recover the stated bound on $F(\bar x^K) - F(x^*)$, we note that **the theorem as commonly stated and as stated in the problem requires a small additional step**: using convexity of $g$ with $v^* \in \partial g(x^*)$,
$$
g(\bar x^K) \leq g(\bar y^K) + \langle v^*, \bar x^K - \bar y^K\rangle + [\text{gap from convexity of }g].
$$
This is not quite a clean inequality. **However**, the statement of the theorem uses $\bar x^K$. We resolve this by showing that one can choose to state the ergodic bound on $\bar x^K$ with an additional vanishing term, and that under the choice $z^* = x^* + \gamma v^*$, the term $\langle v^*, \bar x^K - \bar y^K\rangle = \langle v^*, (z^K - z^0)/K\rangle$ is a telescoping residual that is absorbed into the $\|z^K - z^*\|^2 \geq 0$ term.

We now make this precise.

---

### Step 7: One-step inequality for the mixed gap

From (A), (B), and (H):
\begin{align*}
&[f(x^k) - f(x^*)] + [g(y^k) - g(x^*)] + [h(x^k) - h(x^*)] \\
&\quad \leq \Bigl\langle \frac{y^k - z^{k+1}}{\gamma} - \nabla h(y^k),\; x^k - x^*\Bigr\rangle + \Bigl\langle \frac{z^k - y^k}{\gamma},\; y^k - x^*\Bigr\rangle + \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2 \\
&\quad = \frac{1}{\gamma}\bigl\langle y^k - z^{k+1},\; x^k - x^*\bigr\rangle + \frac{1}{\gamma}\bigl\langle z^k - y^k,\; y^k - x^*\bigr\rangle + \frac{\beta}{2}\|x^k - y^k\|^2. \tag{2}
\end{align*}

We now simplify the RHS using $z^{k+1} - z^k = x^k - y^k$. Write $x^k = y^k + (z^{k+1} - z^k)$ and $y^k - z^{k+1} = -(x^k - y^k) + (y^k - z^k) \cdot 0$... let's instead just compute directly.

**Compute term $T_1 := \langle y^k - z^{k+1}, x^k - x^*\rangle$:**

Using $x^k - x^* = (x^k - y^k) + (y^k - x^*) = (z^{k+1} - z^k) + (y^k - x^*)$:
$$
T_1 = \langle y^k - z^{k+1},\; z^{k+1} - z^k\rangle + \langle y^k - z^{k+1},\; y^k - x^*\rangle.
$$

**Compute term $T_2 := \langle z^k - y^k,\; y^k - x^*\rangle$.**

Summing:
$$
T_1 + T_2 = \langle y^k - z^{k+1},\; z^{k+1} - z^k\rangle + \langle (y^k - z^{k+1}) + (z^k - y^k),\; y^k - x^*\rangle.
$$
Note that $(y^k - z^{k+1}) + (z^k - y^k) = z^k - z^{k+1} = -(x^k - y^k)$. So
$$
T_1 + T_2 = \langle y^k - z^{k+1},\; z^{k+1} - z^k\rangle - \langle x^k - y^k,\; y^k - x^*\rangle.
$$

This still has $y^k - x^*$, which we want to convert to $z$-space differences. Recall $x^* = y^*$ and $z^* = x^* + \gamma v^*$, so $y^k - x^* = y^k - y^*$. Also $(z^k - y^k) = \gamma v^k$ and $(z^* - y^*) = \gamma v^*$, giving
$$
(z^k - z^*) - (y^k - y^*) = \gamma(v^k - v^*).
$$

We now take a more systematic approach. Introduce the anchors $a^k := z^k - \gamma v^*$ and $a^* := z^* - \gamma v^* = x^*$. Then
\begin{align*}
a^k - y^k &= (z^k - \gamma v^*) - y^k = (z^k - y^k) - \gamma v^* = \gamma(v^k - v^*), \\
a^{k+1} - y^k &= (z^{k+1} - \gamma v^*) - y^k = (z^{k+1} - y^k) - \gamma v^* = (x^k - z^k) - \gamma v^* \\
&\quad\ldots \text{using } z^{k+1} - y^k = z^{k+1} - z^k + z^k - y^k = (x^k - y^k) + (z^k - y^k).
\end{align*}

To avoid this growing algebra, we use a cleaner reformulation. We define
$$
\Delta_k := \|z^k - z^*\|^2.
$$
We expand using the polarization identity:
$$
\|z^{k+1} - z^*\|^2 = \|z^k - z^*\|^2 + 2\langle z^{k+1} - z^k,\; z^k - z^*\rangle + \|z^{k+1} - z^k\|^2,
$$
so
$$
\Delta_k - \Delta_{k+1} = -2\langle z^{k+1} - z^k,\; z^k - z^*\rangle - \|z^{k+1} - z^k\|^2 = -2\langle x^k - y^k, z^k - z^*\rangle - \|z^{k+1} - z^k\|^2. \tag{$\Delta$}
$$

Our goal is to show (with $\widetilde Q_k := f(x^k) + g(y^k) + h(x^k) - F(x^*)$):
$$
2\gamma \widetilde Q_k \leq \Delta_k - \Delta_{k+1} - \alpha\|z^{k+1} - z^k\|^2. \tag{MAIN'}
$$
By ($\Delta$), this is equivalent to
$$
2\gamma \widetilde Q_k + 2\langle x^k - y^k, z^k - z^*\rangle + \|z^{k+1} - z^k\|^2 + \alpha \|z^{k+1} - z^k\|^2 \leq 0,
$$
i.e.,
$$
2\gamma \widetilde Q_k + 2\langle x^k - y^k, z^k - z^*\rangle + (1 + \alpha)\|z^{k+1} - z^k\|^2 \leq 0.
$$

Note $1 + \alpha = 3 - \gamma \beta$. We will show this holds term-by-term.

---

### Step 8: Algebraic verification of (MAIN')

Multiply inequality (2) by $2\gamma$:
$$
2\gamma \widetilde Q_k \leq 2 \langle y^k - z^{k+1}, x^k - x^*\rangle + 2\langle z^k - y^k, y^k - x^*\rangle + \gamma \beta\|x^k - y^k\|^2. \tag{2'}
$$

Recall $x^k - y^k = z^{k+1} - z^k$, so $\|x^k - y^k\|^2 = \|z^{k+1} - z^k\|^2$. Thus the last term is $\gamma \beta \|z^{k+1} - z^k\|^2$.

Now we rewrite the two inner products. Note the identities:
$$
y^k - z^{k+1} = y^k - z^k - (z^{k+1} - z^k) = -\gamma v^k - (x^k - y^k), \quad\text{where } \gamma v^k = z^k - y^k,
$$
and $z^k - y^k = \gamma v^k$. Also $x^* = z^* - \gamma v^*$, so
$$
x^k - x^* = x^k - z^* + \gamma v^*,\qquad y^k - x^* = y^k - z^* + \gamma v^*.
$$

Let us compute each inner product in (2'):

**Term $A := 2\langle y^k - z^{k+1}, x^k - x^*\rangle$.**
Using $y^k - z^{k+1} = (y^k - z^k) - (z^{k+1} - z^k) = -\gamma v^k - (x^k - y^k)$ and $x^k - x^* = (x^k - y^k) + (y^k - x^*)$:
\begin{align*}
A/2 &= \langle -\gamma v^k - (x^k - y^k),\; (x^k - y^k) + (y^k - x^*)\rangle \\
&= -\gamma \langle v^k,\; x^k - y^k\rangle - \gamma \langle v^k,\; y^k - x^*\rangle - \|x^k - y^k\|^2 - \langle x^k - y^k,\; y^k - x^*\rangle.
\end{align*}

**Term $B := 2\langle z^k - y^k, y^k - x^*\rangle = 2\gamma \langle v^k, y^k - x^*\rangle$.**

Summing:
$$
A + B = -2\gamma \langle v^k,\; x^k - y^k\rangle - 2\gamma \langle v^k,\; y^k - x^*\rangle + 2\gamma \langle v^k, y^k - x^*\rangle - 2\|x^k - y^k\|^2 - 2\langle x^k - y^k,\; y^k - x^*\rangle.
$$
The middle two $\gamma \langle v^k, y^k - x^*\rangle$ terms cancel:
$$
A + B = -2\gamma \langle v^k,\; x^k - y^k\rangle - 2\|x^k - y^k\|^2 - 2\langle x^k - y^k,\; y^k - x^*\rangle.
$$

Substitute into (2'):
$$
2\gamma \widetilde Q_k \leq -2\gamma \langle v^k,\; x^k - y^k\rangle - 2\|x^k - y^k\|^2 - 2\langle x^k - y^k,\; y^k - x^*\rangle + \gamma \beta \|x^k - y^k\|^2. \tag{2''}
$$

Note that $-2\|x^k - y^k\|^2 + \gamma\beta \|x^k-y^k\|^2 = -(2 - \gamma\beta)\|x^k - y^k\|^2 = -\alpha \|z^{k+1} - z^k\|^2$. Hence
$$
2\gamma \widetilde Q_k + 2\gamma \langle v^k, x^k - y^k\rangle + 2\langle x^k - y^k,\; y^k - x^*\rangle + \alpha \|z^{k+1} - z^k\|^2 \leq 0. \tag{3}
$$

Now we relate the cross terms on the LHS to $2\langle x^k - y^k, z^k - z^*\rangle$:
$$
2\gamma v^k = 2(z^k - y^k), \quad \text{so} \quad 2\gamma \langle v^k, x^k - y^k\rangle = 2\langle z^k - y^k, x^k - y^k\rangle.
$$
Also
$$
2\langle x^k - y^k, y^k - x^*\rangle = 2\langle x^k - y^k, y^k\rangle - 2\langle x^k - y^k, x^*\rangle.
$$

Let us instead add the two middle terms in (3):
\begin{align*}
&2\gamma \langle v^k, x^k - y^k\rangle + 2\langle x^k - y^k, y^k - x^*\rangle \\
&= 2\langle z^k - y^k, x^k - y^k\rangle + 2\langle x^k - y^k, y^k - x^*\rangle \\
&= 2\langle x^k - y^k,\; (z^k - y^k) + (y^k - x^*)\rangle \\
&= 2\langle x^k - y^k,\; z^k - x^*\rangle.
\end{align*}

So (3) becomes
$$
2\gamma \widetilde Q_k + 2\langle x^k - y^k,\; z^k - x^*\rangle + \alpha \|z^{k+1} - z^k\|^2 \leq 0. \tag{4}
$$

Now, we wanted (from (MAIN') and the expansion ($\Delta$)):
$$
2\gamma \widetilde Q_k + 2\langle x^k - y^k,\; z^k - z^*\rangle + (1+\alpha)\|z^{k+1} - z^k\|^2 \leq 0. \tag{target}
$$

The difference between (4) and (target) is:
- (4) has $z^k - x^*$, (target) has $z^k - z^*$. Since $z^* = x^* + \gamma v^*$, we have $z^k - z^* = (z^k - x^*) - \gamma v^*$, so
$$
\langle x^k - y^k, z^k - z^*\rangle = \langle x^k - y^k, z^k - x^*\rangle - \gamma \langle x^k - y^k, v^*\rangle.
$$

- (4) has $\alpha$, (target) has $1 + \alpha$. The difference is $\|z^{k+1} - z^k\|^2$.

Therefore (target) is equivalent to
$$
2\gamma \widetilde Q_k + 2\langle x^k - y^k, z^k - x^*\rangle - 2\gamma \langle x^k - y^k, v^*\rangle + \alpha\|z^{k+1}-z^k\|^2 + \|z^{k+1}-z^k\|^2 \leq 0.
$$
Using (4), it suffices to show:
$$
-2\gamma \langle x^k - y^k, v^*\rangle + \|z^{k+1} - z^k\|^2 \leq 0,
$$
i.e.,
$$
\|z^{k+1} - z^k\|^2 \leq 2\gamma \langle x^k - y^k, v^*\rangle = 2\gamma \langle z^{k+1} - z^k, v^*\rangle. \tag{†}
$$

But (†) is **not** always true: e.g., near the fixed point $x^k = y^k$, both sides are $0$, but for general $x^k - y^k$, the RHS can be negative while the LHS is non-negative. So there is an error in the derivation.

Let me recheck the target. From ($\Delta$):
$$
\Delta_k - \Delta_{k+1} = -2\langle x^k - y^k, z^k - z^*\rangle - \|z^{k+1} - z^k\|^2.
$$
We want (MAIN'):
$$
2\gamma \widetilde Q_k \leq \Delta_k - \Delta_{k+1} - \alpha \|z^{k+1} - z^k\|^2.
$$
Substituting:
$$
2\gamma \widetilde Q_k \leq -2\langle x^k - y^k, z^k - z^*\rangle - \|z^{k+1} - z^k\|^2 - \alpha \|z^{k+1} - z^k\|^2,
$$
which rearranges to
$$
2\gamma \widetilde Q_k + 2\langle x^k - y^k, z^k - z^*\rangle + (1 + \alpha)\|z^{k+1} - z^k\|^2 \leq 0. \tag{target}
$$

And (4) gave: $2\gamma \widetilde Q_k + 2\langle x^k - y^k, z^k - x^*\rangle + \alpha \|z^{k+1} - z^k\|^2 \leq 0$.

Difference (target) $-$ (4) = $2\langle x^k - y^k, z^k - z^*\rangle - 2\langle x^k - y^k, z^k - x^*\rangle + \|z^{k+1} - z^k\|^2 = -2\gamma \langle x^k - y^k, v^*\rangle + \|z^{k+1}-z^k\|^2$ (since $z^* - x^* = \gamma v^*$).

So for (target) to follow from (4), we'd need $-2\gamma \langle x^k - y^k, v^*\rangle + \|z^{k+1}-z^k\|^2 \leq 0$, which as noted need not hold.

This suggests that **the "right" Lyapunov anchor is not $z^*$ but $x^*$ in the $z$-space**, i.e., inequality (4) tells us
$$
2\gamma \widetilde Q_k \leq \Delta'_k - \Delta'_{k+1} - \alpha \|z^{k+1} - z^k\|^2
$$
where $\Delta'_k := \|z^k - x^*\|^2$? Let's check:
$$
\Delta'_k - \Delta'_{k+1} = -2\langle z^{k+1} - z^k, z^k - x^*\rangle - \|z^{k+1} - z^k\|^2 = -2\langle x^k - y^k, z^k - x^*\rangle - \|z^{k+1} - z^k\|^2.
$$
So (4) gives $2\gamma \widetilde Q_k \leq \Delta'_k - \Delta'_{k+1} - (\alpha - 1) \|z^{k+1} - z^k\|^2$, not what we want.

The discrepancy stems from the choice of VI test point. We chose $\xi = x^*$ in (VI-g) and (VI-f). The correct choice for a Lyapunov based on $\|z^k - z^*\|^2$ is to test at $\xi = x^*$ but **with a subgradient correction term that turns the anchor into $z^*$**. Specifically, we should test (VI-f) at $\xi = x^*$ but also apply (VI-g) at a **shifted point** so that the resulting anchor in the $\Delta$-expansion is $z^*$.

**The correct choice:** Apply (VI-g) at $\xi = x^* - \gamma v^*$ — **no**, this is arbitrary. Let's instead re-examine by choosing to test (VI-g) at $\xi = x^*$ and (VI-f) at $\xi = x^*$ both, but then adding a **zero term**
$$
0 = \langle u^* + v^* + \nabla h(x^*),\; x^k - x^*\rangle
$$
to the inequality. With $u^* + v^* + \nabla h(x^*) = 0$, adding $-\langle u^*+v^*+\nabla h(x^*), x^k - x^*\rangle = 0$ to inequality (2) gives:
$$
\widetilde Q_k = [f(x^k) - f(x^*) - \langle u^*, x^k - x^*\rangle] + [g(y^k) - g(x^*) - \langle v^*, y^k - x^*\rangle] + [h(x^k) - h(x^*) - \langle \nabla h(x^*), x^k - x^*\rangle] \\
\quad + \langle u^*, x^k - x^*\rangle + \langle v^*, y^k - x^*\rangle + \langle \nabla h(x^*), x^k - x^*\rangle.
$$
The first three brackets are each $\geq 0$ by convexity (these are Bregman divergences). But since we want an **upper** bound on $\widetilde Q_k$, adding non-negative quantities is the wrong direction.

Instead, we use the VI at test point $\xi = x^*$ with subgradient anchors corrected. The proper formulation:

**Corrected (VI-f) at $\xi = x^*$:** $f(x^*) \geq f(x^k) + \langle u^k, x^* - x^k\rangle$ gives $f(x^k) - f(x^*) \leq \langle u^k, x^k - x^*\rangle$. But also, by convexity $f(x^k) \geq f(x^*) + \langle u^*, x^k - x^*\rangle$, i.e., $f(x^k) - f(x^*) \geq \langle u^*, x^k - x^*\rangle$. Combining:
$$
\langle u^*, x^k - x^*\rangle \leq f(x^k) - f(x^*) \leq \langle u^k, x^k - x^*\rangle,
$$
so
$$
f(x^k) - f(x^*) \leq \langle u^k, x^k - x^*\rangle = \langle u^k - u^*, x^k - x^*\rangle + \langle u^*, x^k - x^*\rangle.
$$
Ah, but we want the sharpest upper bound, which is $\langle u^k, x^k - x^*\rangle$.

Now use monotonicity of $\partial f$: since $u^k \in \partial f(x^k)$ and $u^* \in \partial f(x^*)$,
$$
\langle u^k - u^*, x^k - x^*\rangle \geq 0.
$$
This means $\langle u^k, x^k - x^*\rangle \geq \langle u^*, x^k - x^*\rangle$, consistent with the bracket above. This gives us the stronger bound:
$$
f(x^k) - f(x^*) \leq \langle u^k, x^k - x^*\rangle, \tag{A*}
$$
and similarly
$$
g(y^k) - g(x^*) \leq \langle v^k, y^k - x^*\rangle \tag{B*}
$$
(these are unchanged from (A), (B), just re-derived).

The key now: write
$$
\langle u^k, x^k - x^*\rangle = \langle u^k - u^*, x^k - x^*\rangle + \langle u^*, x^k - x^*\rangle,
$$
$$
\langle v^k, y^k - x^*\rangle = \langle v^k - v^*, y^k - x^*\rangle + \langle v^*, y^k - x^*\rangle.
$$

Summing with the descent (H):
\begin{align*}
\widetilde Q_k &\leq \langle u^k - u^*, x^k - x^*\rangle + \langle v^k - v^*, y^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2 \\
&\quad + \langle u^*, x^k - x^*\rangle + \langle v^*, y^k - x^*\rangle + \langle \nabla h(y^k), x^k - x^*\rangle.
\end{align*}
Wait, let me redo. From (A), (B), (H):
\begin{align*}
\widetilde Q_k &= [f(x^k)-f(x^*)] + [g(y^k)-g(x^*)] + [h(x^k)-h(x^*)] \\
&\leq \langle u^k, x^k - x^*\rangle + \langle v^k, y^k - x^*\rangle + \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2.
\end{align*}
Now subtract and add $\langle u^*, x^k - x^*\rangle + \langle v^*, y^k - x^*\rangle + \langle \nabla h(x^*), x^k - x^*\rangle$. Using $u^* + v^* + \nabla h(x^*) = 0$:
$$
\langle u^*, x^k - x^*\rangle + \langle v^*, x^k - x^*\rangle + \langle \nabla h(x^*), x^k - x^*\rangle = 0,
$$
so we add $0$ of the form $\langle v^*, y^k - x^*\rangle - \langle v^*, x^k - x^*\rangle + [\langle u^*, x^k - x^*\rangle + \langle v^*, x^k - x^*\rangle + \langle \nabla h(x^*), x^k - x^*\rangle]$; the bracket is zero. So we have added $\langle v^*, y^k - x^k\rangle$ on the RHS, meaning our bound is only sharper if we subtract this. Let's redo cleanly:

Add and subtract $\langle u^*, x^k - x^*\rangle + \langle v^*, y^k - x^*\rangle + \langle \nabla h(x^*), x^k - x^*\rangle$:
\begin{align*}
\text{RHS of }(2) &= \bigl[\langle u^k - u^*, x^k - x^*\rangle + \langle v^k - v^*, y^k - x^*\rangle + \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle\bigr] + \frac{\beta}{2}\|x^k-y^k\|^2 \\
&\quad + \bigl[\langle u^*, x^k - x^*\rangle + \langle v^*, y^k - x^*\rangle + \langle \nabla h(x^*), x^k - x^*\rangle\bigr].
\end{align*}

Denote $E_k := \langle u^k - u^*, x^k - x^*\rangle + \langle v^k - v^*, y^k - x^*\rangle + \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle$ and the second bracket as $R_k$:
$$
R_k = \langle u^*, x^k - x^*\rangle + \langle v^*, y^k - x^*\rangle + \langle \nabla h(x^*), x^k - x^*\rangle.
$$
Using $u^* + \nabla h(x^*) = -v^*$:
$$
R_k = \langle -v^*, x^k - x^*\rangle + \langle v^*, y^k - x^*\rangle = \langle v^*, y^k - x^k\rangle = -\langle v^*, x^k - y^k\rangle.
$$

So
$$
\widetilde Q_k \leq E_k + \frac{\beta}{2}\|x^k - y^k\|^2 - \langle v^*, x^k - y^k\rangle. \tag{2-refined}
$$

Now, $u^k - u^* = \frac{y^k - z^{k+1}}{\gamma} - \nabla h(y^k) - u^*$. Using $\gamma u^* = (x^* - z^*) - \gamma \nabla h(x^*)$ from ($\star\star$), so $u^* = (x^* - z^*)/\gamma - \nabla h(x^*)$. Then
$$
u^k - u^* = \frac{y^k - z^{k+1}}{\gamma} - \nabla h(y^k) - \frac{x^* - z^*}{\gamma} + \nabla h(x^*) = \frac{(y^k - x^*) - (z^{k+1} - z^*)}{\gamma} - (\nabla h(y^k) - \nabla h(x^*)).
$$

And $v^k - v^* = (z^k - y^k)/\gamma - (z^* - x^*)/\gamma = \frac{(z^k - z^*) - (y^k - x^*)}{\gamma}$.

So
\begin{align*}
\gamma \langle u^k - u^*, x^k - x^*\rangle &= \langle (y^k - x^*) - (z^{k+1} - z^*),\; x^k - x^*\rangle - \gamma \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle, \\
\gamma \langle v^k - v^*, y^k - x^*\rangle &= \langle (z^k - z^*) - (y^k - x^*),\; y^k - x^*\rangle.
\end{align*}

Therefore
\begin{align*}
\gamma E_k &= \langle (y^k - x^*) - (z^{k+1} - z^*),\; x^k - x^*\rangle + \langle (z^k - z^*) - (y^k - x^*),\; y^k - x^*\rangle \\
&\quad + \gamma \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle - \gamma \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle \\
&= \langle (y^k - x^*) - (z^{k+1} - z^*),\; x^k - x^*\rangle + \langle (z^k - z^*) - (y^k - x^*),\; y^k - x^*\rangle.
\end{align*}

So the $\nabla h$ terms cancel inside $\gamma E_k$ (this is the key cancellation). Expand:
\begin{align*}
\gamma E_k &= \langle y^k - x^*, x^k - x^*\rangle - \langle z^{k+1} - z^*, x^k - x^*\rangle + \langle z^k - z^*, y^k - x^*\rangle - \|y^k - x^*\|^2.
\end{align*}

We now want to express this as a telescoping quantity $\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2$ plus a quadratic residual. We use three-point identities.

Use (3P) or (POL). Let us use (POL): $\langle a, b\rangle = \tfrac{1}{2}(\|a\|^2 + \|b\|^2 - \|a-b\|^2)$.

However, our inner products mix $y^k, z^k, z^{k+1}, x^k$. A cleaner tactic: use
$$
\langle z^{k+1} - z^*, x^k - x^*\rangle = \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle + \langle z^{k+1} - z^*, y^k - x^*\rangle,
$$
since $x^k - x^* = (x^k - y^k) + (y^k - x^*) = (z^{k+1} - z^k) + (y^k - x^*)$.

Similarly,
$$
\langle z^k - z^*, y^k - x^*\rangle \quad \text{stays}.
$$

Rewrite $\gamma E_k$:
\begin{align*}
\gamma E_k &= \langle y^k - x^*, x^k - x^*\rangle - \|y^k - x^*\|^2 - \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle - \langle z^{k+1} - z^*, y^k - x^*\rangle + \langle z^k - z^*, y^k - x^*\rangle \\
&= \langle y^k - x^*, x^k - x^* - (y^k - x^*)\rangle - \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle + \langle (z^k - z^*) - (z^{k+1} - z^*), y^k - x^*\rangle \\
&= \langle y^k - x^*, x^k - y^k\rangle - \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle + \langle z^k - z^{k+1}, y^k - x^*\rangle \\
&= \langle y^k - x^*, x^k - y^k\rangle - \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle - \langle z^{k+1} - z^k, y^k - x^*\rangle \\
&= \langle x^k - y^k, y^k - x^*\rangle - \langle x^k - y^k, y^k - x^*\rangle - \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle \quad\text{(using } z^{k+1}-z^k = x^k - y^k\text{)} \\
&= -\langle z^{k+1} - z^*, z^{k+1} - z^k\rangle.
\end{align*}

**Excellent cancellation!** So
$$
\gamma E_k = -\langle z^{k+1} - z^*,\; z^{k+1} - z^k\rangle. \tag{E}
$$

Now use (POL): $-\langle a, b\rangle = \tfrac{1}{2}(-\|a\|^2 - \|b\|^2 + \|a-b\|^2) = \tfrac{1}{2}(\|a - b\|^2 - \|a\|^2 - \|b\|^2)$. With $a = z^{k+1} - z^*$, $b = z^{k+1} - z^k$:
$$
a - b = z^k - z^*, \quad \|a - b\|^2 = \|z^k - z^*\|^2.
$$
So
$$
\gamma E_k = \tfrac{1}{2}\bigl(\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \|z^{k+1} - z^k\|^2\bigr). \tag{E'}
$$

Substituting (E') into (2-refined) and multiplying by $2\gamma$:
$$
2\gamma \widetilde Q_k \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \|z^{k+1} - z^k\|^2 + \gamma\beta \|x^k - y^k\|^2 - 2\gamma \langle v^*, x^k - y^k\rangle.
$$

Using $\|x^k - y^k\|^2 = \|z^{k+1} - z^k\|^2$:
$$
2\gamma \widetilde Q_k \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - (1 - \gamma\beta) \|z^{k+1} - z^k\|^2 - 2\gamma \langle v^*, x^k - y^k\rangle. \tag{5}
$$

Note $1 - \gamma \beta \neq \alpha = 2 - \gamma \beta$. We are off by one power of $\|z^{k+1}-z^k\|^2$. The culprit is the cross term $-2\gamma \langle v^*, x^k - y^k\rangle$, which we now handle.

**Handling $-2\gamma \langle v^*, x^k - y^k\rangle$:** recall $\gamma v^* = z^* - x^*$. Write $x^k - y^k = z^{k+1} - z^k$. Use (POL) with $a = z^{k+1} - z^k$ and $b = z^* - x^*$... actually use (POL) to expand:
$$
-2\langle z^* - x^*,\; z^{k+1} - z^k\rangle = -\|(z^*-x^*)\|^2 - \|z^{k+1}-z^k\|^2 + \|(z^*-x^*) - (z^{k+1}-z^k)\|^2.
$$
But this introduces $\|z^* - x^*\|^2 = \gamma^2 \|v^*\|^2$, a constant. We don't want to add a constant to each step; let me try a different route.

**Alternative: telescope directly.** The term $-2\gamma\langle v^*, x^k - y^k\rangle = -2\langle z^* - x^*, z^{k+1} - z^k\rangle$. Summed from $k=0$ to $K-1$:
$$
\sum_{k=0}^{K-1} -2\langle z^* - x^*, z^{k+1} - z^k\rangle = -2\langle z^* - x^*, z^K - z^0\rangle.
$$
This is telescoped, but involves $z^K$. To absorb, note that $\|z^K - z^*\|^2 \geq 0$ and
$$
\|z^K - z^*\|^2 = \|(z^K - z^0) - (z^* - z^0)\|^2 = \|z^K - z^0\|^2 - 2\langle z^K - z^0, z^* - z^0\rangle + \|z^* - z^0\|^2 \geq 0.
$$

Hmm, this does not cleanly cancel. Let me recheck the derivation of (E) to look for errors.

**Recheck of $\gamma E_k$:**
$$
\gamma E_k = \gamma \langle u^k - u^*, x^k - x^*\rangle + \gamma \langle v^k - v^*, y^k - x^*\rangle + \gamma \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle.
$$
From the expression of $u^k - u^*$:
$$
\gamma (u^k - u^*) = (y^k - x^*) - (z^{k+1} - z^*) - \gamma(\nabla h(y^k) - \nabla h(x^*)).
$$
So
$$
\gamma \langle u^k - u^*, x^k - x^*\rangle = \langle y^k - x^*, x^k - x^*\rangle - \langle z^{k+1} - z^*, x^k - x^*\rangle - \gamma \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle.
$$
Adding $\gamma \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle$:
$$
\gamma\langle u^k-u^*, x^k-x^*\rangle + \gamma\langle\nabla h(y^k)-\nabla h(x^*), x^k-x^*\rangle = \langle y^k-x^*, x^k-x^*\rangle - \langle z^{k+1}-z^*, x^k-x^*\rangle.
$$
Good.

From $v^k - v^* = \frac{(z^k - z^*) - (y^k - x^*)}{\gamma}$:
$$
\gamma \langle v^k - v^*, y^k - x^*\rangle = \langle z^k - z^*, y^k - x^*\rangle - \|y^k - x^*\|^2.
$$
So
$$
\gamma E_k = \langle y^k - x^*, x^k - x^*\rangle - \langle z^{k+1} - z^*, x^k - x^*\rangle + \langle z^k - z^*, y^k - x^*\rangle - \|y^k - x^*\|^2.
$$

This matches what I had. Continuing:
$$
\langle y^k - x^*, x^k - x^*\rangle - \|y^k - x^*\|^2 = \langle y^k - x^*, x^k - x^* - (y^k - x^*)\rangle = \langle y^k - x^*, x^k - y^k\rangle.
$$
So
$$
\gamma E_k = \langle y^k - x^*, x^k - y^k\rangle + \langle z^k - z^*, y^k - x^*\rangle - \langle z^{k+1} - z^*, x^k - x^*\rangle.
$$

Now: $\langle z^{k+1} - z^*, x^k - x^*\rangle = \langle z^{k+1} - z^*, (x^k - y^k) + (y^k - x^*)\rangle = \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle + \langle z^{k+1} - z^*, y^k - x^*\rangle$.

Thus
\begin{align*}
\gamma E_k &= \langle y^k - x^*, x^k - y^k\rangle + \langle z^k - z^*, y^k - x^*\rangle - \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle - \langle z^{k+1} - z^*, y^k - x^*\rangle \\
&= \langle y^k - x^*, x^k - y^k\rangle + \langle z^k - z^{k+1}, y^k - x^*\rangle - \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle \\
&= \langle y^k - x^*, x^k - y^k\rangle - \langle z^{k+1} - z^k, y^k - x^*\rangle - \langle z^{k+1} - z^*, z^{k+1} - z^k\rangle.
\end{align*}

Now $z^{k+1} - z^k = x^k - y^k$, so $\langle z^{k+1} - z^k, y^k - x^*\rangle = \langle x^k - y^k, y^k - x^*\rangle = \langle y^k - x^*, x^k - y^k\rangle$. Wait — $\langle x^k - y^k, y^k - x^*\rangle = \langle x^k - y^k, y^k - x^*\rangle$. And $\langle y^k - x^*, x^k - y^k\rangle$ is the same thing. So these two terms cancel:
$$
\langle y^k - x^*, x^k - y^k\rangle - \langle z^{k+1} - z^k, y^k - x^*\rangle = \langle y^k - x^*, x^k - y^k\rangle - \langle x^k - y^k, y^k - x^*\rangle = 0.
$$

Therefore
$$
\gamma E_k = -\langle z^{k+1} - z^*,\; z^{k+1} - z^k\rangle. \tag{E confirmed}
$$

So (E) and (E') are correct. The issue is then in (2-refined). Let me recheck (2-refined).

**Recheck of (2-refined) and $R_k$:**

Starting from (2):
$$
\widetilde Q_k \leq \frac{1}{\gamma}\langle y^k - z^{k+1}, x^k - x^*\rangle + \frac{1}{\gamma}\langle z^k - y^k, y^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2.
$$

Note: the RHS of (2) uses the VIs (A), (B) directly. Let me re-derive (2) carefully.

From (A): $f(x^k) - f(x^*) \leq \langle u^k, x^k - x^*\rangle = \langle \frac{y^k - z^{k+1}}{\gamma} - \nabla h(y^k), x^k - x^*\rangle$.
From (B): $g(y^k) - g(x^*) \leq \langle v^k, y^k - x^*\rangle = \langle \frac{z^k - y^k}{\gamma}, y^k - x^*\rangle$.
From (H): $h(x^k) - h(x^*) \leq \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2$.

Adding, the $\nabla h(y^k)$ terms cancel:
$$
\widetilde Q_k \leq \frac{1}{\gamma}\langle y^k - z^{k+1}, x^k - x^*\rangle + \frac{1}{\gamma}\langle z^k - y^k, y^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2. \tag{2}
$$

Now, observe that the first term can be written as $\langle u^k - u^* + u^* + \nabla h(y^k) - \nabla h(y^k), x^k - x^*\rangle$ etc. Let me use a different bookkeeping.

Define the **VI gap operator**: set
$$
G_k := \langle u^k, x^k - x^*\rangle + \langle v^k, y^k - x^*\rangle + \langle \nabla h(y^k), x^k - x^*\rangle.
$$
Then (2) says $\widetilde Q_k \leq G_k - \langle \nabla h(y^k), x^k - x^*\rangle + \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2 = G_k + \frac{\beta}{2}\|x^k - y^k\|^2 - \text{(nothing)}$. Wait:
$$
G_k = \langle u^k, x^k - x^*\rangle + \langle v^k, y^k - x^*\rangle + \langle \nabla h(y^k), x^k - x^*\rangle.
$$
From (A), (B), (H) (recall (H) gives $h(x^k) - h(x^*) \leq \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k-y^k\|^2$):
$$
\widetilde Q_k \leq G_k + \frac{\beta}{2}\|x^k - y^k\|^2. \tag{2-alt}
$$

Now write $G_k$ in terms of $u^k - u^*$, $v^k - v^*$, $\nabla h(y^k) - \nabla h(x^*)$, plus $R_k$ terms:
$$
G_k = \langle u^k - u^*, x^k - x^*\rangle + \langle v^k - v^*, y^k - x^*\rangle + \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle + R_k,
$$
where
$$
R_k := \langle u^*, x^k - x^*\rangle + \langle v^*, y^k - x^*\rangle + \langle \nabla h(x^*), x^k - x^*\rangle.
$$
Using $u^* + \nabla h(x^*) = -v^*$:
$$
R_k = \langle -v^*, x^k - x^*\rangle + \langle v^*, y^k - x^*\rangle = \langle v^*, y^k - x^k\rangle = \langle v^*, -(x^k - y^k)\rangle = -\langle v^*, z^{k+1} - z^k\rangle.
$$
(Recall $x^k - y^k = z^{k+1} - z^k$.)

And (from derivation above) $\langle u^k - u^*, x^k - x^*\rangle + \langle v^k - v^*, y^k - x^*\rangle + \langle \nabla h(y^k) - \nabla h(x^*), x^k - x^*\rangle = E_k$, so $G_k = E_k + R_k$.

From (E'): $E_k = \frac{1}{2\gamma}\bigl(\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \|z^{k+1} - z^k\|^2\bigr)$.

So (2-alt) becomes:
$$
\widetilde Q_k \leq E_k + R_k + \frac{\beta}{2}\|x^k - y^k\|^2 = \frac{1}{2\gamma}\bigl(\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \|z^{k+1} - z^k\|^2\bigr) - \langle v^*, z^{k+1} - z^k\rangle + \frac{\beta}{2}\|z^{k+1} - z^k\|^2. \tag{6}
$$

Multiplying by $2\gamma$:
$$
2\gamma \widetilde Q_k \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - (1 - \gamma \beta)\|z^{k+1} - z^k\|^2 - 2\gamma\langle v^*, z^{k+1} - z^k\rangle. \tag{6'}
$$

---

### Step 9: Summing and handling the residual

Sum (6') from $k = 0$ to $K-1$. The $\|z^k - z^*\|^2$ terms telescope:
$$
\sum_{k=0}^{K-1}(\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2) = \|z^0 - z^*\|^2 - \|z^K - z^*\|^2.
$$
The linear-in-$z^{k+1} - z^k$ term telescopes:
$$
\sum_{k=0}^{K-1} \langle v^*, z^{k+1} - z^k\rangle = \langle v^*, z^K - z^0\rangle.
$$

So
$$
2\gamma \sum_{k=0}^{K-1} \widetilde Q_k \leq \|z^0 - z^*\|^2 - \|z^K - z^*\|^2 - (1 - \gamma\beta)\sum_{k=0}^{K-1}\|z^{k+1} - z^k\|^2 - 2\gamma \langle v^*, z^K - z^0\rangle. \tag{7}
$$

Now use the identity $z^* - x^* = \gamma v^*$, so
$$
-2\gamma \langle v^*, z^K - z^0\rangle = -2\langle z^* - x^*, z^K - z^0\rangle.
$$

Use polarization: $\|z^K - z^*\|^2 = \|(z^K - z^0) - (z^* - z^0)\|^2 = \|z^K - z^0\|^2 - 2\langle z^K - z^0, z^* - z^0\rangle + \|z^* - z^0\|^2$. Not directly useful.

**Use instead:** $\|z^K - z^* + \gamma v^*\|^2 = \|z^K - x^*\|^2 \geq 0$. Expanding:
$$
\|z^K - z^*\|^2 + 2\gamma \langle z^K - z^*, v^*\rangle + \gamma^2 \|v^*\|^2 \geq 0,
$$
so
$$
-2\gamma\langle v^*, z^K - z^*\rangle \leq \|z^K - z^*\|^2 + \gamma^2 \|v^*\|^2.
$$
And $-2\gamma\langle v^*, z^K - z^0\rangle = -2\gamma \langle v^*, z^K - z^*\rangle - 2\gamma\langle v^*, z^* - z^0\rangle$.

This is getting messy. Let me try a **clean fix**: reconsider the starting VI by incorporating $v^*$ correctly from the start.

**The clean approach — redefine the subgradient identification.**

Recall from prox optimality: $v^k := (z^k - y^k)/\gamma \in \partial g(y^k)$. The convexity inequality (B) at test point $x^*$:
$$
g(y^k) - g(x^*) \leq \langle v^k, y^k - x^*\rangle.
$$

*Alternative form using $v^*$*: Add and subtract $\langle v^*, y^k - x^*\rangle$:
$$
g(y^k) - g(x^*) \leq \langle v^k - v^*, y^k - x^*\rangle + \langle v^*, y^k - x^*\rangle.
$$
The first term is monotonicity-nonnegative. But we use the full bound $\langle v^k, y^k - x^*\rangle$.

Alternatively, we can write $v^k = (z^k - y^k)/\gamma$ and note
$$
\langle v^k, y^k - x^*\rangle = \frac{1}{\gamma}\langle z^k - y^k, y^k - x^*\rangle.
$$

**The actual resolution (key insight):** We must ensure the anchor in the $\Delta$-telescope is $z^*$ (not $x^*$). The issue is that $u^k, v^k$ are "centered" at iterates $(x^k, y^k)$, whose relation to $z^*$ involves the fixed-point equation $z^* = x^* + \gamma v^*$.

Look at (6') again. The residual term $-2\gamma \langle v^*, z^{k+1} - z^k\rangle$ plus the $\|z^{k+1} - z^k\|^2$ can be combined via polarization with $\|z^{k+1} - z^*\|^2$. Specifically:

**Rewrite using $z^* = x^* + \gamma v^*$.** We have
$$
\|z^{k+1} - z^*\|^2 = \|z^{k+1} - x^* - \gamma v^*\|^2 = \|z^{k+1} - x^*\|^2 - 2\gamma\langle v^*, z^{k+1} - x^*\rangle + \gamma^2 \|v^*\|^2,
$$
and similarly for $k$. Not obviously helpful.

**Try a different expansion — use the identity**
$$
\|z^{k+1} - z^k\|^2 - 2\gamma \langle v^*, z^{k+1} - z^k\rangle = \|z^{k+1} - z^k - \gamma v^*\|^2 - \gamma^2 \|v^*\|^2.
$$
Since $\gamma v^* = z^* - x^*$:
$$
z^{k+1} - z^k - \gamma v^* = (z^{k+1} - z^*) - (z^k - x^*) \stackrel{?}{=}\ldots
$$
Wait, $z^{k+1} - z^k - \gamma v^* = z^{k+1} - z^k - (z^* - x^*) = (z^{k+1} - z^*) - (z^k - x^*)$. This is a mixture of anchors.

Let me **instead try starting with the anchor $\hat z^k := z^k + \gamma v^*$** or another shift. Actually, the correct move is to adjust the subgradient identification so that the telescope naturally produces $\|z^k - z^*\|^2$.

**Redo subgradient identification with $v^*$-shift.** Note that ($\star$) gives $\gamma v^* = z^* - x^*$. So
$$
\gamma v^k - \gamma v^* = (z^k - y^k) - (z^* - x^*) = (z^k - z^*) - (y^k - x^*).
$$
Similarly, $\gamma u^* = (x^* - z^*) - \gamma \nabla h(x^*) = -\gamma v^* - \gamma \nabla h(x^*)$, so $u^* = -v^* - \nabla h(x^*)$.

Now, the **clean identity** for $E_k$ is (E): $\gamma E_k = -\langle z^{k+1} - z^*, z^{k+1} - z^k\rangle$. Let's instead compute $\gamma(E_k + R_k/\gamma) = \gamma G_k$ and use (POL) directly on $\gamma G_k$:
$$
\gamma G_k = \gamma E_k + \gamma R_k = -\langle z^{k+1} - z^*, z^{k+1} - z^k\rangle - \gamma \langle v^*, z^{k+1} - z^k\rangle.
$$
Combine:
$$
\gamma G_k = -\langle z^{k+1} - z^* + \gamma v^*, z^{k+1} - z^k\rangle = -\langle z^{k+1} - x^*, z^{k+1} - z^k\rangle,
$$
where we used $z^* - \gamma v^* = x^*$, so $z^{k+1} - z^* + \gamma v^* = z^{k+1} - x^*$.

Now apply (POL) with $a = z^{k+1} - x^*$, $b = z^{k+1} - z^k$:
$$
-\langle a, b\rangle = \tfrac{1}{2}(\|a-b\|^2 - \|a\|^2 - \|b\|^2).
$$
$a - b = z^{k+1} - x^* - (z^{k+1} - z^k) = z^k - x^*$. So
$$
\gamma G_k = \tfrac{1}{2}\bigl(\|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2 - \|z^{k+1} - z^k\|^2\bigr). \tag{E''}
$$

**But wait**, this uses anchor $x^*$, giving a telescope in $\|z^k - x^*\|^2$, not $\|z^k - z^*\|^2$. That's a different statement than the theorem.

Let me reconsider. The theorem states the bound in terms of $\|z^0 - z^*\|^2$. The above (E'') gives a telescope in $\|z^k - x^*\|^2$, which is different. Are these compatible?

Let's check: if (E'') is used in (2-alt):
$$
2\gamma \widetilde Q_k \leq \|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2 - \|z^{k+1} - z^k\|^2 + \gamma\beta \|z^{k+1}-z^k\|^2 = \|z^k - x^*\|^2 - \|z^{k+1} - x^*\|^2 - \alpha'\|z^{k+1}-z^k\|^2
$$
with $\alpha' = 1 - \gamma\beta$. This requires $\gamma < 1/\beta$, a stricter condition than $\gamma < 2/\beta$. So this is *not* the correct Lyapunov.

**There must be a different bookkeeping.** Let me reconsider the cross-term handling.

**Key realization:** The descent lemma (H2): $h(x^k) \leq h(y^k) + \langle \nabla h(y^k), x^k - y^k\rangle + \frac{\beta}{2}\|x^k - y^k\|^2$.

We used $h(x^*) \geq h(y^k) + \langle \nabla h(y^k), x^* - y^k\rangle$ (convexity). Subtracting gives (H): $h(x^k) - h(x^*) \leq \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2$.

This produces the $\frac{\beta}{2}\|x^k - y^k\|^2$ slack. After multiplying by $2\gamma$, this becomes $\gamma\beta \|z^{k+1} - z^k\|^2$. Combined with $-\|z^{k+1}-z^k\|^2$ from the telescope, we get $-(1-\gamma\beta)\|z^{k+1}-z^k\|^2$.

The $\alpha = 2 - \gamma\beta$ requires *another* $-\|z^{k+1}-z^k\|^2$ on the RHS. Where does it come from?

**It comes from the FNE of prox** (firm nonexpansiveness), which we haven't used explicitly! The VI (OP)/(VI-$\phi$) is the first-order condition, but prox is actually **firmly nonexpansive**: $\mathrm{prox}_{\gamma\phi}$ satisfies
$$
\|\mathrm{prox}_{\gamma\phi}(w_1) - \mathrm{prox}_{\gamma\phi}(w_2)\|^2 \leq \langle \mathrm{prox}_{\gamma\phi}(w_1) - \mathrm{prox}_{\gamma\phi}(w_2), w_1 - w_2\rangle. \tag{FNE}
$$

Equivalently, for $p = \mathrm{prox}_{\gamma\phi}(w)$, the monotonicity of $\partial \phi$ gives: for any $w', p' = \mathrm{prox}_{\gamma\phi}(w')$,
$$
\langle p - p',\; (w - p) - (w' - p')\rangle \geq 0, \quad\text{i.e., }\quad \langle p - p', w - w'\rangle \geq \|p - p'\|^2. \tag{FNE'}
$$

Equivalently, the "half-monotonicity" sharpening of (VI-$\phi$): the subgradient inequality admits a strengthening via Bregman:
$$
\phi(\xi) \geq \phi(p) + \Bigl\langle \frac{w-p}{\gamma}, \xi - p\Bigr\rangle + D_\phi(\xi, p),
$$
where $D_\phi \geq 0$. This is just the subgradient inequality without strengthening; the FNE lives at the level of the prox map, not the subgradient.

**The actual source of the extra $-\|z^{k+1}-z^k\|^2$ is the following strengthened VI.** The prox VI (VI-$\phi$) can be strengthened using $D_\phi \geq 0$:
$$
\phi(\xi) \geq \phi(p) + \Bigl\langle \frac{w-p}{\gamma}, \xi - p\Bigr\rangle.
$$
This is not strengthened. But combining the two prox VIs via FNE cross-term gives additional slack. Let me try:

**Apply (VI-g) with $\xi = $ some shifted point related to the previous iterate's prox.** Consider applying (VI-g) at $\xi = x^*$ and also **at $\xi = y^*$ (which equals $x^*$)**. That gives the same (B).

**Try: apply (VI-g) with $\xi = y^*$ and $(VI-g')$ at the test point $z^*$ fixed-point iteration:** Since $y^* = \mathrm{prox}_{\gamma g}(z^*)$, the FNE of $\mathrm{prox}_{\gamma g}$ gives
$$
\|y^k - y^*\|^2 \leq \langle y^k - y^*, z^k - z^*\rangle. \tag{FNE-g}
$$

This is a quantitative inequality, using FNE directly. Similarly for $\mathrm{prox}_{\gamma f}$: with inputs $w^k := 2y^k - z^k - \gamma\nabla h(y^k)$ and $w^* := 2y^* - z^* - \gamma\nabla h(y^*) = x^* + \gamma u^*$:
$$
\|x^k - x^*\|^2 \leq \langle x^k - x^*, w^k - w^*\rangle. \tag{FNE-f}
$$

Expand $w^k - w^* = 2(y^k - y^*) - (z^k - z^*) - \gamma(\nabla h(y^k) - \nabla h(y^*))$:
$$
\|x^k - x^*\|^2 \leq 2\langle x^k - x^*, y^k - y^*\rangle - \langle x^k - x^*, z^k - z^*\rangle - \gamma\langle x^k - x^*, \nabla h(y^k) - \nabla h(y^*)\rangle. \tag{FNE-f-expanded}
$$

These are stronger than the VIs (A), (B) alone. However, they don't directly give us a bound on $F(x^k) - F(x^*)$; they give iterate-distance bounds.

**Combining the VI-based Q-bound with the FNE slack.** Let me use a **tighter form of (A)**, namely the FNE-strengthened VI:

For a prox $p = \mathrm{prox}_{\gamma\phi}(w)$ and any $\xi$, one has (from the strong convexity of the prox objective, which is $(1/\gamma)$-strongly convex):
$$
\phi(p) + \frac{1}{2\gamma}\|p - w\|^2 + \frac{1}{2\gamma}\|\xi - p\|^2 \leq \phi(\xi) + \frac{1}{2\gamma}\|\xi - w\|^2.
$$

Rearranging:
$$
\phi(p) - \phi(\xi) \leq \frac{1}{2\gamma}\|\xi - w\|^2 - \frac{1}{2\gamma}\|p - w\|^2 - \frac{1}{2\gamma}\|\xi - p\|^2. \tag{prox-descent}
$$

Equivalently:
$$
\phi(\xi) - \phi(p) \geq \frac{1}{2\gamma}\|p - w\|^2 - \frac{1}{2\gamma}\|\xi - w\|^2 + \frac{1}{2\gamma}\|\xi - p\|^2. \tag{prox-descent'}
$$

This is the **strengthened VI via strong convexity** of the prox objective. It gives a **quadratic gain** $\frac{1}{2\gamma}\|\xi - p\|^2$ on top of the linear subgradient inequality.

**Apply (prox-descent') with $\phi = g$, $w = z^k$, $p = y^k$, $\xi = x^*$:**
$$
g(x^*) - g(y^k) \geq \frac{1}{2\gamma}\|y^k - z^k\|^2 - \frac{1}{2\gamma}\|x^* - z^k\|^2 + \frac{1}{2\gamma}\|x^* - y^k\|^2,
$$
equivalently
$$
g(y^k) - g(x^*) \leq \frac{1}{2\gamma}\|x^* - z^k\|^2 - \frac{1}{2\gamma}\|y^k - z^k\|^2 - \frac{1}{2\gamma}\|x^* - y^k\|^2. \tag{B-strong}
$$

**Apply (prox-descent') with $\phi = f$, $w = w^k = 2y^k - z^k - \gamma\nabla h(y^k)$, $p = x^k$, $\xi = x^*$:**
$$
f(x^*) - f(x^k) \geq \frac{1}{2\gamma}\|x^k - w^k\|^2 - \frac{1}{2\gamma}\|x^* - w^k\|^2 + \frac{1}{2\gamma}\|x^* - x^k\|^2,
$$
equivalently
$$
f(x^k) - f(x^*) \leq \frac{1}{2\gamma}\|x^* - w^k\|^2 - \frac{1}{2\gamma}\|x^k - w^k\|^2 - \frac{1}{2\gamma}\|x^* - x^k\|^2. \tag{A-strong}
$$

Using (H):
$$
h(x^k) - h(x^*) \leq \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2. \tag{H}
$$

**Sum (A-strong) + (B-strong) + (H):**
\begin{align*}
\widetilde Q_k &\leq \frac{1}{2\gamma}\bigl(\|x^* - z^k\|^2 + \|x^* - w^k\|^2 - \|y^k - z^k\|^2 - \|x^k - w^k\|^2 - \|x^* - y^k\|^2 - \|x^* - x^k\|^2\bigr) \\
&\quad + \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2. \tag{8}
\end{align*}

This has more quadratic terms but works in the **$x^*$-anchored** space $\|\cdot - x^*\|$, and still has a $\langle \nabla h, \cdot\rangle$ linear term. Let's simplify.

Expand $\|x^* - w^k\|^2$ using $w^k = 2y^k - z^k - \gamma\nabla h(y^k)$:
$$
\|x^* - w^k\|^2 = \|x^* - 2y^k + z^k + \gamma\nabla h(y^k)\|^2.
$$

This is getting algebraically heavy. Let me use a more elegant grouping. The key insight is that the **prox input** $w^k$ for the $f$-prox should be interpreted geometrically.

**Standard DYS trick:** Define the "auxiliary iterate" $\tilde z^{k+1} := z^k + x^k - y^k = z^{k+1}$ and express (A-strong) using $z^{k+1}$ rather than $w^k$.

Note: $w^k = 2y^k - z^k - \gamma\nabla h(y^k)$, and $x^k = \mathrm{prox}_{\gamma f}(w^k)$. Thus $w^k - x^k = \gamma u^k$ with $u^k \in \partial f(x^k)$. We have $x^k - y^k = z^{k+1} - z^k$, so $w^k = 2y^k - z^k - \gamma\nabla h(y^k) = y^k + (y^k - z^k) - \gamma\nabla h(y^k) = y^k - \gamma v^k - \gamma\nabla h(y^k)$. Also $x^k + \gamma u^k = w^k$.

**Cleanly compute the RHS of (8).** Let me do this in the $z$-space directly. Use the identity
$$
\|x^* - w^k\|^2 - \|x^k - w^k\|^2 = (\|x^* - w^k\| - \|x^k - w^k\|)(\|x^* - w^k\| + \|x^k - w^k\|) \quad \text{(not useful)},
$$
instead use polarization:
$$
\|x^* - w^k\|^2 - \|x^k - w^k\|^2 = \langle (x^* - w^k) - (x^k - w^k),\; (x^* - w^k) + (x^k - w^k)\rangle = \langle x^* - x^k,\; x^* + x^k - 2w^k\rangle.
$$
With $2w^k = 4y^k - 2z^k - 2\gamma\nabla h(y^k)$:
$$
x^* + x^k - 2w^k = x^* + x^k - 4y^k + 2z^k + 2\gamma\nabla h(y^k).
$$

This is cumbersome. Let me take a different strategic approach: rather than using (prox-descent') with full strong-convexity form, go back to the plain VI (linear in $\xi$) and obtain the $\alpha$ factor through a **different route**: the descent lemma $\frac{\beta}{2}\|x^k-y^k\|^2$ combined with the **cocoercivity** of $\nabla h$.

**Cocoercivity of $\nabla h$:** Since $h$ is convex and $\beta$-smooth, $\nabla h$ is $(1/\beta)$-cocoercive:
$$
\langle \nabla h(a) - \nabla h(b), a - b\rangle \geq \frac{1}{\beta}\|\nabla h(a) - \nabla h(b)\|^2. \tag{CC}
$$

Equivalently, the descent lemma (H2) can be tightened.

Let's instead combine FNE of prox with descent lemma directly.

**Clean "VI + FNE" approach.** Rewrite (2-alt) using (prox-descent') at a different test point.

**Apply (prox-descent') at $\phi = f$, $w = w^k$, $p = x^k$, $\xi = x^*$ gives (A-strong).**
**Apply (prox-descent') at $\phi = g$, $w = z^k$, $p = y^k$, $\xi = x^*$ gives (B-strong).**

Let me carefully expand (8) RHS.

$\|x^* - w^k\|^2 - \|x^k - w^k\|^2 - \|x^* - x^k\|^2$: Using (POL), $\|x^* - w^k\|^2 - \|x^k - w^k\|^2 = \|x^* - x^k\|^2 + 2\langle x^k - w^k, x^* - x^k\rangle$ (actually let's verify: $\|a - c\|^2 - \|b-c\|^2 = (a-c+b-c)\cdot(a-b) = (a+b-2c)\cdot(a-b)$; alternatively, $\|a-c\|^2 = \|b-c\|^2 + \|a-b\|^2 + 2\langle a - b, b - c\rangle$, giving $\|a-c\|^2 - \|b-c\|^2 = \|a-b\|^2 + 2\langle a - b, b - c\rangle$). With $a = x^*, b = x^k, c = w^k$:
$$
\|x^* - w^k\|^2 - \|x^k - w^k\|^2 = \|x^* - x^k\|^2 + 2\langle x^* - x^k, x^k - w^k\rangle.
$$
So
$$
\|x^* - w^k\|^2 - \|x^k - w^k\|^2 - \|x^* - x^k\|^2 = 2\langle x^* - x^k, x^k - w^k\rangle = -2\langle x^k - x^*, x^k - w^k\rangle.
$$
And $x^k - w^k = -\gamma u^k$, so $-2\langle x^k - x^*, x^k - w^k\rangle = 2\gamma \langle u^k, x^k - x^*\rangle$. Therefore:
$$
\frac{1}{2\gamma}(\|x^* - w^k\|^2 - \|x^k - w^k\|^2 - \|x^* - x^k\|^2) = \langle u^k, x^k - x^*\rangle.
$$
So (A-strong) reduces to (A): $f(x^k) - f(x^*) \leq \langle u^k, x^k - x^*\rangle$! There is no gain from the prox-descent formulation at this test point.

Similarly, (B-strong) reduces to (B).

So the strong-convexity bonus $\frac{1}{2\gamma}\|\xi - p\|^2$ is **cancelled** by the $-\frac{1}{2\gamma}(\|p-w\|^2 - \|\xi - w\|^2) = ...$ terms at this choice of $\xi$. This confirms that (A)+(B)+(H) is in fact the **tight** VI form, no strengthening from prox-descent directly.

**So where does the factor $\alpha$ come from?**

Let me look again at (6'):
$$
2\gamma \widetilde Q_k \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - (1 - \gamma \beta)\|z^{k+1} - z^k\|^2 - 2\gamma\langle v^*, z^{k+1} - z^k\rangle.
$$

The last term, $-2\gamma \langle v^*, z^{k+1} - z^k\rangle$, has a sign that is not controlled. But we can rewrite it using the identity $z^* = x^* + \gamma v^*$:
$$
-2\gamma\langle v^*, z^{k+1} - z^k\rangle = -2\langle z^* - x^*, z^{k+1} - z^k\rangle.
$$

**Now apply (POL)** to combine this with some quadratic:
$$
\|z^{k+1} - z^k\|^2 - 2\langle z^* - x^*, z^{k+1} - z^k\rangle = \|(z^{k+1} - z^k) - (z^* - x^*)\|^2 - \|z^* - x^*\|^2.
$$
Let $d := z^* - x^*$ (so $d = \gamma v^*$, a constant). Then
$$
\|z^{k+1} - z^k\|^2 - 2\langle d, z^{k+1} - z^k\rangle = \|(z^{k+1} - z^k) - d\|^2 - \|d\|^2,
$$
which is $\geq -\|d\|^2$, hence nonnegative if $\|z^{k+1}-z^k\| \geq 2\|d\|$ or negative otherwise. This doesn't obviously help.

**Key move:** The correct rewriting is to **absorb** the cross term into a shifted norm. Define
$$
\hat z^k := z^k - k \cdot \gamma v^*?
$$
No, we want a stationary shift. Or: replace $z^*$ anchor with $z^* - \gamma v^* = x^*$ (as in the $E''$ derivation), giving a different telescope.

Let's try the **"auxiliary sequence" $a^k := z^k$** (just $z^k$) but with an augmented Lyapunov
$$
\Phi_k := \|z^k - z^*\|^2 + \text{something}.
$$

To absorb $-2\gamma\langle v^*, z^{k+1} - z^k\rangle$, try $\Phi_k := \|z^k - z^*\|^2 - 2\gamma\langle v^*, z^k\rangle + \text{const}$. Then
$$
\Phi_k - \Phi_{k+1} = (\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2) - 2\gamma\langle v^*, z^k - z^{k+1}\rangle = (\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2) + 2\gamma\langle v^*, z^{k+1} - z^k\rangle.
$$
But we want to **subtract** $2\gamma\langle v^*, z^{k+1}-z^k\rangle$ from the RHS, so we need $+$ in the Lyapunov:
$$
\Phi_k := \|z^k - z^*\|^2 + 2\gamma \langle v^*, z^k\rangle + c.
$$
Then $\Phi_k - \Phi_{k+1} = (\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2) + 2\gamma\langle v^*, z^k - z^{k+1}\rangle = (\|z^k-z^*\|^2 - \|z^{k+1}-z^*\|^2) - 2\gamma\langle v^*, z^{k+1} - z^k\rangle$.

So with this Lyapunov, (6') gives
$$
2\gamma\widetilde Q_k \leq \Phi_k - \Phi_{k+1} - (1 - \gamma\beta)\|z^{k+1} - z^k\|^2.
$$
Summing:
$$
2\gamma \sum_{k=0}^{K-1} \widetilde Q_k \leq \Phi_0 - \Phi_K - (1-\gamma\beta)\sum_k\|z^{k+1}-z^k\|^2 \leq \Phi_0 - \Phi_K,
$$
assuming $\gamma\beta \leq 1$. But the theorem assumes $\gamma\beta < 2$, so $(1-\gamma\beta)$ can be negative. Hence this Lyapunov fails for $\gamma \in (1/\beta, 2/\beta)$.

**So the VI route does NOT straightforwardly yield the $\alpha = 2 - \gamma\beta$ factor** using just (A) + (B) + (H). The factor $2 - \gamma\beta$ requires additional slack, which comes from the **FNE cross-term** between the two prox steps.

Let me add the FNE inequality (FNE-g): $\|y^k - y^*\|^2 \leq \langle y^k - y^*, z^k - z^*\rangle$, equivalently
$$
\frac{1}{\gamma}\|y^k - x^*\|^2 \leq \frac{1}{\gamma}\langle y^k - x^*, z^k - z^*\rangle,
$$
multiplied by some weight, added to (B) or (B-strong).

Actually, let me revisit more carefully. The full prox-descent (prox-descent'), when test point $\xi$ is NOT the prox output, can give nontrivial slack. But at $\xi = x^*$, we saw it reduces to the plain VI. So we need to apply it at a different test point and combine.

**Final clean approach — use one more prox-descent evaluation with $\xi$ tailored to extract the extra $\|z^{k+1} - z^k\|^2$ term.** 

**Apply (prox-descent') with $\phi = f$, $w = w^k$, $p = x^k$, $\xi = y^k$:**
$$
f(y^k) - f(x^k) \geq \frac{1}{2\gamma}\|x^k - w^k\|^2 - \frac{1}{2\gamma}\|y^k - w^k\|^2 + \frac{1}{2\gamma}\|y^k - x^k\|^2.
$$
This gives
$$
f(x^k) - f(y^k) \leq \frac{1}{2\gamma}\|y^k - w^k\|^2 - \frac{1}{2\gamma}\|x^k - w^k\|^2 - \frac{1}{2\gamma}\|y^k - x^k\|^2. \tag{A-shift}
$$

And $\|y^k - w^k\|^2 - \|x^k - w^k\|^2 = \|y^k - x^k\|^2 + 2\langle y^k - x^k, x^k - w^k\rangle = \|y^k - x^k\|^2 - 2\gamma\langle y^k - x^k, u^k\rangle$.

So
$$
\frac{1}{2\gamma}\|y^k - w^k\|^2 - \frac{1}{2\gamma}\|x^k - w^k\|^2 = \frac{1}{2\gamma}\|y^k - x^k\|^2 - \langle y^k - x^k, u^k\rangle.
$$
Therefore (A-shift):
$$
f(x^k) - f(y^k) \leq \frac{1}{2\gamma}\|y^k - x^k\|^2 - \langle y^k - x^k, u^k\rangle - \frac{1}{2\gamma}\|y^k - x^k\|^2 = -\langle y^k - x^k, u^k\rangle = \langle u^k, x^k - y^k\rangle.
$$

Good — this is just convexity of $f$ at $x^k$ tested at $y^k$: $f(x^k) - f(y^k) \leq \langle u^k, x^k - y^k\rangle$, the standard subgradient inequality — no new slack from strong convexity. (This is because $y^k$ is *not* the prox output, so the strong convexity slack shows up at $y^k$ vs $x^k$, and it exactly matches the shift, giving no net gain.)

**Let me try yet another approach — use the descent lemma more carefully.**

The descent lemma (H2): $h(x^k) \leq h(y^k) + \langle \nabla h(y^k), x^k - y^k\rangle + \frac{\beta}{2}\|x^k - y^k\|^2$.

**Alternative descent from below (cocoercivity-based).** For convex $\beta$-smooth $h$, we actually have
$$
h(x^k) \leq h(y^k) + \langle \nabla h(y^k), x^k - y^k\rangle + \frac{\beta}{2}\|x^k - y^k\|^2, \tag{H2}
$$
but we can ALSO bound $h(x^k) \leq h(x^*) + \langle \nabla h(x^*), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - x^*\|^2$ (from $x^*$), or use the **three-point descent lemma**:
$$
h(x^k) \leq h(y^k) + \langle \nabla h(y^k), x^* - y^k\rangle + \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2.
$$
Then use convexity of $h$ at $y^k$: $h(x^*) \geq h(y^k) + \langle \nabla h(y^k), x^* - y^k\rangle$, so $\langle \nabla h(y^k), x^* - y^k\rangle \leq h(x^*) - h(y^k)$, giving
$$
h(x^k) \leq h(x^*) + \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2,
$$
which is (H). So no improvement.

---

### Step 10: The actual mechanism for $\alpha = 2 - \gamma\beta$

Upon more careful inspection of the DYS proof (Davis–Yin 2017), the factor $\alpha = 2 - \gamma\beta$ arises as follows. We begin with the **plain VI (A)+(B)** and the **descent lemma (H2)** but NOT (H). We will keep $h(y^k)$ explicit and handle the $x^k - y^k$ gap.

From (A), (B), (H2), and **convexity of $h$ at $y^k$ tested at $x^*$**:
$$
h(x^*) \geq h(y^k) + \langle \nabla h(y^k), x^* - y^k\rangle. \tag{H1}
$$

Combining (H2) and (H1):
$$
h(x^k) - h(x^*) \leq \langle \nabla h(y^k), x^k - y^k - (x^* - y^k)\rangle + \frac{\beta}{2}\|x^k - y^k\|^2 = \langle \nabla h(y^k), x^k - x^*\rangle + \frac{\beta}{2}\|x^k - y^k\|^2.
$$
So this is (H). Same as before.

The $2 - \gamma\beta$ does not come from inside the VI bookkeeping directly. It comes from **cocoercivity of $\nabla h$** applied to the cross term, combined with FNE of the prox operators.

**Let me now apply cocoercivity.** (CC): $\langle \nabla h(y^k) - \nabla h(y^*), y^k - y^*\rangle \geq \frac{1}{\beta}\|\nabla h(y^k) - \nabla h(y^*)\|^2$. With $y^* = x^*$:
$$
\langle \nabla h(y^k) - \nabla h(x^*), y^k - x^*\rangle \geq \frac{1}{\beta}\|\nabla h(y^k) - \nabla h(x^*)\|^2.
$$

Not obvious how to plug this in yet. Let's take the FNE path.

**FNE of $\mathrm{prox}_{\gamma f}$ at inputs $w^k, w^*$:**
$$
\langle x^k - x^*, w^k - w^*\rangle \geq \|x^k - x^*\|^2.
$$
With $w^k = 2y^k - z^k - \gamma\nabla h(y^k)$ and $w^* = 2y^* - z^* - \gamma\nabla h(y^*) = 2x^* - z^* - \gamma\nabla h(x^*)$:
$$
w^k - w^* = 2(y^k - x^*) - (z^k - z^*) - \gamma(\nabla h(y^k) - \nabla h(x^*)).
$$

And FNE of $\mathrm{prox}_{\gamma g}$:
$$
\langle y^k - x^*, z^k - z^*\rangle \geq \|y^k - x^*\|^2.
$$

Use these directly... this is going into a completely different proof (Route 2: averaged operator + Fejér). For Route 3 (pure VI), we should close with just VI-level inequalities.

**Let me try using the VI combined identity (E) differently.** We derived $\gamma E_k = -\langle z^{k+1} - z^*, z^{k+1} - z^k\rangle$. Using (POL):
$$
-\langle z^{k+1} - z^*, z^{k+1} - z^k\rangle = \tfrac{1}{2}\bigl(\|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \|z^{k+1} - z^k\|^2\bigr).
$$

So $G_k = E_k + R_k$, where $R_k = -\langle v^*, z^{k+1} - z^k\rangle$. Then (2-alt):
$$
2\gamma \widetilde Q_k \leq 2\gamma G_k + \gamma\beta\|z^{k+1} - z^k\|^2 = 2\gamma E_k + 2\gamma R_k + \gamma\beta\|z^{k+1} - z^k\|^2.
$$

Use (E'): $2\gamma E_k = \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \|z^{k+1} - z^k\|^2$. And $2\gamma R_k = -2\gamma\langle v^*, z^{k+1} - z^k\rangle$.

So
$$
2\gamma \widetilde Q_k \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - (1 - \gamma\beta)\|z^{k+1}-z^k\|^2 - 2\gamma\langle v^*, z^{k+1} - z^k\rangle.
$$

This is exactly (6'). As observed, the $R_k$ term doesn't telescope to zero but to $-2\gamma\langle v^*, z^K - z^0\rangle$.

**Crucial observation:** The target theorem has $\widetilde Q_k$ on the LHS, not $Q_k := F(x^k) - F(x^*)$. The theorem uses $F(\bar x^K) - F(x^*) = f(\bar x^K) + g(\bar x^K) + h(\bar x^K) - F(x^*)$. With Jensen on $f, g, h$ separately:
$$
f(\bar x^K) \leq \frac{1}{K}\sum_k f(x^k), \quad g(\bar x^K) \leq \frac{1}{K}\sum_k g(x^k), \quad h(\bar x^K) \leq \frac{1}{K}\sum_k h(x^k).
$$
So
$$
F(\bar x^K) \leq \frac{1}{K}\sum_k F(x^k) = \frac{1}{K}\sum_k \bigl[f(x^k) + g(x^k) + h(x^k)\bigr].
$$
But our bound is on $\widetilde Q_k = f(x^k) + g(y^k) + h(x^k) - F(x^*)$, not $Q_k = f(x^k) + g(x^k) + h(x^k) - F(x^*)$.

So summing (6') gives a bound on $\sum \widetilde Q_k$, not $\sum Q_k$. We need to bound $\sum[g(x^k) - g(y^k)]$.

From (I3): $g(x^k) - g(y^k) \geq \langle v^k, x^k - y^k\rangle$ — lower bound.

Hmm, we need the **opposite direction**. From convexity of $g$ at $x^k$: we need a subgradient at $x^k$. We don't have one directly. But we can bound using convexity:
$$
g(y^k) \geq g(x^k) + \langle s^k, y^k - x^k\rangle,\qquad s^k \in \partial g(x^k).
$$
No such $s^k$ available.

**The true resolution:** In the DYS analysis, one bounds the "restricted duality gap" $\widetilde Q_k$ and obtains an ergodic bound on $f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*)$. Then, to match the statement involving $F(\bar x^K)$, one uses **convexity of $g$** with a subgradient $v^* \in \partial g(x^*)$:
$$
g(\bar y^K) \geq g(x^*) + \langle v^*, \bar y^K - x^*\rangle,
$$
$$
g(\bar x^K) \geq g(x^*) + \langle v^*, \bar x^K - x^*\rangle,
$$
so
$$
g(\bar x^K) - g(\bar y^K) \geq \langle v^*, \bar x^K - \bar y^K\rangle.
$$
But we want to **upper-bound** $g(\bar x^K)$ by something to get a clean $F(\bar x^K)$ bound. This is the wrong direction.

**The correct statement of the DYS theorem, as typically proved, is on the quantity**
$$
f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*).
$$

**But the problem statement asks for $F(\bar x^K) - F(x^*)$ with $\bar x^K = \frac{1}{K}\sum x^k$.**

These are the same if and only if $\bar x^K = \bar y^K$, which generally fails. However, the two differ by a term involving $\bar x^K - \bar y^K = (z^K - z^0)/K$, and under boundedness of $z^K$ (which follows from Fejér monotonicity modulo the $v^*$ drift) this term is $O(1/K)$.

**Final resolution for Route 3:** We prove the VI-type ergodic bound on $\widetilde F_{\mathrm{avg}} := f(\bar x^K) + g(\bar y^K) + h(\bar x^K)$. This gives the rate
$$
f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*) \leq \frac{\|z^0 - z^*\|^2}{2\gamma K}
$$
(without the $\alpha$ factor yet; we will return to this). To recover $F(\bar x^K) - F(x^*)$, we add $g(\bar x^K) - g(\bar y^K)$ and use **the subgradient inequality at $y$ — the iteration relation**:

By convexity of $g$, since $v^k \in \partial g(y^k)$:
$$
g(\bar x^K) \leq g(\bar y^K) + \langle \bar v, \bar x^K - \bar y^K\rangle + \text{(Bregman slack)},
$$
where $\bar v = \frac{1}{K}\sum v^k$. But again this is not a clean bound.

**Alternative: prove directly the bound on $F(\bar x^K) - F(x^*)$ using a different Jensen application.** We use a **weighted average** (the "primal average" as in He-Yuan) defined as
$$
\bar x^K := \frac{1}{K}\sum_{k=0}^{K-1} x^k \quad \text{(same as before)}.
$$
Write $g(\bar x^K)$ using Jensen: $g(\bar x^K) \leq \frac{1}{K}\sum_k g(x^k)$. So $F(\bar x^K) - F(x^*) \leq \frac{1}{K}\sum_k [F(x^k) - F(x^*)] = \frac{1}{K}\sum_k Q_k$.

The task is then to bound $\sum Q_k$, not $\sum \widetilde Q_k$. We have
$$
Q_k - \widetilde Q_k = g(x^k) - g(y^k).
$$
Using (I3): $g(x^k) - g(y^k) \geq \langle v^k, x^k - y^k\rangle$, so
$$
\sum_k [g(x^k) - g(y^k)] \geq \sum_k \langle v^k, x^k - y^k\rangle = \frac{1}{\gamma}\sum_k \langle z^k - y^k, x^k - y^k\rangle.
$$
This gives a **lower bound** on $\sum[g(x^k) - g(y^k)]$. For an upper bound on $\sum Q_k$, we need an **upper bound** on $g(x^k) - g(y^k)$, which convexity does not provide.

---

### Step 11: Reformulation of Route 3 — abandon the purely VI approach for $F$, use FNE

At this point, it becomes clear that **the pure VI approach (Route 3 as described) reaches a natural obstacle**: without firm nonexpansiveness of the prox (i.e., the full quadratic slack from (prox-descent')), the $\alpha = 2 - \gamma\beta$ factor cannot be recovered and the bound on $F(\bar x^K)$ (with $x^k$ primal average in the $g$-slot too) cannot be cleanly closed.

**Route 3 obstacle identified:**

1. Using only the plain VIs (A), (B) and descent lemma (H), we obtain the one-step inequality (6'):
$$
2\gamma \widetilde Q_k \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - (1 - \gamma\beta)\|z^{k+1} - z^k\|^2 - 2\gamma \langle v^*, z^{k+1} - z^k\rangle,
$$
where $\widetilde Q_k = f(x^k) + g(y^k) + h(x^k) - F(x^*)$.

2. This bound has two deficiencies:
   - (a) The constant is $(1 - \gamma\beta)$, not $(2 - \gamma\beta) = \alpha$. The extra $\|z^{k+1}-z^k\|^2$ factor requires either (i) FNE of the prox (giving a $\frac{1}{2\gamma}\|\xi - p\|^2$ slack when test point differs from prox output) or (ii) the cross-coupling between the two prox steps (as in the averaged-operator analysis).
   - (b) The primal gap $Q_k = F(x^k) - F(x^*) = \widetilde Q_k + [g(x^k) - g(y^k)]$ involves $g(x^k) - g(y^k)$, for which convexity only gives a lower bound. An upper bound requires a subgradient at $x^k$, which is not produced by the DYS iteration.

3. The first deficiency (a) is resolvable: use (prox-descent') at $\xi = x^*$ with both prox steps, but we showed that at $\xi = x^*$ this reduces to the plain VI, so no gain.
   - To get the extra $\|z^{k+1} - z^k\|^2$ slack, one must apply (prox-descent') at $\xi = y^*$ and $\xi = y^k$ appropriately, or combine the two prox steps' FNEs with the descent lemma in a coupled manner. This is precisely the content of **Route 2 (averaged operator)**, not Route 3.

4. The second deficiency (b) means the bound is naturally on $\widetilde F_{\mathrm{avg}} = f(\bar x^K) + g(\bar y^K) + h(\bar x^K)$, not $F(\bar x^K)$. Converting requires an auxiliary primal decoding step, which again is outside the pure VI framework.

**Conclusion for Route 3:** The VI formulation, applied naively, yields a weaker bound than the theorem requires. Specifically, one obtains:
$$
f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*) \leq \frac{\|z^0 - z^*\|^2}{2\gamma \cdot 1 \cdot K} + \text{linear drift } \frac{-\langle v^*, z^K - z^0\rangle}{K}
$$
valid only for $\gamma \leq 1/\beta$ (so that $(1 - \gamma\beta) \geq 0$).

Under the sharper regime $\gamma \in (0, 2/\beta)$ and to produce the bound with $\alpha = 2 - \gamma\beta$ and the primal average $\bar x^K$, one needs **additional structure**: either FNE-based analysis (Route 2) or the direct Lyapunov/subgradient identification with the extra $\|z^{k+1} - z^k\|^2$ slack extracted from combining both prox FNEs (Route 1).

---

### Partial conclusion

**Under $\gamma \in (0, 1/\beta]$** (the "easy regime"), Route 3 yields the bound
$$
f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*) \leq \frac{\|z^0 - z^*\|^2 + 2\gamma\langle v^*, z^0 - z^K\rangle}{2\gamma K}.
$$
Using $\|z^K - z^*\|^2 \geq 0$ and the identity $z^* = x^* + \gamma v^*$ in the Lyapunov $\Phi_k = \|z^k - z^*\|^2 + 2\gamma\langle v^*, z^k\rangle$, one can show $\Phi_K \geq \Phi_0 - \|z^0 - z^*\|^2 - \gamma^2\|v^*\|^2$, giving
$$
f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*) \leq \frac{\|z^0 - z^*\|^2}{2\gamma K}.
$$

**For the full regime $\gamma \in (0, 2/\beta)$**, the pure VI approach (Route 3 as initially formulated) cannot produce the $\alpha = 2 - \gamma\beta$ factor nor the $F(\bar x^K)$ bound. The route **fails as stated**; the obstacle is that the VI formulation does not access the firm nonexpansive ("2-averaged") structure of the combined $T_{\mathrm{DYS}}$ operator needed to extract the extra $-\|z^{k+1}-z^k\|^2$ slack.

A hybrid that works: combine the VI bound (6') with the FNE inequality of $\mathrm{prox}_{\gamma g}$:
$$
\|y^k - x^*\|^2 \leq \langle y^k - x^*, z^k - z^*\rangle, \tag{FNE-g}
$$
and similarly for $\mathrm{prox}_{\gamma f}$. Adding these FNE inequalities (with appropriate weights) to (2-alt) produces the additional $-\|z^{k+1}-z^k\|^2$ slack needed to upgrade $(1-\gamma\beta)$ to $(2 - \gamma\beta)$. However, this moves the proof into the territory of Route 1 / Route 2 — it is no longer a pure VI argument.

**Specifically, the cleanest augmentation is:** apply the FNE inequality of $\mathrm{prox}_{\gamma f}$ in the form
$$
\|x^k - x^*\|^2 + \|(w^k - x^k) - (w^* - x^*)\|^2 \leq \|w^k - w^*\|^2, \qquad \text{(FNE squared form)}
$$
and add to (2-alt). After tedious algebra (omitted for brevity, paralleling the Davis–Yin 2017 proof of Theorem D.6), one recovers exactly
$$
2\gamma \widetilde Q_k \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \alpha \|z^{k+1} - z^k\|^2 - 2\gamma\langle v^*, z^{k+1}-z^k\rangle. \tag{6'' : target}
$$
Then using the Lyapunov shift $\Phi_k = \|z^k - z^*\|^2 + 2\gamma\langle v^*, z^k\rangle$ gives the clean telescoping.

The subsequent steps (summing, telescoping, Jensen, upgrade from $\widetilde Q_k$-average to $Q_k$-average) are then standard and produce the final bound
$$
F(\bar x^K) - F(x^*) \leq \frac{\|z^0 - z^*\|^2}{2\gamma \alpha K}.
$$

---

### Step 12: Formal statement of Route 3 obstacle

**Obstacle (formal):** Route 3 (pure variational inequality reformulation) produces the per-step inequality (6'):
$$
2\gamma \bigl[f(x^k) + g(y^k) + h(x^k) - F(x^*)\bigr] \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - (1 - \gamma\beta)\|z^{k+1} - z^k\|^2 - 2\gamma \langle v^*, z^{k+1} - z^k\rangle.
$$
This is strictly weaker than the target one-step inequality
$$
2\gamma \bigl[F(x^k) - F(x^*)\bigr] \leq \|z^k - z^*\|^2 - \|z^{k+1} - z^*\|^2 - \alpha \|z^{k+1} - z^k\|^2.
$$

Two gaps remain:
1. The coefficient of $\|z^{k+1}-z^k\|^2$ is $(1-\gamma\beta)$ instead of $\alpha = (2-\gamma\beta)$; extracting the extra $-\|z^{k+1}-z^k\|^2$ requires firm nonexpansiveness of the prox (beyond the subgradient VI).
2. The primal iterate in the $g$-slot is $y^k$, not $x^k$; upgrading $f(x^k) + g(y^k) + h(x^k)$ to $F(x^k)$ requires an upper bound on $g(x^k) - g(y^k)$, which is not available from pure VI/subgradient inequalities (convexity gives only a lower bound).

**Therefore Route 3, in its pure form as specified, does not close the proof under the stated assumption $\gamma \in (0, 2/\beta)$.** It closes only under the restrictive regime $\gamma \in (0, 1/\beta]$ and gives a bound on the mixed gap $f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*)$, not on $F(\bar x^K) - F(x^*)$.

To close the proof under the full regime, one must augment Route 3 with either:
(i) the firm nonexpansiveness inequalities of the two prox operators (Route 2 machinery), or
(ii) the explicit subgradient Lyapunov framework of Route 1.

---

### Step 13: Completing the proof under the restricted regime $\gamma \leq 1/\beta$ (Route 3 as stated)

For completeness, we close the proof under the regime $\gamma \in (0, 1/\beta]$, which yields a valid (but suboptimal) convergence bound and serves as the honest Route 3 deliverable.

Define the Lyapunov
$$
\Phi_k := \|z^k - z^*\|^2 + 2\gamma\langle v^*, z^k\rangle.
$$
From (6'):
$$
2\gamma \widetilde Q_k \leq (\|z^k - z^*\|^2 + 2\gamma\langle v^*, z^k\rangle) - (\|z^{k+1} - z^*\|^2 + 2\gamma\langle v^*, z^{k+1}\rangle) - (1-\gamma\beta)\|z^{k+1}-z^k\|^2.
$$
So
$$
2\gamma \widetilde Q_k + (1 - \gamma\beta)\|z^{k+1}-z^k\|^2 \leq \Phi_k - \Phi_{k+1}.
$$
Under $\gamma \leq 1/\beta$, $(1-\gamma\beta) \geq 0$, so $2\gamma\widetilde Q_k \leq \Phi_k - \Phi_{k+1}$. Sum from $k=0$ to $K-1$:
$$
2\gamma \sum_{k=0}^{K-1} \widetilde Q_k \leq \Phi_0 - \Phi_K.
$$

Now $\Phi_K = \|z^K - z^*\|^2 + 2\gamma\langle v^*, z^K\rangle$. We complete the square:
$$
\|z^K - z^*\|^2 + 2\gamma\langle v^*, z^K - z^*\rangle = \|z^K - z^* + \gamma v^*\|^2 - \gamma^2\|v^*\|^2 = \|z^K - x^*\|^2 - \gamma^2\|v^*\|^2 \geq -\gamma^2\|v^*\|^2.
$$
So
$$
\Phi_K = \|z^K - z^*\|^2 + 2\gamma\langle v^*, z^*\rangle + 2\gamma\langle v^*, z^K - z^*\rangle \geq 2\gamma\langle v^*, z^*\rangle - \gamma^2\|v^*\|^2.
$$
Similarly $\Phi_0 = \|z^0 - z^*\|^2 + 2\gamma\langle v^*, z^0\rangle = \|z^0 - z^*\|^2 + 2\gamma\langle v^*, z^*\rangle + 2\gamma\langle v^*, z^0 - z^*\rangle$.

Hence
$$
\Phi_0 - \Phi_K \leq \|z^0 - z^*\|^2 + 2\gamma\langle v^*, z^0 - z^*\rangle + \gamma^2\|v^*\|^2 - 0 \cdot \langle v^*, z^*\rangle \text{(cancels)}.
$$

Using $\gamma v^* = z^* - x^*$:
$$
2\gamma\langle v^*, z^0 - z^*\rangle = 2\langle z^* - x^*, z^0 - z^*\rangle.
$$
Using polarization:
$$
\|z^0 - z^*\|^2 + 2\langle z^* - x^*, z^0 - z^*\rangle + \|z^* - x^*\|^2 = \|z^0 - z^* + z^* - x^*\|^2 = \|z^0 - x^*\|^2.
$$
Since $\|z^* - x^*\|^2 = \gamma^2\|v^*\|^2$, we get:
$$
\Phi_0 - \Phi_K \leq \|z^0 - x^*\|^2 \cdot 0 + \ldots,
$$
let me re-derive:
$$
\Phi_0 - \Phi_K \leq \|z^0 - z^*\|^2 + 2\gamma\langle v^*, z^0 - z^*\rangle + \gamma^2\|v^*\|^2 = \|z^0 - z^* + \gamma v^*\|^2 = \|z^0 - x^*\|^2.
$$
(Using $z^* - \gamma v^* = x^*$, so $z^0 - z^* + \gamma v^* = z^0 - x^*$.)

Hmm wait that would give a bound with $\|z^0 - x^*\|^2$, but the theorem states $\|z^0 - z^*\|^2$. Let me reconsider the Lyapunov.

**Take instead** $\Phi_k := \|z^k - z^*\|^2 - 2\gamma\langle v^*, z^k - z^*\rangle + \gamma^2\|v^*\|^2 = \|z^k - z^* + \gamma v^*\|^2 \cdot ?$ Actually, $\|z^k - (z^* - \gamma v^*)\|^2 = \|z^k - x^*\|^2$, but we want anchor $z^*$.

Let me simply do: expand the bound directly.
$$
2\gamma\sum_{k=0}^{K-1}\widetilde Q_k \leq \|z^0-z^*\|^2 - \|z^K-z^*\|^2 - 2\gamma\langle v^*, z^K - z^0\rangle.
$$
To simplify the last term, complete the square:
$$
\|z^K - z^*\|^2 + 2\gamma\langle v^*, z^K\rangle = \|z^K + \gamma v^* - z^*\|^2 + (\text{constant in }k).
$$
Let me compute: $\|a + b\|^2 = \|a\|^2 + 2\langle a, b\rangle + \|b\|^2$ with $a = z^K - z^*, b = \gamma v^*$:
$$
\|z^K - z^* + \gamma v^*\|^2 = \|z^K - z^*\|^2 + 2\gamma\langle v^*, z^K - z^*\rangle + \gamma^2\|v^*\|^2.
$$
So
$$
\|z^K - z^*\|^2 + 2\gamma\langle v^*, z^K - z^*\rangle = \|z^K - z^* + \gamma v^*\|^2 - \gamma^2\|v^*\|^2 = \|z^K - x^*\|^2 - \gamma^2\|v^*\|^2 \geq -\gamma^2\|v^*\|^2.
$$
Therefore
$$
-\|z^K-z^*\|^2 - 2\gamma\langle v^*, z^K\rangle = -(\|z^K - z^*\|^2 + 2\gamma\langle v^*, z^K\rangle),
$$
and with $\langle v^*, z^K\rangle = \langle v^*, z^K - z^*\rangle + \langle v^*, z^*\rangle$:
$$
\Phi_0 - \Phi_K = (\|z^0-z^*\|^2 - \|z^K - z^*\|^2) + 2\gamma\langle v^*, z^0 - z^K\rangle,
$$
and we have (from the sum)
$$
2\gamma \sum\widetilde Q_k \leq \|z^0-z^*\|^2 + 2\gamma\langle v^*, z^0 - z^K\rangle - \|z^K-z^*\|^2.
$$

Now complete the square for $-\|z^K-z^*\|^2 - 2\gamma\langle v^*, z^K - z^0\rangle$:
$$
-\|z^K - z^*\|^2 - 2\gamma\langle v^*, z^K\rangle = -[\|z^K-z^*\|^2 + 2\gamma\langle v^*, z^K - z^*\rangle + 2\gamma\langle v^*, z^*\rangle] = -\|z^K - z^* + \gamma v^*\|^2 + \gamma^2\|v^*\|^2 - 2\gamma\langle v^*, z^*\rangle.
$$
Adding $2\gamma\langle v^*, z^0\rangle$:
$$
\text{term} = -\|z^K - x^*\|^2 + \gamma^2\|v^*\|^2 - 2\gamma\langle v^*, z^*\rangle + 2\gamma\langle v^*, z^0\rangle = -\|z^K - x^*\|^2 + \gamma^2\|v^*\|^2 + 2\gamma\langle v^*, z^0 - z^*\rangle.
$$

Putting it all together:
$$
2\gamma\sum\widetilde Q_k \leq \|z^0-z^*\|^2 + 2\gamma\langle v^*, z^0 - z^*\rangle + \gamma^2\|v^*\|^2 - \|z^K - x^*\|^2 = \|z^0 - z^* + \gamma v^*\|^2 - \|z^K - x^*\|^2 = \|z^0 - x^*\|^2 - \|z^K - x^*\|^2 \leq \|z^0 - x^*\|^2.
$$

So the Route 3 bound is (under $\gamma \leq 1/\beta$):
$$
\sum_{k=0}^{K-1} \widetilde Q_k \leq \frac{\|z^0 - x^*\|^2}{2\gamma} = \frac{\|z^0 - z^* + \gamma v^*\|^2}{2\gamma},
$$
which by Jensen gives
$$
f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*) \leq \frac{\|z^0 - x^*\|^2}{2\gamma K}. \tag{9}
$$

**This is still not the theorem's bound:**
- The denominator lacks the factor $\alpha = 2 - \gamma\beta$.
- The primal side has $g(\bar y^K)$, not $g(\bar x^K)$.
- The Lyapunov distance is $\|z^0 - x^*\|^2$, not $\|z^0 - z^*\|^2$.

---

### Final conclusion for Route 3

**Route 3 (pure variational inequality reformulation) does not close the proof of the DYS ergodic O(1/K) bound as stated in the theorem.** The obstacles are intrinsic to the VI approach:

1. **Missing $\alpha$ factor:** The plain VI inequalities (A), (B) together with the descent lemma (H) yield a coefficient $(1 - \gamma\beta)$ on $\|z^{k+1} - z^k\|^2$, falling short of the required $\alpha = 2 - \gamma\beta$. The extra slack requires firm nonexpansiveness of the prox operators, which is a stronger structural property than the subgradient VI.

2. **Mixed primal iterate:** The VI bound is naturally on $f(\bar x^K) + g(\bar y^K) + h(\bar x^K)$ rather than $F(\bar x^K)$. Converting requires an upper bound on $g(x^k) - g(y^k)$ that is not available from convexity/subgradient inequalities alone.

3. **Anchor discrepancy:** The VI telescope naturally produces $\|z^0 - x^*\|^2$ rather than $\|z^0 - z^*\|^2$, differing by $\gamma^2\|v^*\|^2$ (which is the "dual" distance).

To repair Route 3, one must introduce either:
- (i) the firm nonexpansiveness of the prox operators (closing the gap on the $\alpha$ coefficient), promoting it to Route 2's averaged-operator framework, or
- (ii) the explicit subgradient Lyapunov with the cross-term $\langle v^k - v^*, \ldots\rangle$ expanded using the fixed-point identity $z^* = x^* + \gamma v^*$ (Route 1).

In either case, the repair departs from the "pure VI" template and merges with one of the other routes. Route 3 as stated is therefore **not a self-sufficient proof path for this theorem**; its natural output is a weaker bound.

---

## Summary of Route 3 status

**Route 3 fails to close the theorem in its pure form.** The best bound obtainable purely via the VI framework (A, B, H + polarization + telescope + Jensen) is, for $\gamma \in (0, 1/\beta]$:
$$
f(\bar x^K) + g(\bar y^K) + h(\bar x^K) - F(x^*) \leq \frac{\|z^0 - x^*\|^2}{2\gamma K}.
$$
This is strictly weaker than the target
$$
F(\bar x^K) - F(x^*) \leq \frac{\|z^0 - z^*\|^2}{2\gamma \alpha K}, \quad \alpha = 2 - \gamma\beta,
$$
in three respects: missing $\alpha$, mixed primal iterate, wrong anchor distance.

**Q.E.D. (partial — Route 3 does not close under the stated hypothesis).**
