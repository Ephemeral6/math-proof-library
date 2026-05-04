# E6: Multi-Agent Verification Error Propagation (Problem 4.1)

**Path**: `proofs/research/multi-agent/verification/multi-agent-verification-error-propagation/`
**Source**: Inspired by Cumulative Reasoning (Zhang-Yang-Yuan-Yao 2023, arXiv 2308.04371)

## Verdict: NOVEL THEORETICAL FRAMING (CR paper is empirical)

## Our claim
- Part (a): single-shot Pr[chain correct] >= (1-epsilon)^T, tightness via honest-Proposer construction.
- Part (b): k-retry Pr[chain correct] >= (1 - epsilon^k)^T.
- Part (c): numerical instantiation at (epsilon, k, T) = (0.14, 3, 10): 22% -> 97%.

## Literature comparison
Cumulative Reasoning (CR) paper 2308.04371 is **primarily empirical**: it reports benchmark
gains (FOLIO 9.3% improvement, Game of 24 98%, MATH 4.2%). The paper's abstract and apparent
content do NOT contain formal probability bounds like (1-epsilon)^T or (1-epsilon^k)^T for
auditor-fixer reliability.

Therefore E6 is a NOVEL probabilistic formalization of an empirical framework. It is
mathematically elementary (i.i.d. Bernoulli, monotonicity of probability, product of
independent events), but the FRAMING — specifically the (1-epsilon^k)^T retry amplification
applied to a verifier loop — appears to be a fresh theoretical contribution.

## Assessment
- "Elementary but novel framing": YES. The math is undergraduate probability; the application
  to LLM verification chains is the original part.
- NOT a reproof of a known theorem: there is no published "auditor-fixer reliability theorem" in
  CR or related papers.

The TIGHTNESS construction in part (a) is the honest-Proposer instance and is correctly handled
(noting the cancellation pitfall from naive proposers).

The remark on independence assumption (verifier judgments may not be independent if the verifier
deterministically errs on hard propositions) is a thoughtful caveat.

## Discrepancies
None. The proof is internally consistent and clearly novel relative to the CR paper.

## Confidence: HIGH (within the elementary scope of the claim)
