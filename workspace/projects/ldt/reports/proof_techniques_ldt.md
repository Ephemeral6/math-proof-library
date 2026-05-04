# LDT Proof Techniques Dictionary (seed)

> Created: 2026-04-20 (Stage 1.4 of LDT extension)
>
> **This dictionary starts thin on purpose.** It will grow with the library. Scout (`scout.md` Step 0) should read this file alongside `proof_techniques_summary.md` and `failure_patterns.md`. Only the five keyword areas from the collaborator are seeded.
>
> Updates policy: after every archived LDT proof, Step F (archival) appends any new technique or refines an existing one — one paragraph per technique, cite the proof that exhibited it.

---

## 1. Knot theory (纽结理论)

### 1.1 Skein-relation computation
Apply the Jones / HOMFLY skein at an arbitrary crossing to reduce a diagram to simpler diagrams. Always pick the crossing that reduces the complexity (fewer crossings after the 0-smoothing, or a known link). The recursion terminates because total crossing number strictly decreases in at least one branch.
- When it works: polynomial invariants of small-crossing knots; distinguishing knots when you only need polynomial equality/inequality.
- TSV ground-truth: `tsv_knot.jones_polynomial(name)` / `alexander_polynomial(name)` for named small knots.
- Pitfall: sign of Jones polynomial depends on orientation/writhe convention; right-handed vs. left-handed trefoil have mirror polynomials.

### 1.2 State sum (Kauffman bracket)
Write `<D> = A <D_0> + A^{-1} <D_∞>` for each crossing, iterate, and count resulting circles. `V(q) = (-A)^{-3w} <D>|_{A=q^{-1/4}}`. Good when a diagram is small and you want to compute by hand without a CAS.
- TSV ground-truth: `tsv_knot.kauffman_bracket(name)` derived from Jones.
- Pitfall: planar-arc matching is easy to get wrong on paper — always count circles carefully.

### 1.3 Burau representation → Alexander polynomial
Represent a braid `β ∈ B_n` as a product of reduced Burau matrices over ℤ[t, t^-1]. Then `Δ(closure(β))(t) = det(I - β) / (1 + t + ⋯ + t^{n-1})` up to units.
- TSV ground-truth: `tsv_knot.alexander_polynomial` for named knots; best-effort Burau path for B_2.
- Pitfall: signs and the unit (t^k) normalization. Normalize so `Δ(1) = ±1` and the constant coefficient is positive.

### 1.4 HOMFLY specialization
`V(q) = P(a=-q^{-3/2}, z=q^{-1/2}-q^{1/2})` (Jones) and `Δ(t) = P(a=1, z=t^{1/2}-t^{-1/2})` (Alexander) — both are specializations of HOMFLY. Use to derive relations between Jones and Alexander of the same knot.
- Reference only in current seed dictionary; no TSV ground-truth yet.

### 1.5 Hyperbolic-volume obstruction (Gromov–Thurston)
If vol(S^3 \ K) ≠ vol(S^3 \ K'), then K and K' are distinct. Torus knots (including trefoil) have volume 0 (non-hyperbolic), so trefoil vs. figure-eight is detectable via volume alone.
- TSV ground-truth: `tsv_knot.hyperbolic_volume(name)` for small knots.
- Pitfall: volume detects only the complement's hyperbolic structure; non-hyperbolic knots need other invariants.

## 2. Mapping class groups (映射类群)

### 2.1 Picture proof vs. algebraic reduction
MCG identities admit two styles: (a) "picture" — draw the twisted surface, observe geometric equivalence; (b) "algebraic" — reduce words via the Artin + lantern + chain relations.
- System policy: Explorer may produce picture proofs, but Auditor REQUIRES that any picture step be accompanied by either a TSV-Group check (`check_lantern_relation`, etc.) OR an `[UNVERIFIABLE: picture]` tag. Fixer's job is to convert to algebra where possible.
- Pitfall: orientation matters; a "right-handed twist" and its mirror are distinct elements.

### 2.2 Lantern + chain + braid: the "three standard relations"
Almost every MCG computation below genus 3 can be reduced to:
  - braid relation (twists on curves with i=1): `T_a T_b T_a = T_b T_a T_b`
  - commuting relation (twists on disjoint curves): `T_a T_b = T_b T_a`
  - lantern relation (on the 4-holed sphere): `T_x T_y T_z = T_a T_b T_c T_d`
  - chain relation (on a chain of length 2g+1 or 2g+2).
- TSV ground-truth: `tsv_group.check_braid_between_twists`, `check_commuting_disjoint_twists`, `check_lantern_relation`, `check_chain_relation`.

### 2.3 Birman exact sequence
Relates MCG(S) to MCG(S with one less puncture/boundary) and π_1. Use for inductive arguments on complexity.
- Reference only; requires careful statement.

## 3. Curve complex (曲线复形)

### 3.1 Subsurface projection (Masur–Minsky)
For a subsurface Y ⊂ S, project a curve γ to C(Y) by intersecting γ with Y and taking the arc/curve complex of the intersection. The projection is coarsely well-defined.
- Reference only (global technique, outside TSV scope).

### 3.2 Hierarchical decomposition
For two curves α, β at large distance in C(S), a Masur–Minsky hierarchy is a tree of geodesics in C(subsurfaces) realizing the distance up to a uniform additive constant.
- Reference only; used in virtual fibering and various MCG rigidity results.

### 3.3 Finite-neighborhood argument (toy-but-useful)
For specific small cases, compute distances in C(S) by exhibiting an explicit path of curves. Only works for small surfaces (e.g., Σ_{0,4}, Σ_{1,1} where C(S) is the Farey graph).
- TSV ground-truth: `tsv_simplicial.verify_simplicial_distance_upper_bound`.

## 4. 3-manifold machinery (三维流形的几何与拓扑) — reference only

The agent does NOT currently have verification coverage of these. Any proof step that invokes them must be tagged `[REF:external]` or `[UNVERIFIABLE: 3-manifold-machinery]`.

- JSJ decomposition (Jaco–Shalen–Johannson)
- Geometrization (Perelman–Thurston)
- Heegaard splitting / Heegaard distance
- Heegaard Floer / monopole Floer / embedded contact
- Dehn surgery and exceptional fillings

## 5. Teichmüller theory (Teichmüller 理论) — reference only

- Quasiconformal maps, Beltrami differentials
- Extremal length
- Quadratic differentials and their moduli
- Teichmüller metric and geodesic flow
- Mirzakhani volume recursion

All of these require analytical machinery outside current TSV scope. Tag `[UNVERIFIABLE: Teichmüller-machinery]` when invoked.

---

## Honest disclaimer (Stage 1)

**This dictionary is seeded with 10 techniques; the optimization dictionary has 36.** Scout SHOULD NOT hallucinate that it is complete. When an LDT proof requires a technique not listed here, Scout must mark the route with `[TECHNIQUE-NEW]` and record a 1-paragraph description so Step F can add it after the proof archives. Round 0 will expose gaps; expansion happens in Stage 3 and onward.

## Growth log

| Date | Added technique | Exhibiting proof |
|------|-----------------|------------------|
| 2026-04-20 | seeded 10 items | none (Stage 1.4 seed) |
