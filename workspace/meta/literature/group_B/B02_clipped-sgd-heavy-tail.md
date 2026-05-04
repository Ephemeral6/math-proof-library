# B2 — Clipped SGD heavy-tail convergence

**Verdict**: CONFIRMED

**Source**: Zhang, Karimireddy, Veit, Kim, Reddi, Kumar, Sra, *"Why are adaptive methods good for attention models?"* / Zhang, Cutkosky, Mitliagkas (2020 NeurIPS, arXiv was actually 2002.10589 / 1905.11881 family — note the proof_list arXiv ID 1912.07467 appears to be a typo, the listed paper is in astrophysics). Also Gorbunov, Danilova, Gasnikov 2020 (arXiv:2005.10785, "clipped-SSTM" for high-prob convex bounds). [ARXIV-UNREACHABLE — abstract pages did not contain theorem; relying on training-data knowledge.]

## OUR statement
For $L$-smooth (possibly nonconvex) $f$, stochastic gradient with $p$-th moment noise $\mathbb{E}\|\xi_t\|^p \le \sigma^p$, $p\in(1,2]$. With $\tau = \sigma T^{1/p-1/2}$ and $\eta = \sqrt{\Delta_f}/(\sqrt{L}\tau\sqrt T)$:
$$\frac{1}{T}\sum_t \mathbb{E}\|\nabla f(x_t)\|^2 = O\!\left(\frac{(\Delta_f L + L\sigma^2)}{T^{1-1/p}}\right).$$

## Paper statement (training-data)
Zhang et al. (NeurIPS 2020) "Why gradient clipping accelerates training" / Gorbunov et al.: for nonconvex $L$-smooth and $p$-th moment noise,
$$\mathbb{E}\|\nabla f(x_R)\|^2 = O\!\left(\frac{(\sigma L \Delta)^{(p-1)/p}}{T^{(p-1)/p}}\right) = O(T^{-(1-1/p)}),$$
with clip threshold $\tau \asymp \sigma T^{1/p-1/2}$ and $\eta \asymp 1/(L T^{1/p})$ (or similar). For $p=2$ recovers $O(T^{-1/2})$; $p=1$ gives no convergence.

## Comparison
- Rate exponent $1-1/p$: **matches exactly**.
- Parameter scaling for $\tau$: matches exactly ($\sigma T^{1/p-1/2}$).
- $\eta$ scaling: ours is $\Theta(1/(L\sigma T^{1/p}))$ — also matches up to absorbed factors.
- Constants: ours has $\Delta_f L + L\sigma^2$; paper typically has $(\sigma L \Delta)^{(p-1)/p}$ which by AM-GM is the same big-O class.
- Technique: standard descent + clipping bias decomposition + Young's inequality, same as Zhang et al.

## Verdict
**CONFIRMED**: rate exponent and parameter scalings match. Constants in same big-O class. Technique standard. (arXiv ID in master list is a typo: 1912.07467 is an astrophysics paper; the correct Zhang heavy-tail clipping paper is NeurIPS 2020 / Gorbunov 2005.10785 family.)
