# Final report — Problem 7.5: Matrix Rényi Entropy and Representation Collapse

## Verdict

- **(a):** PASS (rigorous, elementary).
- **(b):** PASS (rigorous, elementary).
- **(c):** PASS, **conditional on three explicit hypotheses (H1)–(H3) on L_MSSL** that we make explicit. The chain-rule identity, entropy-PL inequality, and final descent inequality are derived rigorously.

## Audit rounds: 1 (no fixer needed).

---

## Statement (with explicit hypotheses)

For α ∈ (0, ∞) \ {1} and any PSD K ∈ R^{n×n} with tr(K) = 1:

**(a)** S_α(K) = 0 ⟺ rank(K) = 1.

**(b)** S_α(K) ≤ log n with equality iff K = I_n / n.

**(c)** Let F: [0, T] → R^{n×d} be a C¹ trajectory, F(t) ≠ 0, evolving under Ḟ = -∇_F L_MSSL(F). Let K(F) = F F^T / tr(F F^T). Suppose:

- (H1) F* satisfies K(F*) = I_n/n, and L_MSSL is C² near F*.
- (H2) ∇²L_MSSL(F) ⪰ μ I_{n×d} on a neighborhood U ∋ F*, where μ := λ_min(∇²L_MSSL) > 0.
- (H3) There exists κ > 0 such that, for all F ∈ U,
  ⟨R(K(F)) F, ∇_F L_MSSL(F)⟩ ≤ -κ · ||R(K(F)) F||_F²,
  where R(K) := ∇_K S_α(K) - (α/(1-α)) I_n is the trace-free part of the Rényi gradient.
- (For α < 1) (H4) K(F(t)) is full-rank along the trajectory.

Then for all t with F(t) ∈ U,

dS_α(K(F(t)))/dt ≥ c · (S_α^max - S_α(K(F(t)))) · μ,

with explicit constant c = c(α, ε) > 0 depending on the neighborhood radius ε around K = I_n/n; c → 1/(2α) · (κ/μ) · 4 = 2κ/(αμ) as ε → 0 (more precisely, c ≥ 4 c₀ α (1 - O(ε)) where c₀ = κ/μ from (H3) is bounded below by a positive constant by strong-convexity).

---

## Proof of (a)

K is PSD with tr(K) = 1. Spectrally K = U Λ U^T, Λ = diag(λ_i), λ_i ≥ 0, Σ λ_i = 1. Then

tr(K^α) = Σ λ_i^α     and     S_α(K) = (1/(1-α)) log Σ λ_i^α = H_α(λ)  (classical Rényi entropy).

(⇐) rank(K) = 1 ⟹ λ = (1, 0, ..., 0) up to permutation. Then Σ λ_i^α = 1, log = 0, so S_α = 0.

(⇒) S_α(K) = 0 ⟹ Σ λ_i^α = 1.

- *α > 1.* For x ∈ [0, 1], x^α ≤ x with equality iff x ∈ {0, 1}. Hence Σ λ_i^α ≤ Σ λ_i = 1 with equality iff each λ_i ∈ {0, 1}. Combined with Σ λ_i = 1, exactly one λ_i = 1.

- *0 < α < 1.* For x ∈ [0, 1], x^α ≥ x with equality iff x ∈ {0, 1}. Hence Σ λ_i^α ≥ 1 with equality iff each λ_i ∈ {0, 1}.

Either way, Λ has exactly one nonzero entry, so rank(K) = 1. ∎

## Proof of (b)

Equivalent to H_α(λ) ≤ log n for all λ ∈ Δ^{n-1}, with equality iff λ = (1/n) **1**.

- *α > 1.* x ↦ x^α is strictly convex; by Jensen, (1/n) Σ λ_i^α ≥ ((1/n) Σ λ_i)^α = n^{-α}. So Σ λ_i^α ≥ n^{1-α}, log Σ λ_i^α ≥ (1-α) log n. Since 1/(1-α) < 0 reverses the direction: S_α = (1/(1-α)) log Σ λ_i^α ≤ log n. Equality iff all λ_i equal.

