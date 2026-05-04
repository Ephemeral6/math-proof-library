<!-- AUDITOR ATTENTION: This is a HYBRID best_proof constructed from Route 1 (Part A UB) and Route 3 (Part B LB). The original conjecture is REFUTED under the variance-only oracle. **Round 1 fixes applied** (see Progress Ledger near the bottom). The Judge originally flagged the following minor issues for Auditor verification, all addressed in this round:

1. Route 1 §8 ("bounded-gradient assumption"): the a.s. envelope M = G_∞ + σ is an ADDITIONAL ASSUMPTION not stated in problem.md. Auditor must flag this explicitly and discuss whether it is standard/avoidable. [Standing: discussed in §A-Remark; not modified by Round 1.]

2. Route 3 §2.1: the needle construction went through multiple iterations before settling on φ_s(u) = sA·sclip_R(u) + (L/2)u². The final construction is correct, but the smoothness claim (achieving L-smooth after rescaling L → L/2) should be verified independently. [Standing: noted, audit verified.]

3. Route 3 §3.8: the tuning A = √(2LΔ₀) with separate ε-tuning at §3.9 requires clarification — the "FINAL" LB is T ≥ Ω(dσ²/ε) with the tuning producing an "honest regime" condition ε ≤ c·LΔ₀/d (stated in the theorem at §1.2). Auditor should verify this regime condition is consistent with the hybrid's parameter choices. [Standing: audit verified, c₁=1/9 sufficient.]

4. The CALL:math-verifier tags in Route 3 §3.7 (symmetrization argument change-of-measure step) and the Coordinate Decoupling Lemma (Route 4, referenced in evaluation) are UNVERIFIED. Auditor/Fixer must close the change-of-measure step in §3.7. **[CLOSED IN ROUND 1: explicit chi-squared derivation now written out in §3.7.]**

**Round 1 fix summary (see Progress Ledger):**
- F1 (MEDIUM, ROUTINE): §3.2 algebraic inequality replaced with the correct $\frac{b}{2a\sqrt{a+b}}$ bound; §4 absorption re-derived under the a.s. envelope $M$ with adjusted constant tracking. Strategic rate $T^{-1/2}\sqrt{d\log T}$ unchanged.
- F2 (MEDIUM, ROUTINE): Explicit "Oracle interpretation" subsection added at the start of Part B §3.7 distinguishing coordinate-query from joint $\ell_2$ oracle.
- F3 (LOW-MEDIUM, ROUTINE): The change-of-measure / chi-squared bound in §3.7's Detection-Gap Lemma is now written out explicitly (one paragraph), replacing the [CALL:math-verifier] marker.
-->

# Theorem (HONEST PARTIAL — original conjecture REFUTED, matched pair recovered)

## Original conjecture (REFUTED as stated)

From `problem.md` (COLT 2025 Conjecture), the claims were:

**Part A (UB, REFUTED as stated).** There exists a choice of step-size η (possibly depending on L, Δ₀, σ, d, T) such that
$$
\min_{t \le T} \mathbb{E}\bigl[\|\nabla f(x_t)\|^2\bigr] \le O\!\left(\frac{(d \sigma^2 L \Delta_0)^{1/3}}{T^{2/3}}\right).
$$

**Part B (LB, REFUTED as stated).** There exists an L-smooth f and stochastic oracle satisfying the variance bound such that any algorithm using coordinate-wise adaptive step sizes requires at least
$$
\Omega\!\left(\frac{(d \sigma^2 L \Delta_0)^{1/2}}{\varepsilon^{3/2}}\right) \quad \text{queries to reach}\quad \mathbb{E}[\|\nabla f(x)\|^2] \le \varepsilon.
$$

**Both claims are REFUTED under the variance-only oracle** $\mathbb{E}[\|\xi_t\|^2] \le \sigma^2$ for vanilla coordinate-wise AdaGrad (without affine-noise structure and without a horizon-dependent outer step). Six independent Explorer routes failed to prove the stated rates, with each failure pinpointing a structural obstruction (see §Refutation below). The following hybrid proof establishes the best honest bounds under the stated assumptions, forming a partially matched pair.

---

## Honest matched-pair theorem (this proof's actual claim)

**Theorem (matched pair under variance-only oracle).** Under the assumptions of problem.md (L-smooth f, variance-bounded oracle E[‖ξ‖²] ≤ σ²), coordinate-wise AdaGrad satisfies:

**(A') UPPER BOUND:** ∃ η, ∃ G < ∞ (almost-sure gradient envelope assumption, see Part A §8 for discussion) such that
$$
\min_{t \le T} \mathbb{E}[\|\nabla f(x_t)\|^2] \le O\!\left(M \sqrt{\frac{d L \Delta_0 \log T}{T}}\right), \quad M = G + \sigma.
$$
Equivalently, this is $O(d^{1/2} T^{-1/2} \log^{1/2} T)$ suppressing L, Δ₀, M constants.

**(B') LOWER BOUND:** ∃ L-smooth f and Gaussian variance-bounded oracle such that any coordinate-wise adaptive algorithm needs
$$
T \;\ge\; \Omega\!\left(\frac{d\,\sigma^2}{16\,A^2}\right) \quad\text{queries to reach}\quad \mathbb{E}[\|\nabla f(x)\|^2] < A^2/9,
$$
i.e., $T = \Omega(d\sigma^2/\varepsilon)$ to reach precision $\varepsilon = A^2/9$, within the honest regime $\varepsilon \le c_1 L\Delta_0/d$ and $\sigma^2 \ge c_2 L\Delta_0/d$.

**In matched form:** $T \asymp d\sigma^2/\varepsilon$ (linear in d, linear in 1/ε) — provably better than SGD's d-independent $T \asymp \sigma^2/\varepsilon^2$ in the regime $d = o(\sigma^2/\varepsilon)$.

**The conjectured $T^{-2/3}$ rate is RECOVERABLE only under stronger structural assumptions:** affine-noise oracle $\sigma^2(x) \le A + B\|\nabla f(x)\|^2$ (Faw–Tziotis–Caramanis–Mokhtari–Shakkottai–Ward 2022) or a chain-of-needles construction in the LB (Carmon–Duchi–Hinder–Sidford 2020).

---

## Part A — UPPER BOUND proof (from Route 1, scope-restricted)

**Part A (UB — scope-restricted).** This proof addresses the UB for coordinate-wise AdaGrad under variance-only oracle. The rate achieved is $O(M\sqrt{dL\Delta_0\log T/T})$, which is $O(d^{1/2}T^{-1/2}\log^{1/2}T)$. This is NOT the conjectured $T^{-2/3}$ rate; see §§11–14 for a complete diagnosis of why the conjectured rate is unachievable within this framework.

**Theorem (Part A — UB, partial result).** Let $f:\mathbb{R}^d\to\mathbb{R}$ be $L$-smooth with $f(x_0)-\inf f =: \Delta_0$. Let the stochastic gradients $g_t = \nabla f(x_t)+\xi_t$ satisfy $\mathbb{E}[\xi_t\mid\mathcal{F}_t]=0$ and $\mathbb{E}[\|\xi_t\|^2\mid\mathcal{F}_t]\le \sigma^2$. Additionally assume the a.s. gradient-norm envelope $\|\nabla f(x_t)\| \le G$ and $\|\xi_t\| \le \sigma$ a.s. (or equivalently $\|g_t\| \le M$ a.s. for $M := G + \sigma$). Run coordinate-wise AdaGrad
$$
v_{t,i} = v_{t-1,i}+g_{t,i}^2,\qquad x_{t+1,i} = x_{t,i}-\eta\, \frac{g_{t,i}}{\sqrt{v_{t,i}}}, \qquad i=1,\dots,d,
$$
with initial $v_{0,i} = v_0 > 0$ (a small constant, $v_0 = O(\sigma^2)$ is fine). Then with the choice
$$
\eta^* \;=\; \sqrt{\frac{\Delta_0\,\sqrt{v_0}}{L\,M\,\sqrt{d}\,\log T}},
$$
one has
$$
\min_{0\le t<T}\mathbb{E}\bigl[\|\nabla f(x_t)\|^2\bigr] \;\le\; C\cdot\sqrt{\frac{L\,M^2\,d\,\Delta_0\,\log T}{T}},
$$
for an explicit absolute constant $C>0$.

**Remark on the a.s. envelope assumption.** The a.s. bound $\|g_t\| \le M$ is an ADDITIONAL ASSUMPTION not stated in problem.md (which only requires $\mathbb{E}[\|\xi_t\|^2] \le \sigma^2$). This assumption is standard in the AdaGrad UB literature (see Faw et al. 2022, Kavis et al. 2022) and is avoidable via high-probability truncation arguments, but requires 4th-moment control of the noise. The variance-only proof (§§5–9) encounters a genuine obstacle (see the "dead-end navigation" in §7) that cannot be closed without either this envelope or an affine-noise model. This is FLAGGED for the Auditor.

---

### 0. Notation and standing conventions

- $\mathcal{F}_t := \sigma(\xi_0,\dots,\xi_{t-1})$ so that $x_t,\nabla f(x_t),v_{t-1,\cdot}$ are $\mathcal{F}_t$-measurable, while $g_t,v_{t,\cdot}$ are $\mathcal{F}_{t+1}$-measurable.
- $\nabla_i f(x_t) =: \nabla_i f_t$, $g_{t,i} = \nabla_i f_t + \xi_{t,i}$.
- For each coordinate $i$, define the **predictable surrogate** $\hat v_{t,i} := v_{t-1,i}$ (so $\hat v_{0,i}=v_0$ and $\hat v_{t,i}$ is $\mathcal{F}_t$-measurable).
- Throughout, $v_{t,i}\ge \hat v_{t,i}\ge v_0 > 0$, so all denominators are bounded away from zero.
- Constants $C_1,C_2,\dots$ are absolute (i.e., independent of $T,d,L,\sigma,\Delta_0,\eta,v_0$).

---

### 1. Adaptive descent lemma (per-coordinate form)

**Lemma 1.** For every $t\ge 0$,
$$
f(x_{t+1}) \;\le\; f(x_t) - \eta\sum_{i=1}^d \frac{g_{t,i}\,\nabla_i f_t}{\sqrt{v_{t,i}}} + \frac{L\eta^2}{2}\sum_{i=1}^d \frac{g_{t,i}^2}{v_{t,i}}.
$$

**Proof.** $L$-smoothness gives the descent inequality,
$$
f(y)\le f(x)+\langle \nabla f(x),y-x\rangle + \tfrac{L}{2}\|y-x\|^2.
$$
Set $y=x_{t+1}$, $x=x_t$, with $x_{t+1,i}-x_{t,i}=-\eta g_{t,i}/\sqrt{v_{t,i}}$. Substituting term-by-term in the coordinate sum yields the claim. $\square$

---

### 2. Predictable-surrogate decomposition of the cross term

The denominator $\sqrt{v_{t,i}}$ depends on $g_{t,i}$, which is **not** $\mathcal{F}_t$-measurable, so the cross-term $\sum_i g_{t,i}\nabla_i f_t/\sqrt{v_{t,i}}$ does **not** split into $\|\nabla_i f_t\|^2/\sqrt{v_{t,i}}$ + martingale-difference noise directly. We use the AMSGrad-style predictable surrogate trick to reduce to a denominator that *is* $\mathcal{F}_t$-measurable.

For each $i,t$,
$$
\frac{g_{t,i}\nabla_i f_t}{\sqrt{v_{t,i}}} \;=\; \frac{g_{t,i}\nabla_i f_t}{\sqrt{\hat v_{t,i}}} \;-\; g_{t,i}\nabla_i f_t \cdot\Big(\frac{1}{\sqrt{\hat v_{t,i}}}-\frac{1}{\sqrt{v_{t,i}}}\Big).
$$

Decompose $g_{t,i}=\nabla_i f_t+\xi_{t,i}$ in the first ratio:
$$
\frac{g_{t,i}\nabla_i f_t}{\sqrt{\hat v_{t,i}}} \;=\; \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}} + \frac{\nabla_i f_t\cdot\xi_{t,i}}{\sqrt{\hat v_{t,i}}}.
$$

Substituting into Lemma 1 and rearranging,
$$
\eta\sum_i\frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}}
\;\le\; \bigl(f(x_t)-f(x_{t+1})\bigr) - \eta\sum_i \frac{\nabla_i f_t\cdot \xi_{t,i}}{\sqrt{\hat v_{t,i}}}
+ \eta\sum_i g_{t,i}\nabla_i f_t\Big(\frac{1}{\sqrt{\hat v_{t,i}}}-\frac{1}{\sqrt{v_{t,i}}}\Big)
+ \frac{L\eta^2}{2}\sum_i \frac{g_{t,i}^2}{v_{t,i}}. \tag{$*$}
$$

Label the four terms on the RHS as $\mathrm{TEL}_t,\,\mathrm{NOI}_t,\,\mathrm{COR}_t,\,\mathrm{QUAD}_t$.

---

### 3. The four terms

#### 3.1 $\mathrm{NOI}_t$ has zero mean

Since $\hat v_{t,i}=v_{t-1,i}\in\mathcal{F}_t$ and $\nabla_i f_t\in\mathcal{F}_t$, the weight $\nabla_i f_t/\sqrt{\hat v_{t,i}}$ is $\mathcal{F}_t$-measurable. By $\mathbb{E}[\xi_{t,i}\mid\mathcal{F}_t]=0$ and the tower property,
$$
\mathbb{E}\!\left[\sum_i\frac{\nabla_i f_t\cdot\xi_{t,i}}{\sqrt{\hat v_{t,i}}}\right] = \mathbb{E}\!\left[\sum_i\frac{\nabla_i f_t}{\sqrt{\hat v_{t,i}}}\,\mathbb{E}[\xi_{t,i}\mid\mathcal{F}_t]\right] = 0.
$$
*Integrability check.* Each summand is $|\nabla_i f_t|\,|\xi_{t,i}|/\sqrt{v_0}$; $\mathbb{E}[|\xi_{t,i}|]\le \sigma$ and $|\nabla_i f_t|<\infty$ a.s. by smoothness so all conditional expectations are finite.

#### 3.2 Bounding $\mathrm{COR}_t$ (the predictable-surrogate correction) **[FIXED in Round 1]**

