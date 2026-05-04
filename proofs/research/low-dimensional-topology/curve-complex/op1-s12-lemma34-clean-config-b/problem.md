# Lemma 3.4''-clean (OP-1 closure on S_{1,2}, config (b))

## Source
- Problem: OP-1 (descending-link contractibility for the curve complex of S_{1,2})
- Context: Closing the last open piece of OP-1 on S_{1,2}, the only outstanding case being i(γ_0, α) = 2 in configuration (b) (both punctures on the same side of α ∪ γ_0)
- Related: Hatcher 1991 (arc complex), Bestvina–Brady 1997 (descending links), Penner–Harer 1992 (train tracks), Bonahon 1986 (intersection number formulas)

## Statement

**Lemma 3.4''-clean.** Let S = S_{1,2} (genus-1 orientable surface with 2 punctures), γ_0 a fixed essential non-separating simple closed curve, and α an essential simple closed curve with i(γ_0, α) = 2 in configuration (b) (i.e., the two arcs of α on Σ_{0,4} = S \ γ_0 separate the surface into a pair of pants R_{pp} containing both punctures and a disk R_∅).

Let DL(α) denote the descending link of α in the level-1 stratum, defined as the graph with:
- Vertices: level-1 simple closed curves β (i.e., i(γ_0, β) = 1) such that i(α, β) = 1
- Edges: pairs (β, β') with i(β, β') ≤ 1

Then DL(α) is one of:

(i) A JOIN $K_2 \vee G_{\text{outer}}$, where $K_2$ consists of the two consecutive γ_0-twists of an arc representing α on Σ_{0,4} (= the cone vertices), and $G_{\text{outer}}$ is some graph on |DL(α)| - 2 vertices.

(ii) The graph $G^\star = K_4 + 4\text{-paired-leaves}$: 8 vertices with degree sequence (6, 6, 6, 6, 3, 3, 3, 3), where the K_4 vertices form a complete subgraph, each of the 4 leaves has degree 3 connecting to 3 of the 4 K_4 vertices, and each leaf is paired with a unique K_4 vertex (the one it doesn't connect to).

Case (i) occurs iff α has parallel arcs on Σ_{0,4} (the multi-arc decomposition is 2[C] for a single arc class C). Case (ii) occurs iff α has non-parallel arcs ([C_1] + [C_2] for distinct classes).

## Difficulty
research

## Significance
This lemma closes the last open piece of OP-1 (descending-link contractibility for C^1(S_{1,2})). Combined with prior results for k = i(γ_0, α) ≥ 3 and k = 2 configuration (a), it completes the proof that C^1(S_{1,2}) is contractible — a key ingredient in studying the Bestvina–Brady Morse theory of the curve complex.

## Notation
- S = S_{1,2}: genus-1 orientable surface with 2 punctures
- γ_0: a fixed essential non-separating simple closed curve
- Σ_{0,4} = S \ γ_0: the four-holed sphere obtained by cutting
- C^1(S): the first stratum of the curve complex
- α, β: simple closed curves on S
- i(α, β): geometric intersection number
- T_γ: Dehn twist along γ
- DL(α): descending link of α in C^1(S)
