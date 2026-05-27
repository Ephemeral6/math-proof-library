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
import MIP.Results.RSUB11_ReciprocalFreeEnergy
import MIP.Results.RSUB12_KnowledgeMeasureSpace
import MIP.Results.RSUB14_CtrainKLBound
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
-- R.x main-trunk results (2026-05 formalization batch)
import MIP.Results.R19_OptimalQuestioner
import MIP.Results.R22_CivilizationTrichotomy
import MIP.Results.R25_SecondDifficultyDim
import MIP.Results.R26_PositiveImpedance
import MIP.Results.R56_SingularityTime
import MIP.Results.R98_GompertzKappa
import MIP.Results.R40_CriticalPathBound
import MIP.Results.R41_ParallelSpeedup
import MIP.Results.R76_TotalDifferential
import MIP.Results.R80_GrokkingCrossing
import MIP.Results.R97_TwoPhaseTransitions
-- A.4 cognitive-boundary companion results (R.800-R.807, N.7)
import MIP.Results.N7_OrbitInvariance
import MIP.Results.R800_BoundaryLowerBound
import MIP.Results.R802_QuestionerAnonymity
import MIP.Results.R805_AugmentationGain
import MIP.Results.R806_AugmentationCoverage
import MIP.Results.R807_RAGIndistinguishability
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
import MIP.Results.R135_ReversibilityContrast
import MIP.Results.R136_AsymDynamics
-- Categorical formalization (R.458)
import MIP.Results.R458_S2Decomposition
-- Decay branch results (R.152, R.156, R.157)
import MIP.Results.R152_CollapseTime
import MIP.Results.R156_HalfLife
import MIP.Results.R157_DecayGompertz
-- Round-2 derived leftovers (2026-05 hypothesis-bundle batch)
import MIP.Results.R2_DensityObservable
import MIP.Results.R13_AIMetacogOnAI
import MIP.Results.R21_BoundsEstimable
import MIP.Results.R31w_KappaIndependence
import MIP.Results.R37w_MetacogTraining
import MIP.Results.R42_KappaMeasurable
import MIP.Results.R47t_SigmaTopology
import MIP.Results.R60_UncertaintyNontrivial
import MIP.Results.R61w_NonIIDBounds
import MIP.Results.R63_UnimodalSTransition
import MIP.Results.R86_DiagonalSeparation
import MIP.Results.R94_VarianceDominance
import MIP.Results.R95_ScalingLaw
import MIP.Results.R101_DiagonalFamily
import MIP.Results.R104_EdgeObservable
-- Round-2 duality-branch extras (R.141/145/147)
import MIP.Results.R141_SelfAidDecay
import MIP.Results.R145_CollaborationThermodynamics
import MIP.Results.R147_CumulativeMutualInfo
-- Thermodynamics branch (R.267-R.281)
import MIP.Results.R267_FreeEnergy
import MIP.Results.R268_PhaseDiagram
import MIP.Results.R269_CVJump
import MIP.Results.R270_FDT
import MIP.Results.R271_CorrelationLength
import MIP.Results.R272_Ginzburg
import MIP.Results.R273_WilsonFisher1Loop
import MIP.Results.R274_EffectiveDim
import MIP.Results.R275_DoubleDescent
import MIP.Results.R276_Tricritical
import MIP.Results.R277_CouplingFormula
import MIP.Results.R278_ArrheniusForgetting
import MIP.Results.R279_EmergentAlgebra
import MIP.Results.R280_WilsonFisher2Loop
import MIP.Results.R281_Jarzynski
-- Computability / complexity (reduction-transfer kernels)
import MIP.Results.R16_WeakUncomputable
import MIP.Results.R83_Uncomputable
import MIP.Results.R84_FiniteUndecidable
import MIP.Results.R85_BoundedN_NPHard
import MIP.Results.R100_OptimalOrder_NPHard
-- Theory-unification: degenerations (R.400-R.407)
import MIP.Results.R400_ICL_Degeneration
import MIP.Results.R401_MoE_Partition
import MIP.Results.R402_RLHF_KL
import MIP.Results.R404_ConstitutionalAI
import MIP.Results.R406_PACBayes
import MIP.Results.R407_Goodhart
-- Friston FEP unification (R.408-R.410)
import MIP.Results.R408_FristonDegeneration
import MIP.Results.R409_FristonVariableMap
import MIP.Results.R410_FristonPropositions
-- Multi-agent FEP (R.412-R.417)
import MIP.Results.R412_ActiveInferenceDual
import MIP.Results.R413_InteractiveFEP
import MIP.Results.R414_CommunicativeAI
import MIP.Results.R415_GeneralizedSynchrony
import MIP.Results.R417_JointFreeEnergy
-- CoE primitives R/T/C/P (R.421-R.433)
import MIP.Results.R421_RPrimitive
import MIP.Results.R422_TPrimitive
import MIP.Results.R423_CPrimitive
import MIP.Results.R424_PrimitiveInteraction
import MIP.Results.R425_OptimalAllocation
import MIP.Results.R426_DomainSpecificity
import MIP.Results.R427_ReasoningSchedule
import MIP.Results.R428_BarrierThreshold
import MIP.Results.R429_GompertzMultiRound
import MIP.Results.R430_EngineBlindSpot
import MIP.Results.R431_ContextSaturation
import MIP.Results.R432_PluralityPrimitive
import MIP.Results.R433_FourPrimitives
-- Categorical formalization (R.450-R.461)
import MIP.Results.R450_KappaTowerMagma
import MIP.Results.R451_FreeCategory
import MIP.Results.R452_TrainingColimit
import MIP.Results.R453_PhaseFunctor
import MIP.Results.R454_GradientLens
import MIP.Results.R455_TrainingNatTrans
import MIP.Results.R456_FreeMonoidUniversal
import MIP.Results.R457_DialogueCospan
import MIP.Results.R459_PartialOperad
import MIP.Results.R460_SeparableProfunctor
import MIP.Results.R461_YonedaBehavior
-- Round-3: §1 B-grade leftovers
import MIP.Results.R3w_PhaseExists
import MIP.Results.R10_TypeIITwoStage
import MIP.Results.R24b_ThermoTempEntropy
import MIP.Results.R37s_StrictMetacogOptimal
import MIP.Results.R61s_CompactForm
import MIP.Results.R75_XiMeasurement
import MIP.Results.R77_PartialDerivatives
import MIP.Results.R78_TrainingMethodDiff
import MIP.Results.R82_RhoDynamics
import MIP.Results.R87_ComplexityHierarchy
import MIP.Results.R803_ExpertAdvantage
-- Round-3: §2 early thermodynamics (R.119-125)
import MIP.Results.R119_MeanFieldExponents
import MIP.Results.R120_FreeEnergyShannon
import MIP.Results.R121_ConservationLaw
import MIP.Results.R122_BoltzmannHTheorem
import MIP.Results.R123_TwoTemperature
import MIP.Results.R125_SOn
-- Round-3: §2 Asym-Wasserstein bridge + exact scaling
import MIP.Results.R148_AsymWassersteinBridge
import MIP.Results.R148a_AsymPseudometric
import MIP.Results.R148b_ConservationWasserstein
import MIP.Results.R150_ExactScaling
import MIP.Results.R150a_ChinchillaDegeneration
-- Round-3: §3 simplicial homology (R.462-466) + partial operad (R.468-473)
import MIP.Results.R462_VietorisRips
import MIP.Results.R463_H1Dimension
import MIP.Results.R464_HomologyDecay
import MIP.Results.R465_PhaseStratification
import MIP.Results.R466_TopologicalLowerBound
import MIP.Results.R468_PartialOperadUpgrade
import MIP.Results.R470_KappaSatCardinality
import MIP.Results.R473_PartialOperadRefinement
-- Round-3: §3 gamma-kappa scaling exponent
import MIP.Results.R418_GammaKappa
import MIP.Results.RNEWPAC_GammaNonderivability
-- Round-3 §2 geometry/frontier (R.105-118)
import MIP.Results.R105_KappaReversibility
import MIP.Results.R106_KappaFisherMetric
import MIP.Results.R107_NoetherConservation
import MIP.Results.R108_MipIncompleteness
import MIP.Results.R109_IStarLowerBound
import MIP.Results.R110_KappaEstimable
import MIP.Results.R111_MinimalActionEL
import MIP.Results.R112_BarrierObjectivity
import MIP.Results.R113_ConjunctionSubadditivity
import MIP.Results.R114_ZinvKappaNonMonotone
import MIP.Results.R115_NMetaTwoStage
import MIP.Results.R116_EntropyVarianceLink
import MIP.Results.R117_ThermoCorrespondence
import MIP.Results.R118_FisherNaturalGradient
-- Round-3 §3 computation branch (R.163-176)
import MIP.Results.R163_TractabilityDichotomy
import MIP.Results.R164_GreedyApproximation
import MIP.Results.R165_ArithmeticHierarchy
import MIP.Results.R166_ParameterizedComplexity
import MIP.Results.R167_SelfExternalImpedance
import MIP.Results.R168_BlindSpotMeasure
import MIP.Results.R169_OutOfFrameQuestioner
import MIP.Results.R170_AverageCaseComputability
import MIP.Results.R171_BPPN_NoSpeedup
import MIP.Results.R172_MIPRice
import MIP.Results.R173_KolmogorovLowerBound
import MIP.Results.R174_CommunicationLowerBound
import MIP.Results.R175_DecayBoundedN_NPHard
import MIP.Results.R176_MaintSched_SetCover
-- Round-3 §4 candidate block R.500-800+ (autonomous exploration, not human-audited)
import MIP.Results.R502_LatticeMeetJoin
import MIP.Results.R510_MultiAgentN
import MIP.Results.R520_SymplecticDissipative
import MIP.Results.R527_AsymMetricFamily
import MIP.Results.R551_CollectiveDuality
import MIP.Results.R554_ReasoningWallDegeneration
import MIP.Results.R560_ShannonDictionary
import MIP.Results.R566_FisherFlat
import MIP.Results.R600_LearningOT
import MIP.Results.R700_EntropyPower
import MIP.Results.R730_AgentsMonoid
import MIP.Results.R740_GameTheory
import MIP.Results.R750_RenyiFamily
import MIP.Results.R790_FreeMonoidNoInverse
import MIP.Results.RBN_BayesianNetwork
import MIP.Results.RFCL_FormalConceptLattice
import MIP.Results.RMKH_MobiusKappa
-- Round-4: remaining R.500-800+ candidate kernels
import MIP.Results.R314_BrenierSubdifferential
import MIP.Results.R518_DecayGrokkingSuppression
import MIP.Results.R522_GradientFlow
import MIP.Results.R523_NonKahler
import MIP.Results.R524_ContactStructure
import MIP.Results.R530_SelfRefCollective
import MIP.Results.R530_ITAHLFMeta
import MIP.Results.R539_AsymRefutation
import MIP.Results.R540_FisherHalfSpace
import MIP.Results.R560t_ThermoDualityNoether
import MIP.Results.R770_Cj55Complement
import MIP.Results.R81ab_DoubleDescentSplit
import MIP.Results.RMKH2_MobiusTail
import MIP.Results.RFCL2_ConceptLatticeTail
import MIP.Results.RBN2_BayesNetTail
-- Round-4: IT impossibility theorems (IT.5-14, meta)
import MIP.Results.IT5_AtomicBarrierCoNPHard
import MIP.Results.IT6_NoPACLearn
import MIP.Results.IT7_BehaviorPi2Complete
import MIP.Results.IT7b_KMembershipNbiBounds
import MIP.Results.IT8_CeSigma2Complete
import MIP.Results.IT9_PolytopeExtension
import MIP.Results.IT10_FanoTimeLowerBound
import MIP.Results.IT10b_F4FourPath
import MIP.Results.IT11_PreorderCoNPHard
import MIP.Results.IT12_NOFCommunication
import MIP.Results.IT13_SigmaStarUnique
import MIP.Results.IT14_MultiYW1Hard
-- Corollaries
import MIP.Corollaries.C12_FreeEnergy
-- Foundational lemmas L.1-L.7, L.3*, L.F (2026-05-27 gap-closure batch)
import MIP.Lemmas.L1_DeltaRobustness
import MIP.Lemmas.L2_AtomicExistence
import MIP.Lemmas.L3_AtomicLower
import MIP.Lemmas.L4_AtomicUpper
import MIP.Lemmas.L5_AtomicExact
import MIP.Lemmas.L3star_ReverseAtomic
import MIP.Lemmas.L6_UnidirectionalAH
import MIP.Lemmas.L7_UnidirectionalHA
import MIP.Lemmas.LF_FrameCompat
-- Corollaries C.1-C.8, C.10, C.11 (2026-05-27 gap-closure batch)
import MIP.Corollaries.C1_Finiteness
import MIP.Corollaries.C2_Solvability
import MIP.Corollaries.C3_FrameworkValue
import MIP.Corollaries.C4_NoviceExpert
import MIP.Corollaries.C5_Decomposability
import MIP.Corollaries.C6_PosetMonotone
import MIP.Corollaries.C7_UnifiedMetric
import MIP.Corollaries.C8_MetacogSubstitution
import MIP.Corollaries.C10_BidirectionalStrict
import MIP.Corollaries.C11_BidirectionalLowerBound
-- R.72 xi-cooperation bound (2026-05-27)
import MIP.Results.R72_XiCooperationBound
-- Collaboration-dynamics branch R.810-R.820 (block 19, audited 2026-05-27)
import MIP.Results.R810_SilenceCollapse
import MIP.Results.R811_CollabFano
import MIP.Results.R813_JointCoverage
import MIP.Results.R814_CompositionGap
import MIP.Results.R815_NoInjection
import MIP.Results.R816_FlywheelTrap
import MIP.Results.R817_InterventionReach
import MIP.Results.R818_KappaCumulativeMonotone
import MIP.Results.R819_ExpertDilution
import MIP.Results.R820_MuOrthogonal
-- Phase-2 gap-closure: canonical R.150-R.509 branch results (2026-05-27)
-- Geometry branch (R.201-R.213)
import MIP.Results.R201_ZInvFisherMetric
import MIP.Results.R202_KHkFisherMetric
import MIP.Results.R206_SigmaNormal4D
import MIP.Results.R207_SigmaZFisherCurvature
import MIP.Results.R208_GeodesicVsSteepest
import MIP.Results.R210_Sigma0Embedding
import MIP.Results.R211_KillingNoether
import MIP.Results.R212_FocalTimeChaos
import MIP.Results.R213_ThreeTrajectory
-- Collective branch (R.500-R.508)
import MIP.Results.R500_CoverageMonotonicity
import MIP.Results.R501_DiversityRedundancy
import MIP.Results.R502_StarTopology
import MIP.Results.R503_ConnectivityBound
import MIP.Results.R504_DiversityTransition
import MIP.Results.R505_GeneralistSpecialist
import MIP.Results.R506_CommConvergence
import MIP.Results.R508_CoverageDecayRobust
-- Decay branch (R.190-R.197)
import MIP.Results.R190_DecayInflatesN
import MIP.Results.R192_MaintLearnTradeoff
import MIP.Results.R193_DecayLearnTransition
import MIP.Results.R194_DecayModifiedOhm
import MIP.Results.R195_FiveDPhaseSpace
import MIP.Results.R197_HeteroDecayScaling
-- Sociology branch (R.350-R.353)
import MIP.Results.R350_EduOptimalAllocation
import MIP.Results.R352_CivilizationPhase
import MIP.Results.R353_CollabInequality
-- Parallel emergence (R.175-R.177, Brent)
import MIP.Results.R175_BrentLowerBound
import MIP.Results.R176_BrentUpperBound
import MIP.Results.R177_DAGGeometrySignal
