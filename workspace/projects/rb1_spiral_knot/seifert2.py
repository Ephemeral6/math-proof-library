import sympy as sp
import numpy as np
from itertools import product

t = sp.symbols('t')

D1 = sp.Matrix([[-1, 1], [0, -1]])
D2 = sp.Matrix([[1, -1], [0, 1]])

# Faster numeric search: pick a value of t (e.g. t=2) and search for L,K matrices that
# give det(M - tM^T) = (t-1)^4 numerically; then verify symbolically the matches.

# Numeric value
t0 = 2.0
target_val = (t0 - 1)**4  # = 1
# Also -1 (since polynomial defined up to ±t^k)

def stack(D1, L, K, D2):
    M = np.zeros((4,4))
    M[:2,:2] = np.array(D1, dtype=float)
    M[:2,2:] = L
    M[2:,:2] = K
    M[2:,2:] = np.array(D2, dtype=float)
    return M

D1n = np.array([[-1,1],[0,-1]], dtype=float)
D2n = np.array([[1,-1],[0,1]], dtype=float)

candidates = []
for entries in product([-1, 0, 1], repeat=8):
    L = np.array(entries[:4]).reshape(2,2)
    K = np.array(entries[4:]).reshape(2,2)
    M = stack(D1n, L, K, D2n)
    A = M - t0 * M.T
    d = np.linalg.det(A)
    if abs(abs(d) - 1.0) < 1e-9:
        candidates.append((L.copy(), K.copy()))

print(f"Numerical candidates at t=2: {len(candidates)}")

# Now check each symbolically
sym_solutions = []
for L_n, K_n in candidates:
    L = sp.Matrix(L_n.astype(int).tolist())
    K = sp.Matrix(K_n.astype(int).tolist())
    M = sp.Matrix.zeros(4,4)
    M[:2,:2] = D1
    M[:2,2:] = L
    M[2:,:2] = K
    M[2:,2:] = D2
    A = M - t * M.T
    det_A = sp.expand(A.det())
    target1 = sp.expand((t-1)**4)
    target2 = sp.expand(-(t-1)**4)
    if sp.simplify(det_A - target1) == 0:
        sym_solutions.append((L, K, det_A, +1))
    elif sp.simplify(det_A - target2) == 0:
        sym_solutions.append((L, K, det_A, -1))

print(f"Symbolic solutions: {len(sym_solutions)}")
for L, K, d, s in sym_solutions[:10]:
    print(f"sign={s}, L={L.tolist()}, K={K.tolist()}, det={d}")
