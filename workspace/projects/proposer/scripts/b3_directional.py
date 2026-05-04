"""B3 supplemental: directional robustness for R1/R2/R5 (claims that hold for every seed)."""
import numpy as np
import os

# R1: every seed has final/min > 1e3?  R2: every seed has final > 1e-6?
# R5: every seed has slope > 0.5?
# Reuse functions inline:

def make_sc_quad(d, seed):
    rng = np.random.default_rng(seed)
    Q, _ = np.linalg.qr(rng.standard_normal((d, d)))
    eigs = rng.uniform(0.05, 1.0, size=d); eigs[0]=0.05; eigs[-1]=1.0
    A = (Q * eigs) @ Q.T; A = 0.5*(A+A.T)
    return A, eigs.max()


def adam(A, x0, T, eta):
    x=x0.copy(); m=np.zeros_like(x); v=np.zeros_like(x); fs=np.empty(T)
    for t in range(1,T+1):
        g=A@x; m=0.9*m+0.1*g; v=0.999*v+0.001*g*g
        mh=m/(1-0.9**t); vh=v/(1-0.999**t)
        x=x-eta*mh/(np.sqrt(vh)+1e-8)
        fs[t-1]=0.5*x@A@x
    return fs


fail_div = 0; fail_floor = 0
for seed in range(30):
    A,L=make_sc_quad(10,seed)
    rng=np.random.default_rng(seed+1000); x0=rng.standard_normal(10)
    fs=adam(A,x0,10000,1.0/L)
    if fs[-1]/fs.min() <= 1e3: fail_div += 1
    if fs[-1] <= 1e-6: fail_floor += 1
print(f"R1 (final/min>1e3): pass {30-fail_div}/30")
print(f"R2 (final>1e-6):    pass {30-fail_floor}/30")

# R5
fail_slope = 0
for seed in range(30):
    gaps=[]
    for d in [2,10,50,200,500]:
        rng=np.random.default_rng(seed)
        Q,_=np.linalg.qr(rng.standard_normal((d,d)))
        eigs=rng.uniform(1e-3,1.0,size=d); eigs[0]=1e-3; eigs[-1]=1.0
        A=(Q*eigs)@Q.T; A=0.5*(A+A.T)
        x_star=rng.standard_normal(d); b=A@x_star; f_star=-0.5*x_star@b
        x0=x_star+rng.standard_normal(d)
        x=x0.copy(); m=np.zeros_like(x); v=np.zeros_like(x)
        for t in range(1,5001):
            g=A@x-b; m=0.9*m+0.1*g; v=0.999*v+0.001*g*g
            mh=m/(1-0.9**t); vh=v/(1-0.999**t)
            x=x-1.0*mh/(np.sqrt(vh)+1e-8)
        gap=max(0.5*x@A@x - b@x - f_star, 1e-300)
        gaps.append(np.log10(gap))
    slope,_=np.polyfit(np.log10([2,10,50,200,500]), gaps, 1)
    if slope <= 0.5: fail_slope += 1
print(f"R5 (slope>0.5): pass {30-fail_slope}/30")
