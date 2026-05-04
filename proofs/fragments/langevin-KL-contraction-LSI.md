# Fragment: langevin-KL-contraction-LSI

## Statement
Let $\pi \propto e^{-f}$ on $\mathbb{R}^d$ satisfy the $\alpha$-log-Sobolev inequality (LSI):
$$\mathrm{FI}(\mu \| \pi) \;\ge\; 2\alpha\, \mathrm{KL}(\mu\|\pi)$$
for all probability densities $\mu$, where $\mathrm{FI}(\mu\|\pi) := \int \mu \|\nabla \log(\mu/\pi)\|^2$.

If $\mu_t$ is the marginal at time $t$ of the Langevin SDE $dY_t = -\nabla f(Y_t) dt + \sqrt{2}\, dB_t$, then:
$$\frac{d}{dt}\mathrm{KL}(\mu_t\|\pi) \;=\; -\mathrm{FI}(\mu_t\|\pi) \;\le\; -2\alpha\,\mathrm{KL}(\mu_t\|\pi).$$
By Grönwall:
$$\mathrm{KL}(\mu_t\|\pi) \;\le\; e^{-2\alpha(t-s)}\,\mathrm{KL}(\mu_s\|\pi).$$

## Proof
The Fokker-Planck equation gives $\partial_t \mu_t = \nabla\cdot(\mu_t \nabla\log(\mu_t/\pi))$. Differentiate the KL via the de Bruijn identity:
$$\frac{d}{dt}\mathrm{KL}(\mu_t\|\pi) = \int \log\!\bigl(\tfrac{\mu_t}{\pi}\bigr) \partial_t \mu_t = -\int \mu_t \|\nabla\log(\mu_t/\pi)\|^2 = -\mathrm{FI}(\mu_t\|\pi).$$
Apply LSI: $\mathrm{FI} \ge 2\alpha\,\mathrm{KL}$. Solve $g'(t) \le -2\alpha\, g(t)$ via Grönwall. $\square$

## Source
- `proofs/research/probability/sampling/ula-kl-convergence-lsi/proof.md` — Lemma 2.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (drives the Vempala-Wibisono ULA convergence rate under LSI)
- **Potential applications**:
  - ULA / SDE convergence rates in KL under LSI (or weaker: Talagrand T2)
  - Hamiltonian Monte Carlo, MALA convergence in KL
  - Continuous-time variants of langevin dynamics for sampling
  - Connections to hypercontractivity and Otto's calculus
  - Functional inequality bootstraps (Bakry-Émery curvature)

## Tags
langevin, LSI, KL, fisher-information, de-bruijn, sampling
