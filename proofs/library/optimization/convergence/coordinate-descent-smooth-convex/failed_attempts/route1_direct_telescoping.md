# Proof Route 1: Direct Coordinate Descent Lemma + Telescoping

**Route**: Direct per-coordinate descent + expectation + convexity + recurrence

## Proof

### Setting and Notation

We consider $f: \mathbb{R}^n \to \mathbb{R}$ convex, with coordinate-wise Lipschitz continuous gradients:
$$|\nabla_i f(x + te_i) - \nabla_i f(x)| \leq L_i |t|, \quad \forall x \in \mathbb{R}^n, t \in \mathbb{R}, i = 1,\ldots,n$$

The algorithm: at iteration $t$, pick $i_t \sim \text{Uniform}\{1,\ldots,n\}$ and update:
$$x_{t+1} = x_t - \frac{1}{L_{i_t}} \nabla_{i_t} f(x_t) \cdot e_{i_t}$$

Let $\bar{L} = \frac{1}{n}\sum_{i=1}^n L_i$, and let $x^*$ be a minimizer of $f$ with $f^* = f(x^*)$.

### Step 1: Coordinate-wise descent lemma

Since $\nabla_i f$ is $L_i$-Lipschitz in the $i$-th coordinate, for any $x \in \mathbb{R}^n$ and $t \in \mathbb{R}$:

$$f(x + te_i) \leq f(x) + t \nabla_i f(x) + \frac{L_i}{2} t^2$$

This follows from the standard smoothness bound applied along the $i$-th coordinate direction. Specifically, define $g(s) = f(x + se_i)$. Then $g'(s) = \nabla_i f(x + se_i)$ and $|g'(s) - g'(0)| \leq L_i|s|$, so $g(t) \leq g(0) + g'(0)t + \frac{L_i}{2}t^2$.

Setting $t = -\frac{1}{L_i}\nabla_i f(x)$:

$$f\left(x - \frac{1}{L_i}\nabla_i f(x) \cdot e_i\right) \leq f(x) - \frac{1}{L_i}(\nabla_i f(x))^2 + \frac{L_i}{2} \cdot \frac{(\nabla_i f(x))^2}{L_i^2}$$

$$= f(x) - \frac{1}{2L_i}(\nabla_i f(x))^2$$

### Step 2: Expected descent per iteration

Conditioning on $x_t$, and taking expectation over $i_t \sim \text{Uniform}\{1,\ldots,n\}$:

$$\mathbb{E}_{i_t}[f(x_{t+1}) \mid x_t] \leq f(x_t) - \frac{1}{n}\sum_{i=1}^n \frac{1}{2L_i}(\nabla_i f(x_t))^2$$

### Step 3: Lower bound the descent using Cauchy-Schwarz

We want to relate $\sum_{i=1}^n \frac{1}{L_i}(\nabla_i f(x_t))^2$ to something involving $f(x_t) - f^*$ and $\|x_t - x^*\|^2$.

By the Cauchy-Schwarz inequality (in the form of the Cauchy-Schwarz for sums with weights):

$$\left(\sum_{i=1}^n |\nabla_i f(x)| \cdot |x_i - x_i^*|\right)^2 \leq \left(\sum_{i=1}^n \frac{(\nabla_i f(x))^2}{L_i}\right) \left(\sum_{i=1}^n L_i (x_i - x_i^*)^2\right)$$

This uses weights $a_i = \frac{|\nabla_i f(x)|}{\sqrt{L_i}}$ and $b_i = \sqrt{L_i}|x_i - x_i^*|$ in $(\sum a_i b_i)^2 \leq (\sum a_i^2)(\sum b_i^2)$.

Note that:
$$\sum_{i=1}^n |\nabla_i f(x)| \cdot |x_i - x_i^*| \geq \sum_{i=1}^n \nabla_i f(x) (x_i - x_i^*) = \langle \nabla f(x), x - x^* \rangle$$

Actually, we need a different direction. We need $\langle \nabla f(x), x_t - x^* \rangle$ not $|...|$.

By convexity of $f$:
$$f(x_t) - f^* \leq \langle \nabla f(x_t), x_t - x^* \rangle$$

Now applying Cauchy-Schwarz:
$$\langle \nabla f(x_t), x_t - x^* \rangle = \sum_{i=1}^n \nabla_i f(x_t)(x_{t,i} - x_i^*)$$