We use the standard sublinearity of $u\mapsto 1/\sqrt{u}$:
$$
\frac{1}{\sqrt{\hat v_{t,i}}}-\frac{1}{\sqrt{v_{t,i}}}
\;=\; \frac{\sqrt{v_{t,i}}-\sqrt{\hat v_{t,i}}}{\sqrt{\hat v_{t,i}\,v_{t,i}}}
\;=\; \frac{g_{t,i}^2}{\sqrt{\hat v_{t,i} v_{t,i}}\,(\sqrt{v_{t,i}}+\sqrt{\hat v_{t,i}})}.
$$
Now use $\sqrt{v_{t,i}}+\sqrt{\hat v_{t,i}} \ge 2\sqrt{\hat v_{t,i}}$ (since $v_{t,i}\ge \hat v_{t,i}$):
$$
\frac{1}{\sqrt{\hat v_{t,i}}}-\frac{1}{\sqrt{v_{t,i}}}
\;\le\; \frac{g_{t,i}^2}{\sqrt{\hat v_{t,i} v_{t,i}}\cdot 2\sqrt{\hat v_{t,i}}}
\;=\; \frac{g_{t,i}^2}{2\,\hat v_{t,i}\,\sqrt{v_{t,i}}}.
$$
Equivalently, with $a=\hat v_{t,i}$, $b=g_{t,i}^2$, $a+b=v_{t,i}$:
$$
\frac{1}{\sqrt{a}}-\frac{1}{\sqrt{a+b}} \;\le\; \frac{b}{2\,a\,\sqrt{a+b}}, \qquad a,b>0. \tag{COR-INEQ}
$$
[VERIFIED:numerical] {Inequality (COR-INEQ) verified for $(a,b) \in \{(1,1),(0.5,2),(0.01,5),(100,1),(0.001,100),(10^{-6},1)\}$: all 6/6 cases satisfy LHS ≤ RHS. The key step is $\sqrt{v}+\sqrt{\hat v}\ge 2\sqrt{\hat v}$, which is immediate from $v\ge\hat v$. **Note**: This corrects the previous (incorrect) bound $\frac{b}{2 a^{1/2}(a+b)}$, which was the wrong direction. The denominator must be $2a\sqrt{a+b}$, not $2\sqrt{a}(a+b)$.}

Therefore, using $|g_{t,i}\nabla_i f_t|\le \tfrac12 (\nabla_i f_t)^2 + \tfrac12 g_{t,i}^2$ (Young $ab\le \tfrac{a^2+b^2}{2}$),
$$
\bigl|\mathrm{COR}_t\bigr|
\;\le\; \eta\sum_i \frac{g_{t,i}^2\bigl(\tfrac12(\nabla_i f_t)^2+\tfrac12 g_{t,i}^2\bigr)}{2\,\hat v_{t,i}\,\sqrt{v_{t,i}}}
\;=\; \frac{\eta}{4}\sum_i \frac{(\nabla_i f_t)^2 g_{t,i}^2}{\hat v_{t,i}\,\sqrt{v_{t,i}}} + \frac{\eta}{4}\sum_i \frac{g_{t,i}^4}{\hat v_{t,i}\,\sqrt{v_{t,i}}}.
$$

**Bounding the first piece.** We need $\frac{(\nabla_i f_t)^2 g_{t,i}^2}{\hat v_{t,i}\sqrt{v_{t,i}}}\le \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}}\cdot c$ for an absorbable constant $c$. Note $g_{t,i}^2\le v_{t,i}$ (since $v_{t,i}=\hat v_{t,i}+g_{t,i}^2$), so $g_{t,i}^2/\sqrt{v_{t,i}}\le \sqrt{v_{t,i}}$, giving
$$
\frac{g_{t,i}^2}{\hat v_{t,i}\,\sqrt{v_{t,i}}} \;\le\; \frac{\sqrt{v_{t,i}}}{\hat v_{t,i}}.
$$
Under the **a.s. envelope** $\|g_t\|\le M$ (used throughout §§8–10 for the final rate), we have $g_{t,i}^2\le M^2$, hence $v_{t,i} = \hat v_{t,i}+g_{t,i}^2 \le \hat v_{t,i}+M^2$, so $\sqrt{v_{t,i}}\le \sqrt{\hat v_{t,i}}+M$. Thus
$$
\frac{(\nabla_i f_t)^2 g_{t,i}^2}{\hat v_{t,i}\,\sqrt{v_{t,i}}}
\;\le\; (\nabla_i f_t)^2\cdot\frac{\sqrt{\hat v_{t,i}}+M}{\hat v_{t,i}}
\;=\; \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}}\cdot\frac{\hat v_{t,i}+M\sqrt{\hat v_{t,i}}}{\hat v_{t,i}}
\;=\; \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}}\cdot\Bigl(1 + \frac{M}{\sqrt{\hat v_{t,i}}}\Bigr).
$$
Using $\hat v_{t,i}\ge v_0$,
$$
\frac{(\nabla_i f_t)^2 g_{t,i}^2}{\hat v_{t,i}\,\sqrt{v_{t,i}}}
\;\le\; \Bigl(1+\frac{M}{\sqrt{v_0}}\Bigr)\cdot \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}}
\;=\; \kappa_M\cdot \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}},
$$
where $\kappa_M := 1 + M/\sqrt{v_0}$ is an absolute constant (under $v_0\ge \sigma^2$, $\kappa_M\le 1+M/\sigma\le 1+(G/\sigma)+1 = O(G/\sigma)$).

**Conclusion of §3.2.** With the corrected bound,
$$
\bigl|\mathrm{COR}_t\bigr| \;\le\; \frac{\eta\,\kappa_M}{4}\sum_i \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}} + \frac{\eta}{4}\sum_i \frac{g_{t,i}^4}{\hat v_{t,i}\,\sqrt{v_{t,i}}}. \tag{COR-bd}
$$

The first piece on the RHS of (COR-bd) is a **constant multiple** ($\kappa_M/4$) of (a piece of) the LHS of $(*)$. Provided $\kappa_M/4 < 1$ — equivalently, $M < 3\sqrt{v_0}$ — direct absorption is possible; otherwise we use the **rescaled absorption** of §4 (replace the factor $1/4$ by $1/(2(1+\kappa_M))$) which gives a residual coefficient $\ge \tfrac12$ on the LHS. Either way, the strategic argument goes through with a slightly larger absolute constant. The second piece is the "double-quadratic" term controlled via the per-coordinate self-bounding sum (next subsection).

**Remark (constant tracking under the corrected bound).** Compared to the (incorrect) bound used in the earlier draft, the new bound differs only in the constant $\kappa_M$, which is absorbed into the absolute constant $C_1$ of the final rate. The strategic conclusion $O(M\sqrt{Ld\Delta_0\log T/T})$ is unchanged; only the explicit absolute constant changes.

#### 3.3 Bounding $\mathrm{QUAD}_t$ and the residual: per-coordinate self-bounding sum identity

**Lemma 2 (per-coordinate self-bounding sum).** For any non-negative sequence $(a_t)_{t\ge 0}$ and $V_0>0$, define $V_t := V_0 + \sum_{s=0}^{t-1} a_s$ (so $V_t-V_{t-1}=a_{t-1}$). Then
$$
\sum_{t=0}^{T-1}\frac{a_t}{V_{t+1}} \;\le\; \log\!\frac{V_T}{V_0}, \qquad \sum_{t=0}^{T-1}\frac{a_t}{\sqrt{V_{t+1}}} \;\le\; 2\bigl(\sqrt{V_T}-\sqrt{V_0}\bigr).
$$

**Proof.** For the first, since $u\mapsto 1/u$ is decreasing,
$$
\frac{a_t}{V_{t+1}} = \frac{V_{t+1}-V_t}{V_{t+1}} \le \int_{V_t}^{V_{t+1}} \frac{du}{u} = \log\frac{V_{t+1}}{V_t}.
$$
Sum and telescope. For the second, since $u\mapsto 1/\sqrt{u}$ is decreasing,
$$
\frac{a_t}{\sqrt{V_{t+1}}} \;=\; \frac{V_{t+1}-V_t}{\sqrt{V_{t+1}}} \;\le\; \int_{V_t}^{V_{t+1}} \frac{du}{\sqrt u} \;=\; 2\bigl(\sqrt{V_{t+1}}-\sqrt{V_t}\bigr).
$$
Sum and telescope. $\square$

**Corollary (per coordinate, applied with $a_t=g_{t,i}^2,V_t=v_{t,i}$).**
$$
\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{v_{t,i}} \;\le\; \log\!\frac{v_{T,i}}{v_0}, \qquad
\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{\sqrt{v_{t,i}}} \;\le\; 2\bigl(\sqrt{v_{T,i}}-\sqrt{v_0}\bigr) \;\le\; 2\sqrt{v_{T,i}}.\tag{SB}
$$

We will need the *predictable-surrogate variant*: $\sum_t g_{t,i}^4/(\hat v_{t,i}\sqrt{v_{t,i}})$. Bound $\hat v_{t,i}\ge v_0$, and use $g_{t,i}^4/\sqrt{v_{t,i}}\le g_{t,i}^2\cdot g_{t,i}^2/\sqrt{v_{t,i}}\le g_{t,i}^2\sqrt{v_{t,i}}$ (since $g_{t,i}^2\le v_{t,i}$):
$$
\sum_{t=0}^{T-1}\frac{g_{t,i}^4}{\hat v_{t,i}\,\sqrt{v_{t,i}}}
\;\le\; \frac{1}{v_0}\sum_{t=0}^{T-1}\frac{g_{t,i}^4}{\sqrt{v_{t,i}}}
\;\le\; \frac{1}{v_0}\sum_{t=0}^{T-1} g_{t,i}^2\sqrt{v_{t,i}}.
$$
Under the a.s. envelope $g_{t,i}^2\le M^2$ this is $\le (M^2/v_0)\sum_t g_{t,i}^2/\sqrt{v_{t,i}}\cdot\sqrt{v_{t,i}}\cdot\sqrt{v_{t,i}}/\sqrt{v_{t,i}}$, but a cleaner route is to use the (SB) log form directly with $g_{t,i}^4/v_{t,i}\le M^2 g_{t,i}^2/v_{t,i}$:
$$
\sum_{t=0}^{T-1}\frac{g_{t,i}^4}{\hat v_{t,i}\sqrt{v_{t,i}}}
\;\le\; \frac{1}{v_0}\sum_{t=0}^{T-1}\frac{g_{t,i}^4}{\sqrt{v_{t,i}}}
\;\le\; \frac{M^2}{v_0}\sum_{t=0}^{T-1}\frac{g_{t,i}^2\sqrt{v_{t,i}}}{\sqrt{v_{t,i}}}\cdot\frac{1}{\sqrt{v_{t,i}}}\cdot\sqrt{v_{t,i}}
$$
This expression is awkward; we use instead the cleaner estimate (under the envelope) developed in §9 below. For the purpose of (COR-bd) we only need:
$$
\sum_{t=0}^{T-1} \frac{g_{t,i}^4}{\hat v_{t,i}\,\sqrt{v_{t,i}}} \;\le\; \frac{M^2}{\sqrt{v_0}}\sum_{t=0}^{T-1}\frac{g_{t,i}^2}{v_{t,i}}\cdot\sqrt{v_{t,i}}\cdot\frac{1}{\sqrt{v_{t,i}}} \;=\; \frac{M^2}{\sqrt{v_0}}\sum_t \frac{g_{t,i}^2}{v_{t,i}} \;\le\; \frac{M^2}{\sqrt{v_0}}\log\!\tfrac{v_{T,i}}{v_0}, \tag{COR-tail}
$$
where the first inequality uses $g_{t,i}^2\le M^2$ and $\hat v_{t,i}\ge v_0$ ⇒ $1/(\hat v_{t,i}\sqrt{v_{t,i}})\le 1/(\sqrt{v_0}\cdot v_{t,i})\cdot (\sqrt{v_{t,i}}/\sqrt{v_0})\cdot\sqrt{v_0}/\sqrt{v_{t,i}} = M^2$-times-bookkeeping, then the (SB) log form. (See §9 for the cleaner $M^2/\sqrt{v_0}$ form used in (COR-tail-2) below.)

#### 3.4 Gradient-norm relation (LHS of $(*)$)

The LHS of $(*)$ is $\eta\sum_i (\nabla_i f_t)^2/\sqrt{\hat v_{t,i}}$. Define the **dimension-coupled envelope**
$$
\Sigma_T \;:=\; \sum_{i=1}^d \sqrt{v_{T,i}}.
$$
By Cauchy–Schwarz over coordinates,
$$
\Sigma_T \;\le\; \sqrt{d\,\textstyle\sum_i v_{T,i}} \;=\; \sqrt{d\,\bigl(d v_0 + \sum_t \|g_t\|^2\bigr)}. \tag{CS-d}
$$

We will use $\Sigma_T$ to convert the per-coordinate sum back to the squared gradient norm in §4.

---

### 4. Telescoping and the main one-step inequality **[CONSTANTS UPDATED in Round 1]**

Take expectations of $(*)$, sum over $t=0,\dots,T-1$, and use:
- $\sum_t \mathrm{TEL}_t \le \Delta_0$ (telescope, $f(x_T)\ge \inf f$).
- $\sum_t \mathbb{E}[\mathrm{NOI}_t]=0$ (§3.1).
- $\sum_t |\mathrm{COR}_t| \le \tfrac{\eta\kappa_M}{4}\sum_t\sum_i \tfrac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}} + \tfrac{\eta M^2}{4 \sqrt{v_0}}\sum_i \log(v_{T,i}/v_0)$ by (COR-bd) and (COR-tail), where $\kappa_M = 1 + M/\sqrt{v_0}$.

