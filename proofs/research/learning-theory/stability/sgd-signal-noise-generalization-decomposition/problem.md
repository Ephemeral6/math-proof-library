# SGD Signal-Noise Generalization Decomposition

## Source
- Paper: Zhang, Yifan, et al., "Towards Understanding Generalization via Decomposing Excess Risk Dynamics", ICLR 2022
- Direction: Generalization theory (Yang Yuan style)

## Statement

Consider SGD on a loss `L(θ;z) = L_S(θ) + L_N(θ;z)` (signal + noise) with the population/residual decomposition:
- `L_S(θ) := E_{z∼D}[L(θ;z)]` (population component, "signal");
- `L_N(θ;z) := L(θ;z) − L_S(θ)` (zero-mean residual, "noise").

SGD update with i.i.d. mini-batch: `θ_{t+1} = θ_t − η ∇L(θ_t; z_{i_t})`, `i_t ~ Unif[m]`.

Define `σ_N^2 := sup_θ E_z‖∇L_N(θ;z)‖^2` and `G_S := ‖∇L_S‖_∞`.

**Claim 1 (decomposed generalization gap).** Under (A1) `ℓ(·;z)` convex and `L`-smooth for every `z`, (A2) `‖∇L_S‖ ≤ G_S` and noise-variance bound `σ_N^2 < ∞`, and (A3) `η ≤ 1/L`, the SGD iterate `θ_T` satisfies
```
|E_S[L_S(θ_T) − L̂(θ_T;S)]| ≤ G_S(T) + G_N(T),
```
with
```
G_S(T) = O(G_S^2 · η · (√(T/m) + T/m)),
G_N(T) = O(σ_N^2 · η · (√(T/m) + T/m)).
```

(The original paper formulation `G_S = O(G_S^2 η^2 T/m)`, `G_N = O(σ_N^2 η/m)` requires additional structure — see notes for the actual exponents reachable via stability.)

**Claim 2 (regime-restricted tightness vs Hardt et al. 2016).** In the noise-dominated regime `G_S ≪ σ_N` AND `T ≥ m` (multi-epoch), our bound matches HRS up to constants. **Strict tightness `ε_ours ≪ ε_HRS` does NOT hold via this stability proof in the single-epoch regime; it requires PAC-Bayes or last-iterate optimization analysis.**

## Difficulty
research
