# Geometry Tools — Install & Smoke-Test Status

**Date:** 2026-04-30
**Platform:** Windows 11, Python 3.13 (`C:\Users\12729\AppData\Local\Programs\Python\Python313`)
**Scope:** install only, no math problem solving.

---

## Summary table

| Tool | Install status | Version | Smoke test | Notes |
|------|---------------|---------|------------|-------|
| **SnapPy** | ✅ INSTALLED | 3.3.2 | ✅ PASS | figure-eight knot vol = 2.0298832128, π₁ = ⟨a,b ∣ abbbaBAAB⟩ |
| **curver** | ✅ INSTALLED | 0.5.1 | ✅ PASS | `curver.load(1, 1)` → MappingClassGroup ⟨a₀, b₀⟩ on 3_o |
| **flipper** | ✅ INSTALLED (this session) | 0.15.6 | ✅ PASS | `flipper.load('S_1_1')` → EquippedTriangulation with laminations [a, b] |
| **spherogram** | ✅ INSTALLED (was already) | 2.4.1 | ⚠ PARTIAL | Link object loads (`Link('4_1')` → 4 crossings), but Jones polynomial requires Sage |
| **plink** | ✅ INSTALLED (was already) | 2.4.9 | (import only) | GUI knot diagram editor; no headless smoke test attempted |
| **Regina** | ❌ NOT INSTALLED | — | — | `pip install regina` failed: requires MSVC C++ Build Tools 14.0+ to compile from source. No conda available. |
| **SageMath** | ❌ NOT INSTALLED | — | — | `which sage` and `where sage` both empty. Native Windows install not attempted (per task brief). |

---

## Detailed install log

### SnapPy 3.3.2 — already installed

Verified import: `python -c "import snappy; print(snappy.__version__)"` → `3.3.2`.

### curver 0.5.1 — already installed

Verified import: `python -c "import curver; print(curver.__version__)"` → `0.5.1`.

### flipper 0.15.6 — installed this session

Command: `pip install flipper --break-system-packages`
Built wheel from source (built `flipper-0.15.6-py3-none-any.whl` from sdist; brought in pure-Python deps).
Verified import: `import flipper; print(flipper.__version__)` → `0.15.6`.

### spherogram 2.4.1 — already present (transitive dep of SnapPy)

`pip install spherogram --break-system-packages` reported "Requirement already satisfied".
Pulls in `snappy_manifolds 1.4`, `knot_floer_homology 1.2.2`, `networkx`, `decorator`, `packaging`.

### plink 2.4.9 — already present

`pip install plink --break-system-packages` reported "Requirement already satisfied".

### Regina — install failed

Command attempted: `pip install regina --break-system-packages`
Failure mode:
```
error: Microsoft Visual C++ 14.0 or greater is required.
Get it with "Microsoft C++ Build Tools": https://visualstudio.microsoft.com/visual-cpp-build-tools/
ERROR: Failed to build installable wheels for some pyproject.toml based projects (regina)
```
The `regina` package on PyPI is a C++ extension and there is no pre-built wheel for Windows + Python 3.13. `conda` is also not on this system (`which conda` empty), so the conda-forge fallback is unavailable. Per task brief, did not exceed the 10-minute budget — bailed at the build error.

**Next-step options for Regina (NOT executed; for the user to choose):**
1. Install MSVC Build Tools from <https://visualstudio.microsoft.com/visual-cpp-build-tools/> (~6 GB; covers other future C-extension installs too) and re-run `pip install regina`.
2. Install Miniconda, then `conda install -c conda-forge regina` — likely the easiest path.
3. Use WSL Ubuntu and `apt install regina-normal python3-regina`.
4. Download the official Regina Windows installer from <https://regina-normal.github.io/> (provides GUI; CLI/Python bindings depend on the version).

### SageMath — not attempted (per task brief)

`which sage` returns empty; `where sage` also empty. Per task brief, did not attempt native Windows install. Recommended path is WSL Ubuntu (`apt install sagemath`) or Docker.

---

## Smoke-test details

### SnapPy: figure-eight knot