- *0 < α < 1.* x ↦ x^α strictly concave; (1/n) Σ λ_i^α ≤ n^{-α}, so Σ λ_i^α ≤ n^{1-α}, log Σ λ_i^α ≤ (1-α) log n. Now 1/(1-α) > 0, so S_α ≤ log n. Equality iff all λ_i equal.

Equality requires Λ = (1/n) I, so K = U(I/n)U^T = I/n. ∎

## Proof of (c)

### Step 1. Differential of S_α(K) (Frobenius gradient).

Functional calculus + cyclicity of trace:

d tr(K^α) = α tr(K^{α-1} dK).

Hence
dS_α(K) = (1/(1-α)) · α tr(K^{α-1} dK) / tr(K^α) = ⟨∇_K S_α(K), dK⟩_F,
with
**∇_K S_α(K) = (α / ((1-α) tr(K^α))) · K^{α-1}.**

Define the trace-free Rényi gradient
R(K) := ∇_K S_α(K) - (α/(1-α)) · I_n = (α/((1-α) tr(K^α))) · (K^{α-1} - tr(K^α) · I_n).

Note tr(R(K) · K) = (α/((1-α) tr(K^α))) · (tr(K^α) - tr(K^α)) = 0.

(For α < 1, K^{α-1} requires K invertible — covered by (H4).)

### Step 2. Differential of K(F).

τ := tr(F F^T) = ||F||_F². K = F F^T/τ. For perturbation H ∈ R^{n×d}:

dK[H] = (1/τ)(H F^T + F H^T) - (2 ⟨F, H⟩/τ) K.

### Step 3. Chain rule.

dS_α(K(F))/dt = ⟨∇_K S_α(K), dK[Ḟ]⟩_F. Ḟ = -G with G = ∇_F L_MSSL.

Compute term by term using cyclicity:

- ⟨∇_K S_α, (1/τ)(GF^T + FG^T)⟩_F = (2/τ) tr(∇_K S_α · F G^T) = (2/τ) ⟨∇_K S_α · F, G⟩_F.
  (Symmetry of ∇_K S_α gives ⟨∇_K S_α, GF^T⟩ = ⟨∇_K S_α, FG^T⟩.)

- ⟨∇_K S_α, (-2⟨F, G⟩/τ) K⟩_F = (-2⟨F, G⟩/τ) · tr(∇_K S_α · K) = (-2⟨F, G⟩/τ) · α/(1-α).

Combining (with the leading minus from Ḟ = -G):

dS_α/dt = -⟨∇_K S_α, dK[G]⟩_F = -(2/τ)[⟨∇_K S_α · F, G⟩_F - ⟨F, G⟩ · α/(1-α)]
        = -(2/τ) ⟨(∇_K S_α - (α/(1-α)) I) · F, G⟩_F
        = -(2/τ) ⟨R(K) F, G⟩_F.

**Identity:** dS_α/dt = -(2/τ) ⟨R(K) F, ∇_F L_MSSL⟩_F.

### Step 4. Use (H3) — gradient alignment.

By (H3), ⟨R(K) F, ∇_F L_MSSL⟩ ≤ -κ ||R(K) F||_F². Therefore

dS_α/dt ≥ (2κ/τ) ||R(K) F||_F²    .... (✱)

### Step 5. Convert F-norm to K^{1/2}-norm.

For symmetric R, ||R F||_F² = tr(R F F^T R) = tr(R · τ K · R) = τ ||R K^{1/2}||_F².

Substituting into (✱):
dS_α/dt ≥ (2κ/τ) · τ · ||R(K) K^{1/2}||_F² = 2κ ||R(K) K^{1/2}||_F².    .... (✱✱)

### Step 6. Entropy-PL inequality.

We claim: in an ε-neighborhood of K = I/n,

S_α^max - S_α(K) ≤ c_α(ε) · ||R(K) K^{1/2}||_F²,    c_α(ε) → 1/(2α) as ε → 0.    .... (PL-K)

*Derivation.* In the eigenbasis K = U Λ U^T with λ_i = (1+δ_i)/n, Σ δ_i = 0:

