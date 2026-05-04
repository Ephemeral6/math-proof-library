# Library / Low-Dimensional Topology / Simplicial Complexes

B- and C-class lemmas supporting curve complex / arc complex arguments.

## What belongs here

- Flag complex conditions and verifications
- Link / star local structure lemmas
- Path-length / distance-at-most-k arguments for explicit finite subcomplexes
- Farey graph facts (finite pieces of it)
- Simple connectedness / contractibility of specific subcomplexes
- Finite neighborhood computations in the curve complex C(S)

## TSV integration

`tsv/tsv_simplicial.py` is TOY-LEVEL. Only finite local subcomplexes can be ground-truth checked. Any entry appealing to global hyperbolicity of C(S) must carry an `[UNVERIFIABLE: global-property]` tag.

## Warning

This folder is the main place where the honest acknowledgment "we cannot formally verify infinite-complex properties" lives. Do NOT push global results (Masur–Minsky hyperbolicity, uniform hyperbolicity) here; those belong in `proofs/research/low-dimensional-topology/curve-complex/`.
