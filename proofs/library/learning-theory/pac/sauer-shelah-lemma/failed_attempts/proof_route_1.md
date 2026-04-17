# Proof of Sauer-Shelah Lemma — Route 1: Shifting/Compression

**Route**: Shifting/Compression technique

We prove the Sauer-Shelah Lemma in two parts:
- Part A: Pi_H(n) <= sum_{i=0}^{d} C(n,i) (the combinatorial bound)
- Part B: sum_{i=0}^{d} C(n,i) <= (en/d)^d (the polynomial bound)

---

## Part A: Combinatorial bound via shifting

We work with set systems. Given H with VC dimension d acting on a set S = {x_1, ..., x_n}, define F = {T ⊆ S : T = {x_i : h(x_i)=1} for some h ∈ H} as the trace of H on S. We have |F| = Pi_H(n) (choosing S to maximize).

**Definition (Shifting operator).** For i ∈ [n], define S_i: 2^S → 2^S by:
- S_i(A) = A \ {x_i} if x_i ∈ A and A \ {x_i} ∉ F
- S_i(A) = A otherwise

For a family F, define S_i(F) = {S_i(A) : A ∈ F}.

**Claim 1:** |S_i(F)| = |F| for every i.

*Proof of Claim 1:* S_i is injective on F. If S_i(A) = S_i(B) with A ≠ B, then one of them (say A) was shifted to A \ {x_i} and the other was not shifted. So S_i(B) = B and S_i(A) = A \ {x_i} = B. But then B = A \ {x_i} ∈ F, which by definition means A should not have been shifted — contradiction. □

**Claim 2:** VCdim(S_i(F)) ≤ VCdim(F).

*Proof of Claim 2:* If S_i(F) shatters T, we show F shatters a set of the same size. If x_i ∉ T, then for every U ⊆ T there exists A ∈ S_i(F) with A ∩ T = U. Each such A comes from some B ∈ F with S_i(B) = A. Since x_i ∉ T, A ∩ T = B ∩ T or (B \ {x_i}) ∩ T = B ∩ T (as x_i ∉ T). So F shatters T.

If x_i ∈ T, consider T' = (T \ {x_i}) ∪ {x_i}... Actually, this case requires more care. We instead argue as follows: suppose S_i(F) shatters T with x_i ∈ T. For every U ⊆ T, there exists A_U ∈ S_i(F) with A_U ∩ T = U. Now x_i ∉ A_U for U with x_i ∉ U (since these A_U don't contain x_i). For the preimage B_U ∈ F of each A_U: if A_U = B_U, then B_U ∩ T = U; if A_U = B_U \ {x_i}, then B_U contains x_i and B_U ∩ T = U ∪ {x_i} ≠ U. 

This approach gets complicated. Let me switch to a cleaner argument.

---

## Route Failure Report
- Route: Shifting/Compression
- Failed at: Claim 2 — proving VCdim doesn't increase under shifting
- Obstacle: The argument for preserving VC dimension under shifting when the shifted element is in the shattered set is technically involved and I could not close it cleanly within this route. The standard shifting proof (e.g., Frankl 1983) requires a more delicate exchange argument that goes beyond simple shifting.
