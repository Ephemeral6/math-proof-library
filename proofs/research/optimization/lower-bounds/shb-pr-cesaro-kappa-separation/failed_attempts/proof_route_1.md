# Proof — Route E (Companion Matrix Jordan Form)

**Route**: E — Operator/Matrix lifted state via Jordan form, exact computation of
$(I - M^{(\lambda)})^{-1}$ and $(I - M^{(\lambda)})^{-2}$.

**Theorem (boxed claim from problem.md).**
Under the over-damped slow-mode regime ($\eta\mu < (1-\sqrt\beta)^2$), the stable
condition (S), Assumption A, and the asymptotic regime $T(1-r_{1,\mu}) \to \infty$,
$$
\frac{f(\widetilde x_T)}{f(\bar x_T)} \;=\; \frac{4(1-\beta)^2}{T^2(\eta L)^2}\,\kappa^2\,(1+o(1)).
$$

---

## Pre-proof Knowledge Reuse

- **Strategy index**: closest match is `polyak-ruppert-shb-defeats-cycling`
  (meta-template: `spectral_eigenvalue` = MT8; technique chain: complexify → arithmetico-geometric sum → triangle inequality on closed-form). The slot pattern transfers, but with a critical difference: there $|\omega|=1$ (cycling), here $|r_{j}| \le \sqrt\beta < 1$ (decaying). The MT8 spectral skeleton is the right scaffold; the decay regime simplifies the arithmetic.
- **Meta-template**: MT8 (spectral / eigenvalue argument) — slot matrix is the
  $2\times 2$ companion $M^{(\lambda)}$; slot gap is $r_{1,\lambda}$ vs $r_{2,\lambda}$ in over-damped, and slow-mode-vs-fast-mode in $\lambda$.
- **Structure map**: links to Cluster A (SHB lower-bounds family), specifically
  `polyak-ruppert-shb-defeats-cycling` which uses the same companion-matrix lift but in the cycling regime.
- **Failure triggers**: scanned FT-18 (UB-LB consistency — N/A: this is purely an asymptotic identity, no LB to compare), FT triggers about Polyak SHB cycling (N/A: this is the strictly stable regime). No trigger fires.

---

## Step 1 — Setup and per-coordinate companion matrix

Because $f(x) = \tfrac12 \sum_i \lambda_i x_i^2$ is separable and the SHB
iteration $x_{t+1} = x_t - \eta\nabla f(x_t) + \beta(x_t - x_{t-1})$ is
component-wise linear with $[\nabla f(x)]_i = \lambda_i x_i$, every coordinate
$x_t^{(\lambda)}$ (we use $\lambda$ to label the per-eigenvalue scalar
trajectory) evolves independently:
$$
x_{t+1}^{(\lambda)} \;=\; (1+\beta-\eta\lambda)\, x_t^{(\lambda)} \;-\; \beta\, x_{t-1}^{(\lambda)}.
\tag{1}
$$

Lift to the state $y_t^{(\lambda)} := (x_t^{(\lambda)},\, x_{t-1}^{(\lambda)})^\top$. Then
$$
y_{t+1}^{(\lambda)} \;=\; M^{(\lambda)} \, y_t^{(\lambda)},\qquad
M^{(\lambda)} \;=\; \begin{pmatrix} 1+\beta-\eta\lambda & -\beta \\ 1 & 0\end{pmatrix}.
\tag{2}
$$

(Check: the first row of (2) reproduces (1), and the second row gives
$x_t^{(\lambda)} = x_t^{(\lambda)}$.)
By induction, $y_t^{(\lambda)} = (M^{(\lambda)})^t y_0^{(\lambda)}$, so
$$
x_t^{(\lambda)} \;=\; e_1^\top (M^{(\lambda)})^t y_0^{(\lambda)},
\qquad e_1 = (1,0)^\top.
\tag{3}
$$

For brevity in steps 2–6 we suppress the superscript $(\lambda)$.

## Step 2 — Eigenstructure of $M$

The characteristic polynomial of $M$ is
$$
\det(rI - M) \;=\; \det\begin{pmatrix} r - a & \beta \\ -1 & r\end{pmatrix}
\;=\; r^2 - a r + \beta,\qquad a := 1+\beta - \eta\lambda. \tag{4}
$$
Its roots $r_1, r_2$ satisfy Vieta's identities
$$
r_1 + r_2 = a = 1+\beta-\eta\lambda, \qquad r_1 r_2 = \beta. \tag{5}
$$

