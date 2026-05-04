# Proof of ADMM Ergodic O(1/T) Convergence Rate — Route 3

**Route**: Direct augmented-Lagrangian saddle analysis (no VI / operator-theoretic machinery).

**Target**: For every $T\ge 1$ and every test point $(\tilde x,\tilde z,\tilde\lambda)$ in the primal–dual domain, the ergodic gap
$$\Phi\big((\bar x_T,\bar z_T,\bar\lambda_T);(\tilde x,\tilde z,\tilde\lambda)\big)\;\le\;\frac{1}{T}\Bigl[\tfrac{\beta}{2}\|B(\tilde z-z^0)\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^0\|^2\Bigr]$$
where
$$\Phi\big((x,z,\lambda);(\tilde x,\tilde z,\tilde\lambda)\big)=\bigl[f(x)+g(z)-f(\tilde x)-g(\tilde z)\bigr]+\langle\tilde\lambda,\,Ax+Bz-c\rangle-\langle\lambda,\,A\tilde x+B\tilde z-c\rangle.$$

**Scope of the theorem**. We interpret the "primal–dual domain" as follows: the test point satisfies $\tilde x\in\operatorname{dom}f$, $\tilde z\in\operatorname{dom}g$, and $\tilde\lambda\in\mathbb R^m$. The stated bound holds when *in addition* the residual $d:=A\tilde x+B\tilde z-c$ is *treated as an extra pairing with the running dual*; for **feasible test points** (i.e. $d=0$), the bound holds in its stated form, and this is the only setting in which it is meaningful (as the remark in the problem statement notes — the corollary "feasibility of $(x^\star,z^\star)$ as $\tilde x,\tilde z$" recovers the standard primal–dual gap). Throughout the proof we first derive a *per-step inequality* valid for arbitrary $(\tilde x,\tilde z,\tilde\lambda)$ and show the RHS telescopes to the stated bound **plus** a term that vanishes when $d=0$. The resulting bound therefore holds exactly as stated for feasible test points, which is the setting intended by the theorem.

Throughout, $r^{k+1}:=Ax^{k+1}+Bz^{k+1}-c$ and the dual update is $\lambda^{k+1}=\lambda^k+\beta r^{k+1}$.

Reference: the structural template `[REF: proofs/library/convex-analysis/subgradient/admm-ergodic-convergence-full-rank/proof.md]` (its "Version B — no full-rank assumption", Steps 1–3) follows the same direct-Lagrangian strategy. We adapt it to (i) use the lagged dual $\bar\lambda_T$ as defined, (ii) allow *arbitrary* test points (not only KKT saddle points) with the feasibility caveat above, (iii) carry through without any full-rank assumption on $A,B$.

---

## Step 1: First-order optimality conditions of the subproblems

The $x$-subproblem $x^{k+1}\in\arg\min_x f(x)+\tfrac{\beta}{2}\|Ax+Bz^k-c+\lambda^k/\beta\|^2$ is the minimization of the sum of a proper closed convex function $f$ and a finite-valued convex quadratic. By Rockafellar's sum rule (Rockafellar, *Convex Analysis*, Thm 23.8), $x^{k+1}$ satisfies
$$0\in\partial f(x^{k+1})+\beta A^\top(Ax^{k+1}+Bz^k-c+\lambda^k/\beta).$$
The inner bracket equals $Ax^{k+1}+Bz^k-c+\lambda^k/\beta$. Since $\lambda^{k+1}=\lambda^k+\beta r^{k+1}=\lambda^k+\beta(Ax^{k+1}+Bz^{k+1}-c)$,
$$\beta(Ax^{k+1}+Bz^k-c)+\lambda^k=\lambda^k+\beta(Ax^{k+1}+Bz^{k+1}-c)+\beta B(z^k-z^{k+1})=\lambda^{k+1}+\beta B(z^k-z^{k+1}).$$
Hence there exists
$$\xi_f^{k+1}:=-A^\top\lambda^{k+1}-\beta A^\top B(z^k-z^{k+1})\in\partial f(x^{k+1}). \tag{O$_x$}$$

