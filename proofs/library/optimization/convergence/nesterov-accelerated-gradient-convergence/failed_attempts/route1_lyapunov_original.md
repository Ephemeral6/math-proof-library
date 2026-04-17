# Proof Route 1: Lyapunov / Energy Function Approach

**Route**: Lyapunov energy function with auxiliary sequence

## Setup and Notation

Let f: ℝ^d → ℝ be convex with L-Lipschitz continuous gradient, i.e., for all x, y:
- f(y) ≤ f(x) + ⟨∇f(x), y - x⟩ + (L/2)||y - x||²  (L-smoothness / descent lemma)
- f(y) ≥ f(x) + ⟨∇f(x), y - x⟩  (convexity)

The algorithm with x₀ = x₋₁:
- y_k = x_k + ((k-1)/(k+2))(x_k - x_{k-1})
- x_{k+1} = y_k - (1/L)∇f(y_k)

Let x* be a minimizer of f, and f* = f(x*).

## Step 1: Introduce auxiliary sequence z_k

Define the auxiliary sequence:
- z₀ = x₀
- z_{k+1} = z_k - ((k+1)/(2L))∇f(y_k)

And define the relationship:
- y_k = x_k + (k-1)/(k+2) · (x_k - x_{k-1})

We will also verify that with these definitions:
- y_k = (k/(k+2))x_k + (2/(k+2))z_k  ... (*)

**Verification of (*) by induction:**

Base case k=0: y₀ = x₀ + 0 = x₀. RHS: (0/2)x₀ + (2/2)z₀ = z₀ = x₀. ✓

For the inductive step, we need to verify the relationship is consistent with the algorithm definition. We will actually use a different but equivalent reformulation. 

**Alternative**: Instead of proving (*) inductively (which requires careful bookkeeping), let us directly define z_k via:
- z₀ = x₀  
- z_{k+1} = z_k - ((k+1)/(2L))∇f(y_k)

And define y_k purely from the algorithm. Then define the Lyapunov function and work directly.

## Step 2: Define the Lyapunov function

Define:
$$V_k = k(k+1)(f(x_k) - f^*) + 2L\|z_k - x^*\|^2$$

where z_k is defined by the recursion above.

**Goal**: Show V_{k+1} ≤ V_k for all k ≥ 0.

If this holds, then:
$$k(k+1)(f(x_k) - f^*) \leq V_k \leq V_0 = 0 \cdot 1 \cdot (f(x_0) - f^*) + 2L\|x_0 - x^*\|^2 = 2L\|x_0 - x^*\|^2$$

giving:
$$f(x_k) - f^* \leq \frac{2L\|x_0 - x^*\|^2}{k(k+1)} \leq \frac{2L\|x_0 - x^*\|^2}{(k+1)^2}$$

since k(k+1) ≥ (k+1)² · k/(k+1) ... Actually, k(k+1) < (k+1)² for k ≥ 0, so this gives us a bound of 2L||x₀-x*||²/(k(k+1)), which is slightly better than 2L||x₀-x*||²/(k+1)².

Wait — we need (k+1)² in the denominator. Since k(k+1) = k² + k and (k+1)² = k² + 2k + 1, we have k(k+1) < (k+1)², so:
$$f(x_k) - f^* \leq \frac{2L\|x_0 - x^*\|^2}{k(k+1)}$$

This is actually a stronger bound. The claimed bound with (k+1)² follows since k(k+1) ≤ (k+1)² would go the wrong way. Let me reconsider...

Actually, the Lyapunov function should use (k+1)² terms. Let me redefine.

## Step 2 (Revised): Lyapunov function

Let t_k = (k+1)/2. Define:
$$V_k = t_k^2 (f(x_k) - f^*) + \frac{L}{2}\|z_k - x^*\|^2$$

where z₀ = x₀ and z_{k+1} = z_k - t_k/L · ∇f(y_k), and y_k = (1 - 1/t_{k+1})x_k + (1/t_{k+1})z_k, or equivalently via the algorithm.

Actually, let me use the cleaner formulation with integer sequences. Define:

$$V_k = \frac{(k+1)^2}{4}(f(x_k) - f^*) + \frac{L}{2}\|z_k - x^*\|^2$$

This doesn't simplify nicely. Let me switch to Route 3's approach which is cleaner.

## ROUTE FAILURE NOTE

This route is getting bogged down in the exact coefficient matching between the Lyapunov function coefficients and the algorithm's momentum parameter. The core difficulty is ensuring the t_k sequence, the momentum coefficient (k-1)/(k+2), and the z_k update all mesh perfectly.

Rather than continue with imprecise coefficients, I acknowledge this route attempt is incomplete. The correct approach via Lyapunov functions does work — see Route 3 for the clean version.
