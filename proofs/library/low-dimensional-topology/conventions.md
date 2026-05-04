# LDT Convention Registry

Purpose: fix an explicit convention for every sign/normalization choice in
low-dimensional-topology proofs, so Explorer and Auditor can cross-check
against a single source. Updated 2026-04-20 at Stage 3 of v2.1 extension.

## 1. Knot invariants

### 1.1 Jones polynomial — Lickorish convention

- **Variable**: $V_K(q)$, where $q = A^{-4}$, i.e. substitute $A = q^{-1/4}$
  into Kauffman bracket after writhe normalization.
- **Normalization**: $V_K(q) = (-A)^{-3w(D)} \langle D \rangle \big|_{A = q^{-1/4}}$
  where $D$ is any diagram of $K$ and $w(D)$ is its writhe.
- **Unknot**: $V_{\text{unknot}}(q) = 1$.
- **Right-handed trefoil $3_1$**: $V_{3_1}(q) = -q^{-4} + q^{-3} + q^{-1}$.
- **Left-handed trefoil $3_1^m$**: $V_{3_1^m}(q) = -q^4 + q^3 + q$ (mirror).
- **Figure-eight $4_1$**: $V_{4_1}(q) = q^{-2} - q^{-1} + 1 - q + q^2$
  (note: $4_1$ is amphichiral, so $V_{4_1}(q) = V_{4_1}(q^{-1})$).

**Source**: Lickorish, *An Introduction to Knot Theory* (GTM 175, Springer 1997), §3.

**Cross-check**: These match KnotInfo's `jones_polynomial` column under the
variable convention $q$. Our TSV `_KNOT_TABLE` is populated from this source.

### 1.2 Kauffman bracket

Axioms:
- (B1) $\langle \text{unknot} \rangle = 1$.
- (B2) $\langle D \sqcup \text{unknot} \rangle = (-A^2 - A^{-2}) \langle D \rangle$.
- (B3) At a crossing: $\langle X \rangle = A \langle \smoothing_0 \rangle + A^{-1} \langle \smoothing_\infty \rangle$
  where $\smoothing_0$ is the **$A$-smoothing** — the smoothing obtained by
  rotating the overstrand counterclockwise $90°$ to meet the understrand.
  (Equivalent: the angular-region labelled $A$ is the one swept by the
  overstrand rotating counterclockwise.)
- **Crossing sign for $\sigma_i$ in braid $B_n$**: In the standard Birman
  convention, $\sigma_i$ is a POSITIVE crossing (overstrand goes right over
  left when viewed looking down the braid axis).

### 1.3 Alexander polynomial — reduced Burau

- **Representation**: $\overline{\rho}: B_n \to GL_{n-1}(\mathbb{Z}[t, t^{-1}])$.
- **Generator action** (Birman–Weinberg convention):
  $$\overline{\rho}(\sigma_i) = I_{i-2} \oplus \begin{pmatrix} -t & 1 \\ 0 & 1 \end{pmatrix} \oplus I_{n-i-2}$$
  for $1 \le i \le n-1$, with appropriate gluing on the boundary rows.
- **Alexander polynomial**:
  $$\Delta_{\widehat{\beta}}(t) = \frac{\det(I_{n-1} - \overline{\rho}(\beta))}{1 + t + t^2 + \cdots + t^{n-1}}$$
  defined **up to multiplication by $\pm t^k$** for some integer $k$.
- **Right-handed trefoil $3_1$**: $\Delta_{3_1}(t) = t^2 - t + 1$ (det $= 3$).
- **Figure-eight $4_1$**: $\Delta_{4_1}(t) = t^2 - 3t + 1$ (det $= 5$).

**Source**: Birman, *Braids, Links, and Mapping Class Groups* (AMS 1974), §3.
**Note**: A competing convention uses unreduced Burau (dim $n$); do NOT mix.

### 1.4 Knot determinant
$$\det(K) = |\Delta_K(-1)| = |V_K(-1)|.$$

