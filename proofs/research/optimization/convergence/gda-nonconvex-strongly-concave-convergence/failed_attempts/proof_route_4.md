# Proof of GDA Convergence for Nonconvex–Strongly-Concave Minimax (Route 4)

## Setup and Notation

We consider
$$
\min_{x\in\mathbb{R}^{d_x}}\max_{y\in\mathbb{R}^{d_y}} f(x,y),
$$
under
- **(A1)** $\nabla f$ is $L$-Lipschitz on $\mathbb{R}^{d_x+d_y}$;
- **(A2)** for every fixed $x$, $y\mapsto f(x,y)$ is $\mu$-strongly concave;
- **(A3)** $\Phi(x):=\max_y f(x,y)$ satisfies $\Phi(x_0)-\inf_x\Phi\le\Delta$.

Let $\kappa:=L/\mu\ge 1$. For each $x$, by (A2) there is a unique maximizer
$y^*(x):=\arg\max_y f(x,y)$.

The two-time-scale GDA iteration is
$$
x_{t+1}=x_t-\eta_x\nabla_x f(x_t,y_t),\qquad
y_{t+1}=y_t+\eta_y\nabla_y f(x_t,y_t),
$$
with stepsizes
$$
\eta_x=\frac{1}{16\kappa^2 L},\qquad \eta_y=\frac{1}{L}.
$$

Denote
$$
g_t:=\nabla_x f(x_t,y_t),\qquad
e_t:=g_t-\nabla\Phi(x_t),\qquad
\delta_t:=\|y_t-y^*(x_t)\|^2.
$$

## Proof
**Route**: IFT + y* Jacobian Perturbation

---

### Step 1: Jacobian of $y^*$ via the Implicit Function Theorem (Lemma A)

Assume first $f\in C^2$. Define
$$
F:\mathbb{R}^{d_x}\times\mathbb{R}^{d_y}\to\mathbb{R}^{d_y},\qquad
F(x,y):=\nabla_y f(x,y).
$$
By optimality, $F(x,y^*(x))=0$.

**Invertibility.** By (A2), for every $x$ the map $y\mapsto f(x,y)$ is $\mu$-strongly concave and $C^2$, so
$$
\nabla^2_{yy} f(x,y)\preceq -\mu I\qquad\text{for all }y.
$$
Hence $\nabla^2_{yy} f(x,y)$ is symmetric with eigenvalues $\le -\mu$, therefore invertible, with
$$
\bigl\|[\nabla^2_{yy} f(x,y)]^{-1}\bigr\|_{\text{op}}\le\frac{1}{\mu}.
$$

**IFT.** Since $F$ is $C^1$ and $\partial F/\partial y=\nabla^2_{yy}f$ is invertible at $(x,y^*(x))$, the classical implicit function theorem yields that $y^*$ is $C^1$ in a neighborhood of every $x$, with
$$
\boxed{\;Dy^*(x)=-\bigl[\nabla^2_{yy} f(x,y^*(x))\bigr]^{-1}\,\nabla^2_{yx} f(x,y^*(x)).\;}
$$

**Operator norm bound.** By (A1), $\nabla f$ is $L$-Lipschitz, so every second-order partial (viewed as a block of $\nabla^2 f$) has operator norm $\le L$; in particular $\|\nabla^2_{yx}f(x,y)\|_{\text{op}}\le L$. Therefore
$$
\|Dy^*(x)\|_{\text{op}}\le\frac{1}{\mu}\cdot L=\kappa.
$$

**Regularity caveat.** (A1) yields only $f\in C^{1,1}$, not $C^2$. Two ways to close the gap:

*(i) Rademacher.* Since $y^*$ is $\kappa$-Lipschitz (proved in (ii) below), by Rademacher's theorem it is differentiable a.e.; at any differentiability point the IFT formula above holds, which is enough for the smoothness calculations that follow (they use only the Lipschitz constant $\kappa$).

