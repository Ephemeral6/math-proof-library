# Proof: Modified Log-Sobolev Inequality Implies Exponential Decay of KL Divergence

## Theorem

Let $\Omega$ be a finite state space and $\mu$ a probability measure on $\Omega$ with $\mu(x) > 0$ for all $x \in \Omega$. Let $(P_t)_{t \geq 0}$ be a continuous-time reversible Markov semigroup with generator $L$ and stationary measure $\mu$. Define the Dirichlet form:

$$\mathcal{E}_D(f, g) = \frac{1}{2}\sum_{x,y \in \Omega} \mu(x) Q(x,y)(f(x) - f(y))(g(x) - g(y))$$

where $Q(x,y)$ are the transition rates of the continuous-time chain ($L g(x) = \sum_y Q(x,y)(g(y) - g(x))$).

Suppose $\mu$ satisfies a **Modified Log-Sobolev Inequality (MLSI)** with constant $\alpha > 0$: for all $f: \Omega \to \mathbb{R}_+$,

$$\mathrm{Ent}_\mu(f) \leq \frac{1}{2\alpha}\,\mathcal{E}_D(f, \ln f)$$

where $\mathrm{Ent}_\mu(f) = \mathbb{E}_\mu[f \ln f] - \mathbb{E}_\mu[f]\ln\mathbb{E}_\mu[f]$.

Then for any initial distribution $\nu$ on $\Omega$:

$$D_{\mathrm{KL}}(\nu P_t \,\|\, \mu) \leq e^{-2\alpha t}\, D_{\mathrm{KL}}(\nu \,\|\, \mu).$$

In particular, the mixing time in KL divergence satisfies:

$$t_{\mathrm{mix}}(\epsilon) \leq \frac{1}{2\alpha}\left(\ln\ln\frac{1}{\mu_{\min}} + \ln\frac{1}{\epsilon}\right).$$

---

## Proof

### Setup and Notation

Let $\nu$ be an arbitrary initial distribution on $\Omega$ with $\nu \ll \mu$ (if $\nu$ is not absolutely continuous with respect to $\mu$, then $D_{\mathrm{KL}}(\nu \| \mu) = +\infty$ and the bound holds trivially). Define the time-evolved distribution:

$$\nu_t := \nu P_t$$

and the density (Radon-Nikodym derivative) with respect to $\mu$:

$$f_t(x) := \frac{d\nu_t}{d\mu}(x) = \frac{\nu_t(x)}{\mu(x)}.$$

Note that $f_t \geq 0$ and $\mathbb{E}_\mu[f_t] = \sum_x \mu(x) f_t(x) = \sum_x \nu_t(x) = 1$ for all $t \geq 0$.

The KL divergence can be written as:

$$D_{\mathrm{KL}}(\nu_t \| \mu) = \sum_{x \in \Omega} \nu_t(x) \ln\frac{\nu_t(x)}{\mu(x)} = \sum_{x \in \Omega} \mu(x)\, f_t(x) \ln f_t(x) = \mathbb{E}_\mu[f_t \ln f_t].$$

Since $\mathbb{E}_\mu[f_t] = 1$, we have $\mathbb{E}_\mu[f_t] \ln \mathbb{E}_\mu[f_t] = 1 \cdot \ln 1 = 0$, so:

$$D_{\mathrm{KL}}(\nu_t \| \mu) = \mathbb{E}_\mu[f_t \ln f_t] - \mathbb{E}_\mu[f_t]\ln\mathbb{E}_\mu[f_t] = \mathrm{Ent}_\mu(f_t). \tag{1}$$

---

### Step 1: Evolution Equation for the Density

The continuous-time Markov semigroup $P_t = e^{tL}$ acts on the distribution $\nu_t$ via:

$$\nu_t(y) = \sum_x \nu_0(x)\, p_t(x,y)$$

where $p_t(x,y) = (P_t)(x,y)$ is the transition kernel. In terms of the density $f_t = \nu_t / \mu$, we derive the evolution equation.

**Claim:** $\frac{\partial}{\partial t} f_t = L f_t$.

*Proof of Claim.* For any test function $g: \Omega \to \mathbb{R}$:

$$\frac{d}{dt}\langle f_t, g \rangle_\mu = \frac{d}{dt} \sum_x \mu(x) f_t(x) g(x) = \frac{d}{dt} \sum_x \nu_t(x) g(x) = \frac{d}{dt}\, \mathbb{E}_{\nu_t}[g].$$

Since $\nu_t = \nu P_t$ and $P_t$ is a semigroup with generator $L$:

$$\frac{d}{dt}\,\mathbb{E}_{\nu_t}[g] = \mathbb{E}_{\nu_t}[Lg] = \sum_x \nu_t(x)\, Lg(x) = \sum_x \mu(x)\, f_t(x)\, Lg(x) = \langle f_t, Lg \rangle_\mu.$$

By **reversibility** of the chain, the generator $L$ is self-adjoint in $L^2(\mu)$:

$$\langle f_t, Lg \rangle_\mu = \langle Lf_t, g \rangle_\mu.$$

