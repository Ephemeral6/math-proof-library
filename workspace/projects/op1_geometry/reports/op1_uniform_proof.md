---
title: "OP-1 uniform proof attempt — honest negative report"
subtitle: "Why the 389/389 enumerated closure does NOT yet upgrade to a $\\forall (g,\\xi,k)$ theorem, and what the true gap is"
date: "2026-05-01"
author: "Autonomous attempt log"
---

# Status: NOT closed

After ~1 hour of literature search, careful re-reading of `op1_complete_report.md` / `bigon_cancellation_proof.md` / `op1_report_for_senior.md`, and analysis of where the empirical 389/389 closure does and does not generalize, **I did not produce a uniform proof of `Lk↓(α) contractible for all g≥1, ξ≥1, k≥2`**. Souto's question on contractibility of $C_1(S_{g,n})$ remains open in published literature (the cross-reference to Przytycki–Sisto 1502.02176 attributing "Question 2" to Souto could not be corroborated in a search; the framing as an open problem is consistent with all 2015–2026 results located).

This file is the honest debrief: what is already uniform, what is finite-data only, where the precise gap is, and which two routes are most promising for a follow-up. The 389/389 closure in `op1_complete_report.md` stands — but it is finite verification, not a theorem.

---

# 1. What is already uniform (no surface-specific finite data)

These pieces of the existing pipeline are surface- and $k$-uniform proofs in the strict sense, and they survive any future closure attempt unchanged.

| Statement | Proof | Status |
|---|---|---|
| **§3.3** $C_1^{(1)}(S_{g,n})$ connected for $g \ge 1, \xi \ge 1$ | Lickorish/Humphries + Putman + Dehn-twist formula | ✅ uniform |
| **§3.4** $C_1^+(S_{g,n})$ contractible (with peripherals, $n \ge 1$) | peripheral curve is universal vertex | ✅ uniform |
| **§3.5–3.8** BB-filtration reduction: $C_1$ contractible $\Leftarrow$ every $\mathrm{Lk}^\downarrow(\alpha)$ at $k \ge 2$ contractible | Bestvina–Brady [BB97] template | ✅ uniform |
| **§3.6** $k = 1$ DLs contractible ($\gamma_0$ universal) | direct check | ✅ uniform |
| **Lemma 2.1** (single-step bigon cancellation) **conditional** on $\sigma_\alpha$ being a valid $C_1$-vertex: $\,i(\sigma_\alpha,\beta) = i(\alpha,\beta)$ for all $\beta \in \mathrm{Lk}^\downarrow(\alpha)$ | Hass–Scott bigon criterion + $[\sigma_\alpha]=[\alpha]$ in $H_1(\mathbb Z)$ for parity | ✅ uniform (proof never uses $S_{1,2}$-specific data) |

The crucial point about Lemma 2.1 is that **its proof does not depend on the surface or on $k$**: it is a disc-arc-decomposition argument plus a one-line homology fact. *If* an essential non-peripheral $\sigma_\alpha$ at level $\le k-2$ exists with $i(\sigma_\alpha, \alpha) = 0$, then by Lemma 2.1 it is a universal vertex of $\mathrm{Lk}^\downarrow(\alpha)$, hence the DL is a simplicial cone, hence contractible.

**The entire uniform proof, if it exists, hinges on filling exactly one missing piece:**

> **(★) Surgery existence.** For every $\alpha$ on $S_{g,n}$ with $g \ge 1$, $\xi \ge 1$, $f(\alpha) = k \ge 2$, there exists an adjacent pair $(p_j, p_{j+1})$ along $\alpha \cap \gamma_0$ whose innermost disc $D \subset S$ is *puncture-free*. Then the Hatcher output $\sigma_\alpha = a_L \cup g_S$ is essential and non-peripheral, hence a valid vertex of $C_1$, hence a universal vertex of $\mathrm{Lk}^\downarrow(\alpha)$ (Lemma 2.1). $\Rightarrow \mathrm{Lk}^\downarrow(\alpha)$ contractible.

(★) is **false in general**, by the empirical data — see §3 below.