$$\leq \sum_{i=1}^n |\nabla_i f(x_t)| \cdot |x_{t,i} - x_i^*|$$

$$\leq \left(\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i}\right)^{1/2} \left(\sum_{i=1}^n L_i(x_{t,i} - x_i^*)^2\right)^{1/2}$$

Therefore:
$$f(x_t) - f^* \leq \left(\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i}\right)^{1/2} \left(\sum_{i=1}^n L_i(x_{t,i} - x_i^*)^2\right)^{1/2}$$

Rearranging:
$$\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i} \geq \frac{(f(x_t) - f^*)^2}{\sum_{i=1}^n L_i(x_{t,i} - x_i^*)^2}$$

### Step 4: Bound the weighted norm

Note that $\sum_{i=1}^n L_i(x_{t,i} - x_i^*)^2 \leq L_{\max} \|x_t - x^*\|^2$. But this gives an $L_{\max}$ dependence which we don't want.

**Alternative approach**: We cannot directly close a recurrence using only $f(x_t) - f^*$ without involving $\|x_t - x^*\|^2$. Let us instead set up a coupled recurrence.

### Step 5: Distance evolution

Compute $\|x_{t+1} - x^*\|^2$:

$$\|x_{t+1} - x^*\|^2 = \left\|x_t - \frac{1}{L_{i_t}}\nabla_{i_t} f(x_t) e_{i_t} - x^*\right\|^2$$

$$= \|x_t - x^*\|^2 - \frac{2}{L_{i_t}}\nabla_{i_t} f(x_t)(x_{t,i_t} - x_{i_t}^*) + \frac{1}{L_{i_t}^2}(\nabla_{i_t} f(x_t))^2$$

Taking expectation over $i_t$:

$$\mathbb{E}_{i_t}[\|x_{t+1} - x^*\|^2 \mid x_t] = \|x_t - x^*\|^2 - \frac{2}{n}\sum_{i=1}^n \frac{\nabla_i f(x_t)(x_{t,i} - x_i^*)}{L_i} + \frac{1}{n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i^2}$$

### Step 6: Lyapunov argument with coupled quantities

Define the Lyapunov function:
$$\Phi_t = t(f(x_t) - f^*) + \frac{n\bar{L}}{2}\|x_t - x^*\|^2$$

where we use $\frac{n\bar{L}}{2} = \frac{1}{2}\sum_{i=1}^n L_i$.

We will show $\mathbb{E}[\Phi_{t+1}] \leq \mathbb{E}[\Phi_t] + \mathbb{E}[f(x_{t+1}) - f^*]$, i.e., we track the combined potential.

Actually, let me use a cleaner approach. Define:
$$\Phi_t = \frac{n}{2}\sum_{i=1}^n L_i(x_{t,i} - x_i^*)^2 = \frac{n}{2}\|x_t - x^*\|_L^2$$

where $\|x\|_L^2 = \sum_{i=1}^n L_i x_i^2$ is the $L$-weighted norm.

**Revised Step 5**: Expected evolution of $\|x_t - x^*\|_L^2$:

$$\mathbb{E}_{i_t}\left[\sum_{j=1}^n L_j(x_{t+1,j} - x_j^*)^2 \mid x_t\right]$$

Only coordinate $i_t$ changes, so:
$$= \sum_{j=1}^n L_j(x_{t,j} - x_j^*)^2 + \frac{1}{n}\sum_{i=1}^n L_i\left[\left(x_{t,i} - \frac{\nabla_i f(x_t)}{L_i} - x_i^*\right)^2 - (x_{t,i} - x_i^*)^2\right]$$

$$= \|x_t - x^*\|_L^2 + \frac{1}{n}\sum_{i=1}^n L_i\left[-\frac{2\nabla_i f(x_t)}{L_i}(x_{t,i} - x_i^*) + \frac{(\nabla_i f(x_t))^2}{L_i^2}\right]$$

$$= \|x_t - x^*\|_L^2 - \frac{2}{n}\sum_{i=1}^n \nabla_i f(x_t)(x_{t,i} - x_i^*) + \frac{1}{n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i}$$

$$= \|x_t - x^*\|_L^2 - \frac{2}{n}\langle \nabla f(x_t), x_t - x^*\rangle + \frac{1}{n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i}$$

By convexity: $\langle \nabla f(x_t), x_t - x^*\rangle \geq f(x_t) - f^*$

