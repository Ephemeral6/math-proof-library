# B1 — SPS-SGD convergence rate

**Verdict**: CONFIRMED-WEAKER (constant tracking)

**Source**: Loizou, Vaswani, Laradji, Lacoste-Julien, *"Stochastic Polyak Step-size for SGD: An Adaptive Learning Rate for Fast Convergence"*, AISTATS 2021 (arXiv:2002.10542).

## OUR statement
For convex $L$-smooth $f_i$ with interpolation ($f_i(x^*)=0$) and SPS$_{\max}$-style step $\gamma_k = f_{i_k}(x_k)/(c\|\nabla f_{i_k}(x_k)\|^2)$ with $c\ge 1$:
$$\mathbb{E}[f(\bar x_T)-f^*] \le \frac{2cL\,\|x_0-x^*\|^2}{T}.$$

## Paper statement (training-data, abstract verified)
Loizou et al. Theorem 3.4 (SPS$_{\max}$ for convex finite-sums under interpolation): with $c \ge 1/2$,
$$\mathbb{E}[f(\bar x_T)-f^*] \le \frac{c L_{\max}\|x_0-x^*\|^2}{(2c-1)\,T}\,.$$
For $c=1$ this gives $L_{\max}\|x_0-x^*\|^2/T$. The paper's standard convention $f(y)\le f(x)+\langle\nabla f(x),y-x\rangle+\frac{L}{2}\|y-x\|^2$ matches ours.

## Comparison
- Same algorithm, same assumptions (convex, smooth, interpolation), same proof template (descent + co-coercivity bound $\|\nabla f_i\|^2\le 2L f_i$).
- Constants: ours is $2cL/T$; paper is $cL/((2c-1)T)$. For $c=1$ ours is $2L/T$, paper is $L/T$ — **paper is 2x tighter**. Our proof's `Remark` already concedes this and explains: paper uses $\gamma_k \ge \min(1/(2cL), \gamma_b)$ with the upper-bound $\gamma_b$ doing extra work; our Step 5 uses only the lower bound.
- No contradictions; technique is the same.

## Verdict
**CONFIRMED-WEAKER**: same theorem, same technique, but constant 2x looser than published. Honest acknowledgement appears in our proof's remark.