---

# 2. The 389/389 closure is finite-data, not a theorem

The closure relies on three case-by-case verifications, each tied to a specific surface and $k$-window:

1. **$S_{1,1}$, $k \le 8$.** Closed via Stern–Brocot ($|\mathrm{Lk}^\downarrow| \le 2$). This actually IS uniform on $S_{1,1}$ — but it does not generalize to other surfaces.
2. **$S_{1,2}$, $k \le 8$.** 259/271 closed via PEO chordality (computer-checked); the 12 non-chordal DLs split into 6 single-step bigon (Lemma 2.1 applied — uniform argument *given* a valid $\sigma_\alpha$, which exists on these 6) and 6 multi-step (Lemma 4.1, conditional on a finite-data $H_1(\mathbb Z/2)$ check that the bigon proof file itself flags as "**not auto-satisfied on other surfaces** … on $S_{2,1}$ at least 5 alphas exhibit $[\sigma_\mathrm{curver}] \ne [\alpha]$").
3. **$S_{2,1}$, $k \le 4$.** 41/47 cone (Hatcher), 6/47 two-step almost-cone (Lemma 7.1, uniform on graphs but the existence of $(v_1, v_2, w)$ on each of the 6 specific DLs is a finite check).

For "all $g \ge 1, \xi \ge 1$, all $k \ge 2$": this enumeration covers a vanishing fraction. Higher genus, higher $n$, higher $k$ are all unhandled.

---

# 3. Where the proof breaks past the enumerated dataset

The deepest obstruction is failure of (★) at small $k$. Concretely:

**The 6 universal-vertex counterexamples on $S_{1,2}$ at $k = 2$** ($\alpha \in \{25, 72, 149, 208, 217, 218\}$) have a uniform structure: $\mathrm{Lk}^\downarrow(\alpha)$ is the 8-vertex graph $K_4 + 4$ leaves, each leaf attached to 3 of 4 core vertices. **No vertex has degree 7**, so no universal vertex exists. (`analyze_no_universal.py`.)

By Lemma 2.1, *if* the Hatcher single-step output $\sigma_\alpha$ were essential and non-peripheral, $\sigma_\alpha$ would be a universal vertex of $\mathrm{Lk}^\downarrow(\alpha)$. The contrapositive forces:

> **Diagnosis.** For each of the 6 alphas, every possible Hatcher single-step output $\sigma_\alpha$ is **either null-homotopic or peripheral on $S_{1,2}$**, hence not a vertex of $C_1$ (E3 convention).

A homology argument rules out null-homotopic ($[\sigma_\alpha] = [\alpha] \ne 0$ in $H_1(S; \mathbb Z)$, since $\sigma_\alpha - \alpha = \partial D$). So **$\sigma_\alpha$ is peripheral**.

The geometric reason: for $S_{1,2}$ at $k=2$, $\alpha$ has only 2 intersection points with $\gamma_0$, hence one adjacent pair, hence two candidate discs $D_+, D_-$ (one on each side of $\gamma_0$ between $p_1, p_2$). At $k=2$, both candidate discs together exhaust the complement of $\alpha \cup \gamma_0$ "between the punctures." For these 6 alphas, **both candidate discs contain a puncture**, so any Hatcher output bounds (with the leftover arc) a once-punctured disc, i.e., is peripheral.

**This pattern generalizes**: whenever $S_{g,n}$ has $n \ge 1$ punctures and $k$ is small enough that no puncture-free innermost disc exists, (★) fails. The threshold scales with $n$.

---

# 4. The four obstructions to a uniform theorem

Boiled down, four things would need to be proved uniformly to upgrade the 389/389 closure into a theorem:

**(O1) Surgery output essential and non-peripheral.** Equivalent to (★). False for the 6 $S_{1,2}$ $k=2$ alphas. A natural conditional version — "(★) holds whenever some adjacent pair has a puncture-free innermost disc" — is straightforward (cf. §5 below), but the existence of such a pair is the actual content.

