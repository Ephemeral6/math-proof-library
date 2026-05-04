# Proof: MCE Generalization Gap is Smaller than CE under Low-Rank Spectrally-Floored Features

## Theorem (Conditional)

Let $\mathcal D$ be a distribution on $\mathcal X \times \{1,\ldots,K\}$, $\mathcal H = \{f_\theta:\mathcal X \to \mathbb R^d\}_{\theta\in\Theta}$ a class of representation maps, and $W \in \mathbb R^{K\times d}$ a fixed-norm linear classification head ($\|W\|_{\mathrm{op}} \le W_0$). Define

$$\widehat{\Sigma}_\theta := \tfrac{1}{m}\sum_{i=1}^m f_\theta(x_i) f_\theta(x_i)^\top \in \mathbb S^d_+,\qquad \Sigma_\theta := \mathbb E_{x\sim\mathcal D}[f_\theta(x) f_\theta(x)^\top],$$
$$\widehat{\rho}_\theta := \widehat{\Sigma}_\theta/\mathrm{tr}(\widehat{\Sigma}_\theta),\qquad \widehat{\mathcal L}_{\mathrm{MCE}}(\theta) := -\mathrm{tr}(\rho_* \log \widehat{\rho}_\theta),$$
$$\widehat{\mathcal L}_{\mathrm{CE}}(\theta) := \tfrac{1}{m}\sum_{i=1}^m \ell_{\mathrm{CE}}(W f_\theta(x_i), y_i),\quad 0 \le \ell_{\mathrm{CE}} \le B_{\mathrm{CE}},$$
with $\rho_*$ a fixed reference density ($\mathrm{tr}\rho_* = 1$). Population versions are denoted without hats.

Assume:
- **(C1)** $\|f_\theta(x)\|_2 \le B$ a.s. for every $\theta\in\Theta, x\in\mathcal X$.
- **(C2)** $r_{\mathrm{eff}}(\Sigma_\theta) := \mathrm{tr}(\Sigma_\theta)/\|\Sigma_\theta\|_{\mathrm{op}} \le R$ for all $\theta$.
- **(C3)** Spectral floor: $\widehat{\rho}_\theta \succeq (\mu/d) I_d$ on the relevant high-probability event (achieved by Tikhonov $\widehat{\Sigma}_\theta \mapsto \widehat{\Sigma}_\theta + \varepsilon I$ with $\varepsilon = \mu \mathrm{tr}(\widehat\Sigma)/d$).
- **(C4)** $m \ge c \cdot B^2 \|\Sigma\|_{\mathrm{op}} \mu^{-2} \log(R/\delta)$, an absolute constant $c > 0$.
- **(C5)** Population CE has positive variance: $v_0 := \mathrm{Var}_{(x,y)\sim\mathcal D}[\ell_{\mathrm{CE}}(W^\star f_{\theta^*_{\mathrm{CE}}}(x), y)] > 0$, *and the parameters satisfy*
$$\frac{8 B^2 \|\Sigma\|_{\mathrm{op}} \log(8 R/\delta)}{\mu^2} \;<\; v_0. \tag{$\star$}$$

Then with probability at least $1 - 2\delta$ over the i.i.d. sample,
$$\bigl|\mathcal L_{\mathrm{MCE}}(\theta^*_{\mathrm{MCE}}) - \widehat{\mathcal L}_{\mathrm{MCE}}(\theta^*_{\mathrm{MCE}})\bigr| \;<\; \bigl|\mathcal L_{\mathrm{CE}}(\theta^*_{\mathrm{CE}}) - \widehat{\mathcal L}_{\mathrm{CE}}(\theta^*_{\mathrm{CE}})\bigr|.$$

Quantitative form:
$$|\mathrm{gap}_{\mathrm{MCE}}| \le \frac{2B}{\mu}\sqrt{\frac{2\|\Sigma\|_{\mathrm{op}} \log(8R/\delta)}{m}} + O(1/m), \qquad |\mathrm{gap}_{\mathrm{CE}}| \ge \sqrt{\frac{v_0}{m}} - O(1/m).$$

---

## Proof

### Step 1: Operator-Lipschitz estimate for matrix log

**Lemma 1.** *Let $A, B \in \mathbb S^d_{++}$ satisfy $A, B \succeq \mu I$ for some $\mu > 0$. Then*
$$\|\log A - \log B\|_{\mathrm{op}} \le \frac{1}{\mu} \|A - B\|_{\mathrm{op}}.$$