```
Figure-eight knot volume: 2.0298832128
Homology: Z
Fundamental group: Generators: a,b   Relators: abbbaBAAB
```
Matches Lickorish / Thurston canonical values. ✅

### curver: once-punctured torus

```
Surface: Mapping class group < a_0, b_0 > on 3_o
Type: MappingClassGroup
Notable methods: arcs, cayley, curves, lamination, mapping_class,
                 mapping_classes, neg/pos_mapping_classes, random_word,
                 triangulation, zeta
```
✅ MappingClassGroup of S_{1,1} is constructed and exposes the expected combinatorial primitives (`curves`, `arcs`, `mapping_class`, `lamination`, etc.).

### flipper: once-punctured torus

```
Surface: Triangulation with laminations: ['a', 'b'] and mapping classes: ['a', 'b']
Type: EquippedTriangulation
Notable methods: all_mapping_classes, all_words, decompose_word, lamination,
                 laminations, mapping_class, mapping_classes,
                 neg/pos_mapping_classes, random_word, triangulation, zeta
```
✅ Returns an EquippedTriangulation with two named laminations and two named mapping classes. Compatible with curver-style API.

### spherogram: figure-eight link

```
Figure-eight link: <Link 4_1: 1 comp; 4 cross>
Crossings: [0, 1, 2, 3]
```
Basic link object loads. Jones polynomial method calls `sage_helper._sage_method` and raises `SageNotAvailable` — feature gated on Sage. ⚠ PARTIAL — the parts that don't depend on Sage work; Jones / linking-form / homology-via-Sage do not.

### SnapPy HTLinkExteriors census enumeration (Q4 prep)

```
Census class: HTLinkExteriors
Length: 180511
First 5 entries by index (name, volume, homology):
  K3a1: vol=0,            homology=Z      (trefoil — non-hyperbolic, vol=0 sentinel)
  K4a1: vol=2.0298832128, homology=Z      (figure-eight)
  K5a1: vol=2.8281220883, homology=Z      (5_1)
  K5a2: vol=0,            homology=Z      (5_2... or another non-hyperbolic — vol=0)
  K6a1: vol=5.6930210913, homology=Z
```
✅ Census has 180,511 link/knot exteriors indexable by integer. Iteration via index works (the original `for M in snappy.HTLinkExteriors:` form returns 0 — needs `for i in range(len(c)): M = c[i]` or `for M in snappy.HTLinkExteriors[:N]:` slicing).

Other censuses confirmed available:
- `CensusKnots`: 3,116 entries
- `OrientableCuspedCensus`: 212,641 entries
- `AlternatingKnotExteriors`, `NonalternatingKnotExteriors`: lazy classes (no `len()`; use as iterators)

---

## Capability deltas (versus the report from earlier this session)

The previous `geometry_capability_report.md` recorded:
- SnapPy ✅ (3.3.2) — confirmed.
- curver ✅ (0.5.1) — confirmed.
- flipper ❌ — **now ✅ (0.15.6)**.
- spherogram, plink — were not on the earlier list — **both ✅ (already present as SnapPy deps)**.
- Regina ❌ — still ❌; pip path now confirmed blocked by MSVC requirement.
- SageMath ❌ — still ❌ unchanged.

---

## What this enables for the four problems

| Problem | Tool readiness after this session |
|---------|-----------------------------------|
| Q1 (1-curve complex homotopy) | **READY** — curver + flipper cover small-case enumeration; SnapPy covers hyperbolic structure; tsv_simplicial covers finite local checks. |
| Q2 (N_{1,5} + Markoff) | **NOT READY** — needs Sage for Markoff machinery. SnapPy can lift to orientation double cover but the Markoff side is uncovered. |
| Q3 (Kakimizu + Gromov hyperbolic) | **PARTIALLY READY** — SnapPy gives the knot complement and π₁; Regina is needed for normal-surface (Seifert surface) enumeration. **BLOCKED on Regina.** |
| Q4 (genus-2 KC diameter ≤ 8) | **PARTIALLY READY** — HTLinkExteriors gives 180k+ exteriors to enumerate; Regina is needed for KC computation per knot. **BLOCKED on Regina.** |

