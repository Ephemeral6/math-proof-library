/-
MIP open-conjecture attempts (2026-05-27).

Each module formalizes one open conjecture from
`~/Desktop/MIP/conjectures/index.md` and records a VERDICT:
  PROVED   — full sorry-free proof of a faithful formalization,
  REFUTED  — explicit counterexample to a faithful formalization,
  OPEN     — faithful statement + sorry-free partial lemmas + a
             documented "BLOCKED AT / MISSING" account (no sorry).

This aggregator imports every attempt so `lake build MIP.Conjectures`
checks them all. Superseded (already-R) and falsified conjectures are
omitted. None of these introduce `sorry` or new axioms.
-/

-- Partition-function / path-structure family
import MIP.Conjectures.CjNEW4_PartitionKLBridge
import MIP.Conjectures.CjNEW3_EtaCovTwoTransitions
import MIP.Conjectures.CjNEW2_MuPathKappa
import MIP.Conjectures.CjNEW1_GainGompertz
-- μ₀ measurement family
import MIP.Conjectures.CjNEW5_DeterministicCoding
import MIP.Conjectures.CjNEW10_Mu0MaxTempInvariant
import MIP.Conjectures.CjNEW11_Mu0RateLimit
import MIP.Conjectures.CjNEW12_Mu0EtaCovTight
import MIP.Conjectures.CjNEW8_Mu0RhoTight
import MIP.Conjectures.CjNEW9_SFTSharpensRho
import MIP.Conjectures.CjNEW13_HpiMaxAtTStar
import MIP.Conjectures.CjNEW14_VertexAbsorption
-- Candidate refutations
import MIP.Conjectures.Cj31_HkVarNNegCorr
import MIP.Conjectures.Cj52_UncertaintyPrinciple
import MIP.Conjectures.Cj4_ZselfExpectation
-- Meta / universality
import MIP.Conjectures.Cj7_MeanFieldUniversality
import MIP.Conjectures.Cj13_CrossoverScaling
import MIP.Conjectures.Cj18_RenormalizationGroup
import MIP.Conjectures.Cj11_Completeness
-- Education / observability
import MIP.Conjectures.Cj40_KappaAdvantage
import MIP.Conjectures.Cj41_EducationPriority
import MIP.Conjectures.Cj42_QuestionerRole
import MIP.Conjectures.Cj6_DAGObservability
-- Quantum / biology / architecture / scaling
import MIP.Conjectures.Cj43_QuantumEmergence
import MIP.Conjectures.Cj46_EmergenceBiology
import MIP.Conjectures.Cj48_ArchitectureRepresentation
import MIP.Conjectures.Cj50_GammaKappaScaling
