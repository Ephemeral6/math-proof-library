## Proof
**Route**: Route 4 — Direct Problem-Dependent Bound via Two-Phase Counting (clean variant of Agrawal–Goyal).

---

### Notation and setup

Fix a $K$-armed Bernoulli bandit with means $\mu_1,\ldots,\mu_K\in[0,1]$. Let $k^*\in\arg\max_k\mu_k$, $\mu^*:=\mu_{k^*}$, and $\Delta_k:=\mu^*-\mu_k\ge 0$. For arm $k$ at round $t$ let
$$
N_k(t-1)=\sum_{s<t}\mathbb 1[I_s=k],\qquad S_k(t-1)=\sum_{s<t}r_s\mathbb 1[I_s=k],
$$
and $F_k(t-1)=N_k(t-1)-S_k(t-1)$. Posterior samples are
$$
\theta_k(t)\sim\mathrm{Beta}(S_k(t-1)+1,F_k(t-1)+1),
$$
independent across arms conditionally on the history $\mathcal H_{t-1}$. Define the empirical mean
$$
\hat\mu_k(t):=\begin{cases}S_k(t-1)/N_k(t-1) & \text{if } N_k(t-1)\ge 1,\\ 0 & \text{otherwise.}\end{cases}
$$
Throughout write $L_k:=\left\lceil 8\log T/\Delta_k^2\right\rceil$ for suboptimal arms $k$ (those with $\Delta_k>0$). We assume $T\ge K\ge 2$; constants absorb the case $T$ small into the final $C$.

For the whole proof, "$\log$" is natural log. We only use $T\ge 2$ so $\log T>0$.

---

### Step 1. Beta–Binomial duality

**Lemma 1 (Beta–Binomial duality).** For integers $a\ge 0$, $b\ge 0$ and $y\in[0,1]$,
$$
\Pr\bigl(\mathrm{Beta}(a+1,b+1)\le y\bigr)=\Pr\bigl(\mathrm{Binom}(a+b+1,\,y)\ge a+1\bigr).
$$
Equivalently,
$$
\Pr\bigl(\mathrm{Beta}(a+1,b+1)> y\bigr)=\Pr\bigl(\mathrm{Binom}(a+b+1,\,y)\le a\bigr).
$$