**(O2) Multi-step homology preservation.** Lemma 4.1 hypothesis (b) `$[\sigma_\mathrm{curver}] = [\alpha]$ in $H_1(\mathbb Z/2)$` is verified 12/12 on $S_{1,2}$, but the bigon-proof file itself documents 5+ counterexamples on $S_{2,1}$. So Lemma 4.1's empirical pattern is an artifact of $S_{1,2}$, not a general fact.

**(O3) Chordal-or-cone dichotomy uniformly.** 6 of 47 $S_{2,1}$ DLs are neither chordal nor cones; closed via Lemma 7.1 (almost-cone). For higher genus or higher $n$, no comparable enumeration exists, and the dichotomy could fail more dramatically (e.g., $G$ neither chordal nor cone nor almost-cone).

**(O4) The puncture-disc existence problem.** For each $\alpha$ at level $k$, must show there's at least *one* adjacent pair whose disc avoids all punctures. This is a subtle counting / pigeonhole question on $S_{g,n}$. It fails when $k$ is small and $n$ is large — in fact, for $k = 2$ and $n \ge 2$, both candidate discs can each contain a puncture (the 6 cases on $S_{1,2}$).

---

# 5. The most promising direction (a sketch, NOT a proof)

The cleanest split is:

**Case A — large $k$ (say $k \ge 2 n + 2$).** Pigeonhole: there are $k$ intersection points $p_1, \dots, p_k$ along $\gamma_0$, hence $k$ candidate adjacent-pair discs (each side of each consecutive pair gives a candidate). With $n$ punctures total, at least $k - n$ adjacent pairs have a puncture-free candidate disc on one side. For $k \ge n + 2$ this is non-empty, so (★) holds and Lemma 2.1 closes the DL via the universal-vertex argument.

The actual threshold may be tighter (e.g., $k \ge 4$ may suffice on most $S_{g,n}$ — the 12 non-chordal $S_{1,2}$ cases at $k \ge 4$ all have a working surgery), but the qualitative claim is: large-$k$ DLs uniformly admit a Hatcher universal vertex.

**Case B — small $k$ (specifically $k = 2$).** Here adjacent-pair surgery may fail (★). Two sub-routes:

*(B1) Direct chordality.* Empirically all $k = 2$ DLs on $S_{1,2}$ are chordal. Conjecture: for every $\alpha$ at $k = 2$ on any $S_{g,n}$, $\mathrm{Lk}^\downarrow(\alpha)$ is chordal. If true, PEO closes the DL. Proving this requires understanding the structure of "level-$\le 1$ curves with $i(\cdot, \alpha) \le 1$" — feasible but non-trivial. The $K_4 + 4$ leaves structure suggests the cycle structure is controlled by $\alpha$'s topology.

*(B2) Subsurface reduction.* When all surgery discs contain punctures, the curve $\alpha$ "encloses" punctures in a structured way, and $\mathrm{Lk}^\downarrow(\alpha)$ should reduce to a curve complex on a smaller subsurface. Then induction on $\xi(S)$ closes the DL.

**Threshold $k = 3, \dots, 2n+1$**: requires combining A and B. Likely the messiest part.

If one can prove either (B1) (a small-$k$ chordality theorem) or (B2) (a subsurface induction), combined with the large-$k$ pigeonhole argument, the whole problem closes.

---

# 6. Honest assessment of feasibility

**The single-step bigon cancellation argument (Lemma 2.1) is genuinely one of the core technical ingredients** — its uniformity is the most surprising and useful piece of the existing pipeline. Two further uniform inputs would suffice:

(i) a clean statement of (★) with hypothesis "an adjacent pair has a puncture-free innermost disc" — call it **Lemma 2.1+**, which is roughly 1–2 pages of proof from Lemma 2.1 plus a homotopy-class-preservation argument across the disc $D$;

(ii) an existence theorem for puncture-free adjacent pairs at $k \ge $ some explicit threshold $T(g, n)$.

(i) is bookkeeping. (ii) is the real mathematical question, and it is not yet visible in the literature.

For $k < T(g, n)$, separate handling is required, and the small-$k$ DLs may need a chordality theorem of their own.

