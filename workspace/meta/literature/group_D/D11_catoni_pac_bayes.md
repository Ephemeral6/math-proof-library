# D11: Catoni PAC-Bayes (inverse-KL)

**Source claimed**: Catoni 2007 (lecture notes); Alquier-Ridgway-Chopin 2016 (1606.01799).

**Local proof**: Route 3 (Fubini-first + change of measure). Sub-Bernoulli MGF, supermartingale construction with $W_S = \mathbb{E}_{h\sim P}e^{\phi_S(h)}$, Markov, then Donsker-Varadhan. Final bound:
$$R(Q) \le \frac{\lambda/n}{1-e^{-\lambda/n}}\hat R_S(Q) + \frac{1}{1-e^{-\lambda/n}}\cdot\frac{\mathrm{KL}(Q\|P)+\log(1/\delta)}{n}.$$

**Literature**: This is *exactly* Catoni's bound from his 2007 St Flour lecture notes, "PAC-Bayesian Supervised Classification: The Thermodynamics of Statistical Learning" (IMS Lecture Notes 56). The form $\frac{\lambda/n}{1-e^{-\lambda/n}}$ for the leading factor is Catoni's hallmark "thermodynamic" inversion (asymptotically $1+\lambda/(2n)+O$, recovering McAllister-style as $\lambda \to 0$). Alquier et al. 2016 give a textbook re-derivation.

**Verdict**: REPRODUCED (matches Catoni 2007 / Alquier et al. 2016 exactly). The Fubini-first construction with $W_S$ is the canonical PAC-Bayes proof framework (sometimes called "Seldin's trick"); the sub-Bernoulli cumulant $\psi(u)=u-1+e^{-u}$ is Catoni's specific choice yielding the thermodynamic kernel.

**Discrepancies**: None.

**Honest classification**: A-class for Catoni's original; the local reproof faithfully restates it. Solid.
