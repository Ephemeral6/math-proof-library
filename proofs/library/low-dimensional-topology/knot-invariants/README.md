# Library / Low-Dimensional Topology / Knot Invariants

B- and C-class reusable lemmas on classical knot invariants.

## What belongs here

- Jones polynomial properties (skein relation, multiplicativity, mirror behavior, value at specific roots of unity)
- Alexander polynomial properties (determinant, signature relation, fibering obstruction)
- Kauffman bracket computations and state-sum identities
- Signature, determinant, genus, unknotting number basic properties
- HOMFLY/Kauffman two-variable relations
- Computations for named knots: trefoil (3_1), figure-eight (4_1), torus knots T(p,q), twist knots

## Role in the system

Explorer may reference these as `[REF: proofs/library/low-dimensional-topology/knot-invariants/jones-trefoil/proof.md]` instead of recomputing.

## TSV integration

Most entries here should be ground-truth verifiable via `tsv/tsv_knot.py`. Whenever a library entry states a closed-form invariant, the accompanying `notes.md` should include the TSV verification command that confirmed it.
