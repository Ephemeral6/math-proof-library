# Proof via Minimax / Saddle Point Approach

**Route**: Minimax / Saddle Point via Sion's Theorem

## Setup

Consider the convex optimization problem:
$$\min_{x} f_0(x) \quad \text{s.t.} \quad f_i(x) \leq 0,\; i=1,\ldots,m, \quad Ax = b$$

with $f_0, \ldots, f_m$ convex, $\mathcal{D} = \bigcap_{i=0}^m \text{dom}(f_i)$, and Slater's condition: there exists $\hat{x} \in \text{relint}(\mathcal{D})$ with $f_i(\hat{x}) < 0$, $A\hat{x} = b$.

Assume $p^* > -\infty$.

The Lagrangian is $L(x, \lambda, \nu) = f_0(x) + \sum_i \lambda_i f_i(x) + \nu^T(Ax-b)$.

Strong duality means: $\inf_{x \in \mathcal{D}} \sup_{\lambda \geq 0, \nu} L(x,\lambda,\nu) = \sup_{\lambda \geq 0, \nu} \inf_{x \in \mathcal{D}} L(x,\lambda,\nu)$.

## Step 1: Reformulation as Two-Set Separation

Define the set:
$$\mathcal{A} = \{(y, t) \in \mathbb{R}^m \times \mathbb{R} : \exists x \in \mathcal{D}, \; f_i(x) \leq y_i \; \forall i, \; Ax = b, \; f_0(x) \leq t\}$$

This set is convex (by convexity of $f_i$ and $\mathcal{D}$).

Define $\mathcal{B} = \{(y,t) : y < 0 \text{ (componentwise)}, \; t < p^*\}$, which is an open convex set.

**Claim**: $\mathcal{A} \cap \mathcal{B} = \emptyset$.

*Proof*: Suppose $(y,t) \in \mathcal{A} \cap \mathcal{B}$. Then there exists $x \in \mathcal{D}$ with $f_i(x) \leq y_i < 0$ and $Ax = b$ and $f_0(x) \leq t < p^*$. But this $x$ is feasible with value $f_0(x) < p^*$, contradicting $p^* = \inf$. $\square$

## Step 2: Apply Separating Hyperplane Theorem

Since $\mathcal{A}$ is convex, $\mathcal{B}$ is open and convex, and $\mathcal{A} \cap \mathcal{B} = \emptyset$, by the separating hyperplane theorem there exists $(\lambda, \mu) \in \mathbb{R}^m \times \mathbb{R}$, $(\lambda, \mu) \neq 0$, such that:

$$\lambda^T y + \mu t \leq \lambda^T y' + \mu t'$$

for all $(y,t) \in \mathcal{B}$ and $(y', t') \in \mathcal{A}$.

Equivalently: $\sup_{(y,t) \in \mathcal{B}} [\lambda^T y + \mu t] \leq \inf_{(y',t') \in \mathcal{A}} [\lambda^T y' + \mu t']$.

## Step 3: Determine Sign Constraints

**$\lambda \geq 0$**: Since $\mathcal{B}$ includes all $(y, t)$ with $y \ll 0$ and $t < p^*$, if $\lambda_i < 0$ for some $i$, we could take $y_i \to -\infty$ making the sup over $\mathcal{B}$ equal to $+\infty$, contradicting the finite bound. So $\lambda \geq 0$.

**$\mu \geq 0$**: Similarly, since $t$ ranges over $(-\infty, p^*)$ in $\mathcal{B}$, if $\mu < 0$, taking $t \to -\infty$ gives sup $= +\infty$. So $\mu \geq 0$.

## Step 4: Show $\mu > 0$ Using Slater's Condition

Suppose $\mu = 0$. Then the separating hyperplane is $\lambda^T y = c$ for some $c$, and $\lambda \geq 0$, $\lambda \neq 0$.

From the $\mathcal{B}$ side: $\sup_{y < 0} \lambda^T y = 0$ (since $\lambda \geq 0$, taking $y \to 0^-$).

From the $\mathcal{A}$ side: $\inf_{(y',t') \in \mathcal{A}} \lambda^T y' \geq 0$.

By Slater's condition, $\hat{x}$ satisfies $f_i(\hat{x}) < 0$, $A\hat{x} = b$. So $(f(\hat{x}), f_0(\hat{x})) \in \mathcal{A}$ with $f(\hat{x}) < 0$ componentwise.

Then $\lambda^T f(\hat{x}) < 0$ (since $\lambda \geq 0$, $\lambda \neq 0$, and $f(\hat{x}) < 0$). This gives $\inf_{\mathcal{A}} \lambda^T y' \leq \lambda^T f(\hat{x}) < 0$, contradicting $\inf_{\mathcal{A}} \lambda^T y' \geq 0$.

Therefore $\mu > 0$. Normalize $\mu = 1$ (divide everything by $\mu$).

## Step 5: Extract Dual Variables

After normalization ($\mu = 1$), we have $\lambda \geq 0$ (renaming $\lambda/\mu \to \lambda$) and:

