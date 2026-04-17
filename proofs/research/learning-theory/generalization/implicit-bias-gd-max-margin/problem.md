# Implicit Bias of Gradient Descent: Max-Margin Convergence

## Source
- Paper: Soudry et al. 2018 (JMLR) — "The Implicit Bias of Gradient Descent on Separable Data"
- Context: Fundamental result in implicit regularization theory. Shows that gradient descent on the logistic loss with linearly separable data converges in direction to the $\ell_2$ max-margin (hard-margin SVM) classifier, without any explicit regularization.

## Statement

For linearly separable data $\{(x_i, y_i)\}_{i=1}^n$ with $x_i \in \mathbb{R}^d$, $y_i \in \{-1,+1\}$, consider gradient descent on the empirical logistic loss:
$$L(w) = \frac{1}{n}\sum_{i=1}^n \log(1 + e^{-y_i w^T x_i})$$
with update $w_{t+1} = w_t - \eta \nabla L(w_t)$ from any initialization $w_0 \in \mathbb{R}^d$, and step size $\eta \leq 1/\beta$ where $\beta = \frac{1}{4n}\lambda_{\max}(\sum_i x_ix_i^T)$.

Then:
$$\frac{w_t}{\|w_t\|} \to \frac{w^*}{\|w^*\|}$$
where $w^* = \arg\min\{\|w\| : y_i w^T x_i \geq 1 \;\forall i\}$ is the hard-margin SVM solution (equivalently, $w^*/\|w^*\| = \arg\max_{\|w\|=1}\min_i y_i w^T x_i$).

## Difficulty
research
