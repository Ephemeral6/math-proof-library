# OFUL Linear Bandit Regret Bound — Complete Proof (Fixed)

## Setup

Linear bandit: round $t$, select $a_t \in \mathcal{A}_t \subseteq \mathbb{R}^d$, observe $r_t = \langle a_t, \theta^*\rangle + \eta_t$.

**Notation:**
- $A_t = \sum_{s=1}^t a_s a_s^\top$ (unregularized design matrix)
- $V_t = \lambda I + A_t$ (regularized design matrix)
- $S_t = \sum_{s=1}^t \eta_s a_s$ (noise vector)
- $\hat{\theta}_t = V_t^{-1}\sum_{s=1}^t r_s a_s$ (ridge estimator)
- $\|x\|_M = \sqrt{x^\top M x}$

**Assumptions:**
1. $\|\theta^*\| \leq S$
2. $\|a\| \leq L$ for all feasible actions
3. $\eta_t$ conditionally $R$-sub-Gaussian: $\mathbb{E}[e^{s\eta_t}|\mathcal{F}_{t-1}] \leq e^{s^2R^2/2}$
4. $\lambda \geq L^2$ (ensures $\|a_t\|_{V_{t-1}^{-1}}^2 \leq 1$)

**Goal:** With probability $\geq 1-\delta$:

$$\text{Regret}(T) \leq 2\beta_T\sqrt{2Td\ln\!\left(1+\frac{TL^2}{\lambda d}\right)}$$

where $\beta_T = R\sqrt{d\ln(1+TL^2/(\lambda d)) + 2\ln(1/\delta)} + \sqrt{\lambda}S$.

---

## Lemma 1: Self-Normalized Martingale Bound

**Claim:** W.p. $\geq 1-\delta$, simultaneously for all $t \geq 0$:

$$\|S_t\|_{V_t^{-1}} \leq R\sqrt{d\ln\!\left(1+\frac{tL^2}{\lambda d}\right) + 2\ln\frac{1}{\delta}}$$

**Proof.**

**Step 1.1: Define the mixture.** For $\theta \in \mathbb{R}^d$, let

$$L_t(\theta) = \exp\!\left(\frac{\langle\theta, S_t\rangle}{R^2} - \frac{\|\theta\|_{A_t}^2}{2R^2}\right)$$

where $A_t = \sum_{s=1}^t a_s a_s^\top$ (NOTE: uses $A_t$, not $V_t$). Integrate against prior $p(\theta) = \mathcal{N}(0, (R^2/\lambda)I)$:

$$M_t = \int_{\mathbb{R}^d} L_t(\theta)\,p(\theta)\,d\theta$$

**Step 1.2: Complete the square.** The total exponent in the integrand is:

$$\frac{\langle\theta,S_t\rangle}{R^2} - \frac{\|\theta\|_{A_t}^2}{2R^2} - \frac{\lambda\|\theta\|^2}{2R^2} = \frac{\langle\theta,S_t\rangle}{R^2} - \frac{\|\theta\|_{V_t}^2}{2R^2}$$

since $A_t + \lambda I = V_t$. Completing the square:

$$= -\frac{(\theta - V_t^{-1}S_t)^\top V_t(\theta - V_t^{-1}S_t)}{2R^2} + \frac{\|S_t\|_{V_t^{-1}}^2}{2R^2}$$

The Gaussian integral evaluates to $(2\pi R^2)^{d/2}\det(V_t)^{-1/2}$. Including the prior normalization $\lambda^{d/2}/(2\pi R^2)^{d/2}$:

$$M_t = \frac{\lambda^{d/2}}{\det(V_t)^{1/2}}\exp\!\left(\frac{\|S_t\|_{V_t^{-1}}^2}{2R^2}\right)$$

**Step 1.3: Supermartingale property.** The ratio $L_t(\theta)/L_{t-1}(\theta)$ involves:

$$\frac{L_t(\theta)}{L_{t-1}(\theta)} = \exp\!\left(\frac{\eta_t\langle a_t,\theta\rangle}{R^2} - \frac{\langle a_t,\theta\rangle^2}{2R^2}\right)$$

Taking conditional expectation and using $R$-sub-Gaussianity with $s = \langle a_t,\theta\rangle/R^2$:

$$\mathbb{E}\!\left[\exp\!\left(\frac{\eta_t\langle a_t,\theta\rangle}{R^2}\right)\bigg|\mathcal{F}_{t-1}\right] \leq \exp\!\left(\frac{\langle a_t,\theta\rangle^2}{2R^2}\right)$$

The two exponentials **cancel exactly**: $\mathbb{E}[L_t(\theta)|\mathcal{F}_{t-1}] \leq L_{t-1}(\theta)$.

By Fubini: $\mathbb{E}[M_t|\mathcal{F}_{t-1}] \leq M_{t-1}$.

**Step 1.4:** $M_0 = \lambda^{d/2}/\lambda^{d/2} \cdot e^0 = 1$.

**Step 1.5: Ville's inequality.** $(M_t)$ is a non-negative supermartingale with $M_0=1$. By Ville's inequality: $\mathbb{P}(\exists t: M_t \geq 1/\delta) \leq \delta$.

When $M_t < 1/\delta$: $\frac{\lambda^{d/2}}{\det(V_t)^{1/2}}\exp(\|S_t\|_{V_t^{-1}}^2/(2R^2)) < 1/\delta$

$$\|S_t\|_{V_t^{-1}}^2 < 2R^2\left[\frac{1}{2}\ln\frac{\det(V_t)}{\lambda^d} + \ln\frac{1}{\delta}\right]$$

