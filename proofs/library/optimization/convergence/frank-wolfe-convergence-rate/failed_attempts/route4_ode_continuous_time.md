# Proof Route 4: Continuous-Time ODE Argument

**Route**: ODE Continuous-Time

## Route Failure Report
- Route: Continuous-Time ODE Argument
- Failed at: Step 2 (Discretization)
- Obstacle: The continuous-time Frank-Wolfe dynamics $\dot{x}(t) = s(t) - x(t)$ where $s(t) = \arg\min_{s \in \mathcal{D}} \langle \nabla f(x(t)), s \rangle$ can be analyzed to show $h(t) = O(1/t)$ in continuous time. However, rigorously converting this to a discrete-time bound with the exact constant $2LD^2$ requires essentially the same induction argument as Routes 1-3. The ODE approach adds unnecessary complexity (existence/uniqueness of the ODE solution, discretization error bounds) without providing additional insight for this particular result.

The core difficulty is that the Frank-Wolfe dynamics involves a non-smooth selection map $s(t) = \arg\min_{s \in \mathcal{D}} \langle \nabla f(x(t)), s \rangle$, making the ODE analysis non-standard.

**Recommendation**: Use the direct discrete-time induction (Routes 1-3) which is cleaner and gives the exact constant.
