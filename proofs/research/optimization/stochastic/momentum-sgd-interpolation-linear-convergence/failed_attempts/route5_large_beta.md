# Failed Attempt: AM-GM approach with $\beta = \mu/(4L) = O(1/\kappa)$

## Approach
Work with $e_t, S_t = \|\gamma v_t\|^2$. Use AM-GM to bound cross terms $\langle u_t, s_t\rangle$ and $\langle s_t, \bar{g}_t\rangle$. Set $\beta = \mu/(4L)$.

## Result
The $a_{12}$ entry of the recursion matrix includes $\beta^2/(\gamma\mu) = 1/8$ (an $O(1)$ constant).

## Why it fails
With $a_{12} = O(1)$, the Lyapunov constant $c$ must be at least $\Omega(1)$ to satisfy condition (II). But then $c \cdot a_{21} = \Omega(1/\kappa^2)$ overwhelms the descent margin $O(1/\kappa^2)$ in condition (I), leaving no room for contraction.

## Lesson
The momentum parameter $\beta$ must be small enough that $\beta^2/(\gamma\mu) = o(1)$. With $\gamma = \Theta(\mu/L^2)$, this requires $\beta = o(\mu/L)$, i.e., $\beta \ll 1/\kappa$.
