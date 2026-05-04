import Lake
open Lake DSL

package optext where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩
  ]

@[default_target]
lean_lib OptExt where

require optlib from "../optlib"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.13.0"