The $z$-subproblem's inner bracket equals $Ax^{k+1}+Bz^{k+1}-c+\lambda^k/\beta=r^{k+1}+\lambda^k/\beta=\lambda^{k+1}/\beta$, so optimality gives
$$\xi_g^{k+1}:=-B^\top\lambda^{k+1}\in\partial g(z^{k+1}). \tag{O$_z$}$$

No uniqueness of minimizer is needed; we simply fix one $(x^{k+1},z^{k+1})$ and its associated subgradient pair.

---

## Step 2: Subgradient convexity inequalities

Let $(\tilde x,\tilde z,\tilde\lambda)$ be any test point with $\tilde x\in\operatorname{dom}f$, $\tilde z\in\operatorname{dom}g$. By convexity of $f$ and the subgradient inequality $f(\tilde x)\ge f(x^{k+1})+\langle\xi_f^{k+1},\tilde x-x^{k+1}\rangle$:
$$f(x^{k+1})-f(\tilde x)\le\langle\xi_f^{k+1},x^{k+1}-\tilde x\rangle=-\langle\lambda^{k+1},A(x^{k+1}-\tilde x)\rangle-\beta\langle B(z^k-z^{k+1}),A(x^{k+1}-\tilde x)\rangle. \tag{I$_f$}$$

By convexity of $g$ and (O$_z$):
$$g(z^{k+1})-g(\tilde z)\le-\langle\lambda^{k+1},B(z^{k+1}-\tilde z)\rangle. \tag{I$_g$}$$

Adding (I$_f$) and (I$_g$) and using $A(x^{k+1}-\tilde x)+B(z^{k+1}-\tilde z)=r^{k+1}-d$ where $d:=A\tilde x+B\tilde z-c$:
$$\Delta\theta^{k+1}\le-\langle\lambda^{k+1},r^{k+1}\rangle+\langle\lambda^{k+1},d\rangle-\beta\langle B(z^k-z^{k+1}),A(x^{k+1}-\tilde x)\rangle, \tag{Step 2}$$
where $\Delta\theta^{k+1}:=f(x^{k+1})+g(z^{k+1})-f(\tilde x)-g(\tilde z)$.

---

## Step 3: Gap function with the lagged dual

The theorem's ergodic dual is $\bar\lambda_T=\frac1T\sum_{k=1}^T\lambda^{k-1}=\frac1T\sum_{k=0}^{T-1}\lambda^k$. Accordingly, we evaluate the gap at the lagged dual $\lambda^k$ (paired with step-$(k+1)$ primals):
$$\widehat\Phi^{k+1}:=\bigl[f(x^{k+1})+g(z^{k+1})-f(\tilde x)-g(\tilde z)\bigr]+\langle\tilde\lambda,r^{k+1}\rangle-\langle\lambda^k,d\rangle=\Delta\theta^{k+1}+\langle\tilde\lambda,r^{k+1}\rangle-\langle\lambda^k,d\rangle.$$

**Jensen's inequality for the ergodic average.** The averages are $\bar x_T=\frac1T\sum_{k=1}^Tx^k$, $\bar z_T=\frac1T\sum_{k=1}^Tz^k$, $\bar\lambda_T=\frac1T\sum_{k=0}^{T-1}\lambda^k$, and
$$\bar r_T:=\frac1T\sum_{k=0}^{T-1}r^{k+1}=A\bar x_T+B\bar z_T-c.$$

By convexity of $f$ and $g$ (Jensen):
$$f(\bar x_T)+g(\bar z_T)\le\frac1T\sum_{k=0}^{T-1}\bigl[f(x^{k+1})+g(z^{k+1})\bigr].$$
By linearity of the inner-product terms,
$$\frac1T\sum_{k=0}^{T-1}\widehat\Phi^{k+1}\ge\bigl[f(\bar x_T)+g(\bar z_T)-f(\tilde x)-g(\tilde z)\bigr]+\langle\tilde\lambda,\bar r_T\rangle-\langle\bar\lambda_T,d\rangle=\Phi\bigl((\bar x_T,\bar z_T,\bar\lambda_T);(\tilde x,\tilde z,\tilde\lambda)\bigr). \tag{Jensen}$$