To verify self-adjointness: the detailed balance condition $\mu(x) Q(x,y) = \mu(y) Q(y,x)$ implies

$$\langle Lf, g\rangle_\mu = \sum_x \mu(x) g(x) \sum_y Q(x,y)(f(y) - f(x))$$
$$= \sum_{x,y} \mu(x) Q(x,y) f(y) g(x) - \sum_x \mu(x) g(x) f(x) \sum_y Q(x,y)$$

and by detailed balance (swapping $x \leftrightarrow y$ in the first sum):

$$\sum_{x,y} \mu(x) Q(x,y) f(y) g(x) = \sum_{x,y} \mu(y) Q(y,x) f(y) g(x) = \sum_{x,y} \mu(x) Q(x,y) f(x) g(y)$$

which shows $\langle Lf, g\rangle_\mu = \langle f, Lg\rangle_\mu$. Thus $L = L^*$ in $L^2(\mu)$.

Since $\langle \partial_t f_t, g\rangle_\mu = \langle Lf_t, g\rangle_\mu$ for all test functions $g$, we conclude:

$$\frac{\partial f_t}{\partial t} = Lf_t. \tag{2}$$

---

### Step 2: Time Derivative of KL Divergence

Define $\Phi(t) := D_{\mathrm{KL}}(\nu_t \| \mu) = \sum_x \mu(x)\, f_t(x)\ln f_t(x)$.

We compute:

$$\frac{d\Phi}{dt} = \sum_x \mu(x)\, \frac{\partial f_t}{\partial t}(x)\,(\ln f_t(x) + 1).$$

Substituting the evolution equation (2):

$$\frac{d\Phi}{dt} = \sum_x \mu(x)\,(Lf_t)(x)\,(\ln f_t(x) + 1). \tag{3}$$

**Mass conservation:** Since $L$ is a generator of a Markov chain, $\sum_x \mu(x)\,(Lf_t)(x) = 0$. This is because:

$$\sum_x \mu(x)(Lf_t)(x) = \langle Lf_t, \mathbf{1}\rangle_\mu = \langle f_t, L\mathbf{1}\rangle_\mu = 0$$

where we used self-adjointness and the fact that $L\mathbf{1} = 0$ (constant functions are in the null space of the generator).

Therefore the "$+1$" term in (3) vanishes:

$$\frac{d\Phi}{dt} = \sum_x \mu(x)\,(Lf_t)(x)\,\ln f_t(x) = \langle Lf_t, \ln f_t\rangle_\mu. \tag{4}$$

---

### Step 3: Relating to the Dirichlet Form

We now show that $\langle Lf_t, \ln f_t\rangle_\mu = -\mathcal{E}_D(f_t, \ln f_t)$.

By definition of the generator:

$$\langle Lf, \ln f\rangle_\mu = \sum_x \mu(x)\,\ln f(x) \sum_y Q(x,y)(f(y) - f(x)).$$

We symmetrize using detailed balance $\mu(x)Q(x,y) = \mu(y)Q(y,x)$. Write:

$$\langle Lf, \ln f\rangle_\mu = \sum_{x,y} \mu(x)\,Q(x,y)\,(f(y) - f(x))\,\ln f(x).$$

By swapping $x \leftrightarrow y$ and using detailed balance:

$$\sum_{x,y}\mu(x)\,Q(x,y)\,(f(y)-f(x))\,\ln f(x) = \sum_{x,y}\mu(y)\,Q(y,x)\,(f(x)-f(y))\,\ln f(y)$$
$$= \sum_{x,y}\mu(x)\,Q(x,y)\,(f(x)-f(y))\,\ln f(y).$$

Adding the original expression and its swapped version:

$$2\langle Lf, \ln f\rangle_\mu = \sum_{x,y}\mu(x)\,Q(x,y)\,(f(y)-f(x))\,\ln f(x) + \sum_{x,y}\mu(x)\,Q(x,y)\,(f(x)-f(y))\,\ln f(y)$$

$$= -\sum_{x,y}\mu(x)\,Q(x,y)\,(f(x)-f(y))\,(\ln f(x) - \ln f(y))$$

$$= -2\,\mathcal{E}_D(f, \ln f).$$

Therefore:

$$\langle Lf_t, \ln f_t\rangle_\mu = -\mathcal{E}_D(f_t, \ln f_t). \tag{5}$$

**Remark on sign.** Since $(\cdot)$ and $\ln(\cdot)$ are comonotone (both increasing), $(f(x)-f(y))(\ln f(x)-\ln f(y)) \geq 0$ for all $x,y$. Hence $\mathcal{E}_D(f_t, \ln f_t) \geq 0$, which confirms that $d\Phi/dt \leq 0$ (KL divergence is non-increasing, as expected).

Combining (4) and (5):

$$\frac{d}{dt}\,D_{\mathrm{KL}}(\nu_t \| \mu) = -\mathcal{E}_D(f_t, \ln f_t). \tag{6}$$

---

### Step 4: Applying the MLSI

The Modified Log-Sobolev Inequality states: for all $f: \Omega \to \mathbb{R}_+$,

