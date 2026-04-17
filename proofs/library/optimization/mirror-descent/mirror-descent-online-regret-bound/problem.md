# Online Mirror Descent Regret Bound

## Source
- Paper: Standard result in online convex optimization (Shalev-Shwartz, Hazan, etc.)
- Context: Fundamental regret bound for mirror descent in online learning

## Statement

Consider the Online Mirror Descent algorithm on a convex compact set K ⊆ ℝᵈ.
Let ψ: K → ℝ be a σ-strongly convex function with respect to norm ‖·‖,
and let D_ψ(x, y) = ψ(x) - ψ(y) - ⟨∇ψ(y), x - y⟩ be the Bregman divergence.

At each round t = 1, ..., T, the learner plays xₜ ∈ K and observes a convex loss fₜ
with ‖∇fₜ(xₜ)‖_* ≤ G (dual norm bounded).

The update rule is:
  xₜ₊₁ = arg min_{x ∈ K} { η⟨∇fₜ(xₜ), x⟩ + D_ψ(x, xₜ) }

Then for any comparator u ∈ K:

  Σₜ₌₁ᵀ [fₜ(xₜ) - fₜ(u)] ≤ D_ψ(u, x₁)/η + ηG²T/(2σ)

With η = √(2σD_ψ(u, x₁)/(G²T)):

  Regret ≤ G√(2D_ψ(u, x₁)T/σ)

## Difficulty
research