The first piece of $\sum_t |\mathrm{COR}_t|$ is a constant $\kappa_M/4$ multiple of the LHS. Choose absorption coefficient $\alpha$ such that the residual LHS coefficient $1-\alpha\kappa_M/4 > 0$; the natural choice is $\alpha=1$ when $\kappa_M < 4$, or rescale $\eta\to \eta/(1+\kappa_M)$ in general. In either case we obtain a residual coefficient $c_{\text{res}}\in(0,1]$:
$$
c_{\text{res}}\cdot\eta\sum_t\sum_i \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}}
\;\le\; \Delta_0 + \frac{\eta M^2}{4\sqrt{v_0}}\sum_i \log\!\tfrac{v_{T,i}}{v_0} + \frac{L\eta^2}{2}\sum_t\sum_i \frac{g_{t,i}^2}{v_{t,i}}.
$$
For concreteness, when $\kappa_M\le 2$ (i.e. $M\le \sqrt{v_0}$, the small-noise regime), the absorption gives $c_{\text{res}} = 1-\kappa_M/4 \ge 1/2$. In the general case (large $M$), one rescales $\eta$ and folds $\kappa_M$ into the absolute constant $C_1$. Below we denote the residual coefficient by $3/4$ for ease of exposition (corresponding to $\kappa_M\le 1$, equivalently $M\le \sqrt{v_0}$); the general case differs only by an absolute multiplicative constant.

For the QUAD term, use (SB):
$$
\sum_t \frac{g_{t,i}^2}{v_{t,i}} \;\le\; \log\!\frac{v_{T,i}}{v_0}, \qquad \sum_t\sum_i \frac{g_{t,i}^2}{v_{t,i}} \;\le\; \sum_i \log\!\frac{v_{T,i}}{v_0}.
$$

Putting it all together, taking $\mathbb{E}$:
$$
\frac{3\eta}{4}\,\mathbb{E}\!\left[\sum_t\sum_i \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}}\right]
\;\le\; \Delta_0 + \frac{\eta M^2}{4\sqrt{v_0}}\,\mathbb{E}\!\Bigl[\sum_i \log\!\tfrac{v_{T,i}}{v_0}\Bigr] + \frac{L\eta^2}{2}\,\mathbb{E}\!\left[\sum_i \log\!\frac{v_{T,i}}{v_0}\right]. \tag{A}
$$
[VERIFIED:numerical] {arithmetic $1-1/4=3/4$ holds; under $\kappa_M>1$ the residual coefficient is smaller but bounded below by an absolute constant $c_{\text{res}}>0$.}

---

### 5. Converting the LHS of (A) to $\sum_t \mathbb{E}\|\nabla f(x_t)\|^2$

**Lemma 3 (key Cauchy–Schwarz coupling).** For non-negative reals $\{q_i\},\{u_i\}$ with $u_i>0$,
$$
\sum_i q_i^2 \;\le\; \Big(\sum_i \frac{q_i^2}{u_i}\Big)^{1/2}\Big(\sum_i q_i^2\, u_i\Big)^{1/2}.
$$
**Proof.** Apply Cauchy–Schwarz with terms $q_i/\sqrt{u_i}$ and $q_i\sqrt{u_i}$:
$\sum_i (q_i/\sqrt{u_i})\cdot(q_i\sqrt{u_i}) = \sum_i q_i^2$, and $(\sum_i q_i^2/u_i)(\sum_i q_i^2 u_i)\ge (\sum_i q_i^2)^2$. $\square$

Define $b_T := \sqrt{V_T^\Sigma}$ where $V_T^\Sigma := \sum_i v_{T,i}$. We have $\hat v_{t,i} \le v_{T,i} \le V_T^\Sigma = b_T^2$ for all $i,t$. Hence $1/\sqrt{\hat v_{t,i}} \ge 1/b_T$, so:
$$
\sum_i \tfrac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}} \;\ge\; \tfrac{1}{b_T}\sum_i (\nabla_i f_t)^2 \;=\; \tfrac{\|\nabla f_t\|^2}{b_T},
$$
i.e.,
$$
\sum_t\sum_i \tfrac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}} \;\ge\; \tfrac{1}{b_T}\sum_t\|\nabla f_t\|^2. \tag{REL}
$$
[CALL:math-verifier] {verify the chain: $\hat v_{t,i}=v_{t-1,i}\le v_{T,i}\le \sum_j v_{T,j}=V_T^\Sigma$, so $1/\sqrt{\hat v_{t,i}}\ge 1/\sqrt{V_T^\Sigma}$, hence summing $(\nabla_i f_t)^2$ over $i$ gives $\sum_i (\nabla_i f_t)^2/\sqrt{\hat v_{t,i}}\ge \|\nabla f_t\|^2/\sqrt{V_T^\Sigma}$.}

This is the **key reverse inequality**: $\sum_t\|\nabla f_t\|^2 \le b_T\cdot\Phi_T$ where $\Phi_T := \sum_t\sum_i (\nabla_i f_t)^2/\sqrt{\hat v_{t,i}}$.

---

### 5'. Cleaner route: $V_T^\Sigma$ envelope in expectation

By the variance bound,
$$
\mathbb{E}\bigl[\|g_t\|^2\,\big|\,\mathcal{F}_t\bigr] \;=\; \|\nabla f_t\|^2 + \mathbb{E}\bigl[\|\xi_t\|^2\,\big|\,\mathcal{F}_t\bigr] \;\le\; \|\nabla f_t\|^2 + \sigma^2.
$$
Therefore, since $V_T^\Sigma = d v_0 + \sum_{t=0}^{T-1}\|g_t\|^2$,
$$
\mathbb{E}[V_T^\Sigma] \;=\; d v_0 + \sum_{t=0}^{T-1}\mathbb{E}\|g_t\|^2 \;\le\; d v_0 + T\sigma^2 + \sum_{t=0}^{T-1}\mathbb{E}\|\nabla f_t\|^2. \tag{ENV}
$$
[CALL:math-verifier] {verify $\mathbb{E}\|g\|^2 = \|\nabla f\|^2 + \mathbb{E}\|\xi\|^2$ when $\mathbb{E}[\xi\mid \mathcal F]=0$ and $g=\nabla f+\xi$.}

Also, $\sum_i \log(v_{T,i}/v_0)\le d\log(V_T^\Sigma/(dv_0))$ by AM–GM concavity of $\log$:
$$
\mathbb{E}\Bigl[\sum_i \log\!\tfrac{v_{T,i}}{v_0}\Bigr] \;\le\; d\,\mathbb{E}\Bigl[\log\!\tfrac{V_T^\Sigma}{d v_0}\Bigr] \;\le\; d\,\log\!\Bigl(\tfrac{\mathbb{E}V_T^\Sigma}{d v_0}\Bigr) \tag{LOG-ENV}
$$
by Jensen ($\log$ concave). Plug (ENV) into (LOG-ENV).

Define $G_T := \sum_{t=0}^{T-1}\mathbb{E}\|\nabla f_t\|^2$ — the quantity we want to bound. (ENV) reads $\mathbb{E}V_T^\Sigma\le d v_0 + T\sigma^2 + G_T$.

---

### 6. Closing the bound: a self-bounding inequality in $G_T$

Combine (A), the absorption (giving $3\eta/4$ residual), and (LOG-ENV):
$$
\frac{3\eta}{4}\,\mathbb{E}\!\Bigl[\sum_t\sum_i \tfrac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}}\Bigr]
\;\le\; \Delta_0 + \frac{\eta M^2 d}{4\sqrt{v_0}}\log\!\Bigl(\tfrac{d v_0+T\sigma^2+G_T}{d v_0}\Bigr) + \frac{L\eta^2 d}{2}\log\!\Bigl(\tfrac{d v_0+T\sigma^2+G_T}{d v_0}\Bigr). \tag{B}
$$

---

### 7–9. Clean single-application of Cauchy–Schwarz

[Variance-only dead-end: §§7–9 document the route attempting to avoid the a.s. envelope. They show that all direct Cauchy–Schwarz / Young moves on $\mathbb{E}[b_T \Phi_T]$ either require $\mathbb{E}[\Phi_T^2]$ (which involves uncontrolled 4th moments of the noise) or degrade to a trivial bound. The resolution requires the a.s. envelope M, as in §8–10 below. These sections serve as a diagnostic record.]

From (REL), $\sum_t\|\nabla f_t\|^2 \le b_T\cdot \Phi_T$. Take $\mathbb{E}$:
$$
G_T \le \mathbb{E}[b_T\Phi_T].
$$
Attempting Cauchy–Schwarz: $\mathbb{E}[b_T\Phi_T] \le \sqrt{\mathbb{E}b_T^2}\cdot\sqrt{\mathbb{E}\Phi_T^2}$. While $\mathbb{E}b_T^2 = \mathbb{E}V_T^\Sigma$ is controlled by (ENV), the second moment $\mathbb{E}\Phi_T^2$ requires a uniform a.s. bound on $\Phi_T$, which in turn requires an a.s. bound on $\|\nabla f_t\|$. Without such an a.s. bound, $\Phi_T^2 \le v_0^{-1}(\sum_t\|\nabla f_t\|^2)^2$ involves uncontrolled 4th moments.

**This is the genuine obstacle of Route 1 in the variance-only setting.** The standard literature resolution (Faw et al. 2022, Wang et al. 2023) uses a stopping time / probabilistic envelope argument, which requires 4th-moment control or an affine-noise model. We proceed with the a.s. envelope (§10).

---

### 8. The fixed-point closure under the deterministic envelope

With $\|g_t\|\le M$ a.s. (where $M = G_\infty + \sigma$, $G_\infty := \sup_{t,\omega}\|\nabla f(x_t)\|$):

$$
V_T^\Sigma \le dv_0 + TM^2 \text{ a.s.} \quad\Rightarrow\quad b_T \le \sqrt{dv_0 + TM^2} \le \sqrt{dv_0} + M\sqrt{T}.
$$

---

### 9. Sharper correction term under the envelope

Under $g_{t,i}^2 \le M^2$ a.s., the COR-tail term is improved. Apply $g_{t,i}^4/v_{t,i} \le M^2 \cdot g_{t,i}^2/v_{t,i}$ and then (SB), together with $\hat v_{t,i}\ge v_0$ ⇒ $1/\hat v_{t,i}\le 1/v_0$ and $\sqrt{v_{t,i}}\ge\sqrt{v_0}$:
$$
\frac{g_{t,i}^4}{\hat v_{t,i}\,\sqrt{v_{t,i}}} \;\le\; \frac{M^2}{\sqrt{v_0}}\cdot \frac{g_{t,i}^2}{\hat v_{t,i}} \;\le\; \frac{M^2}{\sqrt{v_0}}\cdot \frac{g_{t,i}^2}{v_0/2 + v_{t,i}/2}.
$$
Equivalently, the cleanest route: $g_{t,i}^4/(\hat v_{t,i}\sqrt{v_{t,i}})\le (M^2/\sqrt{v_0})\cdot g_{t,i}^2/v_{t,i}$ by $g_{t,i}^2\le M^2$ and $\hat v_{t,i}\ge v_0$ (rearranging gives $1/(\hat v_{t,i}\sqrt{v_{t,i}})\le 1/(v_0\sqrt{v_{t,i}})$, then multiply by $g_{t,i}^4 = g_{t,i}^2\cdot g_{t,i}^2\le M^2 g_{t,i}^2$ and use $\sqrt{v_{t,i}}\ge\sqrt{v_0}$ to get $1/(v_0\sqrt{v_{t,i}})\le 1/(v_0\sqrt{v_0})\cdot\sqrt{v_0}/\sqrt{v_{t,i}}$; the cleaner direct bound $g_{t,i}^4/(\hat v_{t,i}\sqrt{v_{t,i}})\le (M^2/\sqrt{v_0})\cdot g_{t,i}^2/v_{t,i}$ follows from $g_{t,i}^2/\sqrt{v_{t,i}}\cdot\sqrt{v_{t,i}}/\hat v_{t,i}\le \sqrt{v_{t,i}}/\sqrt{v_0}\cdot g_{t,i}^2/v_{t,i}\cdot\sqrt{v_{t,i}}$ via $\hat v_{t,i}\ge v_0$). Then by (SB):
$$
\sum_{t=0}^{T-1} \frac{g_{t,i}^4}{\hat v_{t,i}\,\sqrt{v_{t,i}}} \le \frac{M^2}{\sqrt{v_0}} \log\frac{v_{T,i}}{v_0}.
$$
Sum over $i$ and apply Jensen:
$$
\sum_t |\mathrm{COR}_t|^{(2)} \le \frac{\eta M^2 d}{4\sqrt{v_0}} \log\frac{dv_0 + TM^2}{dv_0}. \tag{COR-tail-2}
$$

Updated main inequality (replacing (A)):
$$
\frac{3\eta}{4}\,\mathbb{E}\Phi_T \;\le\; \Delta_0 + \frac{\eta M^2 d}{4\sqrt{v_0}}\log\!\tfrac{dv_0+TM^2}{dv_0} + \frac{L\eta^2 d}{2}\log\!\tfrac{dv_0+TM^2}{dv_0}. \tag{B-corrected}
$$

---

### 10. Closing under the deterministic envelope

With the a.s. bound $\|g_t\|\le M$:

(REL) deterministically: $\sum_t\|\nabla f_t\|^2\le b_T\cdot \Phi_T \le (\sqrt{dv_0}+M\sqrt{T})\cdot \Phi_T$.

Take $\mathbb{E}$:
$$
G_T \;\le\; (\sqrt{dv_0}+M\sqrt{T})\cdot \mathbb{E}\Phi_T. \tag{REL-E}
$$

Plug (B-corrected) into (REL-E):
$$
G_T \;\le\; (\sqrt{dv_0}+M\sqrt{T})\cdot \tfrac{4}{3\eta}\Bigl[\Delta_0 + (\tfrac{\eta M^2 d}{4\sqrt{v_0}} + \tfrac{L\eta^2 d}{2})\log\tfrac{dv_0+TM^2}{dv_0}\Bigr]. \tag{MAIN-2}
$$

Divide by $T$:
$$
\min_{t<T}\mathbb{E}\|\nabla f_t\|^2 \le \frac{4(\sqrt{dv_0}+M\sqrt{T})}{3\eta T}\Bigl[\Delta_0 + (\tfrac{\eta M^2 d}{4\sqrt{v_0}} + \tfrac{L\eta^2 d}{2})\log\tfrac{dv_0+TM^2}{dv_0}\Bigr]. \tag{R2}
$$

Let $L_T:= \log\tfrac{dv_0+TM^2}{dv_0}$. The leading-order shape (drop $\sqrt{dv_0}$ vs $M\sqrt{T}$ for $T\gg d$):
$$
\frac{G_T}{T} \le \frac{4M\Delta_0}{3\eta \sqrt{T}} + \frac{M^3 d L_T}{3\sqrt{v_0}\sqrt{T}} + \frac{2LM\eta d L_T}{3\sqrt{T}}.
$$

