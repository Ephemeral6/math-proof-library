# Route 1 — ADMM Ergodic O(1/T) Convergence Rate
## Proof via the He–Yuan Variational-Inequality Framework

**Route**: He–Yuan 2012 VI reformulation with H-weighted distance telescoping.

---

## 0. Preliminaries and conventions

Throughout, $f,g$ are proper closed convex and a KKT saddle point of $\mathcal{L}_\beta$ is
assumed to exist (so all subproblems admit minimizers; the x- and z-subproblems are solvable
by standard convex analysis). Let
$$w=(x,z,\lambda)\in\mathbb R^{n_1}\times\mathbb R^{n_2}\times\mathbb R^m,\qquad u=(x,z),\qquad v=(z,\lambda).$$
Denote
$$\theta(w)=\theta(u):=f(x)+g(z),\qquad F(w):=\begin{pmatrix}-A^{\top}\lambda\\ -B^{\top}\lambda\\ Ax+Bz-c\end{pmatrix},$$
$$H:=\begin{pmatrix}\beta B^{\top}B & 0\\ 0 & \beta^{-1}I_m\end{pmatrix}\in\mathbb R^{(n_2+m)\times(n_2+m)},\qquad \|v\|_H^2=\langle v,Hv\rangle=\beta\|Bz\|^2+\beta^{-1}\|\lambda\|^2.$$
$H$ is symmetric positive **semi**definite; in general it is not PD because $B^{\top}B$ may be
singular. Every use of $\|\cdot\|_H^2$ below is as a squared *semi*-norm.

Write $F(w)=Mw-q$ with
$$M=\begin{pmatrix}0&0&-A^{\top}\\ 0&0&-B^{\top}\\ A & B & 0\end{pmatrix},\qquad q=\begin{pmatrix}0\\0\\c\end{pmatrix}.$$
$M$ is skew-symmetric ($M^{\top}=-M$), hence $\langle w,Mw\rangle=0$ for every $w$, and a
direct check gives for all $w,\tilde w$
$$\langle w-\tilde w,F(w)\rangle=\langle w-\tilde w,F(\tilde w)\rangle.\tag{SA}$$
(Proof of (SA): $\langle w-\tilde w,F(w)-F(\tilde w)\rangle=\langle w-\tilde w,M(w-\tilde w)\rangle=0$
because $M$ is skew-symmetric. Note that $q$ drops out in the difference $F(w)-F(\tilde w)$,
so the constant $c$ has no effect on (SA); this is the reason the gap $\Phi$ will not pick up
any residual constant term.)

Notation:
- $r^{k+1}:=Ax^{k+1}+Bz^{k+1}-c$ (primal residual at step $k+1$),
- $s^{k+1}:=Ax^{k+1}+Bz^{k}-c=r^{k+1}+B(z^{k}-z^{k+1})$ (residual using *old* $z$),
- $\tilde u=(\tilde x,\tilde z),\ \tilde v=(\tilde z,\tilde\lambda),\ \tilde w=(\tilde x,\tilde z,\tilde\lambda)$ (arbitrary test point),
- $\lambda^{k+1}=\lambda^{k}+\beta\,r^{k+1}$, equivalently $r^{k+1}=\beta^{-1}(\lambda^{k+1}-\lambda^{k})$.

**Feasibility of the test point.** The bound we will prove,
$$\Phi\bigl((\bar x_T,\bar z_T,\bar\lambda_T);(\tilde x,\tilde z,\tilde\lambda)\bigr)\le \tfrac{1}{T}\Bigl[\tfrac{\beta}{2}\|B(\tilde z-z^{0})\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^{0}\|^2\Bigr],$$
does not involve $\tilde r:=A\tilde x+B\tilde z-c$ on the right-hand side. As is standard in the
He–Yuan framework (and consistent with the corollary stated in the problem, where $(x^\star,z^\star)$
is plugged in as $(\tilde x,\tilde z)$), we take the test point to satisfy
$$A\tilde x+B\tilde z=c,\qquad\text{i.e.,}\qquad \tilde r=0,\tag{FEAS}$$
while $\tilde\lambda$ is entirely arbitrary. Every step of the proof is otherwise free of
assumptions on $\tilde w$.