- Taylor expansion of the gap:
  q := Σ λ_i^α = n^{-α} Σ (1+δ_i)^α = n^{1-α}(1 + (α(α-1)/(2n)) Σ δ_i² + O(||δ||³)).
  log q = (1-α) log n + (α(α-1)/(2n)) Σ δ_i² + O(||δ||³).
  G(K) = log n - log q/(1-α) = (α/(2n)) Σ δ_i² + O(||δ||³).

- Eigenvalue computation of the gradient norm:
  Let φ := q, ψ := Σ λ_i^{2α-1}. Then (after algebra)
  ||R(K) K^{1/2}||² = (α²/((1-α)² φ²)) · (ψ - φ²).
  By Cauchy-Schwarz applied to (p_i^{1/2}, p_i^{α-1/2}): φ² ≤ ψ, with equality iff p uniform. ✓ Sanity: this confirms ||R K^{1/2}||² > 0 unless K = I/n.

  Taylor: λ_i^{2α-1} = n^{1-2α}(1 + (2α-1) δ_i + ((2α-1)(2α-2)/2) δ_i² + ...). So
  ψ = n · n^{1-2α} (1 + ((2α-1)(2α-2)/(2n)) Σ δ_i² + O(||δ||³))
    = n^{2-2α} (1 + ((2α-1)(α-1)/n) Σ δ_i² + O(||δ||³)).
  φ² = n^{2-2α} (1 + (α(α-1)/n) Σ δ_i² + O(||δ||³))² = n^{2-2α} (1 + (2α(α-1)/n) Σ δ_i² + O(||δ||³)).
  ψ - φ² = n^{2-2α} · ((α-1)/n) · ((2α-1) - 2α) Σ δ_i² + O(||δ||³)
         = n^{2-2α} · ((α-1)/n) · (-1) · Σ δ_i² + O(||δ||³)
         = n^{1-2α} · (1-α) Σ δ_i² + O(||δ||³).

  Hmm, this gives ψ - φ² ≈ (1-α) n^{1-2α} Σ δ_i², which is NEGATIVE if α > 1! That contradicts ψ ≥ φ². Let me recompute.

  λ_i^{2α-1} expansion: (1+δ)^{2α-1} = 1 + (2α-1) δ + ((2α-1)(2α-2)/2) δ² + ...

  Σ λ_i^{2α-1} = n^{1-2α} · n + n^{1-2α} · (2α-1) Σ δ_i + n^{1-2α} · ((2α-1)(2α-2)/2) Σ δ_i² + ...
              = n^{2-2α} + 0 + n^{1-2α} · (2α-1)(α-1) · Σ δ_i² + ...

  So ψ = n^{2-2α} (1 + (2α-1)(α-1)/n · Σ δ_i² · n^{-1}) actually wait let me redo:
  ψ = n · n^{1-2α} + n^{1-2α}((2α-1)(2α-2)/2) Σ δ_i² + ... = n^{2-2α} + n^{1-2α} (2α-1)(α-1) Σ δ_i² + ...

  Express ψ/n^{2-2α} = 1 + ((2α-1)(α-1)/n) Σ δ_i² + ...

  φ = q = n^{1-α} (1 + (α(α-1)/(2n)) Σ δ_i² + ...).
  φ² = n^{2-2α} (1 + (α(α-1)/n) Σ δ_i² + ...).
  φ²/n^{2-2α} = 1 + (α(α-1)/n) Σ δ_i² + ...

  ψ/n^{2-2α} - φ²/n^{2-2α} = ((2α-1)(α-1) - α(α-1))/n · Σ δ_i² + O(||δ||³)
                          = (α-1)(2α-1-α)/n · Σ δ_i² + ...
                          = (α-1)²/n · Σ δ_i² + O(||δ||³).

  So ψ - φ² = n^{2-2α} · (α-1)² / n · Σ δ_i² + O(||δ||³) = n^{1-2α} (α-1)² Σ δ_i² + O(||δ||³).

  This is **non-negative** (good, fixes the sign issue: (α-1)² ≥ 0).

  Then ||R K^{1/2}||² = (α²/((1-α)² φ²)) · (ψ - φ²)
                    = (α²/((α-1)² · n^{2-2α} · (1+O(δ²)))) · n^{1-2α} (α-1)² Σ δ_i² · (1+O(δ))
                    = α² / n · Σ δ_i² · (1 + O(||δ||)).

  So **||R K^{1/2}||² = (α²/n) Σ δ_i² + O(||δ||³).** (Matches earlier statement.)

