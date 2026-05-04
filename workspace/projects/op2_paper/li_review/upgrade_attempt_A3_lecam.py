"""
A3 verification: Does Le Cam variance LB transfer to averaged iterate?

Le Cam two-point lemma: max_s P_s[hat_s != s] >= (1 - TV)/2 for ANY estimator hat_s.
Estimator can be hat_s := -sgn(y_T) [last iterate] or hat_s := -sgn(bar_y_T) [avg iterate].
The LB is estimator-agnostic.

So if we use hat_s := -sgn(bar_y_T):
- On misidentification event A_s = {sgn(bar_y_T) = s}, what gap can we extract?
- alpha_s bar_y_T = s alpha bar_y_T = alpha |bar_y_T| (sign matches)
- w(bar_y_T) >= 0
- min_y[alpha_s y + w(y)] = -alpha D/sqrt(2) + alpha^2/(2L)
- So G_s(bar_y_T) = alpha |bar_y_T| + w(bar_y_T) + alpha D/sqrt(2) - alpha^2/(2L) >= alpha D/sqrt(2) - alpha^2/(2L)

This is the SAME bound as for last-iterate (Lemma 2.9 step 2). So variance term DOES transfer.

We just verify numerically: for OP-2's stochastic y-dynamics, E[G_s(bar_y_T)] >= sigma D / (112 sqrt T).
"""

import numpy as np

def shb_y_simulate(alpha, L, R, sigma, beta, eta, T, n_trials=20000, seed=0):
    """Simulate y-dynamics of SHB on f(y) = alpha y + w(y), w(y) = (L/2) max(|y|-R, 0)^2.
    Init: y_0 = y_{-1} = 0. Returns array of (last_y_T, bar_y_T) over n_trials."""
    rng = np.random.default_rng(seed)
    last = np.zeros(n_trials)
    avg = np.zeros(n_trials)

    for trial in range(n_trials):
        y_prev = 0.0
        y_curr = 0.0
        running_sum = 0.0
        for t in range(T):
            running_sum += y_curr
            # Gradient: alpha + w'(y_curr) = alpha + L*max(|y|-R,0)*sgn(y)
            absy = abs(y_curr)
            wprime = L * max(absy - R, 0.0) * (1.0 if y_curr > 0 else (-1.0 if y_curr < 0 else 0.0))
            xi = rng.standard_normal() * sigma
            g = alpha + wprime + xi
            y_new = y_curr - eta * g + beta * (y_curr - y_prev)
            y_prev = y_curr
            y_curr = y_new
        last[trial] = y_curr
        avg[trial] = running_sum / T  # average of y_0, y_1, ..., y_{T-1}
    return last, avg

# Setup: OP-2 parameters
L = 1.0
D = 1.0
sigma = 1.0   # arbitrary; bound scales with sigma
T_values = [10, 50, 200]

beta = 0.5
eta = 3.0 / L

print("=" * 80)
print(f"A3 verification: variance LB on bar_y_T vs last y_T")
print(f"Beta={beta}, eta L={eta*L}, sigma={sigma}")
print("=" * 80)

c_NY_target = 1.0 / 112  # OP-2's constant

for T in T_values:
    alpha = sigma / (2 * np.sqrt(2 * T))
    R = D / np.sqrt(2) - alpha / L
    y_star_pos = -D / np.sqrt(2)  # for s=+1
    min_val_pos = alpha * y_star_pos + (L/2) * max(abs(y_star_pos) - R, 0)**2

    print(f"\nT = {T}:  alpha = {alpha:.4f}, R = {R:.4f}, min_val = {min_val_pos:.6f}")

    last_pos, avg_pos = shb_y_simulate(alpha, L, R, sigma, beta, eta, T, n_trials=20000, seed=T)
    last_neg, avg_neg = shb_y_simulate(-alpha, L, R, sigma, beta, eta, T, n_trials=20000, seed=T+10000)

    def compute_gap(y, alpha_signed, R, L, min_val):
        absy = abs(y)
        w = (L/2) * np.maximum(absy - R, 0)**2
        return alpha_signed * y + w - min_val

    gap_last_pos = compute_gap(last_pos, alpha, R, L, min_val_pos)
    gap_last_neg = compute_gap(last_neg, -alpha, R, L, min_val_pos)  # symmetric, same min
    gap_avg_pos = compute_gap(avg_pos, alpha, R, L, min_val_pos)
    gap_avg_neg = compute_gap(avg_neg, -alpha, R, L, min_val_pos)

    target = c_NY_target * sigma * D / np.sqrt(T)

    print(f"  Last iterate gap    | s=+1: E={gap_last_pos.mean():.5f}, s=-1: E={gap_last_neg.mean():.5f}, max = {max(gap_last_pos.mean(), gap_last_neg.mean()):.5f}")
    print(f"  Averaged iter gap   | s=+1: E={gap_avg_pos.mean():.5f}, s=-1: E={gap_avg_neg.mean():.5f}, max = {max(gap_avg_pos.mean(), gap_avg_neg.mean()):.5f}")
    print(f"  OP-2 target c_NY * sigma D / sqrt T = {target:.5f}")
    print(f"  Last iter passes: {max(gap_last_pos.mean(), gap_last_neg.mean()) >= target}")
    print(f"  Avg iter passes:  {max(gap_avg_pos.mean(), gap_avg_neg.mean()) >= target}")
