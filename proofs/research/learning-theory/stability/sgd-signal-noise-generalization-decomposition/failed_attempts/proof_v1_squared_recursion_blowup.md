# Proof v1: Signal-Noise Decomposition for SGD Generalization

## Setup and assumptions

- Sample `S = (z_1, ..., z_m)` drawn i.i.d. from `D`. Mini-batch SGD with batch size 1, `T` steps:
  `θ_{t+1} = θ_t − η ∇ℓ(θ_t; z_{i_t})`,  `i_t ~ Unif[m]` i.i.d.
- **Decomposition (committed):** `L_S(θ) := E_{z∼D} ℓ(θ;z)`, `L_N(θ;z) := ℓ(θ;z) − L_S(θ)`.
  Then `∇ℓ(θ;z) = ∇L_S(θ) + ∇L_N(θ;z)`, with `E_z ∇L_N(θ;z) = 0` and
  `σ_N^2(θ) := E_z ‖∇L_N(θ;z)‖^2`,  `σ_N^2 := sup_θ σ_N^2(θ)`.
- **(A1) Convexity & smoothness:** for every `z`, `ℓ(·;z)` is convex and `L_total`-smooth.
  This implies `L_S` is convex and `L_total`-smooth.
- **(A2) Lipschitz:** `‖∇ℓ(θ;z)‖ ≤ G` uniformly. Equivalently, `‖∇L_S(θ)‖ ≤ G_S := ‖∇L_S‖_∞` and
  `√(E_z ‖∇L_N(θ;z)‖^2) ≤ σ_N`, with `G ≤ G_S + σ_N`.
- **Step size:** `η ≤ 2/L_total`.

## Generalization gap

Define `gen(S) := E_z[ℓ(θ_T(S);z)] − (1/m) Σ_i ℓ(θ_T(S); z_i)`. We bound `E_S[gen(S)]`.

### Step 1: gap reduces to a leave-one-out stability of `L_N`

By the population/residual splitting,
```
gen(S) = E_z L_S(θ_T) + E_z L_N(θ_T;z) − L_S(θ_T) − (1/m)Σ_i L_N(θ_T;z_i)
       = − (1/m) Σ_i L_N(θ_T(S); z_i)                                (*)
```
(since `E_z L_N(θ_T;z) = 0` for any fixed `θ_T`, and `L_S(θ_T)` cancels with itself).

Let `S^{(i)} := (z_1,...,z_{i−1}, z'_i, z_{i+1},...,z_m)` with fresh `z'_i ~ D` independent of `S`.
Let `θ_T^{(i)} := θ_T(S^{(i)})`. By independence, `E[L_N(θ_T^{(i)}; z_i)] = 0`. So

```
E_S[gen(S)] = − (1/m) Σ_i E_{S,z'_i}[L_N(θ_T(S); z_i) − L_N(θ_T^{(i)}; z_i)].   (**)
```

By per-sample Lipschitzness of `L_N(·;z)` (slope `≤ ‖∇L_N(·;z)‖`):
```
|L_N(θ_T;z_i) − L_N(θ_T^{(i)};z_i)| ≤ ‖∇L_N(·;z_i)‖_∞ · ‖θ_T − θ_T^{(i)}‖.
```

Taking absolute values in (**) and Cauchy-Schwarz on the product (over the joint
randomness of `S, z'_i, {i_t}`):

```
|E_S[gen(S)]| ≤ (1/m) Σ_i √( E[‖∇L_N(·;z_i)‖^2] ) · √( E[‖θ_T − θ_T^{(i)}‖^2] )
           ≤ σ_N · max_i √( E[‖θ_T − θ_T^{(i)}‖^2] ).                              (***)
```

### Step 2: stability bound on `E ‖θ_T − θ_T^{(i)}‖^2`

Couple `(θ_t)` and `(θ_t^{(i)})` with the same index sequence `{i_t}`. Let
`δ_t := θ_t − θ_t^{(i)}`, `Δ_t := E ‖δ_t‖^2`. We split into signal and noise contributions
to the per-step recursion.

