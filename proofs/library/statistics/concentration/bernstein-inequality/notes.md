# Notes: Bernstein's Inequality for Bounded Random Variables

## Proof technique
Route 2 (Direct Taylor Series + Moment Bounds) was selected. The proof uses the Chernoff bound framework combined with a direct Taylor expansion of the moment-generating function, moment bounds from boundedness, a factorial inequality to reduce to geometric series, and an explicit choice of the Chernoff parameter.

## Key steps
1. **Moment bound:** $|\mathbb{E}[X_i^k]| \leq \sigma_i^2 M^{k-2}$ for $k \geq 2$ — this is the fundamental bound that encodes both variance and boundedness information.
2. **Factorial inequality:** $k! \geq 2 \cdot 3^{k-2}$ for $k \geq 2$ — this converts the Taylor series into a geometric series, which is what produces the $1/3$ constant in the denominator.
3. **$1+x \leq e^x$:** Converts additive MGF bound to exponential form, enabling product over independent variables.
4. **Choice of $\lambda^* = t/(V + Mt/3)$:** This specific (non-optimal) choice directly yields the Bernstein denominator. The optimal choice would give the stronger Bennett inequality.

## Audit result
**PASS.** Line-by-line verification found no logical errors. All inequality directions verified, convergence conditions checked, edge cases ($V=0$, $M \to 0$, $t \to 0$, $t \to \infty$) all consistent. One cosmetic issue noted: the Moment Bound lemma initially stated a weaker form with unnecessary $k!/2$ factor, which was acknowledged and not used.

## Related results
- **Hoeffding's inequality:** The special case where we only use boundedness (not variance). Gives $\exp(-2t^2/(nD^2))$ where $D$ is the range. Bernstein is tighter when variance is small.
- **Bennett's inequality:** The stronger result $\exp(-\frac{V}{M^2} h(Mt/V))$ where $h(u) = (1+u)\log(1+u) - u$. Bernstein's inequality follows from Bennett's via $h(u) \geq u^2/(2+2u/3)$.
- **Sub-exponential tail characterization:** Bernstein's inequality shows that bounded mean-zero RVs are sub-exponential with parameters $(\sqrt{2V}, 2M/3)$.
- **Matrix Bernstein inequality:** Tropp's extension to matrix-valued random variables (already in our library).
- **McDiarmid's inequality:** Related bounded-differences concentration (already in our library).
- **Hoeffding's inequality:** Scalar version already in our library.