$$\mathrm{Ent}_\mu(f) \leq \frac{1}{2\alpha}\,\mathcal{E}_D(f, \ln f).$$

Rearranging:

$$\mathcal{E}_D(f, \ln f) \geq 2\alpha\,\mathrm{Ent}_\mu(f).$$

Applying this to $f = f_t$ and using the identity $\mathrm{Ent}_\mu(f_t) = D_{\mathrm{KL}}(\nu_t \| \mu)$ from (1):

$$\mathcal{E}_D(f_t, \ln f_t) \geq 2\alpha\,D_{\mathrm{KL}}(\nu_t \| \mu). \tag{7}$$

Substituting (7) into (6):

$$\frac{d}{dt}\,D_{\mathrm{KL}}(\nu_t \| \mu) = -\mathcal{E}_D(f_t, \ln f_t) \leq -2\alpha\,D_{\mathrm{KL}}(\nu_t \| \mu). \tag{8}$$

---

### Step 5: Gronwall's Inequality

Let $\Phi(t) = D_{\mathrm{KL}}(\nu_t \| \mu)$. The differential inequality (8) reads:

$$\Phi'(t) \leq -2\alpha\,\Phi(t), \qquad \Phi(t) \geq 0.$$

**Application of Gronwall's lemma (differential form):**

Define $\Psi(t) = e^{2\alpha t}\,\Phi(t)$. Then:

$$\Psi'(t) = 2\alpha\,e^{2\alpha t}\,\Phi(t) + e^{2\alpha t}\,\Phi'(t) = e^{2\alpha t}\bigl(2\alpha\,\Phi(t) + \Phi'(t)\bigr) \leq 0$$

where the last inequality uses (8). Since $\Psi$ is non-increasing:

$$\Psi(t) \leq \Psi(0) \implies e^{2\alpha t}\,\Phi(t) \leq \Phi(0).$$

Therefore:

$$\boxed{D_{\mathrm{KL}}(\nu_t \| \mu) \leq e^{-2\alpha t}\,D_{\mathrm{KL}}(\nu \| \mu).} \tag{9}$$

This completes the proof of exponential decay. $\blacksquare$

---

### Step 6: Mixing Time Bound

For the mixing time application, consider the worst-case initial distribution $\nu = \delta_x$ (point mass at $x$). Then:

$$D_{\mathrm{KL}}(\delta_x \| \mu) = \sum_{y}\delta_x(y)\ln\frac{\delta_x(y)}{\mu(y)} = \ln\frac{1}{\mu(x)} \leq \ln\frac{1}{\mu_{\min}}$$

where $\mu_{\min} = \min_{x \in \Omega}\mu(x)$.

By (9):

$$D_{\mathrm{KL}}(\delta_x P_t \| \mu) \leq e^{-2\alpha t}\ln\frac{1}{\mu_{\min}}.$$

To achieve $D_{\mathrm{KL}}(\delta_x P_t \| \mu) \leq \epsilon$, it suffices to require:

$$e^{-2\alpha t}\ln\frac{1}{\mu_{\min}} \leq \epsilon.$$

Taking logarithms:

$$-2\alpha t + \ln\ln\frac{1}{\mu_{\min}} \leq \ln\epsilon$$

$$t \geq \frac{1}{2\alpha}\left(\ln\ln\frac{1}{\mu_{\min}} + \ln\frac{1}{\epsilon}\right).$$

Therefore:

$$\boxed{t_{\mathrm{mix}}(\epsilon) \leq \frac{1}{2\alpha}\left(\ln\ln\frac{1}{\mu_{\min}} + \ln\frac{1}{\epsilon}\right).} \tag{10}$$

**Remark.** The doubly-logarithmic dependence on $1/\mu_{\min}$ (equivalently, on $|\Omega|$ when $\mu$ is close to uniform) is a hallmark of the log-Sobolev approach and is strictly stronger than the $O(\ln(1/\mu_{\min}))$ bound obtained from the spectral gap via Poincare inequality. $\blacksquare$

---

## Summary of Key Steps

| Step | Content | Key Identity/Inequality |
|------|---------|------------------------|
| 1 | Density evolution | $\partial_t f_t = Lf_t$ (by reversibility) |
| 2 | KL time derivative | $\frac{d}{dt}D_{\mathrm{KL}} = \langle Lf_t, \ln f_t\rangle_\mu$ |
| 3 | Dirichlet form connection | $\langle Lf, \ln f\rangle_\mu = -\mathcal{E}_D(f, \ln f)$ |
| 4 | MLSI application | $\mathcal{E}_D(f_t, \ln f_t) \geq 2\alpha\,\mathrm{Ent}_\mu(f_t) = 2\alpha\,D_{\mathrm{KL}}(\nu_t\|\mu)$ |
| 5 | Gronwall | $D_{\mathrm{KL}}(\nu_t\|\mu) \leq e^{-2\alpha t}D_{\mathrm{KL}}(\nu\|\mu)$ |
| 6 | Mixing time | $t_{\mathrm{mix}}(\epsilon) \leq \frac{1}{2\alpha}(\ln\ln\frac{1}{\mu_{\min}} + \ln\frac{1}{\epsilon})$ |