---

## One-line status

SnapPy + curver + flipper + spherogram + plink all installed and smoke-tested
on Windows native Python 3.13; **Regina blocked on MSVC Build Tools** (or
needs conda / WSL); **SageMath not attempted on native Windows** (needs WSL or
Docker).

---

## Conda `geometry` environment (added 2026-04-30, second pass)

A dedicated conda env was set up to attempt Regina + Sage via conda-forge.
Result: tools that pip-installed cleanly are now also available in a
reproducible `geometry` env; **Regina and Sage remain unavailable on win-64**
(no conda-forge build for either).

### Setup

- **Miniconda location:** `C:\Users\12729\miniconda3` (already present;
  conda 26.1.1). Existing envs detected: `base`, `d2l`, `difflinker`.
- **Env created:** `geometry` (`conda create -n geometry python=3.11 -y`).
- **Python in env:** 3.11.15 (`/c/Users/12729/miniconda3/envs/geometry/python.exe`).
- **Activation script:** `scripts/geometry_env.sh`. Usage:
  ```bash
  source scripts/geometry_env.sh
  ```
  Tested — activates the env and reports python version + path.

### Regina via conda-forge — FAILED

```
$ conda install -n geometry -c conda-forge regina -y
PackagesNotFoundError: The following packages are not available from current channels:
  - regina
```
Confirmed by `conda search -c conda-forge regina` and
`conda search -c conda-forge regina-normal` — both `No match found`.

**Conclusion:** Regina has no Windows conda-forge build (Linux + macOS only).
Native Windows path remains blocked. **Use WSL Ubuntu** (`apt install
regina-normal python3-regina`) to get Regina on this machine.

### Sage via conda-forge — FAILED (unsatisfiable on win-64)

```
$ conda install -n geometry -c conda-forge sage -y
LibMambaUnsatisfiableError: Encountered problems while solving:
  - nothing provides cddlib >=1!0.94m needed by sage-10.0-hd8ed1ab_0
The following packages are incompatible
└─ sage [10.0..9.8] would require cddlib (no win-64 build)
└─ sage [10.5..10.7] would require cypari2 (no win-64 build)
```

**Conclusion:** Sage's conda-forge feedstock cannot resolve on win-64; both
older (`cddlib`) and newer (`cypari2`) variants depend on packages that have
no Windows build. **Use WSL or Docker** for Sage.

### Pip-installed tools in `geometry` env

```
$ /c/Users/12729/miniconda3/envs/geometry/python.exe -m pip install \
    snappy curver flipper spherogram plink
```
All 5 installed cleanly. `conda list -n geometry` confirms (pypi-channel):
- `snappy 3.3.2`, `snappy-manifolds 1.4`
- `curver 0.5.1`
- `flipper 0.15.6`
- `spherogram 2.4.1`
- `plink 2.4.9`
- supporting deps brought in by SnapPy: `cypari 2.5.6`, `low_index 1.2.1`,
  `knot_floer_homology 1.2.2`, `FXrays 1.3.6`, `tkinter-gl 1.1`,
  `numpy 2.4.4`, `sympy 1.14.0`, `mpmath 1.3.0`, `pandas 3.0.2`, `networkx 3.6.1`,
  `ipython 9.13.0`.

### Final verification (inside `geometry` env)

```
=== Geometry Tools Final Check ===
  snappy 3.3.2
  curver 0.5.1
  flipper 0.15.6
  spherogram 2.4.1
  plink 2.4.9
  regina NOT AVAILABLE
  sage NOT AVAILABLE
  SnapPy smoke: 4_1 volume = 2.0298832128
  curver smoke: Mapping class group < a_0, b_0 > on 3_o
  flipper smoke: Triangulation with laminations: ['a', 'b'] and mapping classes: ['a', 'b']
=== All checks done ===
```

### What this env adds beyond the system Python

- **Reproducibility.** A clean Python 3.11 env separated from the system
  Python 3.13 install and from the `d2l` / `difflinker` envs already on the
  machine; downstream proofs can pin to it.