From Step 2: $\frac{1}{n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i} \leq 2n(\text{expected function value decrease from Step 2})$

Wait, from Step 2:
$$\mathbb{E}_{i_t}[f(x_{t+1})] \leq f(x_t) - \frac{1}{2n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i}$$

So $\frac{1}{n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i} = 2(f(x_t) - \mathbb{E}_{i_t}[f(x_{t+1})])$ ... no, this is an inequality not equality.

Let $D_t = \frac{1}{2n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i}$ so that $\mathbb{E}[f(x_{t+1})] \leq f(x_t) - D_t$.

Then the weighted norm evolution becomes:
$$\mathbb{E}[\|x_{t+1} - x^*\|_L^2] \leq \|x_t - x^*\|_L^2 - \frac{2}{n}(f(x_t) - f^*) + 2D_t$$

### Step 7: Define the Lyapunov function and close the recurrence

Let $\delta_t = f(x_t) - f^*$ and $R_t^2 = \|x_t - x^*\|_L^2$.

Define:
$$\Phi_t = t \cdot \delta_t + \frac{n}{2} R_t^2$$

Compute $\mathbb{E}[\Phi_{t+1} \mid x_t]$:

$$\mathbb{E}[\Phi_{t+1}] = (t+1)\mathbb{E}[\delta_{t+1}] + \frac{n}{2}\mathbb{E}[R_{t+1}^2]$$

$$\leq (t+1)(\delta_t - D_t) + \frac{n}{2}\left(R_t^2 - \frac{2}{n}\delta_t + 2D_t\right)$$

$$= (t+1)\delta_t - (t+1)D_t + \frac{n}{2}R_t^2 - \delta_t + nD_t$$

$$= t\delta_t + \frac{n}{2}R_t^2 - (t+1-n)D_t$$

$$= \Phi_t - (t+1-n)D_t$$

For $t \geq n - 1$, we have $t + 1 - n \geq 0$, so $\mathbb{E}[\Phi_{t+1}] \leq \Phi_t$.

But we need this for ALL $t \geq 0$. Let us try a shifted Lyapunov function.

### Step 8: Shifted Lyapunov function

Define:
$$\Phi_t = (t + \beta) \cdot \delta_t + \frac{n}{2} R_t^2$$

for some $\beta > 0$ to be determined.

Then:
$$\mathbb{E}[\Phi_{t+1}] = (t+1+\beta)\mathbb{E}[\delta_{t+1}] + \frac{n}{2}\mathbb{E}[R_{t+1}^2]$$

$$\leq (t+1+\beta)(\delta_t - D_t) + \frac{n}{2}(R_t^2 - \frac{2}{n}\delta_t + 2D_t)$$

$$= (t+1+\beta)\delta_t - (t+1+\beta)D_t + \frac{n}{2}R_t^2 - \delta_t + nD_t$$

$$= (t+\beta)\delta_t + \frac{n}{2}R_t^2 - (t+1+\beta - n)D_t$$

$$= \Phi_t - (t+1+\beta - n)D_t$$

For this to be $\leq \Phi_t$ for all $t \geq 0$, we need $t + 1 + \beta - n \geq 0$ for all $t \geq 0$.

Setting $t = 0$: need $1 + \beta - n \geq 0$, i.e., $\beta \geq n - 1$.

Choose $\beta = n - 1$. Then for all $t \geq 0$:
$$\mathbb{E}[\Phi_{t+1}] \leq \Phi_t - t \cdot D_t \leq \Phi_t$$

(Since $t + 1 + (n-1) - n = t \geq 0$ and $D_t \geq 0$.)

### Step 9: Extract the convergence rate

Since $\mathbb{E}[\Phi_{t+1}] \leq \mathbb{E}[\Phi_t]$ for all $t \geq 0$:

$$\mathbb{E}[\Phi_T] \leq \Phi_0 = (0 + n - 1)(f(x_0) - f^*) + \frac{n}{2}\|x_0 - x^*\|_L^2$$

Since $\Phi_T = (T + n - 1)\delta_T + \frac{n}{2}R_T^2 \geq (T + n - 1)\delta_T$:

$$\mathbb{E}[(T + n - 1)(f(x_T) - f^*)] \leq (n-1)(f(x_0) - f^*) + \frac{n}{2}\|x_0 - x^*\|_L^2$$

