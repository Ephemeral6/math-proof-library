# Failed/deferred Candidate B — Multi-well coupled to ‖x‖

## What was attempted

Replace $h(z)$ with a coupled multi-well:
$$h_{\mathrm{coupled}}(x, z) := \frac{L}{4}(z^2 - D^2)^2/D^2 - q(\|x\|)\,z$$
where $q$ is a smooth coupling function so that the $z$-dynamics are excited
by the cycling on $x$.

## Status

**Deferred, not failed.** Candidate A's clean separation made B unnecessary.
Phase-5 audit did not flag any concern that would force B.

## Why deferred (not progressed beyond design sketch)

- **L-smoothness verification non-trivial**: the coupling $q(\|x\|)\,z$ has Hessian terms with $\|x\|$ derivatives that are messy.
- **Cycling identity may break**: the $x$-gradient picks up a $-q'(\|x\|)\hat x z$ term that depends on $z$. Even if $z$ stays small, this could perturb the projection-cycle identity (eq:star) by $O(q'\, z)$ per step, accumulating over $T$.
- **Candidate A is sharper**: its LB constant $B_{\mathrm{NC}}$ is path-wise (not just in expectation) and $\mu$-independent. Coupled construction would lose at least one of these.

## Conditions under which B might be needed

- If a future auditor argues that A's "decorative" non-convexity is too weak (i.e., the LB depends only on the convex sub-function), and demands a non-convexity that actively interacts with the cycling, then B is the natural fallback.
- If a downstream extension to higher-order optimization methods (Newton-momentum, Adam-momentum) requires non-trivial $z$-dynamics, B may be the right starting point.