$$\sup_{(y,t) \in \mathcal{B}} [\lambda^T y + t] \leq \inf_{(y',t') \in \mathcal{A}} [\lambda^T y' + t']$$

**Left side**: $\sup_{y < 0, t < p^*} [\lambda^T y + t] = 0 + p^* = p^*$ (since $\lambda \geq 0$, $\sup_{y<0} \lambda^T y = 0$; and $\sup_{t < p^*} t = p^*$).

**Right side**: $\inf_{(y',t') \in \mathcal{A}} [\lambda^T y' + t']$. For any $(y',t') \in \mathcal{A}$, there exists $x \in \mathcal{D}$ with $f(x) \leq y'$, $Ax = b$, $f_0(x) \leq t'$. Since $\lambda \geq 0$:
$$\lambda^T y' + t' \geq \lambda^T f(x) + f_0(x) = L(x, \lambda, 0) - 0 = f_0(x) + \lambda^T f(x)$$

Wait, we need to incorporate the equality constraint. Since $Ax = b$ for all points in $\mathcal{A}$, the $\nu^T(Ax-b)$ term vanishes. But the dual problem has $\nu$ as a free variable too.

Let me handle equality constraints. Redefine:
$$\mathcal{A} = \{(y, w, t) \in \mathbb{R}^m \times \mathbb{R}^p \times \mathbb{R} : \exists x \in \mathcal{D}, f_i(x) \leq y_i, Ax-b = w, f_0(x) \leq t\}$$

$$\mathcal{B} = \{(y, w, t) : y < 0, \; w = 0, \; t < p^*\}$$

$\mathcal{A}$ is convex, $\mathcal{B}$ is convex (but not open in $\mathbb{R}^{m+p+1}$). This creates issues with separation.

**Alternative**: Keep the original formulation but restrict to the affine subspace $\{x : Ax = b\}$.

Actually, the cleaner approach for problems with both inequality and equality constraints is to only separate in the $(y,t)$ space, having already fixed $Ax = b$.

Redefine:
$$\mathcal{A} = \{(y, t) \in \mathbb{R}^m \times \mathbb{R} : \exists x \in \mathcal{D} \text{ with } Ax=b, \; f_i(x) \leq y_i, \; f_0(x) \leq t\}$$

$\mathcal{B} = \{(y,t) : y_i < 0 \; \forall i, \; t < p^*\}$.

The separation argument goes through as before (Steps 2-4), yielding $\lambda \geq 0$ and (after normalization) $\mu = 1$ with:

$$p^* \leq \inf_{(y,t) \in \mathcal{A}} [\lambda^T y + t]$$

For any $x \in \mathcal{D}$ with $Ax = b$, setting $y = f(x)$ and $t = f_0(x)$:

$$p^* \leq \lambda^T f(x) + f_0(x) = f_0(x) + \lambda^T f(x)$$

Taking inf over all $x \in \mathcal{D}$ with $Ax = b$:

$$p^* \leq \inf_{x \in \mathcal{D}: Ax=b} [f_0(x) + \lambda^T f(x)]$$

But this doesn't yet give us the $\nu$ multiplier for the equality constraint.

## Step 6: Incorporating Equality Constraints via Extended Separation

To handle the $\nu$ multiplier, we use the full perturbation. Define:

$$\mathcal{A}' = \{(y, w, t) : \exists x \in \mathcal{D}, \; f_i(x) \leq y_i, \; Ax - b = w, \; f_0(x) \leq t\}$$

This is convex. Define:

$$\mathcal{B}' = \{(y, w, t) : y_i < 0 \; \forall i, \; w = 0, \; t \leq p^* - \epsilon\} \text{ for some } \epsilon > 0$$

$\mathcal{B}'$ is convex, and $\mathcal{A}' \cap \mathcal{B}' = \emptyset$ by the same argument.

But $\mathcal{B}'$ has empty interior (due to $w = 0$), so standard strict separation doesn't apply.

**Resolution**: Instead, separate $\mathcal{A}'$ from the half-space $H = \{(y,w,t) : y < 0, t < p^*\}$ projected to $w = 0$. Or better, use the perturbation function approach from Route 1.

## Route Failure Report

- **Route**: Minimax / Saddle Point via Sion's Theorem
- **Failed at**: Step 6 — incorporating equality constraints into the separation
- **Obstacle**: The equality constraint $Ax = b$ creates a thin set (affine subspace) that prevents clean separation in the full $(y,w,t)$ space. The approach works cleanly for inequality-only problems but requires additional machinery for equality constraints. Reducing to the restricted problem on $\{x : Ax = b\}$ yields a partial result ($g(\lambda, 0) \geq p^*$ restricted to $Ax = b$) but doesn't produce the $\nu^*$ multiplier.
- **What partially works**: For problems with ONLY inequality constraints (no $Ax = b$), Steps 1-5 provide a complete proof of strong duality via the two-set separation approach, yielding $\lambda^* \geq 0$ with $g(\lambda^*) = p^*$.
- **Suggested fix**: Combine with the perturbation function approach (Route 1) to handle equality constraints, or use the extended separation in the $(u,v,t)$ space with the perturbation function $p(u,v)$ which naturally handles both.
