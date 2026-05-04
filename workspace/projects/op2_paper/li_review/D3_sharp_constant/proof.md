# D3 — Sharper variance constant for OP-2 Lemma 2.9

**Date:** 2026-04-26
**Status:** PASS (with honest caveat: the cleanest finite-$T$ constant under (RGM) as stated is $\sqrt 2/27$, not $1/(8\sqrt 2)$)
**Improvement:** factor $\approx 5.87$ over OP-2's $1/112$

---

## Headline result

The honest sharp constant attainable by the Le Cam two-point construction with the *displayed* wall-correction term, **under the (RGM)-tight regime $\sigma = LD\sqrt{2T}$ (the worst case of the regime hypothesis used in OP-2's construction)**, is

$$
\boxed{\;c_{\mathrm{NY}}^\star \;=\; \frac{\sqrt 2}{27}\;\approx\;0.05238\;}
\qquad\text{at}\qquad c_\alpha^\star=\tfrac13.
$$

This improves the existing $1/112\approx 0.00893$ by a factor of $\approx 5.87$ but is **strictly worse** than the optimistic claim $1/(8\sqrt 2)\approx 0.0884$.

The value $1/(8\sqrt 2)$ is recovered only in the **asymptotic regime $\sigma/(LD\sqrt T)\to 0$** (i.e. (RGM) far from tight).

| (RGM) tightness $r := \sigma/(LD\sqrt T)$ | optimal $c_\alpha^\star$ | $c_{\mathrm{NY}}^\star$ (Pinsker) | factor over $1/112$ |
|---|---|---|---|
| $r\to 0$ (asymptotic, wall correction vanishes) | $1/2$ | $\sqrt 2/16=1/(8\sqrt 2)\approx 0.0884$ | $9.90$ |
| $r=1/2$ | $0.448$ | $0.0736$ | $8.24$ |
| $r=1$ | $0.385$ | $0.0609$ | $6.82$ |
| $r=\sqrt 2$ ((RGM)-tight) | $1/3$ | $\sqrt 2/27\approx 0.0524$ | $5.87$ |

**Recommendation for OP-2:** state $c_{\mathrm{NY}}=\sqrt 2/27$ as the sharp Pinsker constant under (RGM); state $c_{\mathrm{NY}}=1/(8\sqrt 2)$ as the asymptotic limit (or the constant one obtains under tighter (RGM) like $\sigma\le LD$, where it is essentially attained — see §6).

---

## 1. Setup and parametrization

Parametrize $\alpha = c_\alpha\,\sigma/\sqrt T$ with $c_\alpha\in(0,1)$ (Pinsker requires $c_\alpha < 1$ for nontrivial TV bound).

The wall radius is forced by the construction: $R = D/\sqrt 2 - \alpha/L$ (so that $|y^\star_s| = D/\sqrt 2$ exactly). Therefore the wall correction at the minimizer is

$$w(y^\star_s)=\tfrac{L}{2}\bigl(|y^\star_s|-R\bigr)^2 = \tfrac{L}{2}(\alpha/L)^2 = \alpha^2/(2L),$$

**not negligible** — it depends on $\alpha$, hence on $c_\alpha$.

Define $r := \sigma/(LD\sqrt T)\in(0,\sqrt 2]$ (the (RGM) hypothesis is $r\le\sqrt 2$). Then $\alpha/L = c_\alpha r D$ and

- $\alpha D/\sqrt 2 \;=\; (c_\alpha r/\sqrt 2)\,LD^2$,
- $\alpha^2/(2L) \;=\; (c_\alpha^2 r^2/2)\,LD^2$.

The ratio $\dfrac{\alpha^2/(2L)}{\alpha D/\sqrt 2}=\dfrac{c_\alpha r}{\sqrt 2}$, so

$$
G_s(y_T)\big|_{A_s} \;\ge\; \alpha D/\sqrt 2 \;-\;\alpha^2/(2L) \;=\; \alpha D\cdot \rho(c_\alpha,r),
\quad\text{where}\quad
\rho(c_\alpha,r) := \frac{1}{\sqrt 2}\Bigl(1-\frac{c_\alpha r}{\sqrt 2}\Bigr).
$$

This is **exact** (no inequality is loose at this step).

## 2. KL, Pinsker, and Le Cam

Per-step Gaussian KL: $\mathrm{KL}(\mathcal N(\alpha,\sigma^2)\Vert\mathcal N(-\alpha,\sigma^2)) = 2\alpha^2/\sigma^2 = 2c_\alpha^2/T$.
Total over $T$ adaptive queries (KL chain rule, as in [MOD v3-4]): $\mathrm{KL}_T = 2c_\alpha^2$.
Pinsker: $\mathrm{TV}\le \sqrt{\mathrm{KL}_T/2}=c_\alpha$ (valid for $c_\alpha\le 1$).
Le Cam: $\Pr_s[A_s]\ge (1-\mathrm{TV})/2 \ge (1-c_\alpha)/2$ for the worse $s$.

## 3. The optimization

$$
\max_s \mathbb E_s[G_s(y_T)] \;\ge\; \alpha D\cdot \rho(c_\alpha,r)\cdot \frac{1-c_\alpha}{2}
= \frac{\sigma D}{\sqrt T}\cdot\underbrace{\frac{c_\alpha(1-c_\alpha)}{2\sqrt 2}\Bigl(1-\frac{c_\alpha r}{\sqrt 2}\Bigr)}_{c_{\mathrm{NY}}(c_\alpha,r)}.
$$

Equivalently, $c_{\mathrm{NY}}(c_\alpha,r) = \dfrac{\sqrt 2}{8}\,c_\alpha(1-c_\alpha)\,(2-c_\alpha r\sqrt 2)$.

**Optimization in $c_\alpha$ at fixed $r$.** Setting $\partial_{c_\alpha}=0$ gives the cubic
$3\sqrt 2\,r\,c_\alpha^2 - (2\sqrt 2\,r + 4)c_\alpha + 2 = 0$
with root in $(0,1)$:
$$
c_\alpha^\star(r)\;=\;\frac{r+\sqrt 2 - \sqrt{r^2-\sqrt 2\,r+2}}{3r}\qquad (r > 0),\qquad c_\alpha^\star(0)=\tfrac12.
$$

**Two clean closed forms:**

- **$r=0$ (asymptotic):** $c_{\mathrm{NY}}(c_\alpha,0) = \dfrac{\sqrt 2}{4}c_\alpha(1-c_\alpha)$, maximized at $c_\alpha^\star=\tfrac12$ giving
$c_{\mathrm{NY}}^\star = \dfrac{\sqrt 2}{16} = \dfrac{1}{8\sqrt 2}\approx 0.0884$. ✓ (matches the OP-2 conjecture)

- **$r=\sqrt 2$ ((RGM)-tight):** $c_{\mathrm{NY}}(c_\alpha,\sqrt 2) = \dfrac{\sqrt 2}{4}c_\alpha(1-c_\alpha)^2$, maximized at $c_\alpha^\star=\tfrac13$ giving
$c_{\mathrm{NY}}^\star = \dfrac{\sqrt 2}{4}\cdot\tfrac13\cdot(\tfrac23)^2 = \dfrac{\sqrt 2}{27}\approx 0.0524$.

(Verified: `f'(c) = 6c²−8c+2 = 0 ⇒ c=1/3 or 1`; `f(1/3)=8/27`; `c_NY = (√2/8)·(8/27) = √2/27`.)

## 4. Hellinger vs. Pinsker

For $T$ i.i.d. samples of $\mathcal N(\pm\alpha,\sigma^2)$ the Hellinger affinity tensorizes as
$\mathrm{BC}_T = \exp(-T\alpha^2/(2\sigma^2)) = \exp(-c_\alpha^2/2)$,
so $H_T^2 = 1-\mathrm{BC}_T = 1-e^{-c_\alpha^2/2}$ and the LeCam–Yang bound
$\mathrm{TV}\le\sqrt{H_T^2(2-H_T^2)} = \sqrt{1-e^{-c_\alpha^2}}$.

| $c_\alpha$ | $\mathrm{TV}_\text{Pinsker}=c_\alpha$ | $\mathrm{TV}_\text{Hell}=\sqrt{1-e^{-c_\alpha^2}}$ |
|---|---|---|
| 0.3 | 0.3000 | 0.2934 |
| 0.5 | 0.5000 | 0.4703 |
| 0.7 | 0.7000 | 0.6224 |
| 0.9 | 0.9000 | 0.7451 |
| 1.0 | 1.0000 | 0.7951 |

Hellinger is **uniformly tighter** (strictly, for $c_\alpha>0$). Re-optimizing $c_{\mathrm{NY}}$ with Hellinger:

- $r=0$: $c_\alpha^\star\approx 0.594$, $c_{\mathrm{NY}}^\star\approx 0.0955$ (vs $1/(8\sqrt 2)=0.0884$). Factor $\approx 10.70$ over $1/112$.
- $r=\sqrt 2$: $c_\alpha^\star\approx 0.345$, $c_{\mathrm{NY}}^\star\approx 0.0531$ (vs $\sqrt 2/27=0.0524$). Factor $\approx 5.95$ over $1/112$.

Hellinger gives a $\sim 1{-}8\%$ improvement on top of Pinsker but no clean closed form. **Recommendation: keep Pinsker for the headline constant** ($\sqrt 2/27$ or $1/(8\sqrt 2)$) and remark Hellinger for marginal sharpening.

## 5. Reverse-consistency check

Plugging the **original** OP-2 choice $c_\alpha = 1/(2\sqrt 2)$ into the new chain at $r=\sqrt 2$ (RGM-tight):

- $\mathrm{TV}=1/(2\sqrt 2)\approx 0.3536$, $p_\min^\text{exact}=(1-\mathrm{TV})/2\approx 0.3232$;
- $\rho = (1/\sqrt 2)(1 - 1/2) = 1/(2\sqrt 2)$ (matching v3's "$1/\sqrt 2 - 1/4 \ge 1/(2\sqrt 2)$");
- $c_{\mathrm{NY}}^\text{exact} = c_\alpha\,\rho\,p_\min = \dfrac{(4-\sqrt 2)^2}{128}\approx 0.0522$ (no floor);
- After OP-2's $p_\min\to 1/14$ floor: $c_{\mathrm{NY}}=1/56-\sqrt 2/224 \approx 0.01154$, then further round-down to $1/112\approx 0.00893$.

So OP-2's $1/112$ stems from **two** suboptimal choices: (a) $c_\alpha=1/(2\sqrt 2)$ instead of $1/3$, (b) the $p_\min$ round-down. The new optimum at $c_\alpha=1/3$ keeps both factors in their clean exact form and gives $\sqrt 2/27$. ✓

## 6. Effect of (RGM)-tightness

The optimal $c_{\mathrm{NY}}^\star(r)$ is **monotonically decreasing in $r$** (the (RGM) ratio):

| $r$ | $c_\alpha^\star$ | $c_{\mathrm{NY}}^\star$ |
|---|---|---|
| 0 | 0.5000 | 0.0884 |
| 0.25 | 0.4759 | 0.0808 |
| 0.50 | 0.4480 | 0.0736 |
| 0.75 | 0.4172 | 0.0669 |
| 1.00 | 0.3850 | 0.0609 |
| 1.25 | 0.3532 | 0.0556 |
| $\sqrt 2$ | 0.3334 | 0.0524 |

Under tighter (RGM) hypotheses:
- $\sigma\le LD$ ⇒ $r\le 1/\sqrt T$. For any $T\ge 2$, $r\le 1/\sqrt 2$, giving $c_{\mathrm{NY}}^\star\ge 0.0707$. As $T\to\infty$, $c_{\mathrm{NY}}^\star\to 1/(8\sqrt 2)$.
- $\sigma=o(LD\sqrt T)$ ⇒ $r\to 0$, recovering $1/(8\sqrt 2)$ exactly in the limit.

So **yes**, sharpening (RGM) does improve the constant; the $1/(8\sqrt 2)$ value of OP-2's footnote is the **asymptotic limit** as the noise shrinks relative to the bias, *not* a finite-$T$ deliverable when $\sigma$ saturates the (RGM) ceiling.

## 7. Final tight Lemma 2.9'

**Lemma 2.9' (Sharpened Le Cam gap on the $y$-coordinate).** Under the same hypotheses as OP-2 Lemma 2.9, with $\alpha:=c_\alpha\,\sigma/\sqrt T$ and wall radius $R:=D/\sqrt 2 - \alpha/L$, for any $c_\alpha\in(0,1)$ such that $\alpha/L\le D/\sqrt 2$ (i.e., the wall construction is well-defined),
$$
\max_{s\in\{+,-\}}\mathbb E_s\bigl[G_s(y_T)\bigr]\;\ge\;\frac{\sigma D}{\sqrt T}\cdot \frac{\sqrt 2}{8}\,c_\alpha(1-c_\alpha)\,\Bigl(2-c_\alpha r\sqrt 2\Bigr),
\qquad r:=\frac{\sigma}{LD\sqrt T}.
$$
In particular, optimizing in $c_\alpha$:

- (asymptotic, $r\to 0$) $c_\alpha^\star=1/2$ ⇒ $c_{\mathrm{NY}}^\star = 1/(8\sqrt 2)$;
- (RGM-tight, $r=\sqrt 2$) $c_\alpha^\star=1/3$ ⇒ $c_{\mathrm{NY}}^\star = \sqrt 2/27$.

Under (RGM) $\sigma\le LD\sqrt{2T}$ (i.e. $r\le\sqrt 2$), the worst-case (over the (RGM)-allowed $r$) sharp Pinsker constant is
$$
\boxed{\;c_{\mathrm{NY}}=\sqrt 2/27\approx 0.0524\;}\qquad\text{(at $c_\alpha=1/3$).}
$$

*Proof sketch.* Identical to the existing Lemma 2.9 chain with $\alpha=\sigma/(2\sqrt{2T})$ replaced by $\alpha=c_\alpha\,\sigma/\sqrt T$ throughout, and $R$ updated accordingly. Steps 1–2 (sign-test reduction, gap formula) are formal substitutions. Step 3 (wall correction) becomes the **exact** identity
$\alpha D/\sqrt 2-\alpha^2/(2L) = \alpha D\,\rho(c_\alpha,r)$ rather than a loose $\le$; the (RGM) hypothesis enters only via the bound $r\le\sqrt 2$ to ensure $R\ge 0$. Step 4 (Pinsker + Le Cam) uses $\mathrm{TV}\le c_\alpha$, $p_\min\ge (1-c_\alpha)/2$. Step 5 multiplies and optimizes; the resulting cubic in $c_\alpha$ admits closed-form roots and at $r=\sqrt 2$ has the rational root $c_\alpha=1/3$, yielding the stated constant. $\square$

## 8. How this changes OP-2

In OP-2's main theorem statement (§0.5), replace
$$c_{\mathrm{NY}}=1/112 \quad \longrightarrow\quad c_{\mathrm{NY}}=\sqrt 2/27$$
(a factor-of-$\approx 5.87$ improvement). Sec. 2.4.1 needs:

1. Replace $\alpha:=\sigma/(2\sqrt{2T})$ by $\alpha:=\sigma/(3\sqrt T)$ (i.e., $c_\alpha=1/3$) throughout §2.1.2 (ALPHA) and §2.4.1 (Lemma 2.9, with corresponding $R=D/\sqrt 2-\sigma/(3L\sqrt T)$).
2. In Lemma 1.4, KL becomes $1/(9T)$ per step / $\mathrm{KL}_T = 2/9$, TV $\le 1/3$, $p_\min\ge 1/3$.
3. In Step 3 of the Lemma 2.9 proof, replace the loose inequality $\alpha^2/(2L)\le\alpha D/4$ by the **exact** identity $\alpha^2/(2L) = c_\alpha r/\sqrt 2 \cdot \alpha D/\sqrt 2$, then track the worst-case $r=\sqrt 2$, giving $\rho=\sqrt 2/3$ in place of $1/(2\sqrt 2)$.
4. Step 4: $(\alpha D)\cdot(\sqrt 2/3)\cdot(1/3) = \sqrt 2\,\alpha D/9 = (\sqrt 2/9)\cdot(\sigma D)/(3\sqrt T) = \sqrt 2\,\sigma D/(27\sqrt T)$, i.e. $c_{\mathrm{NY}} = \sqrt 2/27$.
5. The footnote claiming "$1/(8\sqrt 2)$ achievable" should be re-stated as: "$1/(8\sqrt 2)$ is the asymptotic limit as $\sigma/(LD\sqrt T)\to 0$; under the saturated (RGM) ceiling, the sharp Pinsker constant is $\sqrt 2/27$. Hellinger gives a further $\sim 1\%$ sharpening at $r=\sqrt 2$."