**Therefore it suffices to prove**
$$\sum_{k=0}^{T-1}\widehat\Phi^{k+1}\le\tfrac{\beta}{2}\|B(\tilde z-z^0)\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^0\|^2. \tag{Goal}$$

---

## Step 4: From (Step 2) to a bound on $\widehat\Phi^{k+1}$

Rewrite (Step 2) by subtracting $-\langle\tilde\lambda,r^{k+1}\rangle+\langle\lambda^k,d\rangle$ from both sides and adding $\Delta\theta^{k+1}$:

LHS becomes $\Delta\theta^{k+1}+\langle\tilde\lambda,r^{k+1}\rangle-\langle\lambda^k,d\rangle=\widehat\Phi^{k+1}$.

RHS becomes $-\langle\lambda^{k+1},r^{k+1}\rangle+\langle\lambda^{k+1},d\rangle-\beta\langle B(z^k-z^{k+1}),A(x^{k+1}-\tilde x)\rangle+\langle\tilde\lambda,r^{k+1}\rangle-\langle\lambda^k,d\rangle$
$=\langle\tilde\lambda-\lambda^{k+1},r^{k+1}\rangle+\langle\lambda^{k+1}-\lambda^k,d\rangle-\beta\langle B(z^k-z^{k+1}),A(x^{k+1}-\tilde x)\rangle$
$=\langle\tilde\lambda-\lambda^{k+1},r^{k+1}\rangle+\beta\langle r^{k+1},d\rangle-\beta\langle B(z^k-z^{k+1}),A(x^{k+1}-\tilde x)\rangle$,

where the last line uses $\lambda^{k+1}-\lambda^k=\beta r^{k+1}$. Therefore
$$\widehat\Phi^{k+1}\le\langle\tilde\lambda-\lambda^{k+1},r^{k+1}\rangle+\beta\langle r^{k+1},d\rangle-\beta\langle B(z^k-z^{k+1}),A(x^{k+1}-\tilde x)\rangle. \tag{Step 4}$$

---

## Step 5: Decomposing the $x$-subproblem cross-term

Using the identity (trivially)
$$A(x^{k+1}-\tilde x)=\bigl[Ax^{k+1}+Bz^{k+1}-c\bigr]-\bigl[A\tilde x+B\tilde z-c\bigr]-B(z^{k+1}-\tilde z)=r^{k+1}-d-B(z^{k+1}-\tilde z), \tag{A-split}$$
we expand
$$-\beta\langle B(z^k-z^{k+1}),A(x^{k+1}-\tilde x)\rangle=-\beta\langle B(z^k-z^{k+1}),r^{k+1}\rangle+\beta\langle B(z^k-z^{k+1}),d\rangle+\beta\langle B(z^k-z^{k+1}),B(z^{k+1}-\tilde z)\rangle. \tag{Cross-split}$$

Substituting into (Step 4):
$$\widehat\Phi^{k+1}\le\langle\tilde\lambda-\lambda^{k+1},r^{k+1}\rangle+\underbrace{\beta\langle r^{k+1},d\rangle+\beta\langle B(z^k-z^{k+1}),d\rangle}_{=\beta\langle s^{k+1},d\rangle\;(\ast)}-\beta\langle B(z^k-z^{k+1}),r^{k+1}\rangle+\beta\langle B(z^k-z^{k+1}),B(z^{k+1}-\tilde z)\rangle,$$
where $s^{k+1}:=r^{k+1}+B(z^k-z^{k+1})=Ax^{k+1}+Bz^k-c$ is the "intermediate primal residual" seen by the $x$-subproblem.

Verification of $(\ast)$: $\beta r^{k+1}+\beta B(z^k-z^{k+1})=\beta(Ax^{k+1}+Bz^{k+1}-c)+\beta B(z^k-z^{k+1})=\beta(Ax^{k+1}+Bz^k-c)=\beta s^{k+1}$, so $\beta\langle r^{k+1},d\rangle+\beta\langle B(z^k-z^{k+1}),d\rangle=\beta\langle s^{k+1},d\rangle$. ✓

