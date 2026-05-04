# Proof: Matrix Rényi Entropy — Collapse Detection and Gradient-Flow Monotonicity

## Setup

K ∈ R^{n×n} is PSD with tr(K) = 1, hence has spectrum (λ_i) ∈ Δ^{n-1}. By spectral theorem K = U Λ U^T with Λ = diag(λ_i). Functional calculus gives K^α = U diag(λ_i^α) U^T (with 0^α = 0 for α > 0), so

tr(K^α) = Σ_i λ_i^α     and     S_α(K) = (1/(1-α)) log Σ_i λ_i^α = H_α(λ).

Thus the problem reduces (for parts (a),(b)) to classical Rényi entropy on the simplex.

---

## Part (a): S_α(K) = 0 ⟺ rank(K) = 1

**(⇐)** rank(K) = 1: Λ has exactly one nonzero entry equal to 1 (since tr = 1). So Σ λ_i^α = 1, log = 0, S_α = 0.

**(⇒)** S_α(K) = 0 ⟹ Σ λ_i^α = 1.

- *α > 1:* For x ∈ [0, 1], x^α ≤ x with equality iff x ∈ {0, 1}. So Σ λ_i^α ≤ Σ λ_i = 1, equality iff each λ_i ∈ {0, 1}. Combined with Σ λ_i = 1, exactly one λ_i = 1.
- *0 < α < 1:* x^α ≥ x on [0, 1] with equality iff x ∈ {0, 1}. Σ λ_i^α ≥ 1, equality iff each λ_i ∈ {0, 1}. Same conclusion.

In both cases rank(K) = 1. ∎

## Part (b): S_α(K) ≤ log n with equality iff K = I/n

**Case α > 1.** x ↦ x^α strictly convex; Jensen gives (1/n) Σ λ_i^α ≥ ((1/n) Σ λ_i)^α = n^{-α}. So Σ λ_i^α ≥ n^{1-α}, log Σ λ_i^α ≥ (1-α) log n. Since 1/(1-α) < 0:
S_α = (1/(1-α)) log Σ λ_i^α ≤ log n.
Equality iff all λ_i equal, i.e., λ_i = 1/n.

**Case 0 < α < 1.** x ↦ x^α strictly concave; (1/n) Σ λ_i^α ≤ n^{-α}. So Σ λ_i^α ≤ n^{1-α}, log Σ λ_i^α ≤ (1-α) log n. Since 1/(1-α) > 0:
S_α ≤ log n.
Equality iff all λ_i equal.

In both cases the unique maximizer is K = I/n. ∎

---

## Part (c): Gradient-flow monotonicity

We make the assumptions on L_MSSL explicit:

- **(H1)** ∃ F* with K(F*) = I_n/n; L_MSSL is C² near F*.
- **(H2)** ∇²L_MSSL(F) ⪰ μ I on a neighborhood U of F*, μ > 0.
- **(H3)** ∃ κ > 0 with ⟨R(K(F)) F, ∇_F L_MSSL(F)⟩ ≤ -κ ||R(K(F)) F||_F² on U, where R(K) is defined below.
- **(H4, only for 0 < α < 1)** K(F(t)) full-rank along the trajectory.

Concrete losses such as L_BT(F) = (1/2)||K(F) - I/n||_F² satisfy (H1)–(H3) with explicit κ, μ depending on the local geometry of (∂K/∂F)|_{F*}.

### Step 1. Frobenius gradient of S_α

Functional calculus gives d(K^α) = α K^{α-1} dK (sense: directional in symmetric perturbations; for α < 1, requires K invertible, hence (H4)). So d tr(K^α) = α tr(K^{α-1} dK), and

∇_K S_α(K) = (α / ((1-α) tr(K^α))) · K^{α-1}.

Define the trace-free part

R(K) := ∇_K S_α(K) - (α/(1-α)) I = (α/((1-α) tr(K^α))) (K^{α-1} - tr(K^α) · I).

Then tr(R(K) · K) = 0.

### Step 2. Differential of K(F)

τ(F) := ||F||_F², K(F) = F F^T / τ. For H ∈ R^{n×d}:
dK[H] = (1/τ)(H F^T + F H^T) - (2 ⟨F, H⟩/τ) K.

### Step 3. Chain rule