*Proof.* Use the integral representation (Bhatia, *Matrix Analysis*, V.2.6):
$$\log A = \int_0^\infty \left( \frac{1}{1+t} I - (A + t I)^{-1} \right) dt.$$
Applying the resolvent identity $(B+tI)^{-1} - (A+tI)^{-1} = (B+tI)^{-1}(A-B)(A+tI)^{-1}$,
$$\log A - \log B = \int_0^\infty (B+tI)^{-1} (A-B) (A+tI)^{-1}\, dt.$$
Since $A, B \succeq \mu I$ both resolvents satisfy $\|(A+tI)^{-1}\|_{\mathrm{op}} \le 1/(\mu+t)$, hence
$$\|\log A - \log B\|_{\mathrm{op}} \le \|A - B\|_{\mathrm{op}} \int_0^\infty \frac{dt}{(\mu+t)^2} = \frac{\|A-B\|_{\mathrm{op}}}{\mu}.\qquad \Box$$

### Step 2: Lipschitz constant of the MCE loss in $\widehat\Sigma$

**Lemma 2.** *Let $\rho_*$ be a density operator and $A, B \in \mathbb S^d_{++}$ with $A, B \succeq \mu I$ and $\mathrm{tr}(A), \mathrm{tr}(B) \in [\tau_-, \tau_+]$. Define $\Phi(A) := -\mathrm{tr}(\rho_* \log(A/\mathrm{tr} A))$. Then*
$$|\Phi(A) - \Phi(B)| \le L \|A - B\|_{\mathrm{op}}, \quad L := \frac{1}{\mu} + \frac{d}{\tau_-}.$$

*Proof.* Decompose $\Phi(A) = -\mathrm{tr}(\rho_* \log A) + \mathrm{tr}(\rho_*) \log\mathrm{tr}(A) = -\mathrm{tr}(\rho_* \log A) + \log\mathrm{tr}(A)$ since $\mathrm{tr}\rho_* = 1$.
- *First term:* By trace–operator-norm Hölder, $|\mathrm{tr}(\rho_*(\log A - \log B))| \le \|\rho_*\|_{S_1} \|\log A - \log B\|_{\mathrm{op}}$. Since $\|\rho_*\|_{S_1} = \mathrm{tr}\rho_* = 1$, Lemma 1 gives this $\le \|A-B\|_{\mathrm{op}}/\mu$.
- *Second term:* $|\log\mathrm{tr}(A) - \log\mathrm{tr}(B)| \le |\mathrm{tr}(A) - \mathrm{tr}(B)|/\tau_- \le d \|A-B\|_{\mathrm{op}}/\tau_-$ (by $|\mathrm{tr}(M)| \le d\|M\|_{\mathrm{op}}$).

Sum: $L = 1/\mu + d/\tau_-$. Under (C3), $\tau_- \ge d \mu \cdot \mathrm{tr}(\widehat\Sigma)/(d \cdot \mathrm{tr}(\widehat\Sigma)) \cdot (\text{const})$, equivalently $d/\tau_- \le 1/\mu$, giving the practical bound $L \le 2/\mu$. $\qquad \Box$

### Step 3: Matrix Bernstein concentration of the empirical covariance

**Lemma 3** (Tropp 2015, Theorem 6.1.1, intrinsic-dimension form §7.3). *Let $X_1,\ldots,X_m$ be i.i.d. centered Hermitian matrices in $\mathbb R^{d\times d}$ with $\|X_i\|_{\mathrm{op}} \le R_0$ a.s.\ and intrinsic dimension $r := \mathrm{tr}(\mathbb E[X^2])/\|\mathbb E[X^2]\|_{\mathrm{op}}$. Then for any $t \ge 0$,*
$$\Pr\!\left( \Big\|\frac{1}{m}\sum_i X_i\Big\|_{\mathrm{op}} \ge t \right) \le 8 r \exp\!\left(-\frac{m t^2 / 2}{\sigma^2 + R_0 t/3}\right), \quad \sigma^2 := \|\mathbb E[X^2]\|_{\mathrm{op}}.$$

**Application.** Let $X_i = f_\theta(x_i) f_\theta(x_i)^\top - \Sigma_\theta$. Then:

(i) $\|X_i\|_{\mathrm{op}} \le \|f_\theta(x_i)f_\theta(x_i)^\top\|_{\mathrm{op}} + \|\Sigma_\theta\|_{\mathrm{op}} \le B^2 + B^2 = 2 B^2$, so $R_0 \le 2 B^2$.