So
$$\widehat\Phi^{k+1}\le\langle\tilde\lambda-\lambda^{k+1},r^{k+1}\rangle+\beta\langle s^{k+1},d\rangle-\beta\langle B(z^k-z^{k+1}),r^{k+1}\rangle+\beta\langle B(z^k-z^{k+1}),B(z^{k+1}-\tilde z)\rangle. \tag{Step 5}$$

---

## Step 6: Polarization identities (dual and primal-$B$)

**Dual identity.** Using $r^{k+1}=(\lambda^{k+1}-\lambda^k)/\beta$ and the three-point identity (parallelogram law) $\langle a-b,b-c\rangle=\tfrac12(\|a-c\|^2-\|a-b\|^2-\|b-c\|^2)$ with $a=\tilde\lambda$, $b=\lambda^{k+1}$, $c=\lambda^k$:
$$\langle\tilde\lambda-\lambda^{k+1},\lambda^{k+1}-\lambda^k\rangle=\tfrac12\bigl(\|\tilde\lambda-\lambda^k\|^2-\|\tilde\lambda-\lambda^{k+1}\|^2-\|\lambda^{k+1}-\lambda^k\|^2\bigr).$$
Dividing by $\beta$,
$$\langle\tilde\lambda-\lambda^{k+1},r^{k+1}\rangle=\tfrac{1}{2\beta}\bigl(\|\tilde\lambda-\lambda^k\|^2-\|\tilde\lambda-\lambda^{k+1}\|^2\bigr)-\tfrac{\beta}{2}\|r^{k+1}\|^2, \tag{Dual-ID}$$
using $\|\lambda^{k+1}-\lambda^k\|^2=\beta^2\|r^{k+1}\|^2$.

**$B$-polarization.** Apply the three-point identity with $a=\tilde z$, $b=z^{k+1}$, $c=z^k$ (so $a-b=\tilde z-z^{k+1}$, $b-c=z^{k+1}-z^k$, $a-c=\tilde z-z^k$), then left-multiply the vectors by $B$ and take inner products:
$$\langle B(\tilde z-z^{k+1}),B(z^{k+1}-z^k)\rangle=\tfrac12\bigl(\|B(\tilde z-z^k)\|^2-\|B(\tilde z-z^{k+1})\|^2-\|B(z^{k+1}-z^k)\|^2\bigr).$$

[Derivation of the three-point identity: $\|a-c\|^2=\|(a-b)+(b-c)\|^2=\|a-b\|^2+2\langle a-b,b-c\rangle+\|b-c\|^2$, so $\langle a-b,b-c\rangle=\tfrac12(\|a-c\|^2-\|a-b\|^2-\|b-c\|^2)$. Replacing $a,b,c$ by $B\cdot(\text{same})$ preserves the identity because the three-point identity is a polarization, and $B$ is linear.]

Since $B(z^k-z^{k+1})=-B(z^{k+1}-z^k)$ and $B(z^{k+1}-\tilde z)=-B(\tilde z-z^{k+1})$,
$$\langle B(z^k-z^{k+1}),B(z^{k+1}-\tilde z)\rangle=\langle B(\tilde z-z^{k+1}),B(z^{k+1}-z^k)\rangle.$$
Hence
$$\beta\langle B(z^k-z^{k+1}),B(z^{k+1}-\tilde z)\rangle=\tfrac{\beta}{2}\bigl(\|B(\tilde z-z^k)\|^2-\|B(\tilde z-z^{k+1})\|^2\bigr)-\tfrac{\beta}{2}\|B(z^{k+1}-z^k)\|^2. \tag{B-pol}$$

**Perfect square.** Combine the three "remainder" terms from (Dual-ID), (B-pol), and the middle of (Step 5):
$$-\tfrac{\beta}{2}\|r^{k+1}\|^2-\beta\langle B(z^k-z^{k+1}),r^{k+1}\rangle-\tfrac{\beta}{2}\|B(z^{k+1}-z^k)\|^2$$
$$=-\tfrac{\beta}{2}\bigl(\|r^{k+1}\|^2+2\langle r^{k+1},B(z^k-z^{k+1})\rangle+\|B(z^k-z^{k+1})\|^2\bigr)=-\tfrac{\beta}{2}\|r^{k+1}+B(z^k-z^{k+1})\|^2=-\tfrac{\beta}{2}\|s^{k+1}\|^2. \tag{Sq}$$

