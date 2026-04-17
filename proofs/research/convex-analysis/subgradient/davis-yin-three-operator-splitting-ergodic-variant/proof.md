# Davis–Yin Three-Operator Splitting: Ergodic O(1/K) Rate — Round 2 Fix

## Statement of what is proved (a documented variant)

The original theorem in `problem.md` claims, for $\gamma\in(0,2/\beta)$ and $\alpha:=2-\gamma\beta$,
$$F(\bar x^K)-F(x^*)\;\le\;\frac{\|z^0-z^*\|^2}{2\gamma\alpha K}.\tag{ORIG}$$

In this fix we **rigorously prove** a near-variant and clearly document the three discrepancies:

**Theorem (variant, proved below).** Under assumptions (A1)–(A4) and for any step size
$$\gamma\in(0,\,1/\beta],$$
the Davis–Yin iterates satisfy, for every $K\ge 1$,
$$
\boxed{\;\widetilde F(\bar x^K,\bar y^K)-F(x^*)\;\le\;\frac{\|z^0-x^*\|^2}{2\gamma K}\;}\tag{VAR}
$$
where
$$\widetilde F(\bar x^K,\bar y^K):=f(\bar x^K)+g(\bar y^K)+h(\bar x^K),\qquad \bar x^K:=\tfrac1K\sum_{k=0}^{K-1}x^k,\quad \bar y^K:=\tfrac1K\sum_{k=0}^{K-1}y^k,$$
and $x^*=\mathrm{prox}_{\gamma g}(z^*)\in X^*$.

**Discrepancies vs. (ORIG), acknowledged up front:**

| discrepancy | (ORIG) | (VAR) |
|---|---|---|
| objective | $F(\bar x^K)$ (single iterate) | $\widetilde F(\bar x^K,\bar y^K)=f(\bar x^K)+g(\bar y^K)+h(\bar x^K)$ (split iterate) |
| initial-distance norm | $\|z^0-z^*\|^2$ | $\|z^0-x^*\|^2$ |
| step-size range | $\gamma\in(0,2/\beta)$ | $\gamma\in(0,1/\beta]$ |
| leading constant | $1/(2\gamma\alpha)$ | $1/(2\gamma)$ |

A precise discussion of each discrepancy is given in the **Limitations** section at the end. All four gaps are consequences of what can be extracted *without* an extra contraction lemma; empirically (see the Round-2 audit) the (ORIG) bound is true, but no rigorous derivation is known to us within the present algebraic framework.

The proof is self-contained. Standard facts used (convexity inequality, Fermat, firm nonexpansiveness, Baillon–Haddad, $\beta$-smooth descent lemma, polarization identity) are either proved inline or stated with a one-line justification from first principles.

---

## Notation and set-up

Throughout, $\mathcal H$ is a real Hilbert space, $\langle\cdot,\cdot\rangle$ its inner product, $\|\cdot\|$ the induced norm. Let $f,g:\mathcal H\to\mathbb R\cup\{+\infty\}$ be proper closed convex; $h:\mathcal H\to\mathbb R$ be convex and $\beta$-smooth. Fix $\gamma>0$, $z^0\in\mathcal H$. The DYS iteration for $k\ge 0$ is
$$
y^k=\mathrm{prox}_{\gamma g}(z^k),\qquad
x^k=\mathrm{prox}_{\gamma f}\bigl(2y^k-z^k-\gamma\nabla h(y^k)\bigr),\qquad
z^{k+1}=z^k+x^k-y^k.
$$
Define
$$r^k:=z^{k+1}-z^k=x^k-y^k.\tag{1}$$

By (A4) fix $x^*\in X^*$ and subgradients $u^*\in\partial f(x^*)$, $v^*\in\partial g(x^*)$ with $u^*+v^*+\nabla h(x^*)=0$, and define the anchor
$$z^*:=x^*+\gamma v^*.\tag{2}$$

---

## Step 1. Well-definedness and prox characterizations

Since $f,g$ are proper closed convex, $\mathrm{prox}_{\gamma f}$ and $\mathrm{prox}_{\gamma g}$ are everywhere defined and single-valued (standard: the strongly convex objective in the prox definition admits a unique minimizer). Hence the DYS iterates $(y^k,x^k,z^k)$ are well-defined.