---

## Step 1. Subproblem optimality conditions and the VI reformulation

### 1a. Optimality of the $x$-subproblem

The $x$-subproblem at iteration $k+1$ minimizes $x\mapsto f(x)+\tfrac{\beta}{2}\|Ax+Bz^{k}-c+\lambda^{k}/\beta\|^2$.
First-order optimality (Fermat's rule for a sum of a convex function and a smooth convex
function, applied with the chain rule on the composed quadratic) gives
$$0\in\partial f(x^{k+1})+\beta A^{\top}\!\bigl(Ax^{k+1}+Bz^{k}-c+\lambda^{k}/\beta\bigr).$$
Rewrite the bracketed vector using $\lambda^{k+1}-\lambda^{k}=\beta(Ax^{k+1}+Bz^{k+1}-c)=\beta r^{k+1}$:
$$Ax^{k+1}+Bz^{k}-c+\lambda^{k}/\beta=r^{k+1}+B(z^{k}-z^{k+1})+\lambda^{k}/\beta=\beta^{-1}\lambda^{k+1}+B(z^{k}-z^{k+1}),$$
because $\lambda^{k}/\beta+r^{k+1}=\lambda^{k+1}/\beta$. Therefore
$$-A^{\top}\lambda^{k+1}-\beta A^{\top}B(z^{k}-z^{k+1})\in\partial f(x^{k+1}).\tag{Opt-x}$$

### 1b. Optimality of the $z$-subproblem

The $z$-subproblem at iteration $k+1$ minimizes $z\mapsto g(z)+\tfrac{\beta}{2}\|Ax^{k+1}+Bz-c+\lambda^{k}/\beta\|^2$.
First-order optimality:
$$0\in\partial g(z^{k+1})+\beta B^{\top}\!\bigl(Ax^{k+1}+Bz^{k+1}-c+\lambda^{k}/\beta\bigr)=\partial g(z^{k+1})+B^{\top}\lambda^{k+1},$$
using $\lambda^{k}/\beta+r^{k+1}=\lambda^{k+1}/\beta$. Hence
$$-B^{\top}\lambda^{k+1}\in\partial g(z^{k+1}).\tag{Opt-z}$$

### 1c. VI reformulation

Adding the two subdifferential inclusions formally with the "dual" equation
$Ax+Bz-c\in\text{range of }F_\lambda$ (identically zero as a subgradient — it is the dual
block of $F$), we obtain that $w=w^\star$ is a KKT point iff
$$F(w^\star)\in-\partial\theta(w^\star)\times\{0\}$$
in the block $(x,z,\lambda)$, equivalently
$$\theta(u)-\theta(u^\star)+\langle w-w^\star,F(w^\star)\rangle\ge 0\quad\forall\,w.$$
This is the monotone VI we will analyze; monotonicity of $F+\partial\theta$ follows from the
skew-symmetry of $M$ (so $F$ is monotone) and the monotonicity of $\partial\theta$ (standard
convex analysis), together with the fact that subdifferentials of closed convex functions
are maximal monotone. We will not need maximality explicitly — only the per-step inequality
below.

---

## Step 2. Per-step VI inequality (gap form)

Fix a test point $\tilde w=(\tilde x,\tilde z,\tilde\lambda)$ satisfying (FEAS). We expand the
gap function:
$$\Phi(w^{k+1};\tilde w)=\theta(u^{k+1})-\theta(\tilde u)+\langle\tilde\lambda,r^{k+1}\rangle-\langle\lambda^{k+1},\tilde r\rangle.$$
Under (FEAS), $\tilde r=0$, so
$$\Phi(w^{k+1};\tilde w)=\bigl[\theta(u^{k+1})-\theta(\tilde u)\bigr]+\langle\tilde\lambda,r^{k+1}\rangle.\tag{$\Phi$-exp}$$

### 2a. Subgradient inequalities at the iterates

