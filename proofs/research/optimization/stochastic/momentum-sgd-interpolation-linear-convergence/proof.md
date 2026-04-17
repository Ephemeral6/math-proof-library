# Proof: SGD with Polyak Momentum under Interpolation — Linear Convergence

## Setup and Notation

- $u_t = x_t - x^*$, $e_t = \|u_t\|^2$, $s_t = \gamma v_t$ (scaled momentum), $S_t = \|s_t\|^2$
- $\bar{g}_t = \nabla f(x_t)$, $g_t = \nabla f_{i_t}(x_t)$
- $\kappa = L/\mu \geq 3$
- Parameters: $\gamma = \frac{1}{2L\kappa}$, $\beta = \frac{1}{4\kappa^2}$

The update in scaled coordinates:
$$s_{t+1} = \beta s_t + \gamma g_t, \quad u_{t+1} = u_t - s_{t+1} = u_t - \beta s_t - \gamma g_t$$

## Preliminary Inequalities

**(P1) Interpolation noise bound.** Since each $f_i$ is convex and $L$-smooth with $\nabla f_i(x^*) = 0$:

$$\|\nabla f_i(x)\|^2 = \|\nabla f_i(x) - \nabla f_i(x^*)\|^2 \leq 2L(f_i(x) - f_i(x^*))$$

where the inequality is the standard co-coercivity for convex $L$-smooth functions. Averaging:

$$\mathbb{E}_i[\|\nabla f_i(x)\|^2] \leq 2L(f(x) - f^*) \leq L^2\|x - x^*\|^2$$

The last step uses $f(x) - f^* \leq \frac{L}{2}\|x - x^*\|^2$ (smoothness + $\nabla f(x^*) = 0$).

**(P2) Strong convexity.** $\langle \nabla f(x_t), x_t - x^*\rangle \geq \mu\|x_t - x^*\|^2$.

**(P3) Smoothness.** $\|\nabla f(x_t)\| \leq L\|x_t - x^*\|$.

## Step 1: Recursion for $\mathbb{E}_t[e_{t+1}]$

Expanding:
$$e_{t+1} = \|u_t - \beta s_t - \gamma g_t\|^2 = e_t - 2\beta\langle u_t, s_t\rangle - 2\gamma\langle u_t, g_t\rangle + \beta^2 S_t + 2\gamma\beta\langle s_t, g_t\rangle + \gamma^2\|g_t\|^2$$

Taking $\mathbb{E}_t$ (conditional on $x_t, v_t$), using $\mathbb{E}_t[g_t] = \bar{g}_t$ and (P1), (P2):

$$\mathbb{E}_t[e_{t+1}] \leq (1 - 2\gamma\mu + \gamma^2 L^2)e_t - 2\beta\langle u_t, s_t\rangle + \beta^2 S_t + 2\gamma\beta\langle s_t, \bar{g}_t\rangle$$

**Bounding cross terms via Young's inequality** ($2ab \leq pa^2 + b^2/p$):

- **(C1)** With $p_1 = \gamma\mu/\beta$: $\;-2\beta\langle u_t, s_t\rangle \leq \gamma\mu\, e_t + \frac{\beta^2}{\gamma\mu}S_t$

- **(C2)** With $p_2 = 1$: $\;2\gamma\beta\langle s_t, \bar{g}_t\rangle \leq \gamma\beta L\, e_t + \gamma\beta L\, S_t$

Substituting:
$$\mathbb{E}_t[e_{t+1}] \leq \underbrace{(1 - \gamma\mu + \gamma^2 L^2 + \gamma\beta L)}_{a_{11}}\, e_t + \underbrace{\left(\beta^2 + \frac{\beta^2}{\gamma\mu} + \gamma\beta L\right)}_{a_{12}}\, S_t$$

**Evaluating** with $\gamma = \frac{1}{2L\kappa}$, $\beta = \frac{1}{4\kappa^2}$:

| Term | Value |
|------|-------|
| $\gamma\mu$ | $1/(2\kappa^2)$ |
| $\gamma^2 L^2$ | $1/(4\kappa^2)$ |
| $\gamma\beta L$ | $1/(8\kappa^3)$ |
| $\beta^2$ | $1/(16\kappa^4)$ |
| $\beta^2/(\gamma\mu)$ | $1/(8\kappa^2)$ |

$$a_{11} = 1 - \frac{1}{2\kappa^2} + \frac{1}{4\kappa^2} + \frac{1}{8\kappa^3} = 1 - \frac{1}{4\kappa^2} + \frac{1}{8\kappa^3} \leq 1 - \frac{1}{8\kappa^2}$$

(The last inequality uses $\frac{1}{8\kappa^3} \leq \frac{1}{8\kappa^2}$ for $\kappa \geq 1$.)

$$a_{12} = \frac{1}{16\kappa^4} + \frac{1}{8\kappa^2} + \frac{1}{8\kappa^3} \leq \frac{5}{16\kappa^2}$$