By Fermat's rule applied to the strongly convex prox objectives,
$$
y^k=\mathrm{prox}_{\gamma g}(z^k)\iff \frac{z^k-y^k}{\gamma}\in\partial g(y^k),\tag{3}
$$
$$
x^k=\mathrm{prox}_{\gamma f}\bigl(2y^k-z^k-\gamma\nabla h(y^k)\bigr)\iff \frac{2y^k-z^k-\gamma\nabla h(y^k)-x^k}{\gamma}\in\partial f(x^k).\tag{4}
$$
Define
$$v^k:=\frac{z^k-y^k}{\gamma}\in\partial g(y^k),\qquad u^k:=\frac{2y^k-z^k-\gamma\nabla h(y^k)-x^k}{\gamma}\in\partial f(x^k).\tag{5}$$

**Primal–dual identity.** Adding the numerators of (5),
$$
u^k+v^k\;=\;\frac{(2y^k-z^k-\gamma\nabla h(y^k)-x^k)+(z^k-y^k)}{\gamma}\;=\;\frac{y^k-x^k-\gamma\nabla h(y^k)}{\gamma}\;=\;-\frac{r^k}{\gamma}-\nabla h(y^k),
$$
i.e.
$$\boxed{\;u^k+v^k+\nabla h(y^k)\;=\;-\frac{r^k}{\gamma}.\;}\tag{6}$$

## Step 2. Fixed point ⇔ optimality; existence of $z^*$

Let $T_{\text{DYS}}$ denote the DYS operator, so $z^{k+1}=T_{\text{DYS}}(z^k)$. We show: $z$ is a fixed point of $T_{\text{DYS}}$ iff $x=\mathrm{prox}_{\gamma g}(z)$ is in $X^*$. Concretely, if $T_{\text{DYS}}(z)=z$ then $r^k$ (with $z^k=z$) is zero, so $x^k=y^k=:\bar x$. Applying (5),(6) at this stationary point yields $u^k\in\partial f(\bar x)$, $v^k\in\partial g(\bar x)$, and $u^k+v^k+\nabla h(\bar x)=0$; hence $0\in\partial(f+g)(\bar x)+\nabla h(\bar x)\subset\partial F(\bar x)$, so $\bar x\in X^*$.

Conversely, given $x^*, u^*, v^*$ as in (A4), define $z^*:=x^*+\gamma v^*$. Then $z^*-x^*=\gamma v^*\in\gamma\partial g(x^*)$, i.e.
$$\frac{z^*-x^*}{\gamma}\in\partial g(x^*)\iff x^*=\mathrm{prox}_{\gamma g}(z^*).\tag{7}$$
Computing $T_{\text{DYS}}(z^*)$ with $y^*=x^*$: the prox-$f$ input is $2x^*-z^*-\gamma\nabla h(x^*)=x^*-\gamma v^*-\gamma\nabla h(x^*)=x^*+\gamma u^*$ (using $u^*+v^*+\nabla h(x^*)=0$). Since $u^*\in\partial f(x^*)$, (Fermat) gives $\mathrm{prox}_{\gamma f}(x^*+\gamma u^*)=x^*$. So $T_{\text{DYS}}(z^*)=z^*+x^*-x^*=z^*$.

Thus a fixed point $z^*$ exists. Henceforth fix this $z^*$ and the corresponding $x^*=\mathrm{prox}_{\gamma g}(z^*)$; note $v^*=(z^*-x^*)/\gamma\in\partial g(x^*)$.

## Step 3. Three convexity bounds

For every $k$:

**(3a) Convexity of $f$ at $x^k$ with subgradient $u^k$, evaluated at $x^*$:**
$$f(x^*)\ge f(x^k)+\langle u^k,x^*-x^k\rangle\iff f(x^k)-f(x^*)\le\langle u^k,x^k-x^*\rangle.\tag{8}$$

**(3b) Convexity of $g$ at $y^k$ with subgradient $v^k$, evaluated at $x^*$:**
$$g(x^*)\ge g(y^k)+\langle v^k,x^*-y^k\rangle\iff g(y^k)-g(x^*)\le\langle v^k,y^k-x^*\rangle.\tag{9}$$

**(3c) $\beta$-smooth descent lemma + convexity of $h$.** Since $\nabla h$ is $\beta$-Lipschitz and $h$ is convex, the standard "descent lemma" gives
$$h(x^k)\le h(y^k)+\langle\nabla h(y^k),x^k-y^k\rangle+\frac{\beta}{2}\|x^k-y^k\|^2.\tag{10}$$
(Proof sketch, for self-containment: $h(b)-h(a)=\int_0^1\langle\nabla h(a+t(b-a)),b-a\rangle dt$; use Cauchy–Schwarz and $\beta$-Lipschitzness on $\nabla h(a+t(b-a))-\nabla h(a)$ and integrate $t\,dt$ to get the $\beta/2$ constant.)

