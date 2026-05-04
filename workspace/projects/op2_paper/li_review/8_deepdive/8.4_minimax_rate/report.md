# 8.4 — Stochastic Upper Bound for Fixed-Momentum SHB

**Date:** 2026-04-26
**Status:** PARTIAL PASS — clean Lyapunov UB derived, but **disjoint from $\mathcal{F}$** so OP-2's LB and this UB do NOT directly match.

## Headline result

A clean Cesàro-average UB is derived via GFJ15-style Lyapunov:
$$\boxed{\mathbb{E}[f(\bar x_T) - f^\star] \leq \frac{(1-\beta)D^2}{2\eta T} + \frac{\eta\sigma^2}{2(1-\beta)}}$$
on $\mathcal{S}_{\text{Lyap}} := \{(\beta,\eta) : \eta \leq (1-\beta^2)/L\}$. Optimizing $\eta = (1-\beta)D/(\sigma\sqrt T)$ gives
$$\mathrm{UB}^\star = \frac{D\sigma}{\sqrt T},$$
matching OP-2's variance term up to constants.

## Critical obstruction (sub-task e)

$\mathcal{S}_{\text{Lyap}} \cap \mathcal{F} = \emptyset$:
- Lyapunov UB requires $\eta \leq (1-\beta^2)/L \leq 1/L$.
- $\mathcal{F}$ requires $\eta \geq \gamma_\mathrm{crit}(\beta)/L > 1/L$ for cycling-feasibility.

**The UB and OP-2's LB cover disjoint regions of the parameter space.** No closed-form UB on $\mathcal{F}$ proper is known. Closing this gap likely requires IQC (Lessard–Recht–Packard 2016) or PEP (Taylor–Bach 2019) techniques.

## Lyapunov derivation (sub-task a-c)

Lyapunov: $V_t = \mathbb{E}[f(x_t) - f^\star] + a\,\mathbb{E}\|m_t\|^2$ with $m_t = x_t - x_{t-1}$.

Choose $a = (1-L\eta)/(2\eta)$ to kill the cross term $\langle\nabla f(x_t), m_t\rangle$. Master inequality:
$$V_{t+1} \leq V_t - \tfrac{\eta}{2}\mathbb{E}\|\nabla f(x_t)\|^2 + \tfrac{\eta}{2}\sigma^2.$$

Function-value bound via the augmented potential $\Phi_t = \mathbb{E}\|x_t - x^\star + \tfrac{\beta}{1-\beta}m_t\|^2 + \mu\mathbb{E}\|m_t\|^2$, telescoping over $T$ steps.

Variance enters via $\mathbb{E}_t\|g_t\|^2 \leq \|\nabla f(x_t)\|^2 + \sigma^2$ in two places: smoothness expansion (gives $L\eta^2\sigma^2/2$) and momentum recursion (gives $a\eta^2\sigma^2$). Together: $\eta\sigma^2/2$ per step.

The $1/(1-\beta)$ amplification on the variance term comes from the change of variables in the augmented potential.

## Last iterate vs Cesàro (sub-task d)

Last-iterate stochastic UB matching OP-2's LB is **unlikely** for fixed-momentum SHB:
- Shamir-Zhang 2013 suffix-averaging gives $O(LD^2/T + \sigma D \log T/\sqrt T)$ for SGD — adds $\log T$ overhead.
- Liu-Orabona 2020 anytime online-to-batch removes the log but **requires time-varying step-sizes**, incompatible with fixed-momentum SHB.

So the natural minimax statement is for $\bar x_T$, not $x_T$.

## Recommended addition to OP-2 §4.2

> *Stochastic UB on $\mathcal{S}_{\text{Lyap}}$.* A standard GFJ15-style Lyapunov gives $\mathbb{E}[f(\bar x_T) - f^\star] \leq (1-\beta)D^2/(2\eta T) + \eta\sigma^2/(2(1-\beta))$ on the strict subset $\mathcal{S}_{\text{Lyap}} = \{\eta \leq (1-\beta^2)/L\}$, which is **disjoint from $\mathcal{F}$**. Optimizing recovers the SGD rate $D\sigma/\sqrt T$. Closing the UB on $\mathcal{F}$ proper — where SHB cycling is feasible — is open and likely requires IQC/PEP techniques.

## Honest stance

The non-acceleration conclusion (LB rules out $LD^2/T^2$ on $\mathcal{F}$) is unaffected. But the "tight $\Theta$-rate on $\mathcal{F}$" framing should be carefully scoped: it holds *relative to SGD* but no direct SHB UB matches it on $\mathcal{F}$.