By AM-GM: $\det(V_t) \leq (\text{tr}(V_t)/d)^d \leq (\lambda + tL^2/d)^d$, so $\det(V_t)/\lambda^d \leq (1+tL^2/(\lambda d))^d$.

$$\|S_t\|_{V_t^{-1}}^2 < R^2\!\left[d\ln\!\left(1+\frac{tL^2}{\lambda d}\right) + 2\ln\frac{1}{\delta}\right] \qquad \square$$

---

## Lemma 2: Confidence Ellipsoid

**Claim:** W.p. $\geq 1-\delta$, for all $t \geq 1$: $\|\hat{\theta}_t - \theta^*\|_{V_t} \leq \beta_t$.

**Proof.** Since $r_s = \langle a_s,\theta^*\rangle + \eta_s$:

$$\hat{\theta}_t - \theta^* = V_t^{-1}S_t - \lambda V_t^{-1}\theta^*$$

By triangle inequality: $\|\hat{\theta}_t - \theta^*\|_{V_t} \leq \|S_t\|_{V_t^{-1}} + \lambda\|\theta^*\|_{V_t^{-1}}$.

Since $V_t \succeq \lambda I$: $\lambda\|\theta^*\|_{V_t^{-1}} \leq \lambda \cdot S/\sqrt{\lambda} = \sqrt{\lambda}S$.

Combining with Lemma 1: $\|\hat{\theta}_t - \theta^*\|_{V_t} \leq \beta_t$ where

$$\beta_t = R\sqrt{d\ln\!\left(1+\frac{tL^2}{\lambda d}\right) + 2\ln\frac{1}{\delta}} + \sqrt{\lambda}S \qquad \square$$

---

## Lemma 3: Instantaneous Regret

**Claim:** On the high-probability event, $\langle a_t^*,\theta^*\rangle - \langle a_t,\theta^*\rangle \leq 2\beta_{t-1}\|a_t\|_{V_{t-1}^{-1}}$.

**Proof.**

**Optimism:** Since $\theta^* \in \mathcal{C}_{t-1}$, by Cauchy-Schwarz:

$$\langle a_t^*,\theta^*\rangle \leq \langle a_t^*,\hat{\theta}_{t-1}\rangle + \beta_{t-1}\|a_t^*\|_{V_{t-1}^{-1}}$$

OFUL selects $a_t$ to maximize $\langle a,\hat{\theta}_{t-1}\rangle + \beta_t\|a\|_{V_{t-1}^{-1}}$. Since $\beta_t \geq \beta_{t-1}$:

$$\langle a_t,\hat{\theta}_{t-1}\rangle + \beta_t\|a_t\|_{V_{t-1}^{-1}} \geq \langle a_t^*,\hat{\theta}_{t-1}\rangle + \beta_t\|a_t^*\|_{V_{t-1}^{-1}} \geq \langle a_t^*,\hat{\theta}_{t-1}\rangle + \beta_{t-1}\|a_t^*\|_{V_{t-1}^{-1}}$$

Therefore: $\langle a_t^*,\theta^*\rangle \leq \langle a_t,\hat{\theta}_{t-1}\rangle + \beta_t\|a_t\|_{V_{t-1}^{-1}}$.

$$\text{reg}_t \leq \langle a_t,\hat{\theta}_{t-1}-\theta^*\rangle + \beta_t\|a_t\|_{V_{t-1}^{-1}} \leq 2\beta_t\|a_t\|_{V_{t-1}^{-1}}$$

Using $\beta_{t-1} \leq \beta_t \leq \beta_T$ in the final sum. $\square$

---

## Lemma 4: Elliptical Potential

**Claim:** $\sum_{t=1}^T \|a_t\|_{V_{t-1}^{-1}}^2 \leq 2d\ln(1+TL^2/(\lambda d))$.

**Proof.** Let $x_t = \|a_t\|_{V_{t-1}^{-1}}^2$.

**Step 4.1 (Matrix determinant lemma):** $\det(V_t)/\det(V_{t-1}) = 1 + x_t$.

**Step 4.2 (Telescoping):** $\sum_{t=1}^T \ln(1+x_t) = \ln\det(V_T) - \ln\det(V_0) \leq d\ln(1+TL^2/(\lambda d))$.

**Step 4.3 (Key inequality):** Since $\lambda \geq L^2$, we have $x_t \leq L^2/\lambda \leq 1$. For $x \in [0,1]$: $x \leq 2\ln(1+x)$ (since $f(x) = \ln(1+x) - x/2$ has $f(0)=0$, $f'(x) = 1/(1+x) - 1/2 \geq 0$ for $x \leq 1$).

**Step 4.4:** $\sum_{t=1}^T x_t \leq 2\sum_{t=1}^T \ln(1+x_t) \leq 2d\ln(1+TL^2/(\lambda d))$. $\square$

---

## Main Theorem

**Proof.** From Lemma 3 with monotonicity $\beta_t \leq \beta_T$:

$$\text{Regret}(T) \leq 2\beta_T\sum_{t=1}^T \|a_t\|_{V_{t-1}^{-1}}$$

By Cauchy-Schwarz: $\sum_t \|a_t\|_{V_{t-1}^{-1}} \leq \sqrt{T\sum_t \|a_t\|_{V_{t-1}^{-1}}^2}$.

By Lemma 4: $\sum_t \|a_t\|_{V_{t-1}^{-1}}^2 \leq 2d\ln(1+TL^2/(\lambda d))$.

$$\boxed{\text{Regret}(T) \leq 2\beta_T\sqrt{2Td\ln\!\left(1+\frac{TL^2}{\lambda d}\right)}} = \tilde{O}(d\sqrt{T})$$

$\blacksquare$