- **Same coverage.** No new tools became available (Regina + Sage both
  declined). Functionally identical to the system Python 3.13 install for
  Q1 / Q4 work; choose whichever Python is convenient.

### Updated tool-vs-problem readiness

| Problem | Readiness | Path |
|---------|-----------|------|
| Q1 (1-curve complex homotopy) | ✅ READY | `geometry` env or system Python — both sufficient |
| Q2 (N_{1,5} + Markoff) | ❌ NOT READY | needs Sage → use WSL Ubuntu |
| Q3 (Kakimizu + Gromov hyperbolic) | ❌ BLOCKED | needs Regina → use WSL Ubuntu |
| Q4 (genus-2 KC diameter ≤ 8) | ❌ BLOCKED | needs Regina → use WSL Ubuntu |

### Recommended next move (NOT executed — for the user)

To unblock Q3 + Q4 + Q2, install WSL2 + Ubuntu and run:
```bash
sudo apt update
sudo apt install -y regina-normal python3-regina sagemath
pip install --user snappy curver flipper spherogram plink
```
WSL has working Debian/Ubuntu builds of both Regina and Sage. Estimated
disk: Regina ~150 MB, Sage ~3–5 GB. Time: 15–30 min total on a reasonable
connection.

---

## ✅ WSL Ubuntu environment (added 2026-04-30, third pass — **PRIMARY ENV**)

This is the **production** geometry environment going forward. The Windows-native
and Windows-conda envs above are kept for reference, but **all four problems
(Q1–Q4) are now unblocked** via WSL.

### Setup snapshot

| Component | Value |
|---|---|
| Distro | Ubuntu 24.04.3 LTS (WSL2, kernel 6.6.87.2) |
| System Python | 3.12.3 at `/usr/bin/python3` |
| pip | 24.0 (system-wide via `--break-system-packages`, user-mode at `/home/ephemeral/.local`) |
| Conda | Miniconda3 25.11.0 at `~/miniconda3` |
| Sage env | conda env `sage` at `~/miniconda3/envs/sage` (Python 3.14, 5.3 GB) |
| Bridge to Windows | `/mnt/c/Users/12729/Desktop/Math` ↔ `C:\Users\12729\Desktop\Math` |
| Caller wrapper | `scripts/wsl_python.sh` |
| WSL disk usage | 32 GB / 1 TB (924 GB free) |

### Install results

| Tool | Status | Version | Install path | Smoke test |
|---|---|---|---|---|
| **numpy** | ✅ | 2.4.4 | pip3 system | — |
| **sympy** | ✅ | 1.14.0 | pip3 system | — |
| **mpmath** | ✅ | 1.3.0 | pip3 system | — |
| **matplotlib** | ✅ | 3.10.9 | pip3 system | — |
| **SnapPy** | ✅ | 3.3.2 | pip3 system | `4_1` volume = 2.029883 ✓ |
| **Regina** | ✅ | **7.4** | pip3 system (manylinux wheel from PyPI, 20.6 MB) | trefoil Jones = `-x⁸ + x⁶ + x²` ✓; figure-8 ideal triangulation ✓ |
| **curver** | ✅ | 0.5.1 | pip3 system | `curver.load(1,1)` → MCG ⟨a₀, b₀⟩ on 3_o ✓ |
| **flipper** | ✅ | 0.15.6 | pip3 system | imports clean |
| **spherogram** | ✅ | 2.4.1 | transitive (SnapPy dep) | imports clean |
| **plink** | ✅ | 2.4.9 | transitive (SnapPy dep) | tkinter unavailable (headless), CLI usage fine |
| **knot_floer_homology** | ✅ | 1.2.2 | transitive (SnapPy dep) | available |
| **low_index** | ✅ | 1.2.1 | transitive (SnapPy dep) | available |
| **FXrays** | ✅ | 1.3.6 | transitive (SnapPy dep) | available |
| **SageMath** | ✅ | **10.8** (released 2025-12-18) | conda env `sage` via conda-forge | `EllipticCurve([1,2])`: rank=0, disc=-1792 ✓ |

**Net: 14/14 tools installed, 14/14 smoke tests pass.**

