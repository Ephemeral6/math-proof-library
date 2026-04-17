# Route 2: Two-Phase Step Size Schedule

## Result: Proved O(1/√T) for the Phase 2 AVERAGED iterate.

Phase 1 (t=1..T/2): η_t = D/(G√(T/2))
Phase 2 (t=T/2+1..T): η_t = D/(G√T)

The Phase 2 averaged iterate satisfies E[f(x̄) - f*] ≤ (5/2)DG/√T = O(1/√T).

Could NOT prove the literal last-iterate bound. The Markov chain mixing argument is promising in 1D but quantifying the mixing rate without strong convexity introduces function-dependent constants.
