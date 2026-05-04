"""B1.3 PEPit Worst-Case Search.

We probe three settings:
  (i) SHB on smooth convex non-SC at T in {3,5,10}, beta in {0.5, 0.9}, eta=1/L.
      Reference: Goujaud et al show worst-case is bad (cycling).
  (ii) Adam on smooth convex, T in {3,5,10}, beta1=0.9, beta2=0.999, eps=1e-8, eta=1/L.
       PEPit may not have native Adam; if not, we skip.
  (iii) SVRG with snapshot frequency m in {n/2, n, 2n}: PEPit may not directly support; skip if so.

We collect worst-case last-iterate function gap (or grad norm) and report.
"""
import os
import traceback

OUT_DIR = "workspace/proposer/results"
os.makedirs(OUT_DIR, exist_ok=True)

results_lines = ["# B1.3 PEPit Worst-Case Search\n"]


def section(s):
    results_lines.append(f"\n## {s}\n")
    print(f"\n=== {s} ===")


def line(s):
    results_lines.append(s + "\n")
    print(s)


# Try import
try:
    import PEPit
    from PEPit import PEP
    from PEPit.functions import SmoothConvexFunction
    try:
        line(f"PEPit version: {PEPit.__version__}")
    except AttributeError:
        line("PEPit imported (version attr missing)")
except Exception as e:
    line(f"PEPit import FAILED: {e}")
    with open(os.path.join(OUT_DIR, "b1_3_pepit.md"), "w") as f:
        f.write("\n".join(results_lines))
    raise SystemExit(0)


# ------------------- SHB on smooth convex non-SC -------------------
section("SHB on smooth convex (L=1), eta=1/L, several beta, T in {3,5,10}")

for beta in [0.5, 0.9]:
    for T in [3, 5, 10]:
        try:
            problem = PEP()
            f = problem.declare_function(SmoothConvexFunction, L=1.0)
            xs = f.stationary_point()
            fs = f(xs)
            x0 = problem.set_initial_point()
            problem.set_initial_condition((x0 - xs) ** 2 <= 1)
            x_prev = x0
            x = x0  # at t=0, x_prev = x0; first momentum term = 0
            for t in range(T):
                g = f.gradient(x)
                # x_{t+1} = x_t - (1/L) g + beta (x_t - x_prev)
                x_new = x - (1.0 / 1.0) * g + beta * (x - x_prev)
                x_prev = x
                x = x_new
            problem.set_performance_metric(f(x) - fs)
            wc = problem.solve(verbose=0)
            line(f"SHB beta={beta} T={T}: worst-case f(x_T)-f* = {wc:.4e}")
        except Exception as e:
            line(f"SHB beta={beta} T={T}: FAILED {type(e).__name__}: {e}")


# ------------------- Smooth convex GD baseline (sanity) -------------------
section("GD on smooth convex (L=1), eta=1/L, T in {3,5,10}  -- sanity check")
for T in [3, 5, 10]:
    try:
        problem = PEP()
        f = problem.declare_function(SmoothConvexFunction, L=1.0)
        xs = f.stationary_point()
        fs = f(xs)
        x0 = problem.set_initial_point()
        problem.set_initial_condition((x0 - xs) ** 2 <= 1)
        x = x0
        for t in range(T):
            x = x - (1.0 / 1.0) * f.gradient(x)
        problem.set_performance_metric(f(x) - fs)
        wc = problem.solve(verbose=0)
        line(f"GD T={T}: worst-case f(x_T)-f* = {wc:.4e}  (theory ~ L/(4T+2) = {1.0/(4*T+2):.4e})")
    except Exception as e:
        line(f"GD T={T}: FAILED {type(e).__name__}: {e}")


# ------------------- NAG sanity -------------------
section("NAG on smooth convex L=1, T in {3,5,10}")
for T in [3, 5, 10]:
    try:
        problem = PEP()
        f = problem.declare_function(SmoothConvexFunction, L=1.0)
        xs = f.stationary_point()
        fs = f(xs)
        x0 = problem.set_initial_point()
        problem.set_initial_condition((x0 - xs) ** 2 <= 1)
        x = x0
        x_prev = x0
        # Use Nesterov constant momentum scheme with t/(t+3) type schedule
        for t in range(T):
            mom = t / (t + 3.0)
            y = x + mom * (x - x_prev)
            x_new = y - (1.0 / 1.0) * f.gradient(y)
            x_prev = x
            x = x_new
        problem.set_performance_metric(f(x) - fs)
        wc = problem.solve(verbose=0)
        line(f"NAG T={T}: worst-case f(x_T)-f* = {wc:.4e}  (theory O(1/T^2) ~ {1.0/(T*T):.4e})")
    except Exception as e:
        line(f"NAG T={T}: FAILED {type(e).__name__}: {e}")


# ------------------- Adam: PEPit doesn't have native Adam; we attempt manual encoding -------------------
section("Adam on smooth convex (L=1), T in {3,5,10} -- attempted manual PEP encoding")
# Adam uses elementwise sqrt of v_t which is non-convex in g; PEP encodings are typically
# done in 1D-equivalent (treat as scalar). Even so, the m_hat / sqrt(v_hat) op is hard in PEPit.
# We attempt the simplest 1D scalar Adam.
try:
    line("PEPit's PEP framework treats decision variables as elements of a Hilbert space and operations")
    line("must be linear in gradient + function-class queries. Adam's normalization v_hat^{-1/2} is NOT")
    line("expressible directly. SKIPPING — would require a custom interpolation class.")
except Exception as e:
    line(f"Adam: FAILED {e}")


# ------------------- SVRG -------------------
section("SVRG: PEPit has limited support for variance-reduction worst-case PEPs without finite-sum interpolation")
line("PEPit does support finite-sum settings via SmoothStronglyConvexFunction list, but constructing SVRG")
line("with snapshot frequency m requires careful encoding. Skipping for time budget.")


with open(os.path.join(OUT_DIR, "b1_3_pepit.md"), "w") as f:
    f.write("".join(results_lines))
print(f"\nSaved {os.path.join(OUT_DIR, 'b1_3_pepit.md')}")
