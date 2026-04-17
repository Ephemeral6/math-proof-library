# Proof: Implicit Bias of GD — Max-Margin Convergence

## Notation
- Signed data vectors: $z_i = y_i x_i$.
- Gram matrix: $H_{ij} = z_i^T z_j$.
- Margins: $m_i(t) = z_i^T w_t$.
- SVM solution: $w^* = \sum_{i \in \mathcal{S}} \alpha_i^* z_i$, normalized so $z_i^T w^* = 1$ for $i \in \mathcal{S}$ (support vectors), $z_i^T w^* > 1$ for $i \notin \mathcal{S}$.
- $R = \max_i \|x_i\|$.

## Step 1: Smoothness and descent

The Hessian satisfies $\nabla^2 L(w) = \frac{1}{n}\sum_i \sigma(m_i)\sigma(-m_i)z_iz_i^T \preceq \frac{1}{4n}\sum_i z_iz_i^T$ since $\sigma(s)(1-\sigma(s)) \leq 1/4$. So $L$ is $\beta$-smooth with $\beta = \frac{1}{4n}\lambda_{\max}(\sum_i z_iz_i^T)$. For $\eta \leq 1/\beta$, the descent lemma gives:
$$L(w_{t+1}) \leq L(w_t) - \frac{\eta}{2}\|\nabla L(w_t)\|^2$$

Summing over $t$: $\sum_{t=0}^{\infty}\|\nabla L(w_t)\|^2 \leq 2L(w_0)/\eta < \infty$, hence $\|\nabla L(w_t)\| \to 0$.

## Step 2: Norm divergence — no finite critical points

If $\nabla L(\bar{w}) = 0$ for some finite $\bar{w}$, then $\sum_i \mu_i z_i = 0$ with $\mu_i = \sigma(-z_i^T\bar{w}) > 0$. Taking inner product with a separating direction $v$ (satisfying $z_i^Tv > 0$ for all $i$): $0 = \sum_i \mu_i(z_i^Tv) > 0$. Contradiction.

Since $\|\nabla L(w_t)\| \to 0$, if $\{w_t\}$ were bounded, it would have a limit point $\bar{w}$ with $\nabla L(\bar{w})=0$ (using $\|w_{t+1}-w_t\| \to 0$ to upgrade subsequential convergence to full convergence). This contradicts the above, so $\|w_t\| \to \infty$.

## Step 3: All margins diverge to $+\infty$

For any $j$, using the inner product of $-\nabla L(w_t)$ with $w^*/\|w^*\|$:
$$\|\nabla L(w_t)\| \geq \langle -\nabla L(w_t), w^*/\|w^*\|\rangle = \frac{1}{n\|w^*\|}\sum_i \sigma(-m_i(t))(z_i^Tw^*) \geq \frac{1}{n\|w^*\|}\sigma(-m_j(t))$$
since $z_i^Tw^* \geq 1$.

If $\liminf_t m_j(t) \leq M$, then $\sigma(-m_j(t)) \geq \sigma(-M) > 0$ infinitely often, contradicting $\|\nabla L(w_t)\| \to 0$. So $m_i(t) \to +\infty$ for all $i$, and $L(w_t) \to 0$.

## Step 4: Iterate telescoping

Since $\sigma(-m) = e^{-m}(1+O(e^{-m}))$ for $m \to \infty$, summing the GD updates:
$$w_T = w_0 + \sum_{i=1}^n \bar{\beta}_i(T) z_i + r_T$$
where $\bar{\beta}_i(T) = \frac{\eta}{n}\sum_{t=0}^{T-1}e^{-m_i(t)}$ and $\|r_T\| \leq \frac{\eta R}{n}\sum_t\sum_i e^{-2m_i(t)} = O(1)$.

## Step 5: Loss decays as $O(1/t)$, minimum margin is $\log t + O(1)$

Define $S_t = \frac{1}{n}\sum_i \sigma(-m_i(t))$. Using $\log(1+e^{-m}) \leq e^{-m}$ and $\sigma(-m) \geq e^{-m}/2$ for $m \geq 0$:
$$L(w_t) \leq 2S_t, \quad \|\nabla L(w_t)\| \geq S_t/\|w^*\|$$

Combining with the descent lemma:
$$L(w_{t+1}) \leq L(w_t) - \frac{\eta}{8\|w^*\|^2}L(w_t)^2 \implies L(w_t) \leq \frac{8\|w^*\|^2}{\eta t}$$

Since $L(w_t) \geq \frac{1}{2n}e^{-m_{\min}(t)}$:
$$m_{\min}(t) \geq \log t - \log(16n\|w^*\|^2/\eta) = \log t - C_1$$

## Step 6: All margins are $O(\log t)$

$\|w_T\| \leq \|w_0\| + \eta R\sum_{t=1}^{T} S_t = O(\log T)$ (since $S_t = O(1/t)$). Therefore $m_i(t) \leq R\|w_t\| = O(\log t)$ for all $i$.

Combined with Step 5: $m_{\min}(t) = \log t + O(1)$.

## Step 7: SVM KKT conditions from limiting coefficients

Let $B(T) = \sum_i \bar{\beta}_i(T) = \Theta(\log T)$ and $\hat{\beta}_i(T) = \bar{\beta}_i(T)/B(T)$.

Since $w_0, r_T = O(1)$ and $B(T) \to \infty$: any limit point of $\hat{\beta}(T)$ defines $\tilde{w} = \sum_i \hat{\beta}_i^\infty z_i$ with $w_T/B(T) \to \tilde{w}$.

The limiting margin ratios are $h_i = \lim m_i(T)/B(T) = \sum_j \hat{\beta}_j^\infty H_{ij}$. For data points with $h_i > h_{\min}$, $e^{-m_i(t)}$ decays as $t^{-h_i C}$ with exponent $> 1$, so $\bar{\beta}_i(T) = O(1)$ and $\hat{\beta}_i^\infty = 0$.

Let $\mathcal{S}' = \{i : h_i = h_{\min}\}$. Setting $\alpha_i' = \hat{\beta}_i^\infty / h_{\min}$, the conditions become:
$$\sum_{j \in \mathcal{S}'}\alpha_j' H_{ij} = 1 \;\;\forall i \in \mathcal{S}', \qquad \sum_{j \in \mathcal{S}'}\alpha_j' H_{ij} > 1 \;\;\forall i \notin \mathcal{S}', \qquad \alpha_j' > 0 \;\;\forall j \in \mathcal{S}'$$

These are precisely the KKT conditions for the hard-margin SVM. Since the SVM primal solution is unique (strict convexity of $\|w\|^2$): $\tilde{w} \propto w^*$.

## Step 8: Conclusion

Every convergent subsequence of $w_T/\|w_T\|$ converges to $w^*/\|w^*\|$ (by the uniqueness argument in Step 7). Since the unit sphere is compact, the full sequence converges:
$$\frac{w_t}{\|w_t\|} \to \frac{w^*}{\|w^*\|} \quad \blacksquare$$