This is a genuine squared Euclidean norm (not a semi-norm), so $-\tfrac{\beta}{2}\|s^{k+1}\|^2\le 0$.

---

## Step 7: Per-step inequality

Substituting (Dual-ID), (B-pol), (Sq) into (Step 5):
$$\widehat\Phi^{k+1}\le\tfrac{1}{2\beta}\bigl(\|\tilde\lambda-\lambda^k\|^2-\|\tilde\lambda-\lambda^{k+1}\|^2\bigr)+\tfrac{\beta}{2}\bigl(\|B(\tilde z-z^k)\|^2-\|B(\tilde z-z^{k+1})\|^2\bigr)-\tfrac{\beta}{2}\|s^{k+1}\|^2+\beta\langle s^{k+1},d\rangle.$$

Define the Lyapunov function
$$\mathcal E^k:=\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^k\|^2+\tfrac{\beta}{2}\|B(\tilde z-z^k)\|^2\ge 0.$$
Then
$$\boxed{\widehat\Phi^{k+1}\;\le\;\mathcal E^k-\mathcal E^{k+1}-\tfrac{\beta}{2}\|s^{k+1}\|^2+\beta\langle s^{k+1},d\rangle.} \tag{Key}$$

**Observation.** The last term $\beta\langle s^{k+1},d\rangle$ vanishes identically when $d=0$ (feasible test point). For $d=0$:
$$\widehat\Phi^{k+1}\le\mathcal E^k-\mathcal E^{k+1}-\tfrac{\beta}{2}\|s^{k+1}\|^2. \tag{Key$_0$}$$
This is the per-step inequality for feasible test points.

---

## Step 8: Telescoping sum (feasible test points, $d=0$)

Sum (Key$_0$) over $k=0,\dots,T-1$:
$$\sum_{k=0}^{T-1}\widehat\Phi^{k+1}\;\le\;\mathcal E^0-\mathcal E^T-\tfrac{\beta}{2}\sum_{k=0}^{T-1}\|s^{k+1}\|^2.$$

Both $\mathcal E^T\ge 0$ and $\tfrac{\beta}{2}\sum\|s^{k+1}\|^2\ge 0$ can be dropped:
$$\sum_{k=0}^{T-1}\widehat\Phi^{k+1}\;\le\;\mathcal E^0=\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^0\|^2+\tfrac{\beta}{2}\|B(\tilde z-z^0)\|^2. \tag{Sum}$$

This establishes (Goal) for $d=0$.

---

## Step 9: Combining with Jensen and dividing by $T$

From (Jensen) and (Sum):
$$\Phi\bigl((\bar x_T,\bar z_T,\bar\lambda_T);(\tilde x,\tilde z,\tilde\lambda)\bigr)\le\frac1T\sum_{k=0}^{T-1}\widehat\Phi^{k+1}\le\frac{1}{T}\Bigl[\tfrac{\beta}{2}\|B(\tilde z-z^0)\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^0\|^2\Bigr]. \tag{Ergodic}$$

This is **exactly** the stated bound.

---

## Step 10: Application to recover the standard primal–dual gap

For the standard primal–dual gap, choose:
1. $(\tilde x,\tilde z)$ to be the primal part of any KKT saddle point $(x^\star,z^\star,\lambda^\star)$ (so $A\tilde x+B\tilde z=c$, i.e. $d=0$).
2. $\tilde\lambda$ to range over a bounded set $\mathcal B_\rho=\{\lambda:\|\lambda\|\le\rho\}$.

Then (Ergodic) gives
$$f(\bar x_T)+g(\bar z_T)-f(x^\star)-g(z^\star)+\langle\tilde\lambda,A\bar x_T+B\bar z_T-c\rangle\le\frac{1}{T}\Bigl[\tfrac{\beta}{2}\|B(z^\star-z^0)\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^0\|^2\Bigr].$$
Taking the supremum over $\tilde\lambda\in\mathcal B_\rho$ (and noting the RHS is quadratic in $\tilde\lambda$) recovers a $C/T$ bound on the standard gap, as indicated in the problem's remark.

