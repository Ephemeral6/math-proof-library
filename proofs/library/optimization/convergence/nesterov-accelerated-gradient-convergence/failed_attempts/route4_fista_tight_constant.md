# Proof Route 4: Tight Lyapunov with Adjusted Parameterization

**Route**: Direct Lyapunov with the exact (k+1)² constant via adjusted parameterization

## Proof

### Setup

Let f: ℝ^d → ℝ be convex with L-Lipschitz continuous gradient:

**(S1)** f(x) ≤ f(y) + ⟨∇f(y), x - y⟩ + (L/2)||x - y||²  (descent lemma)

**(S2)** f(x) ≥ f(y) + ⟨∇f(y), x - y⟩  (convexity)

Let x* be a minimizer, f* = f(x*).

### Algorithm (Three-Sequence Form)

We use the parameterization with sequence {t_k} where t₀ = 1 and t_{k+1} = (1 + √(1+4t_k²))/2.

Define:
- z₀ = x₀ (arbitrary initial point)
- y_k = x_k + ((t_k - 1)/t_{k+1})(x_k - x_{k-1}), with x₋₁ = x₀ [original form]

Equivalently, define the auxiliary sequence:
- z₀ = x₀
- For k ≥ 0:
  - y_k = x_k + (t_k - 1)/(t_{k+1}) · (x_k - x_{k-1}) [with x₋₁ = x₀]
  - x_{k+1} = y_k - (1/L)∇f(y_k)
  - z_{k+1} = y_k - (1/L)∇f(y_k) = x_{k+1} [This isn't the right z_k]

Actually, let me use the clean parameterization that gives the tight constant.

### Algorithm (Clean Parameterization for Tight Bound)

Set t₀ = 1, and define t_{k+1} = (1 + √(1 + 4t_k²))/2.

**Key property**: t_{k+1}² - t_{k+1} = t_k², equivalently t_{k+1}(t_{k+1}-1) = t_k².

This gives t_k ≥ (k+2)/2 for all k ≥ 0. (Proof below.)

Define:
- x₀ = y₀ = z₀ (arbitrary)
- For k ≥ 0:
  - x_{k+1} = y_k - (1/L)∇f(y_k)
  - z_{k+1} = x_{k+1} + (t_k - 1)(x_{k+1} - x_k) / t_{k+1} ... 

No — let me use the cleanest known formulation from Chambolle-Dossal (2015) / Beck-Teboulle (FISTA, 2009).

### Algorithm (FISTA Form)

Set t₁ = 1. For k ≥ 1:
- x_k = y_{k-1} - (1/L)∇f(y_{k-1})
- t_{k+1} = (1 + √(1+4t_k²))/2
- y_k = x_k + ((t_k - 1)/t_{k+1})(x_k - x_{k-1})

**Lemma**: t_k ≥ (k+1)/2 for all k ≥ 1.

*Proof*: t₁ = 1 ≥ 2/2 = 1. ✓
Inductively: t_{k+1} = (1 + √(1+4t_k²))/2 ≥ (1 + 2t_k)/2 = t_k + 1/2.
So t_k ≥ 1 + (k-1)/2 = (k+1)/2. ∎

### Step 1: Lyapunov Function

Let v_k be defined by: v₁ = x₀, and:
$$v_{k+1} = \frac{1}{t_{k+1}}\left[x_k + (t_{k+1}-1)v_k\right] + \frac{t_k-1}{t_{k+1}}(x_k - x_{k-1})$$

Hmm, this is still getting messy. Let me use the simplest self-contained approach.

---

### CLEAN PROOF (Starting Fresh)

We use the formulation and proof from Beck and Teboulle (2009) / Tseng (2008).

**Algorithm**: Given x₁ = y₀ arbitrary, for k = 1, 2, ...:
1. x_{k+1} = y_k - (1/L)∇f(y_k)  
2. t_{k+1} = (1 + √(1 + 4t_k²))/2 with t₁ = 1
3. y_{k+1} = x_{k+1} + ((t_k - 1)/t_{k+1})(x_{k+1} - x_k)

**Claim**: f(x_{k+1}) - f* ≤ 2L||x₁ - x*||² / (k+1)² for all k ≥ 1.

### Step 1: One-Step Progress Lemma

From the descent lemma (S1):
$$f(x_{k+1}) \leq f(y_k) - \frac{1}{2L}\|\nabla f(y_k)\|^2 \tag{D}$$

Let g_k = ∇f(y_k). Note x_{k+1} = y_k - g_k/L, so g_k = L(y_k - x_{k+1}).

From (D), for any u ∈ ℝ^d, adding and subtracting using convexity f(u) ≥ f(y_k) + ⟨g_k, u - y_k⟩:

$$f(x_{k+1}) \leq f(u) + \langle g_k, y_k - u\rangle - \frac{1}{2L}\|g_k\|^2$$

$$= f(u) + \frac{L}{2}\left[\|y_k - u\|^2 - \|y_k - u - g_k/L\|^2\right]$$

$$= f(u) + \frac{L}{2}\left[\|y_k - u\|^2 - \|x_{k+1} - u\|^2\right] \tag{P}$$

This is the **proximal-gradient key inequality**.

### Step 2: Apply (P) with two choices of u

**Choice 1**: u = x_k in (P):
$$f(x_{k+1}) \leq f(x_k) + \frac{L}{2}[\|y_k - x_k\|^2 - \|x_{k+1} - x_k\|^2] \tag{P1}$$

**Choice 2**: u = x* in (P):
$$f(x_{k+1}) \leq f^* + \frac{L}{2}[\|y_k - x^*\|^2 - \|x_{k+1} - x^*\|^2] \tag{P2}$$

### Step 3: Weighted Combination

Take (1 - 1/t_{k+1}) × (P1) + (1/t_{k+1}) × (P2):

$$f(x_{k+1}) \leq (1 - \frac{1}{t_{k+1}})f(x_k) + \frac{1}{t_{k+1}}f^* + \frac{L}{2}\left[(1 - \frac{1}{t_{k+1}})\|y_k - x_k\|^2 + \frac{1}{t_{k+1}}\|y_k - x^*\|^2 - (1-\frac{1}{t_{k+1}})\|x_{k+1} - x_k\|^2 - \frac{1}{t_{k+1}}\|x_{k+1} - x^*\|^2\right]$$

Let α_k = 1/t_{k+1}. Then:

$$f(x_{k+1}) - f^* \leq (1-\alpha_k)(f(x_k) - f^*) + \frac{L}{2}\left[(1-\alpha_k)\|y_k - x_k\|^2 + \alpha_k\|y_k - x^*\|^2 - (1-\alpha_k)\|x_{k+1} - x_k\|^2 - \alpha_k\|x_{k+1}-x^*\|^2\right]$$

### Step 4: Define the Lyapunov Sequence

Define:
$$E_k = t_k^2(f(x_k) - f^*) + \frac{L}{2}\|w_k - x^*\|^2$$

where w_k is to be determined. We want E_{k+1} ≤ E_k.

Multiply the inequality from Step 3 by t_{k+1}²:

$$t_{k+1}^2(f(x_{k+1}) - f^*) \leq t_{k+1}^2(1-\alpha_k)(f(x_k) - f^*) + \frac{L}{2}t_{k+1}^2[\cdots]$$

Since α_k = 1/t_{k+1}, we have t_{k+1}²(1 - 1/t_{k+1}) = t_{k+1}(t_{k+1}-1) = t_k² (by the recursion).

So: 
$$t_{k+1}^2(f(x_{k+1}) - f^*) \leq t_k^2(f(x_k) - f^*) + \frac{Lt_{k+1}^2}{2}[\cdots] \tag{M}$$

Now for the distance terms:
$$\frac{Lt_{k+1}^2}{2}\left[(1-\alpha_k)\|y_k - x_k\|^2 + \alpha_k\|y_k - x^*\|^2\right]$$

With α_k = 1/t_{k+1}:
- t_{k+1}²(1-α_k) = t_{k+1}(t_{k+1}-1) = t_k²
- t_{k+1}² · α_k = t_{k+1}

So the positive distance terms are:
$$\frac{L}{2}\left[t_k^2\|y_k - x_k\|^2 + t_{k+1}\|y_k - x^*\|^2\right]$$

And the negative terms:
$$-\frac{L}{2}\left[t_k^2\|x_{k+1} - x_k\|^2 + t_{k+1}\|x_{k+1} - x^*\|^2\right]$$

### Step 5: Choose w_k and y_k to make things telescope

Define: **w_k = x_k + t_k(x_k - x_{k-1})** (or equivalently set up w_k so that the distance terms collapse).

Actually, define **w_k** by the recursion:
$$w_{k+1} = w_k + t_{k+1}(x_{k+1} - x_k) - (t_k - 1)(x_k - x_{k-1})$$

Hmm, this is still messy. Let me use the approach from the original FISTA paper more directly.

**Define**: u_k = x_k + t_k(x_k - x_{k-1}) and set w₁ = x₁. Then:

From y_k = x_k + ((t_k-1)/t_{k+1})(x_k - x_{k-1}), we can write:
$$t_{k+1}y_k = t_{k+1}x_k + (t_k - 1)(x_k - x_{k-1})$$

**Key definition**: Let w_k = x_k + t_k(x_k - x_{k-1}) = (1+t_k)x_k - t_k x_{k-1} (with x₀ = x₁, so w₁ = x₁).

Then:
$$t_{k+1}y_k - x_{k+1} = t_{k+1}x_k + (t_k-1)(x_k-x_{k-1}) - x_{k+1}$$
$$= (t_{k+1}-1)x_k + (t_k-1)(x_k-x_{k-1}) + x_k - x_{k+1}$$

This is getting quite involved. Let me take a step back and use the cleanest known proof technique.

---

### CLEANEST PROOF: Via the Two-Point Inequality

**Lemma (Two-point inequality)**: For L-smooth convex f, if x⁺ = y - (1/L)∇f(y), then for all u:
$$2L t² (f(x⁺) - f(u)) \leq 2Lt² \langle\nabla f(y), y - u\rangle - t²\|\nabla f(y)\|² \cdot (2L/L²)...$$

No, let me just use the clean result I know. Here is the proof that works.

---

### FINAL CLEAN PROOF

**Lyapunov function**: $\mathcal{E}_k = t_k^2(f(x_k) - f^*) + \frac{L}{2}\|v_k - x^*\|^2$

where $v_1 = x_1 = x_0$, $t_1 = 1$, and the updates are:
- $x_{k+1} = y_k - \frac{1}{L}\nabla f(y_k)$
- $t_{k+1} = \frac{1+\sqrt{1+4t_k^2}}{2}$  (so $t_{k+1}^2 = t_{k+1} + t_k^2$, i.e., $t_k^2 = t_{k+1}(t_{k+1}-1)$)
- $y_k = x_k + \frac{t_k - 1}{t_{k+1}}(x_k - x_{k-1})$
- $v_{k+1} = x_k + t_k(x_{k+1} - x_k)$  [or equivalently: $v_{k+1} = y_k - \frac{t_k}{L}\nabla f(y_k)$, since $x_{k+1} - y_k = -\nabla f(y_k)/L$ and $v_{k+1} = x_k + t_k(y_k - \frac{1}{L}\nabla f(y_k) - x_k)$...]

Let me define v_k cleanly. Note that y_k = x_k + ((t_k-1)/t_{k+1})(x_k - x_{k-1}).

Define: $v_{k+1} = v_k - \frac{t_k}{L}\nabla f(y_k)$, with $v_1 = x_1$.

Then: $v_{k+1} - x^* = v_k - x^* - \frac{t_k}{L}\nabla f(y_k)$

**Claim**: $y_k = \frac{t_k - 1}{t_{k+1}}x_k + \frac{1}{t_{k+1}}v_k + \text{correction}$... 

Actually, the key relationship we need is:
$$t_{k+1}y_k = t_k x_k + v_k$$

Let's verify: With $v_1 = x_1$ and $y_1 = x_1 + 0 = x_1$ (since $t_1=1$, $(t_1-1)/t_2 = 0$), we need $t_2 y_1 = t_1 x_1 + v_1 = x_1 + x_1 = 2x_1$, so $y_1 = 2x_1/t_2$. Since $t_2 = (1+\sqrt5)/2 \approx 1.618$, $y_1 = 2x_1/1.618 \neq x_1$ unless $t_2 = 2$. So this relationship doesn't hold with the exact $t_k$ sequence. 

It does hold if we use $t_k = (k+1)/2$ (which is a lower bound on the actual $t_k$). Let me switch to this simpler choice.

### THE SIMPLEST CLEAN PROOF: Using t_k = (k+1)/2

**Algorithm variant**: Set $\theta_k = 2/(k+2)$ for $k \geq 0$. Equivalently $t_k = (k+1)/2$.

- $z_0 = x_0$ 
- $y_k = (1-\theta_k)x_k + \theta_k z_k = \frac{k}{k+2}x_k + \frac{2}{k+2}z_k$
- $x_{k+1} = y_k - \frac{1}{L}\nabla f(y_k)$
- $z_{k+1} = z_k - \frac{1}{\theta_k L}\nabla f(y_k) \cdot \theta_k^2 \cdot ...$

Hmm — for the $t_k = (k+1)/2$ choice, $t_{k+1}(t_{k+1}-1) = ((k+2)/2)((k+2)/2 - 1) = ((k+2)/2)(k/2) = k(k+2)/4$, while $t_k^2 = (k+1)^2/4$. These are NOT equal (we'd need $k(k+2) = (k+1)^2$, i.e., $k^2+2k = k^2+2k+1$, which fails). So $t_k = (k+1)/2$ doesn't satisfy the FISTA recursion exactly.

This is why Route 3 with the $V_k = k(k+1)(f(x_k)-f^*) + 2L\|z_k-x^*\|^2$ Lyapunov function is the right approach — it naturally gives $k(k+1)$ in the denominator which is $\Theta(k^2)$.

**I defer to Route 3 for the complete proof.** Route 3 gives the clean O(1/k²) bound. The exact constant $2L/(k+1)^2$ requires a more careful choice of $t_k$ (the FISTA sequence) but the rate is the same.

## Route Failure Report
- Route: Tight Lyapunov with exact (k+1)² constant
- Failed at: Step 4-5, matching the Lyapunov decrease with the exact FISTA t_k sequence
- Obstacle: The bookkeeping for the exact constant is very delicate; the auxiliary variable definitions and the algorithm parameterization must be perfectly synchronized. The O(1/k²) rate is established in Route 3 with a slightly different constant.
