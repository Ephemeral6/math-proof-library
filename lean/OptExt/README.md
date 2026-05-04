# OptExt

Extension library on top of [optlib](https://github.com/optsuite/optlib) — provides
optimization-theory results that optlib does not yet cover (stochastic methods,
momentum, lower bounds, mirror descent, Frank–Wolfe, …).

## Layout

```
OptExt/
├── lakefile.lean         require optlib (path) + mathlib v4.13.0
├── lean-toolchain        leanprover/lean4:v4.13.0
└── OptExt/
    ├── StochasticOracle.lean   (Layer 1) SFO, unbiased + bounded variance
    ├── SGD.lean                (Layer 1) O(σ/√T + LD²/T) for the running average
    └── HeavyBall.lean          (Layer 1) SHB + Goujaud feasibility region
```

## Build

```bash
cd OptExt
lake update          # populate .lake/packages (needs network)
lake exe cache get   # fetch precompiled mathlib oleans
lake build           # compile OptExt skeleton
```

All theorems are currently `sorry`.  Type-checking is the goal at this stage.

## Roadmap

* **Layer 1 (current):** stochastic oracle, SGD, stochastic Heavy Ball.
* **Layer 2:** lower bounds — oracle complexity model, Nesterov `Ω(1/T²)`,
  SGD `Ω(σ/√T)`.
* **Layer 3:** mirror descent, Frank–Wolfe, accelerated proximal under strong
  convexity, last-iterate analyses.
