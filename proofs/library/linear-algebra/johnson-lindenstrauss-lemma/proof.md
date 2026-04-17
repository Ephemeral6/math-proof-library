# Johnson-Lindenstrauss Lemma — Proof

**Construction.** Let $A \in \mathbb{R}^{k \times d}$ have i.i.d. $N(0,1)$ entries. Define $f(x) = \frac{1}{\sqrt{k}} A x$.

---

## Step 1: Reduction to χ² concentration

For any $u, v \in X$, write $w = u - v$ and $x = w/\|w\|$. Then:

$$\|f(u)-f(v)\|^2 = \|u-v\|^2 \cdot \frac{\|Ax\|^2}{k}.$$

By Gaussian rotational invariance, $(Ax)_i \sim N(0,1)$ i.i.d., so $Y := \|Ax\|^2 \sim \chi^2(k)$.

The JL condition reduces to $|Y/k - 1| \le \varepsilon$.

## Step 2: MGF of χ²(k)

$$\mathbb{E}[e^{tY}] = (1-2t)^{-k/2}, \quad t < 1/2.$$

## Step 3: Upper tail

By Chernoff with optimal $t^* = \varepsilon/(2(1+\varepsilon))$:

$$\Pr[Y \ge k(1+\varepsilon)] \le [(1+\varepsilon)e^{-\varepsilon}]^{k/2}.$$

Using $\ln(1+\varepsilon) - \varepsilon \le -\varepsilon^2/6$ for $0 < \varepsilon < 1$:

$$\Pr[Y \ge k(1+\varepsilon)] \le e^{-k\varepsilon^2/12}.$$

## Step 4: Lower tail

By Chernoff with optimal $\mu^* = \varepsilon/(2(1-\varepsilon))$:

$$\Pr[Y \le k(1-\varepsilon)] \le [(1-\varepsilon)e^{\varepsilon}]^{k/2}.$$

Using $\ln(1-\varepsilon) + \varepsilon \le -\varepsilon^2/2$:

$$\Pr[Y \le k(1-\varepsilon)] \le e^{-k\varepsilon^2/4}.$$

## Step 5: Union bound

$$\Pr\left[\left|\frac{Y}{k} - 1\right| > \varepsilon\right] \le 2e^{-k\varepsilon^2/12}.$$

Over $\binom{n}{2} \le n^2/2$ pairs, total failure probability $\le n^2 e^{-k\varepsilon^2/12}$.

Setting this $\le 1/n$ gives $k \ge 36\ln n / \varepsilon^2$.

## Conclusion

With $k = \lceil 36\ln n / \varepsilon^2 \rceil = O(\log n / \varepsilon^2)$, the random projection $f(x) = \frac{1}{\sqrt{k}}Ax$ preserves all pairwise distances within factor $(1 \pm \varepsilon)$ with probability $\ge 1 - 1/n$. $\blacksquare$
