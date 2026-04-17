# Proof Report: Online Mirror Descent Regret Bound

## 1. Problem Statement

Consider the Online Mirror Descent algorithm on a convex compact set K ⊆ ℝᵈ.
Let ψ: K → ℝ be a σ-strongly convex function with respect to norm ‖·‖,
and let D_ψ(x, y) = ψ(x) - ψ(y) - ⟨∇ψ(y), x - y⟩ be the Bregman divergence.

At each round t = 1, ..., T, the learner plays xₜ ∈ K and observes a convex loss fₜ
with ‖∇fₜ(xₜ)‖_* ≤ G (dual norm bounded).

The update rule is:
  xₜ₊₁ = arg min_{x ∈ K} { η⟨∇fₜ(xₜ), x⟩ + D_ψ(x, xₜ) }

Prove that for any comparator u ∈ K, the regret satisfies:

  Σₜ₌₁ᵀ [fₜ(xₜ) - fₜ(u)] ≤ D_ψ(u, x₁)/η + ηG²T/(2σ)

and by choosing η = √(2σD_ψ(u, x₁)/(G²T)), this yields:

  Regret ≤ G√(2D_ψ(u, x₁)T/σ)

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed, top 4 selected |
| Explorer | Opus | 4 proofs attempted, 4 succeeded |
| Judge | Sonnet | Route 1 selected (score: 36/40) |
| Audit | Opus | PASS (1 round, 7/7 valid) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

| Route | Name | Score | Outcome |
|-------|------|-------|---------|
| 1 | Telescoping Bregman Decomposition | 36/40 | ✓ Winner |
| 2 | Fenchel Conjugate Duality | 27/40 | ✓ Complete but sign issues in presentation |
| 3 | One-Step Regret Lemma + Summation | 32/40 | ✓ Complete |
| 5 | Lyapunov / Potential Function | 32/40 | ✓ Complete (variant of Route 3) |

## 4. Final Proof

**Theorem (Online Mirror Descent Regret Bound).** Let ψ : K → ℝ be σ-strongly convex with respect to a norm ‖·‖ on a convex compact set K ⊆ ℝᵈ. Let x₁ ∈ K be arbitrary, and define the OMD iterates by

  x_{t+1} = arg min_{x ∈ K} { η⟨∇f_t(x_t), x⟩ + D_ψ(x, x_t) }

Suppose ‖∇f_t(x_t)‖_* ≤ G for all t. Then for any comparator u ∈ K:

  Σₜ₌₁ᵀ [f_t(x_t) - f_t(u)] ≤ D_ψ(u, x₁)/η + ηG²T/(2σ)

Optimizing over η gives Regret ≤ G√(2D_ψ(u,x₁)T/σ).

**Proof.**

**Step 1 (Convexity reduction).** Since each f_t is convex:

  f_t(x_t) - f_t(u) ≤ ⟨∇f_t(x_t), x_t - u⟩

It suffices to bound Σₜ ⟨∇f_t(x_t), x_t - u⟩.

**Step 2 (First-order optimality).** Since x_{t+1} minimizes η⟨∇f_t(x_t), x⟩ + D_ψ(x, x_t) over K, the KKT condition gives: for all x ∈ K,

  ⟨η∇f_t(x_t) + ∇ψ(x_{t+1}) - ∇ψ(x_t), x - x_{t+1}⟩ ≥ 0

Setting x = u and rearranging:

  η⟨∇f_t(x_t), x_{t+1} - u⟩ ≤ ⟨∇ψ(x_{t+1}) - ∇ψ(x_t), x_{t+1} - u⟩   ... (1)

**Step 3 (Three-point identity).** For any a, b, c in the domain of ψ:

  D_ψ(a,b) - D_ψ(a,c) - D_ψ(c,b) = ⟨∇ψ(b) - ∇ψ(c), c - a⟩

Proof: Expand all three Bregman divergences using the definition and cancel ψ terms:
  LHS = -⟨∇ψ(b), a-b⟩ + ⟨∇ψ(c), a-c⟩ + ⟨∇ψ(b), c-b⟩
      = ⟨∇ψ(b), c-a⟩ + ⟨∇ψ(c), a-c⟩ = ⟨∇ψ(b) - ∇ψ(c), c-a⟩  ✓

With a = u, b = x_t, c = x_{t+1}:

  ⟨∇ψ(x_t) - ∇ψ(x_{t+1}), x_{t+1} - u⟩ = D_ψ(u,x_t) - D_ψ(u,x_{t+1}) - D_ψ(x_{t+1},x_t)

**Step 4 (Combine optimality + three-point).** From (1) and Step 3:

  η⟨∇f_t(x_t), x_{t+1} - u⟩ ≤ D_ψ(u,x_t) - D_ψ(u,x_{t+1}) - D_ψ(x_{t+1},x_t)   ... (*)

Key: the D_ψ(x_{t+1},x_t) appears with a MINUS sign.

Split x_t - u = (x_t - x_{t+1}) + (x_{t+1} - u):

  η⟨∇f_t, x_t - u⟩ = η⟨∇f_t, x_t - x_{t+1}⟩ + η⟨∇f_t, x_{t+1} - u⟩
    ≤ η⟨∇f_t, x_t - x_{t+1}⟩ + D_ψ(u,x_t) - D_ψ(u,x_{t+1}) - D_ψ(x_{t+1},x_t)

**Step 5 (Young's inequality + strong convexity cancellation).**

Fenchel-Young with α = σ:

  η⟨∇f_t, x_t - x_{t+1}⟩ ≤ η²/(2σ) · ‖∇f_t‖²_* + (σ/2)‖x_t - x_{t+1}‖²

σ-strong convexity of ψ:

  D_ψ(x_{t+1}, x_t) ≥ (σ/2)‖x_{t+1} - x_t‖²

Combining: the (σ/2)‖Δx‖² from Young exactly cancels against -D_ψ(x_{t+1},x_t) ≤ -(σ/2)‖Δx‖²:

  η⟨∇f_t, x_t - u⟩ ≤ η²/(2σ)‖∇f_t‖²_* + D_ψ(u,x_t) - D_ψ(u,x_{t+1})   ... (6)

**Step 6 (Telescope).** Sum (6) over t = 1,...,T:

  η Σₜ ⟨∇f_t, x_t - u⟩ ≤ η²G²T/(2σ) + D_ψ(u,x₁) - D_ψ(u,x_{T+1})

Since D_ψ(u,x_{T+1}) ≥ 0, divide by η:

  Σₜ [f_t(x_t) - f_t(u)] ≤ D_ψ(u,x₁)/η + ηG²T/(2σ)   ∎

**Step 7 (Optimize η).** Minimize A/η + Bη where A = D_ψ(u,x₁), B = G²T/(2σ):

  η* = √(A/B) = √(2σD_ψ(u,x₁)/(G²T))

  Regret ≤ 2√(AB) = G√(2D_ψ(u,x₁)T/σ)   ∎

## 5. Audit Result

PASS on first round. All 7 steps marked VALID. No mathematical errors found.

Medium issues (presentation only):
- Assumptions on ψ (differentiability, norm matching) could be more explicit
- Gradient boundedness used implicitly in telescoping step

Low issues: comparator dependence, advance knowledge needed for optimal η.

## 6. Fix History

No fixes needed. Audit passed on first round.