### 1.5 Signature
Use the convention that right-handed $3_1$ has signature $\sigma(3_1) = -2$
(following KnotInfo / Livingston). Figure-eight has $\sigma(4_1) = 0$.

## 2. Hyperbolic invariants

### 2.1 Hyperbolic volume

- **Unit**: cubic units of hyperbolic 3-space $\mathbb{H}^3$ with curvature $-1$.
- **Reference values**:
  - $\mathrm{vol}(S^3 \setminus 4_1) = 2 \Lambda(\pi/3) \approx 2.0298832128$
    where $\Lambda$ is the Lobachevsky function.
  - $\mathrm{vol}(S^3 \setminus 5_2) \approx 2.8281220883$.
  - Torus knots, cable knots, satellites: volume **undefined** (non-hyperbolic).
- **Convention on non-hyperbolic manifolds**: we do NOT write "vol = 0". We
  write "$\mathrm{vol}$ is undefined (manifold is non-hyperbolic)" or
  equivalently "$M$ admits no hyperbolic structure". This is a categorical
  distinction, not a numerical one.

**Source**: Thurston, *The Geometry and Topology of 3-Manifolds* (Princeton
Lecture Notes 1979), §4–5, §7.

## 3. Mapping class group (for later rounds)

### 3.1 Twist direction
A **left Dehn twist** $T_\gamma$ about simple closed curve $\gamma$: cut along
$\gamma$, rotate one side 360° to the left (as viewed from outside the surface),
reglue. This is Farb–Margalit's convention and the standard one in MCG theory.

### 3.2 Relations
- Disjoint: $T_\alpha T_\beta = T_\beta T_\alpha$ if $\alpha \cap \beta = \emptyset$.
- Braid (adjacent): $T_\alpha T_\beta T_\alpha = T_\beta T_\alpha T_\beta$ if
  $|\alpha \cap \beta| = 1$ geometrically.
- Commute: $T_\alpha T_\beta = T_\beta T_\alpha$ if $|\alpha \cap \beta| = 0$.

**Source**: Farb–Margalit, *A Primer on Mapping Class Groups* (Princeton 2012), Ch. 3.

### 3.3 Lantern relation
On $\Sigma_{0,4}$ (4-holed sphere), with boundary twists $b_1, \dots, b_4$
and interior twists $x, y, z$ on the three essential curves:
$$x y z = b_1 b_2 b_3 b_4.$$

### 3.4 Chain relation
On a chain of curves $c_1, \dots, c_{2k+1}$ each intersecting the next once:
$$(T_{c_1} T_{c_2} \cdots T_{c_{2k+1}})^{2k+2} = T_{\partial_1} T_{\partial_2}.$$

## 4. Orientation & ambient isotopy

- **Knots in $S^3$**: unless stated otherwise, we work up to ambient isotopy,
  not regular isotopy. This means R1 (kinks) are allowed.
- **Oriented vs unoriented**: Jones polynomial is sensitive to mirror but not
  to orientation reversal for knots (it is sensitive for LINKS). Alexander
  polynomial is orientation-independent (returns $\Delta(t^{-1}) = \Delta(t)$
  up to $\pm t^k$).
- **Chirality**: "right-handed trefoil $3_1$" = the one with positive
  crossings under the right-hand rule; $3_1^m$ denotes mirror (left-handed).

## 5. When conventions conflict

If an external source (SnapPy, KnotInfo, Rolfsen, Kawauchi) disagrees with
this registry:
1. Note the discrepancy explicitly in the proof.
2. Use THIS registry for computation.
3. If the discrepancy is a mirror/sign artifact, both results are
   cross-checkable via $V_K(q) \leftrightarrow V_{K^m}(q^{-1})$.

## 6. Future additions

- HOMFLY-PT polynomial convention (deferred to when needed).
- Khovanov homology bigrading (deferred).
- Heegaard-Floer gradings (deferred).
- Teichmüller space metric choice (deferred).

---

*Maintained alongside `~/.claude/skills/math-verifier/tsv/tsv_knot.py`'s
`_KNOT_TABLE`. Keep the two in sync.*