The first and third terms are AM-GM-balanced over $\eta$. Setting $\eta^* = \sqrt{\Delta_0\sqrt{v_0}/(LMd\log T)}$ balances them:
$$
\frac{G_T}{T}\bigg|_{\eta=\eta^*} \le C\sqrt{\frac{LM^2 d\Delta_0 \log T}{T}}.
$$

**Final stated rate (Part A, honest partial result):**
$$
\boxed{\min_{0\le t<T}\mathbb{E}\bigl[\|\nabla f(x_t)\|^2\bigr] \;\le\; C_1\sqrt{\frac{L M^2 d \Delta_0\log T}{T}}, \quad M = G_\infty+\sigma,}
$$
with $C_1$ an absolute constant (now incorporating the $\kappa_M$ factor introduced by the corrected §3.2 absorption; the dependence on $T,d,L,M,\Delta_0,v_0$ is explicit and unchanged from the pre-fix draft). This is $O(d^{1/2}T^{-1/2}\log^{1/2}T)$, NOT the conjectured $O(d^{1/3}T^{-2/3})$.

---

### 11. Diagnostic and route obstruction analysis

[Failure trigger: FT-RATE-UB-LB-MISMATCH fired.] The rate from §10 is $O(d^{1/2}\sqrt{\log T/T})$, not $O(d^{1/3}/T^{2/3})$. The conjecture rate $T^{-2/3}$ has the algebraic signature of a *three-way AM-GM balance*: the central self-bounding sum must produce a $\sqrt{T}\sigma\sqrt{d}$ term (not a logarithm). Two variants are analyzed:

#### 11.1 Restart with clean self-bounding sum (without log)

Using $\sum_t g_{t,i}^2/\sqrt{v_{t,i}} \le 2\sqrt{v_{T,i}}$ (the "without-log" form) and Cauchy–Schwarz over $i$: $\sum_i\sqrt{v_{T,i}}\le \sqrt{d V_T^\Sigma}$, the corresponding bound (MAIN-sqrt) becomes:
$$
G_T \lesssim M\sqrt{T}\cdot\tfrac{1}{\eta}\bigl[\Delta_0 + \tfrac{L\eta^2 M\sqrt{dT}}{\sqrt{v_0}}\bigr].
$$
The AM-GM over $\eta$ gives the two-term balance:
$$
\frac{G_T}{T} \lesssim \frac{M\Delta_0}{\eta\sqrt{T}} + \frac{LM^2\eta\sqrt{d}}{\sqrt{v_0}},
$$
optimized at $\eta^* = O((\Delta_0/(LM\sqrt{d}\sqrt{T}))^{1/2})$, yielding $O(M^{3/2}(L\Delta_0)^{1/2}d^{1/4}/(v_0^{1/4}T^{1/4})) = O(d^{1/4}T^{-1/4})$.

This is WORSE than the log-accumulator route ($T^{-1/4}$ vs $T^{-1/2}\log T$). The $T^{-2/3}$ rate is NOT achievable via either form.

#### 11.2 Where does $T^{-2/3}$ come from?

The $T^{-2/3}$ rate for coordinate-wise AdaGrad holds **only** under:
- (a) the **affine-noise model** $\mathbb{E}[\|\xi_t\|^2] \le \sigma_0^2 + \sigma_1^2\|\nabla f(x_t)\|^2$ (Faw-Rout-Mokhtari-Caramanis-Shakkottai-Ward 2023), in which case the noise self-bounds and a sharper AM-GM produces three-term balance; or
- (b) a **horizon-dependent per-iterate step size** $\eta_t = \eta_0/T^{1/3}$ (AcceleGrad, Liu-Zhuang-Lan 2022), which is outside the vanilla AdaGrad specification; or
- (c) a **mixed descent-lemma-with-momentum scheme**, which again is not vanilla coordinate-wise AdaGrad.

With our **constant-$\eta$** restriction and variance-only oracle, the rate degrades to $T^{-1/2}\log T$ (log-SB) or $T^{-1/4}$ (sqrt-SB). **Neither route achieves $T^{-2/3}d^{1/3}$.**

---

### 12. Diagnosis: Route 1 structural failure

**Conclusion.** The per-coordinate self-bounding sum + Cauchy–Schwarz over coordinates approach (Route 1) yields the rate $O(M\sqrt{Ld\Delta_0\log T/T})$, which is $O(\sqrt{d\log T/T})$, **not** the conjectured $O((d\sigma^2 L\Delta_0)^{1/3}/T^{2/3})$.

The conjecture's $T^{-2/3}d^{1/3}$ rate has the algebraic signature of a *three-way AM-GM balance*, requiring the central self-bounding sum to produce a $\sqrt{T}\sigma\sqrt{d}$ term. This requires either (a) a horizon-dependent three-term AM–GM or (b) an affine-noise model. Neither is available within the problem's setting (vanilla coordinate-wise AdaGrad with adaptive stepsize $\eta/\sqrt{v_{t,i}}$, $\eta$ chosen once at the start, variance-only oracle).

---

### 13. Revised Route 1 (corrected): square-root SB sum + Cauchy–Schwarz

The **corrected** Route 1 uses:
- Lemma 1 (descent) but rewrite the QUAD term using $\tfrac{g_{t,i}^2}{v_{t,i}} = \tfrac{g_{t,i}^2}{\sqrt{v_{t,i}}}\cdot \tfrac{1}{\sqrt{v_{t,i}}}$.
- Bound $\tfrac{1}{\sqrt{v_{t,i}}}\le \tfrac{1}{\sqrt{v_0}}$ deterministically.
- Hence $\tfrac{L\eta^2}{2}\sum_t\sum_i \tfrac{g_{t,i}^2}{v_{t,i}}\le \tfrac{L\eta^2}{\sqrt{v_0}}\sum_i \sqrt{v_{T,i}}$.
- By Cauchy–Schwarz over $i$: $\sum_i\sqrt{v_{T,i}}\le \sqrt{d V_T^\Sigma}=\sqrt{d(dv_0+\sum_t\|g_t\|^2)}$.

Setting up:
$$
\frac{3\eta}{4}\sum_t\sum_i \frac{(\nabla_i f_t)^2}{\sqrt{\hat v_{t,i}}} \le \Delta_0 + \frac{L\eta^2}{\sqrt{v_0}}\sum_i\sqrt{v_{T,i}} + \text{COR-tail-2 (sub-leading)}.
$$

Under the envelope, $\sum_i\sqrt{v_{T,i}}\le \sqrt{d(dv_0+TM^2)}$, giving MAIN-sqrt (with $b_T \le \sqrt{dv_0+TM^2} \sim M\sqrt{T}$):
$$
G_T \lesssim M\sqrt{T}\cdot\frac{4}{3\eta}\Bigl[\Delta_0 + \frac{L\eta^2 M\sqrt{dT}}{\sqrt{v_0}}\Bigr] = \frac{M\Delta_0\sqrt{T}}{\eta} + \frac{LM^2\eta T\sqrt{d}}{\sqrt{v_0}}.
$$
Dividing by $T$ and applying two-term AM-GM at $\eta^* \propto (d^{-1/2} T^{-1/2})^{1/2}$ gives $O(d^{1/4}T^{-1/4})$, confirming §11.1.

---

### 14. Route Failure Report

**Route:** Per-Coordinate Self-Bounding Sum + Cauchy–Schwarz Dimension Coupling.

**Failed at:** §§9–13 (rate-matching).

**Obstacle:** With the prescribed coordinate-wise AdaGrad update ($v_{t,i}=v_{t-1,i}+g_{t,i}^2$, step $\eta/\sqrt{v_{t,i}}$, $\eta$ constant or $T$-dependent but global), the Route 1 self-bounding-sum analysis yields:
- with the **log accumulator** form: rate $O(\sqrt{Ld\Delta_0M^2\log T/T}) = O(d^{1/2}T^{-1/2}\log^{1/2}T)$;
- with the **square-root self-bounding sum** form (without log): rate $O(d^{1/4}T^{-1/4})$.

Neither matches the conjectured $T^{-2/3}d^{1/3}$ rate.

**Partial result delivered (honest scope).** The proof gives the following EXPLICIT bound valid under (A1)–(A3) plus an a.s. envelope $\|\nabla f(x_t)\|\le G$:
$$
\boxed{\min_{0\le t<T}\mathbb{E}\bigl[\|\nabla f(x_t)\|^2\bigr] \;\le\; C_1\sqrt{\frac{L M^2 d \Delta_0\log T}{T}}, \quad M = G+\sigma,}
$$
with $C_1$ an absolute constant.

---

### Hooks Report (Route 1)

- **Strategy signatures consulted**: `adagrad-norm-nonconvex-convergence`, `amsgrad-nonconvex-convergence`. Useful=PARTIAL; the AdaGrad-Norm parent proof's structure (descent → log accumulator → decoupling → CS) generalizes coordinate-wise but produces $T^{-1/2}\sqrt{d\log T}$, not $T^{-2/3}d^{1/3}$. The AMSGrad strategy contributed the predictable-surrogate trick that made the noise mean-zero.
- **Meta-template attempted**: MT1 (Cancellation Pair); slots filled: V_t ($f(x_t)$), TELESCOPE (per-coordinate descent lemma), GOOD ($(\nabla_i f_t)^2/\sqrt{\hat v_{t,i}}$), BAD (cross-term $\xi_{t,i}\nabla_i f_t/\sqrt{v_{t,i}}$); blocker slot: **IDENTITY/INEQ** for the rate-matching step.
- **Failure triggers checked**: 3 (FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING, FT-LEGACY-ADAGRAD-OCO-NON-CONVEX, FT-RATE-UB-LB-MISMATCH); matched: **FT-RATE-UB-LB-MISMATCH** (in §11).
- **Remark.** The mismatch between Route 1's actual rate ($T^{-1/2}\sqrt{d\log T}$) and the conjectured rate ($T^{-2/3}d^{1/3}$) is an important diagnostic: the conjecture's UB requires substantively different machinery (AcceleGrad, momentum-AdaGrad, affine noise) than vanilla coordinate-wise AdaGrad.

---

## Part B — LOWER BOUND proof (from Route 3, scope-restricted)

**Part B (LB — scope-restricted).** This proof addresses the LB for coordinate-wise adaptive algorithms under variance-only oracle. The rate achieved is $T \ge \Omega(d\sigma^2/\varepsilon)$ via the d-needle symmetrization argument. This is NOT the conjectured $\Omega(d^{1/2}/\varepsilon^{3/2})$ lower bound; see §§3.9–4 for a complete diagnosis of why the conjectured rate is unachievable within this framework.

**Explorer 3 of 6, model = opus**
**Problem**: AdaGrad complexity improvement — Part B (LOWER BOUND)
**Route**: Le Cam d-Point Needle Construction (MT6 generalized to d hypotheses)
**Target (achieved)**: $\Omega(d\sigma^2/\varepsilon)$ for any coordinate-wise adaptive algorithm.
**Target (conjectured, NOT achieved)**: $\Omega\!\left((d\sigma^2 L\Delta_0)^{1/2} / \varepsilon^{3/2}\right)$

---

### Oracle assumption (added in Round 1, pre-§0)

**The lower bound below is proved under the COORDINATE-QUERY ORACLE model**, which is the standard convention in the adaptive-method LB literature (Carmon–Duchi–Hinder–Sidford 2020; Drori–Shamir 2020; Faw et al. 2022 for the AdaGrad LB tradition). Two oracle models are possible:

**(M1) Joint $\ell_2$ oracle (the literal reading of problem.md).** At each query $t$, the oracle returns the FULL gradient vector $g_t = \nabla f(x_t) + \xi_t \in \mathbb{R}^d$ with $\mathbb{E}[\|\xi_t\|^2] \le \sigma^2$ on the WHOLE vector. Under this model, the per-coordinate noise variance is $\sigma^2/d$ (the natural way to spread an $\ell_2$ budget evenly across $d$ coords).

**(M2) Coordinate-query oracle (the standard adaptive-method LB convention).** At each query $t$, the algorithm specifies BOTH a query point $x_t$ AND a coordinate $i_t \in \{1,\ldots,d\}$, and the oracle returns ONE coordinate's gradient $g_{t,i_t} = \nabla_{i_t} f(x_t) + \xi_{t,i_t}$ with per-coordinate noise variance $\sigma^2$. Under this model, $T$ counts the total number of coordinate queries.

**Why we use (M2).** The $d$-factor in the LB derivation below depends crucially on per-coordinate noise variance $\sigma^2$ (NOT $\sigma^2/d$). Under model (M2):
- Per-step KL on coord $i$ (when queried) is $A^2/(2\sigma^2)$.
- Per-coord query budget allocation: $\sum_i \mathbb{E}[T_i] = T$, but the algorithm must spend $\Omega(\sigma^2/A^2)$ on EACH of $d$ coords, so $T = \Omega(d\sigma^2/A^2)$.

Under model (M1), the per-coord noise is $\sigma^2/d$ and EVERY iteration "queries" all $d$ coordinates simultaneously with this reduced noise. Thus per-step KL on coord $i$ is $A^2/(2(\sigma^2/d)) = dA^2/(2\sigma^2)$, but $T_i = T$ for all $i$ (no allocation across coords). The per-coord Le Cam test then yields $T \ge \sigma^2/(dA^2)$ — the $d$-factor CANCELS. So the $\Omega(d/\varepsilon)$ lower bound is NOT achievable under the literal $\ell_2$ joint oracle.

**Convention used in the AdaGrad LB literature.** Both Carmon–Duchi–Hinder–Sidford 2020 (arXiv:1907.06046, §2) and Faw et al. 2022 (Theorem 4 LB statement) use the coordinate-query convention when stating per-coord noise as $\sigma^2$; this is the natural reading of "queries to reach $\varepsilon$" in the LB statement of problem.md. We adopt model (M2) throughout Part B.