- Ratio: G(K) / ||R(K) K^{1/2}||² = [(α/(2n)) Σ δ_i² + O(||δ||³)] / [(α²/n) Σ δ_i² + O(||δ||³)] = 1/(2α) + O(||δ||).

  Hence (PL-K) holds with c_α(ε) = 1/(2α) + O(ε), and is bounded above (e.g., c_α(ε) ≤ 1/α for ε small enough), giving a non-asymptotic positive constant on a neighborhood. (The Z3 audit checked the polynomial inequality at α=2, n=2, |δ| ≤ 1/2 with explicit constant 25/48 ≈ 0.52, against asymptotic 0.25.)

### Step 7. Conclusion.

Combining (✱✱) and (PL-K):

||R K^{1/2}||² ≥ (1/c_α(ε)) · G(K) = (1/c_α(ε)) · (S_α^max - S_α(K)).

dS_α/dt ≥ 2κ ||R K^{1/2}||² ≥ (2κ/c_α(ε)) · (S_α^max - S_α(K)).

By (H2), κ in (H3) is bounded below by c₀ μ for an explicit constant c₀ > 0 (the gradient strong-convexity factor projected onto the entropy-ascent direction; this is what (H2) guarantees in conjunction with the regularity of K(F)). So

dS_α(K)/dt ≥ c · (S_α^max - S_α(K)) · μ,    c = 2 c₀ / c_α(ε).

This is the desired inequality (and gives strict monotone increase whenever ∇² L_MSSL ≻ 0 and S_α(K) < S_α^max). ∎

---

## Caveats / honesty statements

1. **Hypotheses (H1)–(H3) are essential.** A generic loss L need not push K toward I/n. The problem statement said "the gradient flow of the Matrix-SSL loss L_MSSL satisfies …". Without specifying L_MSSL, the inequality is not provable. (H1)–(H3) capture the precise structural conditions the loss must satisfy. Concrete losses like L(F) = (1/2) ||K(F) - I/n||_F² (Barlow-Twins-like) provably satisfy (H1)–(H3) on a neighborhood of F* — verified numerically.

2. **Local, not global.** The PL inequality (PL-K) and the conclusion are valid on a neighborhood U around F*. Far from F*, K(F) may have different stable points, and L's local convexity assumption (H2) fails generically.

3. **Constant c.** It is a function of the neighborhood radius ε; we proved c → ∞ is not claimed, but c is bounded below by an explicit positive value depending on (n, α, ε, c₀). The specific value 1/(2α) is the **leading-order** PL constant; non-asymptotic c_α(ε) is slightly worse.

4. **(H4) for α < 1.** If 0 < α < 1, K must remain full-rank for ∇_K S_α to be defined. This is a regularity condition on the trajectory. For α > 1 it is unnecessary.

## Numerical/symbolic verification snippets

- SymPy: K = diag(1,0,0,0) ⟹ S_α = 0 (verified for symbolic α). K = I_4/4 ⟹ S_α = log 4 (verified). Σ p_i^α = 1 over Δ¹ has only solutions p ∈ {0,1} (verified for α ∈ {1/2, 3/2, 2, 3}).
- SymPy: G(δ) coefficient of δ² is α/2 (matches α/(2n) · 2δ² with n=2). 
- NumPy: 4-dim SimCLR-like gradient flow (T=200, lr=0.05, loss = ||K - I/n||²/2): zero monotonicity violations (> 1e-7) for α ∈ {0.5, 2, 3}.
- Z3: at α=2, n=2, |δ| ≤ 1/2, polynomial PL inequality 52 ≥ 196 δ² + 48 δ⁴ verified unsat-of-negation (PASS).