**Why this is hard**: the augmented-curve-graph contractibility question (Souto, framed publicly via Przytycki–Sisto's quasi-isometric statement) has been explicitly open since ~2007, despite heavy investigation of the standard curve complex's analogous properties (Hatcher 1991, Harer, Putman 2008, Hensel–Przytycki–Webb 2015). The available proof techniques — Hatcher surgery, Putman's trick, Bestvina–Brady, Chepoi–Osajda systolicity — have all been tried (under different names) in the user's seven-iteration log. None yields a uniform closure without a new geometric idea.

The 389/389 closure provides extremely strong empirical confidence and identifies the *right* universal vertex candidate ($\sigma_\alpha$ = Hatcher single-step output). It is one geometric lemma — a quantitative version of (★) with a constructive existence argument — short of a theorem.

---

# 7. Concrete next steps for a future attempt

Anyone resuming this should:

1. **Write down Lemma 2.1+ explicitly.** Statement: *"If $\alpha$ on $S_{g,n}$ ($g \ge 1, \xi \ge 1$) is essential and non-peripheral, $f(\alpha) = k \ge 2$, $(p_j, p_{j+1})$ is an adjacent pair along $\alpha \cap \gamma_0$ whose innermost disc $D$ is puncture-free, then $\sigma_\alpha = (a_L \cup g_S)$ (smoothed) is essential and non-peripheral, $i(\sigma_\alpha, \alpha) = 0$, $f(\sigma_\alpha) \le k - 2$, and $\sigma_\alpha$ is a universal vertex of $\mathrm{Lk}^\downarrow(\alpha)$."* The proof is short: essentialness from $[\sigma_\alpha] = [\alpha] \ne 0$; non-peripheral from a $D \cup D'$ contradiction (if $\sigma_\alpha = \partial D'$ peripheral with $D'$ a once-punctured disc, then $D \cup_{g_S} D'$ is a once-punctured disc bounded by $\alpha$, so $\alpha$ peripheral — contradiction); universal-vertex from Lemma 2.1.

2. **Attack the existence of puncture-free adjacent-pair discs.** Prove or disprove: for $k \ge 2(n + 1)$, some adjacent pair has a puncture-free innermost disc. This is a discrete-geometry / pigeonhole question on the cyclic structure of $p_1, \dots, p_k$ along $\gamma_0$ relative to the punctures. If true, this disposes of all $k \ge 2(n+1)$.

3. **Resolve the small-$k$ residue.** For $2 \le k < 2(n+1)$, prove chordality of the DL via a direct combinatorial argument. The $K_4 + 4$ leaves pattern at $k = 2$ on $S_{1,2}$ is suggestive: it should be characterized by the puncture-encircling structure of $\alpha$.

4. **Verify the closure on at least one more surface.** Run the entire pipeline on $S_{2,2}$ or $S_{3,1}$ to expose any pattern that fails outside the current dataset (the $S_{2,1}$ multi-step homology counterexamples are the canary here — beware that conditional lemmas tuned to $S_{1,2}$ may break elsewhere).

Item 1 is ~half a day of writing. Item 2 is the actual research problem. Items 3–4 are auxiliary.

---

# Files referenced

- `workspace/projects/op1_geometry/reports/op1_complete_report.md` (14-page primary report; all 389/389 closure work)
- `workspace/projects/op1_geometry/reports/bigon_cancellation_proof.md` (Lemma 2.1, 4.1, 7.1; the rigorous core)
- `workspace/projects/op1_geometry/analyze_no_universal.py` (the 6 $K_4 + 4$ leaves alphas)
- `workspace/projects/op1_geometry/exhaustive_k2.py` (all 64 $S_{1,2}$ DLs at $k = 2$)

# Bottom line

OP-1 is closed on enumerated data, **not** as a theorem for arbitrary $g, n, k$. The cleanest path forward is the two-step plan in §5–7: (i) write Lemma 2.1+ explicitly, (ii) prove the puncture-free-disc existence theorem at large $k$, (iii) handle small-$k$ chordality separately. The geometry of (ii) is the genuinely open piece.