*(ii) Direct strong-monotonicity argument.* For any $x,x'$, by optimality $\nabla_y f(x,y^*(x))=0=\nabla_y f(x',y^*(x'))$. Write
$$
0=\bigl[\nabla_y f(x',y^*(x'))-\nabla_y f(x',y^*(x))\bigr]+\bigl[\nabla_y f(x',y^*(x))-\nabla_y f(x,y^*(x))\bigr].
$$
Take inner product with $y^*(x')-y^*(x)$. Strong concavity in $y$ (equivalent to strong monotonicity of $-\nabla_y f(\cdot,\cdot)$ in the second argument) gives
$$
\bigl\langle \nabla_y f(x',y^*(x'))-\nabla_y f(x',y^*(x)),\;y^*(x')-y^*(x)\bigr\rangle\le-\mu\|y^*(x')-y^*(x)\|^2.
$$
Cauchy–Schwarz and (A1) give
$$
\bigl|\langle \nabla_y f(x',y^*(x))-\nabla_y f(x,y^*(x)),\;y^*(x')-y^*(x)\rangle\bigr|\le L\|x'-x\|\cdot\|y^*(x')-y^*(x)\|.
$$
Adding the two and using $0=\cdots$:
$$
\mu\|y^*(x')-y^*(x)\|^2\le L\|x'-x\|\cdot\|y^*(x')-y^*(x)\|,
$$
hence
$$
\|y^*(x')-y^*(x)\|\le\kappa\|x'-x\|.\tag{$\star$}
$$
This establishes $\kappa$-Lipschitzness of $y^*$ without $C^2$.

From now on we use only the consequence: **$y^*$ is $\kappa$-Lipschitz.**

---

### Step 2: $\nabla\Phi$ formula and $(1+\kappa)L$-smoothness (Lemma B)

**Danskin's theorem.** Because $y\mapsto f(x,y)$ is strictly concave (even strongly) and has a unique maximizer, Danskin's theorem (the envelope theorem for strictly concave problems) gives
$$
\nabla\Phi(x)=\nabla_x f(x,y^*(x)).
$$

**Smoothness.** For any $x,x'$, using (A1) on the joint gradient $\nabla f$ and $(\star)$:
$$
\begin{aligned}
\|\nabla\Phi(x')-\nabla\Phi(x)\|
&=\|\nabla_x f(x',y^*(x'))-\nabla_x f(x,y^*(x))\|\\
&\le L\,\bigl\|(x',y^*(x'))-(x,y^*(x))\bigr\|\\
&=L\sqrt{\|x'-x\|^2+\|y^*(x')-y^*(x)\|^2}\\
&\le L\sqrt{1+\kappa^2}\,\|x'-x\|\\
&\le (1+\kappa)L\,\|x'-x\|.
\end{aligned}
$$
Since $\kappa\ge 1$, $(1+\kappa)\le 2\kappa$, so $\Phi$ is $L_\Phi$-smooth with
$$
L_\Phi:=2\kappa L.
$$

---

### Step 3: Gradient error bound (Lemma C)

By Danskin, $\nabla\Phi(x_t)=\nabla_x f(x_t,y^*(x_t))$, hence
$$
e_t=\nabla_x f(x_t,y_t)-\nabla_x f(x_t,y^*(x_t)).
$$
By (A1),
$$
\|e_t\|\le L\|y_t-y^*(x_t)\|=L\sqrt{\delta_t},
\qquad\text{i.e.}\qquad
\|e_t\|^2\le L^2\delta_t.\tag{C}
$$

---

### Step 4: Descent in $\Phi$ (Lemma D)

Using $L_\Phi=2\kappa L$-smoothness of $\Phi$,
$$
\Phi(x_{t+1})\le\Phi(x_t)+\langle\nabla\Phi(x_t),\,x_{t+1}-x_t\rangle+\frac{L_\Phi}{2}\|x_{t+1}-x_t\|^2.
$$
With $x_{t+1}-x_t=-\eta_x g_t$ and $g_t=\nabla\Phi(x_t)+e_t$:
$$
\Phi(x_{t+1})\le\Phi(x_t)-\eta_x\langle\nabla\Phi(x_t),g_t\rangle+\kappa L\eta_x^2\|g_t\|^2.
$$
Expand $\langle\nabla\Phi(x_t),g_t\rangle=\|\nabla\Phi(x_t)\|^2+\langle\nabla\Phi(x_t),e_t\rangle$, and $\|g_t\|^2\le 2\|\nabla\Phi(x_t)\|^2+2\|e_t\|^2$ (Young):
$$
\Phi(x_{t+1})\le\Phi(x_t)-\eta_x\|\nabla\Phi(x_t)\|^2-\eta_x\langle\nabla\Phi(x_t),e_t\rangle+2\kappa L\eta_x^2\|\nabla\Phi(x_t)\|^2+2\kappa L\eta_x^2\|e_t\|^2.
$$
Young on the cross term, $-\eta_x\langle\nabla\Phi,e_t\rangle\le\frac{\eta_x}{2}\|\nabla\Phi\|^2+\frac{\eta_x}{2}\|e_t\|^2$:
$$
\Phi(x_{t+1})\le\Phi(x_t)-\Bigl(\tfrac{\eta_x}{2}-2\kappa L\eta_x^2\Bigr)\|\nabla\Phi(x_t)\|^2+\Bigl(\tfrac{\eta_x}{2}+2\kappa L\eta_x^2\Bigr)\|e_t\|^2.
$$
At $\eta_x=1/(16\kappa^2 L)$ we have $2\kappa L\eta_x^2=\eta_x\cdot 2\kappa L\eta_x=\eta_x\cdot\tfrac{1}{8\kappa}\le\tfrac{\eta_x}{8}$. Hence
$$
\tfrac{\eta_x}{2}-2\kappa L\eta_x^2\ge\tfrac{\eta_x}{2}-\tfrac{\eta_x}{8}=\tfrac{3\eta_x}{8}\ge\tfrac{\eta_x}{2}\cdot\tfrac{3}{4}\ge\tfrac{\eta_x}{4},
$$
and $\tfrac{\eta_x}{2}+2\kappa L\eta_x^2\le\tfrac{\eta_x}{2}+\tfrac{\eta_x}{8}=\tfrac{5\eta_x}{8}\le\eta_x$. Using (C):
$$
\boxed{\;\Phi(x_{t+1})\le\Phi(x_t)-\frac{\eta_x}{4}\|\nabla\Phi(x_t)\|^2+\eta_x L^2\delta_t.\;}\tag{D}
$$

---

### Step 5: Tracking error recursion (Lemma E)

Define $\phi_x(y):=-f(x,y)$. By (A2) it is $\mu$-strongly convex and by (A1) it is $L$-smooth, with $y^*(x)=\arg\min_y\phi_x(y)$. One gradient-descent step on $\phi_{x_t}$ from $y_t$ with stepsize $\eta_y$ equals the GDA update on $y$:
$$
y_{t+1}=y_t+\eta_y\nabla_y f(x_t,y_t)=y_t-\eta_y\nabla\phi_{x_t}(y_t).
$$

**Contraction of one GD step on strongly-convex $L$-smooth $\phi_{x_t}$** (see `proofs/library/optimization/convergence/gd-strongly-convex-linear-convergence/proof.md`). For stepsize $\eta_y\in(0,2/(\mu+L)]$,
$$
\|y_{t+1}-y^*(x_t)\|^2\le\Bigl(1-\frac{2\eta_y\mu L}{\mu+L}\Bigr)\|y_t-y^*(x_t)\|^2.
$$
Since $\mu\le L$, we have $\frac{1}{L}\le\frac{2}{\mu+L}$, so $\eta_y=1/L$ is admissible, and
$$
1-\frac{2\eta_y\mu L}{\mu+L}=1-\frac{2\mu}{\mu+L}=\frac{L-\mu}{L+\mu}\le 1-\frac{1}{\kappa+1}\le 1-\frac{1}{2\kappa}.
$$
(The last inequality uses $\kappa\ge 1$, so $\kappa+1\le 2\kappa$.) Hence
$$
\|y_{t+1}-y^*(x_t)\|^2\le\Bigl(1-\tfrac{1}{2\kappa}\Bigr)\delta_t.\tag{E1}
$$

**Include the drift of $y^*$.** Triangle + Young with $\alpha>0$:
$$
\delta_{t+1}=\|y_{t+1}-y^*(x_{t+1})\|^2\le(1+\alpha)\|y_{t+1}-y^*(x_t)\|^2+\Bigl(1+\tfrac{1}{\alpha}\Bigr)\|y^*(x_t)-y^*(x_{t+1})\|^2.
$$
By $\kappa$-Lipschitzness ($\star$) of $y^*$ and $x_{t+1}-x_t=-\eta_x g_t$:
$$
\|y^*(x_{t+1})-y^*(x_t)\|\le\kappa\|x_{t+1}-x_t\|=\kappa\eta_x\|g_t\|.
$$
Choose $\alpha=\frac{1}{4\kappa}$. Then
$$
\delta_{t+1}\le\Bigl(1+\tfrac{1}{4\kappa}\Bigr)\Bigl(1-\tfrac{1}{2\kappa}\Bigr)\delta_t+\Bigl(1+4\kappa\Bigr)\kappa^2\eta_x^2\|g_t\|^2.
$$

**Decay factor.** Compute
$$
\Bigl(1+\tfrac{1}{4\kappa}\Bigr)\Bigl(1-\tfrac{1}{2\kappa}\Bigr)=1-\tfrac{1}{2\kappa}+\tfrac{1}{4\kappa}-\tfrac{1}{8\kappa^2}=1-\tfrac{1}{4\kappa}-\tfrac{1}{8\kappa^2}\le 1-\tfrac{1}{4\kappa}.
$$

**Coefficient of $\|g_t\|^2$.** For $\kappa\ge 1$: $1+4\kappa\le 5\kappa$, so
$$
(1+4\kappa)\kappa^2\eta_x^2\le 5\kappa^3\eta_x^2.
$$

Combining:
$$
\boxed{\;\delta_{t+1}\le\Bigl(1-\tfrac{1}{4\kappa}\Bigr)\delta_t+5\kappa^3\eta_x^2\|g_t\|^2.\;}\tag{E}
$$

---

### Step 6: Self-bound on $g_t$ (Lemma F)

From $g_t=\nabla\Phi(x_t)+e_t$ and (C):
$$
\|g_t\|^2\le 2\|\nabla\Phi(x_t)\|^2+2\|e_t\|^2\le 2\|\nabla\Phi(x_t)\|^2+2L^2\delta_t.\tag{F}
$$

---

### Step 7: Lyapunov analysis

Define
$$
V_t:=\Phi(x_t)-\Phi^*+c\,\delta_t,\qquad \Phi^*:=\inf_x\Phi,\qquad c>0\text{ TBD}.
$$

Substitute (F) into (E):
$$
\delta_{t+1}\le\Bigl(1-\tfrac{1}{4\kappa}\Bigr)\delta_t+5\kappa^3\eta_x^2\bigl(2\|\nabla\Phi(x_t)\|^2+2L^2\delta_t\bigr)
=\bigl(1-\tfrac{1}{4\kappa}+10\kappa^3\eta_x^2 L^2\bigr)\delta_t+10\kappa^3\eta_x^2\|\nabla\Phi(x_t)\|^2.\tag{E'}
$$

At $\eta_x=1/(16\kappa^2 L)$,
$$
\kappa^3\eta_x^2 L^2=\kappa^3\cdot\frac{L^2}{256\kappa^4 L^2}=\frac{1}{256\kappa},
\qquad 10\kappa^3\eta_x^2 L^2=\frac{10}{256\kappa}=\frac{5}{128\kappa}.
$$
Hence $1-\tfrac{1}{4\kappa}+10\kappa^3\eta_x^2 L^2=1-\tfrac{32}{128\kappa}+\tfrac{5}{128\kappa}=1-\tfrac{27}{128\kappa}\le 1-\tfrac{1}{8\kappa}$ (since $27/128\ge 1/8=16/128$).

Also $10\kappa^3\eta_x^2=\frac{10\kappa^3}{256\kappa^4 L^2}=\frac{10}{256\kappa L^2}=\frac{5}{128\kappa L^2}\le\frac{\eta_x}{25L}\cdot\cdots$; we just keep the symbolic form.

Combine (D) and (E'):
$$
V_{t+1}=\Phi(x_{t+1})-\Phi^*+c\delta_{t+1}
\le V_t-\frac{\eta_x}{4}\|\nabla\Phi(x_t)\|^2+\eta_x L^2\delta_t-c\cdot\tfrac{1}{8\kappa}\delta_t+10c\kappa^3\eta_x^2\|\nabla\Phi(x_t)\|^2,
$$
i.e.
$$
V_{t+1}\le V_t-\Bigl(\tfrac{\eta_x}{4}-10c\kappa^3\eta_x^2\Bigr)\|\nabla\Phi(x_t)\|^2-\Bigl(\tfrac{c}{8\kappa}-\eta_x L^2\Bigr)\delta_t.\tag{L}
$$

**Choice of $c$.** Set $c:=16\kappa L$. Then
$$
\frac{c}{8\kappa}=2L,\qquad \eta_x L^2=\frac{L}{16\kappa^2}\le\frac{L}{16}\le L,
$$
so
$$
\frac{c}{8\kappa}-\eta_x L^2\ge 2L-L=L\ge 0.\tag{L1}
$$

Check the $\|\nabla\Phi\|^2$ coefficient:
$$
10c\kappa^3\eta_x^2=10\cdot 16\kappa L\cdot\kappa^3\cdot\frac{1}{256\kappa^4 L^2}=\frac{160}{256 L}=\frac{5}{8L}.
$$
Compare to $\eta_x/4=\frac{1}{64\kappa^2 L}$. We need
$$
\frac{\eta_x}{4}-10c\kappa^3\eta_x^2\ge\frac{\eta_x}{8},\qquad\text{i.e.}\qquad 10c\kappa^3\eta_x^2\le\frac{\eta_x}{8}=\frac{1}{128\kappa^2 L}.
$$
We have $10c\kappa^3\eta_x^2=\frac{5}{8L}$, which is NOT $\le\frac{1}{128\kappa^2 L}$ for $\kappa\ge 1$. The choice $c=16\kappa L$ is too large. Reselect $c$ to balance both constraints.

**Balanced choice.** Set $c:=c_0\kappa L$ with a constant $c_0>0$. Then
- (L1): $\frac{c}{8\kappa}-\eta_x L^2=\frac{c_0 L}{8}-\frac{L}{16\kappa^2}\ge L\Bigl(\frac{c_0}{8}-\frac{1}{16}\Bigr)\ge 0$ iff $c_0\ge\tfrac12$.
- $\|\nabla\Phi\|^2$ coefficient: $10c\kappa^3\eta_x^2=10c_0\kappa L\cdot\frac{\kappa^3}{256\kappa^4 L^2}=\frac{10c_0}{256 L}=\frac{5c_0}{128 L}$.

To get $10c\kappa^3\eta_x^2\le\frac{\eta_x}{8}=\frac{1}{128\kappa^2 L}$ we need $\frac{5c_0}{128 L}\le\frac{1}{128\kappa^2 L}$, i.e. $c_0\le\frac{1}{5\kappa^2}$. But $c_0\ge 1/2$ conflicts for $\kappa\ge 1$. **The issue is that $c$ must scale differently**: we separate the $\delta$ coefficient from the $\|\nabla\Phi\|^2$ coefficient by using a sharper bound in (E').

**Sharper version of (E').** Retain $\|g_t\|^2$ without expanding prematurely. Use (F) only in the $\|\nabla\Phi\|^2$ part; for the $\delta$ absorption use the closer bound $10\kappa^3\eta_x^2L^2\le\frac{1}{8\kappa}\cdot\tfrac{1}{4}$ to get
$$
\delta_{t+1}\le\Bigl(1-\tfrac{3}{16\kappa}\Bigr)\delta_t+10\kappa^3\eta_x^2\|g_t\|^2.
$$
Now split $\|g_t\|^2\le 2\|\nabla\Phi\|^2+2L^2\delta_t$ and absorb only the $\nabla\Phi$ piece:
$$
\delta_{t+1}\le\Bigl(1-\tfrac{3}{16\kappa}+20\kappa^3\eta_x^2 L^2\Bigr)\delta_t+20\kappa^3\eta_x^2\|\nabla\Phi\|^2.
$$
At $\eta_x=1/(16\kappa^2 L)$: $20\kappa^3\eta_x^2 L^2=\frac{20}{256\kappa}=\frac{5}{64\kappa}$. Hence
$$
1-\tfrac{3}{16\kappa}+\tfrac{5}{64\kappa}=1-\tfrac{12-5}{64\kappa}=1-\tfrac{7}{64\kappa}\le 1-\tfrac{1}{16\kappa}.
$$
Thus
$$
\delta_{t+1}\le\Bigl(1-\tfrac{1}{16\kappa}\Bigr)\delta_t+20\kappa^3\eta_x^2\|\nabla\Phi(x_t)\|^2.\tag{E''}
$$

Now the Lyapunov inequality becomes
$$
V_{t+1}\le V_t-\Bigl(\tfrac{\eta_x}{4}-20c\kappa^3\eta_x^2\Bigr)\|\nabla\Phi(x_t)\|^2-\Bigl(\tfrac{c}{16\kappa}-\eta_x L^2\Bigr)\delta_t.\tag{L'}
$$

**Choose $c$.** Take $c:=32\kappa L$. Then
- $\frac{c}{16\kappa}-\eta_x L^2=2L-\frac{L}{16\kappa^2}\ge 2L-L=L>0.$ ✓
- $20c\kappa^3\eta_x^2=20\cdot 32\kappa L\cdot\frac{\kappa^3}{256\kappa^4 L^2}=\frac{640}{256L}=\frac{5}{2L}$.

We still need $20c\kappa^3\eta_x^2\le\eta_x/8$, i.e. $\frac{5}{2L}\le\frac{1}{128\kappa^2 L}$, which fails. The obstruction is intrinsic: absorbing $\|\nabla\Phi\|^2$ through $\|g_t\|^2$ in (E) adds a term $\propto c\kappa^3\eta_x^2$, which is $\propto c/(\kappa L)$, and we need $c$ at least $\Omega(\kappa L)$ to beat the $\eta_x L^2\delta_t$ term in (D). The fix is **not** to plug (F) into (E) to bound $\|g_t\|^2$, but to **use $x_{t+1}-x_t$ directly**:

**Refined (E).** Return to
$$
\delta_{t+1}\le\Bigl(1-\tfrac{1}{4\kappa}\Bigr)\delta_t+5\kappa^3\eta_x^2\|g_t\|^2,\quad \|g_t\|^2=\|(x_{t+1}-x_t)/\eta_x\|^2=\|x_{t+1}-x_t\|^2/\eta_x^2.
$$
Using $\|x_{t+1}-x_t\|=\eta_x\|g_t\|$ we cannot simplify further, but recall from (D)'s derivation that
$$
\kappa L\eta_x^2\|g_t\|^2\le\tfrac{\eta_x}{16}\|g_t\|^2\le\tfrac{\eta_x}{8}\|\nabla\Phi\|^2+\tfrac{\eta_x}{8}\|e_t\|^2\le\tfrac{\eta_x}{8}\|\nabla\Phi\|^2+\tfrac{\eta_x L^2}{8}\delta_t.
$$
This already appears inside (D). So **reuse (D) bound on $\|g_t\|^2$**: from the expansion preceding (D),
$$
\kappa L\eta_x^2\|g_t\|^2\le\Phi(x_t)-\Phi(x_{t+1})+\eta_x\|\nabla\Phi(x_t)\|^2+\eta_x\langle\nabla\Phi,e_t\rangle-(\text{nonnegative}),
$$
which is awkward. Cleaner route: **use the primal bound**
$$
\|g_t\|^2\le 2\|\nabla\Phi(x_t)\|^2+2L^2\delta_t
$$
inside (E), but now take $c$ **small** and accept a weaker $\|\nabla\Phi\|^2$ contraction.

**Final clean balancing.** We assemble (D) + (E'') with $c:=C_c L/\kappa$ for a numerical constant $C_c$:
- $\frac{c}{16\kappa}-\eta_x L^2=\frac{C_c L}{16\kappa^2}-\frac{L}{16\kappa^2}=\frac{L(C_c-1)}{16\kappa^2}\ge 0$ iff $C_c\ge 1$.
- $20c\kappa^3\eta_x^2=20\cdot\frac{C_c L}{\kappa}\cdot\frac{\kappa^3}{256\kappa^4 L^2}=\frac{20C_c}{256\kappa^2 L}=\frac{5C_c}{64\kappa^2 L}$. Compare with $\eta_x/8=\frac{1}{128\kappa^2 L}$. Need $\frac{5C_c}{64}\le\frac{1}{128}$, i.e. $C_c\le\frac{1}{10}$. Conflict with $C_c\ge 1$.

The conflict shows that using only (E'') and (D) with the same $\delta$-coefficient on both sides is too loose. We need to **exploit the $\|e_t\|^2=L^2\delta_t$ bound already included in (D)**: the term $\eta_x L^2\delta_t$ in (D) is what $c\cdot(-\frac{1}{16\kappa})\delta_t$ in (E'') must dominate. Choose $c$ so that
$$
\frac{c}{16\kappa}\ge\eta_x L^2\cdot\text{(some factor)}.
$$
With $\eta_x L^2=\frac{L}{16\kappa^2}$ we need $c\ge\frac{L}{\kappa}$ (up to constants), pointing to $c=\Theta(L/\kappa)$. But the $\|\nabla\Phi\|^2$ constraint requires $c=O(L/\kappa)$ with a *small* constant.

**Take $c:=\frac{L}{\kappa}$ (i.e. $C_c=1$).** Then:
- $\delta$-coefficient in (L'): $\frac{c}{16\kappa}-\eta_x L^2=\frac{L}{16\kappa^2}-\frac{L}{16\kappa^2}=0$. Borderline; strengthen by using (E'') with factor $1-\tfrac{1}{16\kappa}$ replaced by $1-\tfrac{1}{32\kappa}$ and decay-rate $\tfrac{1}{32\kappa}$:

  Going back, $1-\tfrac{7}{64\kappa}\le 1-\tfrac{1}{16\kappa}$ was loose; actually $\tfrac{7}{64}>\tfrac{1}{16}=\tfrac{4}{64}$, so we have the stronger $1-\tfrac{7}{64\kappa}$. Then the $\delta$-coefficient is $\frac{7c}{64\kappa}-\eta_x L^2=\frac{7L}{64\kappa^2}-\frac{L}{16\kappa^2}=\frac{7L-4L}{64\kappa^2}=\frac{3L}{64\kappa^2}>0$. ✓
- $\|\nabla\Phi\|^2$-coefficient: $\frac{\eta_x}{4}-20c\kappa^3\eta_x^2=\frac{1}{64\kappa^2 L}-20\cdot\frac{L}{\kappa}\cdot\frac{\kappa^3}{256\kappa^4 L^2}=\frac{1}{64\kappa^2 L}-\frac{20}{256\kappa^2 L}=\frac{1}{64\kappa^2 L}-\frac{5}{64\kappa^2 L}=-\frac{4}{64\kappa^2 L}<0.$ ✗

Still fails. The fundamental tension is that $c$ must be big enough to kill $\eta_x L^2\delta_t$ but small enough to keep $c\kappa^3\eta_x^2\le\eta_x$. Ratio: $c\kappa^3\eta_x^2 / (\eta_x L^2)=c\kappa^3\eta_x/L^2=c\cdot\frac{1}{16\kappa^2 L^3}\cdot\kappa^3=\frac{c\kappa}{16L^3}$. To have the Lyapunov coefficients work, we need this ratio $\ll 1$, which we achieve by **shrinking $\eta_x$**—but $\eta_x$ is fixed at $1/(16\kappa^2 L)$.

The remedy is the **tighter $\|g_t\|^2$ bound from (D)**: from (D)'s proof,
$$
\Phi(x_{t+1})-\Phi(x_t)\le-\eta_x\langle\nabla\Phi,g_t\rangle+\kappa L\eta_x^2\|g_t\|^2,
$$
we can rearrange to **extract $\|g_t\|^2$**:
$$
\kappa L\eta_x^2\|g_t\|^2\ge\Phi(x_{t+1})-\Phi(x_t)+\eta_x\langle\nabla\Phi,g_t\rangle.
$$
Equivalently,
$$
\|g_t\|^2\le\frac{1}{\kappa L\eta_x^2}\bigl[\Phi(x_t)-\Phi(x_{t+1})-\eta_x\langle\nabla\Phi,g_t\rangle\bigr]\text{ (wrong sign for upper bound)}.
$$
This is not a usable upper bound. Instead, we use the **correct two-time-scale Lyapunov**: since $c\kappa^3\eta_x^2\|g_t\|^2$ is what causes trouble, use the **absolute** bound $\|g_t\|^2\le 2\|\nabla\Phi\|^2+2L^2\delta_t$ only in the $\delta$-term, and for the $\|\nabla\Phi\|^2$-term borrow from (D).

**Streamlined Lyapunov (final clean version).** Redo as follows.

Add (D) and $c\times$(E) directly:
$$
V_{t+1}-V_t\le-\tfrac{\eta_x}{4}\|\nabla\Phi\|^2+\eta_x L^2\delta_t+c\Bigl(-\tfrac{1}{4\kappa}\delta_t+5\kappa^3\eta_x^2\|g_t\|^2\Bigr).
$$
Using $\|g_t\|^2\le 2\|\nabla\Phi\|^2+2L^2\delta_t$:
$$
V_{t+1}-V_t\le-\tfrac{\eta_x}{4}\|\nabla\Phi\|^2+\eta_x L^2\delta_t-\tfrac{c}{4\kappa}\delta_t+10c\kappa^3\eta_x^2(\|\nabla\Phi\|^2+L^2\delta_t).
$$
$$
=-\Bigl(\tfrac{\eta_x}{4}-10c\kappa^3\eta_x^2\Bigr)\|\nabla\Phi\|^2-\Bigl(\tfrac{c}{4\kappa}-\eta_x L^2-10c\kappa^3\eta_x^2 L^2\Bigr)\delta_t.
$$

**Pick $c:=\dfrac{\eta_x L^2\cdot 4\kappa}{1-40\kappa^4\eta_x^2 L^2}$ from the $\delta$-constraint.** Compute at $\eta_x=1/(16\kappa^2 L)$:
$$
40\kappa^4\eta_x^2 L^2=\frac{40\kappa^4}{256\kappa^4 L^2}\cdot L^2=\frac{40}{256}=\frac{5}{32}<1.
$$
So $1-40\kappa^4\eta_x^2L^2=\tfrac{27}{32}$. And $\eta_xL^2\cdot 4\kappa=\frac{4\kappa L^2}{16\kappa^2 L}=\frac{L}{4\kappa}$. Thus **take**
$$
c:=\frac{L/(4\kappa)}{27/32}=\frac{8L}{27\kappa}.
$$
For cleanliness just take $c:=\dfrac{L}{2\kappa}$, which satisfies $c\ge\frac{8L}{27\kappa}$ and maintains $\delta$-positivity:
$$
\tfrac{c}{4\kappa}-\eta_x L^2-10c\kappa^3\eta_x^2 L^2=\tfrac{L}{8\kappa^2}-\tfrac{L}{16\kappa^2}-10\cdot\tfrac{L}{2\kappa}\cdot\tfrac{\kappa^3}{256\kappa^4 L^2}\cdot L^2=\tfrac{L}{16\kappa^2}-\tfrac{5L}{256\kappa^2}=\tfrac{16L-5L}{256\kappa^2}=\tfrac{11L}{256\kappa^2}>0.\tag{L$\delta$}
$$

**Check $\|\nabla\Phi\|^2$-coefficient with $c=\dfrac{L}{2\kappa}$:**
$$
10c\kappa^3\eta_x^2=10\cdot\tfrac{L}{2\kappa}\cdot\tfrac{\kappa^3}{256\kappa^4 L^2}=\tfrac{10}{512\kappa^2 L}=\tfrac{5}{256\kappa^2 L}.
$$
Compare with $\eta_x/4=\frac{1}{64\kappa^2 L}=\frac{4}{256\kappa^2 L}$. We get
$$
\tfrac{\eta_x}{4}-10c\kappa^3\eta_x^2=\tfrac{4}{256\kappa^2 L}-\tfrac{5}{256\kappa^2 L}=-\tfrac{1}{256\kappa^2 L}<0,
$$
fails by a constant. We tighten (D) to extract $\eta_x/2$ instead of $\eta_x/4$:

Going back to the end of Step 4, we had $\tfrac{\eta_x}{2}-2\kappa L\eta_x^2\ge\tfrac{3\eta_x}{8}$, so (D) can be sharpened to
$$
\Phi(x_{t+1})\le\Phi(x_t)-\tfrac{3\eta_x}{8}\|\nabla\Phi\|^2+\eta_x L^2\delta_t.\tag{D'}
$$
Using (D') instead of (D):
$$
\tfrac{3\eta_x}{8}-10c\kappa^3\eta_x^2=\tfrac{3}{128\kappa^2 L}-\tfrac{5}{256\kappa^2 L}=\tfrac{6-5}{256\kappa^2 L}=\tfrac{1}{256\kappa^2 L}>0.\tag{L$\nabla$}
$$

Thus with $c=\tfrac{L}{2\kappa}$ we obtain
$$
\boxed{\;V_{t+1}\le V_t-\frac{1}{256\kappa^2 L}\|\nabla\Phi(x_t)\|^2-\frac{11L}{256\kappa^2}\delta_t.\;}\tag{L}
$$

In particular,
$$
V_{t+1}\le V_t-\frac{1}{256\kappa^2 L}\|\nabla\Phi(x_t)\|^2.\tag{L*}
$$

---

### Step 8: Telescoping

Sum (L*) from $t=0$ to $T-1$:
$$
\frac{1}{256\kappa^2 L}\sum_{t=0}^{T-1}\|\nabla\Phi(x_t)\|^2\le V_0-V_T\le V_0.
$$
Now
$$
V_0=\Phi(x_0)-\Phi^*+c\,\delta_0\le\Delta+\frac{L}{2\kappa}\delta_0\le\Delta+\frac{L}{2}\delta_0,
$$
so
$$
\frac{1}{T}\sum_{t=0}^{T-1}\|\nabla\Phi(x_t)\|^2\le\frac{256\kappa^2 L\bigl(\Delta+\tfrac{L}{2\kappa}\delta_0\bigr)}{T}=\frac{256\kappa^2 L\,\Delta}{T}+\frac{128\kappa L^2\,\delta_0}{T}.
$$

Since $\delta_0=\|y_0-y^*(x_0)\|^2$, this is exactly the required form
$$
\frac{1}{T}\sum_{t=0}^{T-1}\|\nabla\Phi(x_t)\|^2\le\frac{C_1\kappa^2 L\,\Delta}{T}+\frac{C_2\kappa^2 L\,\|y_0-y^*(x_0)\|^2}{T},
$$
with explicit constants
$$
\boxed{\;C_1=256,\qquad C_2=\frac{128 L}{\kappa\cdot\kappa^2 L}\cdot\kappa^2 L\cdot\frac{1}{\kappa}\cdot\kappa^2=128\cdot\frac{1}{\kappa}\le 128\quad\text{for }\kappa\ge 1.\;}
$$

More simply: $\frac{128\kappa L^2\delta_0}{T}=\frac{128\kappa L^2}{T}\delta_0$ and we want this $\le\frac{C_2\kappa^2 L}{T}\delta_0$, so $C_2\ge\frac{128 L}{\kappa L}=\frac{128}{\kappa}$. Since $\kappa\ge 1$, $C_2=128$ suffices.

**Conclusion.** For $\kappa\ge 1$, $\eta_x=1/(16\kappa^2 L)$, $\eta_y=1/L$:
$$
\frac{1}{T}\sum_{t=0}^{T-1}\|\nabla\Phi(x_t)\|^2\le\frac{256\,\kappa^2 L\,\Delta}{T}+\frac{128\,\kappa^2 L\,\|y_0-y^*(x_0)\|^2}{T}.
$$

$$\text{Q.E.D.}$$