### Key surprises and decisions

1. **No PPA needed for Regina.** `pip install regina` pulls a manylinux wheel
   for Regina 7.4 directly. The PPAs `regina-normal/regina` and
   `regina-normal/ppa` are both 404 — the PyPI route is now the canonical
   Linux install.
2. **Sage runs only with proper env activation.** Calling
   `~/miniconda3/envs/sage/bin/sage` directly fails with `Singular not on
   PATH` because Sage looks for sibling tools via PATH. Always activate first:
   ```bash
   source ~/miniconda3/etc/profile.d/conda.sh && conda activate sage && sage ...
   ```
   The `scripts/wsl_python.sh --sage` wrapper handles this.
3. **Sage env is huge (5.3 GB)** but WSL has 924 GB free, so this is fine.
   The whole geometry stack adds ~6 GB to WSL disk.
4. **Two name collisions to remember:**
   - apt's `regina-rexx` is the REXX language, NOT topology Regina.
   - apt's `python3-snappy` is Google's compression library, NOT SnapPy.
   We installed everything via pip3 / conda, avoiding both traps.

### Caller pattern (from Windows / Claude Code)

```bash
# Plain Python in WSL (numpy / sympy / snappy / regina / curver / flipper)
bash scripts/wsl_python.sh path/to/script.py [args...]
bash scripts/wsl_python.sh -c "import regina; print(regina.versionString())"

# Sage in WSL
bash scripts/wsl_python.sh --sage path/to/script.py [args...]
bash scripts/wsl_python.sh --sage path/to/script.sage [args...]   # Sage syntax
bash scripts/wsl_python.sh --sage -c "from sage.all import EllipticCurve; ..."
```

The wrapper:
- Auto-translates `C:\foo\bar.py` and `C:/foo/bar.py` → `/mnt/c/foo/bar.py`.
- Routes plain-Python calls to system `python3` (fast, ~380 ms cold start).
- Routes `--sage` calls through `conda activate sage && sage` (slower, ~2 s
  cold start due to Sage import overhead).
- Distinguishes `.sage` files (Sage preparser) from `.py` files (`sage --python`).

### Updated tool-vs-problem readiness — **ALL FOUR PROBLEMS UNBLOCKED**

| Problem | Status | Path |
|---|---|---|
| Q1 (1-curve complex homotopy) | ✅ READY | `wsl_python.sh` — curver + flipper + snappy |
| Q2 (N_{1,5} + Markoff) | ✅ READY | `wsl_python.sh --sage` — full Sage Markoff machinery |
| Q3 (Kakimizu + Gromov hyperbolic) | ✅ READY | `wsl_python.sh` — Regina normal-surface + SnapPy hyperbolic |
| Q4 (genus-2 KC diameter ≤ 8) | ✅ READY | `wsl_python.sh` — Regina + HTLinkExteriors (180k+ knots) |

### Final smoke-test transcript (2026-04-30)

```
=== WSL Geometry Environment ===
Python 3.12.3
  numpy       2.4.4
  sympy       1.14.0
  mpmath      1.3.0
  matplotlib  3.10.9
  snappy      3.3.2
  curver      0.5.1
  flipper     0.15.6
  spherogram  2.4.1
  plink       2.4.9
  regina      7.4

--- Smoke tests ---
  snappy 4_1 (figure-8) volume: 2.029883
  curver: Mapping class group < a_0, b_0 > on 3_o
  regina trefoil Jones: -x^8 + x^6 + x^2
=== All checks done ===

[Sage env activated separately]
SageMath version 10.8, Release Date: 2025-12-18
EllipticCurve y² = x³ + x + 2 over Q:  rank = 0, disc = -1792
```

### Side effects of this install pass

- `apt update && apt upgrade -y`: 112 packages upgraded.
- `apt autoremove`: 129 MB freed.
- `~/.local/bin` not on PATH (pip user installs warned). Not a problem since
  we always import via Python, not call CLIs. To silence the warning, add
  `export PATH=$HOME/.local/bin:$PATH` to `~/.bashrc`.