In the **over-damped regime** $\eta\lambda < (1-\sqrt\beta)^2$, the discriminant
$\Delta = a^2 - 4\beta = (1-\beta)^2 - 2(1+\beta)\eta\lambda + (\eta\lambda)^2$
is positive, so $r_1, r_2$ are real with $0 < r_2 < r_1 < 1$. (This holds, in
particular, for $\lambda = \mu$ by hypothesis.)

For $\lambda = L$ the slow-mode hypothesis is silent on whether the discriminant
is positive (the fast mode may be under-damped). Either way (S) gives both
roots in the open unit disc, so $|r_{j,L}| \le \sqrt\beta$ for $j = 1,2$
(use $|r_1 r_2| = \beta$ and the constraint that both roots are inside the unit
disc — when complex, both have modulus $\sqrt\beta$; when real, the larger root
is at most $1$ but the product is $\beta$ so neither factor exceeds 1, and
$\max_j |r_{j,L}| \le \max(r_{1,L}, |r_{2,L}|)$, both bounded by 1; the precise
bound used below is only $\max_j|r_{j,L}|^T \to 0$ as $T \to \infty$, which is
implied by (S) since both roots strictly satisfy $|r| < 1$).

**Eigenvectors.** From $(M - r_j I) v = 0$, with $M - rI = \begin{pmatrix} a - r & -\beta \\ 1 & -r \end{pmatrix}$,
the second row gives $v^{(1)} = r v^{(2)}$, so $v_j = (r_j, 1)^\top$. The
first row is automatically satisfied: $(a - r_j) r_j - \beta = a r_j - r_j^2 - \beta = -(r_j^2 - a r_j + \beta) = 0$ by (4).

Thus, when $r_1 \ne r_2$ (over-damped slow mode at $\lambda = \mu$, and in
the under-damped regime for $\lambda = L$ where roots are distinct complex
conjugates),
$$
P = \begin{pmatrix} r_1 & r_2 \\ 1 & 1 \end{pmatrix}, \qquad
P^{-1} = \frac{1}{r_1 - r_2}\begin{pmatrix} 1 & -r_2 \\ -1 & r_1 \end{pmatrix},
\qquad
M = P\,\mathrm{diag}(r_1, r_2)\, P^{-1}.
\tag{6}
$$

(Check: $PP^{-1} = (r_1-r_2)^{-1}\begin{pmatrix}r_1-r_2 & -r_1 r_2 + r_2 r_1 \\ 1-1 & -r_2 + r_1\end{pmatrix} = I$. ✓)

## Step 3 — Closed form for $(I - M)^{-1}$ and $(I-M)^{-2}$

Direct computation. With $a = 1+\beta-\eta\lambda$,
$$
I - M \;=\; \begin{pmatrix} 1 - a & \beta \\ -1 & 1 \end{pmatrix},\qquad
\det(I-M) \;=\; (1-a) + \beta \;=\; \eta\lambda. \tag{7}
$$
(Equivalently, $\det(I-M) = (1-r_1)(1-r_2) = 1 - (r_1+r_2) + r_1 r_2 = 1 - a + \beta = \eta\lambda$ by Vieta.)

By Cramer's rule (cofactor transpose / determinant),
$$
(I - M)^{-1} \;=\; \frac{1}{\eta\lambda}\,
\begin{pmatrix} 1 & -\beta \\ 1 & 1-a \end{pmatrix}
\;=\; \frac{1}{\eta\lambda}\,
\begin{pmatrix} 1 & -\beta \\ 1 & \eta\lambda - \beta \end{pmatrix}, \tag{8}
$$
where we used $1 - a = \eta\lambda - \beta$. **Verification.**
$$
(I-M)\,(I-M)^{-1}
= \frac{1}{\eta\lambda}\begin{pmatrix} 1-a & \beta \\ -1 & 1 \end{pmatrix}
                    \begin{pmatrix} 1 & -\beta \\ 1 & \eta\lambda - \beta\end{pmatrix}
