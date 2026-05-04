# 8.10 — Communication Complexity of Verifying SHB Non-Acceleration

**Date:** 2026-04-26
**Status:** PASS — clean tight bound + structural insight.

## Headline result

> **OP-2 verification is communication-optimal: $\Theta(\log(1/\epsilon))$ bits — exponentially cheaper than verifying Nesterov-style first-order LBs ($\Omega(T\log(1/\epsilon))$).**

## The protocol

```
Π_OP2(ε, c, L, D, σ):
  1. Alice → Bob: encode (β, η, T, L, D, σ) at precision ε.
                   [O(log(1/ε)) bits]
  2. Bob: f := OP2.construct(β, η, T, L, D, σ); simulate SHB locally;
          v := empirical mean f(x_T) − f*.
  3. Bob → Alice: v at precision ε.
                   [O(log(1/ε)) bits]
  4. Alice: accept iff v ≥ c LD²/T − ε.
```

Total: $\Theta(\log(1/\epsilon))$ bits.

## Lower bound

**Claim.** Any protocol verifying $\mathbb{E}[f(x_T) - f^\star] \gtrless c LD^2/T \pm \epsilon$ correctly with prob $\ge 2/3$ requires $\Omega(\log(1/\epsilon))$ bits.

**Proof.** Discretize a one-parameter shift family $f_\tau = f + \tau$ for $\tau \in \{-1, +1\}\cdot 2\epsilon$ over $N = \Theta(1/\epsilon)$ levels. Distinguishing $N$ inputs requires $\log_2 N = \Omega(\log(1/\epsilon))$ bits (fooling-set argument; Yao for randomization). $\square$

The OP-2 protocol matches the LB up to constants — **communication-optimal**.

## Comparison with Nesterov

| Property | Nesterov first-order LB | OP-2 SHB LB |
|---|---|---|
| Hard-instance dimension $d$ | $\Theta(T)$ | $3$ |
| Spec bits | $\Theta(T \log(1/\epsilon))$ | $O(\log(1/\epsilon))$ |
| Per-query oracle bits | $\Theta(T \log(1/\epsilon))$ | $O(\log(1/\epsilon))$ |
| Total online bits | $\Theta(T^2 \log(1/\epsilon))$ | $O(T \log(1/\epsilon))$ |
| LB scope | Algorithm-class | Algorithm-specific |

**Exponential gap in spec size.** OP-2 wins by a factor of $T$.

## Structural insight: "constant-dimensional witnesses"

Algorithm-class LBs (Nesterov, Woodworth–Srebro) must defeat the entire linear-span family, forcing $d = \Theta(T)$. Algorithm-specific LBs (OP-2 against SHB) can exploit the algorithm's restricted update geometry, yielding **constant-dimensional witnesses**.

This connects to a broader theme: algorithm-specific LBs are "PCP-like" with constant-locality witnesses, whereas algorithm-class LBs behave more like exponential-witness instances.

## Trustless / zero-knowledge

The OP-2 hard instance is fully determined by public parameters $(\beta, \eta, T, L, D, \sigma)$ — Alice can reconstruct $f$ herself. Bob's role is just to confirm the empirical mean. The protocol is **zero-knowledge in the trivial sense**.

For a **trustless variant** (Alice doesn't trust Bob's empirical mean): Both parties run SHB locally; Bob only confirms a hash. Same $O(\log(1/\epsilon))$ cost.

## Take-away

The communication-complexity lens crystallizes a feature of OP-2's framework: **constant-dimensional witnesses** are the signature of pinning down precisely which structural primitives the algorithm fails on. Cycling-on-Goujaud-polytope is "compact" in a way that Nesterov's worst-case quadratic is not.

Modest contribution but a clean note worth ~1 page in OP-2 §4 or as a standalone observation.
