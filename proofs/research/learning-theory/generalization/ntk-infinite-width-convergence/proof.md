# Proof: NTK Infinite-Width Convergence

**Route**: Schur Product Theorem + Matrix Bernstein

---

**Step 1 (Decomposition).** Write Θ̂ₘ - Θ∞ = (1/m)Σₖ Zₖ where Zₖ = (Aₖ - E[A₁]) ∘ G. Here Aₖ = sₖsₖᵀ with (sₖ)ᵢ = σ'(wₖᵀxᵢ) and G is the Gram matrix Gᵢⱼ = xᵢᵀxⱼ. The Zₖ are i.i.d., mean-zero, symmetric n×n matrices.

**Step 2 (Schur Product Lemma).** For symmetric M and PSD G with Gᵢᵢ = 1: ‖M∘G‖_op ≤ ‖M‖_op.

*Proof:* Write G = XXᵀ with ‖xᵢ‖=1. For unit v ∈ ℝⁿ:
  vᵀ(M∘G)v = Σᵢⱼ Mᵢⱼ Gᵢⱼ vᵢvⱼ = Σᵢⱼ Mᵢⱼ vᵢvⱼ Σ_ℓ (xᵢ)_ℓ(xⱼ)_ℓ = Σ_ℓ q_ℓᵀMq_ℓ

where (q_ℓ)ᵢ = vᵢ(xᵢ)_ℓ. Since Σ_ℓ‖q_ℓ‖² = Σᵢ vᵢ²‖xᵢ‖² = 1:
  |vᵀ(M∘G)v| ≤ ‖M‖_op · Σ_ℓ‖q_ℓ‖² = ‖M‖_op. ∎

**Step 3 (Operator norm bound).** By Step 2: ‖Aₖ∘G‖_op ≤ ‖Aₖ‖_op = ‖sₖ‖² ≤ n‖σ'‖²_∞. Similarly ‖E[A₁]∘G‖_op ≤ n‖σ'‖²_∞. By triangle inequality: ‖Zₖ‖_op ≤ 2n‖σ'‖²_∞ =: R.

**Step 4 (Variance bound).** ‖E[Z₁²]‖_op ≤ E[‖Z₁‖²_op] ≤ R² = 4n²‖σ'‖⁴_∞ (by Jensen + a.s. bound).

**Step 5 (Matrix Bernstein).** For i.i.d. symmetric mean-zero matrices with ‖Zₖ‖_op ≤ R a.s. and matrix variance σ² = m·‖E[Z₁²]‖_op ≤ 4mn²‖σ'‖⁴:

  P(‖Σₖ Zₖ‖_op ≥ t) ≤ 2n·exp(-t²/2/(σ² + Rt/3))

Set = δ. In variance-dominated regime (m ≥ Ω(log(n/δ))):
  ‖(1/m)Σₖ Zₖ‖_op ≤ n‖σ'‖²_∞ · √(8log(2n/δ)/m)

**Step 6 (Simplify).** log(2n/δ) ≤ 3log(n/δ) for n/δ ≥ √2. Therefore:

  ‖Θ̂ₘ - Θ∞‖_op ≤ C · ‖σ'‖²_∞ · n · √(log(n/δ)/m)

with C = 2√6. ∎
