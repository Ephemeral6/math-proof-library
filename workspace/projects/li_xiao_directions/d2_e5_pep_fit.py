"""
Fit the PEP variance-only data to test:
  H1: PEP_var ~ A * sigma * D / sqrt(T)         (matches OP-2 LB)
  H2: PEP_var ~ A * sigma^2 * eta / (1 - beta^2)  (constant noise floor)
  H3: PEP_var ~ A * T^p, p > 0                   (diverges)

Fit log(PEP_var) ~ p * log(T) + c using the data from the decompose run.
"""
import numpy as np

# pasted from latest run; (beta, etaL, T, PEP_var)
data = [
    (0.0, 0.5, [3,5,8,10,12,15,20], [0.2292,0.2854,0.3397,0.3661,0.3879,0.4148,0.4497]),
    (0.0, 1.0, [3,5,8,10,12,15,20], [0.7667,0.8936,1.0109,1.0666,1.1122,1.1679,1.2398]),
    (0.5, 0.5, [3,5,8,10,12,15,20], [0.3788,0.5302,0.6665,0.7290,0.7791,0.8394,0.9157]),
    (0.5, 1.0, [3,5,8,10,12,15,20], [1.1379,1.4669,1.7543,1.8851,1.9888,2.1124,2.2679]),
    (0.9, 0.5, [3,5,8,10,12,15,20], [0.6304,1.0727,1.7007,2.1134,2.4824,3.0186,3.8073]),
    (0.9, 1.0, [3,5,8,10,12,15,20], [1.7164,3.0133,5.2987,7.2678,9.1398,12.6554,19.8128]),
]

print(f"{'beta':>5} {'etaL':>5} {'fitted exp':>12} {'expected if NF':>16} "
      f"{'ratio var(T=20)/var(T=3)':>26}")
for beta, etaL, Ts, vs in data:
    Ts = np.array(Ts); vs = np.array(vs)
    # Fit log v = p log T + c
    p, c = np.polyfit(np.log(Ts), np.log(vs), 1)
    eta = etaL
    L = 1.0
    nf = (eta) / (1.0 - beta * beta)  # sigma=1, L=1: noise floor sigma^2 eta/(L (1-beta^2))
    # times L/2 is f-units for quadratic
    nf_f = 0.5 * L * nf
    ratio = vs[-1] / vs[0]
    print(f"{beta:5.2f} {etaL:5.2f}     T^{p:6.3f}      {nf_f:14.4f}     "
          f"{ratio:24.2f}")

print()
print("Interpretation:")
print(" - p < 0: variance decreasing -> consistent with sigma D/sqrt(T)")
print(" - p ~ 0: variance saturating -> consistent with constant noise floor")
print(" - p > 0: variance growing  -> diverges (PEP shows worst-case f")
print("                                 designed adversarially per T)")
