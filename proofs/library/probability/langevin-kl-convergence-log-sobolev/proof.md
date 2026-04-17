# Langevin Diffusion Exponential Convergence via Log-Sobolev Inequality

## Proof via Entropy Dissipation (De Bruijn Identity + LSI + Gronwall)

### Setup and Notation

We are given the Langevin diffusion:
$$dX_t = -\nabla V(X_t)\,dt + \sqrt{2}\,dB_t$$

Let $\mu_t$ denote the law of $X_t$ with density $\rho_t$ (w.r.t. Lebesgue measure). The target distribution is $\pi(x) \propto e^{-V(x)}$. We assume $\pi$ satisfies a log-Sobolev inequality (LSI) with constant $\alpha > 0$:

$$\mathrm{Ent}_\pi(f^2) \leq \frac{2}{\alpha}\,\mathbb{E}_\pi[|\nabla f|^2]$$

Define:
$$H(t) := \mathrm{KL}(\mu_t \| \pi) = \int \rho_t \log \frac{\rho_t}{\pi}\,dx$$
$$I(t) := I(\mu_t \| \pi) = \int \rho_t \left|\nabla \log \frac{\rho_t}{\pi}\right|^2 dx \quad \text{(relative Fisher information)}$$

---

## Step 1: Fokker-Planck Equation

The density $\rho_t$ evolves according to the Fokker-Planck equation:

$$\partial_t \rho_t = \nabla \cdot (\rho_t \nabla V) + \Delta \rho_t$$

**Verification that $\pi$ is stationary.** For $\rho_t = \pi \propto e^{-V}$: $\nabla \pi = -\pi \nabla V$, so $\nabla \cdot (\pi \nabla V) + \Delta \pi = \nabla \cdot (\pi \nabla V) + \nabla \cdot (-\pi \nabla V) = 0$. $\checkmark$

**Rewriting in relative form.** Since $\nabla \log(\rho_t/\pi) = \nabla \log \rho_t + \nabla V$:

$$\rho_t \nabla \log \frac{\rho_t}{\pi} = \nabla \rho_t + \rho_t \nabla V$$

Therefore:

$$\partial_t \rho_t = \nabla \cdot \left(\rho_t \nabla \log \frac{\rho_t}{\pi}\right) \tag{FP}$$

---

## Step 2: De Bruijn Identity — Entropy Dissipation

**Claim:** $H'(t) = -I(t)$.

**Proof.** Differentiate under the integral sign:

$$H'(t) = \int (\partial_t \rho_t) \log \frac{\rho_t}{\pi}\,dx + \int \partial_t \rho_t\,dx$$

The second integral vanishes ($\int \rho_t = 1$ for all $t$). Substituting (FP):

$$H'(t) = \int \nabla \cdot \left(\rho_t \nabla \log \frac{\rho_t}{\pi}\right) \log \frac{\rho_t}{\pi}\,dx$$

Integration by parts (boundary terms vanish under sufficient decay of $\rho_t$ at infinity):

$$H'(t) = -\int \rho_t \nabla \log \frac{\rho_t}{\pi} \cdot \nabla \log \frac{\rho_t}{\pi}\,dx = -\int \rho_t \left|\nabla \log \frac{\rho_t}{\pi}\right|^2 dx$$

$$\boxed{\frac{d}{dt}\mathrm{KL}(\mu_t \| \pi) = -I(\mu_t \| \pi)} \tag{1}$$

This shows KL is non-increasing, with dissipation rate equal to the relative Fisher information. $\checkmark$

---

## Step 3: Applying the Log-Sobolev Inequality

**Claim:** $I(t) \geq 2\alpha\, H(t)$.

**Proof.** Make the substitution $f = \sqrt{\rho_t / \pi}$ in the LSI.

**Left-hand side:** Since $\mathbb{E}_\pi[f^2] = \int \frac{\rho_t}{\pi} \pi\,dx = \int \rho_t\,dx = 1$:

$$\mathrm{Ent}_\pi(f^2) = \mathbb{E}_\pi[f^2 \log f^2] - \underbrace{\mathbb{E}_\pi[f^2]}_{=1} \cdot \underbrace{\log \mathbb{E}_\pi[f^2]}_{=0} = \int \frac{\rho_t}{\pi} \log \frac{\rho_t}{\pi} \cdot \pi\,dx = \mathrm{KL}(\mu_t \| \pi) = H(t)$$

**Right-hand side:** Compute $\nabla f$:

$$\nabla f = \frac{1}{2} \left(\frac{\rho_t}{\pi}\right)^{-1/2} \nabla \left(\frac{\rho_t}{\pi}\right) = \frac{1}{2} \left(\frac{\rho_t}{\pi}\right)^{1/2} \nabla \log \frac{\rho_t}{\pi}$$

where we used $\nabla(\rho_t/\pi) = (\rho_t/\pi) \nabla \log(\rho_t/\pi)$. Therefore:

$$|\nabla f|^2 = \frac{1}{4} \cdot \frac{\rho_t}{\pi} \left|\nabla \log \frac{\rho_t}{\pi}\right|^2$$

$$\mathbb{E}_\pi[|\nabla f|^2] = \int \frac{1}{4} \cdot \frac{\rho_t}{\pi} \left|\nabla \log \frac{\rho_t}{\pi}\right|^2 \pi\,dx = \frac{1}{4} \int \rho_t \left|\nabla \log \frac{\rho_t}{\pi}\right|^2 dx = \frac{I(t)}{4}$$

**Substituting into LSI:**

$$H(t) \leq \frac{2}{\alpha} \cdot \frac{I(t)}{4} = \frac{I(t)}{2\alpha}$$

Rearranging:

$$\boxed{I(t) \geq 2\alpha\, H(t)} \tag{2}$$

---

## Step 4: Gronwall's Inequality

Combining (1) and (2):

$$H'(t) = -I(t) \leq -2\alpha\, H(t)$$

**Gronwall's Lemma.** If $H: [0,\infty) \to [0,\infty)$ is absolutely continuous and $H'(t) \leq -\lambda H(t)$ for a.e. $t$, then $H(t) \leq e^{-\lambda t} H(0)$.

*Proof.* Define $\Phi(t) = e^{\lambda t} H(t)$. Then $\Phi'(t) = e^{\lambda t}(\lambda H(t) + H'(t)) \leq 0$, so $\Phi$ is non-increasing. Thus $\Phi(t) \leq \Phi(0) = H(0)$, giving $H(t) \leq e^{-\lambda t} H(0)$. $\square$

Applying with $\lambda = 2\alpha$:

$$\boxed{\mathrm{KL}(\mu_t \| \pi) \leq e^{-2\alpha t} \cdot \mathrm{KL}(\mu_0 \| \pi)} \qquad \blacksquare$$