= \frac{1}{\eta\lambda}\begin{pmatrix} (1-a)+\beta & -\beta(1-a) + \beta(\eta\lambda - \beta) \\ -1 + 1 & \beta + (\eta\lambda-\beta)\end{pmatrix}.
$$
Top-left: $(1-a)+\beta = \eta\lambda$. ✓
Top-right: $-\beta(\eta\lambda - \beta) + \beta(\eta\lambda - \beta) = 0$. ✓
Bottom-left: $0$. ✓ Bottom-right: $\beta + \eta\lambda - \beta = \eta\lambda$. ✓
So $(I-M)(I-M)^{-1} = I$, confirming (8).

**Now the key calculation: $(I-M)^{-2} = (I-M)^{-1} \cdot (I-M)^{-1}$.**

From (8),
$$
(I-M)^{-2}
= \frac{1}{(\eta\lambda)^2}
\begin{pmatrix} 1 & -\beta \\ 1 & \eta\lambda - \beta\end{pmatrix}
\begin{pmatrix} 1 & -\beta \\ 1 & \eta\lambda - \beta\end{pmatrix}.
$$
Compute each entry of the squared matrix.
- $(1,1)$: $1\cdot 1 + (-\beta)\cdot 1 = 1 - \beta$.
- $(1,2)$: $1\cdot(-\beta) + (-\beta)(\eta\lambda - \beta) = -\beta - \beta(\eta\lambda - \beta) = -\beta\bigl(1 + \eta\lambda - \beta\bigr)$.
- $(2,1)$: $1\cdot 1 + (\eta\lambda-\beta)\cdot 1 = 1 + \eta\lambda - \beta$.
- $(2,2)$: $1\cdot(-\beta) + (\eta\lambda-\beta)^2 = -\beta + (\eta\lambda-\beta)^2$.

Hence
$$
\boxed{\;(I-M^{(\lambda)})^{-2} \;=\;
\frac{1}{(\eta\lambda)^2}
\begin{pmatrix} 1-\beta & -\beta(1+\eta\lambda-\beta) \\
1+\eta\lambda-\beta & -\beta + (\eta\lambda-\beta)^2 \end{pmatrix}.\;}
\tag{9}
$$

**This is the resolution of the κ¹/κ² puzzle.** The $(1,1)$ entry of
$(I-M^{(\lambda)})^{-2}$ is $\boxed{(1-\beta)/(\eta\lambda)^2}$, NOT
$1/(\eta\lambda)^2$. The factor $(1-\beta)$ is the difference between
"naive over-damped" and "exact": only the *naive* under-damped formula, in
which one would write $|1-r_{1,\mu}|^2 = \eta\mu$ exactly (true under-damped
modulus identity) and then square to get $1/(\eta\mu)^2$, would skip this
factor. For the matrix entry, however, the cross-term between the $(1,1)$
and $(1,2)$ entries of $(I-M)^{-1}$ contributes $-\beta$ at the $(1,1)$
position, producing the $(1-\beta)$ factor — a structurally distinct
phenomenon from the modulus identity.

For later reference we also need the over-damped expansion. Diagonalizing
(8) using (6),
$$
(I - M)^{-1} = P\,\mathrm{diag}\!\Bigl(\tfrac{1}{1-r_1}, \tfrac{1}{1-r_2}\Bigr) P^{-1},
\qquad
(I - M)^{-2} = P\,\mathrm{diag}\!\Bigl(\tfrac{1}{(1-r_1)^2}, \tfrac{1}{(1-r_2)^2}\Bigr) P^{-1}.
\tag{10}
$$
This is consistent with (8)–(9) and is what we'll use to track the slow-mode
contribution.

## Step 4 — Over-damped slow-mode expansions