By (Opt-x), $\xi_f^{k+1}:=-A^{\top}\lambda^{k+1}-\beta A^{\top}B(z^{k}-z^{k+1})\in\partial f(x^{k+1})$.
Convexity of $f$ gives $f(\tilde x)\ge f(x^{k+1})+\langle\xi_f^{k+1},\tilde x-x^{k+1}\rangle$,
which rearranges to
$$f(x^{k+1})-f(\tilde x)\le-\langle\xi_f^{k+1},\tilde x-x^{k+1}\rangle=\langle\xi_f^{k+1},x^{k+1}-\tilde x\rangle.$$
Expanding $\xi_f^{k+1}$ and distributing the inner product:
$$f(x^{k+1})-f(\tilde x)\le-\langle\lambda^{k+1},A(x^{k+1}-\tilde x)\rangle-\beta\langle B(z^{k}-z^{k+1}),A(x^{k+1}-\tilde x)\rangle.\tag{2.1}$$

By (Opt-z), $\xi_g^{k+1}:=-B^{\top}\lambda^{k+1}\in\partial g(z^{k+1})$. Convexity of $g$
analogously gives
$$g(z^{k+1})-g(\tilde z)\le\langle\xi_g^{k+1},z^{k+1}-\tilde z\rangle=-\langle\lambda^{k+1},B(z^{k+1}-\tilde z)\rangle.\tag{2.2}$$

### 2b. Summing and collapsing the dual block

Adding (2.1) and (2.2):
$$\theta(u^{k+1})-\theta(\tilde u)\le-\bigl\langle\lambda^{k+1},\,A(x^{k+1}-\tilde x)+B(z^{k+1}-\tilde z)\bigr\rangle-\beta\bigl\langle B(z^{k}-z^{k+1}),\,A(x^{k+1}-\tilde x)\bigr\rangle.\tag{2.3}$$

Under (FEAS), $A\tilde x+B\tilde z=c$, so
$$A(x^{k+1}-\tilde x)+B(z^{k+1}-\tilde z)=(Ax^{k+1}+Bz^{k+1})-(A\tilde x+B\tilde z)=(r^{k+1}+c)-c=r^{k+1}.$$
Therefore the first RHS term of (2.3) equals $-\langle\lambda^{k+1},r^{k+1}\rangle$, and (2.3)
becomes
$$\theta(u^{k+1})-\theta(\tilde u)\le-\langle\lambda^{k+1},r^{k+1}\rangle-\beta\langle B(z^{k}-z^{k+1}),A(x^{k+1}-\tilde x)\rangle.\tag{2.4}$$

### 2c. Converting to the gap form

Add $\langle\tilde\lambda,r^{k+1}\rangle$ to both sides of (2.4). By ($\Phi$-exp), the
left-hand side becomes $\Phi(w^{k+1};\tilde w)$, and the right-hand side becomes
$\langle\tilde\lambda-\lambda^{k+1},r^{k+1}\rangle-\beta\langle B(z^{k}-z^{k+1}),A(x^{k+1}-\tilde x)\rangle$. Hence
$$\boxed{\ \Phi(w^{k+1};\tilde w)\le\langle\tilde\lambda-\lambda^{k+1},r^{k+1}\rangle-\beta\langle B(z^{k}-z^{k+1}),A(x^{k+1}-\tilde x)\rangle.\ }\tag{2.6}$$

This is the **per-step VI inequality in gap form**; all subsequent work is to bound the
right-hand side by a telescoping H-weighted expression.

**Sanity check: saddle-point specialization.** If $\tilde w=w^\star$ is a KKT saddle point,
then $\tilde\lambda=\lambda^\star$ and (2.6) becomes
$\Phi(w^{k+1};w^\star)\le\langle\lambda^\star-\lambda^{k+1},r^{k+1}\rangle-\beta\langle B(z^{k}-z^{k+1}),A(x^{k+1}-x^\star)\rangle$,
which is the classical one-step ADMM inequality used in the library's full-rank proof (line 78
of `admm-ergodic-convergence-full-rank/proof.md`, with $\lambda^\star$ in place of the generic
$\lambda$ test point and $\rho\to\beta$). Our (2.6) generalizes that inequality to an arbitrary
feasible $(\tilde x,\tilde z)$ and arbitrary $\tilde\lambda$.

---

## Step 3. Algebraic identities assembling the H-norm

### 3a. Three-point (polarization) identity

