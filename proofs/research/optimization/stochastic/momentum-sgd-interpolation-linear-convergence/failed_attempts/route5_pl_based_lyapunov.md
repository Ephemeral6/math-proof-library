# Failed Attempt: PL-based Lyapunov $\Phi = \Delta_t + c\|v_t\|^2$

## Approach
Work with $\Delta_t = f(x_t) - f^*$ and $W_t = \|v_t\|^2$. Choose $c = \gamma(1 - L\gamma)$ to kill the $\langle \nabla f, v\rangle$ cross term.

## Result
$$\mathbb{E}_t[\Phi_{t+1}] \leq (1 + L\gamma - 2\mu\gamma)\Delta_t + \frac{\beta^2\gamma}{2}W_t$$

The $\Delta_t$ coefficient $1 + L\gamma - 2\mu\gamma < 1$ requires $L < 2\mu$ ($\kappa < 2$).

## Why it fails
The noise bound $\mathbb{E}[\|g_t\|^2] \leq 2L\Delta_t$ contributes $+L^2\gamma^2\Delta_t$ to the descent inequality. After the cross-term cancellation, this simplifies to $+L\gamma\Delta_t$. Combined with the PL descent $-2\mu\gamma\Delta_t$, the net is $(1 + L\gamma - 2\mu\gamma)\Delta_t$, which only contracts when $2\mu > L$.

## Lesson
Working with function values $\Delta_t$ is too lossy because the noise bound $2L\Delta_t$ is proportional to $L$. Working with $e_t = \|x-x^*\|^2$ gives noise $\leq L^2 e_t$ but the strong convexity descent is $-2\gamma\mu e_t$, a better ratio.