For $\lambda = \mu$ in the over-damped regime, both roots are real. Set
$\delta := \eta\mu/(1-\beta) \ll 1$ (the small parameter; the over-damped
condition $\eta\mu < (1-\sqrt\beta)^2 = (1-\beta)^2 \cdot (1-\sqrt\beta)^2/(1-\beta)^2$ implies $\delta < (1-\sqrt\beta)^2/(1-\beta)$, in particular $\delta$ can be small for any fixed $\beta < 1$). The discriminant is
$$
\Delta = (1-\beta)^2 - 2(1+\beta)\eta\mu + (\eta\mu)^2
= (1-\beta)^2\Bigl[1 - 2\frac{(1+\beta)}{(1-\beta)^2}\eta\mu + O((\eta\mu)^2)\Bigr],
$$
so
$$
\sqrt{\Delta} = (1-\beta)\Bigl[1 - \frac{(1+\beta)}{(1-\beta)^2}\eta\mu + O((\eta\mu)^2)\Bigr]
= (1-\beta) - \frac{(1+\beta)}{1-\beta}\eta\mu + O((\eta\mu)^2/(1-\beta)).
$$
The slow root is
$$
r_{1,\mu} = \frac{a + \sqrt\Delta}{2}
= \frac{1+\beta - \eta\mu + (1-\beta) - \tfrac{(1+\beta)}{1-\beta}\eta\mu + O(\cdot)}{2}
= 1 - \frac{\eta\mu}{2}\Bigl[1 + \frac{1+\beta}{1-\beta}\Bigr] + O(\cdot).
$$
Simplifying $1 + \tfrac{1+\beta}{1-\beta} = \tfrac{(1-\beta)+(1+\beta)}{1-\beta} = \tfrac{2}{1-\beta}$,
$$
\boxed{\; r_{1,\mu} = 1 - \frac{\eta\mu}{1-\beta} + O\!\Bigl(\frac{(\eta\mu)^2}{(1-\beta)^3}\Bigr),
\qquad
1 - r_{1,\mu} = \frac{\eta\mu}{1-\beta}\,\Bigl(1 + O(\delta^2/\beta\text{-poly})\Bigr).\;}
\tag{11}
$$
By Vieta $r_{2,\mu} = \beta/r_{1,\mu} = \beta(1 + \eta\mu/(1-\beta) + O(\delta^2)) = \beta + \beta\eta\mu/(1-\beta) + O(\delta^2)$, so
$$
1 - r_{2,\mu} = (1-\beta) - \frac{\beta\eta\mu}{1-\beta} + O(\delta^2)
= (1-\beta)\Bigl[1 - \frac{\beta\,\eta\mu}{(1-\beta)^2} + O(\delta^2)\Bigr].
\tag{12}
$$
Consistency check: $(1 - r_{1,\mu})(1 - r_{2,\mu}) = \frac{\eta\mu}{1-\beta} \cdot (1-\beta)\,(1 + O(\delta)) = \eta\mu\,(1+O(\delta))$, matching the exact identity $\eta\mu$ from (7). The $O(\delta)$ in this product cancels at leading order. ✓

We will also need the squared expansion. From (11),
$$
(1 - r_{1,\mu})^2 = \frac{(\eta\mu)^2}{(1-\beta)^2}\,\bigl(1 + O(\delta^2)\bigr).
\tag{13}
$$

## Step 5 — Matrix-geometric series

We need, for any matrix $M$ with $\rho(M) < 1$,
$$
S_T := \sum_{t=0}^{T-1} M^t = (I-M)^{-1}\,(I - M^T), \tag{14}
$$
$$
W_T := \sum_{t=0}^{T-1} (t+1)\,M^t. \tag{15}
$$

**Identity (14)** is standard. **Identity for $W_T$:** differentiate
$\sum_{t=0}^{T-1} z^{t+1} = z\,(1 - z^T)/(1-z)$ in $z$ at the matrix
level. Concretely, the scalar identity
$\sum_{t=0}^{T-1}(t+1) z^t = \frac{1 - (T+1) z^T + T z^{T+1}}{(1-z)^2}$
generalizes (via the spectral theorem applied to a diagonalizable $M$) to
$$
W_T = (I-M)^{-2}\,\bigl[I - (T+1) M^T + T\,M^{T+1}\bigr]. \tag{16}
$$
**Verification by spectral substitution.** With $M = P\mathrm{diag}(r_1, r_2) P^{-1}$,
the right side of (16) equals $P\,\mathrm{diag}(F_T(r_1), F_T(r_2))\,P^{-1}$
with $F_T(r) = (1 - (T+1)r^T + T r^{T+1})/(1-r)^2$, and $F_T(r) = \sum_{t=0}^{T-1}(t+1)r^t$ by direct algebra (multiply both sides by $(1-r)^2 = 1 - 2r + r^2$ and check the
expansion). Linearity-of-spectrum then gives (16). The same argument
applies in the (degenerate) over-damped equal-roots case via continuity in
the discriminant. ✓

