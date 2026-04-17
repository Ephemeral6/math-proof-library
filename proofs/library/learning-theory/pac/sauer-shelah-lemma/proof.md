# Proof of Sauer-Shelah Lemma

We prove both parts of the Sauer-Shelah Lemma.

## Part A: $\Pi_{\mathcal{H}}(n) \leq \sum_{i=0}^{d}\binom{n}{i}$

We prove: for any set system $F \subseteq 2^{[n]}$ with VC dimension $\leq d$:

$$|F| \leq \Phi(d,n) = \sum_{i=0}^{d}\binom{n}{i}$$

We use the Pascal-type identity: $\Phi(d, n) = \Phi(d, n-1) + \Phi(d-1, n-1)$.

*Proof of identity:* $\Phi(d, n) = \sum_{i=0}^{d} \binom{n}{i} = \sum_{i=0}^{d} \left[\binom{n-1}{i} + \binom{n-1}{i-1}\right] = \Phi(d, n-1) + \Phi(d-1, n-1)$, using Pascal's rule and the substitution $j = i-1$. □

**Proof by induction on $n$.**

**Base cases.**
- $n = 0$: $|F| \leq 1 = \Phi(d, 0)$. ✓
- $d = 0$: VCdim$(F) = 0$ means for every $j \in [n]$, either all sets in $F$ contain $j$ or none do. So $|F| = 1 = \Phi(0, n)$. ✓  
- $n \leq d$: $|F| \leq 2^n = \sum_{i=0}^{n}\binom{n}{i} = \Phi(d, n)$ (since $\binom{n}{i} = 0$ for $i > n$). ✓

**Inductive step.** Assume the result for set systems on $[n-1]$. Let $F \subseteq 2^{[n]}$ with VCdim$(F) \leq d$, $n \geq 1$, $d \geq 1$, $n > d$.

Fix element $n$. Define:
- $F_0 = \{A \in F : n \notin A\}$ (viewed as subsets of $[n-1]$)
- $F_1 = \{A \setminus \{n\} : A \in F, n \in A\}$ (subsets of $[n-1]$)
- $G = F_0 \cup F_1$ (the projection of $F$ onto $[n-1]$)
- $D = F_0 \cap F_1$ (the "duplicated" patterns)

**Counting identity:** $|F| = |F_0| + |F_1| = |G| + |D|$.

*Proof:* $|F| = |F_0| + |F_1|$ since the sets containing $n$ and not containing $n$ partition $F$, and each map to $[n-1]$ is injective. Then $|F_0| + |F_1| = |F_0 \cup F_1| + |F_0 \cap F_1| = |G| + |D|$ by inclusion-exclusion. □

**Bound on $|G|$:** VCdim$(G) \leq d$.

*Proof:* If $G$ shatters $T \subseteq [n-1]$, then for each $U \subseteq T$ there exists $B \in G$ with $B \cap T = U$, and $B$ came from some $A \in F$ with $A \cap T = U$ (since $n \notin T$). Thus $F$ shatters $T$, so $|T| \leq d$. □

By induction: $|G| \leq \Phi(d, n-1)$.

**Bound on $|D|$:** VCdim$(D) \leq d-1$.

*Proof:* $D$ consists of sets $B \subseteq [n-1]$ such that both $B \in F$ and $B \cup \{n\} \in F$. Suppose $D$ shatters $T \subseteq [n-1]$ with $|T| = k$. For each $U \subseteq T$, there exists $B_U \in D$ with $B_U \cap T = U$. Since $B_U \in D$, both $B_U \in F$ and $B_U \cup \{n\} \in F$.

Consider $T' = T \cup \{n\}$ (size $k+1$). For any $V \subseteq T'$:
- If $n \notin V$: use $B_V \in F$ with $B_V \cap T' = V$ (since $n \notin B_V$).
- If $n \in V$: let $U = V \setminus \{n\}$, use $B_U \cup \{n\} \in F$ with $(B_U \cup \{n\}) \cap T' = U \cup \{n\} = V$.

So $F$ shatters $T'$ of size $k+1 \leq d$, giving $k \leq d-1$. □

By induction: $|D| \leq \Phi(d-1, n-1)$.

**Combining:**

$$|F| = |G| + |D| \leq \Phi(d, n-1) + \Phi(d-1, n-1) = \Phi(d, n)$$

Taking the maximum over sets $S$ of size $n$: $\Pi_{\mathcal{H}}(n) \leq \Phi(d, n) = \sum_{i=0}^d \binom{n}{i}$.

**Q.E.D. (Part A)** □

---

## Part B: $\sum_{i=0}^{d}\binom{n}{i} \leq \left(\frac{en}{d}\right)^d$

For $n \geq d \geq 1$. Since $0 < d/n \leq 1$ and $i \leq d$, we have $(d/n)^i \geq (d/n)^d$, hence $(n/d)^i \leq (n/d)^d$. Therefore:

$$\sum_{i=0}^d \binom{n}{i} = \sum_{i=0}^d \binom{n}{i}(d/n)^i (n/d)^i \leq (n/d)^d \sum_{i=0}^d \binom{n}{i}(d/n)^i$$

$$\leq (n/d)^d \sum_{i=0}^n \binom{n}{i}(d/n)^i \cdot 1^{n-i} = (n/d)^d (1 + d/n)^n$$

By the standard inequality $(1 + x/m)^m \leq e^x$ (with $m = n, x = d$):

$$(1 + d/n)^n \leq e^d$$

Therefore:

$$\sum_{i=0}^d \binom{n}{i} \leq (n/d)^d \cdot e^d = \left(\frac{en}{d}\right)^d$$

**Q.E.D. (Part B)** □

---

## Complete Result

$$\Pi_{\mathcal{H}}(n) \leq \sum_{i=0}^{d}\binom{n}{i} \leq \left(\frac{en}{d}\right)^d \quad \forall\, n \geq d$$

**Q.E.D.** □
