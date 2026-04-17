# Route 3: Orlicz Norm / $\psi_2$ Approach

## Setup

**Definition ($\psi_2$ norm).** The sub-Gaussian norm of a random variable $X$ is:
$$\|X\|_{\psi_2} = \inf\{t > 0 : \mathbb{E}[\exp(X^2/t^2)] \leq 2\}.$$

A random variable $X$ is sub-Gaussian iff $\|X\|_{\psi_2} < \infty$.

**Relation to parameter $\sigma$:** If $\mathbb{E}[e^{\lambda X}] \leq e^{\lambda^2 \sigma^2/2}$ for all $\lambda$, then $\|X\|_{\psi_2} \leq C\sigma$ for an absolute constant $C$ (and conversely, up to constants). Specifically, the MGF condition implies the tail bound $P(X > t) \leq e^{-t^2/(2\sigma^2)}$, which implies $\|X\|_{\psi_2} \leq c\sigma$ for some universal $c$.

---

## Part (a): Tail Bound

This is identical to Route 1: union bound + Chernoff gives $P(\max_i X_i > t) \leq n e^{-t^2/(2\sigma^2)}$. $\blacksquare$

---

## Part (b): Expectation Bound via $\psi_2$ Norm

**Step 1: Bound $\|\max_i X_i\|_{\psi_2}$.**

For any random variables $X_1, \ldots, X_n$ (not necessarily independent), the following holds. For any $t > 0$:
$$P(\max_i |X_i| > t) \leq \sum_i P(|X_i| > t) \leq 2n \exp(-t^2 / K^2)$$

where $K = \max_i \|X_i\|_{\psi_2}$. This uses the equivalence between sub-Gaussian norm and tail behavior: $P(|X| > t) \leq 2\exp(-ct^2/\|X\|_{\psi_2}^2)$ for a universal constant $c$.

From this tail bound, one deduces $\|\max_i X_i\|_{\psi_2} \leq CK\sqrt{\log(2n)} \leq C'K\sqrt{\log n}$ for $n \geq 2$ and universal constants $C, C'$.

**Step 2: Extract expectation from $\psi_2$ norm.**

The sub-Gaussian norm controls moments: $\mathbb{E}[|X|] \leq \|X\|_{\psi_2} \cdot C$ for a universal constant. More precisely, $(\mathbb{E}[|X|^p])^{1/p} \leq C\sqrt{p} \|X\|_{\psi_2}$ for all $p \geq 1$.

So: $\mathbb{E}[\max_i X_i] \leq \mathbb{E}[|\max_i X_i|] \leq C \|\max_i X_i\|_{\psi_2} \leq C' \sigma \sqrt{\log n}$.

**Problem:** The constants $C, C'$ are unspecified universal constants. This approach gives $\mathbb{E}[\max_i X_i] \leq C\sigma\sqrt{\log n}$ but NOT the sharp constant $\sqrt{2}$ in $\sigma\sqrt{2\log n}$.

---

## Assessment

Route 3 gives the correct order $O(\sigma\sqrt{\log n})$ but fails to achieve the exact constant $\sqrt{2\log n}$. The Orlicz norm framework trades sharp constants for generality and clean abstractions.

**Route 3 does NOT achieve the exact stated bound.** It proves a weaker version (correct up to universal constants).