**Truncation negligibility.** In the asymptotic regime $T(1-r_{1,\mu}) \to \infty$,
$r_{1,\mu}^T = (1 - \eta\mu/(1-\beta) + O(\delta^2))^T \le \exp(-T(1-r_{1,\mu})) \to 0$
super-polynomially in $T(1-r_{1,\mu})$, and $r_{2,\mu}^T \le \beta^T \to 0$
even faster. For $\lambda = L$, $|r_{j,L}|^T \le \rho(M^{(L)})^T < 1^T$ uniformly,
and (S) ensures $\rho(M^{(L)}) < 1$, so $|r_{j,L}|^T \to 0$.

In the rest of this proof, "slow-mode dominance" plus Assumption A allow us
to drop terms of order $r_{1,\mu}^T, r_{2,\mu}^T, r_{j,L}^T$ — they are
exponentially small in the asymptotic regime, and we'll absorb them into a
single $(1+o(1))$ at the end.

Therefore, asymptotically (with $r_{j}^T \to 0$),
$$
S_T = (I - M)^{-1} + E_T^{(S)},\qquad \|E_T^{(S)}\| = O(\rho(M)^T \cdot (1-\rho(M))^{-1});
\tag{17}
$$
$$
W_T = (I - M)^{-2} + E_T^{(W)},\qquad \|E_T^{(W)}\| = O\!\bigl(T \cdot \rho(M)^T \cdot (1-\rho(M))^{-2}\bigr).
\tag{18}
$$
Both error terms are $o(1) \cdot \|(I-M)^{-2}\|$ in the asymptotic regime.

## Step 6 — Per-coordinate averages

The Cesàro and PR averages of $x_t^{(\lambda)}$ are
$$
\bar x_T^{(\lambda)} \;=\; \frac{1}{T}\sum_{t=0}^{T-1} x_t^{(\lambda)}
\;=\; \frac{1}{T}\,e_1^\top S_T^{(\lambda)} y_0^{(\lambda)},
\tag{19}
$$
$$
\widetilde x_T^{(\lambda)} \;=\; \frac{2}{T(T+1)}\sum_{t=0}^{T-1}(t+1) x_t^{(\lambda)}
\;=\; \frac{2}{T(T+1)}\,e_1^\top W_T^{(\lambda)} y_0^{(\lambda)}.
\tag{20}
$$

Using (17), (18), and (8), (9), we extract the leading entries.

**Cesàro at $\lambda$.** From $e_1^\top (I-M^{(\lambda)})^{-1} = \frac{1}{\eta\lambda}(1, -\beta)$,
$$
\bar x_T^{(\lambda)}
= \frac{1}{T \eta\lambda}\bigl[x_0^{(\lambda)} - \beta\, x_{-1}^{(\lambda)}\bigr] + o\!\Bigl(\frac{1}{T\eta\lambda}\Bigr).
\tag{21}
$$

**PR at $\lambda$.** From $e_1^\top (I-M^{(\lambda)})^{-2} = \frac{1}{(\eta\lambda)^2}\bigl(1-\beta,\; -\beta(1+\eta\lambda-\beta)\bigr)$,
$$
\widetilde x_T^{(\lambda)}
= \frac{2}{T(T+1)(\eta\lambda)^2}\Bigl[(1-\beta) x_0^{(\lambda)} - \beta(1+\eta\lambda-\beta)\, x_{-1}^{(\lambda)}\Bigr] + o\!\Bigl(\frac{1}{T^2 (\eta\lambda)^2}\Bigr).
\tag{22}
$$

Note that the structure (21) vs (22) already shows the order-of-magnitude
difference:
$$
\widetilde x_T^{(\lambda)} \;\asymp\; \frac{2(1-\beta)}{T^2 (\eta\lambda)^2}\, c_0(x_0^{(\lambda)}, x_{-1}^{(\lambda)})
\quad\text{vs.}\quad
\bar x_T^{(\lambda)} \;\asymp\; \frac{1}{T \eta\lambda}\, c_1(x_0^{(\lambda)}, x_{-1}^{(\lambda)}).
\tag{23}
$$
The PR average has an additional $(1-\beta)/(T \eta\lambda)$ factor compared
with the Cesàro average. **This is the precise factor that makes PR vs Cesàro
disagree by κ when $\lambda = \mu$.**