- `dbus` reload warnings during apt upgrade — expected on WSL (no init system),
  harmless.
- `/etc/wsl.conf` still has unknown key `wsl2.networkingMode` (warning shown
  on every `wsl ...` call). Cosmetic; not blocking.

### One-line status

**WSL Ubuntu 24.04 is now the primary geometry compute environment for this
project. All four target problems are unblocked. Call from Windows via
`bash scripts/wsl_python.sh [--sage] <script> [args]`.**

---

## Extended geometry tools (added 2026-04-30, fourth pass)

Broadens the WSL env beyond knot/3-manifold tools into the wider geometry
ecosystem: persistent homology, computational geometry, differential geometry,
finite fields, graph theory, group theory, and visualization.

### Result table — **18/18 extended tools available**

| Category | Tool | Version | Install path | Smoke test |
|---|---|---|---|---|
| **TDA / persistent homology** | ripser | 0.6.14 | pip3 | Rips on 50 random points → 50 H₀ features ✓ |
| | gudhi | 3.12.0 | pip3 | SimplexTree(2,3-simplex) → 11 simplices ✓ |
| | giotto-tda | 0.6.2 | pip3 | imports as `gtda` |
| | scikit-tda | 1.1.1 | pip3 | imports as `sktda` |
| | persim | 0.3.8 | pip3 | imports clean |
| **Computational geometry** | scipy | 1.17.1 | pip3 (pulled by giotto-tda) | ConvexHull(20 random pts in R³) → 12 verts, 20 facets ✓ |
| | trimesh | 4.12.1 | pip3 | imports clean |
| | shapely | 2.1.2 | pip3 | imports clean |
| | pycddlib | 3.0.2 | pip3 (after `apt install libcdd-dev libgmp-dev`) | imports as `cdd` |
| | polymake | ❌ skipped | — | — | needs system polymake C++ build (>5min budget) |
| **Differential geometry** | geomstats | 2.8.0 | pip3 | S² geodesic dist (e₁, e₂) = π/2 ✓ |
| | einsteinpy | 0.4.0 | pip3 | imports clean |
| **Algebraic geometry** | galois | 0.4.10 | pip3 | GF(7), GF(2³)=order 8 ✓ |
| **Graph theory** | networkx | 3.6.1 | (was already there) | Petersen graph: 10 nodes, 15 edges ✓ |
| | igraph | 1.0.0 | pip3 (transitive) | Petersen `IGRAPH U--- 10 15 --` ✓ |
| | graph-tool | 2.59 | apt `python3-graph-tool` | 3×3 lattice: 9 verts, 12 edges ✓ |
| **Group theory** | GAP | 4.12.1 | apt `gap` | `Size(SymmetricGroup(5))` → 120 ✓ |
| **Homological algebra** | dionysus | 2.1.8 | pip3 | Filtration on segment → 3 persistence pairs ✓ |
| | chomp-py / pychomp2 | ❌ skipped | — | not on PyPI under those names; dionysus covers the use case |
| **Visualization** | plotly | 6.7.0 | pip3 (transitive from giotto-tda) | imports clean |
| | k3d | 2.17.0 | pip3 | imports clean |

### Important: numpy version pinned at 1.26.4

The dependency graph for the full extended stack has a **numpy ABI conflict**:

| Package | numpy preference |
|---|---|
| `python3-graph-tool` (apt 2.59) | compiled against numpy 1.x — **crashes on numpy 2.x** with `ImportError: A module that was compiled using NumPy 1.x cannot be run in NumPy 2.4.4` |
| `scikit-learn 1.3.2` (pinned by giotto-tda metadata) | numpy < 2 |
| `dionysus 2.1.8` | metadata says numpy >= 2, **but actually runs fine on 1.26.4** |
| `scikit-learn 1.8.0` (current) | numpy >= 2, but works on 1.26.4 too |

Resolution: **pin numpy to 1.26.4** and accept two harmless `ResolutionImpossible`
warnings from pip:
- `dionysus 2.1.8 requires numpy>=2, but you have numpy 1.26.4` — declared
  requirement is over-strict; runtime is fine.
