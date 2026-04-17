# Proof: Online Mirror Descent Regret Bound

**Route**: Telescoping Bregman Decomposition

---

**Step 1 (Convexity reduction).** Since each f_t is convex:

  f_t(x_t) - f_t(u) ≤ ⟨∇f_t(x_t), x_t - u⟩

It suffices to bound Σₜ ⟨∇f_t(x_t), x_t - u⟩.

**Step 2 (First-order optimality).** Since x_{t+1} minimizes η⟨∇f_t(x_t), x⟩ + D_ψ(x, x_t) over K, the KKT condition gives: for all x ∈ K,

  ⟨η∇f_t(x_t) + ∇ψ(x_{t+1}) - ∇ψ(x_t), x - x_{t+1}⟩ ≥ 0

Setting x = u:

  η⟨∇f_t(x_t), x_{t+1} - u⟩ ≤ ⟨∇ψ(x_{t+1}) - ∇ψ(x_t), x_{t+1} - u⟩   ... (1)

**Step 3 (Three-point identity).** For any a, b, c:

  D_ψ(a,b) - D_ψ(a,c) - D_ψ(c,b) = ⟨∇ψ(b) - ∇ψ(c), c - a⟩

*Proof by expansion:*
  LHS = [ψ(a)-ψ(b)-⟨∇ψ(b),a-b⟩] - [ψ(a)-ψ(c)-⟨∇ψ(c),a-c⟩] - [ψ(c)-ψ(b)-⟨∇ψ(b),c-b⟩]
      = ⟨∇ψ(b), c-a⟩ + ⟨∇ψ(c), a-c⟩ = ⟨∇ψ(b)-∇ψ(c), c-a⟩  ✓

With a=u, b=x_t, c=x_{t+1}:

  ⟨∇ψ(x_t)-∇ψ(x_{t+1}), x_{t+1}-u⟩ = D_ψ(u,x_t) - D_ψ(u,x_{t+1}) - D_ψ(x_{t+1},x_t)

**Step 4 (Combine).** From (1) and Step 3:

  η⟨∇f_t, x_{t+1}-u⟩ ≤ D_ψ(u,x_t) - D_ψ(u,x_{t+1}) - D_ψ(x_{t+1},x_t)   ... (*)

Note: D_ψ(x_{t+1},x_t) appears with MINUS sign.

Split x_t - u = (x_t - x_{t+1}) + (x_{t+1} - u):

  η⟨∇f_t, x_t-u⟩ ≤ η⟨∇f_t, x_t-x_{t+1}⟩ + D_ψ(u,x_t) - D_ψ(u,x_{t+1}) - D_ψ(x_{t+1},x_t)

**Step 5 (Fenchel-Young + strong convexity cancellation).**

Fenchel-Young with α = σ:

  η⟨∇f_t, x_t-x_{t+1}⟩ ≤ η²/(2σ)·‖∇f_t‖²_* + (σ/2)‖x_t-x_{t+1}‖²

σ-strong convexity: D_ψ(x_{t+1},x_t) ≥ (σ/2)‖x_{t+1}-x_t‖²

The terms (σ/2)‖Δx‖² and -D_ψ(x_{t+1},x_t) cancel:

  η⟨∇f_t, x_t-u⟩ ≤ η²/(2σ)‖∇f_t‖²_* + D_ψ(u,x_t) - D_ψ(u,x_{t+1})   ... (6)

**Step 6 (Telescope).** Sum (6) over t=1,...,T. Using ‖∇f_t‖_* ≤ G and D_ψ(u,x_{T+1}) ≥ 0:

  Σₜ [f_t(x_t) - f_t(u)] ≤ D_ψ(u,x₁)/η + ηG²T/(2σ)   ∎

**Step 7 (Optimize η).** η* = √(2σD_ψ(u,x₁)/(G²T)) gives:

  Regret ≤ G√(2D_ψ(u,x₁)T/σ)   ∎
