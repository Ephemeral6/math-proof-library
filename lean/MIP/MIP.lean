-- Mathematical Principles of Intelligence (MIP) / Emergence Mechanics
-- Top-level module re-export
import MIP.Basic
import MIP.Axioms
import MIP.Defs.Knowledge
import MIP.Defs.Barriers
import MIP.Defs.StateSequence
-- Core theorems
import MIP.Theorems.T1_LowerBound
import MIP.Theorems.T2_UpperBound
import MIP.Theorems.T3_Entanglement
import MIP.Theorems.T4_FrameworkEquiv
import MIP.Theorems.T5_Flywheel
import MIP.Theorems.T6_Bidirectional
import MIP.Theorems.T7_Uniqueness
import MIP.Theorems.T8_OhmLaw
-- A.4-grade upgrade theorems (T.32–T.35)
import MIP.Theorems.T32_IBPhi
import MIP.Theorems.T33_UEA
import MIP.Theorems.T34_BareAugmented
import MIP.Theorems.T35_PartitionFunction
-- T.30 phase transition, T.31 FEP
import MIP.Theorems.T30_PhaseTransition
import MIP.Theorems.T31_FreeEnergy
-- Impossibility spectrum T.18.x
import MIP.Theorems.T18_1_Uncomputability
import MIP.Theorems.T18_2_NPHard
import MIP.Theorems.T18_3_SelfModel
import MIP.Theorems.T18_4_Goodhart
import MIP.Theorems.T18_5_Alignment
import MIP.Theorems.T18_6_ExtrapolationWall
import MIP.Theorems.T18_7_MetricUnification
import MIP.Theorems.T18_9_DetGap
import MIP.Theorems.T18_10_Conservation
-- Subdomain results
import MIP.Results.RSUB1_Conservation
import MIP.Results.RSUB2_Pareto
import MIP.Results.RSUB3_OverlapSynergy
import MIP.Results.RSUB4_ParameterIsolation
import MIP.Results.RSUB5_Mu0Decomposition
import MIP.Results.RSUB7_HK_Chain
import MIP.Results.RSUB8_EntropyExtremum
import MIP.Results.RSUB9_Logsumexp
import MIP.Results.RSUB10_SubdomainFreeEnergy
import MIP.Results.RSUB13_KL_Chain
-- R.x main-trunk results
import MIP.Results.R24a_EnergyConservation
import MIP.Results.R51_DynamicSwitching
import MIP.Results.R55_UncertaintyShrink
import MIP.Results.R57_Rho
import MIP.Results.R58_CapabilityOrder
import MIP.Results.R59_Flywheel
import MIP.Results.R62_KKTMarginalEquality
import MIP.Results.R69_BidirectionalSaturation
import MIP.Results.R73_BarrierTrichotomy
import MIP.Results.R74_TypeE_Asymptotic
import MIP.Results.R79_Grokking
import MIP.Results.R89_VarN_Decomposition
import MIP.Results.R90_SigmaZ_Zero
import MIP.Results.R91_StabilityBound
import MIP.Results.R92_SigmaZ_Xi_Orthogonality
import MIP.Results.R93_SigmaZ_TopBound
import MIP.Results.R96_AutonomousTransition
import MIP.Results.R99_Subadditivity
import MIP.Results.R102_UnimodalTransition
import MIP.Results.R103_BarrierMonotone
-- Duality branch results (R.131-R.146)
import MIP.Results.R131_SymmetricSaturation
import MIP.Results.R132_Conservation
import MIP.Results.R133_EStarDichotomy
import MIP.Results.R134_NStarUShape
import MIP.Results.R137_TeachingPower
import MIP.Results.R138_ExternalAidIndex
import MIP.Results.R139_CollaborationSavings
import MIP.Results.R140_TeachingIrreversibility
import MIP.Results.R142_DualAlgebra
import MIP.Results.R143_Committee
import MIP.Results.R144_MutualInformation
import MIP.Results.R146_IdealCurriculum
-- Categorical formalization (R.458)
import MIP.Results.R458_S2Decomposition
-- Decay branch results (R.152, R.156, R.157)
import MIP.Results.R152_CollapseTime
import MIP.Results.R156_HalfLife
import MIP.Results.R157_DecayGompertz
-- Corollaries
import MIP.Corollaries.C12_FreeEnergy