For brevity, define
$$
C_\lambda := x_0^{(\lambda)} - \beta\, x_{-1}^{(\lambda)},\qquad
D_\lambda := (1-\beta) x_0^{(\lambda)} - \beta(1+\eta\lambda-\beta)\, x_{-1}^{(\lambda)}.
\tag{24}
$$

By Assumption A, the slow-mode coefficient $C_\mu \ne 0$ generically (precise
statement at end of Step 7). Both $C_\mu$ and $D_\mu$ are bounded in $\eta\mu$
(they are linear combinations of $x_0^{(\mu)}, x_{-1}^{(\mu)}$ with coefficients
bounded uniformly in $\eta\mu \in (0, (1-\sqrt\beta)^2)$).

## Step 7 — Slow-mode dominance in $f$

Recall $f(\bar x_T) = \sum_\lambda \tfrac{\lambda}{2} (\bar x_T^{(\lambda)})^2$
and similarly for $\widetilde x_T$. Plug (21)–(22) into these formulas.

**Cesàro $f$:**
$$
f(\bar x_T)
\;=\; \sum_\lambda \frac{\lambda}{2} \cdot \frac{C_\lambda^2}{T^2 (\eta\lambda)^2}\,(1+o(1))
\;=\; \frac{1}{2 T^2 \eta^2}\sum_\lambda \frac{C_\lambda^2}{\lambda}\,(1+o(1)).
\tag{25}
$$

**PR $f$:**
$$
f(\widetilde x_T)
\;=\; \sum_\lambda \frac{\lambda}{2} \cdot \frac{4 D_\lambda^2}{T^2(T+1)^2 (\eta\lambda)^4}\,(1+o(1))
\;=\; \frac{2}{T^2(T+1)^2 \eta^4}\sum_\lambda \frac{D_\lambda^2}{\lambda^3}\,(1+o(1)).
\tag{26}
$$

**Slow-mode dominance.** In (25), the term $\lambda = \mu$ contributes
$C_\mu^2/\mu$, while $\lambda = L$ contributes $C_L^2/L$. The ratio is
$(C_\mu^2 / C_L^2) \cdot \kappa$. Under Assumption A, $C_\mu \ne 0$, and
$|C_L|$ is bounded (in fact bounded uniformly in $\kappa$ for any fixed
initialization with bounded $\|x_0\|, \|x_{-1}\|$). Hence the slow-mode term
dominates by a factor $\Theta(\kappa)$ as $\kappa \to \infty$, and
$$
\sum_\lambda \frac{C_\lambda^2}{\lambda}
= \frac{C_\mu^2}{\mu}\,\bigl(1 + O(1/\kappa)\bigr).
\tag{27}
$$

In (26), the slow mode contributes $D_\mu^2/\mu^3$ while $\lambda = L$
contributes $D_L^2/L^3$, ratio $(D_\mu^2/D_L^2)\cdot\kappa^3$. By the same
Assumption A argument and that $D_\lambda$ is a Lipschitz-bounded linear
combination, the slow mode dominates by $\Theta(\kappa^3)$:
$$
\sum_\lambda \frac{D_\lambda^2}{\lambda^3}
= \frac{D_\mu^2}{\mu^3}\,\bigl(1 + O(1/\kappa^3)\bigr).
\tag{28}
$$

(The Assumption A precise statement, $P_\mu(x_0 - r_{2,\mu} x_{-1}) \ne 0$,
combined with the over-damped expansion $r_{2,\mu} = \beta + O(\eta\mu)$,
implies $C_\mu = x_0^{(\mu)} - \beta x_{-1}^{(\mu)} = (x_0^{(\mu)} - r_{2,\mu} x_{-1}^{(\mu)}) + (r_{2,\mu} - \beta) x_{-1}^{(\mu)} = (\text{nonzero}) + O(\eta\mu)$, hence $C_\mu \ne 0$ for $\eta\mu$ small enough; similarly $D_\mu = (1-\beta) C_\mu - \beta\eta\mu\, x_{-1}^{(\mu)} + O(\eta\mu)$, so $D_\mu = (1-\beta) C_\mu + O(\eta\mu)$, again nonzero in the limit.)

