# D17: Matrix Rényi entropy collapse detection (PARTIAL)

**Source claimed**: Internal Problem 7.5 — Matrix-SSL spectral entropy. **NO PUBLISHED SOURCE.**

**Local proof**: For PSD $K$ with $\mathrm{tr}(K)=1$, define $S_\alpha(K) = \frac{1}{1-\alpha}\log\mathrm{tr}(K^\alpha)$.
- (a) PASS: $S_\alpha(K) = 0 \iff \mathrm{rank}(K) = 1$.
- (b) PASS: $S_\alpha(K) \le \log n$ with equality iff $K = I/n$.
- (c) PARTIAL/conditional: gradient flow $\dot F = -\nabla L_{\text{MSSL}}(F)$ with $K(F) = FF^\top/\|F\|_F^2$ satisfies $dS_\alpha(K(F))/dt \ge c\mu(S_\alpha^{\max} - S_\alpha(K))$ under hypotheses (H1)-(H4) (local strong convexity, geometric coupling, full-rank along trajectory for $0<\alpha<1$).

**Literature search**:
- Bach 2022 ("Information Theory with Kernel Methods", arXiv 2202.08545) introduces matrix-form (von Neumann) entropy in kernel methods.
- Skean-Garcia-Galli-Bizzaro et al. 2023+ ("Matrix Entropy and Self-Supervised Learning"): use Matrix Rényi entropy as SSL objective. Properties (a) and (b) are essentially folklore (Rényi entropy on simplex; specialize to spectrum of density operator).
- Zhang et al. ICML 2024 (= D14 source): use matrix entropy/cross-entropy, but do not state collapse-detection theorem in this form.

**Properties (a) and (b)** are textbook quantum-information / Rényi-entropy results applied to the spectrum (Tao 2012 "Topics in Random Matrix Theory" §2, or Bhatia "Matrix Analysis" Ch. IX).

**Property (c)** — the gradient-flow PL-type monotonicity in entropy near the maximum-entropy state — is genuinely non-trivial. The local proof works it out via:
- Functional calculus for $d(K^\alpha) = \alpha K^{\alpha-1}dK$.
- Explicit computation of $R(K) := \nabla_K S_\alpha - \frac{\alpha}{1-\alpha}I$.
- Local Taylor of $S_\alpha$ around $K=I/n$, getting entropy gap $G(K) = \frac{\alpha}{2n}\sum\delta_i^2 + O$ and gradient norm $\|RK^{1/2}\|^2 = \frac{\alpha^2}{n}\sum\delta_i^2 + O$, hence ratio $1/(2\alpha)$.

This local PL-type analysis around the maximum-entropy state, with explicit constant $1/(2\alpha)$, is **NOT** a result I can attribute to published literature. The technique (functional calculus + chain rule + local Taylor) is standard machine but the assembly is original.

**Verdict**: 
- (a)(b): C-class textbook (folklore).
- (c): **NOVEL** but conditional on heavy hypotheses (H1)-(H4). The PL-monotonicity result is plausibly original; closest published work would be Bach 2022's information-theoretic SSL framework, which doesn't state this theorem.

**Defensibility as novel**: MEDIUM. Property (c) is a defensibly original theoretical contribution — a PL/Łojasiewicz-type inequality for matrix Rényi entropy near max-entropy states. The hypotheses are heavy (full local strong convexity, explicit geometric coupling), so the result is a *conditional* one. Numerical verification (200 Euler steps, no monotonicity violations) gives some empirical support.

**Caveats**: hypotheses are not derived from any concrete SSL loss; (H3) "geometric coupling" is essentially what needs to be proven, not assumed. So (c) is a "conditional structural claim" rather than a verified algorithm-level guarantee.
