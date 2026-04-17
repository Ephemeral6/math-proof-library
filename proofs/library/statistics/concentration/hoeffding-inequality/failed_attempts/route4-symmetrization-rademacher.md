# Proof of Hoeffding's Inequality — Route 4: Symmetrization + Rademacher

**Route**: Symmetrization approach using independent copies and Rademacher variables

---

## Route Failure Report
- **Route**: Symmetrization + Rademacher
- **Failed at**: Step 3 (constant recovery)
- **Obstacle**: The symmetrization approach naturally leads to the bound via sub-Gaussian properties of Rademacher sums, but recovering the sharp constant $2$ in the exponent $\exp(-2t^2/\sum c_i^2)$ is problematic. The symmetrization introduces a factor of 2 in the wrong direction.

**Details**: The symmetrization lemma gives $P(\sum Y_i \geq t) \leq 2P(\sum \varepsilon_i Y_i \geq t/2)$ where $\varepsilon_i$ are Rademacher. Then using conditional sub-Gaussian bounds on Rademacher sums gives $\exp(-t^2/(2\sum c_i^2))$ — but this has the wrong constant compared to Hoeffding's sharp bound. The direct MGF approach (Routes 1-3) is strictly superior for obtaining the exact constant.

**Conclusion**: This route is not viable for proving Hoeffding's inequality with the sharp constant. It can prove a weaker version but not the stated theorem.