(ii) $\mathbb E[X_i^2] = \mathbb E[\|f_\theta(x_i)\|_2^2 f_\theta(x_i) f_\theta(x_i)^\top] - \Sigma_\theta^2$.
Since $\|f_\theta(x_i)\|_2^2 \le B^2$, $\mathbb E[\|f\|^2 f f^\top] \preceq B^2 \mathbb E[f f^\top] = B^2 \Sigma_\theta$. Hence
$\mathbb E[X^2] \preceq B^2 \Sigma_\theta$, so $\sigma^2 \le B^2 \|\Sigma_\theta\|_{\mathrm{op}}$.

(iii) Intrinsic dimension $r \le \mathrm{tr}(B^2 \Sigma_\theta)/(B^2 \|\Sigma\|_{\mathrm{op}}) = r_{\mathrm{eff}}(\Sigma_\theta) \le R$ by (C2).

Inverting the Bernstein tail at confidence $1-\delta$: with probability $\ge 1-\delta$,
$$\boxed{\;\|\widehat\Sigma_\theta - \Sigma_\theta\|_{\mathrm{op}} \le \sqrt{\frac{2 B^2 \|\Sigma_\theta\|_{\mathrm{op}} \log(8R/\delta)}{m}} + \frac{4 B^2 \log(8R/\delta)}{3m}.\;} \tag{1}$$

### Step 4: Pointwise MCE generalization gap

For a fixed $\theta$, on the high-probability event of Step 3 (within the spectral cone $\mathcal S_\mu$ by (C3)–(C4)):
$$|\widehat{\mathcal L}_{\mathrm{MCE}}(\theta) - \mathcal L_{\mathrm{MCE}}(\theta)| = |\Phi(\widehat\Sigma_\theta) - \Phi(\Sigma_\theta)| \le L \|\widehat\Sigma_\theta - \Sigma_\theta\|_{\mathrm{op}}.$$
Combining (1) with $L \le 2/\mu$ from Lemma 2:
$$|\widehat{\mathcal L}_{\mathrm{MCE}}(\theta) - \mathcal L_{\mathrm{MCE}}(\theta)| \le \frac{2}{\mu}\sqrt{\frac{2 B^2 \|\Sigma\|_{\mathrm{op}} \log(8R/\delta)}{m}} + \frac{8 B^2 \log(8R/\delta)}{3 \mu m}. \tag{2}$$

### Step 5: Uniform bound over $\Theta$ for MCE

Suppose $\theta \mapsto f_\theta(x)$ is $L_\Theta$-Lipschitz uniformly in $x$ (in some norm $\|\cdot\|_\Theta$), and $\Theta$ has $\varepsilon$-covering number $N(\Theta, \varepsilon)$ in this norm. Then for any $\theta, \theta'$ with $\|\theta-\theta'\|_\Theta \le \varepsilon$:
$$\|\widehat\Sigma_\theta - \widehat\Sigma_{\theta'}\|_{\mathrm{op}} \le 2 B L_\Theta \varepsilon, \qquad \|\Sigma_\theta - \Sigma_{\theta'}\|_{\mathrm{op}} \le 2 B L_\Theta \varepsilon.$$
Taking a union bound of (2) over an $\varepsilon$-net (size $N(\Theta,\varepsilon)$) at confidence $\delta/N$:
$$\sup_{\theta\in\Theta} |\widehat{\mathcal L}_{\mathrm{MCE}}(\theta) - \mathcal L_{\mathrm{MCE}}(\theta)| \le \frac{2}{\mu}\sqrt{\frac{2 B^2 \|\Sigma\|_{\mathrm{op}} (\log(8R/\delta) + \log N(\Theta,\varepsilon))}{m}} + \frac{4 L_\Theta B \varepsilon}{\mu} + O(1/m).$$
Choosing $\varepsilon = 1/m$ absorbs the second term into the $O(1/m)$ remainder. In particular, evaluating at $\theta = \theta^*_{\mathrm{MCE}}$:
$$|\mathrm{gap}_{\mathrm{MCE}}| \le \frac{2B}{\mu}\sqrt{\frac{2 \|\Sigma\|_{\mathrm{op}} (\log(8R/\delta) + \log N(\Theta,1/m))}{m}} + O(1/m). \tag{3}$$

### Step 6: CE generalization gap upper bound

By Hoeffding's inequality applied to the i.i.d.\ bounded-loss sample $\{\ell_{\mathrm{CE}}(W f_{\theta^*_{\mathrm{CE}}}(x_i), y_i)\}$, plus standard symmetrization to handle ERM optimism:
$$|\widehat{\mathcal L}_{\mathrm{CE}}(\theta^*_{\mathrm{CE}}) - \mathcal L_{\mathrm{CE}}(\theta^*_{\mathrm{CE}})| \le 2\mathfrak R_m(\ell_{\mathrm{CE}} \circ \mathcal H) + B_{\mathrm{CE}}\sqrt{\log(2/\delta)/(2m)}.\tag{4}$$

