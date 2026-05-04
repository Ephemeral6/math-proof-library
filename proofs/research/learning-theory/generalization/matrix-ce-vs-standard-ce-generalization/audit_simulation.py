"""
Audit v2: tighter CE comparison using proper ERM (logistic regression on training set).
Also report variance to verify Theta(1/sqrt(m)) scaling.
"""
import numpy as np
from numpy.linalg import lstsq, eigvalsh

rng = np.random.default_rng(42)

def gen_data(m, d, K, lam, sigma, Wstar, u):
    Z = rng.standard_normal((m, d))
    g = rng.standard_normal((m, 1))
    X = sigma * Z + np.sqrt(lam) * g @ u[None, :]
    logits = X @ Wstar
    y = np.argmax(logits + 0.5 * rng.standard_normal(logits.shape), axis=1)
    return X, y

def softmax(z):
    z = z - z.max(axis=-1, keepdims=True); e = np.exp(z); return e/e.sum(-1,keepdims=True)
def ce(X,y,W):
    p = softmax(X@W); return -np.log(p[np.arange(len(y)),y]+1e-12).mean()

def fit_erm_ce(X, y, K, n_iter=200, lr=0.5, ridge=1e-3):
    """Multinomial logistic regression by gradient descent."""
    m, d = X.shape
    W = np.zeros((d, K))
    Y = np.eye(K)[y]
    for _ in range(n_iter):
        P = softmax(X @ W)
        grad = X.T @ (P - Y) / m + ridge * W
        W -= lr * grad
    return W

def mce(X, eps=1e-2):
    m, d = X.shape
    Sigma = (X.T @ X) / m
    Sigma = Sigma + eps * np.trace(Sigma)/d * np.eye(d)
    rho = Sigma / np.trace(Sigma)
    e = np.clip(eigvalsh(rho), 1e-12, None)
    return -np.mean(np.log(e))

def run(m_list, d=30, K=10, lam=10.0, sigma=0.5, eps=5e-2, n_trials=30):
    u = rng.standard_normal(d); u/=np.linalg.norm(u)
    Wstar = rng.standard_normal((d,K))*0.3; Wstar[:,0] += 2.0*u

    # Estimate population losses with a huge fresh draw
    Xpop, ypop = gen_data(80000, d, K, lam, sigma, Wstar, u)
    Wpop = fit_erm_ce(Xpop, ypop, K)
    Lpop_ce = ce(Xpop, ypop, Wpop)
    Lpop_mce = mce(Xpop, eps=eps)
    print(f"\nlam={lam}, sigma={sigma}, eps={eps}, d={d}, K={K}")
    print(f"  r_eff = {1+sigma**2*d/lam:.2f}")
    print(f"  pop L_CE(W_pop) = {Lpop_ce:.4f}, pop L_MCE = {Lpop_mce:.4f}")
    print(f"  L_CE bound B_CE ~ log K = {np.log(K):.2f}")
    print(f"{'m':>6} {'|gap_MCE|':>14} {'|gap_CE|':>14} {'gap_MCE*sqrtm':>16} {'gap_CE*sqrtm':>16}")
    for m in m_list:
        gms, gcs = [], []
        for _ in range(n_trials):
            X, y = gen_data(m, d, K, lam, sigma, Wstar, u)
            W_erm = fit_erm_ce(X, y, K)
            Lhat_ce = ce(X, y, W_erm)
            true_ce = ce(Xpop, ypop, W_erm)
            gcs.append(true_ce - Lhat_ce)
            Lhat_mce = mce(X, eps=eps)
            gms.append(Lpop_mce - Lhat_mce)
        gm = np.mean(np.abs(gms)); gc = np.mean(np.abs(gcs))
        print(f"{m:>6} {gm:>14.5f} {gc:>14.5f} {gm*np.sqrt(m):>16.4f} {gc*np.sqrt(m):>16.4f}")

if __name__=="__main__":
    print("=== LOW EFFECTIVE RANK (predicted: MCE << CE) ===")
    run([200,500,1000,2000,5000], d=30, K=10, lam=10.0, sigma=0.5)
    print("\n=== MODERATE rank ===")
    run([200,500,1000,2000,5000], d=30, K=10, lam=4.0, sigma=1.0)
    print("\n=== HIGH RANK (predicted: gap narrows but CE still has Theta(1/sqrt m)) ===")
    run([200,500,1000,2000,5000], d=30, K=10, lam=1.0, sigma=2.0)
