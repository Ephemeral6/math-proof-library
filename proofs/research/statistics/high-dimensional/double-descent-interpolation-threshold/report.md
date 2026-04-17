# Proof Report: Double Descent — Interpolation Threshold Phenomenon

## 1. Problem Statement

Consider ridgeless least squares $\hat{\beta} = X^+ y$ where $X \in \mathbb{R}^{n \times d}$ has i.i.d. $\mathcal{N}(0, I_d/d)$ rows, $y = X\beta^* + \epsilon$ with $\epsilon \sim \mathcal{N}(0, \sigma^2 I_n)$. In the proportional regime $d/n \to \gamma$:

1. Underparameterized ($\gamma < 1$): $R(\hat{\beta}) \to \sigma^2\gamma/(1 - \gamma)$
2. Overparameterized ($\gamma > 1$): $R(\hat{\beta}) \to \sigma^2/(\gamma - 1) + \text{bias term}$
3. Both diverge as $\gamma \to 1$

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed |
| Explorer | Opus | 4 proofs attempted, 3 succeeded (Route 2 incomplete) |
| Judge | Sonnet | Route 3 selected (score: 34/40) |
| Audit | Opus | PASS (1 round, 0 invalid steps) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

| Route | Name | Outcome | Score |
|-------|------|---------|-------|
| 1 | Random Matrix Theory via Marchenko-Pastur Law | Complete | 23/40 |
| 2 | Resolvent / Deterministic Equivalent | Failed (incomplete) | N/A |
| 3 | Direct Bias-Variance Decomposition + LLN | Complete | 34/40 |
| 5 | SVD + Marchenko-Pastur Integration | Complete | 25/40 |

All three successful routes independently confirmed the same results, including that the correct overparameterized bias is $(\gamma-1)/\gamma \cdot b^2$ (not $1/(\gamma-1) \cdot |\beta^*|^2$ as stated in the problem).

## 4. Final Proof

### Setup

Write $X = Z/\sqrt{d}$ where $Z \in \mathbb{R}^{n \times d}$ has i.i.d. $\mathcal{N}(0,1)$ entries. The model is $y = X\beta^* + \epsilon$ with $\epsilon \sim \mathcal{N}(0, \sigma^2 I_n)$. The prediction risk:

$$R(\hat\beta) = \frac{1}{d}\mathbb{E}\|\hat\beta - \beta^*\|^2$$

### Step 1: Bias-Variance Decomposition

$$\hat\beta - \beta^* = -(I_d - X^+X)\beta^* + X^+\epsilon$$

These terms are orthogonal (bias ∈ ker(X), variance ∈ row(X)), giving:

$$\mathbb{E}\|\hat\beta - \beta^*\|^2 = \mathbb{E}\|(I_d - X^+X)\beta^*\|^2 + \sigma^2 \mathbb{E}[\text{tr}((X^TX)^+)]$$

### Step 2: Underparameterized ($\gamma < 1$)

Bias = 0 since $X^+X = I_d$. Using $(X^TX)^{-1} = d(Z^TZ)^{-1}$ and the inverse Wishart moment $\mathbb{E}[(Z^TZ)^{-1}] = \frac{1}{n-d-1}I_d$:

$$R = \frac{\sigma^2 d}{n - d - 1} \to \frac{\sigma^2\gamma}{1 - \gamma}$$

### Step 3: Overparameterized ($\gamma > 1$)

**Variance:** Using $ZZ^T \sim W_n(d, I_n)$ and $\mathbb{E}[(ZZ^T)^{-1}] = \frac{1}{d-n-1}I_n$:

$$\text{Variance} \to \frac{\sigma^2}{\gamma - 1}$$

**Bias:** By rotational invariance, $\mathbb{E}[I_d - P_X] = \frac{d-n}{d}I_d$:

$$\text{Bias} \to \frac{\gamma - 1}{\gamma} \cdot b^2 \quad \text{where } b^2 = \lim \|\beta^*\|^2/d$$

### Step 4: Divergence at $\gamma = 1$

Both denominators $(n-d-1)$ and $(d-n-1)$ vanish as $\gamma \to 1$, so $R \to +\infty$. This is the interpolation threshold / double descent peak.

**Note on the problem statement:** The stated bias term $|\beta^*|^2/(\gamma-1)$ is incorrect. All three independent proof routes confirm the correct bias is $(\gamma-1)/\gamma \cdot b^2$. The variance term $\sigma^2/(\gamma-1)$ matches the problem statement.

## 5. Audit Result

**PASS** after 1 round. All 4 steps validated. 2 medium-severity presentation issues (idempotency step implicit, independence assumption implicit), 3 low-severity issues. No correctness errors.

## 6. Fix History

No fixes needed.
