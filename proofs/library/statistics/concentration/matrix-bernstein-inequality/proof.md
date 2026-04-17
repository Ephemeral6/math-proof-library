# Matrix Bernstein Inequality

**Theorem.** Let $X_1, \ldots, X_n$ be independent random symmetric matrices in $\mathbb{R}^{d \times d}$ with $\mathbb{E}[X_i] = 0$ and $\|X_i\| \leq L$ a.s. Let $\sigma^2 = \|\sum_{i=1}^n \mathbb{E}[X_i^2]\|$. Then $\Pr[\|\sum_{i=1}^n X_i\| \geq t] \leq 2d \cdot \exp(-t^2/2 / (\sigma^2 + Lt/3))$.

---

**Lemma A.** *If $\mathbb{E}[Y] = 0$ and $|Y| \leq L$ a.s., then $\mathbb{E}[e^{\theta Y}] \leq \exp(\theta^2 \mathbb{E}[Y^2]/(2(1-\theta L/3)))$ for $0 < \theta < 3/L$.*

*Proof.* First, $k! \geq 2 \cdot 3^{k-2}$ for $k \geq 2$ (induction: base $2! = 2$; step uses $k+1 \geq 3$). By Taylor's theorem with integral remainder, $e^{\theta y} = 1 + \theta y + \theta^2 y^2 \int_0^1 (1-s)e^{s\theta y}\,ds$. For $|y| \leq L$: $e^{s\theta y} \leq e^{s\theta L}$, so $e^{\theta y} \leq 1 + \theta y + y^2(e^{\theta L} - 1 - \theta L)/L^2$. The power series $(e^u-1-u)/u^2 = \sum_{k \geq 2} u^{k-2}/k! \leq \frac{1}{2}\sum_{k \geq 2}(u/3)^{k-2} = 1/(2(1-u/3))$ by the factorial bound, giving $e^{\theta y} \leq 1 + \theta y + \theta^2 y^2/(2(1-\theta L/3))$. Taking expectations ($\mathbb{E}[Y]=0$) and applying $1+x \leq e^x$: $\mathbb{E}[e^{\theta Y}] \leq \exp(\theta^2\mathbb{E}[Y^2]/(2(1-\theta L/3)))$. $\blacksquare$

**Lemma B.** *If $\mathbb{E}[X] = 0$ and $\|X\| \leq L$ a.s., then $\mathbb{E}[e^{\theta X}] \preceq \exp(\theta^2 \mathbb{E}[X^2]/(2(1-\theta L/3)))$.*

*Proof.* The scalar bound from Lemma A lifts to matrices via spectral functional calculus (eigenvalue-by-eigenvalue): $e^{\theta X} \preceq I + \theta X + \theta^2 X^2/(2(1-\theta L/3))$. Taking expectations: $\mathbb{E}[e^{\theta X}] \preceq I + M$ where $M = \theta^2\mathbb{E}[X^2]/(2(1-\theta L/3)) \succeq 0$. Since $1+x \leq e^x$ for $x \geq 0$ lifts to $I + M \preceq e^M$, we conclude $\mathbb{E}[e^{\theta X}] \preceq e^M$. $\blacksquare$

**Lemma C (Transfer Rule).** *For fixed Hermitian $H$ and random Hermitian $Y$ independent of $H$: $\mathbb{E}[\operatorname{tr}\exp(H+Y)] \leq \operatorname{tr}\exp(H + \log\mathbb{E}[e^Y])$.*

*Proof.* By Lieb's concavity theorem (Lieb 1973; see Bhatia, *Matrix Analysis*, Ch. IX), $f(A) = \operatorname{tr}\exp(H + \log A)$ is concave on the PD cone. Setting $A = e^Y \succ 0$ and applying Jensen: $\mathbb{E}[f(e^Y)] \leq f(\mathbb{E}[e^Y]) = \operatorname{tr}\exp(H + \log\mathbb{E}[e^Y])$. $\blacksquare$

**Lemma D (Master Trace Bound).** *$\mathbb{E}[\operatorname{tr} e^{\theta S}] \leq d \cdot \exp(\theta^2\sigma^2/(2(1-\theta L/3)))$.*

*Proof.* Peel off $X_n$: by Lemma C with $H = \theta\sum_{i<n} X_i$ and $Y = \theta X_n$, then Lemma B and operator monotonicity of $\log$ (Loewner 1934; Bhatia, *Matrix Analysis*, Thm V.2.5) give $\log\mathbb{E}[e^{\theta X_n}] \preceq \theta^2\mathbb{E}[X_n^2]/(2(1-\theta L/3))$. Trace-exp monotonicity ($A \preceq B \Rightarrow \operatorname{tr} e^{H+A} \leq \operatorname{tr} e^{H+B}$, proved via $g(t) = \operatorname{tr}\exp(H+A+t(B-A))$, $g'(t) = \operatorname{tr}[(B-A)e^{H+A+t(B-A)}] \geq 0$) replaces $\log\mathbb{E}[e^{\theta X_n}]$ by the deterministic bound. Iterating over $X_{n-1}, \ldots, X_1$ yields $\mathbb{E}[\operatorname{tr} e^{\theta S}] \leq \operatorname{tr}\exp(\theta^2 V/(2(1-\theta L/3)))$ where $V = \sum_i \mathbb{E}[X_i^2]$. Finally, $\operatorname{tr}\exp(\alpha V) = \sum_j e^{\alpha\mu_j} \leq d \cdot e^{\alpha\|V\|} = d \cdot e^{\alpha\sigma^2}$. $\blacksquare$

**Lemma E (Chernoff Optimization).** *Setting $\theta^* = t/(\sigma^2 + Lt/3)$ gives $\phi(\theta^*) = -t^2/(2(\sigma^2+Lt/3))$.*

*Proof.* Feasibility: $\theta^* = 3t/(3\sigma^2+Lt) < 3/L$. Direct computation: $1 - \theta^*L/3 = 3\sigma^2/(3\sigma^2+Lt)$, $(\theta^*)^2\sigma^2/(2(1-\theta^*L/3)) = t^2/(2(\sigma^2+Lt/3))$, $\theta^* t = t^2/(\sigma^2+Lt/3)$, so $\phi(\theta^*) = -t^2/(2(\sigma^2+Lt/3))$. $\blacksquare$

**Proof of Theorem.** Since $\|S\| = \max(\lambda_{\max}(S), \lambda_{\max}(-S))$, union bound gives $\Pr[\|S\| \geq t] \leq \Pr[\lambda_{\max}(S) \geq t] + \Pr[\lambda_{\max}(-S) \geq t]$. For each tail, Markov's inequality and $e^{\theta\lambda_{\max}(S)} = \lambda_{\max}(e^{\theta S}) \leq \operatorname{tr} e^{\theta S}$ give $\Pr[\lambda_{\max}(S) \geq t] \leq e^{-\theta t}\mathbb{E}[\operatorname{tr} e^{\theta S}]$. Lemma D bounds $\mathbb{E}[\operatorname{tr} e^{\theta S}] \leq d \cdot e^{\phi(\theta)+\theta t}$. Lemma E with $\theta = \theta^*$ gives $\Pr[\lambda_{\max}(S) \geq t] \leq d \cdot \exp(-t^2/(2(\sigma^2+Lt/3)))$. Combining both tails: $\Pr[\|S\| \geq t] \leq 2d \cdot \exp(-t^2/2/(\sigma^2+Lt/3))$. $\blacksquare$