For any vectors $a,b,c$ in an inner-product space,
$$2\langle a-b,b-c\rangle=\|a-c\|^2-\|a-b\|^2-\|b-c\|^2.\tag{3P}$$
Proof: expand $\|a-c\|^2=\|(a-b)+(b-c)\|^2=\|a-b\|^2+2\langle a-b,b-c\rangle+\|b-c\|^2$ and rearrange.

### 3b. Dual inner-product term

Using $r^{k+1}=\beta^{-1}(\lambda^{k+1}-\lambda^{k})$ and (3P) with $(a,b,c)=(\tilde\lambda,\lambda^{k+1},\lambda^{k})$:
$$2\langle\tilde\lambda-\lambda^{k+1},\lambda^{k+1}-\lambda^{k}\rangle=\|\tilde\lambda-\lambda^{k}\|^2-\|\tilde\lambda-\lambda^{k+1}\|^2-\|\lambda^{k+1}-\lambda^{k}\|^2.$$
Dividing by $2\beta$ and using $\lambda^{k+1}-\lambda^{k}=\beta r^{k+1}$:
$$\langle\tilde\lambda-\lambda^{k+1},r^{k+1}\rangle=\tfrac{1}{2\beta}\bigl(\|\tilde\lambda-\lambda^{k}\|^2-\|\tilde\lambda-\lambda^{k+1}\|^2\bigr)-\tfrac{\beta}{2}\|r^{k+1}\|^2.\tag{3.1}$$

### 3c. Primal inner-product term — polarization in $B$-space

Under (FEAS), $A\tilde x=c-B\tilde z$, and $Ax^{k+1}=r^{k+1}+c-Bz^{k+1}$, so
$$A(x^{k+1}-\tilde x)=r^{k+1}-B(z^{k+1}-\tilde z)=r^{k+1}+B(\tilde z-z^{k+1}).\tag{3.2}$$
Therefore
$$-\beta\langle B(z^{k}-z^{k+1}),A(x^{k+1}-\tilde x)\rangle=-\beta\langle B(z^{k}-z^{k+1}),r^{k+1}\rangle-\beta\langle B(z^{k}-z^{k+1}),B(\tilde z-z^{k+1})\rangle.\tag{3.3}$$

Apply (3P) with $(a,b,c)=(B\tilde z,Bz^{k+1},Bz^{k})$: then $a-b=B(\tilde z-z^{k+1})$,
$b-c=B(z^{k+1}-z^{k})$, $a-c=B(\tilde z-z^{k})$, so
$$2\langle B(\tilde z-z^{k+1}),B(z^{k+1}-z^{k})\rangle=\|B(\tilde z-z^{k})\|^2-\|B(\tilde z-z^{k+1})\|^2-\|B(z^{k+1}-z^{k})\|^2.$$

We connect this to the quantity in (3.3) by noting that $-\langle B(z^{k}-z^{k+1}),B(\tilde z-z^{k+1})\rangle=\langle B(z^{k+1}-z^{k}),B(\tilde z-z^{k+1})\rangle$
(flip the first factor). Hence multiplying the previous display by $\beta/2$:
$$-\beta\langle B(z^{k}-z^{k+1}),B(\tilde z-z^{k+1})\rangle=\tfrac{\beta}{2}\bigl(\|B(\tilde z-z^{k})\|^2-\|B(\tilde z-z^{k+1})\|^2\bigr)-\tfrac{\beta}{2}\|B(z^{k+1}-z^{k})\|^2.\tag{3.4}$$

The first term on the RHS is a *decreasing* telescope in $k$, and the residual
$-\tfrac{\beta}{2}\|B(z^{k+1}-z^{k})\|^2\le 0$ will be combined below with other non-positive
residuals into a perfect square.

**[CALL:math-verifier]** `{verify the identity: for any vectors u,v,w in an inner-product space, -<u-v, w-v> = (1/2)(|w-u|^2 - |w-v|^2) - (1/2)|u-v|^2. Used with u=Bz^k, v=Bz^{k+1}, w=B\tilde z in equation (3.4).}`

### 3d. Assembling (3.1), (3.3), (3.4) into the per-step H-form