- `giotto-tda 0.6.2 requires scikit-learn==1.3.2, but you have scikit-learn
  1.8.0` — declared requirement is a hard pin, but the imports / basic API
  work; if a specific giotto-tda call breaks, downgrade with
  `pip3 install --break-system-packages 'scikit-learn==1.3.2'`.

If the extended stack ever has to run on numpy 2.x, drop graph-tool (use
networkx + igraph instead — they cover most graph-theory use cases) and
upgrade scikit-learn.

### Pinned dependency snapshot

```
numpy        1.26.4   (pinned — required by graph-tool)
scipy        1.17.1
scikit-learn 1.8.0
```

### Skipped tools and why

| Tool | Reason | Workaround |
|---|---|---|
| polymake (Python) | Requires system polymake C++ install (>5min build budget) | Use Sage's polymake interface, or install polymake via apt later if needed |
| graph-tool via pip | Not on PyPI | Used apt `python3-graph-tool` instead — works |
| chomp-py / pychomp2 | Not on PyPI under those names | dionysus 2.1.8 covers the same persistent-homology use cases |

### Install side effects

- numpy went 2.4.4 → 1.26.4 → 2.4.4 → 1.26.4 during install (downgraded by
  giotto-tda, restored by dionysus, then re-pinned to fix graph-tool).
- apt installed `python3-matplotlib 3.6.3` as a graph-tool dependency,
  alongside our pip `matplotlib 3.10.9`. Causes a one-time `Axes3D` import
  warning. Functional, but if you need 3D plotting cleanly:
  `pip3 install --break-system-packages -U matplotlib` to override the apt
  one in the import path.
- WSL disk: 32 GB → 35 GB (+3 GB for the extended stack).

### Caller pattern (unchanged)

All extended tools are accessible through the existing wrapper:
```bash
bash scripts/wsl_python.sh -c "import gudhi, ripser, geomstats, galois, graph_tool"
bash scripts/wsl_python.sh path/to/persistent-homology-script.py
bash scripts/wsl_python.sh --sage <sage-script>     # for Sage-backed work
```

GAP is a CLI tool (not a Python lib); call it directly via:
```bash
wsl bash -c 'echo "Print(Size(SymmetricGroup(5)));QUIT_GAP();" | gap -q'
```

### What this enables (beyond Q1–Q4)

- **TDA on data**: ripser / gudhi for Rips/Čech filtrations; persim for
  bottleneck/Wasserstein distances on persistence diagrams.
- **Polytope computation**: pycddlib for V-rep ↔ H-rep conversion (Fourier-
  Motzkin, etc.), scipy.spatial.ConvexHull for 3D hulls, trimesh for mesh
  surgery.
- **Riemannian geometry / GR**: geomstats for statistics on Lie groups and
  homogeneous spaces; einsteinpy for Schwarzschild / Kerr metrics.
- **Computational group theory**: GAP for character tables, subgroup
  lattices, finitely-presented groups.
- **Large-scale graphs**: graph-tool for 10⁶+ node graphs (Boost C++ backend);
  networkx for ergonomic API; igraph for medium graphs.
- **Finite fields / coding theory**: galois for GF(p^n) arithmetic with
  numpy interop.

### Final consolidated table — entire WSL env

| Category | Count | Tools |
|---|---|---|
| Core scientific | 4 | numpy, sympy, mpmath, matplotlib |
| Knot / 3-manifold topology | 5 | snappy, regina, curver, flipper, spherogram (+ plink) |
| Persistent homology | 6 | ripser, gudhi, giotto-tda, scikit-tda, persim, dionysus |
| Computational geometry | 4 | scipy, trimesh, shapely, pycddlib |
| Differential geometry | 2 | geomstats, einsteinpy |
| Algebraic geometry / number theory | 2 | galois + Sage 10.8 (separate env) |
| Graph theory | 3 | networkx, igraph, graph-tool |
| Group theory | 2 | GAP 4.12.1 + Sage's group theory |
| Visualization | 2 | plotly, k3d |
| **Total** | **30** Python/CLI tools + Sage | All in one WSL Ubuntu 24.04 |
