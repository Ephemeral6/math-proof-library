# SVRG Linear Convergence (ABC Framework) - Full Report

## Phase 1: Scout
Problem: Prove SVRG linear convergence with eta=1/(10L), m=20kappa.
Route: Semi-Stochastic / ABC Framework - track joint (function gap, distance) recursion.

## Phase 2: Exploration
Attempt 1 (L2 variance bound): Failed - kappa blowup in coefficients.
Attempt 2 (Coupled Lyapunov): Abandoned - algebraically unwieldy.
Attempt 3 (Sum-then-average + Nesterov bound): Success - contraction 7/18.

## Phase 3: Judge
Route 5 Attempt 3 wins. Clean, rigorous, self-contained.

## Phase 4: Audit
All coefficients verified. Proof correct. Contraction 7/18 < 1/2.

## Phase 5: No fixes needed.
