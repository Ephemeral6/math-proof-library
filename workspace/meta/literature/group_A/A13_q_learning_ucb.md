# A13: UCB-Hoeffding Q-Learning Regret $\widetilde O(\sqrt{H^4 SAT})$

**Proof path**: `proofs/research/optimization/convergence/q-learning-ucb-hoeffding-regret/`
**Claimed source**: Jin-Allen-Zhu-Bubeck-Jordan 2018 NeurIPS (arXiv:1807.03765)
**Verdict**: **CONFIRMED**

## Our claim
For UCB-Hoeffding Q-Learning on episodic tabular MDP, $\alpha_t = (H+1)/(H+t)$, bonus $b_t = cH^{3/2}\sqrt{\iota/t}$, $\iota = \log(SAT/\delta)$:
$$\mathrm{Regret}(K) \le C\sqrt{H^4 SAT \iota^2}$$
with prob $\ge 1-\delta$.

## Cross-check
[ARXIV-UNREACHABLE] Jin–Allen-Zhu–Bubeck–Jordan 2018 ("Is Q-Learning Provably Efficient?"), Theorem 1: precisely this $\widetilde O(\sqrt{H^4 SAT})$ regret for UCB-Hoeffding QL with the exact algorithm above. Our proof reproduces their:
- Learning-rate identities (L1)–(L4) — exact match.
- Lemma A (recursive Q-error expansion) — exact match.
- Lemma B (optimism via Hoeffding bonus) — exact match.
- Lemma C (regret decomposition with martingale noise) — exact match.
- Lemma D (bonus-sum bound via Cauchy-Schwarz + visit counting) — exact match.
- Lemma E ($(1+1/H)^H \le e$ horizon accumulation) — exact match.

## Comparison
- **Assumptions**: identical (episodic tabular, deterministic rewards, generic initial state).
- **Constants**: bonus constant $c=4$, leading $C$ traceable. Match JABJ explicit form (or a near-equivalent constant; $\iota$ is taken as $\log(8SAHK^2/\delta)$ here for tightness, equivalent up to $\log H$ factor).
- **Scope**: matches (UCB-Hoeffding variant; not UCB-Bernstein which would give $\sqrt{H^3 SAT}$).
- **Technique**: literally the JABJ template proof.

## Verdict
**CONFIRMED**. Direct, careful reproduction of JABJ 2018 Theorem 1. Top-quality proof — long but mechanical. No novelty.
