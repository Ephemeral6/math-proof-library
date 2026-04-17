# Proof Report: OFUL Linear Bandit Regret Bound

## 1. Problem Statement
Prove Regret(T) ≤ 2β_T√(2Td ln(1+TL²/(λd))) for OFUL under L-smoothness, sub-Gaussian noise, λ ≥ L².

## 2. Phase Summary
| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed, top 4 selected |
| Explorer | Opus | 4 proofs attempted, all succeeded |
| Judge | Sonnet | Route 4 selected (34/40) |
| Audit R1 | Opus | FAIL — β_t simplification error, λ≥L² undeclared |
| Fix R1 | Opus | 5 issues fixed |
| Audit R2 | Opus | PASS |

## 3. Routes Explored
| Route | Score | Key Feature |
|-------|-------|-------------|
| 1 (Four-Step) | 21/40 | Wrong file path, incomplete record |
| 2 (Ridge Error) | 24/40 | Many false starts on potential lemma |
| 3 (Potential-First) | 31/40 | Clean modular, self-normalized as black-box |
| **4 (Martingale-First)** | **34/40** | **Self-normalized from scratch via mixture martingale** |

## 4. Final Proof
Mixture martingale M_t → supermartingale → Ville's inequality → self-normalized bound → confidence ellipsoid → optimism → Cauchy-Schwarz → elliptical potential. Rate: Õ(d√T).

## 5. Audit Result
Round 1 FAIL (5 issues), Round 2 PASS (all fixed).

## 6. Fix History
1. β_t: exact form with 2ln(1/δ) (valid for d=1)
2. L_t uses A_t not V_t (no double-counting)
3. λ ≥ L² explicit hypothesis
4. β_{t-1} indexing
5. Unified log argument