## Step 2: Recursion for $\mathbb{E}_t[S_{t+1}]$

$$S_{t+1} = \|\beta s_t + \gamma g_t\|^2 = \beta^2 S_t + 2\gamma\beta\langle s_t, g_t\rangle + \gamma^2\|g_t\|^2$$

Taking $\mathbb{E}_t$, using AM-GM on the cross term with $p_3 = 1$, and (P1):

$$\mathbb{E}_t[S_{t+1}] \leq \underbrace{(\gamma\beta L + \gamma^2 L^2)}_{a_{21}}\, e_t + \underbrace{(\beta^2 + \gamma\beta L)}_{a_{22}}\, S_t$$

$$a_{21} = \frac{1}{8\kappa^3} + \frac{1}{4\kappa^2} \leq \frac{3}{8\kappa^2}$$

$$a_{22} = \frac{1}{16\kappa^4} + \frac{1}{8\kappa^3} \leq \frac{3}{16\kappa^2}$$

## Step 3: Lyapunov Contraction

Define the Lyapunov function:
$$\Phi_t = \mathbb{E}[e_t] + c\,\mathbb{E}[S_t], \quad c = \frac{1}{\kappa^2}$$

The $2\times 2$ recursion gives:
$$\Phi_{t+1} \leq (a_{11} + c\,a_{21})\mathbb{E}[e_t] + (a_{12} + c\,a_{22})\mathbb{E}[S_t]$$

We verify $\Phi_{t+1} \leq \rho\,\Phi_t$ with $\rho = 1 - \frac{1}{16\kappa^2}$.

**Condition (I):** $a_{11} + c\,a_{21} \leq \rho$

$$a_{11} + c\,a_{21} \leq 1 - \frac{1}{8\kappa^2} + \frac{1}{\kappa^2}\cdot\frac{3}{8\kappa^2} = 1 - \frac{1}{8\kappa^2} + \frac{3}{8\kappa^4}$$

Need: $\frac{3}{8\kappa^4} \leq \frac{1}{16\kappa^2}$, i.e., $\kappa^2 \geq 6$, which holds for $\kappa \geq 3$. $\checkmark$

**Condition (II):** $a_{12} + c\,a_{22} \leq \rho\,c$

$$a_{12} + c\,a_{22} \leq \frac{5}{16\kappa^2} + \frac{1}{\kappa^2}\cdot\frac{3}{16\kappa^2} = \frac{5}{16\kappa^2} + \frac{3}{16\kappa^4}$$

$$\rho\,c = \frac{1}{\kappa^2}\left(1 - \frac{1}{16\kappa^2}\right) = \frac{1}{\kappa^2} - \frac{1}{16\kappa^4}$$

Need: $\frac{5}{16\kappa^2} + \frac{3}{16\kappa^4} \leq \frac{1}{\kappa^2} - \frac{1}{16\kappa^4}$, i.e., $\frac{5}{16} + \frac{4}{16\kappa^2} \leq 1$, i.e., $\kappa^2 \geq \frac{4}{11} < 1$. Holds for all $\kappa \geq 1$. $\checkmark$

## Step 4: Spectral Radius Confirmation

The Lyapunov vector $(1, c)^T$ with $c = 1/\kappa^2$ satisfies $M(1,c)^T \leq \rho(1,c)^T$ componentwise, where $M = \begin{pmatrix} a_{11} & a_{12} \\ a_{21} & a_{22}\end{pmatrix}$.

By the Perron-Frobenius theorem for non-negative matrices, the existence of a positive vector $w$ with $Mw \leq \rho w$ implies $\rho(M) \leq \rho < 1$.

Therefore the $2\times 2$ recursion matrix has spectral radius $< 1$.

## Step 5: Final Bound

Since $\Phi_{t+1} \leq \rho\,\Phi_t$:
$$\Phi_t \leq \rho^t \Phi_0$$

And $\mathbb{E}[e_t] \leq \Phi_t$:

$$\mathbb{E}[\|x_t - x^*\|^2] \leq \rho^t\left(\|x_0 - x^*\|^2 + \frac{\gamma^2}{\kappa^2}\|v_0\|^2\right)$$

With $v_0 = 0$ (standard initialization):
$$\boxed{\mathbb{E}[\|x_t - x^*\|^2] \leq \left(1 - \frac{1}{16\kappa^2}\right)^t \|x_0 - x^*\|^2}$$

For general $v_0$, set $C = 1 + \frac{\gamma^2\|v_0\|^2}{\kappa^2\|x_0 - x^*\|^2}$ to get $\mathbb{E}[\|x_t - x^*\|^2] \leq C\rho^t\|x_0 - x^*\|^2$.

The function value bound follows from smoothness:
$$\mathbb{E}[f(x_t) - f^*] \leq \frac{L}{2}\mathbb{E}[\|x_t - x^*\|^2] \leq \frac{CL}{2}\rho^t\|x_0 - x^*\|^2 \qquad \blacksquare$$
