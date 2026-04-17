# Best Proof: Random Matrix Concentration (Sub-Gaussian Rows)

**Route**: ε-Net + Sub-Exponential Bernstein (Two-Regime Analysis)

## Theorem
Let $a_1,\ldots,a_n \in \mathbb{R}^d$ be independent sub-Gaussian rows with parameter $K$ and covariance $\Sigma$. Then with probability $\geq 1-2\exp(-ct^2)$:
$$\left\|\frac{1}{n}A^TA - \Sigma\right\| \leq K^2 \max(\delta, \delta^2), \quad \delta = C\!\left(\sqrt{\frac{d}{n}} + \frac{t}{\sqrt{n}}\right).$$

## Proof

**Step 1: Net reduction.** Construct a $1/4$-net $\mathcal{N}$ on $S^{d-1}$ with $|\mathcal{N}| \leq 9^d$. For symmetric $M$: $\|M\| \leq 2 \sup_{u \in \mathcal{N}} |u^T M u|$.

**Step 2: Sub-exponential structure.** Fix $u \in S^{d-1}$. The summands $X_i = (u^T a_i)^2 - \mathbb{E}(u^T a_i)^2$ are iid, mean-zero, sub-exponential with $\psi_1$-norm $\leq CK^2$.

**Step 3: Two-regime Bernstein.** For $s > 0$:
$$P\!\left(\left|\frac{1}{n}\sum_i X_i\right| \geq s\right) \leq 2\exp\!\left(-cn\min\!\left(\frac{s^2}{K^4}, \frac{s}{K^2}\right)\right).$$

Set $\delta_0 = C_0(\sqrt{d/n} + t/\sqrt{n})$, $s = K^2\max(\delta_0, \delta_0^2)$.

- **Small deviation** ($\delta_0 \leq 1$): $s = K^2\delta_0^2$, Bernstein uses $s^2/K^4 = \delta_0^4$ branch... actually $s = K^2\delta_0$, uses $s^2/K^4 = \delta_0^2$ branch: $n\delta_0^2 = C_0^2(\sqrt{d}+t)^2 \geq C_0^2(d+t^2)$.
- **Large deviation** ($\delta_0 > 1$): $s = K^2\delta_0^2$, uses $s/K^2 = \delta_0^2$ branch: $n\delta_0^2 \geq C_0^2(d+t^2)$.

In both cases: exponent $\geq c'(d + t^2)$.

**Step 4: Union bound.** Over $|\mathcal{N}| \leq 9^d$ points:
$$9^d \cdot 2\exp(-c'(d+t^2)) = 2\exp(d\log 9 - c'(d+t^2)) \leq 2\exp(-c''t^2)$$
for $C_0$ large enough to absorb $d\log 9$ into $c'd$.

**Step 5: Combine.** $\|M\| \leq 2 \sup_{\mathcal{N}} |u^T M u| \leq 2K^2\max(\delta_0,\delta_0^2)$. Absorb factor 2 into $C$.

$$\boxed{\left\|\frac{1}{n}A^TA - \Sigma\right\| \leq K^2\max(\delta, \delta^2), \quad \delta = C\!\left(\sqrt{\frac{d}{n}} + \frac{t}{\sqrt{n}}\right)}$$

with probability $\geq 1 - 2\exp(-ct^2)$. **Q.E.D.**