---

## Appendix: The infeasible-test-point case

For infeasible $\tilde w$ (i.e. $d\ne 0$), the (Key) inequality retains the extra term $\beta\langle s^{k+1},d\rangle$:
$$\widehat\Phi^{k+1}\le\mathcal E^k-\mathcal E^{k+1}-\tfrac{\beta}{2}\|s^{k+1}\|^2+\beta\langle s^{k+1},d\rangle=\mathcal E^k-\mathcal E^{k+1}-\tfrac{\beta}{2}\|s^{k+1}-d\|^2+\tfrac{\beta}{2}\|d\|^2.$$
Summing,
$$\sum_{k=0}^{T-1}\widehat\Phi^{k+1}\le\mathcal E^0+\tfrac{T\beta}{2}\|d\|^2,$$
which yields
$$\Phi(\bar w_T;\tilde w)\le\frac{1}{T}\Bigl[\tfrac{\beta}{2}\|B(\tilde z-z^0)\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^0\|^2\Bigr]+\tfrac{\beta}{2}\|d\|^2.$$
The extra $\tfrac\beta2\|d\|^2$ term is unavoidable by the direct Lagrangian method without further reorganization (as confirmed by a simple explicit calculation: taking $f=g=0$, $A=B=I$, $c=0$, $z^0=0$, $\lambda^0=-\beta$, $\tilde x=1$, $\tilde z=\tilde\lambda=0$ gives $\Phi(\bar w_T;\tilde w)=\beta/T$ but the stated bound without the $\tfrac\beta2\|d\|^2$ correction would be $\beta/(2T)$, violated as soon as $T$ is finite).

Hence the theorem's stated bound is meaningful exactly for feasible test points $(\tilde x,\tilde z)$, which is the sole setting in which the gap function corresponds to a genuine primal–dual optimality measure. The proof of the stated bound for feasible test points is complete.

$\blacksquare$

---

## Summary of the proof

1. **Optimality conditions** (Step 1) give subgradients at $x^{k+1},z^{k+1}$ involving $\lambda^{k+1}$ and the cross-term $\beta B(z^k-z^{k+1})$ from the fact that the $x$-subproblem uses the lagged $z^k$.
2. **Subgradient convexity** (Step 2) at an arbitrary test point yields a per-step linear inequality.
3. **Lagged-dual gap** (Step 3) aligns with $\bar\lambda_T$; Jensen reduces the goal to bounding $\sum_{k=0}^{T-1}\widehat\Phi^{k+1}$.
4. **Residual decomposition** (Steps 4–5) via (A-split) splits the $x$-cross-term into three pieces; crucially, the two terms linear in $d$ combine into $\beta\langle s^{k+1},d\rangle$ via the intermediate residual $s^{k+1}$.
5. **Polarization** (Step 6): (Dual-ID) and (B-pol) produce telescoping $\mathcal E^k-\mathcal E^{k+1}$ differences; (Sq) absorbs the remaining cross-terms with $r^{k+1}$ into a perfect square $-\tfrac\beta2\|s^{k+1}\|^2\le 0$.
6. **Assembly** (Step 7): (Key) per-step inequality.
7. **Telescope** (Step 8) under $d=0$ gives $\sum\widehat\Phi^{k+1}\le\mathcal E^0$.
8. **Jensen + divide by $T$** (Step 9) gives the ergodic bound.

The non-trivial identity (verification unneeded, as it is a direct algebraic consequence):
$$\langle\tilde\lambda-\lambda^{k+1},\beta r^{k+1}\rangle=\tfrac12(\|\tilde\lambda-\lambda^k\|^2-\|\tilde\lambda-\lambda^{k+1}\|^2-\|\lambda^{k+1}-\lambda^k\|^2).$$

No full-rank assumption on $A$ or $B$ is used. The Lyapunov $\mathcal E^k$ uses $\|B(\tilde z-z^k)\|^2$ as a semi-norm on the $z$-direction, which is entirely consistent with non-full-rank $B$: we only need $\mathcal E^k\ge 0$ (which is immediate).

$\blacksquare$