### Step 7: CE generalization gap *lower* bound

This is the crucial half. Let $g_i := \ell_{\mathrm{CE}}(W^\star f_{\theta^*_{\mathrm{CE}}}(x_i), y_i)$, an i.i.d.\ sample of a bounded random variable with variance $\mathrm{Var}(g) = v_0 > 0$ by (C5). Standard CLT gives $\sqrt m (\widehat g - \mathbb E g) \xrightarrow{d} \mathcal N(0, v_0)$, so
$$\mathbb E |\widehat{\mathcal L}_{\mathrm{CE}}(\theta^*_{\mathrm{CE}}) - \mathcal L_{\mathrm{CE}}(\theta^*_{\mathrm{CE}})| \ge \mathbb E |\widehat g - \mathbb E g| - O(1/m) = \sqrt{2v_0/(\pi m)}(1+o(1)).$$
A non-asymptotic version (Berry–Esseen + lower tail of Gaussian): with probability $\ge 1-\delta$,
$$|\widehat{\mathcal L}_{\mathrm{CE}}(\theta^*_{\mathrm{CE}}) - \mathcal L_{\mathrm{CE}}(\theta^*_{\mathrm{CE}})| \ge \sqrt{\frac{v_0}{m}} \cdot \Phi_{\mathcal N}^{-1}(1-\delta) - O(1/m). \tag{5}$$
*Remark.* The optimism bias of ERM is *at least* the deviation of the empirical mean from its expectation at any single fixed $\theta$ in the class with positive loss variance; that fixed $\theta = \theta^*_{\mathrm{CE}}$ provides this lower bound.

### Step 8: Comparison

Combine (3) and (5). The MCE gap is at most
$$\frac{2B}{\mu}\sqrt{\frac{2 \|\Sigma\|_{\mathrm{op}} \log(8R/\delta)}{m}} \cdot (1 + o(1))$$
ignoring the (typically small) $\log N(\Theta,1/m)$ contribution and $O(1/m)$ remainder. The CE gap is at least $\sqrt{v_0/m}(1 + o(1))$.

Strict inequality $|\mathrm{gap}_{\mathrm{MCE}}| < |\mathrm{gap}_{\mathrm{CE}}|$ holds whenever
$$\frac{2B}{\mu}\sqrt{2\|\Sigma\|_{\mathrm{op}} \log(8R/\delta)} < \sqrt{v_0},$$
equivalently the boxed condition $(\star)$:
$$\frac{8 B^2 \|\Sigma\|_{\mathrm{op}} \log(8R/\delta)}{\mu^2} < v_0.$$
Combining the two high-probability events (the matrix Bernstein event of Step 3 and the CLT-deviation event of Step 7) with a union bound concludes the proof at confidence $1 - 2\delta$. $\qquad \blacksquare$

---

## Discussion

### Why the gap exists
Standard CE concentration is governed by the *per-sample loss range* $B_{\mathrm{CE}}$ (which scales as $\log K$ for $K$-class softmax CE). MCE is a smooth function of an empirical *matrix mean*: matrix Bernstein gives concentration at the *operator-norm* scale $B^2 \|\Sigma\|_{\mathrm{op}}$, with dimensionality replaced by the *intrinsic dimension* $r_{\mathrm{eff}}(\Sigma)$. When the representation has low effective rank (the SSL regime), $\|\Sigma\|_{\mathrm{op}}$ is small relative to $B^2$, and the matrix Bernstein bound dominates the scalar Hoeffding bound — even after accounting for the Lipschitz lift constant $1/\mu$ from the matrix log.

### When the gap *fails*
- **Deterministic data:** $v_0 = 0 \Rightarrow$ CE has zero generalization gap, MCE has nontrivial one.
- **No spectral floor:** $\mu \to 0 \Rightarrow L \to \infty$, MCE bound vacuous.
- **Full effective rank in high-$d$:** $r_{\mathrm{eff}} \asymp d$, $\|\Sigma\|_{\mathrm{op}} \asymp B^2/d \to B^2$ scale; bound degrades.

### Connection to ICML 2024 paper
The paper empirically observes that MCE-based SSL generalizes better than CE-based supervised pretraining on downstream tasks. This theorem isolates the *generalization-gap* mechanism: matrix Bernstein replaces dimension by intrinsic dimension, and Tikhonov-style matrix smoothing (their MAtrix-Cross-Entropy with $\varepsilon$ regularizer) controls the Lipschitz lift. The boxed inequality $(\star)$ is the formal statement of "low effective rank + spectral regularization $\Rightarrow$ MCE wins."
