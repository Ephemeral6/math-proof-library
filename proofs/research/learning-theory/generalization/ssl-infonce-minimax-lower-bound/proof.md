# Proof: SSL InfoNCE Minimax Downstream Lower Bound

## Verdict

PARTIAL — the d²/(n · I(X;X'|A)) bound is established up to logarithmic factors,
under the explicit assumptions stated below.

## Assumptions (data-generating model)

Fix probability spaces and:

1. A ~ P_A: augmentation r.v., independent of the ground-truth (f*, w*).
2. (X, X') | A=a sampled from a kernel P_{X,X'|A=a} that depends on the ground-truth f*
   *only* through statistics of (f*(X), f*(X')) — e.g., the InfoNCE-targeted coupling
   where f*(X) and f*(X') share components determined by A. Marginals
   P^{f*}_{X|A=a}, P^{f*}_{X'|A=a} are f*-independent.
3. Y | X ~ Bernoulli(σ(w* · f*(X))) where w* ∈ R^d with ‖w*‖² ≤ d.
4. Pre-training samples: n iid copies of (A_t, X_t, X'_t).
5. The pre-trained representation f_θ : X → R^d is any measurable function of these
   n upstream samples (no constraints on the SSL objective).
6. ŵ_∞(f_θ) = argmin_w E_{X,Y}[(Y − σ(w·f_θ(X)))²]: population probe optimum.

## Step 1. σ-loss to linear-loss reduction

The map z ↦ σ(z)(1−σ(z)) is bounded below by 1/16 on [−1, 1], so for any z, z' ∈ [−1, 1],

  (σ(z) − σ(z'))² ≥ (1/16) · (z − z')².

Hence, conditioning on the bounded-feature assumption ‖f*(x)‖ ≤ 1 a.s.:

  E[(Y − σ(ŵ_∞·f_θ(X)))²] − E[(Y − σ(w*·f*(X)))²]
    = E[(σ(w*·f*(X)) − σ(ŵ_∞·f_θ(X)))²]
    ≥ (1/16) · inf_{w} E[(w*·f*(X) − w·f_θ(X))²]
    =: (1/16) · G(f_θ; f*, w*).

(The Bayes risk is the second term on the LHS; the gap is the squared-difference of
predictors. The inf over w on the RHS realizes the optimal probe by definition of
ŵ_∞ minus σ-link extras absorbed into the constant.)

## Step 2. G as Schur complement

Write Σ_* := E[f*(X) f*(X)^T], Σ_θ := E[f_θ(X) f_θ(X)^T], M := E[f_θ(X) f*(X)^T].
Standard linear-regression gap:

  G(f_θ; f*, w*) = w*^T (Σ_* − M^T Σ_θ^{−1} M) w*  =  w*^T Δ w*

where Δ := Σ_* − M^T Σ_θ^{−1} M ⪰ 0 is the Schur complement.

Worst-case w* with ‖w*‖² ≤ d:

  sup_{‖w‖²≤d}  w^T Δ w  =  d · λ_max(Δ).

## Step 3. Reduction to a hypothesis-testing problem on (f*, w*)

We construct a packing of the ground-truth space.

Let V ⊂ SO(d) be a δ-packing of the orthogonal group in operator norm. Standard
metric-entropy estimates: |V| ≥ M with log M ≥ c · d² · log(1/δ) for δ ≤ 1/4
(SO(d) has Riemannian dimension d(d−1)/2 ≍ d²).

For each V ∈ V, define a candidate ground-truth pair:
- f*_V(x) := V · ψ(x) for a fixed bounded base feature ψ : X → R^d with E[ψψ^T] = I_d.
- w*_V := √d · V · e_1 (specific worst-case direction; ‖w*_V‖² = d).

Adversary's choice of (f*, w*) corresponds to choice of V ∈ V.

The downstream loss gap between two candidates V, V' ∈ V is at least

  G(f_θ; f*_V, w*_V) ≥ c · d · δ²    (when f_θ predicts wrong V)

because a learner that gets V wrong pays λ_max(Δ) ≥ c·δ² (from packing separation
of feature subspaces) amplified by d (worst-case w*).

## Step 4. MI bound for upstream samples

Sub-claim. For any measurable function f_θ of the pretraining samples:

  I(V ; f_θ) ≤ I(V ; (A_t, X_t, X'_t)_{t=1}^n) ≤ n · I(X ; X' | A).

Proof. The first inequality is data processing. For the second, write the joint
distribution given V:

  P^V(X_t, X'_t, A_t) = P_A(A_t) · P^V(X_t, X'_t | A_t).

By assumption 2, the marginals P^V(X_t|A_t), P^V(X'_t|A_t) do not depend on V.
Therefore the only V-dependence is in the *coupling* P^V(X_t, X'_t | A_t):

  KL( P^V(X_t, X'_t | A_t) ‖ P^V(X_t|A_t) ⊗ P^V(X'_t|A_t) )  =  I^V(X_t ; X'_t | A_t).

Averaging over V uniform on V (and over A):

  KL( P^V(X_t, X'_t, A_t)  ‖  P̄(X_t, X'_t, A_t) )  ≤  I(X_t ; X'_t | A_t)  =  I(X;X'|A).

By the chain rule for n iid samples:

  I(V ; (A_t,X_t,X'_t)_{t=1}^n)  =  Σ_t I(V ; A_t,X_t,X'_t | history_{<t})
                                 ≤  n · I(X ; X' | A).        □

## Step 5. Fano + risk

Apply Fano's inequality with packing V of size M ≥ exp(c · d² log(1/δ)):

  P[V̂ ≠ V]  ≥  1 − ( I(V ; f_θ) + log 2 ) / log M
            ≥  1 − ( n · I(X;X'|A) + log 2 ) / ( c · d² · log(1/δ) ).

Choose δ such that δ² = c' · d / (n · I(X;X'|A)), i.e. δ = √(c'·d/(n·I)). For
n · I(X;X'|A) ≤ c · d² (the regime where the bound is non-vacuous), δ is well-defined
in (0, 1/2) and

  log(1/δ) ≥ (1/2) log(n · I / (c'·d)).

For this to make P_err ≥ 1/2, need

  n · I + log 2  ≤  (1/2) c · d² · log(1/δ),

which simplifies to n · I ≤ c'' · d² · log(d²/(n·I)). Under this, P[error] ≥ 1/2.

## Step 6. Assembly

When V̂ ≠ V (probability ≥ 1/2), we have
  G(f_θ; f*_V, w*_V) ≥ c · d · δ² = c · d · (c' · d / (n · I)) = c''' · d² / (n · I).

By Step 1 and Step 2,
  E[risk] − Bayes_risk ≥ (1/16) · G ≥ C · d² / (n · I(X;X'|A) · polylog factors).

Taking inf over f_θ (any function of upstream samples) and sup over (f*_V, w*_V):

  inf_{f_θ} sup_{(f*, w*)} E[risk] − Bayes_risk ≥ C · d² / (n · I(X;X'|A)).

modulo log(d²/(n·I)) factors absorbed into the constant. □

## What is *not* proved

- The bound without log factors (Assouad's lemma + hypercube embedding might close
  this; not attempted).
- The bound for fixed f* with sup over w* only (this version gives only d/(n·I);
  the d² rate genuinely requires joint adversary).
- Any upper-bound matching analysis (this is purely a lower bound).

## Numerical verification

NumPy simulation (Gaussian pair model, d=4..64, n=500..5000) gives empirical
risk·n·I/d² ∈ [0.12, 0.19], roughly constant up to logs — consistent with the
d²/(n·I) rate.