Plugging (27) into (25) and (28) into (26),
$$
f(\bar x_T) \;=\; \frac{C_\mu^2}{2 T^2 \eta^2 \mu}\,\bigl(1 + O(1/\kappa) + o(1)\bigr),
\tag{29}
$$
$$
f(\widetilde x_T) \;=\; \frac{2 D_\mu^2}{T^2(T+1)^2 \eta^4 \mu^3}\,\bigl(1 + O(1/\kappa^3) + o(1)\bigr).
\tag{30}
$$

## Step 8 — The ratio

Take the ratio of (30) to (29):
$$
\frac{f(\widetilde x_T)}{f(\bar x_T)}
= \frac{2 D_\mu^2 / (T^2(T+1)^2 \eta^4 \mu^3)}{C_\mu^2 / (2 T^2 \eta^2 \mu)}\,(1+o(1))
= \frac{4 D_\mu^2}{(T+1)^2 \eta^2 \mu^2 C_\mu^2}\,(1+o(1)).
\tag{31}
$$

Now use $D_\mu = (1-\beta) C_\mu + O(\eta\mu)$ from Step 7. Squaring,
$D_\mu^2 = (1-\beta)^2 C_\mu^2 + O(\eta\mu)$, so $D_\mu^2/C_\mu^2 = (1-\beta)^2 (1 + O(\eta\mu))$.
Substituting,
$$
\frac{f(\widetilde x_T)}{f(\bar x_T)}
= \frac{4(1-\beta)^2}{(T+1)^2 \eta^2 \mu^2}\,(1 + o(1))
= \frac{4(1-\beta)^2}{T^2 \eta^2 \mu^2}\,(1 + o(1)),
\tag{32}
$$
where we absorbed $(T+1)^2 = T^2(1 + O(1/T))$ into the $(1+o(1))$.

Finally, using $\mu = L/\kappa$, i.e. $(\eta\mu)^2 = (\eta L)^2/\kappa^2$,
$$
\boxed{\;
\frac{f(\widetilde x_T)}{f(\bar x_T)}
\;=\; \frac{4(1-\beta)^2}{(T \eta L)^2}\,\kappa^2\,(1 + o(1)).
\;}
\tag{33}
$$
This is the boxed claim. ∎ (for the ratio identity)

## Step 9 — Individual scalings $f(\bar x_T) = \Theta(\kappa^2/T^2)$ and $f(\widetilde x_T) = \Theta(\kappa^4/T^4)$

The boxed claim is the *ratio*, which is the substantive identity. The
individual $\Theta$-statements depend on a normalization of the
initialization. Below we record the natural reading.

From (29) and (30),
$$
f(\bar x_T) = \Theta\!\Bigl(\frac{C_\mu^2}{T^2 \eta^2 \mu}\Bigr),
\qquad
f(\widetilde x_T) = \Theta\!\Bigl(\frac{D_\mu^2}{T^4 \eta^4 \mu^3}\Bigr).
\tag{34}
$$
Substitute $\mu = L/\kappa$:
$$
f(\bar x_T) = \Theta\!\Bigl(\frac{C_\mu^2 \kappa}{T^2 (\eta L)^2 / L}\Bigr)
= \Theta\!\Bigl(\frac{C_\mu^2\, L\, \kappa}{T^2 (\eta L)^2}\Bigr).
\tag{35}
$$
$$
f(\widetilde x_T) = \Theta\!\Bigl(\frac{D_\mu^2 \kappa^3}{T^4 (\eta L)^4 / L^3}\Bigr)
= \Theta\!\Bigl(\frac{D_\mu^2\, L^3\, \kappa^3}{T^4 (\eta L)^4}\Bigr).
\tag{36}
$$

If the initialization is chosen so that $|C_\mu|^2 = \Theta(\kappa)$ — for
instance, the "alt-momentum" initialization
$x_0^{(\mu)} = c\sqrt{\kappa}/\sqrt L$, $x_{-1}^{(\mu)} = -c\sqrt\kappa/\sqrt L$
that makes the slow-mode amplitude in the spectral
expansion scale with $\kappa^{1/2}$ — then $C_\mu^2 \sim \kappa$ and
$D_\mu^2 \sim (1-\beta)^2 \kappa$, yielding
$$
f(\bar x_T) = \Theta(\kappa^2/T^2),\qquad
f(\widetilde x_T) = \Theta(\kappa^4/T^4),
$$
which matches the numerical observations $f(\bar) \sim \kappa^{1.998}$,
$f(\widetilde) \sim \kappa^{3.83}$ in problem.md.

