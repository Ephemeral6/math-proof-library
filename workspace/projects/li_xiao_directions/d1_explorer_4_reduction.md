# Direction 1 — Explorer 4 (REDUCTION frame)

**Task:** Reduce the zero-momentum cycling lower-bound problem to a known result about period-2 attractors of nonlinear maps with reflection symmetry.

**Date:** 2026-04-28
**Phase:** 2 (Explorer)
**Frame:** REDUCTION

---

## 0. Strategic statement

Goal: replace the open analytic question

> *"On what positive-measure subset of $(\beta,\eta L)$ does zero-momentum SHB on the K=3 Goujaud function $f_0$ remain bounded away from zero?"*

with a **fixed-point existence problem** in dimension four:

> *"On what subset does the 2-step SHB map $\Phi^2:\mathbb R^4\to\mathbb R^4$ admit an attractive non-trivial fixed point whose basin contains the diagonal, and what is its norm?"*

Period-2 attractors are the natural candidate because (i) the numerics at $\beta\in\{0.9,0.95\}$ show a bounded orbit with $\|x\|\in[0.86,1.21]$ that is *not* the K=3 cycle; (ii) the Goujaud function has $D_3$ symmetry but no obvious $\mathbb Z_2$ rotational subgroup that explains a period-2 *rotational* orbit, so we must look for orbits that respect a **reflection** symmetry instead.

The rest of this note carries out the reduction in seven steps and ends with the key open analytic questions.

---

## 1. Step 1 — The 2-step SHB map and its fixed points

Define on the **state space** $\mathbb R^4 = \{(x,y) : x = x_t, y = x_{t-1}\}$ the one-step SHB map
$$
\Phi(x,y) \;=\; \bigl(x - \eta\nabla f_0(x) + \beta(x-y),\; x\bigr).
$$
A period-2 orbit of the SHB recursion is a fixed point of $\Phi^2$ that is *not* a fixed point of $\Phi$. The fixed-point equation $\Phi^2(x_0,x_{-1}) = (x_0,x_{-1})$ is equivalent (using $x_2 = x_0$ and $x_3 = x_1$) to
$$
\begin{cases}
x_1 = x_0 - \eta\nabla f_0(x_0) + \beta(x_0 - x_{-1}),\\
x_0 = x_1 - \eta\nabla f_0(x_1) + \beta(x_1 - x_0).
\end{cases}\tag{P2}
$$
Eliminating $x_{-1}$ via $x_{-1} = x_1$ (which is what $x_3 = x_1$ forces in the period-2 case), we get
$$
\boxed{\;\eta\bigl(\nabla f_0(x_0) + \nabla f_0(x_1)\bigr) \;=\; (1-\beta)(x_1 - x_0) + \beta(x_1 - x_0) - 0\;}
$$
Wait — let us be careful. From the second line: $x_0 - x_1 = -\eta\nabla f_0(x_1) + \beta(x_1-x_0)$, hence $(1+\beta)(x_1-x_0) = -\eta\nabla f_0(x_1) + (x_1-x_0)$, which gives $\beta(x_1-x_0) = -\eta\nabla f_0(x_1)$.