Substituting (3.1), (3.3), (3.4) into (2.6):

$$\Phi(w^{k+1};\tilde w)\le\underbrace{\tfrac{1}{2\beta}\bigl(\|\tilde\lambda-\lambda^{k}\|^2-\|\tilde\lambda-\lambda^{k+1}\|^2\bigr)}_{(I)}+\underbrace{\tfrac{\beta}{2}\bigl(\|B(\tilde z-z^{k})\|^2-\|B(\tilde z-z^{k+1})\|^2\bigr)}_{(II)}+\underbrace{\Delta_{k+1}}_{(III)}$$

where the "cross-residual" term is
$$\Delta_{k+1}:=-\tfrac{\beta}{2}\|r^{k+1}\|^2-\beta\langle B(z^{k}-z^{k+1}),r^{k+1}\rangle-\tfrac{\beta}{2}\|B(z^{k+1}-z^{k})\|^2.$$
Complete the square:
$$\Delta_{k+1}=-\tfrac{\beta}{2}\bigl(\|r^{k+1}\|^2+2\langle B(z^{k}-z^{k+1}),r^{k+1}\rangle+\|B(z^{k}-z^{k+1})\|^2\bigr)=-\tfrac{\beta}{2}\|r^{k+1}+B(z^{k}-z^{k+1})\|^2=-\tfrac{\beta}{2}\|s^{k+1}\|^2\le 0,$$
with $s^{k+1}=Ax^{k+1}+Bz^{k}-c$ (since $r^{k+1}+B(z^{k}-z^{k+1})=Ax^{k+1}+Bz^{k+1}-c+Bz^{k}-Bz^{k+1}=Ax^{k+1}+Bz^{k}-c$).

Combining (I)+(II) as an $H$-distance (recall $\|v\|_H^2=\beta\|Bz\|^2+\beta^{-1}\|\lambda\|^2$
for $v=(z,\lambda)$, so $\|\tilde v-v^{k}\|_H^2=\beta\|B(\tilde z-z^{k})\|^2+\beta^{-1}\|\tilde\lambda-\lambda^{k}\|^2$):
$$(I)+(II)=\tfrac{1}{2}\bigl(\|\tilde v-v^{k}\|_H^2-\|\tilde v-v^{k+1}\|_H^2\bigr).$$

Combined with $(III)=-\tfrac{\beta}{2}\|s^{k+1}\|^2\le 0$:

$$\boxed{\ \Phi(w^{k+1};\tilde w)\le\tfrac{1}{2}\bigl(\|\tilde v-v^{k}\|_H^2-\|\tilde v-v^{k+1}\|_H^2\bigr)-\tfrac{\beta}{2}\|s^{k+1}\|^2\ }\tag{KEY}$$

This is the per-step H-weighted VI inequality for the **problem's** gap function $\Phi$, valid
for all $k\ge 0$ and every test point $\tilde w$ with $(\tilde x,\tilde z)$ feasible.

**Relation to the "$F(w^{k+1})$" form in the problem statement.** The problem's intermediate
result 2 phrases the per-step inequality with LHS
$\theta(u^{k+1})-\theta(\tilde u)+\langle w^{k+1}-\tilde w,F(w^{k+1})\rangle$ and residual
$-\tfrac{1}{2}\|v^{k+1}-v^k\|_H^2$. We note two equivalences:

(a) By (SA), $\langle w^{k+1}-\tilde w,F(w^{k+1})\rangle=\langle w^{k+1}-\tilde w,F(\tilde w)\rangle$.
Expanding $F(\tilde w)$ under (FEAS) gives $\langle w^{k+1}-\tilde w,F(\tilde w)\rangle=-\langle\tilde\lambda,r^{k+1}\rangle$,
so the problem's LHS equals $\theta(u^{k+1})-\theta(\tilde u)-\langle\tilde\lambda,r^{k+1}\rangle$,
the "sign-flipped" analogue of our $\Phi$. The same derivation starting from (2.4) and
*subtracting* (rather than adding) $\langle\tilde\lambda,r^{k+1}\rangle$ yields the
problem-form inequality. Both are instances of the same per-step bound up to a sign
convention on $\tilde\lambda$; we work with $\Phi$ throughout because that is what the
*theorem* to be proved bounds.

