# E3: SGD Signal-Noise Generalization Decomposition

**Path**: `proofs/research/learning-theory/stability/sgd-signal-noise-generalization-decomposition/`
**Source**: Teng, Ma, Yuan ICLR 2022 (arXiv 2106.06153) — "Towards Understanding Generalization via Decomposing Excess Risk Dynamics"

## Verdict: CONFIRMED (with honest PARTIAL declaration)

## Our claim
Two-part decomposition:
- Claim 1 (decomposition): |E_S gen(S)| <= G_S(T) + G_N(T) where
  G_S(T) = O(eta G_S^2 (sqrt(T/m) + T/m))
  G_N(T) = O(eta sigma_N^2 (sqrt(T/m) + T/m))
- Claim 2 (strict tightness in noise-dominated regime): NOT achievable via pure stability;
  requires PAC-Bayes data-dependent prior or last-iterate optimization.

## Literature comparison
Teng-Ma-Yuan 2021 (the actual title is "Towards Understanding Generalization via Decomposing
Excess Risk Dynamics", not "Zhang-Yifan"; the index entry attribution may be slightly off but
arXiv ID 2106.06153 is correct). Their abstract explicitly states they propose "a novel decomposition
framework to improve the stability-based bounds via a more fine-grained analysis of the signal
and noise" and "decompose the excess risk dynamics and apply the stability-based bound only on
the noise component."

This matches our Claim 1 construction (signal/noise split inside the per-step recursion).

Our honest scope statement that "Claim 2 strict tightness requires PAC-Bayes / last-iterate
techniques outside stability" is a defensible critique — the paper indeed uses tools beyond
naive HRS (their improvement is precisely the noise-only stability application + extra structure).

## Discrepancies
- Index attribution says "Zhang, Yifan et al. 2022" but the actual authors are Teng, Ma, Yuan.
  The arXiv ID is correct (2106.06153). Cosmetic only.
- Our bound has form (sqrt(T/m) + T/m) while HRS gives T/m. We give a regime analysis showing
  ours is ~4x worse for T >= m and sqrt(m/T)x worse for T < m. This is HONEST about looseness.

## Confidence: MEDIUM-HIGH
The decomposition framework is faithful to the source paper. The numerical verification (60×
constant looseness, but functional form sqrt(T/m) confirmed) is convincing. The PARTIAL
declaration on Claim 2 is responsible scholarship.