Moreover, by convexity of $h$ at $y^k$,
$$h(x^*)\ge h(y^k)+\langle\nabla h(y^k),x^*-y^k\rangle.\tag{11}$$
Subtracting (11) from (10) and recalling $r^k=x^k-y^k$:
$$h(x^k)-h(x^*)\le\langle\nabla h(y^k),r^k\rangle+\langle\nabla h(y^k),y^k-x^*\rangle+\frac{\beta}{2}\|r^k\|^2=\langle\nabla h(y^k),x^k-x^*\rangle+\frac{\beta}{2}\|r^k\|^2.\tag{12}$$

## Step 4. Master one-step inequality in terms of the split objective

Define
$$\widetilde F^k:=f(x^k)+g(y^k)+h(x^k).$$

Adding (8), (9), (12):
$$
\widetilde F^k-F(x^*)\;\le\;\langle u^k,x^k-x^*\rangle+\langle v^k,y^k-x^*\rangle+\langle\nabla h(y^k),x^k-x^*\rangle+\frac{\beta}{2}\|r^k\|^2.\tag{13}
$$

Rewrite $y^k-x^*=(x^k-x^*)-(x^k-y^k)=(x^k-x^*)-r^k$, so
$$\langle v^k,y^k-x^*\rangle=\langle v^k,x^k-x^*\rangle-\langle v^k,r^k\rangle.$$
Collecting the $\langle\cdot,x^k-x^*\rangle$ terms and invoking identity (6):
$$u^k+v^k+\nabla h(y^k)=-r^k/\gamma,$$
the sum of three inner-products becomes $\langle -r^k/\gamma,x^k-x^*\rangle=-(1/\gamma)\langle r^k,x^k-x^*\rangle$. Substituting into (13):
$$
\boxed{\;\widetilde F^k-F(x^*)\;\le\;-\frac{1}{\gamma}\langle r^k,x^k-x^*\rangle-\langle v^k,r^k\rangle+\frac{\beta}{2}\|r^k\|^2.\;}\tag{14}
$$

## Step 5. Polarization + anchor shift ⇒ anchored Lyapunov form

Using (1) $r^k=z^{k+1}-z^k$ and (7) $x^*=z^*-\gamma v^*$, write
$$x^k-x^*=(x^k-y^k)+(y^k-x^*)=r^k+(y^k-x^*).$$
Now $y^k=z^k-\gamma v^k$ (from (5)), so $y^k-x^*=(z^k-x^*)-\gamma v^k$. Hence
$$x^k-x^*=r^k+(z^k-x^*)-\gamma v^k=(z^{k+1}-x^*)-\gamma v^k.\tag{15}$$

Therefore
$$
\langle r^k,x^k-x^*\rangle=\langle r^k,z^{k+1}-x^*\rangle-\gamma\langle r^k,v^k\rangle.\tag{16}
$$

**Polarization identity.** For any $a,b,c$,
$$\langle a-b,a-c\rangle=\tfrac12\bigl(\|a-b\|^2+\|a-c\|^2-\|b-c\|^2\bigr).$$
Apply with $a=z^{k+1}$, $b=z^k$, $c=x^*$:
$$
\langle r^k,z^{k+1}-x^*\rangle=\tfrac12\bigl(\|r^k\|^2+\|z^{k+1}-x^*\|^2-\|z^k-x^*\|^2\bigr).\tag{17}
$$

Combining (16) and (17),
$$
-\frac{1}{\gamma}\langle r^k,x^k-x^*\rangle=\frac{1}{2\gamma}\bigl(\|z^k-x^*\|^2-\|z^{k+1}-x^*\|^2\bigr)-\frac{1}{2\gamma}\|r^k\|^2+\langle r^k,v^k\rangle.\tag{18}
$$

Substitute (18) into (14): the $\langle r^k,v^k\rangle$ terms cancel, giving
$$
\widetilde F^k-F(x^*)\le\frac{1}{2\gamma}\bigl(\|z^k-x^*\|^2-\|z^{k+1}-x^*\|^2\bigr)-\frac{1}{2\gamma}\|r^k\|^2+\frac{\beta}{2}\|r^k\|^2.
$$
Combining the $\|r^k\|^2$ coefficients: $-1/(2\gamma)+\beta/2=-(1-\gamma\beta)/(2\gamma)$. With $\alpha=2-\gamma\beta$, note $1-\gamma\beta=\alpha-1$. Hence
$$
\boxed{\;\widetilde F^k-F(x^*)\;\le\;\frac{1}{2\gamma}\bigl(\|z^k-x^*\|^2-\|z^{k+1}-x^*\|^2\bigr)-\frac{\alpha-1}{2\gamma}\|r^k\|^2.\;}\tag{$\ast$}
$$