**Case A: i_t ≠ i.** Both chains use sample `z_{i_t}`. Then
```
δ_{t+1} = (I − η ∇^2_θ ℓ(·;z_{i_t})) acting between θ_t and θ_t^{(i)}.
```
Formally, for any convex `L`-smooth `f` and `η ≤ 2/L`, the operator `T(θ) := θ − η ∇f(θ)` is
non-expansive: `‖T(θ) − T(θ')‖ ≤ ‖θ − θ'‖` (Baillon–Haddad / co-coercivity). Hence
`‖δ_{t+1}‖ ≤ ‖δ_t‖`, and `‖δ_{t+1}‖^2 ≤ ‖δ_t‖^2`.

**Case B: i_t = i.** Chain 1 uses `z_i`, chain 2 uses `z'_i`. Decompose:
```
δ_{t+1} = δ_t − η[∇ℓ(θ_t;z_i) − ∇ℓ(θ_t^{(i)};z_i)]   (signal-direction step on z_i)
              − η[∇ℓ(θ_t^{(i)};z_i) − ∇ℓ(θ_t^{(i)};z'_i)]   (sample swap at θ_t^{(i)}).
```
Let
- `u_t := δ_t − η[∇ℓ(θ_t;z_i) − ∇ℓ(θ_t^{(i)};z_i)]` (non-expansive step on chain 1's sample),
- `w_t := η[∇ℓ(θ_t^{(i)};z_i) − ∇ℓ(θ_t^{(i)};z'_i)] = η[∇L_N(θ_t^{(i)};z_i) − ∇L_N(θ_t^{(i)};z'_i)]`
  (the `∇L_S(θ_t^{(i)})` pieces cancel since they don't depend on `z`).

By non-expansiveness, `‖u_t‖ ≤ ‖δ_t‖`. Therefore
```
‖δ_{t+1}‖^2 = ‖u_t − w_t‖^2 = ‖u_t‖^2 − 2⟨u_t, w_t⟩ + ‖w_t‖^2
            ≤ ‖δ_t‖^2 − 2⟨u_t, w_t⟩ + ‖w_t‖^2.
```

Take conditional expectation given `F_t` and the event `{i_t = i}`. Crucially, `z'_i` has not
been used by either chain before time `t` (it only enters chain 2's update precisely when `i_t = i`,
and there has been no such step before — since this is the *first* time we condition on it
... actually `z'_i` is used at every `t : i_t = i`. So its conditional law given `F_t` is its
posterior given past usages.)

**Sub-case clean coupling.** Use the standard SGD-with-replacement *bootstrap* coupling: at
each `t` with `i_t = i`, draw a *fresh* `z'_i,t ~ D` independent of the past. Equivalently,
treat the two SGD chains as bootstrap-trained with independent fresh noise on the differing
coordinate. (This corresponds to a slightly looser model than full leave-one-out replacement,
but it is the model used in HRS Theorem 3.7 and is the right one for sampling-with-replacement
SGD.) Under this model, conditionally on `F_t` and `{i_t = i}`,
`z'_i,t` is independent of `θ_t^{(i)}` (and of everything in `F_t`), so
```
E[w_t | F_t, i_t = i] = η · E[∇L_N(θ_t^{(i)}; z_i)] − η · E_{z'_i,t}[∇L_N(θ_t^{(i)}; z'_i,t)] = 0,
```
because `z_i` is also (under bootstrap coupling) independent of `θ_t^{(i)}` at this step and
both expectations vanish: `E_z ∇L_N(θ;z) = 0`. (Strictly, `z_i` was used at past steps when
`i_s = i, s < t`. So `θ_t` does depend on `z_i`. But `θ_t^{(i)}` does not. So
`E_{z_i}[∇L_N(θ_t^{(i)}; z_i)] = 0` rigorously, conditionally on `θ_t^{(i)}`.)

Also
```
E[‖w_t‖^2 | F_t, i_t = i] = η^2 · E[‖∇L_N(θ_t^{(i)}; z_i) − ∇L_N(θ_t^{(i)}; z'_i,t)‖^2]
                           ≤ η^2 · 2 · sup_θ E_z ‖∇L_N(θ;z)‖^2 = 2η^2 σ_N^2.
```

Therefore
```
E[‖δ_{t+1}‖^2 | F_t, i_t = i] ≤ ‖δ_t‖^2 − 2 E[⟨u_t, w_t⟩ | F_t, i_t = i] + 2η^2 σ_N^2.
```
The cross-term: `u_t` depends on `θ_t, θ_t^{(i)}, z_i` (through its appearance in the chain-1
gradient at step `t`). To handle it, use Cauchy-Schwarz inside the conditional expectation:
```
|E[⟨u_t, w_t⟩ | F_t, i_t = i]| ≤ √(E‖u_t‖^2) · √(E‖w_t‖^2) ≤ ‖δ_t‖ · η√2 σ_N.
```

So
```
E[‖δ_{t+1}‖^2 | F_t, i_t = i] ≤ ‖δ_t‖^2 + 2η√2 σ_N · ‖δ_t‖ + 2η^2 σ_N^2 = (‖δ_t‖ + η√2 σ_N)^2.
```

Taking outer expectation and combining cases A and B:
```
Δ_{t+1} ≤ (1 − 1/m) Δ_t + (1/m) · E[(‖δ_t‖ + η√2 σ_N)^2].
```

By `(a+b)^2 = a^2 + 2ab + b^2` and Cauchy-Schwarz `E[‖δ_t‖] ≤ √Δ_t`:
```
Δ_{t+1} ≤ Δ_t + (1/m)[2η√2 σ_N √Δ_t + 2η^2 σ_N^2].                         (♣)
```

### Step 3: solving the recursion

Let `D_t := √Δ_t`. Then `D_{t+1}^2 ≤ D_t^2 + (2η√2 σ_N/m) D_t + 2η^2 σ_N^2/m`.
The right side equals `(D_t + (η√2 σ_N)/m)^2 + 2η^2 σ_N^2/m − 2η^2 σ_N^2 / m^2`. For
`m ≥ 1`, drop the negative term:
```
D_{t+1} ≤ D_t + (η√2 σ_N)/m + (the 2η^2 σ_N^2/m piece treated additively in D_t^2).
```

Cleaner: solve `Δ_{t+1} ≤ Δ_t + (a/m) √Δ_t + (b/m)` with `a = 2η√2 σ_N`, `b = 2η^2 σ_N^2`. By
induction, `Δ_t ≤ ((a t)/(2m))^2 + bt/m`. Verify:
- `Δ_0 = 0` ✓.
- Inductive step: `Δ_{t+1} ≤ ((at)/(2m))^2 + bt/m + (a/m)·(at/(2m) + √(bt/m)) + b/m`
  `= a^2 t^2/(4m^2) + a^2 t/(2m^2) + a√(bt/m)/m + b(t+1)/m`
  `= a^2(t+1)^2/(4m^2) − a^2/(4m^2) + a√(bt/m)/m + b(t+1)/m`
  `≤ a^2(t+1)^2/(4m^2) + b(t+1)/m` provided `a√(bt/m)/m ≤ a^2/(4m^2)`,
  i.e. `√(bt/m) ≤ a/(4m)`. With our `a, b`, this is `√(2η^2 σ_N^2 t/m) ≤ η√2 σ_N/(2m)`,
  i.e. `√(t/m) ≤ 1/(2m)`, only for tiny `t`. So the induction is too tight.

Looser bound: just sum up (♣) crudely. Let `D_t ≤ U_t` where `U_t` solves the equality
`U_{t+1}^2 = U_t^2 + (a/m) U_t + b/m`. Bound `U_T ≤ (a T)/(2m) + √(bT/m)` (this satisfies
the recursion to leading order):
- `(aT/(2m))^2 + bT/m = a^2T^2/(4m^2) + bT/m`,
- and `Δ_T ≤ a^2T^2/(4m^2) + bT/m + (lower order in T/m)`.

Substituting `a, b`:
```
Δ_T ≤ (2η√2 σ_N · T)^2 / (4m^2) + 2η^2 σ_N^2 · T / m
    = 2 η^2 σ_N^2 T^2 / m^2 + 2 η^2 σ_N^2 T / m.
```

So
```
√Δ_T ≤ √(2 η^2 σ_N^2 T^2 / m^2 + 2 η^2 σ_N^2 T / m)
     ≤ η σ_N √(2 T^2/m^2 + 2T/m)
     ≤ η σ_N · (√2 T/m + √(2T/m))    (by √(x+y) ≤ √x + √y)
     = √2 η σ_N T/m + η σ_N √(2T/m).
```

### Step 4: assembling the bound

Plugging back into (***):
```
|E_S[gen]| ≤ σ_N · √Δ_T ≤ √2 η σ_N^2 T/m + η σ_N^2 √(2T/m).             (★)
```

The first term `√2 η σ_N^2 T/m = O(σ_N^2 ηT/m)` is the **noise-driven term** `G_N(T)`.

**Where does the signal-driven term come from?** It does NOT appear if we simply bound
`|L_N(θ_T;z_i) − L_N(θ_T^{(i)};z_i)| ≤ G_N · δ_T` with `G_N := σ_N` (per-sample-RMS). It DOES
appear if we more carefully bound the *deterministic part* of `δ_T` (which grows like
`O(η G_S T/m)` from the bias of using `z_i` vs `z'_i`), then apply Lipschitz to `L_N`.

Specifically, decompose `δ_T = δ_T^{det} + δ_T^{stoch}` where `δ_T^{det}` is the
expectation-component and `δ_T^{stoch}` is the mean-zero fluctuation. The deterministic
part satisfies `‖E δ_T‖ ≤ η G_S · T/m` (bias from one perturbed sample, propagated through
non-expansive iterations with a single `O(η G_S)` push at each `i_t = i` step). The stochastic
part satisfies `E ‖δ_T^{stoch}‖^2 ≤ 2 η^2 σ_N^2 T/m`.

But `(*)`/`(**)` already extracts the leading bias, so the relevant quantity is
`E‖δ_T‖^2`, and the deterministic part contributes `η^2 G_S^2 T^2/m^2` to it. Specifically,
when applying Cauchy-Schwarz at (***), we should split:

```
E[(L_N(θ_T;z_i) − L_N(θ_T^{(i)};z_i))^2] ≤ E[‖∇L_N(·;z_i)‖^2] · E[‖δ_T‖^2]
                                       ≤ σ_N^2 · (2 η^2 σ_N^2 T/m + 2η^2 G_S^2 T^2/m^2 + ...)
```

The `G_S^2 T^2/m^2` term in `E‖δ_T‖^2` is what we missed by treating the cross-term
`⟨u_t, w_t⟩` only via Cauchy-Schwarz. Correctly tracking the **bias** term
`E[w_t] = η · E[∇L_N(θ_t^{(i)}; z_i) − ∇L_N(θ_t^{(i)}; z'_i,t)] = 0` — wait, this is zero!
So the deterministic `δ` does NOT receive a `G_S` push at `i_t = i` steps in this coupling.

Re-examination: in the bootstrap coupling, both `z_i` and `z'_i,t` are mean-zero in
`∇L_N(·; ·)`. So the bias at each `i_t = i` step is zero, and `δ_T` is purely stochastic.
Then `E‖δ_T‖^2 = O(η^2 σ_N^2 T/m)` and `|gen| = O(η σ_N^2 √(T/m))`.

This means the `G_S^2` term **does not appear** under this coupling/decomposition. The
problem statement's `G_S(T) = O(‖∇L_S‖^2 η^2 T/m)` term must come from a *different*
source — namely, the **non-leave-one-out** part of the gen gap that we discarded by saying
"`E_{z'_i}[L_N(θ_T^{(i)}; z_i)] = 0`". This is the **optimization gap** of `L_S` itself,
which Zhang et al. include in their decomposition. Specifically, the full statement
`|E[L_S(θ_T)] − L̂(θ_T)|` lumps together:
- generalization on `L_N` part (gives `G_N`),
- empirical-vs-expected of `L_S(θ_T)` evaluated at the SGD endpoint (gives `G_S`, since
  the SGD endpoint has `E‖θ_T − θ̃_T‖^2 = O(η σ_N^2 T)` deviation from the deterministic
  GD trajectory `θ̃_T`, and `L_S` is `L_total`-smooth so `|L_S(θ_T) − L_S(θ̃_T)|`
  contributes…).

This needs reformulation. **Let me write a cleaner v2.**