*Proof.* Let $n=a+b+1$ and $U_{(1)}<\cdots<U_{(n)}$ be the order statistics of $n$ i.i.d.\ $\mathrm{Uniform}[0,1]$ variables. It is classical that $U_{(a+1)}\sim\mathrm{Beta}(a+1,n-a)=\mathrm{Beta}(a+1,b+1)$. For any $y$,
$$
\{U_{(a+1)}\le y\}=\{\#\{i:U_i\le y\}\ge a+1\},
$$
and $\#\{i:U_i\le y\}\sim\mathrm{Binom}(n,y)$. This proves the first identity; the second is the complement. $\square$

---

### Step 2. Beta concentration via Hoeffding on binomials

**Lemma 2 (Beta concentration).** Let $a,b$ be nonnegative integers with $n:=a+b\ge 1$, let $\hat p:=a/n$, and $S\sim\mathrm{Beta}(a+1,b+1)$. Then for every $\varepsilon\in(0,1)$:
$$
\Pr(S\ge \hat p+\varepsilon)\le\exp(-2n\varepsilon^2),\qquad \Pr(S\le \hat p-\varepsilon)\le\exp(-2n\varepsilon^2).
$$
Consequently $\Pr(|S-\hat p|\ge\varepsilon)\le 2\exp(-2n\varepsilon^2)$.

*Proof.* By Lemma 1 with $y=\hat p+\varepsilon$,
$$
\Pr(S> \hat p+\varepsilon)=\Pr(\mathrm{Binom}(n+1,\hat p+\varepsilon)\le a).
$$
Let $X\sim\mathrm{Binom}(n+1,\hat p+\varepsilon)$; then $\mathbb EX=(n+1)(\hat p+\varepsilon)$. We have
$$
a=n\hat p=(n+1)(\hat p+\varepsilon)-(\hat p+\varepsilon)-n\varepsilon\le \mathbb EX-n\varepsilon,
$$
using $\hat p+\varepsilon\ge 0$. Thus $\{X\le a\}\subseteq\{X-\mathbb EX\le -n\varepsilon\}$. By Hoeffding's inequality [REF: proofs/library/statistics/concentration/hoeffding-inequality/proof.md] applied to the $n+1$ Bernoulli$(\hat p+\varepsilon)$ summands,
$$
\Pr(X-\mathbb EX\le -n\varepsilon)\le\exp\!\left(-\frac{2(n\varepsilon)^2}{n+1}\right)\le\exp(-2n\varepsilon^2)\cdot e^{2\varepsilon^2}.
$$
A cleaner bound follows from a slightly tighter form: we actually have $\Pr(X\le a)=\Pr(X\le a)$ and $a=\mathbb EX-(n+1)\varepsilon+\varepsilon-\varepsilon=\mathbb EX-(n+1)\varepsilon+ (\text{nonneg. slack})$; but it is cleanest to apply Hoeffding to the **symmetric rewrite** below.

We instead argue directly. Let $Y_1,\ldots,Y_{n+1}$ i.i.d.\ $\mathrm{Bernoulli}(\hat p+\varepsilon)$, $X=\sum Y_i$. Then
$$
\Pr(X\le a)=\Pr\Bigl(\sum_{i=1}^{n+1}(Y_i-(\hat p+\varepsilon))\le a-(n+1)(\hat p+\varepsilon)\Bigr).
$$
Since $a=n\hat p$,
$$
a-(n+1)(\hat p+\varepsilon)=-\hat p-(n+1)\varepsilon\le -(n+1)\varepsilon.
$$
Hoeffding's inequality for bounded zero-mean $Y_i-(\hat p+\varepsilon)\in[\,-(\hat p+\varepsilon),\,1-(\hat p+\varepsilon)\,]\subseteq[-1,1]$ with range $1$ gives, for any $u>0$,
$$
\Pr\Bigl(\sum_{i=1}^{n+1}(Y_i-(\hat p+\varepsilon))\le -u\Bigr)\le\exp\!\left(-\frac{2u^2}{n+1}\right).
$$
With $u=(n+1)\varepsilon$ we obtain
$$
\Pr(X\le a)\le\exp(-2(n+1)\varepsilon^2)\le\exp(-2n\varepsilon^2).
$$
Therefore
$$
\Pr(S>\hat p+\varepsilon)\le\exp(-2n\varepsilon^2).\tag{$\ast$}
$$
The left-tail bound follows by the symmetric argument: by Lemma 1 with $y=\hat p-\varepsilon$,
$$
\Pr(S<\hat p-\varepsilon)=\Pr(\mathrm{Binom}(n+1,\hat p-\varepsilon)\ge a+1).
$$
Let $X'\sim\mathrm{Binom}(n+1,\hat p-\varepsilon)$; $\mathbb EX'=(n+1)(\hat p-\varepsilon)$, so
$$
a+1-\mathbb EX'=n\hat p+1-(n+1)\hat p+(n+1)\varepsilon=1-\hat p+(n+1)\varepsilon\ge(n+1)\varepsilon.
$$
Hoeffding again yields $\Pr(X'\ge a+1)\le\exp(-2(n+1)\varepsilon^2)\le\exp(-2n\varepsilon^2)$. Since $\{S\le\hat p-\varepsilon\}\subseteq\{S<\hat p-\varepsilon+\delta\}$ for any $\delta>0$, letting $\delta\downarrow 0$ yields $\Pr(S\le\hat p-\varepsilon)\le\exp(-2n\varepsilon^2)$ (the Beta distribution is continuous, so this is automatic). $\square$

**Corollary (Boundary cases).** For $n=0$ ($S\sim\mathrm{Beta}(1,1)=\mathrm{Uniform}[0,1]$, $\hat p$ undefined), we bound events directly: $\Pr(S\ge y)=1-y$ and $\Pr(S\le y)=y$ for $y\in[0,1]$. We will only need Lemma 2 when $n\ge 1$, so this case is handled by the lemma as stated.

---

### Step 3. Empirical-mean concentration

**Lemma 3 (Empirical concentration).** Conditional on $N_k(t-1)=n\ge 1$, the empirical mean $\hat\mu_k(t)$ is the average of $n$ i.i.d.\ $\mathrm{Bernoulli}(\mu_k)$ random variables (the rewards collected during plays of arm $k$). By Hoeffding [REF: proofs/library/statistics/concentration/hoeffding-inequality/proof.md], for every $\varepsilon>0$,
$$
\Pr\bigl(|\hat\mu_k(t)-\mu_k|\ge\varepsilon\,\bigm|\,N_k(t-1)=n\bigr)\le 2\exp(-2n\varepsilon^2).
$$

*Note on conditioning.* The rewards collected when arm $k$ has been played are i.i.d.\ $\mathrm{Bernoulli}(\mu_k)$ regardless of the (possibly adaptive) selection rule, because the reward at time $s$ is drawn independently from past history given $I_s$. Formally, writing $Y_k^{(1)},Y_k^{(2)},\ldots$ for the independent future reward stream of arm $k$, we have $\hat\mu_k(t)=\frac{1}{n}\sum_{j=1}^n Y_k^{(j)}$ on $\{N_k(t-1)=n\}$, and this sum is independent of $\{N_k(t-1)=n\}$.

---

### Step 4. Two-phase decomposition for a suboptimal arm

Fix a suboptimal arm $k$ (so $\Delta_k>0$). Set
$$
L=L_k:=\lceil 8\log T/\Delta_k^2\rceil.
$$
Decompose
$$
N_k(T)=\sum_{t=1}^T\mathbb 1[I_t=k]\le L+\sum_{t=1}^T\mathbb 1\bigl[I_t=k,\,N_k(t-1)\ge L\bigr].\tag{1}
$$
Indeed, let $\tau:=\min\{t:N_k(t-1)\ge L\}$ (with $\tau=T+1$ if never). At most $L$ plays of $k$ occur at times $<\tau$ (the count $N_k$ increases by $1$ per play of $k$, reaching $L$ exactly at time $\tau$), and any play with count $\ge L$ occurs at $t\ge\tau$. So
$$
\mathbb E[N_k(T)]\le L+\sum_{t=1}^T\Pr\bigl(I_t=k,\,N_k(t-1)\ge L\bigr).\tag{2}
$$

We now bound the summand in (2).

---

### Step 5. The bad events and a decisive good event for the optimal arm

For a run $t$, the event $\{I_t=k\}$ forces $\theta_k(t)\ge\theta_{k^*}(t)$. Define the thresholds
$$
x_k:=\mu_k+\Delta_k/2=\mu^*-\Delta_k/2,\qquad y_k:=\mu_k+\Delta_k/4.
$$
Note $x_k<\mu^*$ and $y_k<x_k<\mu^*$.

Define three bad events at round $t$ (for the suboptimal arm $k$ under analysis):
- $A_t:=\{|\hat\mu_k(t)-\mu_k|\ge\Delta_k/4\}$ — empirical mean of $k$ far from $\mu_k$;
- $B_t:=\{|\theta_k(t)-\hat\mu_k(t)|\ge\Delta_k/4\}$ — posterior sample of $k$ far from its empirical mean;
- $C_t:=\{\theta_{k^*}(t)\le x_k\}$ — the optimal arm's posterior sample is low.

**Claim.** $\{I_t=k\}\cap\{N_k(t-1)\ge L\}\subseteq A_t\cup B_t\cup C_t$.

*Proof.* On $A_t^c\cap B_t^c\cap \{I_t=k\}\cap\{N_k(t-1)\ge L\}$:
$$
\theta_k(t)\le \hat\mu_k(t)+\tfrac{\Delta_k}{4}\le\mu_k+\tfrac{\Delta_k}{4}+\tfrac{\Delta_k}{4}=\mu_k+\tfrac{\Delta_k}{2}=x_k.
$$
So $\theta_{k^*}(t)\le\theta_k(t)\le x_k$, which is $C_t$. $\square$

Therefore
$$
\Pr(I_t=k,N_k(t-1)\ge L)\le\Pr(A_t,N_k(t-1)\ge L)+\Pr(B_t,N_k(t-1)\ge L)+\Pr(C_t,I_t=k).\tag{3}
$$
(The last term uses $\{I_t=k\}\subseteq\{\theta_{k^*}(t)\le\theta_k(t)\}$, but we keep it as $\Pr(C_t,I_t=k)$ and bound separately.)

We bound each term summed over $t$.

---

### Step 6. Summing the $A_t$ and $B_t$ terms

**(a) Sum of $\Pr(A_t,N_k(t-1)\ge L)$.**

By Lemma 3, conditional on $N_k(t-1)=n$,
$$
\Pr(A_t\mid N_k(t-1)=n)\le 2\exp(-2n\cdot(\Delta_k/4)^2)=2\exp(-n\Delta_k^2/8).
$$
So
$$
\sum_{t=1}^T\Pr(A_t,N_k(t-1)\ge L)\le\sum_{t=1}^T\sum_{n\ge L}\Pr(N_k(t-1)=n)\cdot 2\exp(-n\Delta_k^2/8).
$$
Swap sums and use $\sum_{t=1}^T\Pr(N_k(t-1)=n)\le 1$ (since at most one round $t$ has $N_k(t-1)=n$ for each fixed realization — the count is non-decreasing; in fact $\sum_{t=1}^T\mathbb 1[N_k(t-1)=n]=(\text{number of rounds with count }n)$, and this is a deterministic counter that can take each integer value $n$ only on some set of rounds. Here we need only the cruder bound $\sum_{t=1}^T\mathbb 1[N_k(t-1)=n\text{ and }I_t=k]\le 1$ and $\sum_{t=1}^T\mathbb 1[N_k(t-1)=n\text{ and }I_t\ne k]$ can be up to $T$; so we refine below).

The cleaner route: condition on the $n$-th play of arm $k$. Let $T_n^{(k)}$ be the round at which arm $k$ is played for the $n$-th time (with $T_n^{(k)}=\infty$ if it never is). The empirical mean $\hat\mu_k(t)$ changes *only* when arm $k$ is played, so for all $t\in(T_n^{(k)},T_{n+1}^{(k)}]$ we have $N_k(t-1)=n$ and $\hat\mu_k(t)$ equals a *fixed* function $\bar Y_k^{(n)}:=\frac{1}{n}\sum_{j=1}^n Y_k^{(j)}$ of the first $n$ rewards of arm $k$. Thus the event $A_t\cap\{N_k(t-1)=n\}$ is the same event $\{|\bar Y_k^{(n)}-\mu_k|\ge\Delta_k/4\}$ on the $\sigma$-field generated by the first $n$ plays of $k$, regardless of $t$. By a different bounding:
$$
\sum_{t=1}^T\mathbb 1[A_t, N_k(t-1)=n]\le (\text{number of }t\text{ with }N_k(t-1)=n)\cdot\mathbb 1[|\bar Y_k^{(n)}-\mu_k|\ge\Delta_k/4].
$$
The number of $t\in[1,T]$ with $N_k(t-1)=n$ is at most $T$, so this naive bound gives $T\cdot 2\exp(-n\Delta_k^2/8)$, which is too weak.

**Better bound.** We only care about rounds where $I_t=k$ among those, or we bound per play. Observe that
$$
\Pr\bigl(I_t=k,\,A_t,\,N_k(t-1)\ge L\bigr).
$$
Here is the correct estimate: sum over $n\ge L$ the probability that arm $k$ is played *at some time $t$* with $N_k(t-1)=n$ and $A_t$ holds. Since arm $k$ is played exactly once at each count $n$ (the $(n+1)$-st play brings the count to $n+1$), and $A_t$ holding at the moment of the $(n+1)$-st play is equivalent to $|\bar Y_k^{(n)}-\mu_k|\ge\Delta_k/4$ (a fixed event on first $n$ plays),
$$
\sum_{t=1}^T\mathbb 1[I_t=k,A_t,N_k(t-1)=n]\le\mathbb 1[|\bar Y_k^{(n)}-\mu_k|\ge\Delta_k/4].
$$
Taking expectation and summing over $n\ge L$:
$$
\sum_{t=1}^T\Pr(I_t=k,A_t,N_k(t-1)\ge L)\le\sum_{n\ge L}\Pr(|\bar Y_k^{(n)}-\mu_k|\ge\Delta_k/4)\le\sum_{n\ge L}2e^{-n\Delta_k^2/8}.\tag{4}
$$
Geometric-series bound: with $q:=e^{-\Delta_k^2/8}<1$,
$$
\sum_{n\ge L}q^n=\frac{q^L}{1-q}\le\frac{q^L}{1-q}.
$$
Since $L\ge 8\log T/\Delta_k^2$, $q^L\le e^{-\log T}=1/T$. And $1-q\ge 1-e^{-\Delta_k^2/8}\ge \frac{\Delta_k^2}{8}\cdot\frac{1}{1+\Delta_k^2/8}\ge \frac{\Delta_k^2}{16}$ (using $1-e^{-x}\ge x/(1+x)$ for $x\ge 0$, and $\Delta_k\le 1$ so $\Delta_k^2/8\le 1/8$ hence $1+\Delta_k^2/8\le 9/8\le 2$). Therefore
$$
\sum_{n\ge L}2e^{-n\Delta_k^2/8}\le 2\cdot\frac{1/T}{\Delta_k^2/16}=\frac{32}{T\Delta_k^2}.\tag{4'}
$$
Note: here we only kept the subset $\{I_t=k\}$; but we actually need to bound $\Pr(A_t,N_k(t-1)\ge L)$, which is different. However, we can use the sharper inclusion
$$
\{I_t=k,N_k(t-1)\ge L\}\cap A_t\subseteq\{I_t=k,A_t,N_k(t-1)\ge L\}
$$
and return to the decomposition (3); that is,
$$
\Pr(I_t=k,N_k(t-1)\ge L)\le\Pr(I_t=k,A_t,N_k(t-1)\ge L)+\Pr(I_t=k,A_t^c,B_t,N_k(t-1)\ge L)+\Pr(I_t=k,A_t^c,B_t^c,N_k(t-1)\ge L).
$$
The last piece is contained in $\{I_t=k,\theta_{k^*}(t)\le x_k\}$ by the Claim. So we should re-decompose (3) inserting the indicator $\{I_t=k\}$:
$$
\Pr(I_t=k,N_k(t-1)\ge L)\le \underbrace{\Pr(I_t=k,A_t,N_k(t-1)\ge L)}_{\text{(I)}}+\underbrace{\Pr(I_t=k,B_t,N_k(t-1)\ge L)}_{\text{(II)}}+\underbrace{\Pr(I_t=k,C_t)}_{\text{(III)}}.\tag{3'}
$$
**(I) sum over $t$**: bounded by (4)–(4'), yielding $32/(T\Delta_k^2)$.

**(II) sum over $t$.** Here $B_t=\{|\theta_k(t)-\hat\mu_k(t)|\ge\Delta_k/4\}$. Given the first $n$ plays of arm $k$ (producing $S_k=n\hat\mu_k$ successes and $F_k=n-n\hat\mu_k$ failures), at the next play of $k$ (and only then is $\theta_k(t)$ the sample at count $n$), $\theta_k(t)\sim\mathrm{Beta}(S_k+1,F_k+1)$. By Lemma 2 with $\varepsilon=\Delta_k/4$:
$$
\Pr(B_t\mid\mathcal H_{t-1},N_k(t-1)=n)\le 2\exp(-n\Delta_k^2/8).
$$
Crucially $\theta_k(t)$ is drawn *freshly* at each round conditional on the current posterior. But we want to sum across the (possibly many) $t$'s with $N_k(t-1)=n$. Again, arm $k$ is played only once at each count, so
$$
\mathbb 1[I_t=k,B_t,N_k(t-1)=n]
$$
is nonzero for at most one $t$ (namely the unique $t$ with $I_t=k$ and $N_k(t-1)=n$, if any). On that round, $\theta_k(t)$ is a fresh Beta sample, and by Lemma 2 the conditional probability of $B_t$ given the history is $\le 2e^{-n\Delta_k^2/8}$. Therefore
$$
\sum_{t=1}^T\Pr(I_t=k,B_t,N_k(t-1)=n)\le 2e^{-n\Delta_k^2/8},
$$
and summing over $n\ge L$ as in (4'):
$$
\sum_{t=1}^T\Pr(\text{(II)})\le\sum_{n\ge L}2e^{-n\Delta_k^2/8}\le\frac{32}{T\Delta_k^2}.\tag{5}
$$

**(III) sum over $t$** is handled in Step 7 below and is the crux.

Note on handling the boundary $n=0$ for $B_t$ in (II): when $n=0$, arm $k$ has never been played, so $N_k(t-1)=0<L$ (since $L\ge 1$). So $N_k(t-1)\ge L\ge 1$ guarantees $n\ge 1$ and Lemma 2 applies.

---

### Step 7. Handling the optimal arm (event $C_t$)

We bound $\sum_{t=1}^T\Pr(I_t=k,C_t)$ where $C_t=\{\theta_{k^*}(t)\le x_k\}$ and $x_k=\mu^*-\Delta_k/2$.

**Subtle point.** The key difficulty is that the optimal arm's count $N_{k^*}(t-1)$ can be small for many rounds (when TS hasn't yet played $k^*$ enough). Small count means large Beta variance, so $\theta_{k^*}(t)$ can be below $x_k$ with non-negligible probability. This is where the standard Agrawal–Goyal argument reverses the conditioning: bound the expected number of rounds where $C_t$ and $I_t=k$ jointly occur, by relating it to a *geometric-like* quantity associated with the optimal arm.

We use a cleaner bound via empirical concentration + Beta concentration for the optimal arm.

**Setup.** Let $j\ge 0$. On the event $\{N_{k^*}(t-1)=j\}$:
- If $j=0$: $\theta_{k^*}(t)\sim\mathrm{Uniform}[0,1]$, and $\Pr(\theta_{k^*}(t)\le x_k)=x_k\le 1$.
- If $j\ge 1$: $\theta_{k^*}(t)\sim\mathrm{Beta}(S_{k^*}+1,F_{k^*}+1)$ with $\hat\mu_{k^*}:=S_{k^*}/j$. Decompose
$$
\{\theta_{k^*}(t)\le x_k\}\subseteq\underbrace{\{\hat\mu_{k^*}\le\mu^*-\Delta_k/4\}}_{=:A^*_{j}}\cup\underbrace{\{\theta_{k^*}(t)\le\hat\mu_{k^*}-\Delta_k/4\}}_{=:B^*_{t,j}}
$$
(because if neither holds then $\theta_{k^*}(t)>\hat\mu_{k^*}-\Delta_k/4>\mu^*-\Delta_k/2=x_k$).

By Hoeffding (Lemma 3 applied to $k^*$), $\Pr(A^*_j\mid N_{k^*}(t-1)=j)\le e^{-2j(\Delta_k/4)^2}=e^{-j\Delta_k^2/8}$. By Lemma 2, $\Pr(B^*_{t,j}\mid \mathcal H_{t-1},N_{k^*}(t-1)=j)\le e^{-j\Delta_k^2/8}$.

**Bounding the sum (III).** We split by the value of $j=N_{k^*}(t-1)$. Key identity:
$$
\sum_{t=1}^T\mathbb 1[I_t=k,C_t]=\sum_{j=0}^{T-1}\sum_{t=1}^T\mathbb 1[I_t=k,C_t,N_{k^*}(t-1)=j].
$$
For fixed $j$, let $\mathcal T_j:=\{t:N_{k^*}(t-1)=j\}$. This is the (random) interval of consecutive rounds between the $j$-th and $(j+1)$-st play of arm $k^*$ (possibly empty or the terminal segment if $j$-th play never happens or is the last). Call this interval the "$j$-block of $k^*$".

On the $j$-block, $\theta_{k^*}(t)$ is freshly sampled at each round from the *same* Beta distribution $\mathrm{Beta}(S_{k^*}^{(j)}+1,F_{k^*}^{(j)}+1)$ (depending only on the first $j$ plays of $k^*$), and these samples are conditionally i.i.d. given $\mathcal G_j:=\sigma(\text{first }j\text{ plays of }k^*)$. Likewise $\theta_k(t)$ varies across the block (as arm $k$ may be played and its posterior updated). Importantly, within the $j$-block, arm $k^*$ is *not* played (by definition). So $I_t\ne k^*$ for $t\in\mathcal T_j$.

**Lemma 4 (Block-length bound for optimal arm).** For each $j\ge 0$,
$$
\mathbb E\Bigl[\sum_{t\in\mathcal T_j}\mathbb 1[I_t=k,C_t]\Bigr]\le\mathbb E\!\left[\frac{1-p_j^*}{p_j^*}\mathbb 1[\text{$j$-block is nonempty}]\right],
$$
where
$$
p_j^*:=\Pr\bigl(\theta_{k^*}(t)>x_k\,\bigm|\,\mathcal G_j\bigr).
$$
(Here $\theta_{k^*}(t)$ for $t$ in the $j$-block has this conditional distribution depending only on $\mathcal G_j$.)

*Proof of Lemma 4.* Condition on $\mathcal G_j$ and on the $j$-block being nonempty. Inside the block, each round has $\theta_{k^*}(t)$ drawn i.i.d.\ from $\mathrm{Beta}(S_{k^*}^{(j)}+1,F_{k^*}^{(j)}+1)$; moreover, $\theta_{k^*}(t)$ is drawn independently of $\theta_k(t)$ and of the decisions of all suboptimal arms, given the past. The block ends exactly when the first round $t$ in the block has $I_t=k^*$, i.e., $\theta_{k^*}(t)$ exceeds $\max_{k'\ne k^*}\theta_{k'}(t)$ (the maximum over suboptimals). In particular, each round inside the block either has $\theta_{k^*}(t)\le x_k$ (event $C_t$), or $\theta_{k^*}(t)>x_k$.

Here is the key inequality. Enumerate rounds in the block as $t_1<t_2<\cdots$. For $m\ge 1$, the event "block has at least $m$ rounds" is contained in "$\theta_{k^*}(t_1),\ldots,\theta_{k^*}(t_{m-1})$ each fail to be the maximum of $\{\theta_{k'}(t_i)\}_{k'}$." A *sufficient* condition for such failure is $\theta_{k^*}(t_i)\le x_k$ (but not necessary — however, we use it as a one-sided bound:
$$
\{\text{block length}\ge m\}\subseteq\{\theta_{k^*}(t_i)\le\text{something less than }\mu^*\text{ for }i<m\}.
$$
We do *not* use this directly. Instead, we bound
$$
\sum_{t\in\mathcal T_j}\mathbb 1[C_t]\le |\mathcal T_j|=:M_j
$$
and seek to bound $\mathbb E[M_j\mid\mathcal G_j]$. But $M_j$ can be arbitrarily large depending on the dynamics of suboptimal arms.

A different approach, which works: a **coupling/geometric** bound using only the $k^*$ samples.

**Lemma 4$'$ (Refined block-length bound).** Let $\Theta_1,\Theta_2,\ldots$ be the sequence of $\theta_{k^*}$-samples drawn inside the $j$-block (conditionally i.i.d.\ $\mathrm{Beta}(S_{k^*}^{(j)}+1,F_{k^*}^{(j)}+1)$ given $\mathcal G_j$). The block *ends* at round $t_i$ only if $\Theta_i>\max_{k'\ne k^*}\theta_{k'}(t_i)$; a sufficient condition for ending is $\Theta_i>x_k$ (provided all suboptimal samples are $\le x_k$ at that round, which is not guaranteed). So we cannot conclude.

*We reverse the argument.* For a suboptimal arm $k$ to be played at $t\in\mathcal T_j$ with $C_t$ holding, we need $\theta_k(t)\ge\theta_{k^*}(t)$ *and* $\theta_{k^*}(t)\le x_k$ (that is $C_t$). Thus
$$
\mathbb 1[I_t=k,C_t]\le\mathbb 1[C_t].
$$
Hence
$$
\sum_{t\in\mathcal T_j}\mathbb 1[I_t=k,C_t]\le\sum_{t\in\mathcal T_j}\mathbb 1[C_t]=\sum_{t\in\mathcal T_j}\mathbb 1[\Theta_{i(t)}\le x_k],
$$
where $i(t)$ indexes the sample inside the block.

Conditional on $\mathcal G_j$, each $\Theta_i$ is an i.i.d.\ $\mathrm{Beta}(\cdot)$ sample; the block ends at the first $i$ with $\Theta_i>\max_{k'\ne k^*}\theta_{k'}(t_i)$. Dropping the requirement on suboptimal samples yields
$$
\mathcal T_j\subseteq\{\text{indices $i$ until the first $i$ with }\Theta_i>x_k\}\cup\{\text{after that, all }\Theta_i\le x_k\text{ rounds too}\}.
$$
This inclusion is false in general — once $\Theta_i>x_k$, the block may still continue because some suboptimal $\theta_{k'}(t_i)>\Theta_i$. So the block can outlast the first "good $\theta_{k^*}$".

We therefore switch to a different, clean decomposition: **Agrawal–Goyal's original trick** is to relate $\Pr(I_t=k,C_t)$ to $\Pr(I_t=k^*,C_t)$ via the probability ratio. Let us carry it out.

**Lemma 4$''$ (Agrawal–Goyal probability-ratio lemma).** For any round $t$ and event $C_t=\{\theta_{k^*}(t)\le x_k\}$,
$$
\Pr(I_t=k,C_t\mid\mathcal H_{t-1})\le\frac{1-p_{t}^*}{p_{t}^*}\,\Pr(I_t=k^*,C_t^c\mid\mathcal H_{t-1}),
$$
where $p_t^*:=\Pr(\theta_{k^*}(t)>x_k\mid\mathcal H_{t-1})$ depends only on $N_{k^*}(t-1),S_{k^*}(t-1)$.

*Proof of Lemma 4$''$.* Conditional on $\mathcal H_{t-1}$, $\theta_{k^*}(t)$ is independent of $(\theta_{k'}(t))_{k'\ne k^*}$. Let $E_t:=\{I_t=k\text{ if }k^*\text{'s sample were replaced by any value }>x_k\}$… Formally, define
$$
W_t:=\max_{k'\ne k^*}\theta_{k'}(t),\qquad\text{so }\{I_t=k\}=\{\theta_k(t)=W_t\ge\theta_{k^*}(t)\}.
$$
Then
$$
\{I_t=k,C_t\}=\{\theta_k(t)=W_t\}\cap\{\theta_{k^*}(t)\le x_k\}\cap\{\theta_{k^*}(t)\le W_t\}.
$$
And
$$
\{I_t=k^*,C_t^c\}=\{\theta_{k^*}(t)>W_t\}\cap\{\theta_{k^*}(t)>x_k\}=\{\theta_{k^*}(t)>\max(W_t,x_k)\}.
$$
Given $\mathcal H_{t-1}$, write $\mathbb E_{\rm sub}$ for expectation over the suboptimal samples (including $\theta_k$), independent of $\theta_{k^*}$. For any realization of $W_t$:
- $\Pr(\theta_k(t)=W_t,\theta_{k^*}(t)\le\min(W_t,x_k)\mid\mathcal H_{t-1},W_t)=\mathbb 1[\theta_k(t)=W_t]\cdot\Pr(\theta_{k^*}\le\min(W_t,x_k)\mid\mathcal H_{t-1})$. Integrating over the suboptimal samples:
$$
\Pr(I_t=k,C_t\mid\mathcal H_{t-1})=\mathbb E_{\rm sub}\bigl[\mathbb 1[\theta_k(t)=W_t]\,F^*(\min(W_t,x_k))\bigr],
$$
where $F^*(x):=\Pr(\theta_{k^*}(t)\le x\mid\mathcal H_{t-1})$ is the Beta cdf of the optimal arm's posterior.
- $\Pr(I_t=k^*,C_t^c\mid\mathcal H_{t-1})=\mathbb E_{\rm sub}\bigl[1-F^*(\max(W_t,x_k))\bigr]=\mathbb E_{\rm sub}\bigl[\Pr(\theta_{k^*}>\max(W_t,x_k))\bigr]$.

Now for any $w\in[0,1]$:
$$
\frac{F^*(\min(w,x_k))}{1-F^*(\max(w,x_k))}\le\frac{F^*(x_k)}{1-F^*(x_k)}=\frac{1-p_t^*}{p_t^*}.
$$
Indeed, if $w\le x_k$: numerator $=F^*(w)\le F^*(x_k)$, denominator $=1-F^*(x_k)$. If $w> x_k$: numerator $=F^*(x_k)$, denominator $=1-F^*(w)\ge 1-F^*(x_k)\cdot\bigl(\text{may be smaller}\bigr)$; wait, $1-F^*(w)\le 1-F^*(x_k)$ since $F^*$ is nondecreasing, so the denominator is smaller, making the ratio *larger*, not smaller. We need to be careful.

**Revision.** The inequality $\frac{F^*(\min(w,x_k))}{1-F^*(\max(w,x_k))}\le\frac{F^*(x_k)}{1-F^*(x_k)}$ fails in general. We use a different bound: split on whether $\theta_k(t)=W_t\le x_k$ or $>x_k$. On $\{W_t>x_k\}$, the event $\{I_t=k,C_t\}$ requires $\theta_{k^*}(t)\le x_k<W_t$, so it certainly requires $\theta_{k^*}(t)\le x_k$, probability $F^*(x_k)=1-p_t^*$. Similarly on $\{W_t\le x_k\}$, it requires $\theta_{k^*}(t)\le W_t\le x_k$, probability $F^*(W_t)\le F^*(x_k)=1-p_t^*$. Thus in both cases,
$$
\Pr(I_t=k,C_t,\theta_k(t)=W_t\mid\mathcal H_{t-1},W_t,\theta_k(t))\le(1-p_t^*)\,\mathbb 1[\theta_k(t)=W_t].
$$
Wait, this is just the Markov-type bound $F^*(\cdot)\le 1-p_t^*$; it gives $\Pr(I_t=k,C_t\mid\mathcal H_{t-1})\le(1-p_t^*)\Pr(I_t=k\text{ if we ignored }k^*)$, not the $(1-p_t^*)/p_t^*$ bound we want.

Let us finish the ratio inequality correctly. On the event $\{W_t>x_k\}$:
$$
\Pr(\theta_{k^*}\le x_k\mid\mathcal H_{t-1})=1-p_t^*,\qquad \Pr(\theta_{k^*}>W_t\mid\mathcal H_{t-1})\le p_t^*,
$$
and $\{I_t=k^*,C_t^c\}\supseteq\{\theta_{k^*}>W_t,W_t>x_k,\theta_k(t)=W_t\}$... The correct statement is:

**Lemma 4$'''$ (Correct ratio bound).** For any $\mathcal H_{t-1}$,
$$
\Pr(I_t=k,C_t\mid\mathcal H_{t-1})\le\frac{1-p_t^*}{p_t^*}\cdot \Pr(I_t=k^*,\,\theta_{k^*}(t)>x_k\mid\mathcal H_{t-1}).
$$

*Proof.* Condition also on all suboptimal samples $(\theta_{k'}(t))_{k'\ne k^*}$, which determines $W_t$ and whether $\theta_k(t)=W_t$. Let $G:=\{\theta_k(t)=W_t\}$ (event determined by suboptimal samples).

On $G$:
- If $W_t\le x_k$: $\Pr(\theta_{k^*}\le W_t\mid\mathcal H_{t-1})=F^*(W_t)$, and $\Pr(\theta_{k^*}>W_t,\theta_{k^*}>x_k\mid\mathcal H_{t-1})=\Pr(\theta_{k^*}>x_k\mid\mathcal H_{t-1})=p_t^*$ (since $x_k\ge W_t$). Ratio: $F^*(W_t)/p_t^*\le F^*(x_k)/p_t^*=(1-p_t^*)/p_t^*$.
- If $W_t>x_k$: $\{I_t=k,C_t\}=G\cap\{\theta_{k^*}\le x_k\}$ has conditional probability $\mathbb 1_G\cdot(1-p_t^*)$. $\{I_t=k^*,\theta_{k^*}>x_k\}=\{\theta_{k^*}>W_t\}$ (since on $G$, $W_t>x_k$ so $\theta_{k^*}>W_t$ implies $>x_k$), probability $=1-F^*(W_t)$. So we want
$$
\mathbb 1_G(1-p_t^*)\le\frac{1-p_t^*}{p_t^*}\mathbb 1_G(1-F^*(W_t)),
$$
i.e., $p_t^*\le 1-F^*(W_t)$. But $1-F^*(W_t)\le 1-F^*(x_k)=p_t^*$ (since $W_t>x_k$), so this inequality *fails* in general — $p_t^*\le 1-F^*(W_t)$ is equivalent to $F^*(W_t)\le 1-p_t^*=F^*(x_k)$, which fails for $W_t>x_k$.

So Lemma 4$'''$ as stated also fails. The correct Agrawal–Goyal statement is:

**Lemma 4$^*$ (Correct Agrawal–Goyal, with the "good event" for $W_t$).** Let $C_t=\{\theta_{k^*}(t)\le x_k\}$. Define the event
$$
D_t:=\{I_t=k\}\cap C_t.
$$
Then, with $p_t^*$ as above,
$$
\Pr(D_t\mid\mathcal H_{t-1})\le\frac{1-p_t^*}{p_t^*}\,\Pr\bigl(I_t=k^*\mid\mathcal H_{t-1}\bigr).
$$

*Proof.* We compare two conditional probabilities given $\mathcal H_{t-1}$ and the *suboptimal* samples $(\theta_{k'}(t))_{k'\ne k^*}$. Recall $W_t=\max_{k'\ne k^*}\theta_{k'}(t)$, determined by these samples.

$\Pr(I_t=k,C_t\mid\mathcal H_{t-1},\text{subopt samples})=\mathbb 1[\theta_k(t)=W_t]\cdot F^*(\min(W_t,x_k))$

because $\{I_t=k,C_t\}$ requires $\theta_{k^*}\le\min(W_t,x_k)$ and $\theta_k=W_t$.

$\Pr(I_t=k^*\mid\mathcal H_{t-1},\text{subopt samples})=\Pr(\theta_{k^*}>W_t\mid\mathcal H_{t-1})=1-F^*(W_t)$.

We want to show
$$
F^*(\min(W_t,x_k))\le\frac{1-p_t^*}{p_t^*}(1-F^*(W_t)).\tag{$\star$}
$$
- If $W_t\le x_k$: LHS $=F^*(W_t)$, RHS $=\frac{F^*(x_k)}{1-F^*(x_k)}(1-F^*(W_t))$. We want $F^*(W_t)(1-F^*(x_k))\le F^*(x_k)(1-F^*(W_t))$, i.e., $F^*(W_t)\le F^*(x_k)$, true since $W_t\le x_k$ and $F^*$ is nondecreasing.
- If $W_t>x_k$: LHS $=F^*(x_k)$, RHS $=\frac{F^*(x_k)}{1-F^*(x_k)}(1-F^*(W_t))$. We want $1-F^*(x_k)\le 1-F^*(W_t)$, i.e., $F^*(W_t)\le F^*(x_k)$, which *fails* since $W_t>x_k$.

So Lemma 4$^*$ also has a failing branch. We must restrict the inequality to the $W_t\le x_k$ branch and separately handle $W_t>x_k$. On $\{W_t>x_k\}$:
$$
\{I_t=k,C_t\}\subseteq\{\theta_{k^*}\le x_k\},
$$
so $\Pr(I_t=k,C_t\mid\text{subopt})\le \mathbb 1[\theta_k=W_t>x_k]\cdot F^*(x_k)=\mathbb 1[\theta_k=W_t>x_k]\cdot(1-p_t^*)$.

And on $\{W_t>x_k\}$, the event $\{I_t=k^*,\theta_{k^*}>x_k\}=\{\theta_{k^*}>W_t\}$ has probability $1-F^*(W_t)\le 1-F^*(x_k)=p_t^*$. In general no useful ratio.

**The Agrawal–Goyal key observation.** They bound it by combining both branches differently:
$$
\Pr(I_t=k,C_t\mid\mathcal H_{t-1})\le\frac{1-p_t^*}{p_t^*}\Pr(I_t=k^*,C_t^c\mid\mathcal H_{t-1}).
$$
$C_t^c=\{\theta_{k^*}>x_k\}$. On $\{W_t\le x_k\}$: $\{I_t=k^*,C_t^c\}=\{\theta_{k^*}>x_k\}$ (since $\theta_{k^*}>x_k\ge W_t$ implies $I_t=k^*$). Probability $=p_t^*$. So the conditional expectation of RHS is $\frac{1-p_t^*}{p_t^*}\cdot p_t^*\cdot\mathbb 1[W_t\le x_k]=(1-p_t^*)\mathbb 1[W_t\le x_k]$, while LHS$=\mathbb 1[\theta_k=W_t\le x_k]F^*(W_t)\le\mathbb 1[\theta_k=W_t\le x_k](1-p_t^*)\le(1-p_t^*)\mathbb 1[W_t\le x_k]$. OK so this branch holds with constant 1, not $(1-p_t^*)/p_t^*$, but the claimed RHS is even larger, so the inequality holds.

On $\{W_t>x_k\}$: $\{I_t=k^*,C_t^c\}=\{\theta_{k^*}>W_t\}$, probability $=1-F^*(W_t)$. RHS$=\frac{1-p_t^*}{p_t^*}(1-F^*(W_t))$. LHS$=\mathbb 1[\theta_k=W_t]F^*(x_k)=\mathbb 1[\theta_k=W_t](1-p_t^*)$. We need
$$
\mathbb 1[\theta_k=W_t](1-p_t^*)\le\frac{1-p_t^*}{p_t^*}(1-F^*(W_t))\cdot\mathbb 1[W_t>x_k].
$$
Cancel $(1-p_t^*)$ (assume $p_t^*<1$; otherwise LHS$=0$): $\mathbb 1[\theta_k=W_t]\le\frac{1-F^*(W_t)}{p_t^*}\mathbb 1[W_t>x_k]$. But $1-F^*(W_t)\le 1-F^*(x_k)=p_t^*$, so RHS$\le\mathbb 1[W_t>x_k]$. We need $\mathbb 1[\theta_k=W_t]\le\mathbb 1[W_t>x_k]$, i.e., on the relevant branch ($W_t>x_k$), we want $\mathbb 1[\theta_k=W_t]\le 1$, trivially true.

Wait, I need $\mathbb 1[\theta_k=W_t]\le\frac{1-F^*(W_t)}{p_t^*}\mathbb 1[W_t>x_k]$. If $\theta_k=W_t$, then we need $1\le\frac{1-F^*(W_t)}{p_t^*}$, i.e., $p_t^*\le 1-F^*(W_t)$, i.e., $F^*(W_t)\le 1-p_t^*=F^*(x_k)$, which fails when $W_t>x_k$. *So Lemma 4$^*$ with RHS $\Pr(I_t=k^*,C_t^c)$ also fails.*

Let me look up the right formulation. The correct Agrawal–Goyal formulation (2013, Lemma 2.9, restated cleanly):

**Lemma 4 (final correct form).** Let $\mathcal F_{t-1}^{(-k^*)}$ denote the $\sigma$-field of all history *plus* the samples of all suboptimal arms at time $t$ (everything *except* $\theta_{k^*}(t)$). Let
$$
p_t^*=\Pr(\theta_{k^*}(t)>x_k\mid\mathcal H_{t-1}),
$$
(depending only on $S_{k^*}(t-1),F_{k^*}(t-1)$, hence $\mathcal F_{t-1}^{(-k^*)}$-measurable). Then
$$
\Pr(I_t=k,\theta_{k^*}(t)\le x_k\mid\mathcal F_{t-1}^{(-k^*)})\le\frac{1-p_t^*}{p_t^*}\Pr(I_t=k^*,\theta_{k^*}(t)>x_k\mid\mathcal F_{t-1}^{(-k^*)}).
$$

*Proof.* Given $\mathcal F_{t-1}^{(-k^*)}$, everything except $\theta_{k^*}(t)$ is determined; in particular $W_t=\max_{k'\ne k^*}\theta_{k'}(t)$ and the identity of $\arg\max_{k'\ne k^*}\theta_{k'}(t)$ are fixed. Let $M_t:=\arg\max_{k'\ne k^*}\theta_{k'}(t)$; $\{I_t=M_t\}\cup\{I_t=k^*\}=\Omega$ (the arm played is either $k^*$ or the suboptimal leader).

Then $\{I_t=k\}=\{M_t=k,\theta_{k^*}(t)\le W_t\}=\mathbb 1[M_t=k]\cdot\mathbb 1[\theta_{k^*}(t)\le W_t]$. So:
- $\Pr(I_t=k,\theta_{k^*}(t)\le x_k\mid\mathcal F_{t-1}^{(-k^*)})=\mathbb 1[M_t=k]\cdot F^*(\min(W_t,x_k))$.
- $\Pr(I_t=k^*,\theta_{k^*}(t)>x_k\mid\mathcal F_{t-1}^{(-k^*)})=\Pr(\theta_{k^*}(t)>\max(W_t,x_k)\mid\mathcal F_{t-1}^{(-k^*)})=1-F^*(\max(W_t,x_k))$.

We want
$$
\mathbb 1[M_t=k]F^*(\min(W_t,x_k))\le\frac{1-p_t^*}{p_t^*}(1-F^*(\max(W_t,x_k))).\tag{$\dagger$}
$$

Case 1: $W_t\le x_k$. LHS $\le\mathbb 1[M_t=k]F^*(W_t)$. RHS $=\frac{F^*(x_k)}{1-F^*(x_k)}(1-F^*(x_k))=F^*(x_k)\ge F^*(W_t)\ge$ LHS. ✓

Case 2: $W_t>x_k$. LHS $\le\mathbb 1[M_t=k]F^*(x_k)=\mathbb 1[M_t=k](1-p_t^*)$. RHS $=\frac{1-p_t^*}{p_t^*}(1-F^*(W_t))$. Since $W_t>x_k$, $1-F^*(W_t)\le 1-F^*(x_k)=p_t^*$; this gives RHS $\le\frac{(1-p_t^*)p_t^*}{p_t^*}=1-p_t^*$, matching LHS upper bound only in the extreme $W_t=x_k$ case, *but for $W_t>x_k$, RHS can be strictly less than the LHS upper bound $1-p_t^*$!*

Specifically, if $W_t=1$ (possible when $\theta_k(t)$ is near 1), then $1-F^*(W_t)=\Pr(\theta_{k^*}>1)=0$, RHS$=0$, while LHS$=\mathbb 1[M_t=k]F^*(x_k)=\mathbb 1[M_t=k](1-p_t^*)$ may be positive. So $(\dagger)$ fails.

**Conclusion.** The Lemma 4 as naively stated does not hold pointwise on $\mathcal F_{t-1}^{(-k^*)}$. Agrawal–Goyal actually use the bound *in expectation* together with a careful decomposition of which arm plays the role of $M_t$. The proof is significantly more intricate than what the Route-4 outline suggested.

---

### Step 8. Handling event $C_t$ via a direct block-counting argument

Given the failure of the ratio approach pointwise, we give a direct argument that works. The idea: over the *entire horizon*, the total count $\sum_t\mathbb 1[I_t=k,C_t]$ can be bounded by looking at the optimal arm's block structure and showing that for large-enough $j$, the event $C_t$ has small probability.

Split $j=N_{k^*}(t-1)$ into $j<J$ and $j\ge J$ where $J:=\lceil 8\log T/\Delta_k^2\rceil$:

**(a) $j\ge J$.** On $\{N_{k^*}(t-1)=j\ge J\}$, we showed $\Pr(C_t\mid\mathcal F_{t-1}^{(-k^*)})\le e^{-j\Delta_k^2/8}+e^{-j\Delta_k^2/8}=2e^{-j\Delta_k^2/8}$ (unioning $A^*_j$ and $B^*_{t,j}$). So
$$
\sum_{t:N_{k^*}(t-1)\ge J}\Pr(I_t=k,C_t)\le\sum_{t=1}^T\Pr(C_t,N_{k^*}(t-1)\ge J)\le T\cdot\max_{j\ge J}(\text{bound})\cdot(\text{not helpful}).
$$
More carefully, sum over $j\ge J$ of (number of rounds with $N_{k^*}(t-1)=j$ and $C_t$ holds). In the $j$-block of $k^*$, the number of rounds is $\le T$ but each has $\theta_{k^*}(t)$ drawn i.i.d.\ from the same Beta given $\mathcal G_j$. Thus
$$
\mathbb E\Bigl[\sum_{t\in\mathcal T_j}\mathbb 1[C_t]\mid\mathcal G_j\Bigr]=|\mathcal T_j|\cdot\Pr(\theta_{k^*}(t)\le x_k\mid\mathcal G_j)\le T\cdot q_j,
$$
where $q_j:=\Pr(\theta_{k^*}(t)\le x_k\mid\mathcal G_j)$. Taking $\mathbb E$ and summing:
$$
\sum_{j\ge J}\mathbb E\Bigl[\sum_{t\in\mathcal T_j}\mathbb 1[C_t]\Bigr]\le T\sum_{j\ge J}\mathbb E[q_j].
$$
Now $\mathbb E[q_j]=\Pr(\theta_{k^*}\le x_k\mid N_{k^*}=j)\le\mathbb E[e^{-j\Delta_k^2/8}\cdot 2]=2e^{-j\Delta_k^2/8}$ (by the decomposition $q_j\le\mathbb 1[A_j^*]+\Pr(B_{t,j}^*\mid\mathcal G_j)\le\mathbb 1[A_j^*]+e^{-j\Delta_k^2/8}$, taking $\mathbb E$ yields $\le e^{-j\Delta_k^2/8}+e^{-j\Delta_k^2/8}$).

Therefore
$$
\sum_{j\ge J}\mathbb E\Bigl[\sum_{t\in\mathcal T_j}\mathbb 1[I_t=k,C_t]\Bigr]\le 2T\sum_{j\ge J}e^{-j\Delta_k^2/8}\le 2T\cdot\frac{e^{-J\Delta_k^2/8}}{1-e^{-\Delta_k^2/8}}\le 2T\cdot\frac{1/T}{\Delta_k^2/16}=\frac{32}{\Delta_k^2}.\tag{6}
$$

**(b) $j<J$.** For small $j$, we cannot use Hoeffding (it gives weak bounds). Instead, note that the $j$-block length $|\mathcal T_j|$ is the number of rounds between the $j$-th and $(j+1)$-st play of $k^*$. In each round of the $j$-block, $\theta_{k^*}(t)$ is drawn independently from $\mathrm{Beta}(S_{k^*}^{(j)}+1,F_{k^*}^{(j)}+1)$; the block ends when $\theta_{k^*}(t)>\max_{k'\ne k^*}\theta_{k'}(t)$. For each round in $\mathcal T_j$, $\theta_{k^*}(t)$ was below this max; in particular, **dropping the other samples**, we have: the block length $M_j:=|\mathcal T_j|$ satisfies
$$
M_j\le \text{(number of rounds until }\theta_{k^*}(t)>x_k\text{, viewed as a geometric variable)},
$$
IF all suboptimal samples were guaranteed $\le x_k$. But they are not; however, notice:

Decomposition:
$$
M_j=M_j^{(\text{C})}+M_j^{(\text{not C})},
$$
where $M_j^{(\text{C})}=\sum_{t\in\mathcal T_j}\mathbb 1[C_t]$ and $M_j^{(\text{not C})}=\sum_{t\in\mathcal T_j}\mathbb 1[C_t^c]$.

Observe that $\{\theta_{k^*}(t)>x_k\}$ occurring while still in the block means $W_t\ge\theta_{k^*}(t)>x_k$, so $I_t$ is some suboptimal arm with sample $>x_k$. In particular, $I_t\ne k$ is *not* guaranteed; $I_t$ could be $k$ if $\theta_k(t)>x_k$. But we are trying to bound $\mathbb 1[I_t=k,C_t]$, which forces $C_t$, so we only care about $M_j^{(\text{C})}$.

**Key observation.** Within the $j$-block, the samples $\theta_{k^*}(t)$ are i.i.d. given $\mathcal G_j$. Define the stopping index
$$
\tau_j:=\min\{m\ge 1:\theta_{k^*}(t_m)>x_k\}
$$
(a geometric random variable with parameter $p_j:=\Pr(\theta_{k^*}>x_k\mid\mathcal G_j)=1-q_j$, given $\mathcal G_j$). Then for any $m<\tau_j$, $\theta_{k^*}(t_m)\le x_k$, i.e., $C_{t_m}$ holds. So
$$
M_j^{(\text{C})}\ge\tau_j-1\wedge M_j.
$$
More importantly, $M_j^{(\text{C})}\le M_j$ and $M_j\le$ "number of rounds until (some event happens that ends the block)". If we pessimistically assume all suboptimal samples can be arbitrary, the block can last until $\theta_{k^*}$ exceeds them, which can be arbitrarily long. However, we only count rounds where $C_t$ holds, i.e., $\theta_{k^*}(t)\le x_k$. Each such round is an i.i.d. sample below $x_k$. So
$$
M_j^{(\text{C})}=\#\{m:\theta_{k^*}(t_m)\le x_k\text{, among block samples}\}.
$$
The samples within the block continue being drawn until the block ends. The block ends exactly when for some $m$, $\theta_{k^*}(t_m)>W_{t_m}$. A *sufficient* condition for ending (regardless of $W_{t_m}$) is $\theta_{k^*}(t_m)>1$... which never happens. But: the block surely ends no later than the first $m$ with $\theta_{k^*}(t_m)\ge 1-\eta$ for $\eta$ tiny — not useful.

**Cleanest way (stopped geometric bound).** For each $m\ge 1$, conditional on $\mathcal G_j$ and the history up to $t_m$ (before $\theta_{k^*}(t_m)$ is drawn), we have: the block includes round $t_m$ iff the block did not end before. Independently of this, $\theta_{k^*}(t_m)$ is drawn from $\mathrm{Beta}(S_{k^*}^{(j)}+1,F_{k^*}^{(j)}+1)$. Then
$$
\mathbb 1[t_m\in\mathcal T_j]\cdot\mathbb 1[C_{t_m}]=\mathbb 1[t_m\in\mathcal T_j]\cdot\mathbb 1[\theta_{k^*}(t_m)\le x_k].
$$
Now *conditional on $\mathcal G_j$ and the block reaching round $m$*, $\theta_{k^*}(t_m)$ is independent and has $\Pr(\theta_{k^*}(t_m)\le x_k\mid\mathcal G_j)=q_j$. So $M_j^{(\text C)}$ stochastically dominates... hmm, we want an *upper* bound.

Let $N_m:=\mathbb 1[\theta_{k^*}(t_m)\le x_k]$ be the i.i.d. Bernoulli$(q_j)$ sequence of events indicating "this round's optimal sample is $\le x_k$". Then $M_j^{(\text C)}\le\sum_{m=1}^{\infty}N_m\mathbb 1[t_m\text{ is still in block}]$. But the block ending is not purely a function of $N_m$; it depends on all suboptimal samples. *Crucially*, conditional on all suboptimal samples (i.e., on $\mathcal F_{t_m-1}^{(-k^*)}$), the block ends at $t_m$ iff $\theta_{k^*}(t_m)>W_{t_m}$; on $\{W_{t_m}\le x_k\}$, this is equivalent to $\theta_{k^*}(t_m)>W_{t_m}$, which is *weaker* (more likely) than $\theta_{k^*}(t_m)>x_k$.

Going back to the goal: we want $\mathbb E[M_j^{(\text C)}]$ small for $j\ge J$ (done: (6)), and for $j<J$ a bound of $O(1/p_j)$ so that $\mathbb E[1/p_j]$ is controlled.

**Lemma 5 (Optimal-arm forward bound).** For $j<J$:
$$
\mathbb E\Bigl[\sum_{t\in\mathcal T_j}\mathbb 1[I_t=k,C_t]\,\Bigl|\,\mathcal G_j\Bigr]\le\frac{1-p_j}{p_j}\mathbb 1[p_j>0],
$$
where $p_j=\Pr(\theta_{k^*}>x_k\mid\mathcal G_j)$.

*Proof.* Conditional on $\mathcal G_j$: within the $j$-block, at each round $t_m$ ($m=1,2,\ldots$), the samples $(\theta_{k'}(t_m))_{k'}$ are drawn independently of past block history given $\mathcal G_j$ (the $\theta_{k^*}$ is i.i.d.\ Beta, and other arms' samples are drawn from their current posteriors at $t_m$, which evolve as other arms are played). But conditioning on the full history $\mathcal H_{t_m-1}$ (which refines $\mathcal G_j$), $\theta_{k^*}(t_m)$ has distribution determined entirely by $\mathcal G_j$ (since $k^*$ hasn't been played in the block).

*Sub-claim:* If the block has a round $t_m$ with $I_{t_m}=k$ and $C_{t_m}$, then $\theta_{k^*}(t_m)\le x_k$ (by $C_{t_m}$). So we count block-rounds where $\theta_{k^*}(t_m)\le x_k$. The block ends at the first round $t$ with $\theta_{k^*}(t)>W_t$; in particular, if $\theta_{k^*}(t)>x_k$ and $W_t\le x_k$ (suboptimal samples all $\le x_k$, a subcase), then the block ends and arm $k^*$ is played.

*Crucial bounding.* Consider the sequence of block rounds $t_1,t_2,\ldots$ In round $t_m$, given $\mathcal H_{t_m-1}$: arms $k'\ne k^*$ sample $\theta_{k'}(t_m)$ from their posteriors; $\theta_{k^*}(t_m)$ is sampled from $\mathrm{Beta}(\cdot)$ determined by $\mathcal G_j$. These are mutually independent given $\mathcal H_{t_m-1}$.

Let $E_m:=\{I_{t_m}=k,C_{t_m}\}$. Define $F_m:=\{\theta_{k^*}(t_m)>x_k\}$ (event that the optimal's sample exceeds $x_k$). Then $E_m\subseteq F_m^c$ (since $C_{t_m}$ means $\theta_{k^*}\le x_k$). Moreover, we have:
$$
\mathbb 1_{E_m}\le\mathbb 1[I_{t_m}=k]\cdot\mathbb 1_{F_m^c}.
$$

Now here's the key: *conditionally on everything except $\theta_{k^*}(t_m)$*, the event $\{I_{t_m}=k\}$ depends on $\theta_{k^*}(t_m)$ only through $\{\theta_{k^*}(t_m)\le W_{t_m}\}$. Let $G_m:=\{M_{t_m}=k\}$ (the suboptimal leader is $k$, determined by $\mathcal F_{t_m-1}^{(-k^*)}$). Then $\{I_{t_m}=k\}=G_m\cap\{\theta_{k^*}(t_m)\le W_{t_m}\}$. So
$$
E_m=G_m\cap\{\theta_{k^*}(t_m)\le\min(W_{t_m},x_k)\}=G_m\cap\{\theta_{k^*}(t_m)\le x_k\text{ and }\theta_{k^*}(t_m)\le W_{t_m}\}.
$$

Similarly, the block continues past $t_m$ iff $\theta_{k^*}(t_m)\le W_{t_m}$; the block ends at $t_m$ iff $\theta_{k^*}(t_m)>W_{t_m}$.

Let $H_m:=\{\text{block-round }t_m\text{ is still in block}\}=\{\theta_{k^*}(t_{m'})\le W_{t_{m'}}\text{ for all }m'<m\}$. Then $\mathbb 1_{E_m}=\mathbb 1_{H_m}\mathbb 1_{G_m}\mathbb 1[\theta_{k^*}(t_m)\le\min(W_{t_m},x_k)]$.

Consider
$$
X:=\sum_{m=1}^{\infty}\mathbb 1_{E_m},\qquad Y:=\sum_{m=1}^{\infty}\mathbb 1_{H_m}\mathbb 1[F_m]=\sum_{m=1}^{\infty}\mathbb 1_{H_m}\mathbb 1[\theta_{k^*}(t_m)>x_k].
$$
$X$ counts block-rounds with $I_t=k$ and $C_t$; $Y$ counts block-rounds where $\theta_{k^*}>x_k$. Observe $Y\le 1$ a.s.: the first block round where $\theta_{k^*}(t_m)>x_k$ must have $\theta_{k^*}(t_m)>x_k\ge 0\ge...$; hmm, but the block could continue past it if $W_{t_m}>\theta_{k^*}(t_m)$. Specifically, if $\theta_{k^*}(t_m)>x_k$ *and* $W_{t_m}>\theta_{k^*}(t_m)$, then block continues. So $Y$ can be $>1$.

We pair up the sum differently. For each $m$, condition on $\mathcal H_{t_m-1}$ (hence $\mathcal F_{t_m-1}^{(-k^*)}$ after revealing suboptimal samples). The random variable $\theta_{k^*}(t_m)$ has density $f^*$ on $[0,1]$ determined by $\mathcal G_j$. Then
$$
\Pr(E_m\mid\mathcal F_{t_m-1}^{(-k^*)},H_m)=\mathbb 1_{G_m}\mathbb 1_{H_m}F^*(\min(W_{t_m},x_k))
$$
and
$$
\Pr(F_m,H_m\mid\mathcal F_{t_m-1}^{(-k^*)})=\mathbb 1_{H_m}(1-F^*(x_k))=\mathbb 1_{H_m}p_j.
$$
(since $F_m$ depends only on $\theta_{k^*}(t_m)$ which has cdf $F^*$, and $H_m$ is $\mathcal F_{t_m-1}^{(-k^*)}$-measurable.)

Take the ratio:
$$
\frac{\Pr(E_m\mid\mathcal F_{t_m-1}^{(-k^*)})}{\Pr(F_m,H_m\mid\mathcal F_{t_m-1}^{(-k^*)})}=\frac{\mathbb 1_{G_m}\mathbb 1_{H_m}F^*(\min(W_{t_m},x_k))}{\mathbb 1_{H_m}p_j}\le\frac{F^*(x_k)}{p_j}=\frac{1-p_j}{p_j}.
$$
(If $p_j=0$, then $E_m\subseteq F_m^c$ has probability involving... we address the $p_j=0$ case separately: if $p_j=0$, then $\theta_{k^*}$ is almost surely $\le x_k$, so the block never ends (because the block ends only when $\theta_{k^*}>W_t$, and $W_t\le 1$, but $\theta_{k^*}\le x_k<1$ is not contradicted). Actually $\{block ends\}=\{\theta_{k^*}>W_t\}$; if $\theta_{k^*}\le x_k$ a.s., this requires $W_t<x_k$, which depends on suboptimal samples. So the block can still end. Skip $p_j=0$ — it occurs with probability 0 since Beta has full support on $[0,1]$.)

Thus $\mathbb E[\mathbb 1_{E_m}\mid\mathcal F_{t_m-1}^{(-k^*)}]\le\frac{1-p_j}{p_j}\mathbb E[\mathbb 1_{H_m}\mathbb 1_{F_m}\mid\mathcal F_{t_m-1}^{(-k^*)}]$.

Summing over $m$:
$$
\mathbb E[X\mid\mathcal G_j]\le\frac{1-p_j}{p_j}\mathbb E[Y\mid\mathcal G_j].
$$

Finally, $Y\le$ (number of block-rounds with $\theta_{k^*}(t_m)>x_k$). Each such round $m$ with $\theta_{k^*}(t_m)>x_k$: we claim there are at most (geometric-like) many, but actually $Y$ can exceed 1. However, we can bound $\mathbb E[Y\mid\mathcal G_j]$ by:
$$
\mathbb E[Y\mid\mathcal G_j]\le\mathbb E\Bigl[\sum_{m\ge 1}\mathbb 1_{H_m}\mathbb 1_{F_m}\Bigr|\mathcal G_j\Bigr].
$$
In the block, at most $\cdots$. Here's a cleaner path: we do *not* need to bound $Y$ individually; we want $\mathbb E[X]$. But $\mathbb E[Y]$ can be larger than 1.

Here is a crucial observation: **the sum $\sum_{m\ge 1}\mathbb 1_{H_m}$ is just $M_j$, the block length**, and $\mathbb 1_{H_m}\mathbb 1_{F_m}$ counts block-rounds with $\theta_{k^*}>x_k$. The block ends at the first $m$ such that $\theta_{k^*}(t_m)>W_{t_m}$. If we *replace the ending condition* by $\theta_{k^*}(t_m)>x_k$, we get a *shorter* block: let $\tilde M_j:=\min\{m:\theta_{k^*}(t_m)>x_k\}$ (a geometric variable with parameter $p_j$). Then inside the real block, we have $Y\le$ (number of block-rounds with $\theta_{k^*}>x_k$). But if $\theta_{k^*}(t_{\tilde M_j})>x_k$, this occurs at some round within block (possibly before block ends or after, since block ending requires $>W_t$, not just $>x_k$). This sample will also have $\theta_{k^*}>x_k$, so $Y\ge 1$. Beyond $\tilde M_j$, the block might continue and more $\theta_{k^*}>x_k$ samples can accrue, but also samples with $\theta_{k^*}\le x_k$ in between. $Y$ thus equals the total count of $\{\theta_{k^*}>x_k\}$ rounds within the block, which is bounded by $M_j$.

**Final bound.** We don't need a sharper $Y$ bound because we'll later multiply by a Beta lower-tail probability; we use $\mathbb E[X\mid\mathcal G_j]\le\frac{1-p_j}{p_j}\mathbb E[Y\mid\mathcal G_j]$ combined with $Y\le M_j\le T$ trivially to get
$$
\mathbb E[X\mid\mathcal G_j]\le\frac{1-p_j}{p_j}\cdot T.
$$
This gives $\mathbb E[X]\le T\cdot\mathbb E[(1-p_j)/p_j]$ over the $\mathcal G_j$-probability, and the challenge becomes bounding $\mathbb E[1/p_j]$ for small $j$.

This is a known hard point: $\mathbb E[1/p_j]$ for $j=0$ is $\int_0^1\frac{1}{1-y}$ which diverges. So this route does not cleanly give a finite bound for $j=0$.

---

### Route Failure Report

**Route**: Route 4 — Direct Problem-Dependent Bound via Two-Phase Counting (clean variant of Agrawal–Goyal).

**Successfully established**:
- Step 1 (Beta–Binomial duality) — complete.
- Step 2 (Beta concentration $\Pr(|S-\hat p|\ge\varepsilon)\le 2e^{-2n\varepsilon^2)}$) — complete, via Hoeffding on a Binomial with $n+1$ trials.
- Step 3 (Empirical concentration) — complete.
- Step 4 (Two-phase decomposition for suboptimal arm with $L=\lceil 8\log T/\Delta_k^2\rceil$) — complete.
- Step 5 (Bad-event inclusion $\{I_t=k,N_k(t-1)\ge L\}\subseteq A_t\cup B_t\cup C_t$) — complete.
- Step 6 (Sums of $\Pr(A_t)$ and $\Pr(B_t)$ terms, each $\le 32/(T\Delta_k^2)$) — complete.
- Step 8(a): For $j=N_{k^*}(t-1)\ge J=\lceil 8\log T/\Delta_k^2\rceil$, we showed $\sum_{j\ge J}\sum_{t\in\mathcal T_j}\Pr(I_t=k,C_t)\le 32/\Delta_k^2$.

**Failed at**: Step 8(b) — bounding the contribution of rounds with $N_{k^*}(t-1)=j<J$ (the "under-explored optimal arm" regime).

**Obstacle**: The route outline's final sub-step — "$\{\theta_{k^*}(t)\le\mu^*-\Delta_k/2\}$: prob $\le$ Beta lower tail + empirical concentration for optimal arm" — is *not* sufficient when $j<J$, because:

1. For $j=0$ (optimal arm never played), $\theta_{k^*}\sim\mathrm{Uniform}[0,1]$, so $\Pr(C_t)=x_k$, which is $O(1)$, not small. No amount of Hoeffding or Beta concentration helps because the concentration bounds are useless for $n=0$.

2. The canonical Agrawal–Goyal fix is the "probability-ratio lemma" (Lemma 4$^*$ above): bound
$$
\Pr(I_t=k,C_t)\le\frac{1-p_t^*}{p_t^*}\Pr(I_t=k^*,C_t^c).
$$
This requires bounding $\mathbb E[1/p_t^*-1]$ for $j<J$, which in turn requires the celebrated sub-lemma
$$
\mathbb E\Bigl[\frac{1}{p_j}-1\Bigr]\le O(1)\cdot\text{(small for large enough }j\text{)}
$$
when $\theta_{k^*}\sim\mathrm{Beta}(S+1,F+1)$ with $S+F=j$. This bound, proved in Agrawal–Goyal 2017 Lemma 2.13, is *not* a simple consequence of Beta concentration or Hoeffding — it requires a delicate analysis of Beta tails combined with the random-walk properties of the posterior (how $(S,F)$ evolves under repeated plays), and in particular **requires a separate inductive argument** or recurrent bound. The route-outline did *not* anticipate this and provided no tool to handle it.

3. Attempting to bound $\mathbb E[1/p_j]$ directly fails: for $j=0$, $p_0=\Pr(\mathrm{Uniform}[0,1]>x_k)=1-x_k$, so $\mathbb E[1/p_0]=1/(1-x_k)$ is finite but the coefficient $T$ in $\mathbb E[X]\le T/p_j$ makes the bound scale as $T$, not polylog.

**Why Step 8(a) succeeds but 8(b) fails**: For $j\ge J$, the Beta distribution of $\theta_{k^*}$ has effective-width $\sqrt{1/j}\le\Delta_k/\sqrt{8\log T}$, so concentration is tight and $\Pr(C_t)\le 2e^{-j\Delta_k^2/8}$; summing $T\cdot\sum_{j\ge J}\Pr(C_t)$ converges to $O(1/\Delta_k^2)$. For $j<J$, the Beta is too wide to concentrate, and the contribution $\Pr(C_t)=O(1)$ per round is not directly controllable without the ratio lemma.

**Suggested fix (beyond Route 4 as specified)**: Complete the proof by adding the Agrawal–Goyal "Lemma 2.13" argument (bound on $\mathbb E[1/p_j-1]$ via exact Beta-cdf computations and a careful induction on $j$), obtaining
$$
\sum_{j=0}^{J-1}\mathbb E\Bigl[\frac{1-p_j}{p_j}\Bigr]\le O\Bigl(\frac{\log T}{\Delta_k^2}\Bigr),
$$
which combined with the other terms yields $\mathbb E[N_k(T)]\le O(\log T/\Delta_k^2)$. The gap-balancing in Step 9 (below, which we prove *assuming* the per-arm bound) then gives $O(\sqrt{KT\log T})$.

---

### Step 9 (assuming per-arm bound). Gap-balancing: problem-independent $O(\sqrt{KT\log T})$

*We include this step for completeness; it is not blocked by the failure above.*

Assume the per-arm bound $\mathbb E[N_k(T)]\le\frac{C_1\log T}{\Delta_k^2}+C_2$ for suboptimal arms, some constants $C_1,C_2$.

Total regret:
$$
\mathcal R(T)=\sum_{k:\Delta_k>0}\Delta_k\,\mathbb E[N_k(T)].
$$
Let $\Delta^*:=\sqrt{K\log T/T}$. Split arms by $\Delta_k\le\Delta^*$ vs. $\Delta_k>\Delta^*$.

**Small-gap arms ($\Delta_k\le\Delta^*$).** Since $\sum_k N_k(T)=T$, $\sum_{k:\Delta_k\le\Delta^*}\Delta_k N_k(T)\le\Delta^*\cdot T=\sqrt{KT\log T}$.

**Large-gap arms ($\Delta_k>\Delta^*$).** For each such arm, $\Delta_k\cdot\mathbb E[N_k(T)]\le\Delta_k(C_1\log T/\Delta_k^2+C_2)=C_1\log T/\Delta_k+C_2\Delta_k$. Summing:
$$
\sum_{k:\Delta_k>\Delta^*}\Delta_k\mathbb E[N_k(T)]\le\sum_{k:\Delta_k>\Delta^*}\bigl(C_1\log T/\Delta_k+C_2\bigr)\le K\cdot(C_1\log T/\Delta^*+C_2)=C_1\sqrt{KT\log T}+C_2 K.
$$

**Total.** $\mathcal R(T)\le\sqrt{KT\log T}+C_1\sqrt{KT\log T}+C_2K=(1+C_1)\sqrt{KT\log T}+C_2K\le C\sqrt{KT\log T}$ for $T\ge K$ (so $C_2K\le C_2\sqrt{KT}\le C_2\sqrt{KT\log T}$ for $T\ge 2$). $\square$

---

## Summary

**Routes completed**: Lemmas 1, 2, 3; the decomposition Steps 4–6 giving $\mathbb E[N_k(T)]\le L+32/(T\Delta_k^2)+32/(T\Delta_k^2)+(\text{Step-8 term})$; Step 8(a) giving $32/\Delta_k^2$ for the "large-$j$" part of Step-8; Step 9 (gap-balancing).

**Route failed at**: Step 8(b) — the "small-$j$" contribution of $\Pr(I_t=k,C_t)$ when $j=N_{k^*}(t-1)<J$. The route outline suggested that simple Chernoff/Beta concentration suffices, but for small $j$ neither applies (the optimal arm's posterior is too wide). Closing this gap requires the Agrawal–Goyal Lemma 2.13 bound on $\mathbb E[1/p_j-1]$, which is a separate non-trivial result beyond the scope of the outlined Route 4 toolkit.

Q.E.D. (conditional on Agrawal–Goyal Lemma 2.13).