Symmetrically, from the first line with the period-2 substitution $x_{-1} = x_1$:
$$
x_1 = x_0 - \eta\nabla f_0(x_0) + \beta(x_0-x_1) \;\Longleftrightarrow\; (1+\beta)(x_1-x_0) = -\eta\nabla f_0(x_0).
$$
So the **period-2 fixed-point system reduces to**
$$
\boxed{\;\eta\nabla f_0(x_0) \;=\; -(1+\beta)(x_1 - x_0)\,, \qquad \eta\nabla f_0(x_1) \;=\; -(1+\beta)(x_0 - x_1)\;.}\tag{P2$'$}
$$
Adding: $\nabla f_0(x_0) + \nabla f_0(x_1) = 0$. Subtracting: $\nabla f_0(x_0) - \nabla f_0(x_1) = -\frac{2(1+\beta)}{\eta}(x_1-x_0)$.

The first equation $\nabla f_0(x_0) = -\nabla f_0(x_1)$ encodes the **reflection symmetry** condition: a period-2 orbit of SHB on a function $f$ corresponds to two points whose gradients are negatives of each other. For a $D_3$-symmetric Goujaud function $f_0$, the natural way to satisfy $\nabla f_0(x_1) = -\nabla f_0(x_0)$ is to pick $x_1 = -x_0$ (which gives $\nabla f_0(-x_0) = -\nabla f_0(x_0)$ since $f_0$ is *even*: $f_0(-x) = f_0(x)$ because $\widetilde P$ is centrally symmetric for odd $K$? — need to check).

**Lemma 1.1 (even symmetry of $f_0$).** For K=3, the polytope $\widetilde P = \{Me_t\}_{t=0,1,2}$ is *not* centrally symmetric (it is a triangle, not a hexagon). Hence $f_0(-x) \neq f_0(x)$ in general, and $\nabla f_0(-x) \neq -\nabla f_0(x)$.

So the simplest reflection ansatz $x_1 = -x_0$ does **not** automatically work for K=3. This rules out the rotational-$\mathbb Z_2$ reduction. Instead, we use a different reflection.

---

## 2. Step 2 — Reflection symmetry of the polytope

The K=3 Goujaud polytope $\widetilde P = \{Me_0, Me_1, Me_2\}$ — an equilateral triangle — has dihedral symmetry $D_3 = C_3 \rtimes \mathbb Z_2$. The three reflections in $D_3$ are reflections across the *axis through one vertex and the midpoint of the opposite edge*. Call $\sigma_0$ the reflection through the $e_0$ axis (the $x$-axis):
$$
\sigma_0(x,y) = (x,-y).
$$
Then $\sigma_0(e_0) = e_0$, $\sigma_0(e_1) = e_2$, $\sigma_0(e_2) = e_1$. Because $\widetilde P$ and hence $f_0$ are $\sigma_0$-invariant, we have
$$
\nabla f_0(\sigma_0 x) = \sigma_0\nabla f_0(x).
$$
**Reflection ansatz.** We *seek* a period-2 fixed point of the form $(x_0, x_1)$ with
$$
x_1 = \sigma_0(x_0) \quad\text{(equivalently $x_{0,2} = -x_{1,2}$ where the second component is the $y$-coordinate; first components equal).}
$$
Under this ansatz, $\nabla f_0(x_1) = \sigma_0\nabla f_0(x_0)$. The period-2 equation $\nabla f_0(x_0) + \nabla f_0(x_1) = 0$ becomes
$$
\nabla f_0(x_0) + \sigma_0\nabla f_0(x_0) = 0 \;\Longleftrightarrow\; \pi_y\bigl(\nabla f_0(x_0)\bigr)\cdot 2 = \text{free}, \;\;\pi_x\bigl(\nabla f_0(x_0)\bigr) = 0.
$$
Wait: $(I+\sigma_0)v = (2v_x, 0)$, so the equation becomes $2(\nabla f_0(x_0))_x = 0$, i.e., **the $x$-component of $\nabla f_0(x_0)$ vanishes**. This forces $x_0$ to lie on the $y$-axis of *gradient space*, which by strong convexity means $x_0$ lies on the $y$-axis of *position space* (since $\nabla f_0$ at a point on the $y$-axis points along $y$, by reflection symmetry $\sigma_0$).

But waiting — if $x_0$ is on the $y$-axis, then $\sigma_0(x_0) = -x_0$, contradicting $x_1 = \sigma_0(x_0)$ unless $x_0$ has zero $y$-component, i.e., $x_0 = 0$. Trivial.

The reflection ansatz $x_1 = \sigma_0(x_0)$ thus **only yields the trivial fixed point**.

**Alternative reflection ansatz.** Try $x_1 = \sigma_0(x_0) + c$ for some constant $c$. This breaks the symmetry argument. Better: try the *anti-symmetric* ansatz $x_0 = (a, b)$, $x_1 = (a, -b)$ — i.e., they share the $x$-coordinate and reflect in $y$. Then under $\sigma_0$, $x_1 = \sigma_0 x_0$, and the gradient equation reduces (as shown) to $(\nabla f_0)_x(a,b) = 0$, forcing $a = 0$ (by reflection $\sigma_0$ argument applied to $f_0$ itself: gradient is parallel to position direction *only* when on the axis). Same trivial conclusion.

**Conclusion of Step 2.** The $D_3$ reflection symmetries of the K=3 polytope **do not produce non-trivial period-2 orbits via a symmetric ansatz**. Period-2 orbits, if they exist, must be at *generic* (non-symmetric) positions.

This is consistent with the numerics: the bounded oscillation at $\beta=0.9$ with $\|x_t\|\in[0.86, 1.21]$ has *two* distinct norms in the range (not a single norm) — meaning $\|x_0\| \neq \|x_1\|$, and the two points are NOT related by a $D_3$ symmetry.

---

## 3. Step 3 — Period-2 fixed point at *generic* positions

Returning to (P2$'$): we need
$$
\eta\nabla f_0(x_0) = (1+\beta)(x_0 - x_1), \qquad \eta\nabla f_0(x_1) = (1+\beta)(x_1 - x_0). \tag{P2$''$}
$$

Let $w := x_1 - x_0$ and $m := \tfrac12(x_0 + x_1)$ (midpoint). The two equations give:
$$
\nabla f_0(x_0) - \nabla f_0(x_1) = \frac{2(1+\beta)}{\eta}\,w, \qquad \nabla f_0(x_0) + \nabla f_0(x_1) = 0.\tag{P2$'''$}
$$
The second says the gradients at $x_0, x_1$ are *opposite*. Geometrically: the two iterate points lie at positions where $\nabla f_0$ takes opposite values. The first equation says the *difference* of gradients along the chord $w$ is proportional to $w$ with constant $\frac{2(1+\beta)}{\eta}$.

Now $\nabla f_0(x) = \mu x + (L-\mu)(I - P_{\widetilde C})x = Lx - (L-\mu) P_{\widetilde C}(x)$, where $\widetilde C := \mathrm{conv}(\widetilde P)$. So
$$
\nabla f_0(x_0) + \nabla f_0(x_1) = L(x_0 + x_1) - (L-\mu)(P_{\widetilde C}(x_0) + P_{\widetilde C}(x_1)) = 0.
$$
This gives
$$
\boxed{\;P_{\widetilde C}(x_0) + P_{\widetilde C}(x_1) = \frac{L}{L-\mu}(x_0 + x_1) = \frac{2L}{L-\mu}\, m.\;} \tag{Eq-mean}
$$
And the difference:
$$
L(x_0 - x_1) - (L-\mu)(P_{\widetilde C}(x_0) - P_{\widetilde C}(x_1)) = -\frac{2(1+\beta)}{\eta}(x_1 - x_0),
$$
i.e.,
$$
\boxed{\;(L-\mu)\bigl(P_{\widetilde C}(x_0) - P_{\widetilde C}(x_1)\bigr) = \Bigl(L + \frac{2(1+\beta)}{\eta}\Bigr)(x_0 - x_1) = \Bigl(L + \frac{2(1+\beta)}{\eta}\Bigr)\,(-w).\;}\tag{Eq-diff}
$$
Let $\alpha := \frac{L}{L-\mu}$ and $\gamma := \frac{1}{L-\mu}\bigl(L + \frac{2(1+\beta)}{\eta}\bigr) = \alpha + \frac{2(1+\beta)}{\eta(L-\mu)}$. Then (Eq-mean) and (Eq-diff) become
$$
\boxed{\;P_{\widetilde C}(x_0) + P_{\widetilde C}(x_1) = 2\alpha\,m, \qquad P_{\widetilde C}(x_0) - P_{\widetilde C}(x_1) = -\gamma\, w.\;}
$$
Hence
$$
P_{\widetilde C}(x_0) = \alpha m - \tfrac{\gamma}{2}w, \qquad P_{\widetilde C}(x_1) = \alpha m + \tfrac{\gamma}{2}w.
$$
Since $x_0 = m - w/2$ and $x_1 = m + w/2$, the projection map sends
$$
\boxed{\; m - \tfrac{w}{2} \;\longmapsto\; \alpha m - \tfrac{\gamma}{2}w, \qquad m + \tfrac{w}{2} \;\longmapsto\; \alpha m + \tfrac{\gamma}{2}w.\;}\tag{$\star$}
$$
This is a clean **affine** characterization of the period-2 condition: $P_{\widetilde C}$ acts on the pair $\{x_0, x_1\}$ as the affine map $(m \pm w/2) \mapsto (\alpha m \pm \tfrac\gamma2 w)$. Whether such a pair exists depends on the geometry of $P_{\widetilde C}$.

---

## 4. Step 4 — Existence of period-2 fixed points for the K=3 polytope

We now ask: when does there exist a pair $(x_0,x_1)$ with mean $m$ and chord $w$ such that the projections onto the K=3 triangle satisfy ($\star$)?

**Case A — both $x_0, x_1$ project to the *same* face (edge) of $\widetilde C$.** If $\widetilde C = \mathrm{conv}\{Me_0, Me_1, Me_2\}$ has edges $E_{ij} = [Me_i, Me_j]$ and both projections land on $E_{01}$, then $P_{\widetilde C}$ is locally an affine projection onto the line through $E_{01}$. Write $E_{01}$ in the form $\{p + s\hat e : s\in [0,1]\}$ where $\hat e$ is the unit edge vector and $p = Me_0$. The projection $P_{\widetilde C}|_{\text{strip}}(x) = p + \langle x-p, \hat e\rangle \hat e$.

Substituting in ($\star$): with $x_0 = m - w/2$,
$$
P_{\widetilde C}(x_0) = p + \langle m - w/2 - p, \hat e\rangle\hat e = \alpha m - \tfrac\gamma2 w.
$$
This requires $\alpha m - \tfrac\gamma2 w$ to lie on the line through $E_{01}$, i.e., orthogonal to the edge normal $n_{01}$:
$$
\langle \alpha m - \tfrac\gamma 2 w - p, n_{01}\rangle = 0 \;\Longleftrightarrow\; \alpha\langle m,n_{01}\rangle - \tfrac\gamma 2\langle w, n_{01}\rangle = \langle p, n_{01}\rangle.
$$
Same with $x_1$:
$$
\alpha\langle m,n_{01}\rangle + \tfrac\gamma 2\langle w, n_{01}\rangle = \langle p, n_{01}\rangle.
$$
Adding: $\alpha\langle m, n_{01}\rangle = \langle p, n_{01}\rangle$. Subtracting: $\gamma\langle w, n_{01}\rangle = 0$, i.e., $w \perp n_{01}$, so the chord $w$ is *parallel* to the edge $E_{01}$.

Combined with the affine constraint along $\hat e$:
$$
\langle m - w/2 - p, \hat e\rangle = \alpha\langle m, \hat e\rangle - \tfrac\gamma 2\langle w, \hat e\rangle - \langle p, \hat e\rangle? \dots
$$
Actually re-deriving along $\hat e$: $P_{\widetilde C}(x_0)|_{\hat e\text{-component}} = \langle m-w/2-p, \hat e\rangle + \langle p, \hat e\rangle = \langle m-w/2, \hat e\rangle$. We need this to equal $\langle\alpha m - \tfrac\gamma 2 w, \hat e\rangle = \alpha\langle m,\hat e\rangle - \tfrac\gamma 2\langle w, \hat e\rangle$.

Comparing tangential components: $\langle m, \hat e\rangle - \tfrac12\langle w, \hat e\rangle = \alpha\langle m, \hat e\rangle - \tfrac\gamma 2\langle w, \hat e\rangle$,
i.e.,
$$
(1-\alpha)\langle m, \hat e\rangle = \tfrac{1-\gamma}{2}\langle w, \hat e\rangle.
$$
Combined with normal constraints: this is **two scalar equations** in the four unknowns $(m_x, m_y, w_x, w_y)$; the chord is parallel to an edge ($w\perp n_{01}$, one equation), the mean projection is at fixed normal-distance ($\alpha\langle m, n_{01}\rangle = \langle p, n_{01}\rangle$, one equation), and the tangential balance gives one more, leaving a **1-parameter family** of period-2 fixed points (parametrized by, e.g., the chord length).

Thus, **for each edge of $\widetilde C$**, there is a 1-parameter family of period-2 candidate fixed points satisfying the projection conditions ($\star$), provided both $x_0, x_1$ have foot-points on that edge.

**Validity check.** Need $x_0, x_1$ to actually project to the chosen edge (not to a vertex or to the interior of $\widetilde C$). This is an open condition — it cuts the 1-parameter family into intervals.

[CALL:math-verifier] *Verify the system of equations above has a 1-parameter solution family for the K=3 polytope at $\beta=0.9, \eta L=3.7, \kappa=0.1$, and compute the family explicitly.*

---

## 5. Step 5 — The lower bound on the period-2 attractor

Suppose a period-2 fixed point $(x_0^*, x_1^*)$ exists with $\|x_0^*\| = R_0$, $\|x_1^*\| = R_1$. The strong-convexity floor gives
$$
f_0(x_t) - f_0^\star \;\geq\; \tfrac{\mu}{2}\|x_t\|^2 \;\geq\; \tfrac{\mu}{2}\min(R_0, R_1)^2.
$$
From the numerics at $\beta = 0.9$: the orbit oscillates in $\|x_t\| \in [0.86, 1.21]$, so $\min(R_0, R_1) \approx 0.86 \cdot D/\sqrt{2}$ — wait, actually the absolute values are $\|x_t\|\in[0.86,1.21]$ with $D = 1$ in units of the experiment, so $\min(R_0, R_1) \approx 0.86$.

The cycle radius is $D/\sqrt 2 \approx 0.707$. The period-2 attractor has $\|x_t\| \geq 0.86 > 0.707$, so the strong-convexity floor on the period-2 attractor is **at least as good** as on the K=3 cycle. Specifically:
$$
f_0(x_t) - f_0^\star \;\geq\; \tfrac\mu 2 \cdot 0.86^2 \cdot D^2 \;\approx\; 0.37\mu D^2,
$$
which **exceeds** the OP-2 cycle floor of $\mu D^2/4 = 0.25\mu D^2$ by a factor 1.5.

**This is the key payoff of the REDUCTION:** the period-2 attractor gives a *better* lower-bound constant than the K=3 cycle, on the parameter region $\beta\in[0.85,1)$ where it is observed numerically.

---

## 6. Step 6 — Attractiveness via Jacobian spectrum

For attractiveness of the period-2 fixed point $(x_0^*, x_1^*)$, we need the Jacobian of $\Phi^2$ at this fixed point to have spectral radius $<1$.

The Jacobian of $\Phi$ at a state $(x,y)$ where $x \in \mathrm{int}(\widetilde C^c)$ and the projection $P_{\widetilde C}(x)$ lies in the *interior* of an edge $E_{ij}$ is:
$$
D\Phi(x,y) = \begin{pmatrix} (1+\beta)I - \eta\,H(x) & -\beta I \\ I & 0 \end{pmatrix},
$$
where $H(x) = \nabla^2 f_0(x) = LI - (L-\mu)\,DP_{\widetilde C}(x)$ and $DP_{\widetilde C}(x)$ is the orthogonal projection onto the line through $E_{ij}$, i.e., a rank-1 matrix $\hat e \hat e^\top$ (where $\hat e$ is the unit vector along $E_{ij}$). So $H(x) = LI - (L-\mu)\hat e\hat e^\top = \mu \hat e\hat e^\top + L(I - \hat e\hat e^\top)$. The spectrum of $H$ is $\{\mu, L\}$ (one along $\hat e$, one along the edge normal).

The Jacobian of $\Phi^2$ at the period-2 fixed point is $D\Phi(x_1^*, x_0^*) \cdot D\Phi(x_0^*, x_1^*)$ — a product of two 4×4 matrices.

By the SHB scalar-mode decomposition: in the basis where $H$ is diagonal, the SHB recursion decouples into two scalar 2nd-order recursions with characteristic equations
$$
z^2 - (1+\beta-\eta\lambda)z + \beta = 0, \qquad \lambda \in \{\mu, L\}.
$$
The roots $r_{1,\lambda}, r_{2,\lambda}$ have $|r_{i,\lambda}| = \sqrt\beta$ in the under-damped regime. The Jacobian of one step has eigenvalues $\{r_{1,\mu}, r_{2,\mu}, r_{1,L}, r_{2,L}\}$, and the Jacobian of $\Phi^2$ has eigenvalues $\{r_{i,\lambda}^2\}$, all of modulus $\beta$ in the under-damped regime.

**Attractiveness criterion: $\beta < 1$.** Since $\beta\in(0,1)$ in our problem, the Jacobian spectral radius of $\Phi^2$ is $\beta < 1$, **the period-2 fixed point is locally attractive** in the open under-damped regime where $H$ has constant spectrum (i.e., where the projection foot stays on the *same* edge for both $x_0^*$ and $x_1^*$).

[CALL:math-verifier] *Numerically verify $\rho(D\Phi^2(x_0^*, x_1^*)) = \beta$ at $(\beta, \eta L, \kappa) = (0.9, 3.7, 0.1)$, confirming local attractiveness.*

---

## 7. Step 7 — Positive measure via implicit function theorem

The period-2 fixed point equations from Step 3 are
$$
F_1(x_0, x_1; \beta, \eta L, \kappa) := \eta\nabla f_0(x_0) + (1+\beta)(x_1-x_0) = 0,\quad F_2 := \eta\nabla f_0(x_1) + (1+\beta)(x_0-x_1) = 0.
$$
This is 4 equations in 4 unknowns plus 3 parameters $(\beta, \eta L, \kappa)$. At a regular solution $(x_0^*, x_1^*)$, the Jacobian $\partial(F_1,F_2)/\partial(x_0,x_1)$ has full rank (this is exactly the $D\Phi^2 - I$ matrix, which is invertible if 1 is not an eigenvalue of $D\Phi^2$, which holds when $\beta < 1$ in the under-damped regime).

By the implicit function theorem, the solution set $(x_0^*(\beta,\eta L, \kappa), x_1^*(\beta,\eta L,\kappa))$ is a smooth 3-manifold in the 7-dimensional parameter+state space. Its projection to $(\beta,\eta L,\kappa)$ space is open, hence has positive 3-D Lebesgue measure.

The basin condition (zero-momentum init $(v,v)$ with $v = (D/\sqrt 2)e_0$ lies in the basin of $(x_0^*, x_1^*)$) is also an open condition by attractiveness (Step 6) and continuity. Combining, $\mathcal F^{\mathrm{per2}}$ is open and non-empty (numerical evidence: $\beta\in\{0.9, 0.95\}$, $\eta L$ near upper boundary).

---

## 8. Closed-form for the period-2 fixed point: can we solve?

Key analytical question: **is the period-2 fixed point computable in closed form?**

From Step 4: yes, *modulo* knowing which edges of $\widetilde C$ the projections land on. Specifically, if both project to edge $E_{ij}$ with unit vector $\hat e$ and base point $p = Me_i$:
- $w \perp n_{ij}$ (chord parallel to edge),
- $\alpha\langle m, n_{ij}\rangle = \langle p, n_{ij}\rangle$ (mean at fixed normal-distance),
- $(1-\alpha)\langle m, \hat e\rangle = \tfrac{1-\gamma}{2}\langle w, \hat e\rangle$ (tangential balance).

Two equations in the 4-dim variables $(m, w)$ (after using $w\perp n$ — i.e., $\langle w, n\rangle = 0$ — which is one equation but parametrizes $w = w_\| \hat e$, a 1-parameter family). So the solution set is **a 1-parameter family** of period-2 fixed points along the edge, with normal-distance fixed and tangential offset free.

**The free parameter is the chord length $|w_\||$.** Different chord lengths give different period-2 orbits at different positions along the edge; the dynamics select a particular one (the attractor) by stability.

[CALL:math-verifier] *Solve the 2D system at $(\beta, \eta L, \kappa) = (0.9, 3.7, 0.1)$ for the K=3 triangle, and confirm $\|x_0^*\|, \|x_1^*\|$ match the numerical attractor norms $[0.86, 1.21]$.*

---

## 9. Period higher than 2? Quasi-periodic?

**Question: is the bounded attractor at $\beta=0.9$ truly period-2 or higher?**

The numerical evidence shows $\|x_t\|$ oscillating in $[0.86, 1.21]$. If period-2, the orbit would have *exactly two* values of $\|x_t\|$ on the limit set. If higher period (e.g., period-6) or quasi-periodic, the orbit would visit a continuum of $\|x_t\|$ values densely in some interval.

The numerical experiment reports $\|x_t\| \in [0.86, 1.21]$ — this is consistent with *either* period-2 (two values, e.g., 0.86 and 1.21) *or* period-6 (six values within $[0.86, 1.21]$) *or* quasi-periodic.

**Period-6 ansatz.** The K=3 polytope has $C_3$ rotational symmetry, so a $\mathbb Z_6 = \mathbb Z_2 \times \mathbb Z_3$ orbit (6-cycle that respects $C_3$) is also natural: $x_0, x_1, x_2 = R_{2\pi/3}x_0, R_{2\pi/3}x_1, x_4 = R_{4\pi/3}x_0, x_5 = R_{4\pi/3}x_1$, then $x_6 = x_0$. This is a **2-orbit modulo $C_3$**, giving 6 distinct points.

The reduction of period-6 to period-2 modulo $C_3$ is exactly the same as a period-2 fixed point of the *quotient map* $\bar\Phi$ on $\mathbb R^4 / C_3$. The fixed-point equations are identical to Step 3 with $f_0$ replaced by its $C_3$-symmetrized lift, and the result is the same: a 1-parameter family of period-2 (mod $C_3$) fixed points per edge.

**The numerical observation of $\|x_t\|\in[0.86,1.21]$ is consistent with period-6 = period-2 mod $C_3$**, where two distinct norms ($\approx 0.86$ and $\approx 1.21$) cycle through 3 rotated copies.

---

## 10. Summary: what the REDUCTION achieves

**Achieved:**
1. The zero-momentum cycling LB problem is reduced to the existence and attractiveness of a period-2 (or period-6 = period-2 mod $C_3$) fixed point of the SHB 2-step map $\Phi^2$.
2. The fixed-point equations admit an explicit form: $\nabla f_0(x_0) + \nabla f_0(x_1) = 0$ and $\eta(\nabla f_0(x_0) - \nabla f_0(x_1)) = -2(1+\beta)w$.
3. For each edge of the K=3 polytope, a 1-parameter family of candidate period-2 orbits exists, parametrized by chord length, satisfying explicit linear equations on $(m,w)$.
4. Local attractiveness of the period-2 fixed point follows from $\rho(D\Phi^2) = \beta < 1$ in the under-damped regime.
5. The implicit function theorem gives a positive-measure parameter region $\mathcal F^{\mathrm{per2}}$ where the period-2 fixed point exists and is attractive.

**The lower bound on the period-2 attractor:** $f_0(x_t) - f_0^\star \geq (\mu/2)(0.86 D)^2 = 0.37\mu D^2$ — a constant 1.5× larger than the OP-2 K=3 cycle constant.

**Open analytic gaps (for Phase 3 fixer):**
- **Basin condition:** does the zero-momentum init $(v,v)$, $v = (D/\sqrt 2)e_0$, lie in the basin of attraction of the period-2 fixed point? This is global, not local; requires either Lyapunov function (Route F) or a direct trapping argument.
- **Selection of the chord length:** the 1-parameter family must be cut to the *attracting* member by the dynamics. This is determined by transversality of the stable manifold of $\Phi^2$ to the diagonal $\{(v,v)\}$.
- **Period-2 vs. period-6:** numerical refinement (look at $\|x_t\|$ at 6 consecutive steps, check for true 2-periodicity vs. 6-periodicity).

**Reduction to a known result:** the existence + attractiveness analysis is structurally identical to results on **period-2 attractors of piecewise-affine maps on polytopes** (Holmes–Marsden style; cf. period-doubling cascades in continuous-time analogs). The critical novelty here is the basin-of-attraction question for the diagonal, which is a Goujaud-specific geometric obstruction.

**Ranking:** this REDUCTION lowers Route C's difficulty from "research" to "advanced (with verifier assistance)" provided the basin condition is checked by numerical witness (at $\beta = 0.9, \eta L = 3.7$, run the iteration to $T = 10^4$ and confirm convergence to a 2-cycle modulo $C_3$). Combined with Route G (interval arithmetic at a specific point), this gives a constructive positive-measure proof.