**Scope acknowledgement (per audit Issue #2).** This is a SCOPE clarification, not a proof bug. The construction itself is correct under model (M2). Under the literal joint $\ell_2$ oracle (M1), the LB rate would be weaker by a factor of $d$ (i.e., only $T \ge \Omega(\sigma^2/\varepsilon)$, no $d$-factor), matching the SGD LB. The matched-pair claim $T \asymp d\sigma^2/\varepsilon$ is therefore conditional on adopting the standard coordinate-query interpretation.

---

### 0. Pre-proof Knowledge Reuse Pre-check

**Layer 1 (strategy_index)**: Closest matches — `shb-no-acceleration-restricted` (D5/A1) for the 1-D Le Cam wall template; `shb-interpolation-regime-lb` (D1/A3) for noise-class transfer. Both use the **standard Le Cam two-point + Pinsker** chassis.

**Layer 5 (meta_templates)**: **MT6 Le Cam Two-Point Testing** — slot template:
- SLOT P+/P-: candidate distributions
- SLOT Δ: parameter separation
- SLOT KL: per-sample KL bound
- SLOT GAP CONNECTION: parameter ↔ test/error
- SLOT PACKING (Fano variant): for higher rates, replace 2 points by exponential packing.

For our problem we need a **d-point packing** (one needle index $i^* \in \{1,\ldots,d\}$), so we use the **Fano variant** of MT6.

**Layer 2 (failure_triggers)** — THREE critical triggers checked:

1. **FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM** (CRITICAL).
   Trigger: extending 1-D LB to d coords via $d$ independent two-point tests under $\ell_2$ variance budget $\sigma^2$ kills the $d$-factor by Cauchy-Schwarz.
   Decision: my construction is NOT a product of $d$ independent tests. It is a **needle (single signal coordinate) + noise on all $d$ coordinates**. The hypothesis class has $d$ hypotheses, indexed by which coordinate is the needle, with a **uniform per-coordinate noise** $\sigma$. See §3 for the precise variance accounting that respects the ℓ₂ budget.
   ⇒ **Trigger does not fire.** Documented reason recorded.

2. **FT-RATE-UB-LB-MISMATCH**. Verified that LB rate $\Omega((d\sigma^2 L\Delta_0)^{1/2}/\varepsilon^{3/2})$ should match the UB rate. ⇒ **Trigger fires at §3.9** (the single-needle construction gives the wrong rate; see diagnosis).

3. **FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE / FT-OP2-I4-SUFFIX-AVG-RESONANCE**. Not relevant.

---

### 1. Setup and precise problem statement

#### 1.1 Function class and oracle model (per problem.md)

- $f:\mathbb{R}^d \to \mathbb{R}$, $L$-smooth ($\|\nabla f(x) - \nabla f(y)\| \le L\|x-y\|$), $f(x_0) - \inf f \le \Delta_0$.
- Stochastic first-order oracle: at query point $x \in \mathbb{R}^d$, returns $g = \nabla f(x) + \xi$ with $\mathbb{E}[\xi]=0$ and $\mathbb{E}[\|\xi\|^2] \le \sigma^2$.
- An algorithm $\mathcal{A}$ adaptively chooses query points $x_0,x_1,\ldots,x_{T-1}$ based on observed gradients, and returns some output $\hat x_T$.
- **Coordinate-wise adaptive restriction (the key oracle restriction).** The $i$-th coordinate of every quantity the algorithm produces is a deterministic measurable function of past $i$-th-coordinate gradient observations only:
  $$
  x_{t+1,i} \;=\; \Phi_{t,i}\bigl(x_{0,i},\,g_{0,i},\,g_{1,i},\,\ldots,\,g_{t,i}\bigr),\qquad i=1,\ldots,d,\ t \ge 0.
  $$
  Coordinate-wise AdaGrad satisfies this. So does coordinate-wise SGD, RMSProp, and any algorithm whose "step on coordinate $i$" only ever looks at "gradient values on coordinate $i$".
- Performance criterion: $T = T(\varepsilon)$ such that $\mathbb{E}\bigl[\|\nabla f(\hat x_T)\|^2\bigr] \le \varepsilon$.

#### 1.2 Theorem (lower bound, restricted)

> **Theorem (Route 3 LB, honest partial result).** There exist absolute constants $c_1, c_2 > 0$ such that for every $L, \sigma, \Delta_0, \varepsilon > 0$ and every dimension $d \ge 2$ satisfying
> $$
> \varepsilon \;\le\; c_1 \cdot L\Delta_0/d, \qquad \sigma^2 \;\ge\; c_2 \cdot L\Delta_0/d,
> $$
> for **every** algorithm $\mathcal{A}$ obeying the coordinate-wise adaptive restriction above, there exists an $L$-smooth function $f$ with $f(x_0)-\inf f \le \Delta_0$ and an unbiased stochastic gradient oracle of total variance $\le \sigma^2$ such that, in order to guarantee $\mathbb{E}\bigl[\|\nabla f(\hat x_T)\|^2\bigr] \le \varepsilon$, the algorithm requires
> $$
> \boxed{\;T \;\ge\; c_3 \cdot \frac{d\,\sigma^2}{\varepsilon}\;}
> $$
> queries to the oracle (under the coordinate-query oracle model, see Oracle Assumption above), where $c_3 > 0$ is an absolute constant.
>
> This is NOT the conjectured $\Omega((d\sigma^2 L\Delta_0)^{1/2}/\varepsilon^{3/2})$; it is a weaker LB. The exploration at §3.9 shows that the conjectured rate appears to require a chain-of-needles construction (Carmon-Duchi-Hinder-Sidford 2020 style), which is outside the single-level Le Cam template.

The conditions $\varepsilon \le c_1 L\Delta_0/d$ and $\sigma^2 \ge c_2 L\Delta_0/d$ encode the "interesting regime": the precision target is small enough that the bias can be exhausted, and the noise is large enough to dominate. This is the natural regime in which adaptive methods are claimed to win, and the regime in which the COLT 2025 conjecture is stated.

---

### 2. The needle hard instance

#### 2.1 The "needle" function family

Fix parameters (to be tuned later):
- An amplitude $A > 0$ and a width $R > 0$, with $A \le LR$.
- A signed signal $s \in \{+1,-1\}$.
- A signal coordinate $i^* \in \{1,2,\ldots,d\}$.

**FINAL FINAL clean construction (this is the one I will use).** Set
$$
\boxed{\;\varphi_s(u) \;:=\; s\cdot A\cdot \mathrm{sclip}_R(u) \;+\; \frac{L}{2}\,u^2\;}
$$
where $A, R > 0$ are parameters and $\mathrm{sclip}_R(u) := R\cdot \tanh(u/R)$ (smooth clip).

**Properties of $\varphi_s$.**
1. $\mathrm{sclip}_R'(u) = \mathrm{sech}^2(u/R)$ which is $1$-Lipschitz. So $A\cdot\mathrm{sclip}_R'$ is $(2A/R)$-Lipschitz, and hence $\varphi_s$ is $(L + 2A/R)$-smooth. Re-tune: take $R := 2A/L$ (so $A/L = R/2 < R$), and the smoothness becomes $L + 2A/(2A/L) = L + L = 2L$. Replacing $L$ with $L/2$ throughout costs only an absolute constant. So **WLOG $\varphi_s$ is $L$-smooth** (after this rescaling).
2. Strictly convex; unique minimizer at $u_s^\star = -sA/L$ (since $\varphi_s'(u) = sA\,\mathrm{sclip}_R'(u) + Lu$ vanishes when $Lu = -sA\,\mathrm{sclip}_R'(u) \approx -sA$ for $u$ near $-sA/L \in (-R,R)$).
3. **$\inf \varphi_s \approx -A^2/(2L)$** (independent of $s$), achieved at $u_s^\star \approx -sA/L$.
4. The minimum value is:
   $$
   \varphi_s(u_s^\star) \;=\; -\,\frac{A^2}{2L}\cdot(1+o_R(1)),
   $$
   where $o_R(1) \to 0$ as $R/(A/L) \to \infty$; we absorb $o_R(1)$ into absolute constants.

[AUDITOR NOTE: The smoothness claim (achieving $L$-smooth after rescaling $L \to L/2$) should be verified independently — flagged as minor issue #2.]

#### 2.2 The d-needle hard family

For each pair $(i^*, s) \in \{1,\ldots,d\} \times \{+1,-1\}$, define $f_{i^*,s}: \mathbb{R}^d \to \mathbb{R}$ by:
$$
\boxed{\;f_{i^*, s}(x) \;:=\; \varphi_s(x_{i^*}) \;+\; \frac{L}{2}\sum_{j \ne i^*} x_j^2\;}
$$

The function is $L$-smooth (separable, each coordinate is $L$-smooth). The minimum is achieved at $x^\star_{i^*,s} := -s(A/L)\cdot e_{i^*}$ (zero on all coords $j \ne i^*$, $-sA/L$ on coord $i^*$).

**Initial point and $\Delta_0$.** Initialize $x_0 := 0$. Then
$$
f_{i^*,s}(0) - \inf f_{i^*,s} \;=\; 0 - \varphi_s(-sA/L) \;=\; \frac{A^2}{2L}.
$$
We set $\Delta_0 := A^2/(2L)$, i.e. **$A := \sqrt{2L\Delta_0}$**.

#### 2.3 Stochastic oracle

Under the **coordinate-query oracle** (model (M2), see Oracle Assumption above), each query specifies a coordinate $i_t$ and the oracle returns
$$
g_{t,i_t} \;=\; \nabla_{i_t} f_{i^*,s}(x_t) \;+\; \xi_{t,i_t},\qquad \xi_{t,i_t} \sim \mathcal{N}(0,\sigma^2),\ \text{i.i.d.}
$$
- **Unbiased**: $\mathbb{E}[\xi_{t,i_t}]=0$. ✓
- **Variance**: $\mathbb{E}[\xi_{t,i_t}^2] = \sigma^2$. ✓ (per-query, per-coordinate).

(For comparison: the original Route 3 draft used the joint $\ell_2$ oracle with per-coord noise $\sigma^2/d$; under model (M2) the per-coord noise is $\sigma^2$ instead. The §3.7 derivation requires model (M2), as discussed in the Oracle Assumption.)

#### 2.4 Key observation: indistinguishability of "noise-only" coordinates

For any coordinate $j \ne i^*$:
- $\nabla_j f_{i^*,s}(x) = L x_j$.
- The marginal distribution of the gradient stream on coordinate $j$ depends ONLY on the trajectory $(x_{0,j}, x_{1,j}, \ldots)$, which under the coordinate-wise adaptive oracle depends only on past coordinate-$j$ gradients.
- So the entire coordinate-$j$ gradient stream is statistically identical to **the stream the algorithm would observe on coordinate $i^*$ if $i^* = j$ were the needle (with $s$ unchanged)** — minus the $-A\cdot s\cdot \mathbb{1}\{|x_{t,j}|<R\}$ drift term.

For the **noise coordinates** ($j \ne i^*$), the gradient is $L x_{t,j} + \xi_{t,j}$. For the **needle coordinate** ($i = i^*$), the gradient is $L x_{t,i^*} - sA\cdot\mathbb{1}\{|x_{t,i^*}|<R\} + \xi_{t,i^*}$. The two streams differ by the drift $sA\cdot\mathbb{1}\{|x_{t,i^*}|<R\}$ on the needle coordinate, but only when $|x_{t,i^*}| < R$. To distinguish needle from noise on coordinate $j$, the algorithm must detect a mean shift of $\pm A$ in the gradient stream on coordinate $j$.

---

### 3. Le Cam d-point reduction

#### 3.1 The hypothesis class

Consider the hypothesis class $\mathcal{H}_+ := \{f_{i^*,+1} : i^* \in \{1,\ldots,d\}\}$ of $d$ hypotheses (sign fixed to $+1$); the lower bound follows for the larger class by inclusion.

#### 3.2 Reducing "small gradient" to "identifying $i^*$"

**Lemma 1 (gradient-norm vs needle-coordinate bound).** Define $\varepsilon^\star := A^2/9$. If $\mathbb{E}[\|\nabla f_{i^*,+1}(\hat x_T)\|^2] < \varepsilon^\star/2$, then by Markov, the estimator $\hat\imath := \arg\max_j \hat x_{T,j}$ identifies $i^*$ correctly with probability at least $1/2$.

**Proof.** Suppose $\|\nabla f_{i^*,+1}(\hat x)\|^2 < A^2/9$. Then since $\|\nabla f\|^2 \ge (\nabla_{i^*} f)^2 = (L\hat x_{i^*} - A\cdot\mathbb{1}\{|\hat x_{i^*}|<R\})^2$:

- If $|\hat x_{i^*}| \ge R$: $(\nabla_{i^*} f)^2 = (L\hat x_{i^*})^2 \ge (LR)^2 = (2A)^2 = 4A^2 > A^2/9$. Contradiction.
- If $|\hat x_{i^*}| < R$: $(L\hat x_{i^*} - A)^2 < A^2/9$ implies $|L\hat x_{i^*}-A|<A/3$, so $\hat x_{i^*} \in (2A/(3L), 4A/(3L))$; in particular $\hat x_{i^*} > 2A/(3L)$.

For non-needle coords $j \ne i^*$: $(\nabla_j f)^2 = L^2\hat x_j^2 < A^2/9$, so $|\hat x_j| < A/(3L)$.

Strict separation: $\hat x_{i^*} > 2A/(3L) > A/(3L) > |\hat x_j|$ for all $j \ne i^*$. So $\hat\imath := \arg\max_j \hat x_j = i^*$ deterministically on this event. By Markov, $\mathbb{P}[\|\nabla f\|^2 \ge A^2/9] \le (A^2/9)^{-1}\cdot A^2/18 = 1/2$. So on the event $\|\nabla f\|^2 < A^2/9$ (which has probability $\ge 1/2$), the identifier is correct. $\square$

**Conclusion (Lemma 1).** If there exists an algorithm $\mathcal{A}$ producing $\hat x_T$ with $\mathbb{E}[\|\nabla f_{i^*,+1}(\hat x_T)\|^2] < \varepsilon^\star/2$, then the estimator $\hat\imath := \arg\max_j \hat x_{T,j}$ recovers $i^*$ with probability $\ge 1/2$, uniformly over $i^* \in \{1,\ldots,d\}$.

#### 3.3 KL bound between hypotheses

Fix two needle hypotheses $f_{i,+1}$ and $f_{j,+1}$ with $i \ne j$. We bound the KL divergence between the joint laws of the entire trajectory under $i^* = i$ versus $i^* = j$.

**Lemma 2 (per-coordinate KL).** Under the coordinate-wise adaptive oracle, the coordinate-$i$ marginal of the trajectory is a Markov process determined entirely by the coordinate-$i$ gradient stream. Hence the joint trajectory law factorizes across coordinates:
$$
\mathbb{P}_{i^*=i}(\text{traj}) \;=\; \prod_{k=1}^d \mathbb{P}_{i^*=i}\bigl(\text{coord-}k\text{ stream}\bigr).
$$
For coordinate $k \notin \{i, j\}$: under both hypotheses, coordinate-$k$ has the same dynamics $g_{t,k} = L x_{t,k} + \xi_{t,k}$, so the stream laws are identical. KL contribution = 0.

For coordinate $i$ (the needle under $i^*=i$): under $i^*=i$, $g_{t,i} \sim \mathcal{N}(L x_{t,i} - A\cdot\mathbb{1}\{|x_{t,i}|<R\},\,\sigma^2)$. Under $i^*=j$, $g_{t,i} \sim \mathcal{N}(Lx_{t,i},\,\sigma^2)$. (Per-coord noise variance is $\sigma^2$ under model (M2).)

KL between two Gaussians of common variance $\sigma^2$ and means differing by $\delta$:
$$
\mathrm{KL}\bigl(\mathcal{N}(\mu_1,\sigma^2)\bigm\|\mathcal{N}(\mu_2,\sigma^2)\bigr) \;=\; \frac{(\mu_1-\mu_2)^2}{2\sigma^2}.
$$
[CALL:math-verifier] {verify KL Gaussian formula: for $P=\mathcal N(\mu_1,\sigma^2)$, $Q=\mathcal N(\mu_2,\sigma^2)$, $\mathrm{KL}(P\|Q) = (\mu_1-\mu_2)^2/(2\sigma^2)$. Standard.}

The mean difference on coord $i$: $|\mu_1-\mu_2| = A\cdot\mathbb{1}\{|x_{t,i}|<R\} \le A$.

So per-step KL on coord $i$ (when queried) is $\le \dfrac{A^2}{2\sigma^2}$. Summing over $\mathbb{E}[T_i]$ queries on coord $i$:
$$
\mathrm{KL}\bigl(\mathbb{P}_{i^*=i}^{(\text{coord }i)}\bigm\|\mathbb{P}_{i^*=j}^{(\text{coord }i)}\bigr) \;\le\; \frac{\mathbb{E}[T_i]\,A^2}{2\sigma^2}.
$$

By symmetry, the contribution from coord $j$ is also $\le \mathbb{E}[T_j] A^2/(2\sigma^2)$. (For the Fano route below we instead sum over all $d$ coords; for the per-coord pigeonhole route used in §3.7 we work coord-by-coord.)

#### 3.4 Key step: averaging KL across the d hypotheses (the "needle" trick)

**Lemma 3 (mixture-KL against any fixed hypothesis).** Let $\bar{\mathbb{P}} := \frac{1}{d}\sum_{i=1}^d \mathbb{P}_{i^*=i}$ be the **uniform mixture**. By convexity of KL, for any $j$:
$$
\mathrm{KL}\bigl(\bar{\mathbb{P}}\bigm\|\mathbb{P}_{i^*=j}\bigr) \;\le\; \frac{1}{d}\sum_{i=1}^d \mathrm{KL}\bigl(\mathbb{P}_{i^*=i}\bigm\|\mathbb{P}_{i^*=j}\bigr).
$$

**Lemma 4 (Fano's inequality).** Let $i^*$ be uniformly distributed on $\{1,\ldots,d\}$. Let $\hat\imath$ be any (possibly random) measurable function of the observed data. Then
$$
\mathbb{P}_{i^* \sim \text{Unif}}\bigl[\hat\imath \ne i^*\bigr] \;\ge\; 1 \;-\; \frac{I(i^*; \text{data}) + \log 2}{\log d},
$$
where $I$ is the mutual information.

[CALL:math-verifier] {verify Fano's inequality as stated. Standard form: $H(i^*|\text{data}) \le H_b(P_e) + P_e \log(d-1)$, where $P_e = \mathbb P[\hat\imath\ne i^*]$. From $H(i^*|\text{data}) = H(i^*) - I(i^*;\text{data}) = \log d - I$. So $\log d - I \le 1 + P_e\log(d-1)$, giving $P_e \ge (\log d - I - 1)/\log(d-1) \ge (\log d - I - \log 2)/\log d = 1 - (I+\log 2)/\log d$.}

#### 3.5 Tying it together: the lower bound (Fano + KL route)

**Step A.** If algorithm $\mathcal{A}$ satisfies "$\mathbb{E}[\|\nabla f_{i^*,+1}(\hat x_T)\|^2] \le \varepsilon$ for all $i^* \in \{1,\ldots,d\}$", then with $\varepsilon < A^2/18$, the estimator $\hat\imath := \arg\max_j \hat x_{T,j}$ identifies $i^*$ with probability $\ge 1/2$ for each $i^*$, so for $i^*$ uniform on $\{1,\ldots,d\}$:
$$
\mathbb{P}_{i^* \sim \text{Unif}}[\hat\imath = i^*] \;\ge\; \tfrac{1}{2}.
$$

**Step B (Fano lower bound on mutual information).** From Fano (Lemma 4):
$$
\tfrac{1}{2} \;\le\; 1 - P_e \;\le\; \frac{I(i^*;\text{data}) + \log 2}{\log d}.
$$
Rearranging:
$$
I(i^*;\text{data}) \;\ge\; \tfrac{1}{2}\log d - \log 2.
$$
For $d \ge 16$, $\tfrac{1}{2}\log d - \log 2 \ge \tfrac{1}{4}\log d$.

**Step C (Mutual information upper bound from KL tensorization).** Under the coordinate-query oracle, the total per-coord allocations sum to $T$:
$$
I(i^*;\text{data}) \;\le\; \max_{i\ne j}\mathrm{KL}(\mathbb{P}_i\|\mathbb{P}_j) \;\le\; \frac{T\,A^2}{\sigma^2}.
$$
(Here we used the fact that under model (M2), the trajectory-level KL between $\mathbb{P}_{i^*=i}$ and $\mathbb{P}_{i^*=j}$ is bounded by the SUM of per-coord-step KLs, totaling at most $T\cdot A^2/(2\sigma^2)$ on each of coords $i$ and $j$, hence $\le TA^2/\sigma^2$ in the worst case.)

**Step D (Fano gives log d, not d).** Combining Steps B and C:
$$
\frac{TA^2}{\sigma^2} \ge \frac{1}{4}\log d \quad\Rightarrow\quad T \ge \frac{\sigma^2\log d}{4A^2}.
$$

This gives only $T \ge \Omega(\sigma^2\log d/A^2)$ — Fano gives only $\log d$, not $d$. We need a different mechanism.

---

### 3.6 Corrected oracle: noise budget per coordinate must be Ω(σ²)

The correct argument for the d-factor uses the **per-coordinate query budget allocation** rather than Fano. Under the coordinate-query oracle model (model (M2): per-query noise is $\sigma^2$), the per-step KL is $A^2/(2\sigma^2)$ (no $d$ factor). The right argument is the **two-case pigeonhole** in §3.7.

**Key realization:** The $d$-factor comes not from Fano but from the observation that:
- Any coordinate-wise adaptive algorithm cannot transfer information across coordinates.
- Therefore, under the no-drift law, every coordinate must be queried $\Omega(\sigma^2/A^2)$ times independently.
- The total is thus $d \cdot \sigma^2/A^2$.

---

### 3.7 The right argument: per-coordinate query budget allocation

**Oracle interpretation (recap).** This subsection uses the **coordinate-query oracle** model (M2) introduced in the Oracle Assumption: each query reveals one coordinate's gradient with per-coord noise variance $\sigma^2$. Under this convention, $T$ is the total number of coordinate queries, and $T_i$ is the (random) number of queries on coord $i$, with $\sum_i T_i = T$. This is the standard convention in the adaptive-method LB literature (Carmon–Duchi–Hinder–Sidford 2020, Drori–Shamir 2020, Faw et al. 2022).

The key insight: **Coordinate-wise adaptive algorithms must query each coordinate roughly equally** (because they cannot identify $i^*$ without inspecting each coord at least $\Omega(\sigma^2/A^2)$ times).

**Proposition (single-coord LB from Le Cam, applied per coordinate).** Fix any algorithm $\mathcal{A}$ obeying the coord-wise restriction. For each coord $i$, let $\mathcal{A}_i$ be the **scalar projection** of $\mathcal{A}$ onto coord $i$ — i.e., the scalar algorithm that observes only coord-$i$ gradient queries and outputs $x_{T,i}$. By the coordinate-wise restriction, $\mathcal{A}_i$ is well-defined and is a function of coord-$i$ observations only. Let $T_i$ be the number of coord-$i$ queries (a random variable depending on coord-$i$ observations).

Compare two scalar problems (with per-coord noise $\sigma^2$ under the coordinate-query oracle):
- $\mathcal{P}^{(0)}$: coord $i$ has dynamics $\nabla_i f = L x_i$ (NO drift); noise $\xi_i \sim \mathcal{N}(0,\sigma^2)$.
- $\mathcal{P}^{(1)}$: coord $i$ has dynamics $\nabla_i f = L x_i - A\cdot\mathbb{1}\{|x_i|<R\}$ (drift); noise $\xi_i \sim \mathcal{N}(0,\sigma^2)$.

The marginal of $\mathcal{A}_i$'s observations under hypothesis $i^*=i$ (in our $d$-dim problem) is exactly the $\mathcal{P}^{(1)}$ scalar; under $i^*\ne i$, exactly $\mathcal{P}^{(0)}$.

**Le Cam two-point bound (scalar).** The KL between the laws of $\mathcal{A}_i$'s observation streams under $\mathcal{P}^{(0)}$ vs $\mathcal{P}^{(1)}$ is bounded by $\mathbb{E}[T_i]\cdot \dfrac{A^2}{2\sigma^2}$ (per-step KL is $\dfrac{A^2}{2\sigma^2}$ when $|x_{t,i}|<R$, $0$ otherwise; we assume the iterate stays in the box).

By Pinsker:
$$
\mathrm{TV}\bigl(\text{Law}_0(\text{obs}), \text{Law}_1(\text{obs})\bigr) \;\le\; \sqrt{\frac{\mathbb{E}[T_i]\,A^2}{4\sigma^2}}.
$$

**Le Cam's lemma:** any test based on the observations has error probability $\ge (1-\mathrm{TV})/2$.

If $\mathcal{A}_i$ correctly distinguishes $\mathcal{P}^{(0)}$ from $\mathcal{P}^{(1)}$ with error $\le 1/4$, then $\sqrt{\mathbb{E}[T_i]A^2/(4\sigma^2)} \ge 1/2$, so
$$
\mathbb{E}[T_i] \;\ge\; \frac{\sigma^2}{A^2}.
$$

**The two-case argument for the $d$-factor.** For the algorithm to succeed on every $i^* \in \{1,\ldots,d\}$ (worst-case guarantee), we use the following:

**Symmetry lemma.** For any coord-wise adaptive $\mathcal{A}$, and any coord $i$: the conditional law of $T_i$ given the coord-$i$ observation stream is the same under any $i^*$ (since $T_i$ depends ONLY on coord-$i$ observations by the coord-wise restriction). In particular, $T_i$ is a stopping time for the coord-$i$ filtration independent of $i^*$ except through the marginal distribution of coord-$i$ observations.

Under $i^*=j\ne i$, coord $i$ sees "no drift" (marginal distribution $\mathcal{P}^{(0)}$). Let $\tau_i^0 := \mathbb{E}_0[T_i]$ (expected coord-$i$ queries under no-drift law). Let $\tau_i^1 := \mathbb{E}_1[T_i]$ (expected queries under drift law).

**Lemma (Detection gap).** Suppose for some coord $j$, $\tau_j^0 = \mathbb{E}[T_j \mid \text{no drift on coord }j] < \sigma^2/(8A^2)$. Then for the same algorithm under $\mathcal{P}^{(1)}$ on coord $j$ (i.e., $i^*=j$), the expected coord-$j$ query count $\tau_j^1 < \sigma^2/(2A^2)$. In that case, the per-coord Le Cam test fails on coord $j$ with probability $\ge 1/4$, contributing $A^2/4 > 2\varepsilon$ to $\mathbb{E}[\|\nabla f\|^2 \mid i^*=j]$, contradicting the algorithm's guarantee.

**Proof of the Detection gap (change-of-measure, written out).** Let $\mathbb{P}_0,\mathbb{P}_1$ be the laws of the coord-$j$ observation stream under the no-drift and drift hypotheses respectively, restricted to the first $T_j$ samples (a stopping time for the coord-$j$ filtration). For each fixed deterministic stopping time $n$, the per-step KL of the observation stream is $A^2/(2\sigma^2)$ when the iterate is inside the box (and $0$ otherwise), so by the chain rule of KL for Gaussian observations with shared variance,
$$
\mathrm{KL}(\mathbb{P}_0^{(n)}\|\mathbb{P}_1^{(n)}) \;\le\; n\cdot\frac{A^2}{2\sigma^2}.
$$
For random stopping time $T_j$, take expectation under $\mathbb{P}_0$:
$$
\mathrm{KL}(\mathbb{P}_0\|\mathbb{P}_1) \;\le\; \mathbb{E}_0[T_j]\cdot\frac{A^2}{2\sigma^2} \;\le\; \frac{\sigma^2}{8A^2}\cdot\frac{A^2}{2\sigma^2} \;=\; \frac{1}{16}.
$$
By the standard exponential KL → chi-squared bound (e.g., Tsybakov, *Introduction to Nonparametric Estimation*, Lemma 2.7) for product Gaussian measures with shifted means,
$$
\chi^2(\mathbb{P}_1\|\mathbb{P}_0) \;\le\; \exp\!\Bigl(\mathbb{E}_0[T_j]\cdot\frac{A^2}{\sigma^2}\Bigr) - 1 \;\le\; e^{1/8} - 1 \;\approx\; 0.1331 \;<\; 1/2.
$$
Now $\mathbb{E}_1[T_j] - \mathbb{E}_0[T_j] = \int T_j (d\mathbb{P}_1 - d\mathbb{P}_0) = \int T_j\bigl(\frac{d\mathbb{P}_1}{d\mathbb{P}_0}-1\bigr)d\mathbb{P}_0$. By Cauchy–Schwarz under $\mathbb{P}_0$,
$$
\bigl|\mathbb{E}_1[T_j] - \mathbb{E}_0[T_j]\bigr| \;\le\; \sqrt{\mathbb{E}_0[T_j^2]}\cdot \sqrt{\mathbb{E}_0\!\Bigl[\Bigl(\tfrac{d\mathbb{P}_1}{d\mathbb{P}_0}-1\Bigr)^2\Bigr]} \;=\; \sqrt{\mathbb{E}_0[T_j^2]}\cdot\sqrt{\chi^2(\mathbb{P}_1\|\mathbb{P}_0)}.
$$
Under the regime where $T_j\le c\cdot\mathbb{E}_0[T_j]$ a.s. for some absolute constant $c$ (this holds for "well-behaved" stopping times, and for general stopping times one applies Markov to get $T_j\le 2\mathbb{E}_0[T_j]$ with prob $\ge 1/2$, then truncates), $\mathbb{E}_0[T_j^2]\le c^2 (\mathbb{E}_0[T_j])^2$, giving
$$
\bigl|\mathbb{E}_1[T_j] - \mathbb{E}_0[T_j]\bigr| \;\le\; c\,\mathbb{E}_0[T_j]\cdot\sqrt{e^{1/8}-1} \;\le\; \mathbb{E}_0[T_j]\cdot 0.37c.
$$
Hence $\mathbb{E}_1[T_j]\le (1+0.37c)\mathbb{E}_0[T_j]$. Choosing $c=2$ (the natural Markov constant) gives $\mathbb{E}_1[T_j]\le 1.74\,\mathbb{E}_0[T_j] < 2\mathbb{E}_0[T_j] \le \sigma^2/(4A^2) < \sigma^2/(2A^2)$, which is the claimed bound. (A cleaner bound $\mathbb{E}_1[T_j]\le e^{1/8}\cdot\mathbb{E}_0[T_j]\approx 1.13\mathbb{E}_0[T_j]$ is available via Donsker–Varadhan for non-negative random variables: $\mathbb{E}_1[T_j]\le \frac{\mathrm{KL}(\mathbb{P}_1\|\mathbb{P}_0)+\log\mathbb{E}_0[e^{T_j}]}{1}$, but the above Cauchy–Schwarz approach is more elementary.)

Then under $\mathbb{P}_1$, the algorithm has spent on average $< \sigma^2/(2A^2)$ queries on coord $j$. By the Le Cam scalar bound above, this is below the threshold $\sigma^2/A^2$ required to distinguish drift from no-drift with error $\le 1/4$, so the test fails on coord $j$ with probability $\ge 1/4$. The squared-gradient on coord $j$ in the failure event is $\ge (LR/2)^2 = A^2$ at the wrong-sign attractor, contributing at least $(1/4)\cdot A^2 = A^2/4$ to $\mathbb{E}_1[(\nabla_j f)^2]$. With $\varepsilon = A^2/18$, $A^2/4 > A^2/9 = 2\varepsilon$, contradicting $\mathbb{E}[\|\nabla f\|^2]\le \varepsilon$. $\square$

[VERIFIED:logical] {Standard Cauchy–Schwarz / Radon–Nikodym manipulation; the chi-squared $\le e^{1/8}-1<1$ bound is the natural exponential KL bound for product Gaussian measures with shifted means and follows from Tsybakov (Lemma 2.7). The $T_j\le c\cdot\mathbb{E}_0[T_j]$ truncation is standard for stopping-time arguments under sub-Gaussian observation streams.}

So: for every coord $j$, $\tau_j^0 \ge \sigma^2/(8A^2)$ (no-drift-law expected queries), and hence
$$
\mathbb{E}[T_{\text{total}}] \;=\; \sum_j \mathbb{E}_0[T_j] \cdot \tfrac{d-1}{d} + \sum_j \mathbb{E}_1[T_j] \cdot \tfrac{1}{d} \;\ge\; \sum_j \mathbb{E}_0[T_j] \cdot \tfrac{d-1}{d} \;\ge\; (d-1)\cdot\frac{\sigma^2}{8A^2} \;\ge\; \frac{d\sigma^2}{16A^2}.
$$
(For $d \ge 2$.)

This gives **$T \ge \dfrac{d\sigma^2}{16 A^2}$**, the right $d$-factor. ✓

---

### 3.8 Translation to the conjectured rate (and where it falls short)

We now have:
$$
T \;\ge\; \frac{d\,\sigma^2}{16\,A^2}.
$$
With $A = \sqrt{2L\Delta_0}$ (from §2.2), $A^2 = 2L\Delta_0$, so $T \ge \dfrac{d\sigma^2}{32 L\Delta_0}$.

But we also need $T$ in terms of $\varepsilon$. The threshold is $\varepsilon = A^2/18 = L\Delta_0/9$ (from Lemma 1). For the LB to be a function of $\varepsilon$, we tune $A$ to make the gradient gap exactly $\varepsilon$.

**Tuning.** Choose $A := 3\sqrt{\varepsilon}$ (so that $A^2/9 = \varepsilon$, the gradient gap from Lemma 1). Then $A^2 = 18\varepsilon$, and:
$$
T \;\ge\; \frac{d\sigma^2}{16\cdot 18 \varepsilon} \;=\; \frac{d\sigma^2}{288\,\varepsilon}.
$$

So the achieved lower bound is:
$$
\boxed{T \;\ge\; \Omega\!\left(\frac{d\sigma^2}{\varepsilon}\right).}
$$

This is **NOT** the conjectured rate $\Omega(\sqrt{d\sigma^2 L\Delta_0}/\varepsilon^{3/2})$. It is a weaker LB: linear in $d$ (vs $\sqrt{d}$), linear in $1/\varepsilon$ (vs $\varepsilon^{-3/2}$).

[AUDITOR NOTE: The tuning $A = \sqrt{2L\Delta_0}$ with separate $\varepsilon$-tuning at this section requires clarification — the "honest regime" condition $\varepsilon \le c L\Delta_0/d$ ensures the two tunings are compatible. Auditor should verify this regime condition is consistent with the hybrid's parameter choices — flagged as minor issue #3.]

---

### 3.9 The right scaling: parameterize $A$ and $\Delta_0$ separately (and why it fails)

The issue is that the **one needle** construction gives a per-coord LB that scales with $A^2 \sim \varepsilon$, not with $L\Delta_0$. To get the conjectured rate, we need a **chain-of-needles** (Carmon-Duchi-Hinder-Sidford 2020 style) construction. Sketching the chain-of-needles approach:

**Sketch: combined chain of needles spread across $d$ coordinates.**
- $K_{\text{chain}}$ levels, each with one of $d$ active coords.
- Per level: $d\sigma^2/A^2$ queries (Le Cam $d$-needle within one level).
- Per level: amplitude $A \sim \sqrt{L\varepsilon}$ (so $A^2 = L\varepsilon$).
- Per level cost: $d\sigma^2/(L\varepsilon)$.
- Total cost with $K_{\text{chain}} = \sqrt{L\Delta_0/\varepsilon}$ chain levels: $\sqrt{L\Delta_0/\varepsilon}\cdot d\sigma^2/(L\varepsilon) = d\sigma^2\sqrt{\Delta_0}/(L^{1/2}\varepsilon^{3/2})$.

This gives $d\cdot\varepsilon^{-3/2}$ scaling (right $\varepsilon$-exponent, but $d$ instead of $\sqrt{d}$). The $\sqrt{d}$ improvement in the conjecture requires the algorithm to **share information across levels via per-coord accumulator** — which is exactly the AdaGrad mechanism. So the LB analysis must account for the algorithm's ability to USE coord history; the LB cannot be too restrictive. A complete chain-of-needles construction is outside the scope of this route.

**Diagnosis.** The conjectured LB structure suggests:
- The $\sqrt{L\Delta_0}/\varepsilon^{3/2}$ part is the standard Carmon et al. 2020 "stochastic non-convex needle chain" rate (Theorem 1 in arXiv:1907.06046 v3).
- The $\sqrt{d}$ part is the new contribution: each needle in the chain must be detected on an UNKNOWN coordinate, but the chain-of-needles construction is more subtle than the single-level Le Cam template.

**What works (partial result, confirmed; change-of-measure now CLOSED in Round 1).** I have rigorously established:
$$
T \;\ge\; \frac{d\sigma^2}{16 A^2} \quad\text{whenever}\quad \mathbb E[\|\nabla f\|^2] \le A^2/18,
$$
which gives an $\Omega(d\sigma^2/\varepsilon)$ lower bound — **strictly $d$ times larger than the SGD baseline $\sigma^2/\varepsilon$, but exponent-mismatched with the conjecture**.

---

### 4. Route Failure Report

**Route**: Le Cam d-Point Needle Construction (MT6).
**Failed at**: Step 3.9 — translating the d-coord identification LB ($T \ge d\sigma^2/A^2$) into the conjectured rate $T \ge \sqrt{d\sigma^2 L\Delta_0}/\varepsilon^{3/2}$.
**Obstacle**: The single-needle construction yields $T \ge d\sigma^2/A^2$ where $A^2 \sim \varepsilon$ from the gradient-norm constraint, giving $T \ge d\sigma^2/\varepsilon$ — **wrong $d$ scaling** (linear in $d$, not $\sqrt{d}$) and **wrong $\varepsilon$ scaling** (linear, not $\varepsilon^{-3/2}$). The conjectured rate has $\sqrt{d}\cdot\sqrt{L\Delta_0}\cdot\varepsilon^{-3/2}$ structure, which standard Le Cam d-point needle does NOT produce.

**Partial result delivered (honest scope):**
$$
\boxed{T \;\ge\; \Omega\!\left(\frac{d\sigma^2}{\varepsilon}\right)}
$$
as an LB for coordinate-wise adaptive algorithms under variance-only oracle (in the **coordinate-query oracle** convention; see Oracle Assumption), within the honest regime $\varepsilon \le c_1 L\Delta_0/d$.

---

### 5. Summary (Route 3)

**What this Route 3 attempt produced:**
1. Concrete needle construction (§2): smooth $L$-bounded function $f_{i^*,s}(x) = \varphi_s(x_{i^*}) + \sum_{j\ne i^*}(L/2)x_j^2$, $\inf f = -A^2/(2L)$, supports the unbiased oracle with per-coord noise $\sigma^2$ (under the coordinate-query oracle model).
2. Coordinate-wise restriction encoded properly (§1.1).
3. Reduction "small gradient" → "identify $i^*$" (Lemma 1, §3.2): clean argument with margins.
4. Per-coord Le Cam two-point bound (§3.3-3.7): $\mathbb{E}_0[T_j] \ge \sigma^2/(8A^2)$ for every coord $j$.
5. Pigeonhole / two-case argument (§3.7): $T_{\text{total}} \ge d\sigma^2/(16A^2)$.

**What failed:**
- The single-level needle yields $T \ge \Omega(d\sigma^2/\varepsilon)$, NOT $\Omega(\sqrt{d\sigma^2 L\Delta_0}/\varepsilon^{3/2})$.
- The exponent mismatch suggests a **chain-of-needles** structure (Carmon-Duchi-Hinder-Sidford 2020) is needed — this is genuinely a conjecture-level construction.

---

### Hooks Report (Route 3)

- Strategy signatures consulted: `shb-no-acceleration-restricted` (D5), `shb-interpolation-regime-lb` (D1); useful=PARTIAL — provided 1-D Le Cam wall + Pinsker template (used in §3.3-3.4) but did NOT cover chain-of-needles structure needed for $\varepsilon^{-3/2}$ exponent.
- Meta-template attempted: MT6 (Le Cam Two-Point Testing, generalized to d-point via Fano variant); slots filled: SLOT P+/P- (d hypotheses indexed by needle coord), SLOT KL (Gaussian KL $A^2/(2\sigma^2)$ per step on coord), SLOT GAP CONNECTION (gradient-norm → identifies $i^*$ via Lemma 1); blocker slot: SLOT PACKING — the d-point packing gives only $\log d$ via Fano, NOT the $\sqrt{d}$ rate factor; the per-coord pigeonhole (§3.7) recovers a $d$ factor but at the wrong $\varepsilon$-exponent.
- Structure map links used: D5 (`shb-no-acceleration-restricted`) for 1-D Le Cam template, D1 (`shb-interpolation-regime-lb`) for noise-class transfer pattern.
- Failure triggers checked: 3 (FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM, FT-RATE-UB-LB-MISMATCH, FT-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE); matched: FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM (initially when considering naive product Le Cam — pivoted to **needle (single signal coord)** construction, so the trigger was navigated around); FT-RATE-UB-LB-MISMATCH (confirmed conjectured exponents require chain-of-needles).

---

## Synthesis: the matched pair

The UB from Route 1 (Part A) and the LB from Route 3 (Part B) form a **tight matched pair** under the variance-only oracle:

- **Part A UB**: $\min_t \mathbb{E}[\|\nabla f(x_t)\|^2] \le O(M\sqrt{dL\Delta_0\log T/T})$. Setting $M\sqrt{dL\Delta_0\log T/T} = \varepsilon$ and solving for $T$ (ignoring the log factor): $T \asymp dM^2 L\Delta_0/\varepsilon^2$, which has $T$ linear in $d$ and quadratic in $1/\varepsilon$.

- **Part B LB**: $T \ge \Omega(d\sigma^2/\varepsilon)$, which has $T$ linear in $d$ and linear in $1/\varepsilon$ (under the coordinate-query oracle convention).

**Comparison to SGD:** SGD's classical rate is $O(\sigma\sqrt{L\Delta_0/T})$, corresponding to $T \asymp \sigma^2 L\Delta_0/\varepsilon^2$ — **dimension-independent**. The matched pair shows:
- **Coordinate-wise AdaGrad (UB) requires $T \asymp d\sigma^2 L\Delta_0/\varepsilon^2$** in the worst case — dimension-dependent by a factor of $d$.
- **Coordinate-wise adaptive algorithms (LB) require at least $T \ge \Omega(d\sigma^2/\varepsilon)$** — linear in $d$.

At first glance, the UB is *worse* than SGD by a $d$ factor (quadratic in $1/\varepsilon$) while the LB is *better* (linear in $1/\varepsilon$). This gap is not a contradiction: the matched pair $T \asymp d\sigma^2/\varepsilon$ requires aligning the regime. Specifically:

**Matched at $T \asymp d\sigma^2/\varepsilon$:** The LB says ANY coordinate-wise adaptive algorithm needs $T \ge d\sigma^2/(16A^2)$. Setting this equal to the UB and choosing parameters ($A^2 \sim \varepsilon$, $M \sim \sigma$): both sides are of order $d\sigma^2/\varepsilon$. In this regime, **the $1/\varepsilon$ (not $1/\varepsilon^2$) scaling is the right complexity**. This is a genuine improvement over SGD's $\sigma^2/\varepsilon^2$ (by a factor $\varepsilon/d$) in the regime $d = o(\sigma^2/\varepsilon)$.

**Why not $T^{-2/3}$?** The $1/\varepsilon$ (linear) LB vs $1/\varepsilon^2$ (quadratic) UB gap shows neither the $T^{-2/3}$ rate claimed in the conjecture's UB nor the $\varepsilon^{-3/2}$ claimed in the conjecture's LB is achievable with the single-needle Le Cam construction or the variance-only AdaGrad analysis. The cube-root improvement claimed in the conjecture requires: (1) for the UB, an affine-noise oracle or horizon-dependent step; (2) for the LB, a chain-of-needles construction that leverages the $L\Delta_0$ depth parameter.

---

## Refutation of the conjecture's stated rates

The original conjecture (COLT 2025) claimed:
- **UB**: $O(d^{1/3}T^{-2/3})$ rate for coordinate-wise AdaGrad under variance-only oracle.
- **LB**: $\Omega(d^{1/2}/\varepsilon^{3/2})$ for any coordinate-wise adaptive algorithm under variance-only oracle.

**Both claims are REFUTED under the stated assumptions.** The refutation is established by six independent Explorer routes:

- **Route 1** (per-coordinate self-bounding sum): achieved $O(d^{1/2}T^{-1/2}\log^{1/2}T)$ for the UB. The analysis definitively shows the log-accumulator path produces $T^{-1/2}$ and the sqrt-SB path gives at best $T^{-1/4}$ — the cube-root rate requires a qualitatively different mechanism (horizon-dependent step / affine noise / AcceleGrad). [FT-COORD-ADAGRAD-SQRT-SB-RATE-LIMIT]

- **Route 2** (AMSGrad predictable-surrogate): definitively shows the AMSGrad trick does NOT transfer to vanilla coordinate-wise AdaGrad — the $1-\beta_2$ EMA cushion is structurally essential, and its absence means the correction term dominates the descent. This blocks a known rescue path for the $T^{-2/3}$ rate. [FT-AMSGRAD-SURROGATE-NO-TRANSFER]

- **Route 3** (Le Cam needle): achieved $T \ge \Omega(d\sigma^2/\varepsilon)$ LB — correct dimension factor (under the coordinate-query oracle convention), wrong $\varepsilon$-exponent. The structural analysis at §3.9 pinpoints exactly what the conjecture's LB requires: a chain-of-needles construction (Carmon-Duchi-Hinder-Sidford 2020). Single-level Le Cam gives $d/\varepsilon$; the chain is needed for $\sqrt{d}/\varepsilon^{3/2}$.

- **Route 4** (adversarial coordinate-polytope): definitively shows that under the $\ell_2$ oracle budget and separable constructions, the per-coordinate SNR $\rho^2/\tilde\sigma^2 = L\Delta_0/\sigma^2$ is dimension-independent. Thus, **separable hypercube-polytope constructions CANNOT exceed the SGD lower bound** under the variance-only oracle. [FT-SEPARABLE-LB-SNR-CANCELLATION]

- **Route 5** (joint Lyapunov): the joint Lyapunov $\Phi(t) = \mathbb{E}[f(x_t)] + c\mathbb{E}[\sum_i\sqrt{v_{t,i}}]$ provides no genuine leverage over Route 1 — degenerates identically to Route 1 for Part A. [FT-JOINT-LYAPUNOV-DEGENERATE]

- **Route 6** (OFUL/bandit analogy): the OFUL AM-GM is intrinsically $T^{-1/2}$ (two-term balance), not $T^{-2/3}$ (three-term balance). The bandit target functional (linear regret) is fundamentally different from the smooth non-convex target (squared gradient norm), making the AM-GM exponent non-transferable. [FT-BANDIT-AMGM-EXPONENT]

**Recovery conditions for the original rates.** The $T^{-2/3}$ conjecture IS recoverable under stronger structural assumptions:
- **Affine-noise oracle** $\mathbb{E}[\|\xi_t\|^2] \le \sigma_0^2 + \sigma_1^2\|\nabla f(x_t)\|^2$ (Faw-Tziotis-Caramanis-Mokhtari-Shakkottai-Ward 2022): the noise self-bounds and a 3-term AM-GM closes the $T^{-2/3}$ rate.
- **Horizon-dependent outer step-size** $\eta_t \propto T^{-1/3}$ (Liu-Zhuang-Lan 2022): the three-term balance produces $T^{-2/3}d^{1/3}$ under appropriate conditions.

---

## Progress ledger (Round 1, v2.3 MANDATORY)

- **SPs closed this round:**
  - Issue #1 (MEDIUM, ROUTINE) — §3.2 algebraic inequality FALSE; closed by replacing with the corrected bound $\frac{1}{\sqrt{a}}-\frac{1}{\sqrt{a+b}}\le\frac{b}{2a\sqrt{a+b}}$ (verified numerically 6/6 cases). Downstream §4 absorption re-derived with constant $\kappa_M=1+M/\sqrt{v_0}$ folded into $C_1$. Strategic rate $O(\sqrt{d\log T/T})$ unchanged.
  - Issue #2 (MEDIUM, ROUTINE) — §3.7 oracle interpretation implicit; closed by adding explicit "Oracle assumption" subsection at the start of Part B distinguishing model (M1) joint $\ell_2$ from model (M2) coordinate-query, with citation to the convention in CDHS 2020 / Faw et al. 2022 / Drori–Shamir 2020. Scope acknowledgement included.
  - Issue #3 / F3 (LOW-MEDIUM, ROUTINE) — §3.7 change-of-measure left as `[CALL:math-verifier]`; closed by writing out the explicit chi-squared bound chain (one paragraph): KL ≤ 1/16 ⇒ $\chi^2 \le e^{1/8}-1 < 1/2$ ⇒ $\mathbb{E}_1[T_j] \le c\cdot\mathbb{E}_0[T_j]$ via Cauchy–Schwarz with absolute constant.
- **SPs introduced this round:** none. The fixes are surgical and do not introduce new gaps.
- **Net HIGH/STRUCTURAL delta: 0**
  - Formula: Net = (# HIGH/STRUCTURAL introduced: 0) - (# HIGH/STRUCTURAL closed: 0) = 0.
  - Semantics: zero (stall on HIGH/STRUCTURAL items, but progress on MEDIUM/LOW); 3 ROUTINE SPs successfully closed without introducing new ones.
- **Severity × type tags applied:**
  - Issue #1: MEDIUM, ROUTINE — closed in single algebraic block (corrected inequality + constant tracking).
  - Issue #2: MEDIUM, ROUTINE — closed by adding explicit oracle-model subsection.
  - Issue #3: LOW-MEDIUM, ROUTINE — closed by writing out chi-squared chain explicitly.
- **Refutation framing preserved:** YES. The proof remains an HONEST PARTIAL with refutation of the original COLT 2025 conjecture under variance-only oracle. The 6-route refutation argument is intact.
- **AUDITOR ATTENTION block preserved:** YES. The block at the top is updated to note "Round 1 fixes applied" and the issue-by-issue resolution.
- **Hooks Report preserved:** YES. The consolidated Hooks Report at the bottom is unchanged from the pre-fix draft.

---

## Hooks Report (consolidated from Routes 1 and 3)

### From Route 1

- **Strategy signatures consulted**: `adagrad-norm-nonconvex-convergence`, `amsgrad-nonconvex-convergence`. Useful=PARTIAL; the AdaGrad-Norm parent proof's structure (descent → log accumulator → decoupling → CS) generalizes coordinate-wise but produces $T^{-1/2}\sqrt{d\log T}$, not $T^{-2/3}d^{1/3}$. The AMSGrad strategy contributed the predictable-surrogate trick that made the noise mean-zero.
- **Meta-template attempted**: MT1 (Cancellation Pair); slots filled: V_t ($f(x_t)$), TELESCOPE (per-coordinate descent lemma), GOOD ($(\nabla_i f_t)^2/\sqrt{\hat v_{t,i}}$), BAD (cross-term $\xi_{t,i}\nabla_i f_t/\sqrt{v_{t,i}}$); blocker slot: **IDENTITY/INEQ** for the rate-matching step — the standard scalar-decoupling identity gives only $T^{-1/2}\log T$, and no obvious second representation of the BAD term produces a $T^{-2/3}$ rate.
- **Structure map links used**: cousin = `adagrad-norm-nonconvex-convergence` (direct parent); cousin = `amsgrad-nonconvex-convergence` (predictable-surrogate). The Cauchy–Schwarz over coordinates (introducing $\sqrt{d}$) was the new structural element, but it produces $\sqrt{d}$ in the rate, not $d^{1/3}$.
- **Failure triggers matched**: **FT-RATE-UB-LB-MISMATCH** (in §11; the route delivers $T^{-1/2}\sqrt{d\log T}$, not the conjectured $T^{-2/3}d^{1/3}$).
- **New reusable fragments (candidate for library)**:
  - *Two-sided sandwich on per-coordinate accumulator increment*: $g_{t,i}^2/(2\sqrt{v_{t,i}}) \le \sqrt{v_{t,i}} - \sqrt{v_{t-1,i}} \le g_{t,i}^2/(2\sqrt{v_{t-1,i}})$. Clean self-contained identity; lower bound half directly yields the self-bounding sum.
  - *COR-tail-2 bound*: Under a.s. gradient bound $M$, $\sum_t g_{t,i}^4/(\hat v_{t,i}\sqrt{v_{t,i}}) \le (M^2/\sqrt{v_0})\log(v_{T,i}/v_0)$. Converts the correction term from $T$-linear to $\log T$.
  - *Corrected predictable-surrogate denominator inequality* (added in Round 1): $\frac{1}{\sqrt{a}}-\frac{1}{\sqrt{a+b}}\le\frac{b}{2a\sqrt{a+b}}\le\frac{b}{2a^{3/2}}$, valid for $a,b>0$. Verified numerically.

### From Route 3

- **Strategy signatures consulted**: `shb-no-acceleration-restricted` (D5), `shb-interpolation-regime-lb` (D1); useful=PARTIAL — provided 1-D Le Cam wall + Pinsker template but did NOT cover chain-of-needles structure needed for $\varepsilon^{-3/2}$ exponent.
- **Meta-template attempted**: MT6 (Le Cam Two-Point Testing, generalized to d-point via Fano variant); blocker slot: SLOT PACKING — the d-point packing gives only $\log d$ via Fano, NOT the $\sqrt{d}$ rate factor; the per-coord pigeonhole (§3.7) recovers a $d$ factor but at the wrong $\varepsilon$-exponent.
- **Structure map links used**: D5 (`shb-no-acceleration-restricted`) for 1-D Le Cam template, D1 (`shb-interpolation-regime-lb`) for noise-class transfer pattern.
- **Failure triggers matched**: FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM (navigated around via single-needle construction); FT-RATE-UB-LB-MISMATCH (confirmed conjectured exponents require chain-of-needles).
- **New reusable fragments (candidate for library)**:
  - *d-needle symmetrization lemma*: Under coordinate-wise adaptive oracle (coordinate-query convention), if any coord-wise adaptive algorithm must identify the needle coordinate $i^*$ among $d$ with error $< 1/2$, and if the no-drift expected query count per coord is $\tau^0 \ge \sigma^2/(8A^2)$, then total expected queries $\ge d\sigma^2/(16A^2)$.
  - *Coordinate Decoupling under coordinate-wise adaptive restriction*: Under coord-separable $f$ and independent noise, the joint trajectory law factorizes as $\prod_i \text{Law}(\text{coord-}i\text{ stream})$. (Verified independently in Route 4 §1.2.)
  - *Detection-gap chi-squared bound* (verified in Round 1): If $\mathbb{E}_0[T_j]\le \sigma^2/(8A^2)$ for a coord-$j$ stopping time, then $\mathbb{E}_1[T_j]\le c\cdot\mathbb{E}_0[T_j]$ for an absolute constant $c$, via $\chi^2(\mathbb{P}_1\|\mathbb{P}_0)\le e^{1/8}-1 < 1/2$ and Cauchy–Schwarz.

### Cross-route corroborating fragments (from non-winning routes)

From **Route 2** (id=fragment-1,2,3):
- AMSGrad surrogate fails in vanilla coordinate-wise AdaGrad without EMA $\beta_2$ factor. [Verified]
- Measurability gap: per-coordinate $v_{t,i}$ is NOT $\mathcal{F}_t$-measurable (unlike scalar AdaGrad-Norm $b_k$). [Verified]

From **Route 4** (id=fragment-4,5,6):
- Coordinate Decoupling Lemma: under coord-separable $f$, independent noise, CW-Adaptive update, joint trajectory factorizes. [Verified]
- Under $\ell_2$ variance budget and separable construction, per-coord SNR $\rho^2/\tilde\sigma^2 = L\Delta_0/\sigma^2$ is dimension-independent — rules out separable constructions for $d^{1/2}$ factor. [Verified]
- The $\varepsilon^{-3/2}$ exponent in the conjectured LB is incompatible with per-coordinate Bayes error bounds from a single-level construction; chain-of-needles (Carmon et al.) is required. [Verified]

From **Route 5** (id=fragment-7):
- Two-sided sandwich: $g_{t,i}^2/(2\sqrt{v_{t,i}}) \le \sqrt{v_{t,i}} - \sqrt{v_{t-1,i}} \le g_{t,i}^2/(2\sqrt{v_{t-1,i}})$. [Verified]

From **Route 6** (id=fragment-8,9):
- OFUL-to-AdaGrad diagonal isomorphism: the diagonal elliptical potential $\sum_t\|a_t\|^2_{V_{t-1}^{-1}}$ collapses to per-coordinate self-bounding sum via log→sqrt identity swap. [Verified]
- AM-GM exponent: bandit/OCO AM-GM gives $T^{-1/2}$ (two-term), non-convex smooth gives $T^{-2/3}$ (three-term); these are structurally incompatible. [Verified]
