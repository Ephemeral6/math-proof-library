/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: LeanAgent

# OptLib2 — Optimization theory in Lean 4

A self-contained library for first-order optimization theory, depending only
on Mathlib. Provides definitions of L-smooth and convex functions, the
proximal operator, and convergence proofs for gradient descent (`O(1/T)`),
proximal gradient (`O(1/T)`), and Nesterov's accelerated proximal gradient
(`O(1/T²)`).
-/

import LeanAgent.OptLib2.Basic.Defs
import LeanAgent.OptLib2.Basic.Smoothness
import LeanAgent.OptLib2.Basic.Convexity
import LeanAgent.OptLib2.Proximal.Defs
import LeanAgent.OptLib2.Proximal.Properties
import LeanAgent.OptLib2.Algorithms.GradientDescent
import LeanAgent.OptLib2.Algorithms.ProximalGradient
import LeanAgent.OptLib2.Algorithms.Nesterov
