# Notes: SSL InfoNCE Minimax Downstream Lower Bound

## Proof technique

**Winning route:** Reduction to Yang-Barron minimax estimation on SO(d), combined with
a Schur-complement analysis of the linear-probe gap.

The key insight: the d² rate emerges naturally from
- d² coming from the dimension of the orthogonal group SO(d) (≍ d(d−1)/2)
- 1/n from the Pinsker / Fano sample-complexity rate
- 1/I(X;X'|A) from the per-sample MI budget that bounds upstream learnability

Routes 1-3 all hit the d/(n·I) ceiling because they implicitly sup over w* alone with
fixed f*. The d² rate genuinely needs the *joint* sup.

## Key steps

1. σ-link to squared-loss reduction (1/16 constant).
2. Schur-complement decomposition of the optimal-probe gap.
3. DPI + chain rule for MI: I(V; samples^n) ≤ n · I(X;X'|A).
   - Crucial use of the SSL data-gen assumption: V enters only via positive-pair coupling.
4. Metric-entropy packing on SO(d): log M ∝ d² log(1/δ).
5. Fano + packing-separation amplification: G ≥ d · δ² with δ² ≍ d/(n·I).

## Audit result

Round 1: identified that initial routes were too pessimistic. Numerical sims
showed empirical d² rate, prompting reanalysis with joint adversary.
Round 2: PASS modulo log factors after correction.

## Honesty caveats (these matter)

1. **PARTIAL verdict, not PASS:** the bound holds up to logarithmic factors. The
   un-logged d²/(n·I) statement is genuinely tight only after Assouad's hypercube
   embedding (not attempted).

2. **Joint-vs-single sup:** the d² rate requires sup over (f*, w*). Sup over w*
   alone with fixed f* gives only d/(n·I). The problem's literal "sup_{w*}" notation
   is **misleading** — interpreted as "sup over the full minimax adversary" it is
   correct.

3. **‖w*‖² ≤ d normalization:** standard "each coordinate is O(1)" normalization for
   linear classifiers in d dimensions. With unit-ball ‖w*‖ ≤ 1, rate is d/(n·I).

4. **n_down dependence:** absent from the bound — we assumed population probe
   ŵ_∞(f_θ). Finite n_down adds independent O(d/n_down) ERM term.

5. **SSL data-gen assumption:** essential for the MI bound. If f* leaks information
   into upstream samples through channels other than the positive-pair coupling
   (e.g., independent noise that happens to depend on f*), the MI bound fails.

## Related results

- Saunshi et al. (2019), "A Theoretical Analysis of Contrastive Unsupervised
  Representation Learning": upper-bound side of contrastive-learning theory; provides
  the matching upper bound for InfoNCE under the same assumptions.
- HaoChen, Wei, Gaidon, Ma (2021), "Provable Guarantees for Self-Supervised Deep
  Learning with Spectral Contrastive Loss": spectral-decomposition characterization
  of the SSL feature; the d² rate aligns with the spectral gap of the augmentation
  graph in their framework.
- Yang & Barron (1999), "Information-theoretic determination of minimax rates of
  convergence": the metric-entropy lower-bound technique used here.
- Tsybakov (2009), "Introduction to Nonparametric Estimation", Ch. 2 (Le Cam, Fano):
  the standard reference for the lower-bound machinery.

## Open questions

- Closing the log gap via Assouad's hypercube method.
- Sharpening to handle the *finite* n_down case explicitly.
- Extending beyond binary downstream tasks (multiclass, regression) — the σ-link
  argument needs adaptation.
- Analyzing when I(X;X'|A) itself is small (bad augmentation) — the bound becomes
  vacuous when n·I(X;X'|A) ≪ d², matching intuition that with no augmentation
  signal, SSL cannot extract useful representations.
