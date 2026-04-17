# Best Proof: SGD Uniform Stability and Generalization

**Route**: Hardt-Recht-Singer Recursive Coupling

## Setup
$f(w;z)$ convex in $w$, $\beta$-smooth, $L$-Lipschitz. Datasets $S, S'$ differ at index $j$. SGD with same initialization $w_0 = w_0'$ and same index sequence $\{i_t\}$. Step sizes $\alpha_t \leq 2/\beta$.

## Step 1: Non-expansiveness when $i_t \neq j$

When both use the same loss $g(w) = f(w; z_{i_t})$:

$$\|w_{t+1} - w_{t+1}'\|^2 = \|w_t - w_t'\|^2 - \alpha_t\!\left(\frac{2}{\beta} - \alpha_t\right)\|\nabla g(w_t) - \nabla g(w_t')\|^2$$

by co-coercivity of convex $\beta$-smooth functions. Since $\alpha_t \leq 2/\beta$: $\|w_{t+1} - w_{t+1}'\| \leq \|w_t - w_t'\|$.

## Step 2: Bounded perturbation when $i_t = j$

$$\|w_{t+1} - w_{t+1}'\| \leq \|w_t - w_t'\| + \alpha_t(\|\nabla f(w_t;z_j)\| + \|\nabla f(w_t';z_j')\|) \leq \|w_t - w_t'\| + 2\alpha_t L$$

## Step 3: Recurrence

$P(i_t = j) = 1/n$, $P(i_t \neq j) = (n-1)/n$:

$$\delta_{t+1} := \mathbb{E}[\|w_{t+1}-w_{t+1}'\|] \leq \delta_t + \frac{2\alpha_t L}{n}$$

## Step 4: Telescoping

$\delta_0 = 0$, so:

$$\delta_T \leq \frac{2L}{n}\sum_{t=1}^{T}\alpha_t$$

## Step 5: Uniform stability (Part a)

By $L$-Lipschitz: $|f(w_T;z) - f(w_T';z)| \leq L\|w_T - w_T'\|$. Taking expectation:

$$\boxed{\varepsilon_{\mathrm{stab}} \leq \frac{2L^2}{n}\sum_{t=1}^{T}\alpha_t}$$

## Step 6: Generalization bound (Part b)

By the Bousquet-Elisseeff (2002) stability-to-generalization argument: uniform stability $\varepsilon_{\text{stab}}$ implies $|\mathbb{E}[R(w_T)] - \mathbb{E}[R_S(w_T)]| \leq \varepsilon_{\text{stab}}$.

*Proof sketch*: $\mathbb{E}[R(A(S))] - \mathbb{E}[R_S(A(S))] = \frac{1}{n}\sum_i \mathbb{E}[f(A(S);z_i') - f(A(S);z_i)]$. Add/subtract $f(A(S^{(i)});z_i')$ and use symmetry ($z_i \leftrightarrow z_i'$) to bound by $\varepsilon_{\text{stab}}$.

With constant $\alpha_t = \alpha$:

$$\boxed{|\mathbb{E}[R(w_T)] - \mathbb{E}[R_S(w_T)]| \leq \frac{2L^2\alpha T}{n}}$$

**Q.E.D.**