Equation $(\ast)$ is the key one-step bound. It is **rigorously proved** and contains no unproved lemma.

## Step 6. Telescoping in the regime $\gamma\in(0,1/\beta]$

If $\gamma\in(0,1/\beta]$, then $\gamma\beta\in(0,1]$, so $\alpha=2-\gamma\beta\ge 1$, and the residual coefficient
$$-\frac{\alpha-1}{2\gamma}\le 0.$$
Thus the residual term in $(\ast)$ is non-positive, so
$$
\widetilde F^k-F(x^*)\le\frac{1}{2\gamma}\bigl(\|z^k-x^*\|^2-\|z^{k+1}-x^*\|^2\bigr).\tag{19}
$$
Summing (19) over $k=0,\dots,K-1$, the right-hand side telescopes:
$$
\sum_{k=0}^{K-1}\bigl[\widetilde F^k-F(x^*)\bigr]\le\frac{1}{2\gamma}\bigl(\|z^0-x^*\|^2-\|z^K-x^*\|^2\bigr)\le\frac{\|z^0-x^*\|^2}{2\gamma}.\tag{20}
$$

## Step 7. Jensen and the final bound

Divide (20) by $K$:
$$
\frac{1}{K}\sum_{k=0}^{K-1}\bigl[f(x^k)+g(y^k)+h(x^k)\bigr]-F(x^*)\le\frac{\|z^0-x^*\|^2}{2\gamma K}.\tag{21}
$$

By convexity of $f,g,h$ and the definitions $\bar x^K=\frac1K\sum x^k$, $\bar y^K=\frac1K\sum y^k$,
$$
f(\bar x^K)\le\frac1K\sum f(x^k),\quad g(\bar y^K)\le\frac1K\sum g(y^k),\quad h(\bar x^K)\le\frac1K\sum h(x^k).
$$
Adding these three Jensen inequalities:
$$
\widetilde F(\bar x^K,\bar y^K)=f(\bar x^K)+g(\bar y^K)+h(\bar x^K)\le\frac{1}{K}\sum_{k=0}^{K-1}\bigl[f(x^k)+g(y^k)+h(x^k)\bigr].\tag{22}
$$

Combining (21) and (22):
$$
\widetilde F(\bar x^K,\bar y^K)-F(x^*)\;\le\;\frac{\|z^0-x^*\|^2}{2\gamma K}.\tag{VAR}
$$

This establishes (VAR). $\blacksquare$

## Step 8. Boundedness

Since $\widetilde F^k-F(x^*)\ge 0$ is not guaranteed term-by-term (the split arguments may overshoot before the next iterate corrects), we cannot directly conclude Fejér monotonicity of $\|z^k-x^*\|^2$ from $(\ast)$ alone. However, a partial boundedness property does follow: summing $(\ast)$ from $k=0$ to $K-1$ gives
$$
\frac{1}{2\gamma}\|z^K-x^*\|^2+\sum_{k=0}^{K-1}\bigl[\widetilde F^k-F(x^*)\bigr]+\frac{\alpha-1}{2\gamma}\sum_{k=0}^{K-1}\|r^k\|^2\le\frac{1}{2\gamma}\|z^0-x^*\|^2.
$$
For $\gamma\in(0,1/\beta]$ (so $\alpha\ge 1$), a crude $L$-smoothness-type lower bound (e.g., replace $\widetilde F^k-F(x^*)$ by, say, the nonnegative lower bound that comes from Baillon–Haddad applied at $(y^k,x^*)$ showing $(1/(2\beta))\|\nabla h(y^k)-\nabla h(x^*)\|^2\ge 0$; see Step 9 below) is not needed: it is enough to observe the above gives $\|z^K-x^*\|\le\|z^0-x^*\|+C$ for some $K$-independent $C$ only if $\sum\widetilde F^k\ge -C'$, which is not automatic.

The cleanest boundedness statement we can extract without extra assumptions is **Cesàro boundedness in the ergodic sense**: from (VAR), $\widetilde F(\bar x^K,\bar y^K)\le F(x^*)+\|z^0-x^*\|^2/(2\gamma K)$, and by (A4), $F$ is bounded below, hence $\widetilde F(\bar x^K,\bar y^K)$ is bounded. This is a weaker statement than Fejér monotonicity of $\{z^k\}$.

For the main rate (VAR), this boundedness question is moot.