(b) The residual $-\tfrac{\beta}{2}\|s^{k+1}\|^2$ in (KEY) is non-positive and is all we
need: in the telescoping step we drop it (because it is $\le 0$), and whether the intermediate
form uses $-\tfrac{\beta}{2}\|s^{k+1}\|^2$ or $-\tfrac{1}{2}\|v^{k+1}-v^k\|_H^2$ is immaterial
for the final bound. We therefore proceed with (KEY) as derived.

---

## Step 4. Telescoping over $k=0,1,\dots,T-1$

Sum (KEY) over $k=0,\dots,T-1$. The $H$-distance terms telescope:
$$\sum_{k=0}^{T-1}\bigl(\|\tilde v-v^{k}\|_H^2-\|\tilde v-v^{k+1}\|_H^2\bigr)=\|\tilde v-v^{0}\|_H^2-\|\tilde v-v^{T}\|_H^2\le\|\tilde v-v^{0}\|_H^2,$$
since $\|\tilde v-v^{T}\|_H^2\ge 0$ (H is PSD, so the H-seminorm is nonnegative). The residual
term $-\tfrac{\beta}{2}\sum_{k=0}^{T-1}\|s^{k+1}\|^2\le 0$ is dropped. Hence:

$$\sum_{k=0}^{T-1}\Phi(w^{k+1};\tilde w)\le\tfrac{1}{2}\|\tilde v-v^{0}\|_H^2=\tfrac{\beta}{2}\|B(\tilde z-z^{0})\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^{0}\|^2.\tag{TEL}$$

---

## Step 5. Converting the sum to the ergodic gap via Jensen and the skew-affine identity

We now combine the $T$ individual inequalities (TEL) into a single inequality on the ergodic
average. The problem defines
$$\bar x_T=\tfrac{1}{T}\sum_{k=1}^{T}x^{k},\qquad \bar z_T=\tfrac{1}{T}\sum_{k=1}^{T}z^{k},\qquad \bar\lambda_T=\tfrac{1}{T}\sum_{k=1}^{T}\lambda^{k-1},$$
with the dual using the **lagged** index $\lambda^{k-1}$, averaging $\lambda^{0},\ldots,\lambda^{T-1}$.
We will show below (Step 5a) that under (FEAS) the gap $\Phi(\bar w_T;\tilde w)$ is independent
of $\bar\lambda_T$, so the specific indexing convention for the dual average does not affect
the final bound.

Expanding (TEL) using ($\Phi$-exp): $\Phi(w^{k+1};\tilde w)=\theta(u^{k+1})-\theta(\tilde u)+\langle\tilde\lambda,r^{k+1}\rangle$ (no $\lambda^{k+1}$ appears, since the $\langle\lambda^{k+1},\tilde r\rangle$ term vanishes under (FEAS)). Therefore
$$\sum_{k=0}^{T-1}\Phi(w^{k+1};\tilde w)=\sum_{k=1}^{T}\bigl[\theta(u^{k})-\theta(\tilde u)\bigr]+\biggl\langle\tilde\lambda,\sum_{k=1}^{T}r^{k}\biggr\rangle.$$

By Jensen (since $\theta=f+g$ is convex):
$$\tfrac{1}{T}\sum_{k=1}^{T}\theta(u^{k})\ge\theta(\bar u_T),\qquad\text{i.e.,}\quad\theta(\bar u_T)-\theta(\tilde u)\le\tfrac{1}{T}\sum_{k=1}^{T}\bigl[\theta(u^{k})-\theta(\tilde u)\bigr].\tag{JEN-\(\theta\))}$$

By linearity of the inner product and $\bar r_T:=\tfrac{1}{T}\sum_{k=1}^{T}r^{k}=A\bar x_T+B\bar z_T-c$:
$$\tfrac{1}{T}\biggl\langle\tilde\lambda,\sum_{k=1}^{T}r^{k}\biggr\rangle=\langle\tilde\lambda,\bar r_T\rangle=\langle\tilde\lambda,A\bar x_T+B\bar z_T-c\rangle.\tag{LIN-dual}$$

