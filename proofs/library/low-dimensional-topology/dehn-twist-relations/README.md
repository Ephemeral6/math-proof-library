# Library / Low-Dimensional Topology / Dehn-Twist Relations

B- and C-class results on Dehn twists and the presentation of MCG(S_{g,n}).

## What belongs here

- Braid-like relation between twists on disjoint curves
- Braid relation between twists on curves intersecting once
- Chain relation
- Lantern relation (derivation and consequences)
- Hyperelliptic / chain / 2-chain relations
- Wajnryb presentation (and Humphries generators)
- Conjugation-by-twist formulas
- Nielsen realization basics

## Why its own folder (not folded into mapping-class-groups)

MCG results frequently need a specific twist identity; isolating these makes `[REF:]` cleaner.

## TSV integration

`tsv/tsv_group.py` provides `check_lantern_relation`, `check_chain_relation`, and `apply_dehn_twist`. Entries must cite Farb–Margalit Primer, Chapter 3 or 5, for reference text.
