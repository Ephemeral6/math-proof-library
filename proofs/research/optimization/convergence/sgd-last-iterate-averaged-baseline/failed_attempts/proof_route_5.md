# Route 5: Lyapunov Recurrence + Optimal η_t Schedule

## Proof (Averaged Iterate)

**Route**: Lyapunov Recurrence + Optimal η_t Schedule

**Step 1: Setup.** W = [a,b], D = b-a, x* ∈ W minimizer. V_t = E[(x_t - x*)²].

**Step 2: Lyapunov recurrence.** Non-expansiveness of Π_W + subgradient inequality:
V_{t+1} ≤ V_t - 2η_t E[f(x_t) - f*] + η_t² G²  ...(★)

**Step 3: Telescope.** Rearranging (★) and summing t=1..T:
2 Σ η_t E[f(x_t) - f*] ≤ V_1 + G² Σ η_t²
V_1 ≤ D².

**Step 4: Constant step size.** η_t = η = D/(G√T). Then:
Σ η_t² = Tη² = D²/G²
So: 2η Σ E[f(x_t) - f*] ≤ D² + D² = 2D²

**Step 5: Averaged iterate.** x̄_T = (1/T)Σ x_t. By Jensen:
E[f(x̄_T) - f*] ≤ (1/T)Σ E[f(x_t) - f*] ≤ 2D²/(2ηT) = D²G√T/(DT) = DG/√T

**Step 6: Conclusion.**
E[f(x̄_T) - f*] ≤ DG/√T = O(1/√T)

The log(T) is avoided because constant step sizes give Σ η_t² = O(1), unlike decreasing η_t = c/√t which produces harmonic sum O(log T). Q.E.D.

## Last-Iterate Obstacle

The route's original plan — track V_T and use f(x_T) - f* ≤ G√(V_T), requiring V_T = O(1/T) — faces a fundamental obstacle: without strong convexity, the descent term 2η_t E[f(x_t) - f*] cannot be converted into a contraction on V_t. The best achievable for V_T without strong convexity is O(1) (not O(1/T)), giving only E[f(x_T) - f*] = O(1).