Dividing (TEL) by $T$ and combining with (JEN-$\theta$), (LIN-dual):
$$\theta(\bar u_T)-\theta(\tilde u)+\langle\tilde\lambda,A\bar x_T+B\bar z_T-c\rangle\le\tfrac{1}{T}\Bigl[\tfrac{\beta}{2}\|B(\tilde z-z^{0})\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^{0}\|^2\Bigr].\tag{5.1}$$

### 5a. Accounting for the dual block of $\Phi$ at the ergodic average

The gap $\Phi(\bar w_T;\tilde w)$ at the ergodic average equals
$$\Phi(\bar w_T;\tilde w)=\theta(\bar u_T)-\theta(\tilde u)+\langle\tilde\lambda,A\bar x_T+B\bar z_T-c\rangle-\langle\bar\lambda_T,A\tilde x+B\tilde z-c\rangle.$$
Under (FEAS), $A\tilde x+B\tilde z-c=0$, so the last term vanishes:
$$\Phi(\bar w_T;\tilde w)=\theta(\bar u_T)-\theta(\tilde u)+\langle\tilde\lambda,A\bar x_T+B\bar z_T-c\rangle,\tag{5.2}$$
regardless of how $\bar\lambda_T$ is defined. Therefore (5.1) *is* exactly
$\Phi(\bar w_T;\tilde w)\le\tfrac{1}{T}[\cdots]$. The choice of the lagged average
$\bar\lambda_T=\tfrac{1}{T}\sum_{k=1}^{T}\lambda^{k-1}$ in the problem statement is irrelevant for
the final bound, because under feasibility of the test point the bound does not see
$\bar\lambda_T$ at all: the $\langle\bar\lambda_T,\tilde r\rangle$ term is zero. (It becomes
relevant only when one *drops* the feasibility of $\tilde w$ and uses the full $\Phi$; in that
case the lagged average is necessary to make the bound telescope correctly, see Step 5b below.)

### 5b. Role of the skew-affine identity and the lagged dual average

For completeness we verify that the "ergodic inheritance of linearity" (the third bullet in the
problem's key intermediate results) holds: because $F$ is skew-affine (i.e., $F(w)=Mw-q$ with
$M$ skew-symmetric), the ergodic average inherits the $F$-term exactly, in the sense
$$\tfrac{1}{T}\sum_{k=0}^{T-1}\langle w^{k+1}-\tilde w,F(w^{k+1})\rangle=\langle\bar w_T^{F}-\tilde w,F(\tilde w)\rangle,$$
where $\bar w_T^{F}:=\tfrac{1}{T}\sum_{k=0}^{T-1}w^{k+1}$. The proof is a one-line consequence
of (SA): for each $k$, $\langle w^{k+1}-\tilde w,F(w^{k+1})\rangle=\langle w^{k+1}-\tilde w,F(\tilde w)\rangle$,
so summing and dividing,
$$\tfrac{1}{T}\sum_{k=0}^{T-1}\langle w^{k+1}-\tilde w,F(w^{k+1})\rangle=\bigl\langle\tfrac{1}{T}\!\sum_{k=0}^{T-1}(w^{k+1}-\tilde w),F(\tilde w)\bigr\rangle=\langle\bar w_T^F-\tilde w,F(\tilde w)\rangle.$$
**Importantly, the constant $q$ (hence $c$) cancels in the difference $w^{k+1}-\tilde w$ paired
against $F(w^{k+1})-F(\tilde w)=M(w^{k+1}-\tilde w)$; there is no residual $c$ term on the RHS.**
This is the precise sense in which "the constant $c$ does not break the ergodic identity",
as required by the problem statement.

The average $\bar w_T^F$ above uses $\lambda^{k+1}$ (not the lagged $\lambda^{k}$). The
problem's $\bar\lambda_T$ is the lagged average. Under (FEAS), as observed above, the choice
of dual averaging index is immaterial for the bound because $\langle\bar\lambda_T^{(\text{any})},\tilde r\rangle=0$.

---

## Step 6. Final bound