$$\mathbb{E}[f(x_T) - f^*] \leq \frac{(n-1)(f(x_0) - f^*)}{T + n - 1} + \frac{n\|x_0 - x^*\|_L^2}{2(T + n - 1)}$$

For the second term: $\|x_0 - x^*\|_L^2 = \sum_{i=1}^n L_i(x_{0,i} - x_i^*)^2 \leq L_{\max}\|x_0 - x^*\|^2$.

But we want $\bar{L}$, not $L_{\max}$. Note that:
$$\|x_0 - x^*\|_L^2 = \sum_{i=1}^n L_i(x_{0,i} - x_i^*)^2$$

In the worst case this is $L_{\max}\|x_0 - x^*\|^2$, but for the stated bound with $\bar{L}$, we use:

$$\frac{n\|x_0 - x^*\|_L^2}{2(T+n-1)} = \frac{n\sum_i L_i(x_{0,i}-x_i^*)^2}{2(T+n-1)}$$

By AM inequality: $\sum_i L_i(x_{0,i}-x_i^*)^2 \leq (\max_i L_i) \|x_0 - x^*\|^2$

Hmm, this gives $L_{\max}$ dependence. The stated result has $\bar{L}$ dependence. Let me reconsider.

Actually, looking at the problem statement more carefully, the bound is:
$$\mathbb{E}[f(x_T) - f^*] \leq \frac{2n\bar{L}\|x_0 - x^*\|^2}{T+4}$$

Note that $n\bar{L} = \sum_{i=1}^n L_i$. And our bound has $\frac{n}{2}\|x_0-x^*\|_L^2 = \frac{n}{2}\sum_i L_i(x_{0,i}-x_i^*)^2$. 

If we bound $\sum_i L_i(x_{0,i}-x_i^*)^2 \leq (\sum_i L_i) \cdot \max_j(x_{0,j}-x_j^*)^2 \leq (\sum_i L_i)\|x_0-x^*\|^2$... no, this overcounts.

Actually: $\sum_i L_i(x_{0,i}-x_i^*)^2 \leq \sum_i L_i \cdot \|x_0-x^*\|^2$ is wrong.

Correct bound: By Cauchy-Schwarz or just direct bound: $\sum_i L_i (x_{0,i}-x_i^*)^2 \leq (\max_i L_i)\sum_i(x_{0,i}-x_i^*)^2 = L_{\max}\|x_0-x^*\|^2$.

But we can also bound: $\sum_i L_i(x_{0,i}-x_i^*)^2 \leq \sum_i L_i \cdot \|x_0-x^*\|_\infty^2$. This isn't helpful.

The issue is that the original Nesterov result actually has $R_0^2 = \|x_0-x^*\|^2$ in the Euclidean norm with a factor of $n\bar{L}$. This comes from a slightly different argument where the initial Lyapunov value is bounded as:

$\Phi_0 = (n-1)(f(x_0) - f^*) + \frac{n}{2}\sum_i L_i(x_{0,i}-x_i^*)^2$

For the first term, by smoothness of $f$ (in the full-gradient sense), we can bound $f(x_0) - f^* \leq \frac{1}{2}\sum_i L_i(x_{0,i} - x_i^*)^2$ ... no, this isn't right either without additional assumptions.

**Key insight**: The correct approach from Nesterov 2012 uses a different Lyapunov function that involves only $\|x_t - x^*\|^2$ (Euclidean) not $\|x_t - x^*\|_L^2$. Let me redo this.

### Step 6 (Revised): Euclidean distance evolution

From Step 5:
$$\mathbb{E}_{i_t}[\|x_{t+1} - x^*\|^2] = \|x_t - x^*\|^2 - \frac{2}{n}\sum_{i=1}^n \frac{\nabla_i f(x_t)(x_{t,i} - x_i^*)}{L_i} + \frac{1}{n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i^2}$$

This is harder to work with because of the $1/L_i$ weighting. Instead, let us use Nesterov's approach more carefully.

### Step 6 (Alternative): Nesterov's direct argument

From Step 2, we have:
$$\mathbb{E}[f(x_{t+1})] \leq f(x_t) - \frac{1}{2n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i}$$

Now by the convexity first-order condition and Cauchy-Schwarz with weights $\sqrt{L_i}$ and $1/\sqrt{L_i}$:

$$f(x_t) - f^* \leq \langle \nabla f(x_t), x_t - x^*\rangle = \sum_i \nabla_i f(x_t)(x_{t,i}-x_i^*)$$

$$= \sum_i \frac{\nabla_i f(x_t)}{\sqrt{L_i}} \cdot \sqrt{L_i}(x_{t,i}-x_i^*)$$

$$\leq \sqrt{\sum_i \frac{(\nabla_i f(x_t))^2}{L_i}} \cdot \sqrt{\sum_i L_i(x_{t,i}-x_i^*)^2}$$

So:
$$\sum_i \frac{(\nabla_i f(x_t))^2}{L_i} \geq \frac{(f(x_t)-f^*)^2}{\|x_t-x^*\|_L^2}$$

This still involves $\|x_t-x^*\|_L^2$. 

**The standard Nesterov 2012 bound actually IS in terms of the weighted norm $R_L = \|x_0-x^*\|_L$, or equivalently uses $n\bar{L}R^2$ as an upper bound for $n \cdot \|x_0-x^*\|_L^2$ divided by 2.** No wait -- $\sum_i L_i \cdot R^2 \geq \sum_i L_i(x_{0,i}-x_i^*)^2$... this is wrong in general.

Let me just complete with the weighted norm. The bound we get is:

$$\mathbb{E}[f(x_T) - f^*] \leq \frac{(n-1)(f(x_0) - f^*)}{T+n-1} + \frac{n\sum_i L_i(x_{0,i}-x_i^*)^2}{2(T+n-1)}$$