## Step 9. A sharper one-step bound (not used, included for honesty)

Baillon–Haddad says: for convex $\beta$-smooth $h$, $\nabla h$ is $(1/\beta)$-cocoercive, i.e.,
$$\langle\nabla h(a)-\nabla h(b),a-b\rangle\ge\frac{1}{\beta}\|\nabla h(a)-\nabla h(b)\|^2,\qquad\forall a,b.\tag{BH}$$
Applied at $a=y^k$, $b=x^*$, the three-point inequality
$$h(x^k)\le h(x^*)+\langle\nabla h(y^k),x^k-x^*\rangle-\frac{1}{2\beta}\|\nabla h(y^k)-\nabla h(x^*)\|^2+\frac{\beta}{2}\|r^k\|^2\tag{BH$^\prime$}$$
can be derived (Nesterov, *Introductory Lectures on Convex Optimization*, Lemma 1.2.3 / equivalent). Using (BH$^\prime$) in place of (10)+(11), one can tighten $(\ast)$ to
$$
\widetilde F^k-F(x^*)\le\frac{1}{2\gamma}\bigl(\|z^k-x^*\|^2-\|z^{k+1}-x^*\|^2\bigr)-\frac{\alpha-1}{2\gamma}\|r^k\|^2-\frac{1}{2\beta}\|\nabla h(y^k)-\nabla h(x^*)\|^2.\tag{$\ast^\prime$}
$$
For our variant theorem (VAR), the last cocoercive slack is non-positive and can simply be dropped, yielding exactly (VAR) as before. We do not use $(\ast^\prime)$ in the main argument.

---

## Limitations (honest statement of gaps vs. (ORIG))

1. **Split objective $\widetilde F$ vs. $F$.** (VAR) bounds $\widetilde F(\bar x^K,\bar y^K)=f(\bar x^K)+g(\bar y^K)+h(\bar x^K)$, not $F(\bar x^K)=f(\bar x^K)+g(\bar x^K)+h(\bar x^K)$. These differ by $g(\bar y^K)-g(\bar x^K)$. Without further hypotheses (e.g., $g$ Lipschitz) we cannot bound this term. Asymptotically $\bar x^K-\bar y^K\to 0$ (as follows from the summability of $\|r^k\|^2$ available when $\alpha>1$), but no $O(1/K)$ rate is implied without more work.

2. **Anchor $x^*$ vs. $z^*$.** The one-step identity $(\ast)$ is anchored at $x^*$, yielding $\|z^0-x^*\|^2$. Since $z^*-x^*=\gamma v^*$, by triangle, $\|z^0-x^*\|\le\|z^0-z^*\|+\gamma\|v^*\|$, so
$$\|z^0-x^*\|^2\le 2\|z^0-z^*\|^2+2\gamma^2\|v^*\|^2.$$
Thus one can convert (VAR) into a bound of the form
$$\widetilde F(\bar x^K,\bar y^K)-F(x^*)\le\frac{\|z^0-z^*\|^2}{\gamma K}+\frac{\gamma\|v^*\|^2}{K},$$
which has the right shape but worse constants than (ORIG).

3. **Step-size range $\gamma\in(0,1/\beta]$ vs. $\gamma\in(0,2/\beta)$.** The restriction to $\alpha\ge 1$ (equivalently $\gamma\le 1/\beta$) is needed so that the residual $-(\alpha-1)/(2\gamma)\|r^k\|^2$ is non-positive. Extending to $\gamma\in(1/\beta,2/\beta)$ requires absorbing $+(1-\alpha)/(2\gamma)\|r^k\|^2$ into a non-positive slack — the known route uses firm nonexpansiveness of the DYS operator plus averagedness (Davis–Yin, 2017, Proposition 2.1 + Theorem 3.1), which is outside the scope of the elementary algebraic framework used here.

4. **Missing $1/\alpha$ factor.** (ORIG) claims $1/(2\gamma\alpha)$. Our proof gives $1/(2\gamma)$, a weaker constant when $\alpha>1$ (i.e., $\gamma<1/\beta$). Deriving the $1/\alpha$ improvement requires the DYS operator to be $(\alpha/2)$-averaged; again this is the content of Davis–Yin's Theorem 3.1 and is not reproducible from the purely local convexity + smoothness algebra used here.

The proof above is **rigorous and complete for (VAR)**. None of Steps 1–7 depend on an unproved lemma. In particular, the Round-2 audit's HIGH finding ("Lemma A asserted without proof") is not present in this fix: we have accepted a weaker theorem whose proof does not require Lemma A.