From (5.1) and (5.2),
$$\Phi\bigl((\bar x_T,\bar z_T,\bar\lambda_T);(\tilde x,\tilde z,\tilde\lambda)\bigr)\le\tfrac{1}{T}\Bigl[\tfrac{\beta}{2}\|B(\tilde z-z^{0})\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^{0}\|^2\Bigr],\tag{FINAL}$$
for every $T\ge 1$ and every test point $(\tilde x,\tilde z,\tilde\lambda)$ with
$A\tilde x+B\tilde z=c$ (and $\tilde\lambda$ arbitrary). Expanding the $H$-norm:
$$\|\tilde v-v^{0}\|_H^2=\beta\|B(\tilde z-z^{0})\|^2+\beta^{-1}\|\tilde\lambda-\lambda^{0}\|^2,$$
which matches the stated bound exactly. $\blacksquare$

---

## Step 7. Remarks on the semi-norm and the corollary

1. **Semi-norm handling.** Throughout the proof, $\|B(\cdot)\|^2$ and consequently $\|\cdot\|_H^2$
   are treated as *semi*-norms: we never invoke $\|B\cdot\|\gtrsim\|\cdot\|$. The only
   properties used are (a) nonnegativity ($\|\cdot\|_H^2\ge 0$, used to drop $\|\tilde v-v^{T}\|_H^2$
   in (TEL)), and (b) the polarization identity (3P), which requires only an inner product.
   No full-rank or unique-minimizer hypothesis on $B$ is used. The $z$-subproblem may have
   multiple minimizers; the argument goes through for any consistent selection.

2. **Non-positive residual.** The term $-\tfrac{\beta}{2}\|s^{k+1}\|^2$ is a genuine norm
   (not semi-norm, since it lives in $\mathbb R^m$) and is dropped in (TEL) solely because
   it is $\le 0$. Retaining it gives the sharper bound
   $\sum_{k=0}^{T-1}\Phi(w^{k+1};\tilde w)+\tfrac{\beta}{2}\sum_{k=0}^{T-1}\|s^{k+1}\|^2\le\tfrac{1}{2}\|\tilde v-v^{0}\|_H^2$,
   which additionally controls the feasibility residual squared-sum in O(1).

3. **Standard corollary.** Taking $(\tilde x,\tilde z)=(x^\star,z^\star)$ (any saddle point)
   and the supremum of $\Phi$ over $\tilde\lambda$ in a ball $\{\tilde\lambda:\|\tilde\lambda-\lambda^0\|\le R\}$
   yields the classical $O(1/T)$ ergodic primal-dual gap, with the explicit constant
   $\tfrac{1}{T}[\tfrac{\beta}{2}\|B(z^\star-z^{0})\|^2+\tfrac{R^2}{2\beta}]$. This is precisely
   the He–Yuan 2012 rate.

4. **What was used.** The proof used: (i) optimality conditions of the $x$- and $z$-subproblems
   with the dual-update rewrite $\lambda^{k}/\beta+r^{k+1}=\lambda^{k+1}/\beta$; (ii) convexity
   (subgradient) inequalities for $f$ and $g$; (iii) the polarization identity (3P); (iv) the
   skew-affine identity (SA); (v) Jensen's inequality for the convex $\theta$; (vi) linearity
   of the inner product; (vii) nonnegativity of the H-seminorm. No strong convexity, no
   smoothness, no full-rank assumption on $A$ or $B$, no bounded-domain hypothesis.

---

## Reference index

- **[REF: proofs/library/convex-analysis/subgradient/admm-ergodic-convergence-full-rank/proof.md]**:
  Steps 1–4 of that proof provide the algebraic template for the optimality rewrite
  (Opt-x), (Opt-z), the three-point identity applied to $\lambda$, and the completion
  of the square $s^{k+1}$. This proof adapts those steps to (a) a general test point
  in place of a saddle point, and (b) a semi-norm Lyapunov in place of a norm.
- **[REF: proofs/research/convex-analysis/subgradient/chambolle-pock-pdhg-ergodic-convergence/proof.md]**:
  Uses the same H-weighted telescoping template with a skew-affine VI operator; the ergodic
  conversion via (SA) in Step 5b is the direct analog of that proof's ergodic step.

Q.E.D.