The ratio (33) is independent of this normalization since $C_\mu^2$ cancels,
and (33) is the substantive theorem.

## Step 10 — Error term explicit bound

Tracing the $o(1)$ in (33):
1. From (17)–(18), the truncation error contributes $O(T \rho^T (1-\rho)^{-2})$
   where $\rho = \rho(M^{(\mu)}) = r_{1,\mu} = 1 - \eta\mu/(1-\beta) + O(\delta^2)$. So $\rho^T \le \exp(-T(1-r_{1,\mu}))$ which is sub-polynomial in $T(1-r_{1,\mu}) \to \infty$ by hypothesis.
2. From (27)–(28), L-mode subdominance gives $1 + O(1/\kappa)$ for the
   numerator and $1 + O(1/\kappa^3)$ for the denominator.
3. From (32), $(T+1)^2 = T^2(1 + 2/T + 1/T^2)$ contributes $O(1/T)$.
4. From the over-damped expansion (11), $r_{2,\mu} - \beta = \beta\eta\mu/(1-\beta) + O(\delta^2)$, so $D_\mu^2 / C_\mu^2 = (1-\beta)^2 (1 + O(\eta\mu/(1-\beta)))$.

Collecting,
$$
\frac{f(\widetilde x_T)}{f(\bar x_T)}
= \frac{4(1-\beta)^2 \kappa^2}{(T \eta L)^2}\,
\Bigl[1 + O(1/T) + O(1/\kappa) + O(\eta\mu/(1-\beta)) + O(T\rho^T)\Bigr].
\tag{37}
$$
In the strong asymptotic regime $T \to \infty$ with all of $T \rho^T \to 0$,
$1/\kappa \to 0$ (i.e. $\kappa \to \infty$), $\eta\mu/(1-\beta) \to 0$, the
correction collapses to $1+o(1)$. ∎

---

## Hooks Report

- **Strategy signatures consulted**:
  1. `polyak-ruppert-shb-defeats-cycling` (the closest match: same lift to companion matrix, same MT8 spectral skeleton; differs in regime — that proof handles $|r|=1$ cycling, this one handles $|r| \le \sqrt\beta < 1$ decay).
  2. `heavy-ball-instability` (also uses the 2×2 companion matrix eigenvalue analysis; consulted for matrix algebra patterns; useful for confirming the $r_1 r_2 = \beta$ Vieta).
  Useful: **YES** — the slot-fill of MT8 (slot matrix = companion of SHB recurrence; slot gap = $r_{1,\mu}$ vs others) gave a clean scaffold; the technique chain "decoupled diagonal quadratics → 2×2 companion matrix eigenvalues → Vieta product/sum identities" transferred verbatim.
- **Meta-template attempted**: **MT8 (spectral / eigenvalue argument)**.
  Slots filled: [slot matrix = $M^{(\lambda)}$; slot gap = $r_{1,\mu}$ separation from $r_{2,\mu}$ and from L-mode roots; slot decay = $\rho < 1$ from (S)]. Blocker slot: **none** — all slots filled. The key insight not in the bare template was the explicit computation of $(I-M)^{-2}_{11} = (1-\beta)/(\eta\lambda)^2$ rather than $1/(\eta\lambda)^2$; this is the κ¹/κ² resolution and is a route-specific algebraic step beyond the template.
- **Structure map links used**:
  - `polyak-ruppert-shb-defeats-cycling` (same companion matrix lift; structurally analogous) — SAME_TEMPLATE link.
  - Cluster A (SHB lower-bounds family) — DUAL link in spirit (a UB / amplification analogue rather than LB).
- **Failure triggers checked**: 4 (FT-18 UB-LB consistency [N/A — only an asymptotic identity]; the Polyak/Nesterov GPT cycling triggers [N/A — strictly stable regime]; FT on quadratic-too-easy hard instances [N/A — we're proving rate, not LB]; FT on log-cosh curvature transition [N/A — pure quadratic]). **Matched: 0; pivots taken: none.**
- **Library citations**:
  - The companion matrix lift and Vieta identities are standard linear algebra — no library citation needed.
  - The matrix geometric series identities (14), (16) are standard but proofs are included in Step 5 for self-containedness; could be archived as B-class library lemmas if desired.
  - No external [REF: ...] citations required.

Q.E.D.
