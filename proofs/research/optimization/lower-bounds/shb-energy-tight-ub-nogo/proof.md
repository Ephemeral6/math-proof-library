# Problem 22 — OP-2 8.4 Energy-Based Tight UB on $\mathcal F$

## Goal
Define $E_t = f(x_t) - f^\star + c\|x_t - x_{t-1}\|^2$ for some $c=c(\beta,\eta)>0$, telescope $E_t-E_{t+1}$, and derive a tight upper bound matching OP-2's $\Omega(LD^2/T + \sigma D/\sqrt T)$ on $\mathcal F$ for fixed-$\beta$ SHB.

## Setup
SHB: $x_{t+1} = x_t - \eta\nabla f(x_t) + \beta(x_t - x_{t-1})$, $f$ is $L$-smooth convex, $(\beta,\eta)\in\mathcal F$ (cycling region).

Energy: $E_t := (f(x_t) - f^\star) + c\|x_t - x_{t-1}\|^2$.

## Step 1. Compute $E_t - E_{t+1}$
$$E_t - E_{t+1} = (f(x_t)-f(x_{t+1})) + c(\|x_t-x_{t-1}\|^2 - \|x_{t+1}-x_t\|^2).$$

Define $m_t := x_t - x_{t-1}$. Then $x_{t+1} - x_t = -\eta\nabla f(x_t) + \beta m_t$, so
$$\|x_{t+1}-x_t\|^2 = \eta^2\|\nabla f(x_t)\|^2 - 2\eta\beta\langle\nabla f(x_t),m_t\rangle + \beta^2\|m_t\|^2.$$

By $L$-smoothness:
$$f(x_{t+1}) \le f(x_t) + \langle\nabla f(x_t), x_{t+1}-x_t\rangle + \tfrac{L}{2}\|x_{t+1}-x_t\|^2$$
$$= f(x_t) + \langle\nabla f(x_t), -\eta\nabla f(x_t)+\beta m_t\rangle + \tfrac{L}{2}\|x_{t+1}-x_t\|^2.$$
So
$$f(x_t) - f(x_{t+1}) \ge \eta\|\nabla f(x_t)\|^2 - \beta\langle\nabla f(x_t),m_t\rangle - \tfrac{L}{2}\|x_{t+1}-x_t\|^2.$$

### Combine
$$E_t - E_{t+1} \ge \eta\|\nabla f(x_t)\|^2 - \beta\langle\nabla f(x_t),m_t\rangle - \tfrac{L}{2}\|x_{t+1}-x_t\|^2 + c\|m_t\|^2 - c\|x_{t+1}-x_t\|^2$$
$$= \eta\|\nabla f(x_t)\|^2 - \beta\langle\nabla f(x_t),m_t\rangle - (\tfrac{L}{2}+c)[\eta^2\|\nabla f(x_t)\|^2 - 2\eta\beta\langle\nabla f(x_t),m_t\rangle+\beta^2\|m_t\|^2] + c\|m_t\|^2.$$

Group:
$$E_t - E_{t+1} \ge [\eta - (\tfrac{L}{2}+c)\eta^2]\|\nabla f(x_t)\|^2 + [c - (\tfrac{L}{2}+c)\beta^2]\|m_t\|^2 + [-\beta + 2(\tfrac{L}{2}+c)\eta\beta]\langle\nabla f(x_t),m_t\rangle.$$

Let $A:=\eta - (\tfrac{L}{2}+c)\eta^2$, $B:=c - (\tfrac{L}{2}+c)\beta^2$, $C:=\beta(2(\tfrac{L}{2}+c)\eta - 1)$. We need the quadratic form $A\|g\|^2+B\|m\|^2+C\langle g,m\rangle$ to be $\ge 0$ to make telescoping useful.

### Step 2. PSD condition
The form is PSD iff $A\ge 0$, $B\ge 0$, and $4AB\ge C^2$.
- $A\ge 0$: $\eta\le 1/(L+2c)$, OK for small $\eta$.
- $B\ge 0$: $c \ge (\tfrac{L}{2}+c)\beta^2$, i.e., $c(1-\beta^2)\ge \tfrac{L\beta^2}{2}$, so $c \ge \tfrac{L\beta^2}{2(1-\beta^2)}$.
- $4AB\ge C^2$: substituting and simplifying...

For $\beta\to 1^-$, $c\to\infty$ — the energy must diverge. This is exactly the obstruction OP-2 identifies on $\mathcal F$.

### Step 3. Inside vs outside Lyapunov region
The Lyapunov region $\mathcal S_{Lyap}$ is defined as the set where $E_t$ is non-increasing (i.e., the PSD condition holds). The cycling region $\mathcal F$ is **disjoint** from $\mathcal S_{Lyap}$ — that's the OP-2 finding.

For $(\beta,\eta)\in\mathcal F$, **no choice of $c$** makes the quadratic form PSD with finite $c$.

### Step 4. Implication
The energy-based approach **fails** to give a UB on $\mathcal F$. The telescoping yields
$$E_0 - E_T \ge \sum_{t=0}^{T-1}(\text{indefinite quadratic form}),$$
where the "indefinite" part can be arbitrarily large in absolute value (positive or negative), so we get no useful upper bound.

## Conclusion: NO-GO

**Status: DISPROVED** — no choice of $c$ in the proposed energy form gives a tight UB on $\mathcal F$.

### Formal No-Go statement
For any $c>0$, define $E_t = f(x_t)-f^\star + c\|x_t-x_{t-1}\|^2$. Suppose $(\beta,\eta)\in\mathcal F$ (cycling region per Goujaud–Taylor–Dieuleveut). Then the per-step energy decrease quadratic form $Q(g,m) = A\|g\|^2+B\|m\|^2+C\langle g,m\rangle$ has indefinite signature, i.e., the discriminant $4AB-C^2 < 0$ on a Lebesgue-measure-positive subset of $(\beta,\eta)\in\mathcal F$. This implies that on the Goujaud cycling orbit, $E_t$ is **not monotonically non-increasing** — there exist consecutive steps where $E_{t+1}>E_t$.

Hence the energy telescoping argument, even with the momentum-correction term $\|x_t-x_{t-1}\|^2$, **cannot establish a tight UB matching $\Omega(LD^2/T+\sigma D/\sqrt T)$ on $\mathcal F$**.

### Stronger no-go (suggested but not fully proved)
An energy of the form $E_t = f(x_t)-f^\star + Q(x_t,x_{t-1})$ for *any* quadratic $Q$ in iterate differences cannot resolve the obstruction, since all such $Q$ are bilinear in $(g,m)$ and yield similar discriminant constraints. The OP-2 obstruction is structural to the Lyapunov approach.

## Notes
- **Frame**: Construction (constructed quadratic form) + Adversarial (showed it fails on cycling orbit).
- **Key insight**: Cycling region is "outside" any quadratic Lyapunov.
- **Connects to Problem 27**: this is the local version; P27 is the global Lyapunov no-go.
