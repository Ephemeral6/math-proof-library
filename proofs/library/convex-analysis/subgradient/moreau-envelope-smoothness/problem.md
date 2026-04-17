# Moreau Envelope Smoothness and Gradient Formula

## Source
- Paper: Moreau 1965; Rockafellar & Wets 1998 "Variational Analysis"
- Context: Fundamental tool in proximal algorithms and nonsmooth optimization

## Statement

**Theorem (Moreau Envelope Properties).** Let $f: \mathbb{R}^d \to \mathbb{R} \cup \{+\infty\}$ be a proper, closed, convex function. For $\lambda > 0$, define the Moreau envelope:

$$M_\lambda f(x) = \inf_{y} \left\{f(y) + \frac{1}{2\lambda}\|y - x\|^2\right\} = f(\text{prox}_{\lambda f}(x)) + \frac{1}{2\lambda}\|x - \text{prox}_{\lambda f}(x)\|^2$$

where $\text{prox}_{\lambda f}(x) = \arg\min_y \{f(y) + \frac{1}{2\lambda}\|y-x\|^2\}$.

**Prove the following:**

(a) $M_\lambda f$ is finite-valued and continuous everywhere on $\mathbb{R}^d$.

(b) $M_\lambda f$ is differentiable everywhere with gradient:
$$\nabla M_\lambda f(x) = \frac{1}{\lambda}(x - \text{prox}_{\lambda f}(x)).$$

(c) $\nabla M_\lambda f$ is $\frac{1}{\lambda}$-Lipschitz continuous, i.e., $M_\lambda f$ is $\frac{1}{\lambda}$-smooth.

(d) $M_\lambda f(x) \leq f(x)$ for all $x$, with equality iff $0 \in \partial f(x)$.

## Difficulty
research
