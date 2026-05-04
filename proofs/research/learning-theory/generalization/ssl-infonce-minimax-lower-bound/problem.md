# Information-Theoretic Limits of Self-Supervised Pre-Training (InfoNCE)

## Source
- Paper: Saunshi et al. (theoretical analysis of contrastive learning) +
  HaoChen et al. spectral SSL theory; the precise minimax-lower-bound formulation here
  is original synthesis.
- Context: Provide an information-theoretic lower bound on downstream excess risk
  inherited from SSL pre-training, in terms of the conditional mutual information
  in the augmentation distribution.

## Statement

**Setup.**
- A ~ P_A: augmentation random variable.
- (X, X') | A is a positive pair sampled from P_{X,X'|A} (SSL data model).
- Y | X ~ Bernoulli(σ(w* · f*(X))) with f* : X → R^d and ‖w*‖² ≤ d.
- Z = f_θ(X) is a representation learned by minimizing InfoNCE on n unlabeled samples.
- ŵ_∞ is the *population* linear-probe optimum on top of f_θ (n_down → ∞).
- I(X;X'|A) := E_A I(X;X'|A=a) is the conditional mutual information.

**Theorem.** Under the standard SSL data-generating assumption (the ground-truth
representation f* enters upstream samples only through the augmentation-conditional
positive-pair coupling), there is a universal constant C > 0 such that

  inf_{f_θ}  sup_{(f*, w*)}  ( E[(Y − σ(ŵ_∞·f_θ(X)))²] − Bayes_risk )
    ≥  C · d² / (n · I(X;X'|A) · polylog factors)

provided n · I(X;X'|A) ≤ c · d² for some absolute constant c.

## Difficulty
research

## Honesty caveats (see notes.md)
- Bound is up to log factors.
- Sup is jointly over (f*, w*); sup over w* alone gives only d/(n·I).
- ‖w*‖² ≤ d normalization (each coord O(1)); with unit-ball w*, rate is d/(n·I).
- Downstream sample n_down → ∞; finite n_down adds independent O(d/n_down) ERM term.