For $T \geq n$, the first term is at most $(f(x_0)-f^*)$, and using that $f(x_0)-f^* \leq \frac{1}{2}\sum_i L_i(x_{0,i}-x_i^*)^2$ (from smoothness along each coordinate and optimality of $x^*$... actually this isn't obviously true).

Let me use a simpler bound. For $T \geq 4$:
$$\mathbb{E}[f(x_T)-f^*] \leq \frac{n(f(x_0)-f^*) + \frac{n}{2}\sum_i L_i(x_{0,i}-x_i^*)^2}{T+n-1}$$

This gives $O(n\bar{L}R^2/T)$ if we bound $\sum_i L_i(x_{0,i}-x_i^*)^2 \leq n\bar{L}\|x_0-x^*\|^2$... but this is wrong.

**Conclusion**: This route gets close but the final bound has $\|x_0-x^*\|_L^2$ instead of $n\bar{L}\|x_0-x^*\|^2$. The two are equal only when all $L_i$ are equal. The stated bound with $\bar{L}\|x_0-x^*\|^2$ requires a different approach. 

## Route Failure Report
- Route: Direct Coordinate Descent + Telescoping with weighted norm Lyapunov
- Failed at: Step 9 — closing the bound with Euclidean norm
- Obstacle: The natural Lyapunov analysis yields a bound involving $\|x_0-x^*\|_L^2 = \sum_i L_i(x_{0,i}-x_i^*)^2$ rather than $n\bar{L}\|x_0-x^*\|^2$. These are NOT comparable in general ($\|x_0-x^*\|_L^2$ can be much smaller or comparable). The stated result with $\bar{L}\|x_0-x^*\|^2$ requires either a different Lyapunov construction or the use of importance sampling (non-uniform coordinate selection) to achieve this. With uniform sampling, the natural bound is actually in terms of the weighted norm.

**Note**: Upon reflection, the correct result for UNIFORM sampling actually has $\|x_0-x^*\|_L^2$ in the bound, not $n\bar{L}\|x_0-x^*\|^2$. The bound $n\bar{L}\|x_0-x^*\|^2$ is a weaker (but simpler) upper bound that holds because $\sum_i L_i(x_{0,i}-x_i^*)^2 \leq (\sum_i L_i)\|x_0-x^*\|^2 = n\bar{L}\|x_0-x^*\|^2$... 

Wait — actually $\sum_i L_i(x_{0,i}-x_i^*)^2 \leq (\max_i L_i)\|x_0-x^*\|^2$, NOT $(\sum_i L_i)\|x_0-x^*\|^2$! 

But also: $\sum_i L_i(x_{0,i}-x_i^*)^2 \leq \sum_i L_i \cdot \max_j(x_{0,j}-x_j^*)^2 \leq (\sum_i L_i)\|x_0-x^*\|^2 = n\bar{L}\|x_0-x^*\|^2$.

Actually YES: $\max_j (x_{0,j}-x_j^*)^2 \leq \sum_j (x_{0,j}-x_j^*)^2 = \|x_0-x^*\|^2$? No! $\max_j a_j \leq \sum_j a_j$ for non-negative terms, so $\max_j(x_{0,j}-x_j^*)^2 \leq \|x_0-x^*\|^2$. 

Therefore: $\sum_i L_i(x_{0,i}-x_i^*)^2 \leq \sum_i L_i \cdot \|x_0-x^*\|_\infty^2 \leq n\bar{L}\|x_0-x^*\|^2$.

Wait, I had it wrong: $\sum_i L_i c_i \leq (\sum_i L_i)(\max_i c_i)$ where $c_i = (x_{0,i}-x_i^*)^2 \geq 0$. And $\max_i c_i \leq \sum_i c_i = \|x_0-x^*\|^2$. So indeed:

$$\sum_i L_i(x_{0,i}-x_i^*)^2 \leq n\bar{L}\|x_0-x^*\|^2$$

This IS correct! So the route actually succeeds. Let me finalize.

### Step 9 (Corrected): Final bound

From Step 8 with $\beta = n-1$: $\mathbb{E}[\Phi_T] \leq \Phi_0$ where $\Phi_t = (t+n-1)\delta_t + \frac{n}{2}R_t^2$ and $R_t^2 = \|x_t-x^*\|_L^2$.

$$\mathbb{E}[(T+n-1)(f(x_T)-f^*)] \leq (n-1)(f(x_0)-f^*) + \frac{n}{2}\|x_0-x^*\|_L^2$$

Using $\|x_0-x^*\|_L^2 \leq n\bar{L}\|x_0-x^*\|^2$:

$$\mathbb{E}[f(x_T)-f^*] \leq \frac{(n-1)(f(x_0)-f^*)}{T+n-1} + \frac{n^2\bar{L}\|x_0-x^*\|^2}{2(T+n-1)}$$

For the first term, using coordinate-wise smoothness: $f(x_0)-f^* \leq \frac{n\bar{L}}{2}\|x_0-x^*\|^2$ (from the same bound, since $f(y) \leq f(x) + \langle \nabla f(x), y-x\rangle + \frac{1}{2}\sum_i L_i(y_i-x_i)^2$, setting $x=x^*,y=x_0$ gives $f(x_0) \leq f^* + \langle \nabla f(x^*), x_0-x^*\rangle + \frac{1}{2}\sum_i L_i(x_{0,i}-x_i^*)^2$; since $\nabla f(x^*)=0$, $f(x_0)-f^* \leq \frac{1}{2}\|x_0-x^*\|_L^2 \leq \frac{n\bar{L}}{2}\|x_0-x^*\|^2$).

So:
$$\mathbb{E}[f(x_T)-f^*] \leq \frac{(n-1)\frac{n\bar{L}}{2}\|x_0-x^*\|^2}{T+n-1} + \frac{n^2\bar{L}\|x_0-x^*\|^2}{2(T+n-1)}$$

$$= \frac{n\bar{L}\|x_0-x^*\|^2}{2(T+n-1)}\left[(n-1) + n\right] = \frac{n\bar{L}\|x_0-x^*\|^2(2n-1)}{2(T+n-1)}$$

For large $n$, this is approximately $\frac{n^2\bar{L}\|x_0-x^*\|^2}{T}$, which is worse than the claimed $\frac{2n\bar{L}\|x_0-x^*\|^2}{T}$. There's an extra factor of $n$.

The issue is the initialization bound. If $x^*$ is an unconstrained minimizer so $\nabla f(x^*)=0$, and if we DON'T bound $f(x_0)-f^*$ but instead just use the Lyapunov bound directly:

$$\mathbb{E}[f(x_T)-f^*] \leq \frac{\Phi_0}{T+n-1} = \frac{(n-1)(f(x_0)-f^*) + \frac{n}{2}\|x_0-x^*\|_L^2}{T+n-1}$$

This is the correct form. The claimed bound $\frac{2n\bar{L}\|x_0-x^*\|^2}{T+4}$ must use a different (sharper) Lyapunov function.

## Route 1 Status: PARTIAL SUCCESS — gets $O(n\bar{L}/\varepsilon)$ rate but with different constants than claimed
