# Route 1: Constant Step Size η = c/√T — Direct Last-Iterate Analysis

## Result: Proved O(1/√T) for the AVERAGED iterate only.

With constant step size η = D/(G√T), the averaged iterate x̄_T = (1/T)Σx_t satisfies E[f(x̄_T) - f*] ≤ DG/√T.

Could NOT prove the last-iterate bound. Extensive analysis (bounded increment arguments, Markov chain mixing, 1D sign structure, Lyapunov functions, coupling contractions) shows that constant step size η = D/(G√T) gives only O(1) for E[f(x_T) - f*] for general convex Lipschitz functions, even in d=1. The mixing time of the Markov chain is Θ(T) with this step size, so at time T the chain has barely mixed.