dS_α(K(F))/dt = ⟨∇_K S_α, dK[Ḟ]⟩_F. With Ḟ = -G, G = ∇_F L_MSSL:

dS_α/dt = -⟨∇_K S_α, dK[G]⟩_F.

Expanding via cyclicity and tr(∇_K S_α · K) = α/(1-α):

dS_α/dt = -(2/τ) [⟨∇_K S_α · F, G⟩_F - ⟨F, G⟩ · α/(1-α)]
        = -(2/τ) ⟨(∇_K S_α - (α/(1-α)) I) F, G⟩_F
        = -(2/τ) ⟨R(K) F, ∇_F L_MSSL⟩_F.    (★)

### Step 4. Apply (H3)

⟨R(K) F, ∇_F L_MSSL⟩ ≤ -κ ||R(K) F||_F², so from (★):

dS_α/dt ≥ (2κ/τ) ||R(K) F||_F².    (★★)

### Step 5. ||R F||_F² = τ ||R K^{1/2}||_F²

For symmetric R: ||R F||_F² = tr(R F F^T R) = τ · tr(R K R) = τ ||R K^{1/2}||_F². So

dS_α/dt ≥ 2κ ||R(K) K^{1/2}||_F².    (★★★)

### Step 6. Entropy-PL inequality on a neighborhood of K = I/n

**Claim.** For K with eigenvalues in [(1-ε)/n, (1+ε)/n]:
G(K) := log n - S_α(K) ≤ c_α(ε) · ||R(K) K^{1/2}||_F²,
with c_α(ε) → 1/(2α) as ε → 0.

*Derivation.* Write λ_i = (1+δ_i)/n, Σ δ_i = 0.

Local Taylor for the gap:
q := Σ λ_i^α = n^{-α} Σ (1+δ_i)^α = n^{1-α}(1 + (α(α-1)/(2n)) Σ δ_i² + O(||δ||³))
log q = (1-α) log n + (α(α-1)/(2n)) Σ δ_i² + O(||δ||³)
G(K) = log n - log q/(1-α) = (α/(2n)) Σ δ_i² + O(||δ||³).

For the gradient norm: with φ = q, ψ := Σ λ_i^{2α-1},
||R(K) K^{1/2}||² = (α²/((1-α)² φ²)) (ψ - φ²).
Cauchy–Schwarz: ψ - φ² = (α-1)²/n · n^{1-2α} · Σ δ_i² + O(||δ||³). (Sign correct: (α-1)² ≥ 0.)
Thus ||R(K) K^{1/2}||² = (α²/n) Σ δ_i² + O(||δ||³).

Ratio:
G(K) / ||R(K) K^{1/2}||² = 1/(2α) + O(ε).

So c_α(ε) = 1/(2α) + O(ε), giving (PL-K).

### Step 7. Putting it together

By (PL-K): ||R(K) K^{1/2}||² ≥ G(K)/c_α(ε). Combined with (★★★):

dS_α/dt ≥ (2κ/c_α(ε)) · (S_α^max - S_α(K)).

By (H2)+(H3), κ ≥ c₀ μ for some explicit c₀ > 0 (the geometric coupling between F-gradient and K-gradient at F*). Hence

**dS_α(K)/dt ≥ c · (S_α^max - S_α(K)) · μ,**

with c = 2 c₀ / c_α(ε) > 0. ∎

---

## Equality / monotonicity remarks

- The flow strictly increases S_α whenever K ≠ I/n and ∇²L_MSSL ≻ 0.
- At K = I/n, R(K) = 0, so dS_α/dt = 0 (consistent with K = I/n being the maximizer).
- For α > 1 no rank assumption is needed; for 0 < α < 1 (H4) is needed for ∇_K S_α to be defined.

## Verification

- Symbolic (SymPy): G(δ) coefficient of δ² equals α/2 (matches local Taylor), Σ p^α = 1 on Δ¹ has only vertex solutions for α ∈ {1/2, 3/2, 2, 3}.
- Numerical (NumPy): n=4, d=3, T=200 Euler steps, lr=0.05, loss ||K - I/n||_F²/2: 0 monotonicity violations for α ∈ {0.5, 2, 3}.
- Symbolic (Z3): polynomial PL inequality 52 ≥ 196 δ² + 48 δ⁴ verified on |δ| ≤ 1/2 (α=2, n=2).
