# B1.4 Dimension scaling observations

Theory expectation: for fixed L-smooth convex quadratic, full-batch convergence is **dimension-independent** => slope vs log10(d) should be ~ 0.

Flag if |slope| > 0.2.

| Alg | slope log_gap vs log_d | flag |
|---|---|---|
| SGD | -0.145 | no |
| SHB_0.5 | -0.190 | no |
| Adam | +5.416 | YES |
| AdaGrad | +1.337 | YES |
